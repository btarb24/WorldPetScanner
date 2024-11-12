using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PetCollectorUtils
{
  public class Pet
  {
    public int speciesID;
    public List<Variant> variants = new List<Variant>();
    public List<int> npcSoundIDs = new List<int>();
    public List<string> creatureSoundIDs = new List<string>();
    public int companionID;
    public string name;
    public string source;
    public string icon;
    public string flavor;
    public int family;
    public string eventName;
    public string missionSource;
    public string note; //todo: remove
    public string characterClass;
    public string promotion;
    public string tcg;
    public string feature;
    public string reputation;
    public string condition;
    public string covenant;
    public string mission;
    public string achievement;
    public string professionDetail;
    public string locations;
    public string pois;
    public string acquisition;
    public bool isPassive;
    public bool isUnique;
    public bool isTradable;
    public bool isWild;
    public bool intermittent;
    public bool unobtainable;
    public double chance;
    public int pvpHonorLevel;
    public List<int> possibleBreeds;
    public List<double> baseStats = new List<double> { -1, -1, -1 };
    public int soundID_key;
    public int npcSoundID_key;

    public Pet(int speciesID)
    {
      this.speciesID = speciesID;
    }

    public string Serialize()
    {
      var sb = new StringBuilder();
      sb.AppendLine($"    [{speciesID}]={{");
      sb.AppendLine($"        name=\"{name}\",");
      sb.AppendLine($"        speciesID={speciesID},");
      sb.AppendLine($"        companionID={companionID},");
      sb.AppendLine($"        variants={{{string.Join(",", variants)}}},");
      sb.AppendLine($"        family={family},");
      if (isWild) sb.AppendLine($"        isWild={(isWild ? "true" : "false")},");
      if (isTradable) sb.AppendLine($"        isTradable={(isTradable ? "true" : "false")},");
      if (isUnique) sb.AppendLine($"        isUnique={(isUnique ? "true" : "false")},");
      if (isPassive) sb.AppendLine($"        isPassive={(isPassive ? "true" : "false")},");
      if (intermittent) sb.AppendLine($"        intermittent={(intermittent ? "true" : "false")},");
      if (unobtainable) sb.AppendLine($"        unobtainable={(unobtainable ? "true" : "false")},");
      sb.AppendLine($"        source=\"{source}\",");
      sb.AppendLine($"        flavor=\"{flavor}\",");
      sb.AppendLine($"        icon=\"{icon}\",");
      if (!string.IsNullOrEmpty(reputation)) sb.AppendLine($"        reputations={reputation},");
      if (pvpHonorLevel > 0) sb.AppendLine($"        pvpHonorLevel={pvpHonorLevel},");
      if (npcSoundIDs.Any()) sb.AppendLine($"        npcSounds={{{string.Join(",", npcSoundIDs)}}},");
      if (creatureSoundIDs.Any()) sb.AppendLine($"        creatureSounds={SerializeStringArray(creatureSoundIDs.ToArray())},");
      if (!string.IsNullOrEmpty(eventName)) sb.AppendLine($"        eventName=\"{eventName}\",");
      if (!string.IsNullOrEmpty(missionSource)) sb.AppendLine($"        missionSource=\"{missionSource}\",");
      if (!string.IsNullOrEmpty(mission)) sb.AppendLine($"        mission=\"{mission}\",");
      if (!string.IsNullOrEmpty(note)) sb.AppendLine($"        note=\"{note}\",");
      if (!string.IsNullOrEmpty(characterClass)) sb.AppendLine($"        characterClass=\"{characterClass}\",");
      if (!string.IsNullOrEmpty(promotion)) sb.AppendLine($"        promotion=\"{promotion}\",");
      if (!string.IsNullOrEmpty(tcg)) sb.AppendLine($"        tcg=\"{tcg}\",");
      if (!string.IsNullOrEmpty(feature)) sb.AppendLine($"        feature=\"{feature}\",");
      if (!string.IsNullOrEmpty(covenant)) sb.AppendLine($"        covenant={covenant},");
      if (chance > 0) sb.AppendLine($"        chance={chance},");


      //blobs
      if (!string.IsNullOrEmpty(achievement)) sb.AppendLine($"        achievement={achievement},");
      if (!string.IsNullOrEmpty(professionDetail)) sb.AppendLine($"        professionDetail={professionDetail},");

      if (possibleBreeds != null && possibleBreeds.Count > 0)
      {
        sb.AppendLine($"        possibleBreeds={{{string.Join(",", possibleBreeds)}}},");
      }
      sb.AppendLine($"        baseStats={{{string.Join(", ", baseStats)}}},");

      if (!string.IsNullOrEmpty(locations)) sb.AppendLine($"        locations={locations},");
      if (!string.IsNullOrEmpty(pois)) sb.AppendLine($"        pois={pois},");
      if (!string.IsNullOrEmpty(condition)) sb.AppendLine($"        condition={condition},");
      if (!string.IsNullOrEmpty(acquisition)) sb.AppendLine($"        acquisition={acquisition},");

      sb.Append("    }");
      return sb.ToString();
    }

    private string SerializeStringArray(string[] arr)
    {
      var result = "{";
      for (var i = 0; i < arr.Length; i++)
      {
        var separator = i != arr.Length - 1 ? ", " : "";
        result += $"\"{arr[i]}\"{separator}";
      }
      result += "}";
      return result;
    }

    public static double[] ProcessBaseStats(LuaTable stats)
    {
      List<double> result = new List<double>();
      foreach(var stat in stats.Values)
      {
        result.Add(Convert.ToDouble(stat));
      }

      return result.ToArray();
    }
  }
}
