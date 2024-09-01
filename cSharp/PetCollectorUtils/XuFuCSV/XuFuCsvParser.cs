using Microsoft.VisualBasic.FileIO;
using System;
using System.CodeDom;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection.Emit;

namespace PetCollectorUtils.Csv
{
  public class XuFuCsvParser
  {
    public void Compare(Dictionary<int, Pet> petsBySpeciesId)
    {
      var csvStr = File.ReadAllText(@"C:\Users\btarb\Downloads\Pet_Collection_Export_XuFu (1).csv");
      var parser = new TextFieldParser(new StringReader(csvStr));
      parser.SetDelimiters(",");


      var nameIdx = -1;
      var speciesIdx = -1;
      var availableBreedIdx = -1;
      var baseHealthIdx = -1;
      var basePowerIdx = -1;
      var baseSpeedIdx = -1;
      var canBattleIdx = -1;
      var keys = parser.ReadFields();
      for (var i = 0; i < keys.Length; i++)
      {
        if (keys[i] == "Name")
          nameIdx = i;
        else if (keys[i] == "Species")
          speciesIdx = i;
        else if (keys[i] == "Available Breeds")
          availableBreedIdx = i;
        else if (keys[i] == "Base Health")
          baseHealthIdx = i;
        else if (keys[i] == "Base Power")
          basePowerIdx = i;
        else if (keys[i] == "Base Speed")
          baseSpeedIdx = i;
        else if (keys[i] == "Can Battle")
          canBattleIdx = i;
      }

      while (!parser.EndOfData)
      {
        var items = parser.ReadFields();
        var name = items[nameIdx];
        var species = Convert.ToInt32(items[speciesIdx]);
        var availableBreeds  = items[availableBreedIdx];
        var breeds = ConvertBreeds(availableBreeds);
        var baseHealth = Convert.ToDouble(items[baseHealthIdx]);
        var basePower = Convert.ToDouble(items[basePowerIdx]);
        var baseSpeed = Convert.ToDouble(items[baseSpeedIdx]);
        var canBattle = items[canBattleIdx] == "Yes";

        petsBySpeciesId.TryGetValue(species, out Pet pet);
        if (pet == null)
        {
          Console.WriteLine($"NotOnWH         {species} - {name}");
          continue;
        }

        if (pet.name != name)
          Console.WriteLine($"Name            {species} - xu:{name}   wh:{pet.name}");

        if (pet.baseStats[0] != baseHealth || pet.baseStats[1] != basePower || pet.baseStats[2] != baseSpeed)
          Console.WriteLine($"Stats           {species} - {name}   xu:{baseHealth} {basePower} {baseSpeed}  blizzard:{pet.baseStats[0]} {pet.baseStats[1]} {pet.baseStats[2]}");

        if (!canBattle)
          continue;

        if (pet.possibleBreeds == null && breeds.Count == 0)
          continue;
        else if (pet.possibleBreeds == null && breeds.Any())
          Console.WriteLine($"Breed Missing   {species} - {name}   xu:{string.Join(",", breeds.Select(n => n.ToString()).ToArray())}  wh: none");
        else if (pet.possibleBreeds.Any() == true && breeds.Count == 0)
          Console.WriteLine($"Breed Missing   {species} - {name}   xu:none  wh:{string.Join(",", pet.possibleBreeds?.Select(n => n.ToString()).ToArray())}");
        else if (!Enumerable.SequenceEqual(pet.possibleBreeds.OrderBy(t => t), breeds.OrderBy(t => t)))
          Console.WriteLine($"Breeds differ   {species} - {name}   xu:{string.Join(",", breeds.Select(n => n.ToString()).ToArray())}  wh:{string.Join(",", pet.possibleBreeds?.Select(n => n.ToString()).ToArray())}");
      }
    }

    private List<int> ConvertBreeds(string csvBreeds)
    {
      var breeds = new List<int>();
      var split = csvBreeds.Split(',');
      foreach(var item in split )
      {
        switch (item)
        {
          case "BB":
            breeds.Add(1);
            break;
          case "PP":
            breeds.Add(2);
            break;
          case "SS":
            breeds.Add(3);
            break;
          case "HH":
            breeds.Add(4);
            break;
          case "HP":
            breeds.Add(5);
            break;
          case "PS":
            breeds.Add(6);
            break;
          case "HS":
            breeds.Add(7);
            break;
          case "PB":
            breeds.Add(8);
            break;
          case "SB":
            breeds.Add(9);
            break;
          case "HB":
            breeds.Add(10);
            break;
        }
      }

      return breeds;
    }
  }
}