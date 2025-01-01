local PETC = PetCollector
local CONTINENTS = PETC.CONTINENTS

CONTINENTS.list = {
    ["Eastern Kingdoms"] = 1,
    ["Kalimdor"] = 2,
    ["Outland"] = 3,
    ["Northrend"] = 4,
    ["The Maelstrom"] = 5,
    ["Pandaria"] = 6,
    ["Draenor"] = 7,
    ["Broken Isles"] = 8,
    ["Argus"] = 9,
    ["Kul Tiras"] = 10,
    ["Zandalar"] = 11,
    ["Shadowlands"] = 12,
    ["Dragon Isles"] = 13,
    ["Khaz Algar"] = 14,
}

function CONTINENTS:GetSortOrder(continent)
    return CONTINENTS.list[continent]
end