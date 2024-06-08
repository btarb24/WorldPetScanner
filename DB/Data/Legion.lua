local WPS = WorldPetScanner

--	Legion
local data = {
    name = "Legion"
}
WPS.data[7] = data

-- Achievements
local trainer = {
    42159,
    40299,
    40277,
    42442,
    40298,
    40280,
    40282,
    41687,
    40278,
    41944,
    41895,
    40337,
    41990,
    40279,
    41860
}
local argusTrainer = {
    49041,
    49042,
    49043,
    49044,
    49045,
    49046,
    49047,
    49048,
    49049,
    49050,
    49051,
    49052,
    49053,
    49054,
    49055,
    49056,
    49057,
    49058
}

data.achievements = {
    {
        name = "Family Familiar",
        id = 9696,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 9686, criteriaType = "QUESTS", criteria = trainer},
            {id = 9687, criteriaType = "QUESTS", criteria = trainer},
            {id = 9688, criteriaType = "QUESTS", criteria = trainer},
            {id = 9689, criteriaType = "QUESTS", criteria = trainer},
            {id = 9690, criteriaType = "QUESTS", criteria = trainer},
            {id = 9691, criteriaType = "QUESTS", criteria = trainer},
            {id = 9692, criteriaType = "QUESTS", criteria = trainer},
            {id = 9693, criteriaType = "QUESTS", criteria = trainer},
            {id = 9694, criteriaType = "QUESTS", criteria = trainer},
            {id = 9695, criteriaType = "QUESTS", criteria = trainer}
        }
    },
    {
        name = "Family Fighter",
        id = 12100,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 12089, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12091, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12092, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12093, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12094, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12095, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12096, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12097, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12098, criteriaType = "QUESTS", criteria = argusTrainer},
            {id = 12099, criteriaType = "QUESTS", criteria = argusTrainer}
        }
    }
}

-- Pets
data.pets = {
    {
        name = "Grasping Manifestation",
        itemID = 153056,
        creatureID = 128159,
        quest = {{trackingID = 0, wqID = 48729}}
    },
    -- Egg
    {
        name = "Fel-Afflicted Skyfin",
        itemID = 153055,
        creatureID = 128158,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    },
    {
        name = "Docile Skyfin",
        itemID = 153054,
        creatureID = 128157,
        quest = {
            {trackingID = 48667, wqID = 48502},
            {trackingID = 48712, wqID = 48732},
            {trackingID = 48812, wqID = 48827}
        }
    },
    {
        name = "Snowfeather Hatchling",
        itemID = 0,
        creatureID = 115784,
        quest = {{trackingID = 0, wqID = 44892}}
    },
    -- Emissary
    {name = "Thistleleaf Adventurer", itemID = 130167, creatureID = 99389, questID = 42170, emissary = true},
    {name = "Wondrous Wisdomball", itemID = 141348, creatureID = 113827, questID = 43179, emissary = true},
    -- Treasure Master Iks'reeged
    {name = "Scraps", itemID = 146953, creatureID = 120397, questID = 45379}
}