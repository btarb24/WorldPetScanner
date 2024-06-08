local WPS = WorldPetScanner

-- Dragonflight
local data = {
    name = "Dragonflight"
}
WPS.data[10] = data

-- Achievements
data.achievements = {
    {
        name = "Battle in Zaralek Cavern",
        id = 17880,
        criteriaType = "QUESTS",
        criteria = {
            75680,
            75750,
            75834,
            75835
        }
    }
}

-- Pets
data.pets = {
    {
        name = "Wildfire",
        itemID = 202412,
        creatureID = 200771,
        quest = { { trackingID = 0, wqID = 73148 } }
    },
    {
        name = "Vortex",
        itemID = 202413,
        creatureID = 200769,
        quest = { { trackingID = 0, wqID = 73146 } }
    },
    {
        name = "Tremblor",
        itemID = 202411,
        creatureID = 200770,
        quest = { { trackingID = 0, wqID = 73147 } }
    },
    {
        name = "Flow",
        itemID = 202407,
        creatureID = 200772,
        quest = { { trackingID = 0, wqID = 73149 } }
    },
    {
        name = "Time-Lost Vorquin Foal",
        itemID = 193855,
        creatureID = 191298,
        quest = { { trackingID = 0, wqID = 74378 } }
    }
}