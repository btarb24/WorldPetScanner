local WPS = WorldPetScanner

-- Battle for Azeroth
local data = {
    name = "Battle for Azeroth"
}
WPS.data[8] = data

-- Achievements
local trainer = {
    52009,
    52165,
    52218,
    52278,
    52297,
    52316,
    52325,
    52430,
    52471,
    52751,
    52754,
    52799,
    52803,
    52850,
    52856,
    52878,
    52892,
    52923,
    52938
}

data.achievements = {
    {
        name = "Family Battler",
        id = 13279,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 13280, criteriaType = "QUESTS", criteria = trainer},
            {id = 13270, criteriaType = "QUESTS", criteria = trainer},
            {id = 13271, criteriaType = "QUESTS", criteria = trainer},
            {id = 13272, criteriaType = "QUESTS", criteria = trainer},
            {id = 13273, criteriaType = "QUESTS", criteria = trainer},
            {id = 13274, criteriaType = "QUESTS", criteria = trainer},
            {id = 13281, criteriaType = "QUESTS", criteria = trainer},
            {id = 13275, criteriaType = "QUESTS", criteria = trainer},
            {id = 13277, criteriaType = "QUESTS", criteria = trainer},
            {id = 13278, criteriaType = "QUESTS", criteria = trainer}
        }
    }
}

-- Pets
data.pets = {
    {name = "Vengeful Chicken", itemID = 160940, creatureID = 139372, quest = {{trackingID = 0, wqID = 51212}}},
    {
        name = "Rebuilt Gorilla Bot",
        itemID = 166715,
        creatureID = 149348,
        quest = {{trackingID = 0, wqID = 54272}},
        faction = "Alliance"
    },
    {
        name = "Rebuilt Mechanical Spider",
        itemID = 166723,
        creatureID = 149361,
        quest = {{trackingID = 0, wqID = 54273}},
        faction = "Horde"
    }
}