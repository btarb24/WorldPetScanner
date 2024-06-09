local WPS = WorldPetScanner

WPS.Expansions = {
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
    }
}

function WPS:GetExpansionName(id)
    local exp = WPS.Expansions[id];
    if (exp) then
        return exp.Name
    else
        return "Unknown"
    end
end