using Microsoft.VisualBasic.FileIO;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection.Emit;

namespace PetCollectorUtils.Csv
{
  public class CsvParser
  {
    public void ParseCsvData(ref Dictionary<int, Pet> petsBySpeciesId)
    {
      var soundIdKeysByDisplayId = GetSoundIdKeysByDisplayId();
      var npcSoundsByNpcSoundIDKey = GetNpcSoundIdsByNpcSoundIdKey();
      var creatureSoundIdsBySoundIdKey = GetCreatureSoundIdsBySoundIdKey();
      ParseSpeciesData(ref petsBySpeciesId);

      var petsByCompanionId = HashPetsByCompanionId(petsBySpeciesId.Values);
      GetCreatureInfo(ref petsByCompanionId, soundIdKeysByDisplayId, creatureSoundIdsBySoundIdKey, npcSoundsByNpcSoundIDKey);

      GetBaseStats(ref petsBySpeciesId);
    }

    private string downloadCSV(string table)
    {
      string csv = null;
      using (WebClient client = new WebClient()) // WebClient class inherits IDisposable
      {
        csv = client.DownloadString($"https://wago.tools/db2/{table}/csv");
      }

      return csv;
    }

    private Dictionary<int, Pet> HashPetsByCompanionId(IEnumerable<Pet> pets)
    {
      var result = new Dictionary<int, Pet>();

      foreach (var pet in pets)
        result.Add(pet.companionID, pet);

      return result;
    }

    private void ParseSpeciesData(ref Dictionary<int, Pet> petsBySpeciesId)
    {
      var csv = downloadCSV("BattlePetSpecies");
      var parser = new TextFieldParser(new StringReader(csv));
      parser.SetDelimiters(",");

      var flavorIndex = -1;
      var speciesIdIndex = -1;
      var creatureIdIndex = -1;
      var iconIndex = -1;
      var familyIndex = -1;
      var flagsIndex = -1;
      var sourceTypeIndex = -1;
      
      var keys = parser.ReadFields();
      for (var i = 0; i < keys.Length; i++)
      {
        if (keys[i] == "Description_lang")
          flavorIndex = i;
        else if (keys[i] == "ID")
          speciesIdIndex = i;
        else if (keys[i] == "CreatureID")
          creatureIdIndex = i;
        else if (keys[i] == "IconFileDataID")
          iconIndex = i;
        else if (keys[i] == "PetTypeEnum")
          familyIndex = i;
        else if (keys[i] == "Flags")
          flagsIndex = i;
        else if (keys[i] == "SourceTypeEnum")
          sourceTypeIndex = i;
      }

      while (!parser.EndOfData)
      {
        var items = parser.ReadFields();

        var flags = (CsvFlags)Convert.ToInt32(items[flagsIndex]);
        if (flags.HasFlag(CsvFlags.HideFromJournal))
          continue;

        var sourceType = (CsvSourceType)Convert.ToInt32(items[sourceTypeIndex]);
        //if (sourceType == CsvSourceType.Unknown) //blizz sometimes screws up and leaves the source as -1 even though the pet is now obtainable
        //  continue;

        var speciesIdStr = items[speciesIdIndex];
        var speciesId = Convert.ToInt32(speciesIdStr);
        var haveExistingPet = petsBySpeciesId.TryGetValue(speciesId, out var pet);
        if (haveExistingPet)
          continue;

        pet = new Pet(speciesId);
        petsBySpeciesId.Add(speciesId, pet);
        Console.WriteLine($"Creating species {speciesIdStr} in csvParser");

        pet.flavor = items[flavorIndex].Replace(Environment.NewLine, "\\n");
        pet.companionID = Convert.ToInt32(items[creatureIdIndex]);
        pet.icon = items[iconIndex];
        pet.family = Convert.ToInt32(items[familyIndex])+1; //convert from 0-index to 1-index
        pet.isTradable = !flags.HasFlag(CsvFlags.NotTradable);
        pet.isWild = flags.HasFlag(CsvFlags.Capturable);
        pet.isUnique = flags.HasFlag(CsvFlags.LegacyAccountUnique);
        pet.isPassive = flags.HasFlag(CsvFlags.CantBattle);
        pet.source = SourceTypeToString(sourceType);

        //IsUnobtainable
      }
    }

    private void GetCreatureInfo(ref Dictionary<int, Pet> petsByCompanionID, Dictionary<int, string> soundIdKeysByDisplayId, Dictionary<int, string> creatureSoundIdsBySoundIdKey,
                                 Dictionary<int, string> npcSoundsByNpcSoundIDKey)
    {
      var csv = downloadCSV("Creature");
      var parser = new TextFieldParser(new StringReader(csv));
      parser.SetDelimiters(",");

      var companionIdIndex = -1;
      var nameIndex = -1;
      var dispId1Index = -1;
      var dispId2Index = -1;
      var dispId3Index = -1;
      var dispId4Index = -1;
      var dispProbability1Index = -1;
      var dispProbability2Index = -1;
      var dispProbability3Index = -1;
      var dispProbability4Index = -1;

      var keys = parser.ReadFields();
      for (var i = 0; i < keys.Length; i++)
      {
        if (keys[i] == "ID")
          companionIdIndex = i;
        else if (keys[i] == "Name_lang")
          nameIndex = i;
        else if (keys[i] == "DisplayID_0")
          dispId1Index = i;
        else if (keys[i] == "DisplayID_1")
          dispId2Index = i;
        else if (keys[i] == "DisplayID_2")
          dispId3Index = i;
        else if (keys[i] == "DisplayID_3")
          dispId4Index = i;
        else if (keys[i] == "DisplayProbability_0")
          dispProbability1Index = i;
        else if (keys[i] == "DisplayProbability_1")
          dispProbability2Index = i;
        else if (keys[i] == "DisplayProbability_2")
          dispProbability3Index = i;
        else if (keys[i] == "DisplayProbability_3")
          dispProbability4Index = i;
      }

      while (!parser.EndOfData)
      {
        var items = parser.ReadFields();

        var companionID = Convert.ToInt32(items[companionIdIndex]);
        if (petsByCompanionID.TryGetValue(companionID, out var pet))
        {
          pet.name = items[nameIndex];

          //https://www.warcraftmounts.com/multi_look_companions.php
          var dispId1 = Convert.ToInt32(items[dispId1Index]);
          var dispId2 = Convert.ToInt32(items[dispId2Index]);
          var dispId3 = Convert.ToInt32(items[dispId3Index]);
          var dispId4 = Convert.ToInt32(items[dispId4Index]);
          if (dispId1 > 0)
          {
            var probability = Convert.ToDouble(items[dispProbability1Index]);
            pet.variants.Add(new Variant(dispId1, probability));
          }
          if (dispId2 > 0)
          {
            var probability = Convert.ToDouble(items[dispProbability2Index]);
            if (probability > 0)
              pet.variants.Add(new Variant(dispId2, probability));
            else Console.WriteLine($"impossible variant {pet.speciesID} 2");
          }
          if (dispId3 > 0)
          {
            var probability = Convert.ToDouble(items[dispProbability3Index]);
            if (probability > 0)
              pet.variants.Add(new Variant(dispId3, probability));
            else Console.WriteLine($"impossible variant {pet.speciesID} 3");
          }
          if (dispId4 > 0)
          {
            var probability = Convert.ToDouble(items[dispProbability4Index]);
            if (probability > 0)
              pet.variants.Add(new Variant(dispId4, probability));
            else Console.WriteLine($"impossible variant {pet.speciesID} 4");
          }
          ConvertProbabilityToPercentChance(pet.variants);

          //for now let's just assume each displayID has the same sounds assocaited with it
          if (soundIdKeysByDisplayId.TryGetValue(dispId1, out var soundKeys))
          {
            var soundKeysSplit = soundKeys.Split(',');
            var soundId = Convert.ToInt32(soundKeysSplit[0]);
            var npcSoundId = Convert.ToInt32(soundKeysSplit[1]);

            if (npcSoundId > 0)
            {
              if (npcSoundsByNpcSoundIDKey.TryGetValue(npcSoundId, out var npcSounds))
              {
                var npcSoundsSplit = npcSounds.Split(',');
                foreach (var npcSoundStr in npcSoundsSplit)
                  pet.npcSoundIDs.Add(Convert.ToInt32(npcSoundStr));
              }
            }

            if (soundId > 0)
            {
              if (creatureSoundIdsBySoundIdKey.TryGetValue(soundId, out var soundPairs))
              {
                var soundPairsSplit = soundPairs.Split(',');
                foreach (var soundPair in soundPairsSplit)
                {
                  var soundPairSplit = soundPair.Split(';');
                  var soundKey = soundPairSplit[0];
                  var sound = Convert.ToInt32(soundPairSplit[1]);
                  pet.creatureSoundIDs.Add($"{soundKey}_{sound}");
                }
              }
            }
          }
        }
      }
    }

    private void GetBaseStats(ref Dictionary<int, Pet> petsBySpeciesId)
    {
      var csv = downloadCSV("BattlePetSpeciesState");
      var parser = new TextFieldParser(new StringReader(csv));
      parser.SetDelimiters(",");

      var statTypeIndex = -1;
      var speciesIdIndex = -1;
      var valueIndex = -1;
      var keys = parser.ReadFields();
      for (var i = 0; i < keys.Length; i++)
      {
        if (keys[i] == "BattlePetSpeciesID")
          speciesIdIndex = i;
        else if (keys[i] == "BattlePetStateID")
          statTypeIndex = i;
        else if (keys[i] == "Value")
          valueIndex = i;
      }

      while (!parser.EndOfData)
      {
        var items = parser.ReadFields();

        var speciesId = Convert.ToInt32(items[speciesIdIndex]);
        if (petsBySpeciesId.TryGetValue(speciesId, out var pet))
        {
          var value = Convert.ToInt32(items[valueIndex]);
          var statType = items[statTypeIndex];
          var newValue = 8 + (value / 200d);
          var priorValue = -1d;
          var statName = "";
          if (statType == "18")
          {
            statName = "power";
            priorValue = pet.baseStats[1];
            pet.baseStats[1] = newValue;
          }
          else if (statType == "19")
          {
            statName = "health";
            priorValue = pet.baseStats[0];
            pet.baseStats[0] = newValue;
          }
          else if (statType == "20")
          {
            statName = "speed";
            priorValue = pet.baseStats[2];
            pet.baseStats[2] = newValue;
          }

          if (priorValue != newValue && priorValue != -1)
            Console.WriteLine($"{pet.speciesID} {statName} from {priorValue} to {newValue}");
        }
      }
    }

    private Dictionary<int, string> GetSoundIdKeysByDisplayId()
    {
      var result = new Dictionary<int, string>();
      var csv = downloadCSV("CreatureDisplayInfo");
      var parser = new TextFieldParser(new StringReader(csv));
      parser.SetDelimiters(",");

      var dispIdIndex = -1;
      var soundIdIndex = -1;
      var npcSoundIdIndex = -1;
      var keys = parser.ReadFields();
      for (var i = 0; i < keys.Length; i++)
      {
        if (keys[i] == "ID")
          dispIdIndex = i;
        else if (keys[i] == "SoundID")
          soundIdIndex = i;
        else if (keys[i] == "NPCSoundID")
          npcSoundIdIndex = i;
      }

      while (!parser.EndOfData)
      {
        var items = parser.ReadFields();
        var displayId = Convert.ToInt32(items[dispIdIndex]);
        var soundId = items[soundIdIndex];
        var npcSoundId = items[npcSoundIdIndex];
        result.Add(displayId, $"{soundId},{npcSoundId}");
      }

      return result;
    }

    private Dictionary<int, string> GetNpcSoundIdsByNpcSoundIdKey()
    {
      var result = new Dictionary<int, string>();
      var csv = downloadCSV("NPCSounds");
      var parser = new TextFieldParser(new StringReader(csv));
      parser.SetDelimiters(",");

      var npcSoundIdIndex = -1;
      var id0Index = -1;
      var id1Index = -1;
      var id2Index = -1;
      var id3Index = -1;
      var keys = parser.ReadFields();
      for (var i = 0; i < keys.Length; i++)
      {
        if (keys[i] == "ID")
          npcSoundIdIndex = i;
        else if (keys[i] == "SoundID_0")
          id0Index = i;
        else if (keys[i] == "SoundID_1")
          id1Index = i;
        else if (keys[i] == "SoundID_2")
          id2Index = i;
        else if (keys[i] == "SoundID_3")
          id3Index = i;
      }

      while (!parser.EndOfData)
      {
        var items = parser.ReadFields();
        var npcSoundId = Convert.ToInt32(items[npcSoundIdIndex]);
        if (npcSoundId == 0)
          continue;

        var soundId0 = items[id0Index];
        var soundId1 = items[id1Index];
        var soundId2 = items[id2Index];
        var soundId3 = items[id3Index];
        var sounds = new List<string>();
        if (soundId0 != "0")
          sounds.Add(soundId0);
        if (soundId1 != "0" && soundId1 != soundId0)
          sounds.Add(soundId1);
        if (soundId2 != "0" && soundId2 != soundId0)
          sounds.Add(soundId2);
        if (soundId3 != "0" && soundId3 != soundId0)
          sounds.Add(soundId3);

        result.Add(npcSoundId, string.Join(",", sounds));
      }

      return result;
    }

    private Dictionary<int, string> GetCreatureSoundIdsBySoundIdKey()
    {
      var result = new Dictionary<int, string>();

      var csv = downloadCSV("CreatureSoundData");
      var parser = new TextFieldParser(new StringReader(csv));
      parser.SetDelimiters(",");

      var soundIdIndex = -1;
      var keys = parser.ReadFields();
      var keepers = new List<int>();
      var keeperNames = new List<int>();
      for (var i = 0; i < keys.Length; i++)
      {
        switch(keys[i])
        {
          case "ID":
            soundIdIndex = i;
            break;
          case "SoundExertionID":
            keepers.Add(i);
            keeperNames.Add(1);
            break;
          case "SoundExertionCriticalID":
            keepers.Add(i);
            keeperNames.Add(2);
            break;
          case "SoundInjuryID":
            keepers.Add(i);
            keeperNames.Add(3);
            break;
          case "SoundInjuryCriticalID":
            keepers.Add(i);
            keeperNames.Add(4);
            break;
          case "SoundInjuryCrushingBlowID":
            keepers.Add(i);
            keeperNames.Add(5);
            break;
          case "SoundDeathID":
            keepers.Add(i);
            keeperNames.Add(6);
            break;
          case "SoundStunID":
            keepers.Add(i);
            keeperNames.Add(7);
            break;
          case "SoundStandID":
            keepers.Add(i);
            keeperNames.Add(8);
            break;
          case "SoundFootstepID":
            keepers.Add(i);
            keeperNames.Add(9);
            break;
          case "SoundAggroID":
            keepers.Add(i);
            keeperNames.Add(10);
            break;
          case "SoundWingFlapID":
            keepers.Add(i);
            keeperNames.Add(11);
            break;
          case "SoundWingGlideID":
            keepers.Add(i);
            keeperNames.Add(12);
            break;
          case "SoundAlertID":
            keepers.Add(i);
            keeperNames.Add(13);
            break;
          case "SoundJumpStartID":
            keepers.Add(i);
            keeperNames.Add(14);
            break;
          case "SoundJumpEndID":
            keepers.Add(i);
            keeperNames.Add(15);
            break;
          case "SoundPetAttackID":
            keepers.Add(i);
            keeperNames.Add(16);
            break;
          case "SoundPetOrderID":
            keepers.Add(i);
            keeperNames.Add(17);
            break;
          case "SoundPetDismissID":
            keepers.Add(i);
            keeperNames.Add(18);
            break;
          case "LoopSoundID":
            keepers.Add(i);
            keeperNames.Add(19);
            break;
          case "BirthSoundID":
            keepers.Add(i);
            keeperNames.Add(20);
            break;
          case "SpellCastDirectedSoundID":
            keepers.Add(i);
            keeperNames.Add(21);
            break;
          case "SubmergeSoundID":
            keepers.Add(i);
            keeperNames.Add(22);
            break;
          case "SubmergedSoundID":
            keepers.Add(i);
            keeperNames.Add(23);
            break;
          case "WindupSoundID":
            keepers.Add(i);
            keeperNames.Add(24);
            break;
          case "WindupCriticalSoundID":
            keepers.Add(i);
            keeperNames.Add(25);
            break;
          case "ChargeSoundID":
            keepers.Add(i);
            keeperNames.Add(26);
            break;
          case "ChargeCriticalSoundID":
            keepers.Add(i);
            keeperNames.Add(27);
            break;
          case "BattleShoutSoundID":
            keepers.Add(i);
            keeperNames.Add(28);
            break;
          case "TauntSoundID":
            keepers.Add(i);
            keeperNames.Add(29);
            break;
          case "SoundFidget_0":
            keepers.Add(i);
            keeperNames.Add(30);
            break;
          case "SoundFidget_1":
            keepers.Add(i);
            keeperNames.Add(31);
            break;
          case "SoundFidget_2":
            keepers.Add(i);
            keeperNames.Add(32);
            break;
          case "SoundFidget_3":
            keepers.Add(i);
            keeperNames.Add(33);
            break;
          case "SoundFidget_4":
            keepers.Add(i);
            keeperNames.Add(34);
            break;
          case "CustomAttack_0":
            keepers.Add(i);
            keeperNames.Add(35);
            break;
          case "CustomAttack_1":
            keepers.Add(i);
            keeperNames.Add(36);
            break;
          case "CustomAttack_2":
            keepers.Add(i);
            keeperNames.Add(37);
            break;
          case "CustomAttack_3":
            keepers.Add(i);
            keeperNames.Add(38);
            break;
        }
      }

      while (!parser.EndOfData)
      {
        var items = parser.ReadFields();
        var creatureSoundId = Convert.ToInt32(items[soundIdIndex]);
        var sounds = new List<string>();
        for (var itemIdx = 1; itemIdx < items.Length; itemIdx++)
        {
          if (!keepers.Contains(itemIdx))
            continue;

          var soundId = items[itemIdx];
          if (soundId == "0")
            continue;

          sounds.Add($"{keeperNames[keepers.IndexOf(itemIdx)]};{soundId}");
        }

        if (sounds.Any())
           result.Add(creatureSoundId, string.Join(",", sounds));
      }

      return result;
    }

    private string SourceTypeToString(CsvSourceType sourceType)
    {
      switch (sourceType)
      {
        case CsvSourceType.Unknown:
          return "??";
        case CsvSourceType.Drop:
          return "Drop";
        case CsvSourceType.Quest:
          return "Quest";
        case CsvSourceType.Vendor:
          return "Vendor";
        case CsvSourceType.Profession:
          return "Profession";
        case CsvSourceType.WildPet:
          return "Pet Battle";
        case CsvSourceType.Achievement:
          return "Achievement";
        case CsvSourceType.WorldEvent:
          return "World Event";
        case CsvSourceType.Promotion:
          return "Promotion";
        case CsvSourceType.Tcg:
          return "Trading Card Game";
        case CsvSourceType.PetStore:
          return "In-Game Shop";
        case CsvSourceType.Discovery:
          return "??Discovery";
        case CsvSourceType.TradingPost:
          return "Trading Post";
        default:
          return "??";
      }
    }

    private void ConvertProbabilityToPercentChance(List<Variant> variants)
    {
      if (variants.Count == 1)
      {
        variants[0].probability = 100;
        return;
      }

      var sum = variants.Sum(p => p.probability);
      foreach (var variant in variants)
        variant.probability = (int)(variant.probability / sum * 100);
    }
  }
}