using System;
using System.Xml.Linq;

namespace PetCollectorUtils.Csv
{
  internal enum CsvSourceType
  {
		Unknown = -1,
		Drop = 0,
		Quest = 1,
		Vendor = 2,
		Profession = 3,
		WildPet = 4,
		Achievement = 5,
		WorldEvent = 6,
		Promotion = 7,
		Tcg = 8,
		PetStore = 9,
		Discovery = 10,
		TradingPost = 11,
  }
}