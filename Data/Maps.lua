local PETC = PetCollector
local MAPS = PETC.MAPS

MAPS.continents = {
    [1]="Eastern Kingdoms",
    [2]="Kalimdor",
    [3]="Outland",
    [4]="Northrend",
    [5]="The Maelstrom",
    [6]="Pandaria",
    [7]="Draenor",
    [8]="Broken Isles",
    [9]="Argus",
    [10]="Kul Tiras",
    [11]="Zandalar",
    [12]="Shadowlands",
    [13]="Dragon Isles",
}

MAPS.maps = {
    [15]={1, "Badlands"},
    [18]={1, "Tirisfal Glades"},
    [25]={1, "Hillsbrad Foothills"},
    [26]={1, "The Hinterlands"},
    [27]={1, "Dun Morogh"},
    [36]={1, "Burning Steppes"},
    [37]={1, "Elwynn Forest"},
    [41]={4, "Dalaran"},
    [50]={1, "Northern Stranglethorn"},
    [52]={1, "Westfall"},
    [56]={1, "Wetlands"},
    [64]={2, "Thousand Needles"},
    [69]={2, "Feralas"},
    [70]={2, "Dustwallow Marsh"},
    [71]={2, "Tanaris"},
    [78]={2, "Un'Goro Crater"},
    [83]={2, "Winterspring"},
    [84]={1, "Stormwind City"},
    [85]={2, "Orgrimmar"},
    [87]={1, "Ironforge"},
    [88]={2, "Thunder Bluff"},
    [89]={2, "Darnassus"},
    [90]={1, "Undercity"},
    [109]={3, "Netherstorm"},
    [210]={1, "The Cape of Stranglethorn"},
    [219]={2, "Tanaris", "Zul'Farrak"},
    [227]={1, "Dun Morogh", "Gnomeregan", "The Dormitory"},
    [228]={1, "Dun Morogh", "Gnomeregan", "Launch Bay"},
    [229]={1, "Dun Morogh", "Gnomeregan", "Tinker's Court"},
    [292]={1, "Westfall", "The Deadmines", "Ironclad Cove"},
    [367]={1, "Mount Hyjal", "Firelands"},
    [407]={5, "Darkmoon Island"},
    [501]={8, "Dalaran (Broken Isles)"},
    [542]={7, "Spires of Arak"},
    [582]={7, "Lunarfall"},
    [590]={7, "Frostwall"},
    [630]={8, "Azsuna"},
    [634]={8, "Stormheim"},
    [641]={8, "Val'sharah"},
    [650]={8, "Highmountain"},
    [862]={11, "Zuldazar"},
    [1015]={10, "Drustvar", "Waycrest Manor", "1st floor"},
    [1161]={10, "Boralus"},
    [1525]={12, "Revendreth"},
    [1527]={2, "Uldum (BFA)"},
    [1536]={12, "Maldraxxus"},
    [1543]={12, "The Maw"},
    [1970]={12, "Zereth Mortis"},
    [2070]={1, "Tirisfal Glades"},
    [2022]={13, "The Waking Shores"},
    [2023]={13, "Ohn'ahran Plains"},
    [2024]={13, "The Azure Span"},
    [2025]={13, "Thaldraszus"},
    [2112]={13, "Valdrakken"},
    [2151]={13, "The Forbidden Reach"},
    [2133]={13, "Zaralek Cavern"},
    [2200]={13, "Emerald Dream"}
}

function MAPS.GetContinent(mapID)
    local mapData = MAPS.maps[mapID]
    local continentID = mapData[1]
    return PETC.continents[continentID]
end

function MAPS.GetZone(mapID)
    local mapData = MAPS.maps[mapID]
    local zone = mapData[2]
    return zone
end

function MAPS.GetMapInfo(mapID)
    local mapData = MAPS.maps[mapID]
    local continentID = mapData[1]
    local zone = mapData[2]
    local area = mapData[3]
    local floor = mapData[4]
    return MAPS.continents[continentID], zone, area, floor
end