using Newtonsoft.Json.Linq;
using NLua;
using PetCollectorUtils.Csv;
using PetCollectorUtils.LUA;
using PetCollectorUtils.ParseFromWowHead;
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
            "untradable":1,
            "side":0,
            "hideUncollected":1
          };
    */
    static void Main(string[] args)
    {
      var petsBySpeciesId = new LuaParser().Parse();
      new CsvParser().ParseCsvData(ref petsBySpeciesId);
      new WowHeadParser().Parse(ref petsBySpeciesId);

      RemoveBreedless(ref petsBySpeciesId);
      ApplyDefaultBaseStats(ref petsBySpeciesId);

      var petsStr = SerializePets(petsBySpeciesId.Values);
      //Clipboard.SetText(result);

        Console.ReadLine();
    }

    static string SerializePets(IEnumerable<Pet> pets)
    {
      var sorted = pets.OrderBy((p) => p.speciesID);
      var sb = new StringBuilder();
      sb.AppendLine("PETS.all = {");
      foreach (var pet in sorted)
      {
        sb.AppendLine($"{pet.Serialize()}, ");
      }
      sb.Append("}");

      return sb.ToString();
    }

    static void RemoveBreedless(ref Dictionary<int, Pet> petsBySpeciesId)
    {
      var toRemove = new List<int>();
      foreach (var pet in petsBySpeciesId.Values)
      {
        if (!pet.isPassive && (pet.possibleBreeds == null || pet.possibleBreeds.Count == 0))
        {
          toRemove.Add(pet.speciesID);
          Console.WriteLine($"Removing {pet.speciesID}:{pet.name} due to no breeds");
        }
      }

      foreach (var id in toRemove)
        petsBySpeciesId.Remove(id);
    }

    static void ApplyDefaultBaseStats(ref Dictionary<int, Pet> petsBySpeciesId)
    {
      foreach (var pet in petsBySpeciesId.Values)
      {
        if (pet.baseStats == null)
        {
          pet.baseStats = new List<double> { 8, 8, 8 };
        }
        else
        {
          for (int i = 0; i < 3; i++)
            if (pet.baseStats[i] == -1)
              pet.baseStats[i] = 8;
        }
      }
    }
  }
}