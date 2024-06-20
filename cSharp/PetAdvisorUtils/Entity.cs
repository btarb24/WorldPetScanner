using NLua;
using System.Collections.Generic;
using System.Text;

namespace PetAdvisorUtils
{
  public class Entity : ISerializable
  {
    public string name;
    public int ID;

    public string Serialize()
    {
      StringBuilder sb = new StringBuilder();

      sb.Append($"{{name=\"{name}\"");
      if (ID != 0)
        sb.Append($", ID={ID}");

      sb.Append("}");
      return sb.ToString();
    }

    public static Entity[] Parse(LuaTable table)
    {
      var entities = new List<Entity>();
      foreach (var value in table.Values)
      {
        entities.Add(new Entity { name = value.ToString().Replace("\"", "\\\"") });
      }

      return entities.ToArray();
    }
  }
}
