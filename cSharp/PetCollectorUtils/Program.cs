using Newtonsoft.Json.Linq;
using NLua;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace PetCollectorUtils
{
  internal class Program
  {
    static void Main(string[] args)
    {
      var petsFile = new FileInfo(@"..\..\PetsInput.lua");

      var lua = new Lua();
      lua.DoFile(@"..\..\PetsInput.lua");
      var petTables =  (LuaTable)lua["pets"];

      List<Pet> pets = new List<Pet>();
      foreach (var petTable in petTables)
      {
        var kvp = (KeyValuePair<object, object>)petTable;
        var pet = new Pet((LuaTable)kvp.Value);
        pets.Add(pet);
        getDataFromWowhead(pet);
      }

      var sorted = pets.OrderBy((p) => p.speciesID);
      var sb = new StringBuilder();
      sb.AppendLine("PETS.all = {");
      foreach (var pet in sorted)
      {
        sb.AppendLine($"{pet.Serialize()}, ");
      }
      sb.Append("}");
      var result = sb.ToString();
      Clipboard.SetText(result);

      Console.ReadLine();
    }

    static void getDataFromWowhead(Pet pet)
    {
      var filename = $"../../wowHeadData/{pet.companionID}.html";
      string html;
      if (File.Exists(filename))
        html = File.ReadAllText(filename);
      else
      {
        using (WebClient client = new WebClient()) // WebClient class inherits IDisposable
        {
          html = client.DownloadString($"https://www.wowhead.com/npc={pet.companionID}");
          File.WriteAllText(filename, html);
        }
      }

      getLocations(pet, html);
      if (!pet.isPassive)
        getBreedInfo(pet, html);
    }

    static void getBreedInfo(Pet pet, string html)
    {
      var split = html.Split('\n');
      var breedToken = "\"breeds\":";
      var line = split.FirstOrDefault(l => l.Contains(breedToken));

      var breedStr = getBreedDataPoint(line, "breeds");
      var breed = (WowHeadBreeds)Convert.ToInt16(breedStr);
      var breedArr = WowHeadBreedsExtensions.ToFriendlyStrings(breed);
      if (pet.possbileBreeds.Length >= 0)
      {
        if (!Enumerable.SequenceEqual(pet.possbileBreeds.OrderBy(t => t), breedArr.OrderBy(t => t)))
          Console.WriteLine($"mismatch breeds: {pet.speciesID} {pet.name}  addon: {string.Join(",", pet.possbileBreeds)} wowhead: {string.Join(",", breedArr)}");
      }

      pet.possbileBreeds = breedArr;

      var healthStr = getBreedDataPoint(line, "health");
      var powerStr = getBreedDataPoint(line, "power");
      var speedStr = getBreedDataPoint(line, "speed");

      var health = Math.Round(Convert.ToDouble(healthStr), 3);
      var power = Math.Round(Convert.ToDouble(powerStr), 3);
      var speed = Math.Round(Convert.ToDouble(speedStr), 3);
      var stats = new[] { health, power, speed };

      if (pet.baseStats.Length > 0)
      {
        if (Math.Round(pet.baseStats[0], 1) != Math.Round(stats[0], 1) ||
            Math.Round(pet.baseStats[1], 1) != Math.Round(stats[1], 1) ||
            Math.Round(pet.baseStats[2], 1) != Math.Round(stats[2], 1))
          Console.WriteLine($"mismatch stats: {pet.speciesID} {pet.name}  addon: {string.Join(",", pet.baseStats)} wowhead: {string.Join(",", stats)}");
      }

      pet.baseStats = stats;
    }

    static string getBreedDataPoint(string line, string key)
    {
      var token = $"\"{key}\":";

      var sub = line.Substring(line.IndexOf(token) + token.Length);
      var resultStr = sub.Substring(0, sub.IndexOfAny(new[] { ',', ' ' }));
      return resultStr;
    }

    static void getLocations(Pet pet, string html)
    {
      //<script>var g_mapperData = {"9105":[{"count":24,"coords":[[26.4,51],[27,50.8],[27.2,50.4],[27.4,51.6],[27.6,50.2],[27.6,51.2],[27.6,51.6],[38.4,58.4],[38.4,59.2],[38.4,59.6],[38.6,59],[38.6,59.8],[38.8,58.4],[46,30.2],[46.2,30.6],[46.4,29.4],[46.6,29.4],[46.6,29.6],[47,31.2],[47,31.6],[57.4,46.4],[57.4,46.6],[57.6,46.4],[57.6,47]],"uiMapId":1530,"uiMapName":"Vale of Eternal Blossoms"}]};
      //<script>var g_map perData = {"65":[{"count":5,"coords":[[26.8,54],[65.4,35.4],[65.4,35.6],[65.6,35.4],[82.2,66.2]],"uiMapId":115,"uiMapName":"Dragonblight"}],"66":[{"count":2,"coords":[[24.2,63.8],[75.2,23.2]],"uiMapId":121,"uiMapName":"Zul'Drak"}],"67":[{"count":3,"coords":[[29,51.4],[41.8,78.8],[65.2,41.8]],"uiMapId":120,"uiMapName":"The Storm Peaks"}],"210":[{"count":5,"coords":[[44.2,33.4],[44.2,33.6],[48.2,87],[73.4,64.8],[73.6,64.8]],"uiMapId":118,"uiMapName":"Icecrown"}],"394":[{"count":3,"coords":[[25.8,56.8],[61.6,18.2],[79.4,51.8]],"uiMapId":116,"uiMapName":"Grizzly Hills"}],"495":[{"count":3,"coords":[[45.8,43],[68.2,67.4],[71.8,43.2]],"uiMapId":117,"uiMapName":"Howling Fjord"}],"2817":[{"count":4,"coords":[[17.6,56.8],[43.2,44.2],[43.6,44.2],[68,48.8]],"uiMapId":127,"uiMapName":"Crystalsong Forest"}],"3537":[{"count":3,"coords":[[32.8,60.2],[47.6,7.8],[80.8,48.2]],"uiMapId":114,"uiMapName":"Borean Tundra"}],"3711":[{"count":4,"coords":[[36.8,19.4],[44.4,69.2],[44.6,69.4],[58.4,22.2]],"uiMapId":119,"uiMapName":"Sholazar Basin"}]};
      //<script>var g_mapperData = {"1581":{"2":{"count":1,"coords":[[55.6,43.8]]}}};
      //{"1497":[{"count":10,"coords":[[67.2,43.2],[67.2,44.8],[67.2,45.6],[67.4,42.4],[67.4,43.6],[67.6,42.2],[67.6,45.6],[67.8,43],[67.8,45],[68,43.6]],"uiMapId":90,"uiMapName":"Undercity"}],"1637":[{"count":3,"coords":[[54.4,89.4],[54.6,90.2],[54.8,89.2]],"uiMapId":85,"uiMapName":"Orgrimmar"}]}

      var split = html.Split('\n');
      var line = split.FirstOrDefault(l => l.Contains("g_mapperData"));
      if (line == null)
        return;

      try
      {
        var json = line.Split('=').Last().Replace(";", "").Trim();
        if (json == "[]")
          return;

        var jlocations = JObject.Parse(json);
        foreach (var jlocation in jlocations)
        {
          var locationID = jlocation.Key;
          var locationName = TryGetLocationName(jlocation.Value, line, locationID);
          var mapID = TryGetMapID(jlocation.Value, line, locationID);
          var mapFloor = TryGetMapFloor(jlocation.Value);
          var coords = TryGetCoordsArray(jlocation.Value, mapFloor);
          var location = pet.locations?.FirstOrDefault(l => l.continent == locationName || l.zone == locationName || l.area == locationName);
          if (location == null && jlocations.Count == 1 && pet.locations.Length == 1)
            location = pet.locations.Single();

          if (location != null)
          {
            location.mapID = mapID;
            if (mapID == -1)
              location.mapID = int.Parse(locationID);

            if (mapFloor != null)
              location.mapFloor = int.Parse(mapFloor);

            foreach (var coord in coords)
            {
              location.coords.Add(new Coord { x = coord[0].Value<double>(), y = coord[1].Value<double>() });
            }
          }
          else
          {
            Console.WriteLine($"nolocation: {pet.speciesID}");
          }
        }
      }
      catch (Exception ex)
      {
        Console.WriteLine($"location exception: {pet.speciesID}");
      }
    }

    static string TryGetLocationName(JToken jtoken, string line, string locationID)
    {
      if (line.Contains("uiMapName"))
      {
        if (jtoken.First.Children().Any(c => (c as JProperty)?.Name == "uiMapName"))
          return jtoken.First["uiMapName"].Value<string>();
        else if (jtoken.First.First.Children().Any(c => (c as JProperty)?.Name == "uiMapName"))
          return jtoken.First.First["uiMapName"].Value<string>();
      }
      else if (locationID == "5861")
        return "Darkmoon Island";
      else if (locationID == "7502")
        return "Dalaran (Northrend)";
      return null;
    }

    static int TryGetMapID(JToken jtoken, string line, string locationID)
    {
      if (line.Contains("uiMapId"))
      {

        if (jtoken.First.Children().Any(c => (c as JProperty)?.Name == "uiMapId"))
          return AdaptMapID(jtoken.First["uiMapId"].Value<int>());
        else if (jtoken.First.First.Children().Any(c => (c as JProperty)?.Name == "uiMapId"))
          return AdaptMapID(jtoken.First.First["uiMapId"].Value<int>());
      }
      else if (locationID == "5861") //darkmoon island
        return 407;
      else if (locationID == "7502") //dalaran northrend
        return 51;

      return -1;
    }

    static int AdaptMapID(int mapID)
    {
      if (mapID == 5861) //darkmoon island
        return 407;
      else if (mapID == 7502) //dalaran
        return 51;

      return mapID;
    }

    static string TryGetMapFloor(JToken jtoken)
    {
      if (jtoken is JArray)
        return null;

      return ((JProperty)jtoken.First()).Name;
    }

    static JToken TryGetCoordsArray(JToken jtoken, string mapFloor)
    {
      if (jtoken is JArray)
        return jtoken[0]["coords"];
      else
        return jtoken[mapFloor.ToString()]["coords"];
    }
  }
}


