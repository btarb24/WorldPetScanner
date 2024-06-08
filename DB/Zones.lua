local WPS = WorldPetScanner

WPS.ZoneIDList = {
    [4] = {
        [407] = {scanWorldQuests = false, Name = "Darkmoon Faire"},
    },
    [5] = {
        [422] = {scanWorldQuests = false, Name = "Dread Wastes"},
        [418] = {scanWorldQuests = false, Name = "Karasarang Wilds"},
        [379] = {scanWorldQuests = false, Name = "Kun-Lai Summit"},
        [390] = {scanWorldQuests = false, Name = "Vale of Eternal Blossoms"},
        [392] = {scanWorldQuests = false, Name = "Shrine of the Two Moons"},
        [371] = {scanWorldQuests = false, Name = "The Jade Forest"},
        [433] = {scanWorldQuests = false, Name = "The Veiled Stair"},
        [554] = {scanWorldQuests = false, Name = "Timeless Isle"},
        [388] = {scanWorldQuests = false, Name = "Townlong Steppes"},
        [376] = {scanWorldQuests = false, Name = "Valley of the Four Winds"},
    },
    [6] = {
        [539] = {scanWorldQuests = false, Name = "Shadowmoon Valley"},
        [542] = {scanWorldQuests = false, Name = "Spires of Arak"},
        [525] = {scanWorldQuests = false, Name = "Frostfire Ridge"},
        [534] = {scanWorldQuests = false, Name = "Tanaan Jungle"},
        [590] = {scanWorldQuests = false, Name = "Garrison"},
        [543] = {scanWorldQuests = false, Name = "Gorgrond"},
        [588] = {scanWorldQuests = false, Name = "Ashran"},
        [550] = {scanWorldQuests = false, Name = "Nagrand"},
        [624] = {scanWorldQuests = false, Name = "Warspear"},
        [535] = {scanWorldQuests = false, Name = "Talador"},
    },
    [7] = {
        [619] = {scanWorldQuests = true, Name = "Broken Isles"}, --covers the main legion zones
        [627] = {scanWorldQuests = true, Name = "Dalaran"},
        [630] = {scanWorldQuests = false, Name = "Azsuna"},
        [641] = {scanWorldQuests = false, Name = "Val'sharah"},
        [747] = {scanWorldQuests = false, Name = "Val'sharah Dreamgrove"},
        [715] = {scanWorldQuests = false, Name = "Val'sharah Emerald Dreamway"},
        [650] = {scanWorldQuests = false, Name = "Highmountain"},
        [628] = {scanWorldQuests = false, Name = "Dalaran Underbelly"},
        [680] = {scanWorldQuests = false, Name = "Suramar"},
        [634] = {scanWorldQuests = false, Name = "Stormheim"},
        [649] = {scanWorldQuests = false, Name = "Helheim"},
        [646] = {scanWorldQuests = false, Name = "Broken Shore"},
        [790] = {scanWorldQuests = false, Name = "Eye of Azshara"},
        [750] = {scanWorldQuests = false, Name = "Thundertotem"},
        [885] = {scanWorldQuests = true, Name = "Antoran Wastes"}, --argus
        [830] = {scanWorldQuests = true, Name = "Krokuun"}, -- argus
        [882] = {scanWorldQuests = true, Name = "Eredath"},  -- argus
        [831] = {scanWorldQuests = false, Name = "The Vindicaar"},  -- argus
    },
    [8] = {
      --  14, -- Arathi Highlands
      --  62, -- Darkshore
        [875] = {scanWorldQuests = false, Name = "Zandalar"},  -- or maybe Gate of the Setting Sun
        [876] = {scanWorldQuests = false, Name = "Stormstout Brewery"},
        [862] = {scanWorldQuests = true, Name = "Zuldazar"},
        [863] = {scanWorldQuests = true, Name = "Nazmir"},
        [864] = {scanWorldQuests = true, Name = "Vol'dun"},
        [895] = {scanWorldQuests = true, Name = "Tiragarde Sound"},
        [942] = {scanWorldQuests = true, Name = "Stormsong Valley"},
        [896] = {scanWorldQuests = true, Name = "Drustvar"},
        [1161] = {scanWorldQuests = false, Name = "Boralus"},
        [1165] = {scanWorldQuests = false, Name = "Dazar'alor"},
        [1163] = {scanWorldQuests = false, Name = "Dazar'alor The Great Seal"},
        [1355] = {scanWorldQuests = true, Name = "Nazjatar"},
        [1462] = {scanWorldQuests = true, Name = "Mechagon"},
        [1527] = {scanWorldQuests = true, Name = "Uldum"},
        [1530] = {scanWorldQuests = true, Name = "Vale of Eternal Blossoms"},
        [2070] = {scanWorldQuests = false, Name = "Tirisfal Glades"},
    },
    [9] = {
        [1550] = {scanWorldQuests = true, Name = "Shadowlands"}, --covers all the main SL zones
        [1525] = {scanWorldQuests = false, Name = "Revendreth"},
        [1533] = {scanWorldQuests = false, Name = "Bastion"},
        [1536] = {scanWorldQuests = false, Name = "Maldraxxus"},
        [1565] = {scanWorldQuests = false, Name = "Ardenweald"},
        [1670] = {scanWorldQuests = false, Name = "Oribos 1st floor"},
        [1671] = {scanWorldQuests = false, Name = "Oribos 2nd floor"},
        [1543] = {scanWorldQuests = true, Name = "The Maw"},
        [1961] = {scanWorldQuests = false, Name = "Korthia"},
        [1970] = {scanWorldQuests = true, Name = "Zereth Mortis"},
    },
    [10] = {
        [1978] = {scanWorldQuests = true, Name = "Dragon Isles"},  -- covers all main DI zones
        [2022] = {scanWorldQuests = false, Name = "The Waking Shores"}, --2127(2057)
        [2023] = {scanWorldQuests = false, Name = "Ohn'ahran Plains"}, --2129(2057)
        [2024] = {scanWorldQuests = false, Name = "The Azure Span"}, --2128(2057), 2132(2024)
        [2025] = {scanWorldQuests = false, Name = "Thaldraszus"}, --2130(2057)
        [2112] = {scanWorldQuests = true, Name = "Valdrakken"}, --2134(2130), 2135(1978)
        [2151] = {scanWorldQuests = false, Name = "The Forbidden Reach"}, -- 2118, 2131(0)
        [2133] = {scanWorldQuests = true, Name = "Zaralek Cavern"},
        [2200] = {scanWorldQuests = false, Name = "Emerald Dream"},
        [2085] = {scanWorldQuests = false, Name = "Primalist Tomorrow"},
        [2239] = {scanWorldQuests = false, Name = "Belameth"},
    }
}

function WPS:GetZoneName(expansionID, zoneID)
    local expansionZoneList = WPS.ZoneIDList[expansionID]
    if expansionZoneList then
        local zoneMatch = expansionZoneList[zoneID]
        if zoneMatch then
            return zoneMatch.Name
        end
    end

    return "Unknown(".. expansionID .. "_" .. zoneID .. ")"
end