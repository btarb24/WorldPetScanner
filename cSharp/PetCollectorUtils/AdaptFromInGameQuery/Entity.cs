using NLua;
using System.Collections.Generic;
using System.Text;

namespace PetCollectorUtils
{
  public class Entity : ISerializable
  {
    public string name;
    public string ID;

    public string Serialize()
    {
      StringBuilder sb = new StringBuilder();

      sb.Append("{{");
      if (ID != null)
        sb.Append($"id={ID}");

      sb.Append($"{{name=\"{name}\"");

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
