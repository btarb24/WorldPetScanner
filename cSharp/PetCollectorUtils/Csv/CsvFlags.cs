using System;

namespace PetCollectorUtils.Csv
{
  [Flags]
  internal enum CsvFlags
  {
    NoRename = 1,
    WellKnown = 2,
    NotAcccountwide= 4,
    Capturable = 8,
    NotTradable = 16,
    HideFromJournal = 32,
    LegacyAccountUnique = 64,
    CantBattle = 128,
    HordeOnly = 256,
    AllianceOnly = 512,
    Boss = 1024,
    RandomDisplay = 2048,
    NoLicenseRequired = 4096,
    AddsAllowedWithBoss = 8192,
    HideUntilLearned = 16384,
    MatchPlayerHighPetLevel = 32768,
    NoWildPetAddsAllowed = 65536
  }
}