local WPS = WorldPetScanner

WPS.AchievmentColor = "ffff00"
WPS.QuestColor = "ffff00"
WPS.RareColor = "0070FF"

-- cffffff00  yellow
WPS.links = {
    [37203] = "|cffffff00|Hquest:37203|h[Ashlei]|h|r",
    [37207] = "|cffffff00|Hquest:37207|h[Vesharr]|h|r",
    [37208] = "|cffffff00|Hquest:37208|h[Taralune]|h|r",
    [37206] = "|cffffff00|Hquest:37206|h[Tarr the Terrible]|h|r",
    [37205] = "|cffffff00|Hquest:37205|h[Gargra]|h|r",
    [37201] = "|cffffff00|Hquest:37201|h[Cymre Brightblade]|h|r",
    [63824] = "|cffffff00|Hquest:63824|h[Kyrian Assault]|h|r",
}

function WPS:BuildQuestLink(questID, name)
    return "|cffffff00|Hquest:".. questID .. "|h[" .. name .."]|h|r"
end

function WPS:BuildPetSpellLink(spellID, name)
    return "|cff67BCFF|Hspell:".. spellID .. "|h[" .. name .."]|h|r"
end

function WPS.GetSpellLink(spellID)
    return "|cff71d5ff|Hspell:2061:0|h[Flash Heal]|h|r"
end