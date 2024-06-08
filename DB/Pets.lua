local WPS = WorldPetScanner

WPS.PetsViaQuests = {
    [44892] = {
        Name = "Snowfeather Swarm!",
        CustomTooltip = "Kill the Snowfeather Matriarch and then interact with the Orphaned Snowfeather to get the pet",
        Rewards = {
            [1] = {
                CreatureID = 128158,
                SpellID = 230073,
                CreatureName = "Snowfeather Hatchling",
                Guaranteed = true
            }
        }
    },
    [44893] = {
        Name = "Direbeak Swarm!",
        CustomTooltip = "Kill the Direbeak Matriarch and then interact with the Orphaned Direbeak to get the pet",
        Rewards = {
            [1] = {
                CreatureID = 115785,
                SpellID = 230074,
                CreatureName = "Direbeak Hatchling",
                Guaranteed = true
            }
        }
    },
    [44894] = {
        Name = "Bloodgazer Swarm!",
        CustomTooltip = "Kill the Bloodgazer Matriarch and then interact with the Orphaned Bloodgazer to get the pet",
        Rewards = {
            [1] = {
                CreatureID = 115787,
                SpellID = 230076,
                CreatureName = "Bloodgazer Hatchling",
                Guaranteed = true
            }
        }
    },
    [44895] = {
        Name = "Sharptalon Swarm!",
        CustomTooltip = "Kill the Sharptalon Matriarch and then interact with the Orphaned Sharptalon to get the pet",
        Rewards = {
            [1] = {
                CreatureID = 115786,
                SpellID = 230075,
                CreatureName = "Sharptalon Hatchling",
                Guaranteed = true
            }
        }
    },
    [73146] = {
        Name = "Cutting Wind",
        CustomTooltip = "Defeat Vortex when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form.",
        Rewards = {
            [1] = {
                CreatureID = 200769,
                SpellID = 398870,
                CreatureName = "Vortex",
                Guaranteed = true
            }
        }
    },
    [73147] = {
        Name = "Shifting Ground",
        CustomTooltip = "Defeat Tremblor when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form.",
        Rewards = {
            [1] = {
                CreatureID = 200770,
                SpellID = 398873,
                CreatureName = "Tremblor",
                Guaranteed = true
            }
        }
    },
    [73148] = {
        Name = "Combustible Vegetation",
        CustomTooltip = "Defeat Wildfire when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form.",
        Rewards = {
            [1] = {
                CreatureID = 200771,
                SpellID = 398872,
                CreatureName = "Wildfire",
                Guaranteed = false
            }
        }
    },
    [73149] = {
        Name = "Flood Warning",
        CustomTooltip = "Defeat Flow when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form.",
        Rewards = {
            [1] = {
                CreatureID = 200772,
                SpellID = 398871,
                CreatureName = "Flow",
                Guaranteed = true
            }
        }
    },
    [63824] = {
        Name = "Kyrian Assault",
        CustomTooltip = {
            "-Find Sly once per 3 different Kyrian Assault events and you'll receive Sly in your mailbox.",
            "-Complete the quest to receive an [Ascended War Chest] reward for chance at [Copperback Etherwyrm].",
            "-During the Kyrian Assault event there's a cage at 30,43. Pull down the cage to receive [Sinfall Screecher]. Xandria cannot be offering Quest [No One Floats Down Here]."
        },
        Rewards = {
            [1] = {
                CreatureID = 179083,
                SpellID = 353450,
                CreatureName = "Sly",
                Guaranteed = true
            },
            [2] = {
                CreatureID = 179083,
                SpellID = 353451,
                CreatureName = "Copperback Etherwyrm",
                Guaranteed = false
            },
            [3] = {
                CreatureID = 173533,
                SpellID = 339670,
                CreatureName = "Sinfall Screecher",
                Guaranteed = true,
            -- the quest is not discoverable via API
            --    AdditionalCriteria = {
            --        QuestNotAvailable = 63827
            --    }
            }
        }
    },
    [63823] = {
        Name = "Night Fae Assault",
        CustomTooltip = {
            "-enter rift to get key from Elusive Keybinder(19,43|19,32|21,40|23,40) then open the Etherwyrm Cage(20.7,39.7) to get the [Infused Etherwyrm]",
            "-Complete the quest to receive an [War Chest of the Wild Hunt] reward for chance at [Invasive Buzzer].",
        },
        Rewards = {
            [1] = {
                CreatureID = 179025,
                SpellID = 353230,
                CreatureName = "Infused Etherwyrm",
                Guaranteed = true
            },
            [2] = {
                CreatureID = 179180,
                SpellID = 353569,
                CreatureName = "Invasive Buzzer",
                Guaranteed = false
            },
        }
    },
    [63543] = {
        Name = "Necrolord Assault",
        CustomTooltip = {
            "-His 5 body parts are scattered around the questing area. Collect a head, spare arm, torso, legs, and right hand then craft into [Lil' Abom]",
            "-Complete the quest to receive an [War Chest of the Undying Army] reward for chance at [Fodder].",
        },
        Rewards = {
            [1] = {
                CreatureID = 353206,
                SpellID = 353230,
                CreatureName = "Lil' Abom",
                Guaranteed = true
            },
            [2] = {
                CreatureID = 179171,
                SpellID = 353529,
                CreatureName = "Fodder",
                Guaranteed = false
            },
        }
    },
    [78370] = {
        Name = "Claws for Concern",
        CustomTooltip = "Find all 18 birds for the Fiends in Feathers achievement. Best to do it in a raid so you can get them all in one event.",
        Rewards = {
            [1] = {
                CreatureID = 179132,
                SpellID = 426060,
                CreatureName = "Blueloo",
                Guaranteed = true
            }
        }
    },
    [65256] = {
        Name = "Cluck, Cluck, Boom",
        CustomTooltip = "Complete the quest for a chance at receiving [Schematic: Violent Poultrid].",
        Rewards = {
            [1] = {
                CreatureID = 189366,
                SpellID = 364178,
                CreatureName = "Violent Poultrid",
                Guaranteed = false
            }
        }
    },
    [66070] = {
        Name = "Brightblade's Bones",
        CustomTooltip = "Bring an [Eroded Fossil] and [Petrified Dragon Egg] to Cymre Brightblade to receive the pet.",
        Rewards = {
            [1] = {
                CreatureID = 192350,
                SpellID = 377392,
                CreatureName = "Bugbiter Tortoise",
                Guaranteed = true
            }
        }
    },
    [51212] = {
        Name = "Waycrest Manor: Witchy Kitchen",
        CustomTooltip = "Don't kill Roast Chef Rhondo or Sauciere Samuel. Keep them alive until a chicken offers you quest [Cutting Edge Poultry Science]. Turn in at booty bay.",
        Rewards = {
            [1] = {
                CreatureID = 139372,
                SpellID = 273869,
                CreatureName = "Vengeful Chicken",
                Guaranteed = true
            }
        }
    },
    [65102] = {
        Name = "Fish Eyes",
        CustomTooltip = "Complete the quest for a chance at receiving [Aurelid Lattice], which can be used to craft a few pets.",
        Rewards = {
            [1] = {
                CreatureID = 184192,
                SpellID = 364184,
                CreatureName = "Terror Jelly",
                Guaranteed = false
            },
            [2] = {
                CreatureID = 184193,
                SpellID = 364193,
                CreatureName = "Prototickles",
                Guaranteed = false
            },
            [3] = {
                CreatureID = 184186,
                SpellID = 364259,
                CreatureName = "Archetype of Renewal",
                Guaranteed = false,
            },
        }
    },
}

WPS.PetsViaRareDrop = {
    [56308] = {
        Name = "Assault: Aqir Unearthed", --uldum
        Rewards = {
            [1] = {
                RareID = 162140,
                RareName = "Skikx'traz",
                CreatureName = "Aqir Tunneler",
                CreatureID = 162004,
                SpellID = 315360,
                ItemID = 174476,
                ItemName = "Black Chitinous Plate",
                Guaranteed = false
            },
            [2] = {
                RareID = 154604,
                RareName = "Lord Aj'qirai",
                CreatureID = 161997,
                CreatureName = "Rotbreath",
                SpellID = 315355,
                ItemID = 174475,
                ItemName = "Stinky Sack",
                Guaranteed = false
            },
        }
    },
    [57157]= {
        Name = "Assault: The Black Empire", --uldum
        CustomTooltip = "Travel to 59.8, 72.4 and click on the Pyre. The pyre is not always available during the Assault.",
        Rewards = {
            [1] = {
                RareID = 157593,
                RareName = "Amalgamation of Flesh",
                CreatureName = "Wicked Lurker",
                CreatureID = 174478,
                SpellID = 315370,
                ItemID = 174478,
                ItemName = "Wicked Lurker",
                Guaranteed = false
            },
        }
    },
}

WPS.PetViaAchievement = {
    [18384] = { --Whelp, There It Is
        CreatureID = 204369,
        SpellID = 408330,
        CreatureName = "Axel",
        Guaranteed = true
    }
}

WPS.ItemsViaDaily = {
    [37203] = {
        Name = "Ashlei",
        NpcID = 87124,
        ZoneID = 539,
        ExpansionID = 6,
        Reward = {
            Type = WPS.REWARD_TYPE.ITEM,
            ItemID = WPS.PetCharm,
            Quantity = 2,            
            Guaranteed = true
        },
    },
    [37207] = {
        Name = "Vesharr",
        NpcID = 87123,
        ZoneID = 542,
        ExpansionID = 6,
        Reward = {
            Type = WPS.REWARD_TYPE.ITEM,
            ItemID = WPS.PetCharm,
            Quantity = 2,
            Guaranteed = true
        },
    },
    [37208] = {
        Name = "Teralune",
        NpcID = 87125,
        ZoneID = 535,
        ExpansionID = 6,
        Reward = {
            Type = WPS.REWARD_TYPE.ITEM,
            ItemID = WPS.PetCharm,
            Quantity = 2,
            Guaranteed = true
        },
    },
    [37206] = {
        Name = "Tarr the Terrible",
        NpcID = 87110,
        ZoneID = 550,
        ExpansionID = 6,
        Reward = {
            Type = WPS.REWARD_TYPE.ITEM,
            ItemID = WPS.PetCharm,
            Quantity = 2,
            Guaranteed = true
        },
    },
    [37205] = {
        Name = "Gargra",
        NpcID = 87122,
        ZoneID = 525,
        ExpansionID = 6,
        Reward = {
            Type = WPS.REWARD_TYPE.ITEM,
            ItemID = WPS.PetCharm,
            Quantity = 2,
            Guaranteed = true
        },
    },
    [37201] = {
        Name = "Cymre Brightblade",
        NpcID = 83837,
        ZoneID = 543,
        ExpansionID = 6,
        Reward = {
            Type = WPS.REWARD_TYPE.ITEM,
            ItemID = WPS.PetCharm,
            Quantity = 2,
            Guaranteed = true
        },
    },
}