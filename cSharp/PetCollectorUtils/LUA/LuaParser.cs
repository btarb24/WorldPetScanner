using NLua;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCollectorUtils.LUA
{
  internal class LuaParser
  {
    const string childLineIndent         = "            ";
    const string petStart         = "    [";
    const string petEnd           = "    },";
    const string name             = "        name=";
    const string speciesID        = "        speciesID=";
    const string companionID      = "        companionID=";
    const string displayID        = "        displayID=";
    const string displayIDs       = "        displayIDs=";
    const string family           = "        family=";
    const string isWild           = "        isWild=";
    const string isTradable       = "        isTradable=";
    const string isUnique         = "        isUnique=";
    const string isPassive        = "        isPassive=";
    const string intermittent     = "        intermittent=";
    const string unobtainable     = "        unobtainable=";
    const string source           = "        source=";
    const string flavor           = "        flavor=";
    const string icon             = "        icon=";
    const string characterClass   = "        characterClass=";
    const string possibleBreeds   = "        possibleBreeds=";
    const string baseStats        = "        baseStats=";
    const string chance           = "        chance=";
    const string feature          = "        feature=";
    const string covenant         = "        covenant=";
    const string mission          = "        mission=";
    const string missionSource    = "        missionSource=";
    const string reputation       = "        reputation=";
    const string promotion        = "        promotion=";
    const string tcg              = "        tcg=";
    const string eventName        = "        eventName=";
    const string achievement      = "        achievement=";
    const string professionDetail = "        professionDetail=";
    const string locations        = "        locations=";
    const string pois             = "        pois=";
    const string acquisition      = "        acquisition=";

    const string note             = "        note="; //todo: remove
    const string currency_Eat     = "        currency=";
    const string npcs_Eat         = "        ncps=";
    const string profession_Eat   = "        profession=";
    const string items_Eat        = "        items=";
    const string quest_Eat        = "        quest=";
    const string cost_Eat         = "        cost=";

    public Dictionary<int, Pet> Parse()
    {
      var lines = File.ReadAllLines(@"..\..\PetsInput.lua");
      var pets = new Dictionary<int, Pet>();
      Pet currentPet = null;
      for (var i = 1; i < lines.Count()-1; i++)
      {
        var line = lines[i];
        if (!line.StartsWith(" "))
          continue;

        if (line.StartsWith(petStart)) //new pet
        {
          var speciesID = GetSpeciesID(line);
          currentPet = new Pet(speciesID);
        }
        else if (line.StartsWith(petEnd))
        {
          pets.Add(currentPet.speciesID, currentPet);
        }
        else if (line.StartsWith(name))
        {
          currentPet.name = GetSimpleString(line);
        }
        else if (line.StartsWith(speciesID))
        {
          continue;
        }
        else if (line.StartsWith(companionID))
        {
          currentPet.companionID = GetSimpleInt(line);
        }
        else if (line.StartsWith(displayID))
        {
          currentPet.displayIDs.Add(GetSimpleInt(line));
        }
        else if (line.StartsWith(displayIDs))
        {
          currentPet.displayIDs.AddRange(GetIntList(line));
        }
        else if (line.StartsWith(family))
        {
          currentPet.family = GetSimpleInt(line);
        }
        else if (line.StartsWith(isWild))
        {
          currentPet.isWild = GetSimpleBool(line);
        }
        else if (line.StartsWith(isTradable))
        {
          currentPet.isTradable = GetSimpleBool(line);
        }
        else if (line.StartsWith(isUnique))
        {
          currentPet.isUnique = GetSimpleBool(line);
        }
        else if (line.StartsWith(isPassive))
        {
          currentPet.isPassive = GetSimpleBool(line);
        }
        else if (line.StartsWith(intermittent))
        {
          currentPet.intermittent = GetSimpleBool(line);
        }
        else if (line.StartsWith(unobtainable))
        {
          currentPet.unobtainable = GetSimpleBool(line);
        }
        else if (line.StartsWith(source))
        {
          currentPet.source = GetSimpleString(line);
        }
        else if (line.StartsWith(flavor))
        {
          currentPet.flavor = GetSimpleString(line);
        }
        else if (line.StartsWith(icon))
        {
          currentPet.icon = GetSimpleString(line);
        }
        else if (line.StartsWith(possibleBreeds))
        {
          currentPet.possibleBreeds= GetStringList(line);
        }
        else if (line.StartsWith(baseStats))
        {
          currentPet.baseStats= GetDoubleList(line);
        }
        else if (line.StartsWith(chance))
        {
          currentPet.chance = GetSimpleDouble(line);
        }
        else if (line.StartsWith(promotion))
        {
          currentPet.promotion = GetSimpleString(line);
        }
        else if (line.StartsWith(eventName))
        {
          currentPet.eventName = GetSimpleString(line);
        }
        else if (line.StartsWith(tcg))
        {
          currentPet.tcg = GetSimpleString(line);
        }
        else if (line.StartsWith(reputation))
        {
          currentPet.reputation = GetBlobString(lines, line, ref i);
        }
        else if (line.StartsWith(achievement))
        {
          currentPet.achievement = GetBlobString(lines, line, ref i);
        }
        else if (line.StartsWith(professionDetail))
        {
          currentPet.professionDetail = GetBlobString(lines, line, ref i);
        }
        else if (line.StartsWith(locations))
        {
          currentPet.locations = GetBlobString(lines, line, ref i);
        }
        else if (line.StartsWith(pois))
        {
          currentPet.pois = GetBlobString(lines, line, ref i);
        }
        else if (line.StartsWith(acquisition))
        {
          currentPet.acquisition = GetBlobString(lines, line, ref i);
        }
        else if (line.StartsWith(characterClass))
        {
          currentPet.characterClass = GetSimpleString(line);
        }
        else if (line.StartsWith(covenant))
        {
          currentPet.covenant = GetSimpleString(line);
        }
        else if (line.StartsWith(feature))
        {
          currentPet.feature = GetSimpleString(line);
        }
        else if (line.StartsWith(mission))
        {
          currentPet.mission = GetSimpleString(line);
        }
        else if (line.StartsWith(missionSource))
        {
          currentPet.missionSource = GetSimpleString(line);
        }
        else if (line.StartsWith(note))
        {
          currentPet.note = GetSimpleString(line);
        }
        else if (line.StartsWith(currency_Eat) || line.StartsWith(npcs_Eat) || line.StartsWith(profession_Eat) || line.StartsWith(items_Eat)
                || line.StartsWith(quest_Eat) || line.StartsWith(cost_Eat))
        {
        }
        else
        { 
        }
      }

      return pets;
    }

    private int GetSpeciesID(string line)
    {
      var start = line.IndexOf("[") +1;
      var end = line.IndexOf("]");
      var speciesIdStr = line.Substring(start, end - start);
      return Convert.ToInt32(speciesIdStr);
    }

    private string GetSimpleString(string line)
    {
      var start = line.IndexOf("=\"") + 2;
      var end = line.LastIndexOf("\",");
      var result = line.Substring(start, end - start);
      //result = result.Replace("\"", "\\\"");
      return result;
    }

    private int GetSimpleInt(string line)
    {
      var start = line.IndexOf("=") + 1;
      var end = line.IndexOf(",");
      var result = line.Substring(start, end - start);
      return Convert.ToInt32(result);
    }

    private double GetSimpleDouble(string line)
    {
      var start = line.IndexOf("=") + 1;
      var end = line.IndexOf(",");
      var result = line.Substring(start, end - start);
      return Convert.ToDouble(result);
    }

    private bool GetSimpleBool(string line)
    {
      var start = line.IndexOf("=") + 1;
      var end = line.IndexOf(",");
      var result = line.Substring(start, end - start);
      return Convert.ToBoolean(result);
    }

    private List<int> GetIntList(string line)
    {
      var start = line.IndexOf("{") + 1;
      var end = line.IndexOf("}");
      var trimmed = line.Substring(start, end - start);
      var split = trimmed.Split(',');
      var list = new List<int>();
      foreach (var num in split)
        list.Add(Convert.ToInt32(num));

      return list;
    }

    private List<double> GetDoubleList(string line)
    {
      var start = line.IndexOf("{") + 1;
      var end = line.IndexOf("}");
      var trimmed = line.Substring(start, end - start);
      var split = trimmed.Split(',');
      var list = new List<double>();
      foreach (var num in split)
        list.Add(Convert.ToDouble(num));

      return list;
    }

    private List<string> GetStringList(string line)
    {
      var start = line.IndexOf("{") + 1;
      var end = line.IndexOf("}");
      var trimmed = line.Substring(start, end - start);
      var split = trimmed.Split(',');

      var result = new List<string>();

      foreach (var item in split)
        result.Add(item.Trim().Trim('\"').Trim());

      return result;
    }

    private string GetBlobString(string[] lines, string line, ref int i)
    {
      if (!line.Contains("{"))
        return $"\"{GetSimpleString(line)}\"";

      var lineTrim = line.TrimEnd();
      if (lineTrim.EndsWith("},"))
      {
        var start = line.IndexOf("={") + 1;
        var end = line.LastIndexOf("},")+1;
        var result = line.Substring(start, end - start);
        return result;
      }
      else
      {
        var sb = new StringBuilder();
        var start = line.IndexOf("={") + 1;
        sb.AppendLine(line.Substring(start));

        while(true)
        {
          i++;
          var subLine = lines[i];
          if (subLine.StartsWith(childLineIndent))
          {
            sb.AppendLine(subLine);
          }
          else
          {
            sb.Append("        }");
            return sb.ToString();
          }
        }
      }
    }

    /*
    public void ParseWithLua()
    {
      var lua = new Lua();
      lua.DoFile(@"..\..\..\..\Data\Pets.lua");
      var petTables = (LuaTable)lua["pets"];

      List<Pet> pets = new List<Pet>();
      foreach (var petTable in petTables)
      {
        var kvp = (KeyValuePair<object, object>)petTable;
        var pet = new Pet((LuaTable)kvp.Value);
        pets.Add(pet);
      }
    }*/
  }
}
