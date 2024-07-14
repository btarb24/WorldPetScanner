local PETC = PetCollector
local PETS = PETC.PETS

PETC.TRIGGER_TYPE = {
    WORLD_QUEST = "worldQuest",
    DAILY_QUEST = "dailyQuest",
    AURA = "aura",
    ACHIEVEMENT = "achievement",
    AREA_POI = "areapoi",
    WORLD_QUEST_REWARD = "worldQuestReward",
    PERIODIC_ROTATION = 'periodicRotation',
}
PETC.QUEST_EVAL_TYPE = {
    FLAG = "flaggedCompletion",
    ISACTIVE = "isActive",
    BYMAP = "GetQuestsForPlayerBymapID",
}

PETC.TaskData = {
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.AURA,
            auraID = 335150,
            auraName = "Sign of the Destroyer",
            auraDescription = "Cataclysm Timewalking",
            isTimewalking = true,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.VENDOR,
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
            {
                pet = PETS.all[211]
            }
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37203,
            questName = "Ashlei",
            isTimewalking = true,
            questEvaluationType = PETC.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
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
            {
                itemID = PETC.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37207,
            questName = "Vesharr",
            isTimewalking = true,
            questEvaluationType = PETC.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
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
            {
                itemID = PETC.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37208,
            questName = "Taralune",
            isTimewalking = true,
            questEvaluationType = PETC.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
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
            {
                itemID = PETC.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37206,
            questName = "Tarr the Terrible",
            isTimewalking = true,
            questEvaluationType = PETC.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
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
            {
                itemID = PETC.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37205,
            questName = "Gargra",
            isTimewalking = true,
            questEvaluationType = PETC.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
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
            {
                itemID = PETC.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.DAILY_QUEST,
            questID = 37201,
            questName = "Cymre Brightblade",
            isTimewalking = true,
            questEvaluationType = PETC.QUEST_EVAL_TYPE.FLAG,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
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
            {
                itemID = PETC.PetCharm,
                quantity = 2,
                itemName = "Polished Pet Charm",
            }
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 63543,
            questName = "Necrolord Assault",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1543,
            questID = 63543,
            questName = "Necrolord Assault",
        },
        rewards = {
            {
                pet = PETS.all[3098]
            },
            {
                pet = PETS.all[3114]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 63824,
            questName = "Kyrian Assault",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1543,
            questID = 63824,
            questName = "Kyrian Assault",
        },
        rewards = {
            {
                pet = PETS.all[3101]
            },
            {
                pet = PETS.all[3103]
            },
            {
                pet = PETS.all[3010]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 63823,
            questName = "Night Fae Assault",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1543,
            questID = 63823,
            questName = "Night Fae Assault",
        },
        rewards = {
            {
                pet = PETS.all[3099]
            },
            {
                pet = PETS.all[3116]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44892,
            questName = "Snowfeather Swarm!",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 650,
            questID = 44892,
            questName = "Snowfeather Swarm!",
            checkForExistingTask = true,
            note = "Kill the Snowfeather Matriarch (48,10) and then click the Orphaned Snowfeather (32,28)"
        },
        rewards = {
            {
                pet = PETS.all[1974]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44893,
            questName = "Direbeak Swarm!",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 634,
            questID = 44893,
            questName = "Direbeak Swarm!",
            checkForExistingTask = true,
            note = "Kill the Direbeak Matriarch (78,76) and then click the Orphaned Direbeak (80,70)"
        },
        rewards = {
            {
                pet = PETS.all[1975]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44894,
            questName = "Bloodgazer Swarm!",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 630,
            questID = 44894,
            questName = "Bloodgazer Swarm!",
            checkForExistingTask = true,
            note = "Kill the Bloodgazer Matriarch (35,6) and then click the Bloodgazer Direbeak (35,8)"
        },
        rewards = {
            {
                pet = PETS.all[1977]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 44895,
            questName = "Sharptalon Swarm!",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 7,
            zoneID = 641,
            questID = 44895,
            questName = "Sharptalon Swarm!",
            checkForExistingTask = true,
            note = "Kill the Sharptalon Matriarch (48,10) and then click the Sharptalon Direbeak (47,10)"
        },
        rewards = {
            {
                pet = PETS.all[1976]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73146,
            questName = "Cutting Wind",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73146,
            questName = "Cutting Wind",
            checkForExistingTask = true,
        },
        rewards = {
            {
                pet = PETS.all[3446]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73147,
            questName = "Shifting Ground",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73147,
            questName = "Shifting Ground",
            checkForExistingTask = true,
        },
        rewards = {
            {
                pet = PETS.all[3447]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73148,
            questName = "Combustible Vegetation",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73148,
            questName = "Combustible Vegetation",
            checkForExistingTask = true,
        },
        rewards = {
            {
                pet = PETS.all[3448]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 73149,
            questName = "Flood Warning",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.BYMAP,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2151,
            questID = 73149,
            questName = "Flood Warning",
            checkForExistingTask = true,
        },
        rewards = {
            {
                pet = PETS.all[3449]
            },
        }
    },
    {
        -- this quest is only detectible if you're standing in the emerald dream
        --trigger = {
        --    type = PETC.TRIGGER_TYPE.WORLD_QUEST,
        --    questID = 78370,
        --    questName = "Claws for Concern",
        --    questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        --},
        trigger = {
            type = PETC.TRIGGER_TYPE.PERIODIC_ROTATION,
            startDayOfYear = 146,
            startYear = 2024,
            daysInCycle = 16,
            daysDuration = 3
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2200,
            questID = 78370,
            questName = "Claws for Concern",
            note = "Find all 18 birds for the Fiends in Feathers achievement. Best to do it in a raid so you can get them all in one event."
        },
        rewards = {
            {
                pet = PETS.all[4288]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.PERIODIC_ROTATION, --ZaralekCavern | Loamm
            startDayOfYear = 160,
            startYear = 2024,
            daysInCycle = 4,
            daysDuration = 3
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 10,
            zoneID = 2133,
            npcID = 203618,
            npcName = "Klakatak",
            note = "1. kill Klakatak for a 52% chance to drop [Clacking Claw]\n2. Use the Clacking Claw to gain a transformation buff for 10 minutes.\n3. Locate a Curious Top Hat critter and interact with it to gain the Lord Stantley pet.\n   -Some top hat locations: 39,64 | 44,78 | 52,67 | 62,70 | 63,56"
        },
        rewards = {
            {
                pet = PETS.all[3521]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.PERIODIC_ROTATION, --ZaralekCavern | Loamm
            startDayOfYear = 160,
            startYear = 2024,
            daysInCycle = 4,
            daysDuration = 3
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 10,
            zoneID = 2133,
            npcID = 203462,
            npcName = "Kob'rok",
        },
        rewards = {
            {
                pet = PETS.all[3546]
            },
            {
                pet = PETS.all[3545]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.PERIODIC_ROTATION, --ZaralekCavern | Loamm
            startDayOfYear = 160,
            startYear = 2024,
            daysInCycle = 4,
            daysDuration = 3
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 10,
            zoneID = 2133,
            npcID = 203593,
            npcName = "Underlight Queen",
            note = "Kill for a 5% drop chance of the Teardrop Moth pet"
        },
        rewards = {
            {
                pet = PETS.all[3551]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.PERIODIC_ROTATION, --ZaralekCavern | Glimmerogg
            startDayOfYear = 162,
            startYear = 2024,
            daysInCycle = 4,
            daysDuration = 3
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 10,
            zoneID = 2133,
            npcID = 203468,
            npcName = "Aquifon",
            note = "Kill for a 5% drop chance of the Aquapo pet"
        },
        rewards = {
            {
                pet = PETS.all[3548]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.PERIODIC_ROTATION, --ZaralekCavern | Glimmerogg
            startDayOfYear = 162,
            startYear = 2024,
            daysInCycle = 4,
            daysDuration = 3
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 10,
            zoneID = 2133,
            npcID = 203621,
            npcName = "Brullo the Strong",
            note = "Kill for a 3% drop chance of the Brul pet"
        },
        rewards = {
            {
                pet = PETS.all[3533]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.PERIODIC_ROTATION, --ZaralekCavern | Glimmerogg
            startDayOfYear = 162,
            startYear = 2024,
            daysInCycle = 4,
            daysDuration = 3
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 10,
            zoneID = 2133,
            npcID = 203625,
            npcName = "Karokta",
            note = "Kill for a 5% drop chance of the Ridged Shalewing pet"
        },
        rewards = {
            {
                pet = PETS.all[3541]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 65256,
            questName = "Cluck, Cluck, Boom",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1970,
            questID = 65256,
            questName = "Cluck, Cluck, Boom",
            note = "Complete the quest for a chance at receiving [Schematic: Violent Poultrid]."
        },
        rewards = {
            {
                pet = PETS.all[3225]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 65102,
            questName = "Fish Eyes",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1970,
            questID = 65102,
            questName = "Fish Eyes",
            note = "Complete the quest for a chance at receiving [Aurelid Lattice], which can be used to craft a few pets."
        },
        rewards = {
            {
                pet = PETS.all[3230]
            },
            {
                pet = PETS.all[3231]
            },
            {
                pet = PETS.all[3229]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 66070,
            questName = "Brightblade's Bones",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 10,
            zoneID = 2022,
            questID = 66070,
            questName = "Brightblade's Bones",
            note = "Bring an [Eroded Fossil] and [Petrified Dragon Egg] to Cymre Brightblade to receive the pet."
        },
        rewards = {
            {
                pet = PETS.all[3360]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 51212,
            questName = "Waycrest Manor: Witchy Kitchen",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 8,
            zoneID = 896,
            questID = 51212,
            questName = "Waycrest Manor: Witchy Kitchen",
            note = "Don't kill Roast Chef Rhondo or Sauciere Samuel. Keep them alive until a chicken\noffers you the quest [Cutting Edge Poultry Science]. Turn in at booty bay."
        },
        rewards = {
            {
                pet = PETS.all[2192]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 8,
            zoneID = 1527, --uldum
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            npcID = 162140,
            npcName = "Skikx'traz",
            note = "Kill for a 2% chance to drop [Black Chitinous Plate], which yields the pet.\n  Located at 23,62 during Assault: Aqir Unearthed\nBurning the wastelander corpses can speed up the spawn time"
        },
        rewards = {
           {
            pet = PETS.all[2848]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 8,
            zoneID = 1527, --uldum
            questID = 56308,
            questName = "Assault: Aqir Unearthed",
            npcID = 154604,
            npcName = "Lord Aj'qirai",
            note = "Kill for a 2% chance to drop [Stinky Sack], which yields the pet.\n  Located at 34,18 inside the Chamber of the Moon during Assault: Aqir Unearthed\nSpawn time reported as 1-2 hours"
        },
        rewards = {
            {
                pet = PETS.all[2847]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 57157,
            questName = "Assault: The Black Empire",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 8,
            zoneID = 1527, --uldum
            questID = 57157,
            questName = "Assault: The Black Empire",
            npcID = 157593,
            npcName = "Amalgamation of Flesh",
            note = "Kill for a 2% chance to drop [Wicked Lurker].\nTravel to 59.8, 72.4 and click on the Pyre.  The rare will spawn during the 5th wave\nThe pyre respawns 1 minute after the rare was last killed\nOnly lootable once per day"
        },
        rewards = {
            {
                pet = PETS.all[2851]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.ACHIEVEMENT,
            achievementID = 18384,
            achievementName = "Whelp, There It Is",
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.ACHIEVEMENT,
            expansionID = 10,
            zoneID = 2112,
            achievementID = 18384,
            achievementName = "Whelp, There It Is",
        },
        rewards = {
            {
                pet = PETS.all[3555]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 59808,
            questName = "Muck It Up",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 9,
            zoneID = 1525,
            questID = 59808,
            questName = "Muck It Up",
            npcID = 166292,
            npcName = "Bog Beast",
            note = "1. Collect [Primordial Muck] from mobs in the area of the Muck It Up world quest\n2. Join a raid group (otherwise you're limited to 4 spawn chances)\n\n3. Use the [Primordial Muck] for a chance to spawn the Bog Beast rare\n4. Leave the raid to collect more muck, repeat until the rare spawns\n  note: you can only loot him once per day and it has a 9% chance to drop the [Bucket of Primordial Sludge]"
        },
        rewards = {
            {
                pet = PETS.all[2896]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 60655,
            questName = "A Stolen Stone Fiend",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1525,
            questID = 60655,
            questName = "A Stolen Stone Fiend",
            note = "1. Use the quest's [Stone Fiend Tracker] to find/free him several times\n2. defeat Edgar the Collector\n3. Speak to Penkle behind the building to receive a [Cage Key]\n4. Use the key to unlock the nearby cage to receive the pet"
        },
        rewards = {
            {
                pet = PETS.all[2900]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST,
            questID = 60654,
            questName = "Swarming Souls",
            questEvaluationType = PETC.QUEST_EVAL_TYPE.ISACTIVE,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 9,
            zoneID = 1525,
            questID = 60654,
            questName = "Swarming Souls",
            npcID = 170048,
            npcName = "Manifestation of Wrath",
            note = "Option1: Deliver souls to the Avowed Ritualist for a chance to spawn the Manifestation of Wrath\n  for 9% loot drop of the [Bottled Up Rage]\nOption2: kill the Prideful Hulk rare at 68,82 for a 5% loot drop chance.\n  Kill Leeched Souls to spawn the rare."
        },
        rewards = {
            {
                pet = PETS.all[2897]
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = PETC.TRIGGER_TYPE.AREA_POI,
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
            type = PETC.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2022,
            npcID = 192029,
            npcName = "Storm-Touched Stomper",
        },
        rewards = {
            {
                pet = PETS.all[3385]
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = PETC.TRIGGER_TYPE.AREA_POI,
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
            type = PETC.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2023,
            npcID = 189660,
            npcName = "Storm-Touched Timbertooth",
        },
        rewards = {
            {
                pet = PETS.all[3329]
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = PETC.TRIGGER_TYPE.AREA_POI,
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
            type = PETC.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2024,
            npcID = 192256,
            npcName = "Storm-Touched Ottuk",
        },
        rewards = {
            {
                pet = PETS.all[3354]
            },
        }
    },
    {
        excludeFromReport = true,
        trigger = {
            type = PETC.TRIGGER_TYPE.AREA_POI,
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
            type = PETC.CHALLENGE_TYPE.PETBATTLE,
            expansionID = 10,
            zoneID = 2025,
            npcID = 192259,
            npcName = "Storm-Touched Bluefeather",
        },
        rewards = {
            {
                pet = PETS.all[3384]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.AURA,
            auraID = 335150,
            auraName = "Sign of the Destroyer",
            auraDescription = "Cataclysm Timewalking",
            isTimewalking = true,
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.RARE_KILL,
            expansionID = 4,
            zoneID = 198,
            npcID = 52530,
            npcName = "Alysrazor <Timewalking Firelands>",
            note = "1. Kill Alysrazor during a Firelands Timewalking raid (must be timewalking)\n2. Loot 20x[Inert Phoenix Ash] from fire elementals in Un'Goro Crater\n3. Find 10x [Sacred Phoenix Ash] in Spires of Arak\n4. Purchase [Phoneix Ash Talisman] from Zektar in Spires of Arak (52,50)\n5. Turn in the talisman to Tarjin the Blind in Waking Shores(16,63)"
        },
        rewards = {
            {
                pet = PETS.all[3292]
            },
        }
    },
    {
        trigger = {
            type = PETC.TRIGGER_TYPE.WORLD_QUEST_REWARD,
            itemID = 183111,
            itemName = "Animated Ulna",
            questNotCompleted = 62318
        },
        additionalCriteria = {
            questsCompleted = {
                [62318] = false --clicking the Skeletal Hand Fragments 
            }
        },
        challenge = {
            type = PETC.CHALLENGE_TYPE.QUEST,
            expansionID = 9,
            zoneID = 1536,
            note = "1. Complete the pet battle to receive [Animated Ulna]\n2. Purchase [Animated Radius] from Nalcorn Talsen (50,34) for 250 charms\n3. Travel to 47.39,62.11 and click the Skeletal Hand Fragments to receive [Flexing Phalanges]\n    -Once per character. Only available if you have both of the Animated items\n5. Combine the items to receive the [Carpal] pet"
        },
        rewards = {
            {
                pet = PETS.all[3025]
            },
        }
    },
}