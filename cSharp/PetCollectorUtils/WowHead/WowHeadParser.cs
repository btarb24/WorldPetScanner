using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;

namespace PetCollectorUtils.ParseFromWowHead
{
  internal class WowHeadParser
  {
    public void Parse(ref Dictionary<int, Pet> petsBySpeciesId)
    {
      foreach(var pet in petsBySpeciesId.Values)
      {
        getDataFromWowhead(pet);
      }
    }

    public void getDataFromWowhead(Pet pet)
    {
      var html = getHtml(pet.companionID);
      
      var breeds = getBreeds(pet, html);
      pet.possibleBreeds = breeds;

      if (pet.locations == null && pet.acquisition == null)
      {
        var locations = getLocations(html);
        pet.locations = locations;
      }
    }
    
    private string getHtml(int companionID)
    {
      var filename = $"../../wowHeadData/{companionID}.html";
      string html;
      if (File.Exists(filename))
      {
        html = File.ReadAllText(filename);
      }
      else
      {
        using (WebClient client = new WebClient()) // WebClient class inherits IDisposable
        {
          html = client.DownloadString($"https://www.wowhead.com/npc={companionID}");
          File.WriteAllText(filename, html);
        }
      }

      return html;
    }

    private List<int> getBreeds(Pet pet, string html)
    {
      var split = html.Split('\n');
      var line = split.FirstOrDefault(l => l.TrimStart().StartsWith("species:") && l.Contains("\"breeds\":"));
      if (line == null)
        return null;

      var colon = line.LastIndexOf(":");
      var breedBitwise = line.Substring(colon + 1).Replace("}", "").Replace(",", "");
      var breedInt = Convert.ToInt16(breedBitwise);
      var breedsEnum = (Breeds)breedInt;

      var breeds = ConvertBreedsToInts(breedsEnum);
      return breeds;
    }

    private string getLocations(string html)
    {
      //<script>var g_mapperData = {"9105":[{"count":24,"coords":[[26.4,51],[27,50.8],[27.2,50.4],[27.4,51.6],[27.6,50.2],[27.6,51.2],[27.6,51.6],[38.4,58.4],[38.4,59.2],[38.4,59.6],[38.6,59],[38.6,59.8],[38.8,58.4],[46,30.2],[46.2,30.6],[46.4,29.4],[46.6,29.4],[46.6,29.6],[47,31.2],[47,31.6],[57.4,46.4],[57.4,46.6],[57.6,46.4],[57.6,47]],"uiMapId":1530,"uiMapName":"Vale of Eternal Blossoms"}]};
      //<script>var g_mapperData = {"65":[{"count":5,"coords":[[26.8,54],[65.4,35.4],[65.4,35.6],[65.6,35.4],[82.2,66.2]],"uiMapId":115,"uiMapName":"Dragonblight"}],"66":[{"count":2,"coords":[[24.2,63.8],[75.2,23.2]],"uiMapId":121,"uiMapName":"Zul'Drak"}],"67":[{"count":3,"coords":[[29,51.4],[41.8,78.8],[65.2,41.8]],"uiMapId":120,"uiMapName":"The Storm Peaks"}],"210":[{"count":5,"coords":[[44.2,33.4],[44.2,33.6],[48.2,87],[73.4,64.8],[73.6,64.8]],"uiMapId":118,"uiMapName":"Icecrown"}],"394":[{"count":3,"coords":[[25.8,56.8],[61.6,18.2],[79.4,51.8]],"uiMapId":116,"uiMapName":"Grizzly Hills"}],"495":[{"count":3,"coords":[[45.8,43],[68.2,67.4],[71.8,43.2]],"uiMapId":117,"uiMapName":"Howling Fjord"}],"2817":[{"count":4,"coords":[[17.6,56.8],[43.2,44.2],[43.6,44.2],[68,48.8]],"uiMapId":127,"uiMapName":"Crystalsong Forest"}],"3537":[{"count":3,"coords":[[32.8,60.2],[47.6,7.8],[80.8,48.2]],"uiMapId":114,"uiMapName":"Borean Tundra"}],"3711":[{"count":4,"coords":[[36.8,19.4],[44.4,69.2],[44.6,69.4],[58.4,22.2]],"uiMapId":119,"uiMapName":"Sholazar Basin"}]};
      //<script>var g_mapperData = {"1581":{"2":{"count":1,"coords":[[55.6,43.8]]}}};
      //{"1497":[{"count":10,"coords":[[67.2,43.2],[67.2,44.8],[67.2,45.6],[67.4,42.4],[67.4,43.6],[67.6,42.2],[67.6,45.6],[67.8,43],[67.8,45],[68,43.6]],"uiMapId":90,"uiMapName":"Undercity"}],"1637":[{"count":3,"coords":[[54.4,89.4],[54.6,90.2],[54.8,89.2]],"uiMapId":85,"uiMapName":"Orgrimmar"}]}

      var split = html.Split('\n');
      var line = split.FirstOrDefault(l => l.Contains("g_mapperData"));
      if (line == null)
        return null;

      var locations = new List<Location>();
      try
      {
        var json = line.Split('=').Last().Replace(";", "").Trim();
        if (json == "[]")
          return null;

        var jlocations = JObject.Parse(json);
        foreach (var jlocation in jlocations)
        {
          var locationID = jlocation.Key;
          var locationName = TryGetLocationName(jlocation.Value, line);
          var mapID = TryGetMapID(jlocation.Value, line);
          var mapFloor = TryGetMapFloor(jlocation.Value);
          var coords = TryGetCoordsArray(jlocation.Value, mapFloor);
          var location = new Location() { mapID = mapID, zone = $"unknown-{locationName}" };
          locations.Add(location);

          if (location != null)
          {
            location.mapID = mapID;
            if (mapID == -1)
              location.mapID = int.Parse(locationID);

            foreach (var coord in coords)
            {
              location.coords.Add(new Coord { x = coord[0].Value<double>(), y = coord[1].Value<double>() });
            }
          }
        }
      }
      catch (Exception ex)
      {

      }

      if (locations.Any())
        return SerializeArray(locations.ToArray());
      else
        return null;
    }

    private string TryGetLocationName(JToken jtoken, string line)
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

    private int TryGetMapID(JToken jtoken, string line)
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

    private string TryGetMapFloor(JToken jtoken)
    {
      if (jtoken is JArray)
        return null;

      return ((JProperty)jtoken.First()).Name;
    }

    private JToken TryGetCoordsArray(JToken jtoken, string mapFloor)
    {
      if (jtoken is JArray)
        return jtoken[0]["coords"];
      else
        return jtoken[mapFloor.ToString()]["coords"];
    }

    private List<int> ConvertBreedsToInts(Breeds breeds)
    {
      var result = new List<int>();
      if (breeds.HasFlag(Breeds.BB))
        result.Add(1);
      if (breeds.HasFlag(Breeds.PP))
        result.Add(2);
      if (breeds.HasFlag(Breeds.SS))
        result.Add(3);
      if (breeds.HasFlag(Breeds.HH))
        result.Add(4);
      if (breeds.HasFlag(Breeds.HP))
        result.Add(5);
      if (breeds.HasFlag(Breeds.PS))
        result.Add(6);
      if (breeds.HasFlag(Breeds.HS))
        result.Add(7);
      if (breeds.HasFlag(Breeds.PB))
        result.Add(8);
      if (breeds.HasFlag(Breeds.SB))
        result.Add(9);
      if (breeds.HasFlag(Breeds.HB))
        result.Add(10);

      return result;
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

    private bool AreBreedsUpdated(List<string> priorBreeds, List<string> newBreeds)
    {
      if (newBreeds == null)
        return false;

      if (priorBreeds == null)
        return true;

      var areSame = priorBreeds.All(newBreeds.Contains) && priorBreeds.Count() == newBreeds.Count();
      return !areSame;
    }
  }
}
