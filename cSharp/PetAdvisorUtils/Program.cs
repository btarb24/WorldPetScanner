using NLua;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetAdvisorUtils
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
        pets.Add(new Pet((LuaTable)kvp.Value));
      }

      var sorted = pets.OrderBy((p) => p.speciesID);
      var sb = new StringBuilder();
      sb.AppendLine("pets = {");
      foreach (var pet in sorted)
      {
        sb.AppendLine($"{pet.Serialize()}, ");
      }
      sb.Append("}");
      var result = sb.ToString();
      
    }
  }
}
