using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;

namespace PetAdvisorUtils
{
  public class Pet
  {
    public int speciesID;
    public int displayID;
    public int companionID;
    public double cost;
    public string name;
    public string source;
    public string currency;
    public string iconPath;
    public string tooltipDescription;
    public string petType;
    public string eventName;
    public string missionSource;
    public string note;
    public string characterClass;
    public string profession;
    public string promotion;
    public string tcg;
    public string feature;
    public string reputation;
    public string covenant;
    public string mission;
    public bool isPassive;
    public bool isUnique;
    public bool isTradeable;
    public bool isWild;
    public bool unobtainable;
    public Entity quest;
    public Entity achievement;
    public Entity[] npcs;
    public Location[] locations;
    public string[] possbileBreeds;
    public double[] baseStats;
    public Entity[] items;

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
          case "currency":
            currency = value.ToString();
            break;
          case "iconPath":
            iconPath = value.ToString();
            break;
          case "petType":
            petType = value.ToString();
            break;
          case "tooltipDescription":
            tooltipDescription = value.ToString().Replace("\"", "\\\"").Replace("\n", "\\\n");
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
          case "profession":
            profession = value.ToString();
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
            displayID = int.Parse(value.ToString());
            break;
          case "companionID":
            companionID = int.Parse(value.ToString());
            break;
          case "canBattle":
            isPassive = !bool.Parse(value.ToString());
            break;
          case "isUnique":
            isUnique= bool.Parse(value.ToString());
            break;
          case "isTradeable":
            isTradeable = bool.Parse(value.ToString());
            break;
          case "isWild":
            isWild = bool.Parse(value.ToString());
            break;
          case "unobtainable":
            unobtainable = bool.Parse(value.ToString());
            break;
          case "cost":
            cost = Convert.ToDouble(value.ToString());
            break;
          case "locations":
            locations = Location.Parse((LuaTable)value);
            break;
          case "possibleBreeds":
            possbileBreeds = ParseBreeds((LuaTable)value);
            break;
          case "baseStats":
            baseStats = ProcessBaseStats((LuaTable)value);
            break;
          case "item":
            items = Entity.Parse((LuaTable)value);
            break;
          case "npc":
            npcs = Entity.Parse((LuaTable)value);
            break;
          case "achievementName":
            achievement = new Entity { name = value.ToString() };
            var achId = table["achievementID"];
            if (achId != null)
              achievement.ID = Convert.ToInt32(achId);
            break;
          case "quest":
            quest = new Entity { name = value.ToString() };
            var questId = table["questID"];
            if (questId != null)
              quest.ID = Convert.ToInt32(questId);
            break;
          case "questID":
          case "achievementID":
            break; //skip
          default:
            Console.WriteLine(key);
            throw new Exception();
        }
      }

    }

    public string Serialize()
    {
      var sb = new StringBuilder();
      sb.AppendLine($"    [{speciesID}]={{");
      sb.AppendLine($"        name=\"{name}\",");
      sb.AppendLine($"        speciesID={speciesID},");
      sb.AppendLine($"        companionID={companionID},");
      sb.AppendLine($"        displayID={displayID},");
      sb.AppendLine($"        petType=\"{petType}\",");
      sb.AppendLine($"        isWild={isWild},");
      sb.AppendLine($"        isTradeable={isTradeable},");
      sb.AppendLine($"        isUnique={isUnique},");
      sb.AppendLine($"        isPassive={isPassive},");
      sb.AppendLine($"        source=\"{source}\",");
      sb.AppendLine($"        tooltip= \"{tooltipDescription}\",");
      sb.AppendLine($"        icon= \"{iconPath}\",");
      if (currency != null) sb.AppendLine($"        currency=\"{currency}\",");
      if (cost != 0) sb.AppendLine($"        cost={cost},");
      if (!string.IsNullOrEmpty(eventName)) sb.AppendLine($"        eventName=\"{eventName}\",");
      if (!string.IsNullOrEmpty(missionSource)) sb.AppendLine($"        missionSource=\"{missionSource}\",");
      if (!string.IsNullOrEmpty(mission)) sb.AppendLine($"        mission=\"{mission}\",");
      if (!string.IsNullOrEmpty(note)) sb.AppendLine($"        note=\"{note}\",");
      if (!string.IsNullOrEmpty(characterClass)) sb.AppendLine($"        characterClass=\"{characterClass}\",");
      if (!string.IsNullOrEmpty(profession)) sb.AppendLine($"        profession=\"{profession}\",");
      if (!string.IsNullOrEmpty(promotion)) sb.AppendLine($"        promotion=\"{promotion}\",");
      if (!string.IsNullOrEmpty(tcg)) sb.AppendLine($"        tcg=\"{tcg}\",");
      if (!string.IsNullOrEmpty(feature)) sb.AppendLine($"        feature=\"{feature}\",");
      if (!string.IsNullOrEmpty(reputation)) sb.AppendLine($"        reputation=\"{reputation}\",");
      if (!string.IsNullOrEmpty(covenant)) sb.AppendLine($"        covenant=\"{covenant}\",");
      if (unobtainable) sb.AppendLine($"        unobtainable={unobtainable},");
      if (quest != null) sb.AppendLine($"        quest={quest.Serialize()},");
      if (achievement != null) sb.AppendLine($"        achievement={achievement.Serialize()},");

      if (npcs != null && npcs.Length > 0)
      {
        sb.AppendLine($"        npcs={SerializeArray(npcs)},");
      }

      if (items != null && items.Length > 0)
      {
        sb.AppendLine($"        items={SerializeArray(items)},");
      }

      if (locations != null && locations.Length > 0)
      {
        sb.AppendLine($"        locations={SerializeArray(locations)},");
      }

      if (possbileBreeds != null && possbileBreeds.Length > 0)
      {
        sb.AppendLine($"        possbileBreeds={SerializeStringArray(possbileBreeds)},");
      }

      if (baseStats != null && baseStats.Length > 0)
      {
        sb.AppendLine($"        baseStats={{{string.Join(", ", baseStats)}}},");
      }

      sb.Append("    }");
      return sb.ToString();
    }

    private string SerializeArray(ISerializable[] entities)
    {
      if (entities.Length == 1)
      {
        return $"{{{entities[0].Serialize()}}}";
      }
      else
      {
        var sb = new StringBuilder();
        sb.AppendLine("{");
        for (var i = 0; i < entities.Length; i++)
        {
          var comma = i != entities.Length - 1 ? "," : "";
          sb.AppendLine($"            {entities[i].Serialize()}{comma}");
        }
        sb.Append("        }");
        return sb.ToString();
      }
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

    public static string[] ParseBreeds(LuaTable breeds)
    {
      List<string> list = new List<string>();
      foreach (var breed in breeds.Values)
      {
        switch (Convert.ToInt16(breed))
        {
          case 3:
            list.Add("B/B");
            break;
          case 4:
            list.Add("P/P");
            break;
          case 5:
            list.Add("S/S");
            break;
          case 6:
            list.Add("H/H");
            break;
          case 7:
            list.Add("H/P");
            break;
          case 8:
            list.Add("P/S");
            break;
          case 9:
            list.Add("H/S");
            break;
          case 10:
            list.Add("P/B");
            break;
          case 11:
            list.Add("S/B");
            break;
          case 12:
            list.Add("H/B");
            break;
          default: throw new Exception();
        }
      }

      return list.ToArray();
    }
  }
}
