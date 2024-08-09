using System;

namespace PetCollectorUtils
{
  [Flags]
  internal enum Breeds
  {
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
}