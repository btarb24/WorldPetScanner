local WPS = WorldPetScanner

WPS.TRIGGER_TYPE = {
    WORLD_QUEST = "worldQuest",
    DAILY_QUEST = "dailyQuest",
    AURA = "aura",
    ACHIEVEMENT = "achievement",
    AREA_POI = "areapoi",
}
WPS.QUEST_EVAL_TYPE = {
    FLAG = "flaggedCompletion",
    ISACTIVE = "isActive",
    BYMAP = "GetQuestsForPlayerBymapID",
}

WPS.TaskData = {
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.AURA,
            auraID = 335150,
            auraName = "Sign of the Destroyer",
            auraDescription = "Cataclysm Timewalking",
            isTimewalking = true,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.VENDOR,
            expansionID = 4,
            zoneID = {
                Alliance = 84,
                Horde = 85
            },
            vendorID = 101759,
            vendorName = "Kiatke <Timewalking Vendor>",
            note = "Located in Stormwind City (76, 17) and Orgrimmar (52,42) during Cataclysm Timewalking",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureName = "Strand Crawler",
                creatureID = 33226,
                spellID = 62561,
                itemID = 67414,
                itemName = "Bag of Shiny Things",
                chance = true,
                note = "Purchase a [Bag of Shiny Things] from Kiatke for 150 [Timewarped Badge]\nIt has roughly 1% chance of yielding a [Strand Crawler]."
            }
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37203,
            questName = "Ashlei",
            isTimewalking = true,
            questEvaluationType = WPS.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            perAccount = true,
            isTrainer = true,
            expansionID = 6,
            zoneID = 539,
            questID = 37203,
            questName = "Ashlei",
            npcID = 87124,
            npcName = "Ashlei",
            note = "Defeat Ashlei in a pet battle at 50,31. High pet xp."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.ITEM,
                itemID = WPS.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37207,
            questName = "Vesharr",
            isTimewalking = true,
            questEvaluationType = WPS.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            perAccount = true,
            isTrainer = true,
            expansionID = 6,
            zoneID = 542,
            questID = 37207,
            questName = "Vesharr",
            npcID = 87123,
            npcName = "Vesharr",
            note = "Defeat Vesharr in a pet battle at 46,45. High pet xp."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.ITEM,
                itemID = WPS.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37208,
            questName = "Taralune",
            isTimewalking = true,
            questEvaluationType = WPS.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            perAccount = true,
            isTrainer = true,
            expansionID = 6,
            zoneID = 535,
            questID = 37208,
            questName = "Taralune",
            npcID = 87125,
            npcName = "Taralune",
            note = "Defeat Taralune in a pet battle at 49,80. High pet xp."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.ITEM,
                itemID = WPS.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37206,
            questName = "Tarr the Terrible",
            isTimewalking = true,
            questEvaluationType = WPS.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            perAccount = true,
            isTrainer = true,
            expansionID = 6,
            zoneID = 550,
            questID = 37206,
            questName = "Tarr the Terrible",
            npcID = 87110,
            npcName = "Tarr the Terrible",
            note = "Defeat Tarr the Terrible in a pet battle at 56,10. High pet xp."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.ITEM,
                itemID = WPS.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37205,
            questName = "Gargra",
            isTimewalking = true,
            questEvaluationType = WPS.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            perAccount = true,
            isTrainer = true,
            expansionID = 6,
            zoneID = 525,
            questID = 37205,
            questName = "Gargra",
            npcID = 87122,
            npcName = "Gargra",
            note = "Defeat Gargra in a pet battle at 69,65. High pet xp."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.ITEM,
                itemID = WPS.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37201,
            questName = "Cymre Brightblade",
            isTimewalking = true,
            questEvaluationType = WPS.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            perAccount = true,
            isTrainer = true,
            expansionID = 6,
            zoneID = 543,
            questID = 37201,
            questName = "Cymre Brightblade",
            npcID = 83837,
            npcName = "Cymre Brightblade",
            note = "Defeat Cymre Brightblade in a pet battle at 51,71. High pet xp."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.ITEM,
                itemID = WPS.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 63543,
            questName = "Necrolord Assault",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1543,
            questID = 63543,
            questName = "Necrolord Assault",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 353206,
                spellID = 353230,
                creatureName = "Lil' Abom",
                note = "His 5 body parts are scattered around the questing area. Collect and combine into the pet.\n  -Lil' Abom Head - 32.2 56.0 | 30.3 63.3 | 27.4 56.6\n  -Lil' Abom Spare Arm - 33.3 65.8 | 39.2 66.5\n  -Lil' Abom Torso - 36.4 64.4 | 39.9 62.6 (cave ent:36.9 67.4)\n  -Lil' Abom Legs - 29.4 67.2\n  -Lil' Abom Right Hand - back of cave on left 38.5 58.5"
            },
            [2] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 179171,
                spellID = 353529,
                creatureName = "Fodder",
                itemID = 185992,
                itemName = "War Chest of the Undying Army",
                chance = true,
                note = "Complete the quest to receive an [War Chest of the Undying Army] reward for an 11% chance at [Fodder]."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 63824,
            questName = "Kyrian Assault",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1543,
            questID = 63824,
            questName = "Kyrian Assault",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 179083,
                spellID = 353450,
                creatureName = "Sly",
                note = "Find Sly once per 3 different Kyrian Assault events and you'll receive Sly in your mailbox.\nFirst, talk to Orator Kloe (42,44) to get the Sharp Eyed buff\n  1: follow footprints to 40,51 and click Sly\n  2: follow footprints to 38,39 and click Sly\n  3: follow footprints to 32,44 and click Sly (sent to mailbox)"
            },
            [2] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 179083,
                spellID = 353451,
                creatureName = "Copperback Etherwyrm",
                itemID = 185993,
                itemName = "Ascended War Chest",
                chance = true,
                note = "Complete the quest to receive an [Ascended War Chest] reward for an 11% chance at [Copperback Etherwyrm]."
            },
            [3] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 173533,
                spellID = 339670,
                creatureName = "Sinfall Screecher",
                note = "During the Kyrian Assault event there's a cage at 30,43. Pull down the cage to receive [Sinfall Screecher].\n  note: Xandria cannot be offering Quest [No One Floats Down Here]."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 63823,
            questName = "Night Fae Assault",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1543,
            questID = 63823,
            questName = "Night Fae Assault",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 179025,
                spellID = 353230,
                creatureName = "Infused Etherwyrm",
                note = "Acquire a key from someone in the Rift and then open a cage to receive the pet\n  1: (Rift)Kill an Elusive Keybinder to receive key. rough area of 24,40 | 21,39 | 23,42\n  2: (Normal Phase) go to cave entrance 21,39\n  3: Open cage at 23,42"
            },
            [2] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 179180,
                spellID = 353569,
                creatureName = "Invasive Buzzer",
                itemID = 185991,
                itemName = "Ascended War Chest",
                chance = true,
                note = "Complete the quest to receive an [War Chest of the Wild Hunt] reward for an 11% chance at [Invasive Buzzer]."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44892,
            questName = "Snowfeather Swarm!",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 650,
            questID = 44892,
            questName = "Snowfeather Swarm!",
            checkForExistingTask = true,
            note = "Kill the Snowfeather Matriarch (48,10) and then click the Orphaned Snowfeather (32,28)"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 128158,
                spellID = 230073,
                creatureName = "Snowfeather Hatchling",
                note = "Kill the Snowfeather Matriarch (48,10) and then click the Orphaned Snowfeather (32,28)"
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44893,
            questName = "Direbeak Swarm!",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 634,
            questID = 44893,
            questName = "Direbeak Swarm!",
            checkForExistingTask = true,
            note = "Kill the Direbeak Matriarch (78,76) and then click the Orphaned Direbeak (80,70)"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 115785,
                spellID = 230074,
                creatureName = "Direbeak Hatchling",
                note = "Kill the Direbeak Matriarch (78,76) and then click the Orphaned Direbeak (80,70)"
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44894,
            questName = "Bloodgazer Swarm!",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 630,
            questID = 44894,
            questName = "Bloodgazer Swarm!",
            checkForExistingTask = true,
            note = "Kill the Bloodgazer Matriarch (35,6) and then click the Bloodgazer Direbeak (35,8)"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 115787,
                spellID = 230076,
                creatureName = "Bloodgazer Hatchling",
                note = "Kill the Bloodgazer Matriarch (35,6) and then click the Bloodgazer Direbeak (35,8)"
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44895,
            questName = "Bloodgazer Swarm!",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 641,
            questID = 44895,
            questName = "Sharptalon Swarm!",
            checkForExistingTask = true,
            note = "Kill the Sharptalon Matriarch (48,10) and then click the Sharptalon Direbeak (47,10)"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 115786,
                spellID = 230075,
                creatureName = "Sharptalon Hatchling",
                note = "Kill the Sharptalon Matriarch (48,10) and then click the Sharptalon Direbeak (47,10)"
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73146,
            questName = "Cutting Wind",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73146,
            questName = "Cutting Wind",
            checkForExistingTask = true,
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 200769,
                spellID = 398870,
                creatureName = "Vortex",
                note = "Defeat Vortex when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73147,
            questName = "Shifting Ground",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73147,
            questName = "Shifting Ground",
            checkForExistingTask = true,
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 200770,
                spellID = 398873,
                creatureName = "Tremblor",
                note = "Defeat Tremblor when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73148,
            questName = "Combustible Vegetation",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73148,
            questName = "Combustible Vegetation",
            checkForExistingTask = true,
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 200771,
                spellID = 398872,
                creatureName = "Wildfire",
                note = "Defeat Wildfire when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73149,
            questName = "Flood Warning",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73149,
            questName = "Flood Warning",
            checkForExistingTask = true,
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 200772,
                spellID = 398871,
                creatureName = "Flow",
                note = "Defeat Flow when it's in its rare form to receive the pet. No pet rewarded if it is in legendary or epic form."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 78370,
            questName = "Claws for Concern",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2200,
            questID = 78370,
            questName = "Claws for Concern",
            note = "Find all 18 birds for the Fiends in Feathers achievement. Best to do it in a raid so you can get them all in one event."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 179132,
                spellID = 426060,
                creatureName = "Blueloo",
                note = "Find all 18 birds for the Fiends in Feathers achievement. Best to do it in a raid so you can get them all in one event."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 65256,
            questName = "Cluck, Cluck, Boom",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1970,
            questID = 65256,
            questName = "Cluck, Cluck, Boom",
            note = "Complete the quest for a chance at receiving [Schematic: Violent Poultrid]."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 189366,
                spellID = 364178,
                creatureName = "Violent Poultrid",
                note = "Complete the quest for a chance at receiving [Schematic: Violent Poultrid]. Protoform synthesis costs:\n  200x Genesis Mote\n  1x Glimmer of Malice\n  1x Poultrid Lattice",
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 65102,
            questName = "Fish Eyes",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1970,
            questID = 65102,
            questName = "Fish Eyes",
            note = "Complete the quest for a chance at receiving [Aurelid Lattice], which can be used to craft a few pets."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 184192,
                spellID = 364184,
                creatureName = "Terror Jelly",
                chance = true
            },
            [2] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 184193,
                spellID = 364193,
                creatureName = "Prototickles",
                chance = true
            },
            [3] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 184186,
                spellID = 364259,
                creatureName = "Archetype of Renewal",
                chance = true
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 66070,
            questName = "Brightblade's Bones",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2022,
            questID = 66070,
            questName = "Brightblade's Bones",
            note = "Bring an [Eroded Fossil] and [Petrified Dragon Egg] to Cymre Brightblade to receive the pet."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 192350,
                spellID = 377392,
                creatureName = "Bugbiter Tortoise",
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 51212,
            questName = "Waycrest Manor: Witchy Kitchen",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 8,
            zoneID = 896,
            questID = 51212,
            questName = "Waycrest Manor: Witchy Kitchen",
            note = "Don't kill Roast Chef Rhondo or Sauciere Samuel. Keep them alive until a chicken\noffers you the quest [Cutting Edge Poultry Science]. Turn in at booty bay."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 139372,
                spellID = 273869,
                creatureName = "Vengeful Chicken",
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 8,
            zoneID = 1527, --uldum
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            npcID = 162140,
            npcName = "Skikx'traz",
            note = "Kill for a 2% chance to drop [Black Chitinous Plate], which yields the pet.\n  Located at 23,62 during Assault: Aqir Unearthed\nBurning the wastelander corpses can speed up the spawn time"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 162004,
                spellID = 315360,
                creatureName = "Aqir Tunneler",
                itemID = 174476,
                itemName = "Black Chitinous Plate",
                chance = true,
                note = "2% drop chance",
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 8,
            zoneID = 1527, --uldum
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            npcID = 154604,
            npcName = "Lord Aj'qirai",
            note = "Kill for a 2% chance to drop [Stinky Sack], which yields the pet.\n  Located at 34,18 inside the Chamber of the Moon during Assault: Aqir Unearthed\nSpawn time reported as 1-2 hours"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 161997,
                spellID = 315355,
                creatureName = "Rotbreath",
                itemID = 174475,
                itemName = "Stinky Sack",
                chance = true,
                note = "2% drop chance",
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 57157,
            questName = "Assault: The Black Empire",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 8,
            zoneID = 1527, --uldum
            questID = 57157,
            questName = "Assault: The Black Empire",
            npcID = 157593,
            npcName = "Amalgamation of Flesh",
            note = "Kill for a 2% chance to drop [Wicked Lurker].\nTravel to 59.8, 72.4 and click on the Pyre.  The rare will spawn during the 5th wave\nThe pyre respawns 1 minute after the rare was last killed\nOnly lootable once per day"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 174478,
                spellID = 315370,
                creatureName = "Wicked Lurker",
                itemID = 174478,
                itemName = "Wicked Lurker",
                chance = true,
                note = "2% drop chance",
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.ACHIEVEMENT,
            achievementID = 18384,
            achievementName = "Whelp, There It Is",
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.ACHIEVEMENT,
            expansionID = 10,
            zoneID = 2112,
            achievementID = 18384,
            achievementName = "Whelp, There It Is",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 204369,
                spellID = 408330,
                creatureName = "Axel",
                note = "Complete the quest lines at Valdrakken's Little Scales Daycare to satisfy the achievement. \nYou'll be given a handful of pets througout the sequence.\nit will take roughly a week or two to complete."
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 59808,
            questName = "Muck It Up",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 9,
            zoneID = 1525,
            questID = 59808,
            questName = "Muck It Up",
            npcID = 166292,
            npcName = "Bog Beast",
            note = "1. Collect [Primordial Muck] from mobs in the area of the Muck It Up world quest\n2. Join a raid group (otherwise you're limited to 4 spawn chances)\n\n3. Use the [Primordial Muck] for a chance to spawn the Bog Beast rare\n4. Leave the raid to collect more muck, repeat until the rare spawns\n  note: you can only loot him once per day and it has a 9% chance to drop the [Bucket of Primordial Sludge]"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 171121,
                spellID = 333799,
                creatureName = "Primordial Bogling",
                itemID = 180588,
                itemName = "Bucket of Primordial Sludge",
                note = "9% drop chance",
                chance = true
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 60655,
            questName = "A Stolen Stone Fiend",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1525,
            questID = 60655,
            questName = "A Stolen Stone Fiend",
            note = "1. Use the quest's [Stone Fiend Tracker] to find/free him several times\n2. defeat Edgar the Collector\n3. Speak to Penkle behind the building to receive a [Cage Key]\n4. Use the key to unlock the nearby cage to receive the pet"
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 171136,
                spellID = 333819,
                creatureName = "Dal",
                itemID = 183859,
                itemName = "Dal's Courier Badge",
            },
        }
    },
    {
        trigger = {
            type = WPS.TRIGGER_TYPE.WORLD_QUEST,
            questID = 60654,
            questName = "Swarming Souls",
            questEvaluationType = WPS.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 9,
            zoneID = 1525,
            questID = 60654,
            questName = "Swarming Souls",
            npcID = 170048,
            npcName = "Manifestation of Wrath",
            note = "Option1: Deliver souls to the Avowed Ritualist for a chance to spawn the Manifestation of Wrath\n for 9% loot drop of the [Bottled Up Rage]\nOption2: kill the Prideful Hulk rare at 68,82 for a 5% loot drop chance.\nKill Leeched Souls to spawn the rare."
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET_VIA_ITEM,
                creatureID = 171136,
                spellID = 333819,
                creatureName = "Wrathling",
                itemID = 183859,
                itemName = "Bottled Up Rage",
                chance = true,
                note = "9% drop from Manifestation of Wrath\n5% drop from Prideful Hulk",
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = WPS.TRIGGER_TYPE.AREA_POI,
            areaPOIList = {
                { areaPoiID = 7251, mapID = 2022 },
                { areaPoiID = 7255, mapID = 2022 },
                { areaPoiID = 7259, mapID = 2022 },
                { areaPoiID = 7250, mapID = 2022 },
                { areaPoiID = 7254, mapID = 2022 },
                { areaPoiID = 7258, mapID = 2022 },
                { areaPoiID = 7251, mapID = 2022 },
                { areaPoiID = 7255, mapID = 2022 },
                { areaPoiID = 7259, mapID = 2022 },
                { areaPoiID = 7252, mapID = 2022 },
                { areaPoiID = 7256, mapID = 2022 },
                { areaPoiID = 7260, mapID = 2022 }
            }
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2022,
            npcID = 192029,
            npcName = "Storm-Touched Stomper",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 192029,
                creatureName = "Storm-Touched Stomper",
                note = "Battle one and capture it during any storm event in The Waking Shores"
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = WPS.TRIGGER_TYPE.AREA_POI,
            areaPOIList = {
                { areaPoiID = 7221, mapID = 2023 },
                { areaPoiID = 7225, mapID = 2023 },
                { areaPoiID = 7222, mapID = 2023 },
                { areaPoiID = 7226, mapID = 2023 },
                { areaPoiID = 7223, mapID = 2023 },
                { areaPoiID = 7227, mapID = 2023 },
                { areaPoiID = 7224, mapID = 2023 },
                { areaPoiID = 7228, mapID = 2023 }
            }
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2023,
            npcID = 189660,
            npcName = "Storm-Touched Timbertooth",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 189660,
                creatureName = "Storm-Touched Timbertooth",
                note = "Battle one and capture it during any storm event in Ohn'ahran Plains"
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = WPS.TRIGGER_TYPE.AREA_POI,
            areaPOIList = {
                { areaPoiID = 7237, mapID = 2024 },
                { areaPoiID = 7233, mapID = 2024 },
                { areaPoiID = 7229, mapID = 2024 },
                { areaPoiID = 7238, mapID = 2024 },
                { areaPoiID = 7234, mapID = 2024 },
                { areaPoiID = 7230, mapID = 2024 },
                { areaPoiID = 7239, mapID = 2024 },
                { areaPoiID = 7235, mapID = 2024 },
                { areaPoiID = 7231, mapID = 2024 },
                { areaPoiID = 7240, mapID = 2024 },
                { areaPoiID = 7236, mapID = 2024 },
                { areaPoiID = 7232, mapID = 2024 }
            }
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2024,
            npcID = 192257,
            npcName = "Storm-Touched Ottuk",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 192257,
                creatureName = "Storm-Touched Ottuk",
                note = "Battle one and capture it during any storm event in The Azure Span"
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = WPS.TRIGGER_TYPE.AREA_POI,
            areaPOIList = {
                { areaPoiID = 7298, mapID = 2025 },
                { areaPoiID = 7245, mapID = 2025 },
                { areaPoiID = 7299, mapID = 2025 },
                { areaPoiID = 7246, mapID = 2025 },
                { areaPoiID = 7300, mapID = 2025 },
                { areaPoiID = 7247, mapID = 2025 },
                { areaPoiID = 7301, mapID = 2025 },
                { areaPoiID = 7248, mapID = 2025 }
            }
        },
        challenge = {
            type = WPS.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2025,
            npcID = 192259,
            npcName = "Storm-Touched Bluefeather",
        },
        rewards = {
            [1] = {
                type = WPS.REWARD_TYPE.PET,
                creatureID = 192259,
                creatureName = "Storm-Touched Bluefeather",
                note = "Battle one and capture it during any storm event in Thaldraszus"
            },
        }
    },
}