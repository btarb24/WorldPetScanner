local PETC = PetCollector
local EXPANSIONS = PETC.EXPANSIONS

EXPANSIONS.list = {
    [4] = {
        Name = "Cataclysm",
        Collapsed = false,
    },
    [5] = {
        Name = "Mists of Pandaria",
        Collapsed = false,
    },
    [6] = {
        Name = "Warlords of Draenor",
        Collapsed = false,
        CollapseInReportMode = true,
    },
    [7] = {
        Name = "Legion",
        Collapsed = false,
    },
    [8] = {
        Name = "Battle for Azeroth",
        Collapsed = false,
    },
    [9] = {
        Name = "Shadowlands",
        Collapsed = false,
    },
    [10] = {
        Name = "Dragonflight",
        Collapsed = false,
    },
    [11] = {
        Name = "The War Within",
        Collapsed = false,
    }
}

function EXPANSIONS:GetName(id)
    local exp = EXPANSIONS.list[id];
    if (exp) then
        return exp.Name
    else
        return "Unknown"
    end
end