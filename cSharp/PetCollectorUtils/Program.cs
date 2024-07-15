using Newtonsoft.Json.Linq;
using NLua;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace PetCollectorUtils
{
  internal class Program
  {

    // all species data  https://nether.wowhead.com/data/petspecies?dv=8&db=1720130128
    /* g_battlepets[223600]={
            "abilities":[219,350,1078,475,424,513],
            "category":11,
            "health":7,
            "icon":"inv_babynaga2_teal",
            "power":8.25,
            "source":[28],
            "species":4565,
            "speed":8.75,
            "type":1,
            "breeds":256,
            "npc":{
              "classification":0,
              "displayName":"Trishi",
              "displayNames":["Trishi"],
              "id":223600,
              "name":"Trishi",
              "names":["Trishi"],
              "type":12
              },
            "name":"Trishi",
            "model":119579,
            "untameable":0,
            "wowSource":11,
            "description":"She sees you when you're sleeping.",
            "sourceDesc":"<span style=\"color: #FFD200\">Trading Post<\/span><br \/>",
            "companion":0,
            "untradeable":1,
            "side":0,
            "hideUncollected":1
          };
    */
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
        if (pet.isWild)
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

    }

    static void getLocations(Pet pet, string html)
    {
      //<script>var g_mapperData = {"9105":[{"count":24,"coords":[[26.4,51],[27,50.8],[27.2,50.4],[27.4,51.6],[27.6,50.2],[27.6,51.2],[27.6,51.6],[38.4,58.4],[38.4,59.2],[38.4,59.6],[38.6,59],[38.6,59.8],[38.8,58.4],[46,30.2],[46.2,30.6],[46.4,29.4],[46.6,29.4],[46.6,29.6],[47,31.2],[47,31.6],[57.4,46.4],[57.4,46.6],[57.6,46.4],[57.6,47]],"uiMapId":1530,"uiMapName":"Vale of Eternal Blossoms"}]};
      //<script>var g_mapperData = {"65":[{"count":5,"coords":[[26.8,54],[65.4,35.4],[65.4,35.6],[65.6,35.4],[82.2,66.2]],"uiMapId":115,"uiMapName":"Dragonblight"}],"66":[{"count":2,"coords":[[24.2,63.8],[75.2,23.2]],"uiMapId":121,"uiMapName":"Zul'Drak"}],"67":[{"count":3,"coords":[[29,51.4],[41.8,78.8],[65.2,41.8]],"uiMapId":120,"uiMapName":"The Storm Peaks"}],"210":[{"count":5,"coords":[[44.2,33.4],[44.2,33.6],[48.2,87],[73.4,64.8],[73.6,64.8]],"uiMapId":118,"uiMapName":"Icecrown"}],"394":[{"count":3,"coords":[[25.8,56.8],[61.6,18.2],[79.4,51.8]],"uiMapId":116,"uiMapName":"Grizzly Hills"}],"495":[{"count":3,"coords":[[45.8,43],[68.2,67.4],[71.8,43.2]],"uiMapId":117,"uiMapName":"Howling Fjord"}],"2817":[{"count":4,"coords":[[17.6,56.8],[43.2,44.2],[43.6,44.2],[68,48.8]],"uiMapId":127,"uiMapName":"Crystalsong Forest"}],"3537":[{"count":3,"coords":[[32.8,60.2],[47.6,7.8],[80.8,48.2]],"uiMapId":114,"uiMapName":"Borean Tundra"}],"3711":[{"count":4,"coords":[[36.8,19.4],[44.4,69.2],[44.6,69.4],[58.4,22.2]],"uiMapId":119,"uiMapName":"Sholazar Basin"}]};
      //<script>var g_mapperData = {"1581":{"2":{"count":1,"coords":[[55.6,43.8]]}}};
      //{"1497":[{"count":10,"coords":[[67.2,43.2],[67.2,44.8],[67.2,45.6],[67.4,42.4],[67.4,43.6],[67.6,42.2],[67.6,45.6],[67.8,43],[67.8,45],[68,43.6]],"uiMapId":90,"uiMapName":"Undercity"}],"1637":[{"count":3,"coords":[[54.4,89.4],[54.6,90.2],[54.8,89.2]],"uiMapId":85,"uiMapName":"Orgrimmar"}]}

      var split = html.Split('\n');
      var line = split.FirstOrDefault(l => l.Contains("g_mapperData"));
      if (line == null)
        return;

      try
      {
        var json = line.Split('=').Last().Replace(";", "").Trim();
        var jlocations = JObject.Parse(json);
        foreach (var jlocation in jlocations)
        {
          var locationID = jlocation.Key;
          var locationName = TryGetLocationName(jlocation.Value, line);
          var mapID = TryGetMapID(jlocation.Value, line);
          var mapFloor = TryGetMapFloor(jlocation.Value);
          var coords = TryGetCoordsArray(jlocation.Value, mapFloor);
          var location = pet.locations.FirstOrDefault(l => l.continent == locationName || l.zone == locationName || l.area == locationName);
          if (location == null && jlocations.Count == 1 && pet.locations.Length == 1)
            location = pet.locations.Single();

          if (location == null)
          {
            location = new Location() { mapID = mapID, zone = $"unknown-{locationName}" };
            var list = new List<Location>(pet.locations);
            list.Add(location);
            pet.locations = list.ToArray();
          }

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
            Console.WriteLine(pet.speciesID);
          }
        }
      }
      catch
      {
        Console.WriteLine(pet.speciesID);
      }
    }

    static string TryGetLocationName(JToken jtoken, string line)
    {
      try
      {
        if (line.Contains("uiMapName"))
          return jtoken[0]["uiMapName"].Value<string>();
        else
          return null;
      }
      catch { return "oddFormat"; }
    }

    static int TryGetMapID(JToken jtoken, string line)
    {
      try
      {
        if (line.Contains("uiMapId"))
        {
          var mapID = jtoken[0]["uiMapId"].Value<int>();

          if (mapID == 5861) //darkmoon island
            mapID = 407;
          else if (mapID == 7502) //dalaran
            mapID = 51;

          return mapID;
        }
        else
          return -1;
      }
      catch { return 99999; }
    }
    static string TryGetUiMapName(JToken jtoken, string line)
    {
      if (line.Contains("uiMapName"))
      {
        var name = jtoken[0]["uiMapName"].Value<string>();

        return name;
      }
      else
        return null;
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


