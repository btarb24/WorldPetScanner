using System;
using System.Collections.Generic;

namespace PetCollectorUtils
{
  [Flags]
  public enum WowHeadBreeds
  {
    NONE = 0,
    BB = 1,
    PP = 2,
    SS = 4,
    HH = 8,
    HP = 16,
    PS = 32,
    HS = 64,
    PB = 128,
    SB = 256,
    HB = 512
  }

  public static class WowHeadBreedsExtensions
  {
    public static string[] ToFriendlyStrings(this WowHeadBreeds breeds)
    {
      var list = new List<string>();
      if (breeds.HasFlag(WowHeadBreeds.BB))
        list.Add("B/B");
      if (breeds.HasFlag(WowHeadBreeds.PP))
        list.Add("P/P");
      if (breeds.HasFlag(WowHeadBreeds.SS))
        list.Add("S/S");
      if (breeds.HasFlag(WowHeadBreeds.HH))
        list.Add("H/H");
      if (breeds.HasFlag(WowHeadBreeds.HP))
        list.Add("H/P");
      if (breeds.HasFlag(WowHeadBreeds.PS))
        list.Add("P/S");
      if (breeds.HasFlag(WowHeadBreeds.HS))
        list.Add("H/S");
      if (breeds.HasFlag(WowHeadBreeds.PB))
        list.Add("P/B");
      if (breeds.HasFlag(WowHeadBreeds.SB))
        list.Add("S/B");
      if (breeds.HasFlag(WowHeadBreeds.HB))
        list.Add("H/B");

      return list.ToArray();
    }
  }
}