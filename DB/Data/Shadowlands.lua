local WPS = WorldPetScanner

-- Shadowlands
local data = {
    name = "Shadowlands"
}
WPS.data[9] = data

-- Achievements
local trainer = {
    61883,
    61885,
    61886,
    61867,
    61868,
    61866,
    61787,
    61791,
    61784,
    61946,
    61948
}

data.achievements = {
    {
        name = "Family Exorcist",
        id = 14879,
        criteriaType = "ACHIEVEMENT",
        criteria = {
            {id = 14868, criteriaType = "QUESTS", criteria = trainer},
            {id = 14869, criteriaType = "QUESTS", criteria = trainer},
            {id = 14870, criteriaType = "QUESTS", criteria = trainer},
            {id = 14871, criteriaType = "QUESTS", criteria = trainer},
            {id = 14872, criteriaType = "QUESTS", criteria = trainer},
            {id = 14873, criteriaType = "QUESTS", criteria = trainer},
            {id = 14874, criteriaType = "QUESTS", criteria = trainer},
            {id = 14875, criteriaType = "QUESTS", criteria = trainer},
            {id = 14876, criteriaType = "QUESTS", criteria = trainer},
            {id = 14877, criteriaType = "QUESTS", criteria = trainer}
        }
    }
}

-- Pets
data.pets = {
    {name = "Dal", itemID = 183859, creatureID = 171136, quest = {{trackingID = 0, wqID = 60655}}},
    {name = "Carpal", itemID = 183114, creatureID = 173847, source = {type = "ITEM", itemID = 183111}},
    {name = "Primordial Bogling", itemID = 180588, creatureID = 171121, quest = {{trackingID = 0, wqID = 59808}}}
}