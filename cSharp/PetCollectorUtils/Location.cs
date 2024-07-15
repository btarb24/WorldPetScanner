using NLua;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PetCollectorUtils
{
  public class Location : ISerializable
  {
    public string continent;
    public string zone;
    public string area;
    public int mapID;
    public int mapFloor;
    public List<Coord> coords = new List<Coord>();

    public Location() { }
    public Location(string location)
    {
      zone = location;
      if (IsSubArea(zone, out var newZone))
      {
        area = zone;
        zone = newZone;
      }
      continent = GetContinent(zone);
    }

    public string Serialize()
    {
      StringBuilder sb = new StringBuilder();

      sb.Append($"{{continent=\"{continent}\"");
      if (zone != null)
        sb.Append($", zone=\"{zone}\"");

      if (area != null)
        sb.Append($", area=\"{area}\"");

      if (mapID != 0)
        sb.Append($", mapID={mapID}");

      if (mapFloor != 0)
        sb.Append($", mapFloor={mapFloor}");

      if (coords.Any())
      {
        sb.Append($", coords={{");
        foreach (var coord in coords)
        {
          sb.Append($"{{{coord.x},{coord.y}}},");
        }
        sb.Append($"}}");
      }

      sb.Append("}");
      return sb.ToString();
    }

    public static Location[] Parse(LuaTable table)
    {
      List<Location> locations = new List<Location>();
      foreach (var value in table.Values)
      {
        locations.Add(new Location(value.ToString()));
      }

      return locations.ToArray();
    }

    public static string GetContinent(string zone)
    {
      switch (zone)
      {
        case "Antoran Wastes":
        case "Krokuun":
        case "Eredath":
        case "Vindicaar":
          return "Argus";

        case "Dalaran (Broken Isles)":
        case "Azsuna":
        case "Eye of Azshara":
        case "Highmountain":
        case "Stormheim":
        case "Val'sharah":
        case "Broken Shore":
        case "Suramar":
        case "The Deaths of Chromie":
          return "Broken Isles";

        case "Stormshield":
        case "Warspear":
        case "Ashran":
        case "Frostfire Ridge":
        case "Frostwall":
        case "Lunarfall":
        case "Shadowmoon Valley (Draenor)":
        case "Gorgrond":
        case "Talador":
        case "Spires of Arak":
        case "Nagrand (Draenor)":
        case "Tanaan Jungle":
        case "Garrison":
          return "Draenor";

        case "The Waking Shores":
        case "Ohn'ahran Plains":
        case "The Azure Span":
        case "Thaldraszus":
        case "Emerald Dream":
        case "The Forbidden Reach":
        case "Zaralek Cavern":
        case "Valdrakken":
          return "Dragon Isles";

        case "Gilneas City":
        case "Ironforge":
        case "Silvermoon City":
        case "Stormwind City":
        case "Undercity":
        case "Gilneas":
        case "Dun Morogh":
        case "Elwynn Forest":
        case "Eversong Woods":
        case "Ghostlands":
        case "Tirisfal Glades":
        case "Arathi Highlands":
        case "Deadwind Pass":
        case "Duskwood":
        case "Northern Stranglethorn":
        case "The Cape of Stranglethorn":
        case "The Hinterlands":
        case "Wetlands":
        case "Badlands":
        case "Blasted Lands":
        case "Burning Steppes":
        case "Eastern Plaguelands":
        case "Searing Gorge":
        case "Swamp of Sorrows":
        case "Western Plaguelands":
        case "Twilight Highlands":
        case "Vashj'ir":
        case "Loch Modan":
        case "Silverpine Forest":
        case "Westfall":
        case "Hillsbrad Foothills":
        case "Redridge Mountains":
        case "Blackrock Mountain":
        case "Ruins of Gilneas":
          return "Eastern Kingdoms";

        case "Darnassus":
        case "Orgrimmar":
        case "The Exodar":
        case "Thunder Bluff":
        case "Azuremyst Isle":
        case "Bloodmyst Isle":
        case "Durotar":
        case "Moonglade":
        case "Mulgore":
        case "Teldrassil":
        case "Desolace":
        case "Southern Barrens":
        case "Stonetalon Mountains":
        case "Ahn'Qiraj: The Fallen Kingdom":
        case "Dustwallow Marsh":
        case "Felwood":
        case "Feralas":
        case "Silithus":
        case "Tanaris":
        case "Thousand Needles":
        case "Un'Goro Crater":
        case "Winterspring":
        case "Mount Hyjal":
        case "Uldum":
        case "Molten Front":
        case "Azshara":
        case "Darkshore":
        case "Northern Barrens":
        case "Ashenvale":
        case "Ammen Vale":
          return "Kalimdor";

        case "Boralus":
        case "Tiragarde Sound":
        case "Drustvar":
        case "Stormsong Valley":
        case "Mechagon":
        case "Nazjatar":
          return "Kul Tiras";

        case "Dalaran (Northrend)":
        case "Borean Tundra":
        case "Howling Fjord":
        case "Dragonblight":
        case "Grizzly Hills":
        case "Sholazar Basin":
        case "Zul'Drak":
        case "Crystalsong Forest":
        case "Icecrown":
        case "The Storm Peaks":
        case "Wintergrasp":
          return "Northrend";

        case "Shattrath City":
        case "Hellfire Peninsula":
        case "Zangarmarsh":
        case "Nagrand (Outland)":
        case "Terokkar Forest":
        case "Blade's Edge Mountains":
        case "Netherstorm":
        case "Shadowmoon Valley (Outland)":
        case "Isle of Quel'Danas":
          return "Outland";

        case "Shrine of Seven Stars":
        case "Shrine of Two Moons":
        case "The Jade Forest":
        case "Krasarang Wilds":
        case "Valley of the Four Winds":
        case "Kun-Lai Summit":
        case "Townlong Steppes":
        case "Dread Wastes":
        case "The Veiled Stair":
        case "Timeless Isle":
        case "Vale of Eternal Blossoms":
        case "Isle of Thunder":
        case "Isle of Giants":
        case "The Wandering Isle":
          return "Pandaria";

        case "Oribos":
        case "Bastion":
        case "Maldraxxus":
        case "Ardenweald":
        case "Revendreth":
        case "Korthia":
        case "The Maw":
        case "The In-Between":
        case "Zereth Mortis":
          return "Shadowlands";

        case "Kezan":
        case "The Lost Isles":
        case "Darkmoon Island":
        case "Deepholm":
        case "Tol Barad Peninsula":
        case "Tol Barad":
          return "The Maelstrom";

        case "Dazar'alor":
        case "Zuldazar":
        case "Nazmir":
        case "Vol'dun":
          return "Zandalar";


        default:
          Console.WriteLine(zone);
          throw new Exception();
      }
    }
    public static bool IsSubArea(string zone, out string newZone)
    {
      newZone = null;

      switch (zone)
      {
        case "The Bastion of Twilight":
          newZone = "Twilight Highlands";
          return true;
        case "Blackwing Descent":
        case "Lower Blackrock Spire":
        case "Upper Blackrock Spire":
        case "Molten Core":
        case "Molten Core (Anniversary Edition)":
        case "Blackwing Lair":
          newZone = "Blackrock Mountain";
          return true;
        case "Throne of the Four Winds":
        case "Ny'alotha, the Waking City":
          newZone = "Uldum";
          return true;
        case "The Deadmines":
          newZone = "Westfall";
          return true;
        case "Booty Bay":
          newZone = "The Cape of Stranglethorn";
          return true;
        case "Zul'Aman":
          newZone = "Ghostlands";
          return true;
        case "Magisters' Terrace":
        case "Sunwell Plateau":
          newZone = "Isle of Quel'Danas";
          return true;
        case "Karazhan":
          newZone = "Deadwind Pass";
          return true;
        case "Wailing Caverns":
        case "Wailing Caverns (Pet Dungeon)":
          newZone = "Northern Barrens";
          return true;
        case "Zul'Gurub":
          newZone = "Northern Stranglethorn";
          return true;
        case "Heart of Fear":
          newZone = "Dread Wastes";
          return true;
        case "Caverns of Time":
        case "Well of Eternity":
        case "The Culling oF Stratholme":
        case "Hyjal Summit":
        case "Dragon Soul":
          newZone = "Tanaris";
          return true;
        case "Firelands":
          newZone = "Mount Hyjal";
          return true;
        case "Iron Docks":
          newZone = "Gorgrond";
          return true;
        case "Hellfire Citadel":
          newZone = "Tanaan Jungle";
          return true;
        case "Azjol-Nerub":
        case "Naxxramas":
          newZone = "Dragonblight";
          return true;
        case "Black Temple":
          newZone = "Shadowmoon Valley (Draenor)";
          return true;
        case "Helheim":
          newZone = "Stormheim";
          return true;
        case "Drak'Tharon Keep":
          newZone = "Grizzly Hills";
          return true;
        case "Icecrown Citadel":
        case "The Forge of Souls":
        case "Trial of the Crusader":
          newZone = "Icecrown";
          return true;
        case "The Violet Hold":
          newZone = "Dalaran (Northrend)";
          return true;
        case "Dalaran Sewers":
          newZone = "Dalaran (Broken Isles)";
          return true;
        case "Utgarde Keep":
        case "Utgarde Pinnacle":
          newZone = "Howling Fjord";
          return true;
        case "Island Expeditions":
          newZone = "Boralus";
          return true;
        case "Scarlet Monastery":
          newZone = "Tirisfal Glades";
          return true;
        case "Sunken Temple":
          newZone = "Swamp of Sorrows";
          return true;
        case "Battle of Dazar'alor":
          newZone = "Zuldazar";
          return true;
        case "Mogu'shan Vaults":
        case "Isle Of Giants":
          newZone = "Kun-Lai Summit";
          return true;
        case "The Eternal Palace":
          newZone = "Nazjatar";
          return true;
        case "Operation: Mechagon":
          newZone = "Mechagon";
          return true;
        case "Vision of Orgrimmar":
        case "Vision of Stormwind":
        case "Vision of the Twisting Sands":
        case "Temple of Ahn'Qiraj":
          newZone = "Silithus";
          return true;
        case "Plaguefall":
          newZone = "Maldraxxus";
          return true;
        case "Torghast":
        case "Torghast, Tower of the Damned":
        case "Sanctum of Domination":
          newZone = "The Maw";
          return true;
        case "Castle Nathria":
        case "Sanguine Depths":
          newZone = "Revendreth";
          return true;
        case "Mists of Tirna Scithe":
          newZone = "Ardenweald";
          return true;
        case "Tazavesh, the Veiled Market":
          newZone = "Oribos";
          return true;
        case "Deeprun Tram":
          newZone = "Stormwind City";
          return true;
        case "Brawl'gar Arena":
          newZone = "Orgrimmar";
          return true;
        case "Gnomeregan":
          newZone = "Dun Morogh";
          return true;
        case "Throne of Thunder":
          newZone = "Isle of Thunder";
          return true;
        case "Serpentshrine Cavern":
          newZone = "Zangarmarsh";
          return true;
        case "Tempest Keep":
          newZone = "Netherstorm";
          return true;
        case "Zskera Vaults":
          newZone = "The Forbidden Reach";
          return true;
        case "The Primalist Future":
          newZone = "Thaldraszus";
          return true;
        case "Siege of Orgrimmar":
          newZone = "Vale of Eternal Blossoms";
          return true;
        case "The Emerald Nightmare":
          newZone = "Val'sharah";
          return true;
        case "Terrace of Endless Spring":
          newZone = "The Veiled Stair";
          return true;
        case "Ulduar":
          newZone = "The Storm Peaks";
          return true;
        case "Waycrest Manor":
          newZone = "Drustvar";
          return true;
        case "Tol Dagor":
          newZone = "Tiragarde Sound";
          return true;
        case "Temple of Sethraliss":
          newZone = "Vol'dun";
          return true;
      }

      return false;
    }
  }
}