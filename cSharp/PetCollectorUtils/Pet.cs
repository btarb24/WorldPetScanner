using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace PetCollectorUtils
{
  public class Pet
  {
    public int speciesID;
    public List<int> displayIDs = new List<int>();
    public List<int> npcSoundIDs= new List<int>();
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
    public List<string> possibleBreeds;
    public List<double> baseStats = new List<double> { -1, -1, -1 };
    public int soundID_key;
    public int npcSoundID_key;

    public Pet(int speciesID)
    {
      this.speciesID = speciesID;
    }
    /*
    public Pet(LuaTable table)
    {
      foreach(var key in table.Keys)
      {
        var value = table[key];
        switch(key)
        {
          case "name":
            name = value.ToString();
            break;
          case "source":
            source = value.ToString();
            break;
          case "icon":
            icon = value.ToString();
            break;
          case "family":
            family = Convert.ToInt16(value.ToString());
            break;
          case "flavor":
            flavor = value.ToString().Replace("\"", "\\\"").Replace("\n", "\\n");
            break;
          case "promotion":
            promotion = value.ToString();
            break;
          case "tcg":
            tcg = value.ToString();
            break;
          case "event":
            eventName = value.ToString();
            break;
          case "note":
            note = value.ToString();
            break;
          case "feature":
            feature = value.ToString();
            break;
          case "class":
            characterClass = value.ToString();
            break;
          case "reputation":
            reputation = value.ToString();
            break;
          case "covenant":
            covenant = value.ToString();
            break;
          case "mission":
            mission = value.ToString();
            break;
          case "missionSource":
            missionSource = value.ToString();
            break;
          case "speciesID":
            speciesID = int.Parse(value.ToString());
            break;
          case "displayID":
            displayIDs.Add(int.Parse(value.ToString()));
            break;
          case "displayIDs":
            throw new NotImplementedException();
          case "companionID":
            companionID = int.Parse(value.ToString());
            break;
          case "canBattle":
            isPassive = !bool.Parse(value.ToString());
            break;
          case "isUnique":
            isUnique= bool.Parse(value.ToString());
            break;
          case "isTradable":
            isTradable = bool.Parse(value.ToString());
            break;
          case "isWild":
            isWild = bool.Parse(value.ToString());
            break;
          case "unobtainable":
            unobtainable = bool.Parse(value.ToString());
            break;
          case "locations":
            locations = Location.Parse((LuaTable)value);
            break;
          case "possibleBreeds":
            possibleBreeds.AddRange(ParseBreeds((LuaTable)value));
            break;
          case "baseStats":
            baseStats.AddRange(ProcessBaseStats((LuaTable)value));
            break;
          case "achievement":
           // achievement = new Entity { name = value.ToString() };
            var achId = table["achievementID"];
         //   if (achId != null)
          //    achievement.ID = Convert.ToInt32(achId);
            break;
          case "acquisition":
            acquisition = ParseAcquistion((LuaTable)value);
            break;
          case "questID":
          case "achievementID":
            break; //skip
          default:
            Console.WriteLine(key);
            break;
        }
      }

      if (isWild && (source == "Drop" || source == "Achievement" || source == "Quest"))
        isWild = false;
    }*/

    public string Serialize()
    {
      var sb = new StringBuilder();
      sb.AppendLine($"    [{speciesID}]={{");
      sb.AppendLine($"        name=\"{name}\",");
      sb.AppendLine($"        speciesID={speciesID},");
      sb.AppendLine($"        companionID={companionID},");
      sb.AppendLine($"        displayIDs={{{string.Join(",", displayIDs)}}},");
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
      if (!string.IsNullOrEmpty(reputation)) sb.AppendLine($"        reputation={reputation},");
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
      if (!string.IsNullOrEmpty(covenant)) sb.AppendLine($"        covenant=\"{covenant}\",");
      if (chance > 0) sb.AppendLine($"        chance={chance},");


      //blobs
      if (!string.IsNullOrEmpty(achievement)) sb.AppendLine($"        achievement={achievement},");
      if (!string.IsNullOrEmpty(professionDetail)) sb.AppendLine($"        professionDetail={professionDetail},");

      if (possibleBreeds != null && possibleBreeds.Count > 0)
      {
        sb.AppendLine($"        possibleBreeds={SerializeStringArray(possibleBreeds.ToArray())},");
      }
      sb.AppendLine($"        baseStats={{{string.Join(", ", baseStats)}}},");

      if (!string.IsNullOrEmpty(locations)) sb.AppendLine($"        locations={locations},");
      if (!string.IsNullOrEmpty(pois)) sb.AppendLine($"        pois={pois},");
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
