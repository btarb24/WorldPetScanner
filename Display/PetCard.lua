local file="PetCard"

local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local DISPLAY_UTIL = DISPLAY.Util
local UTILITIES = PETC.UTILITIES
local PETS = PETC.PETS
local MAPS = PETC.MAPS

local function getFamilyDetails(family)
    if family == 1 then 
        return "Humanoid", "humanoid", 8/256, 138/256, 222/256
    elseif family == 2 then 
        return "Dragonkin", "dragon", 34/256, 165/256, 24/256
    elseif family == 3 then 
        return "Flying", "flying", 214/256, 199/256, 74/256
    elseif family == 4 then 
        return "Undead", "undead", 164/256, 109/256, 115/256
    elseif family == 5 then 
        return "Critter", "critter", 140/256, 101/256, 74/256
    elseif family == 6 then 
        return "Magical", "magical", 156/256, 105/256, 255/256
    elseif family == 7 then 
        return "Elemental", "elemental", 247/256, 105/256, 0/256
    elseif family == 8 then 
        return "Beast", "beast", 193/256, 36/256, 33/256
    elseif family == 9 then 
        return "Aquatic", "water", 8/256, 170/256, 181/256
    elseif family == 10 then 
        return "Mechanical", "mechanical", 132/256, 125/256, 115/256
    end
end

local function getCreatureSoundDetails(creatureSound)
    local nameId, soundId = strsplit("_", creatureSound)
    nameId = tonumber(nameId)

    if (nameId == 1) then
        return "Exertion", soundId
    elseif (nameId == 2) then
        return "Exterion critical", soundId
    elseif (nameId == 3) then
        return "Injury", soundId
    elseif (nameId == 4) then
        return "Injury critical", soundId
    elseif (nameId == 5) then
        return "Injury crushing blow", soundId
    elseif (nameId == 6) then
        return "Death", soundId
    elseif (nameId == 7) then
        return "Stun", soundId
    elseif (nameId == 8) then
        return "Stand", soundId
    elseif (nameId == 9) then
        return "Footstep", soundId
    elseif (nameId == 10) then
        return "Aggro", soundId
    elseif (nameId == 11) then
        return "Wing flap", soundId
    elseif (nameId == 12) then
        return "Wing glide", soundId
    elseif (nameId == 13) then
        return "Alert", soundId
    elseif (nameId == 14) then
        return "Jump (start)", soundId
    elseif (nameId == 15) then
        return "Jump (end)", soundId
    elseif (nameId == 16) then
        return "Attack", soundId
    elseif (nameId == 17) then
        return "Order", soundId
    elseif (nameId == 18) then
        return "Dismiss", soundId
    elseif (nameId == 19) then
        return "Loop", soundId
    elseif (nameId == 20) then
        return "Birth", soundId
    elseif (nameId == 21) then
        return "Spell cast directed", soundId
    elseif (nameId == 22) then
        return "Submerge", soundId
    elseif (nameId == 23) then
        return "Submerged", soundId
    elseif (nameId == 24) then
        return "Windup", soundId
    elseif (nameId == 25) then
        return "Windup critical", soundId
    elseif (nameId == 26) then
        return "Charge", soundId
    elseif (nameId == 27) then
        return "Charge critical", soundId
    elseif (nameId == 28) then
        return "Battle shout", soundId
    elseif (nameId == 29) then
        return "Taunt", soundId
    elseif (nameId == 30) then
        return "Fidget", soundId
    elseif (nameId == 31) then
        return "Fidget 2", soundId
    elseif (nameId == 32) then
        return "Fidget 3", soundId
    elseif (nameId == 33) then
        return "Fidget 4", soundId
    elseif (nameId == 34) then
        return "Fidget 5", soundId
    elseif (nameId == 35) then
        return "Custom attack", soundId
    elseif (nameId == 36) then
        return "Custom attack 2", soundId
    elseif (nameId == 37) then
        return "Custom attack 3", soundId
    elseif (nameId == 38) then
        return "Custom attack 4", soundId
    end
end

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())
    if (self:GetParent().content) then
        self:GetParent().content:Hide()
    end

    self:GetParent().content = self.content
    self.content:Show()

    if (PAPetCard.SelectedTab) then
        PAPetCard.SelectedTab.Text:SetPoint("LEFT", PAPetCard.SelectedTab, "LEFT", -32, 3)
    end
    PAPetCard.SelectedTab = self    
    self.Text:SetPoint("LEFT", self, "LEFT", -38, 3)
end

local function ParseLocation(location, pet)
    local type = "location"
    local depth1 = 1
    local depth2 = 1
    local depth3 = 1

    if (location == nil) then
        if (pet.locations) then
            type = "location"
        elseif (pet.pois) then
            type = "poi"
        else
            type = "unknown"
        end
    else
        local firstChar = tostring(location):sub(1, 1)
        if (firstChar == "p") then
            type = "poi"
            location = location:sub(2)
            
            local depth1Str, depth2Str, depth3Str  = strsplit(":", location)
            depth1 = tonumber(depth1Str)
            if (depth2Str) then
                depth2 = tonumber(depth2Str)
            end
            if (depth3Str) then
                depth3 = tonumber(depth3Str)
            end
        else
            depth1 = location
        end
    end

    return type, depth1, depth2, depth3
end

local function SetPetColor(fontString, rarity)
    if rarity == 0 then
        fontString:SetTextColor(.5, .1, .57) -- poor
    elseif rarity == 1 then
        fontString:SetTextColor(1, 1, 1) -- common
    elseif rarity == 2 then
        fontString:SetTextColor(.32, 1, .52) -- uncommon
    elseif rarity == 3 then
        fontString:SetTextColor(.59, 1, .5) -- rare
    end
end

local function GetCurrency(currencyIdStr, fontHeight)
    local stripCNotation =  strsub(currencyIdStr, 2)
    local currencyID, qty, itemID = strsplit(":", stripCNotation)

    if currencyID == "gold" then
        return C_CurrencyInfo.GetCoinTextureString(qty * 10000, fontHeight)
    elseif currencyID == "i" then
        local textureID = select(10, GetItemInfo(itemID))
        return string.format("|Hitem:%d|h%dx|T%s:%d|t|h", itemID, qty, textureID, fontHeight)
    else
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        local icon = currencyInfo.iconFileID
        return string.format("|Hcurrency:%d|h%dx|T%s:%d|t|h", currencyID, qty, icon, fontHeight)
    end
end

local function GetLink(idStr, color)
    if idStr == nil then --hack
        return nil
    end

    local type = strsub(idStr, 1, 1)
    local link
    local id
    local name
    if (type == "i") then
        id = tonumber(strsub(idStr, 2))
        name, link = GetItemInfo(id)
    elseif (type == "s") then
        id = tonumber(strsub(idStr, 2))
        link = C_Spell.GetSpellLink(id)
    elseif (type == "a") then
        local detail = strsub(idStr, 2)
        id, name = strsplit(":", detail)
        link = GetAchievementLink(id)
    elseif(type == "n") then
        local detail = strsub(idStr, 2)
        id, name = strsplit(":", detail)
        if not color then
            color = "b3b3b3"
        end
        link = string.format("|Hnpc:%s|h|cFF%s%s|r|h", id, color, name)
    elseif(type == "q") then
        local detail = strsub(idStr, 2)
        id, name = strsplit(":", detail)
        name = name and name or C_QuestLog.GetTitleForQuestID(id)
        if not name then print("missing quest name for " .. tostring(id)) end
        if not color then
            color = "ffff00"
        end
        link = string.format("|cFF%s|Hquest:%d:-1:-1:-1:-1|h[%s]|h|r", color, id, name)
    elseif(type == "o") then
        local detail = strsub(idStr, 2)
        id, name = strsplit(":", detail)
        if not color then
            color = "b3b3b3"
        end
        link = string.format("|cFF%s|Hobject:%d|h%s|h|r", color, id, name)
    elseif(type == "c") then
        link = GetCurrency(idStr)
    elseif(type == "e") then
        local detail = strsub(idStr, 2)
        id, name = strsplit(":", detail)
        if not color then
            color = "b3b3b3"
        end
        link = string.format("|cFF%s|Hevent:%d|h%s|h|r", color, id, name)
    elseif(type == "z") then
        link = strsub(idStr, 2)
        name = link
    end
    return link, id, name, type
end

local function GetCurrencyText(currencies, fontHeight)
    if not fontHeight then fontHeight = 20 end
    local result = {}
    for _, currency in ipairs(currencies) do
        local currencyVal = GetCurrency(currency, fontHeight)
        table.insert(result, currencyVal)
    end
    return result;
end

local function GetLineText(lineContent)
    if (#lineContent == 1) then
        return lineContent[1]
    end
    
    local links = {}
    for idx, entry in ipairs(lineContent) do
        if (idx > 1) then
            local link = GetLink(entry)
            table.insert(links, link)
        end
    end

    return lineContent[1], links
end

local function GetPoiIconAtlas(mapType)
    if (mapType =="start") then 
        return "Islands-QuestBang"
    elseif (mapType == "end") then
        return "Islands-QuestTurnin"
    end
    return nil
end

local function GetPois(topDock, pet, selectedIdx)
    local locationType, selectedDepth1, selectedDepth2, selectedDepth3 = ParseLocation(selectedIdx, pet)
    
    for poiTypeIdx, poiRoot in ipairs(pet.pois) do
        local mainPoiLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        mainPoiLbl:SetText(poiRoot.name)
        if (poiTypeIdx == 1) then
            if (topDock) then
                mainPoiLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT")
                mainPoiLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -10)
            else
                mainPoiLbl:SetPoint("TOPLEFT", PAPetCardTab2.content.scrollFrame.child, "TOPLEFT")
            end
        else
            mainPoiLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT")
            mainPoiLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -10)
        end
        
        topDock = mainPoiLbl
        local t3Indent = 15
        local leftDock = mainPoiLbl
        for entryIdx, entry in ipairs(poiRoot.entries) do
            local poiLbl = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
            local poiLink, poiID, _, poiType
            if (entry.id and entry.id ~= "") then
                poiLink, poiID, _, poiType = GetLink(entry.id);
                if (entry.subDisplay) then
                    poiLink = string.format("%s |cFFb3b3b3(%s)|r", poiLink, entry.subDisplay)
                end
                poiLbl:SetText(poiLink)
                poiLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -5)
 
                if (poiType == "q" or poiType == "a") then                
                    local completed
                    if (poiType == "q") then
                        completed = C_QuestLog.IsQuestFlaggedCompleted(poiID)
                    else --a
                        completed = select(4, GetAchievementInfo(poiID))
                    end 

                    local questState = DISPLAY_UTIL:AcquireTexture(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                    if completed then
                        questState:SetAtlas("auctionhouse-icon-checkmark")
                        questState:SetSize(12,12)
                        questState:SetPoint("TOP", poiLbl, "TOP", 0, -1)
                        questState:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT", 14, 0)
                    else
                        questState:SetAtlas("jailerstower-wayfinder-rewardcircle")
                        questState:SetSize(13,13)
                        questState:SetPoint("TOP", poiLbl, "TOP", 0, 0)
                        questState:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT", 13, 0)
                    end
                    poiLbl:SetPoint("LEFT", mainPoiLbl, "LEFT", 27, 0)
                    leftDock = questState
                else
                    leftDock = poiLbl
                    poiLbl:SetPoint("LEFT", mainPoiLbl, "LEFT", 15, 0)
                end
                t3Indent = 30
                topDock = poiLbl
            else
                leftDock = mainPoiLbl
            end

            if (entry.maps) then
                for mapIdx, map in ipairs(entry.maps) do
                    local mapDescLbl
                    local mapVal = map.display
                    if map.coords then
                        local isSelected = locationType == "poi" and poiTypeIdx == selectedDepth1 and entryIdx == selectedDepth2 and mapIdx == selectedDepth3
                        if isSelected then
                            mapDescLbl = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                            if (not mapVal) then
                                mapVal = GetLink(map.id, "ffffff")
                            end
                        else
                            mapDescLbl = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                            if (not mapVal) then
                                mapVal = select(3, GetLink(map.id, "ffffff"))
                            end
                            mapDescLbl.locationIndex = string.format("p%d:%d:%d", poiTypeIdx, entryIdx, mapIdx)
                            mapDescLbl:SetScript("OnMouseDown",
                                function(self)
                                    DISPLAY.PetCard:Show(PAPetCard.pet, self.locationIndex)
                                end
                            )
                        end
                    else
                        mapDescLbl = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                        if (not mapVal) then
                            mapVal = GetLink(map.id)
                        end
                    end
                    if (map.subDisplay) then
                        mapVal = string.format("%s |cFFb3b3b3(%s)|r", mapVal, map.subDisplay)
                    end
                    mapDescLbl:SetText(mapVal)
                    mapDescLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -2)
                    -- mapDescLbl:SetPoint("LEFT", leftDock, "LEFT", 15, 0)
                    mapDescLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT", t3Indent, 0)

                    local factionIcon
                    if (map.faction) then
                        factionIcon = DISPLAY_UTIL:AcquireTexture(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                        if (map.faction == "h") then
                            factionIcon:SetAtlas("questlog-questtypeicon-horde")
                        else
                            factionIcon:SetAtlas("questlog-questtypeicon-alliance")
                        end
                        factionIcon:SetSize(12,12)
                        factionIcon:SetPoint("TOPLEFT", mapDescLbl, "TOPRIGHT")
                    end

                    local details = ""
                    if (map.chance) then
                        details = string.format(" %s%%", map.chance)
                    end
                    if (map.currencies) then
                        local currencies = GetCurrencyText(map.currencies, 14)
                        local currencyStr = table.concat(currencies, ", ")
                        details = string.format("%s (%s)", details, currencyStr)
                    end
                    if (map.mapID) then
                        local zone = MAPS.GetZone(map.mapID)
                        details = string.format("%s %s", details, zone)
                    end
                    local mapDetails = DISPLAY_UTIL:AcquireSmallerSubduedFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                    mapDetails:SetText(details)
                    if (factionIcon) then
                        mapDetails:SetPoint("TOPLEFT", mapDescLbl, "TOPRIGHT", factionIcon:GetWidth(), -1)
                    else
                        mapDetails:SetPoint("TOPLEFT", mapDescLbl, "TOPRIGHT", 3, -1)
                    end
                    
                    local poiIconAtlas = GetPoiIconAtlas(map.type)
                    if (poiIconAtlas) then
                        local mapTipIcon = DISPLAY_UTIL:AcquireTexture(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                        mapTipIcon:SetAtlas(poiIconAtlas)
                        mapTipIcon:SetSize(16,16)
                        mapTipIcon:SetPoint("TOP", topDock, "BOTTOM")
                        mapTipIcon:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT", t3Indent-6, 0)
                        mapDescLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT", t3Indent+10, 0)
                    end

                    topDock = mapDescLbl
                end
            end
        end
    end
    
    return topDock
end

local function GetProfessionText(topDock, professionDetail)    
    local professionLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
    if (topDock) then
        professionLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT")
        professionLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -10)
    else
        professionLbl:SetPoint("TOPLEFT", PAPetCardTab2.content.scrollFrame.child, "TOPLEFT")        
    end
    professionLbl:SetText("Profession: ")
    
    if professionDetail == nil then --hack
        return professionLbl
    end
    local professionVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
    local professionText
    if professionDetail.desc then
        professionText = string.format("%s |cFFb3b3b3(%s)|r", professionDetail.profession, professionDetail.desc) 
    else
        professionText = string.format("%s |cFFb3b3b3|r", professionDetail.profession)
    end
    professionVal:SetText(professionText)
    professionVal:SetPoint("TOPLEFT", professionLbl, "TOPRIGHT")
    topDock = professionLbl

    if (professionDetail.recipe) then
        local recipeLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        recipeLbl:SetText("Recipe: ")
        recipeLbl:SetPoint("TOPLEFT", professionLbl, "BOTTOMLEFT", 0, -10)
        local recipeVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        recipeVal:SetText(C_Spell.GetSpellLink(professionDetail.recipe))
        recipeVal:SetPoint("TOPLEFT", recipeLbl, "TOPRIGHT")
        topDock = recipeLbl
    end
    
    if (professionDetail.materials) then
        local materialsLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        materialsLbl:SetText("Materials: ")
        materialsLbl:SetPoint("TOPLEFT", topDock, "BOTTOMLEFT", 0, -10)
        topDock = materialsLbl
        for _, mat in pairs(professionDetail.materials) do
            local materialVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
            local itemLink = select(2, GetItemInfo(mat.id))
            
            local matStr = string.format("%dx%s", mat.qty, itemLink)
            materialVal:SetText(matStr)
            materialVal:SetPoint("LEFT", materialsLbl, "LEFT", 10, 0)
            materialVal:SetPoint("TOP", topDock, "BOTTOM", 0, -3)
            topDock = materialVal
        end
    end

    return topDock
end

local function AddLabelAndVal(topDock, header, val, subval)
    local sourceLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
    sourceLbl:SetText(header)
    
    if (topDock) then
        sourceLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -10)
    else
        sourceLbl:SetPoint("TOP", PAPetCardTab2.content.scrollFrame.child, "TOP")
    end

    sourceLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT")
    local sourceVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
    sourceVal:SetPoint("TOPLEFT", sourceLbl, "TOPRIGHT", 5, 0)
    sourceVal:SetPoint("RIGHT", PAPetCardTab2.content.scrollFrame.child, "RIGHT", -5, 0)
    sourceVal:SetJustifyH("LEFT")
    sourceVal:SetWordWrap(true)
    if (subval) then
        val = string.format("%s |cFFb3b3b3(%s)|r", val, subval)
    end
    sourceVal:SetText(val)

    return sourceVal
end

local function BuildMapTitle(location)
    local continent, zone, area, floor = MAPS.GetMapInfo(location.mapID)

    local mapName = string.format("%s > %s", continent, zone)
    if (area) then
        mapName = string.format("%s > %s", mapName, area)
    end
    if (floor) then
        mapName = string.format("%s > %s", mapName, floor)
    end

    return mapName
end

local function GetLocation(pet, location) --location, showLocList
    local locationType, depth1, depth2, depth3 = ParseLocation(location, pet)
    if (locationType == "poi" and pet.pois) then
        local poi = pet.pois[depth1]
        if not poi.entries then
            return nil
        end

        local entry = poi.entries[depth2]
        if (not entry or not entry.maps) then
            return nil
        end
        local map = entry.maps[depth3]
        if map.mapID then
            return map
        else
            return nil
        end
    end

    --no location map
    if (not pet.locations) then
        return nil
    end

    --standard map locations    
    for _, loc in ipairs(pet.locations) do
        if loc.mapID == location then
            return loc
        end
    end

    return pet.locations[1]
end

local function UpdateAbility(texture, abilityID, petType)
    local _, icon = C_PetJournal.GetPetAbilityInfo(abilityID)
    texture:SetTexture(icon)
    texture:SetScript("OnEnter",
        function(self)
            local stats = PAPetCardTab1.content.SelectedBreedFrame.stats
            local abilityInfo = {}
            abilityInfo.petOwner = Enum.BattlePetOwner.Ally;
            abilityInfo.petIndex = nil;
            abilityInfo.GetAbilityID = function() return abilityID end
            abilityInfo.abilityIndex = nil;
            abilityInfo.GetMaxHealth = function()return stats[1] end
            abilityInfo.GetHealth = function()return stats[1] end
            abilityInfo.GetAttackStat = function()return stats[2] end
            abilityInfo.GetSpeedStat = function()return stats[3] end
            abilityInfo.GetCooldown = function() return 0 end
            abilityInfo.IsInBattle = function() return false end
            abilityInfo.HasAura = function() return false end
            abilityInfo.GetPadState = function() return 0 end
            abilityInfo.GetState = function() return 0 end
            abilityInfo.GetPetType = function() return petType end
            abilityInfo.GetWeatherState = function() return 0 end
            SharedPetBattleAbilityTooltip_SetAbility(PetBattlePrimaryAbilityTooltip, abilityInfo);
            PetBattlePrimaryAbilityTooltip:ClearAllPoints()
            PetBattlePrimaryAbilityTooltip:SetPoint("BOTTOM",self,"TOP",0,6)
            PetBattlePrimaryAbilityTooltip:Show()
        end
    )
    texture:SetScript("OnLeave",
        function()
            PetBattlePrimaryAbilityTooltip:Hide()
        end
    )
end

local function CreateTab(idNum, name, tabButtonWidth)
    tabButtonWidth = 96

    local tab = CreateFrame("Button", "PAPetCardTab"..idNum, PAPetCard, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab:SetFrameStrata("HIGH")
    tab:SetFrameLevel(1000)
    tab:SetID(idNum)
    tab:SetText(name)
    tab:SetWidth(32)
    tab:SetHeight(tabButtonWidth)
    tab.Text:SetWidth(tabButtonWidth)
    tab:ClearAllPoints()
    tab:SetScript("OnClick", Tab_OnClick)
    tab:SetScript("OnShow", nil)
    tab.content = CreateFrame("Frame", nil, PAPetCard)
    tab.content:Hide()
    tab.content.contentWidth = DISPLAY.Constants.minWidth
	tab.content:SetPoint("TOPLEFT", PAPetCard, "TOPLEFT", 4, -25);
	tab.content:SetPoint("BOTTOMRIGHT", PAPetCard, "BOTTOMRIGHT", -3, 4);
    tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND")
    tab.content.bg:SetAllPoints(true)
    tab.content.bg:SetColorTexture(.2, 0,.6,.05)

    tab.Left:ClearAllPoints()
    tab.Left:SetPoint("TOPLEFT", tab, "TOPLEFT", -2, 12)
    tab.Left:SetRotation(math.pi/2 *-1)
    tab.Left:SetWidth(tab.Left:GetHeight())
    tab.Right:ClearAllPoints()
    tab.Right:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", -2, 0)
    tab.Right:SetRotation(math.pi/2 *-1)
    tab.Right:SetWidth(tab.Right:GetHeight())
    tab.Middle:ClearAllPoints()
    tab.Middle:SetPoint("TOP", tab, "TOP", 0, -24)
    tab.Middle:SetPoint("LEFT", tab.Left, "LEFT", 0, 0)
    tab.Middle:SetRotation(math.pi/2 *-1)
    tab.Middle:SetWidth(tab.Middle:GetHeight())
    
    tab.LeftActive:ClearAllPoints()
    tab.LeftActive:SetPoint("TOPLEFT", tab, "TOPLEFT", -7, 12)
    tab.LeftActive:SetRotation(math.pi/2 *-1)
    tab.LeftActive:SetWidth(tab.LeftActive:GetHeight())
    tab.RightActive:ClearAllPoints()
    tab.RightActive:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT",-7, 0)
    tab.RightActive:SetRotation(math.pi/2 *-1)
    tab.RightActive:SetWidth(tab.RightActive:GetHeight())
    tab.MiddleActive:ClearAllPoints()
    tab.MiddleActive:SetPoint("TOP", tab, "TOP", 0, -21)
    tab.MiddleActive:SetPoint("LEFT", tab.Left, "LEFT", 4, 12)
    tab.MiddleActive:SetRotation(math.pi/2 *-1)
    tab.MiddleActive:SetWidth(24)
    
    tab.LeftHighlight:ClearAllPoints()
    tab.LeftHighlight:SetPoint("TOPLEFT", tab, "TOPLEFT", -2, 12)
    tab.LeftHighlight:SetRotation(math.pi/2 *-1)
    tab.LeftHighlight:SetWidth(tab.Left:GetHeight())
    tab.RightHighlight:ClearAllPoints()
    tab.RightHighlight:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", -2, 0)
    tab.RightHighlight:SetRotation(math.pi/2 *-1)
    tab.RightHighlight:SetWidth(tab.Right:GetHeight())
    tab.MiddleHighlight:ClearAllPoints()
    tab.MiddleHighlight:SetPoint("TOP", tab, "TOP", 0, -24)
    tab.MiddleHighlight:SetPoint("LEFT", tab.Left, "LEFT", 0, 0)
    tab.MiddleHighlight:SetRotation(math.pi/2 *-1)
    tab.MiddleHighlight:SetWidth(tab.Middle:GetHeight())

    tab.Text:ClearAllPoints()
    tab.Text:SetPoint("LEFT", tab, "LEFT", -32, 3)
    local AnimationGroup = tab.Text:CreateAnimationGroup();
    local Rotation = AnimationGroup:CreateAnimation("Rotation");
    Rotation:SetDegrees(90);
    Rotation:SetDuration(0);
    Rotation:SetEndDelay(1604800);
    AnimationGroup:Play();

    return tab
end

local function UpdateFullScreenBackgroundColor()
    local a = PETC_aSlider:GetValue()
    local r = PETC_rSlider:GetValue()
    local g = PETC_gSlider:GetValue()
    local b = PETC_bSlider:GetValue()
    PAPetCardTab1.content.modelPopoutFullScreenFrame.bg:SetColorTexture(r, g, b, a)

    PETC_States.fullScreenBG_a = a
    PETC_States.fullScreenBG_r = r
    PETC_States.fullScreenBG_g = g
    PETC_States.fullScreenBG_b = b
end

local function AddBreed(breedsHeader, heartIcon, swordIcon, speedIcon, breeds, num)
    local topOffset = -6 -(num * 20)

    local frame = CreateFrame("BUTTON", nil, PAPetCardTab1.content);
    frame:SetPoint("TOP", breedsHeader, "BOTTOM", 0, topOffset + 3)
    frame:SetPoint("LEFT", PAPetCardTab1.content, "LEFT", 16, 0)
    frame:SetPoint("RIGHT", PAPetCardTab1.content, "LEFT", 200, 0)
    frame:SetHeight(17)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetColorTexture(1, .82, 0) --gameFontNormal Color
    texture:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, .3), CreateColor(1, 1, 1, .01))
    texture:SetAllPoints()
    texture:Hide()
    frame.texture = texture
    
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(PETS.BREEDS[num])
    label:SetPoint("TOPRIGHT", breedsHeader, "BOTTOMLEFT", 40, topOffset)
    
    local health = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    health:SetPoint("TOPLEFT", breedsHeader, "BOTTOMLEFT", 29, topOffset)
    health:SetWidth(75)
    health:SetJustifyH("CENTER")
    
    local power = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    power:SetPoint("TOPLEFT", breedsHeader, "BOTTOMLEFT", 70, topOffset)
    power:SetWidth(75)
    power:SetJustifyH("CENTER")

    local speed = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    speed:SetPoint("TOPLEFT", breedsHeader, "BOTTOMLEFT", 110, topOffset)
    speed:SetWidth(75)
    speed:SetJustifyH("CENTER")

    breeds[num] = {
        frame = frame,
        label = label,
        health = health,
        power = power,
        speed = speed,
    }

    --alpha==1 when the breed is available for this pet
    frame:SetScript("OnEnter", function(self)
        if (self:GetAlpha() == 1) then
            if (PAPetCardTab1.content.SelectedBreedFrame ~= self) then
                self.texture:SetDesaturated(true)
                self.texture:Show()
            end
        end
    end)
    frame:SetScript("OnLeave", function(self)
        if (self:GetAlpha() == 1) then
            self.texture:SetDesaturated(false)
            if PAPetCardTab1.content.SelectedBreedFrame ~= self then
                self.texture:Hide()
            end
        end
    end)

    frame:SetScript("OnClick", function(self)
        if (self:GetAlpha() == 1) then
            if (PAPetCardTab1.content.SelectedBreedFrame == self) then
                return
            end
            
            if (PAPetCardTab1.content.SelectedBreedFrame == nil) then
                PAPetCardTab1.content.SelectedBreedFrame = self;
            end

            PAPetCardTab1.content.SelectedBreedFrame.texture:Hide()
            PAPetCardTab1.content.SelectedBreedFrame = self
            self.texture:Show()
            self.texture:SetDesaturated(false)
        end
    end)
end

local function CreateVariant(num)
    local button = CreateFrame("BUTTON", nill, PAPetCardTab1.content.modelFrame.variantsFrame)
    button:SetNormalTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    button:GetNormalTexture():SetTexCoord(.50585938, 0.63085938, 0.02246094, 0.08203125)
    button:SetHighlightTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    button:GetHighlightTexture():SetTexCoord(.50585938, 0.63085938, 0.02246094, 0.08203125)
    --button:SetSize(64,61)
    button:SetSize(34,33)
    button.variantIndex = num

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetText(tostring(num))
    local offset = 0
    if (num == 1) then offset = 2 end
    if (num == 3) then offset = 1 end
    button.text:SetPoint("RIGHT", button, "RIGHT", -11 - offset, 0)
    button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.text:SetPropagateMouseClicks(true)
    button.text:SetPropagateMouseMotion(true)
    
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("RIGHT", button, "RIGHT", -6, 0)
    bg:SetSize(20,20)
    bg:SetTexture("Interface/Addons/PetCollector/textures/black64")

    button.owned = button:CreateTexture(nil, "OVERLAY")
    button.owned:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
    button.owned:SetAtlas("perks-owned-large")
    button.owned:SetSize(16,16)
    
    local chanceBg = button:CreateTexture(nil, "OVERLAY")
    chanceBg:SetPoint("TOPLEFT", button, "TOPRIGHT", -15, -5)
    chanceBg:SetSize(48,15)
    chanceBg:SetColorTexture(0,0,0)
    chanceBg:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, .5), CreateColor(0, 0, 0, 0))

    button.chance = button:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
    button.chance:SetText("25%")
    button.chance:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, -8)
    button.chance:SetAlpha(.5)

    button:SetScript("OnClick", function(self)
        PAPetCardTab1.content.modelFrame.variant1:SetScale(1)
        PAPetCardTab1.content.modelFrame.variant2:SetScale(1)
        PAPetCardTab1.content.modelFrame.variant3:SetScale(1)
        PAPetCardTab1.content.modelFrame.variant4:SetScale(1)
        self:SetScale(1.3)
        PAPetCardTab1.modelDisplayGenerator:SetModelByCreatureDisplayID(PAPetCard.pet.variants[self.variantIndex].id)
    end)

    return button
end

local function CreateWindow()
    DISPLAY.PetCard.winWidth = 400;

   --window
    local f = CreateFrame("Frame", "PAPetCard", UIParent, "UIPanelDialogTemplate", "TitleDragAreaTemplate")
    f.pools = {}
    f:SetResizable(true)
    f:SetSize(DISPLAY.PetCard.winWidth, 600)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)

    f.TitleArea = CreateFrame("Frame", nil, f)
    f.TitleArea:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -40)
    f.TitleArea:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -50, 0)
    f.TitleArea:EnableMouse(true)
    f.TitleArea:RegisterForDrag("LeftButton")
    f.TitleArea:SetScript("OnDragStart",
        function(self)
            PAPetCard.moving = true
            PAPetCard:StartMoving()
        end
    )
    f.TitleArea:SetScript("OnDragStop",
        function(self)
            PAPetCard.moving = nil
            PAPetCard:StopMovingOrSizing()
        end
    )
    f.Title:ClearAllPoints()
    f.Title:SetPoint("TOP", 0, -9)
    f.Title:SetPoint("CENTER")


    f.PrevPet = CreateFrame("BUTTON", nil, f.TitleArea)
    f.PrevPet:SetNormalAtlas("perks-backbutton")
    f.PrevPet:SetPushedAtlas("perks-backbutton-down")
    f.PrevPet:SetHighlightAtlas("hud-microbutton-highlight")
    f.PrevPet:SetPoint("TOPLEFT", f.TitleArea, "TOPLEFT", 10, -4)
    f.PrevPet:SetSize(24,22)
    f.PrevPet:SetScript("OnClick", function(self)
        if PAPetCard.pet.speciesID == PETS.lowest then
            DISPLAY.PetCard:Show(PETS.all[PETS.highest])
        else
            for idx = PAPetCard.pet.speciesID-1, PETS.lowest, -1 do
                if (PETS.all[idx]) then
                    DISPLAY.PetCard:Show(PETS.all[idx])
                    return;
                end
            end
        end
    end)

    f.NextPet = CreateFrame("BUTTON", nil, f.TitleArea)
    f.NextPet:SetNormalAtlas("perks-nextbutton")
    f.NextPet:SetPushedAtlas("perks-nextbutton-down")
    -- f.NextPet:SetHighlightAtlas("chatframe-button-up")
    f.NextPet:SetHighlightAtlas("hud-microbutton-highlight")
    f.NextPet:SetPoint("TOPLEFT", f.PrevPet, "TOPRIGHT", 2, 0)
    f.NextPet:SetSize(24,22)
    f.NextPet:SetScript("OnClick", function(self)
        if PAPetCard.pet.speciesID == PETS.highest then
            DISPLAY.PetCard:Show(PETS.all[PETS.lowest])
        else
            for idx = PAPetCard.pet.speciesID+1, PETS.highest, 1 do
                if (PETS.all[idx]) then
                    DISPLAY.PetCard:Show(PETS.all[idx])
                    return;
                end
            end
        end
    end)

    f.Close = CreateFrame("Button", "$parentClose", f)
    f.Close:SetSize(24, 24)
    f.Close:SetPoint("TOPRIGHT")
    f.Close:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    f.Close:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
    f.Close:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
    f.Close:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)

    --SpellBook-SkillLineTab
    PAPetCard.numTabs = 3
    local tab1 = CreateTab(1, "Pet Info")
    f.tab1 = tab1
    tab1:SetPoint("TOPRIGHT", PAPetCardTopLeft, "TOPLEFT", 4, -45)
    tab1:SetPoint("TOPLEFT", PAPetCardTopLeft, "TOPLEFT", -28, -45)

    local tab2 = CreateTab(2, "Acquisition")
    f.tab2 = tab2
    tab2:SetPoint("TOPRIGHT", tab1, "BOTTOMRIGHT", 0, -10)
    tab2:SetPoint("TOPLEFT", tab1, "BOTTOMRIGHT", -32, -10)

    local tab3 = CreateTab(3, "Sounds")
    f.tab3 = tab3
    tab3:SetPoint("TOPRIGHT", tab2, "BOTTOMRIGHT", 0, -10)
    tab3:SetPoint("TOPLEFT", tab2, "BOTTOMRIGHT", -32, -10)

   --tab1
    tab1.content.modelFrame = CreateFrame("FRAME", nil, tab1.content, "InsetFrameTemplate4")
    tab1.content.modelFrame:SetPoint("TOP", tab1.content, "TOP", 0, -15)
    tab1.content.modelFrame:SetPoint("LEFT", tab1.content, "LEFT", 15, 0)
    tab1.content.modelFrame:SetPoint("RIGHT", tab1.content, "RIGHT", -13, 0)
    tab1.content.modelFrame:SetHeight(200)
    tab1.content.modelFrame.bg = tab1.content.modelFrame:CreateTexture(nil, "BACKGROUND")
    tab1.content.modelFrame.bg:SetAllPoints(true)
    tab1.content.modelFrame.bg:SetAtlas("store-card-transmog")
    tab1.content.modelFrame.bg:SetTexCoord(.1,.9,.1,.9)
    tab1.content.modelFrame.shadow = tab1.content.modelFrame:CreateTexture(nil, "BACKGROUND")
    tab1.content.modelFrame.shadow:SetPoint("CENTER", tab1.content.modelFrame, "CENTER", 0, -70)
    tab1.content.modelFrame.shadow:SetHeight(150)
    tab1.content.modelFrame.shadow:SetAtlas("GarrFollower-Shadow")
    tab1.content.modelFrame.shadow:SetAlpha(.5)
    tab1.content.model = CreateFrame("ModelScene", nil, tab1.content.modelFrame, "WrappedAndUnwrappedModelScene")
    tab1.content.model:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 4, -4)
    tab1.content.model:SetPoint("BOTTOMRIGHT", tab1.content.modelFrame, "BOTTOMRIGHT", -4, 4)
    tab1.content.modelPopoutFullScreenFrame = CreateFrame("FRAME", nill, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    tab1.content.modelPopoutFullScreenFrame:Hide()
    tab1.content.modelPopoutFullScreenFrame:SetFrameStrata("FULLSCREEN")
    tab1.content.modelPopoutFullScreenFrame:SetAllPoints()
    tab1.content.modelPopoutFullScreenFrame.bg = tab1.content.modelPopoutFullScreenFrame:CreateTexture(nil, "BACKGROUND")
    tab1.content.modelPopoutFullScreenFrame.bg:SetAllPoints(true)
    tab1.content.modelPopoutFullScreenFrame.bg:SetColorTexture(0,0,0,0)

    tab1.content.modelFrame.PopOut = CreateFrame("BUTTON", nil, tab1.content.modelFrame)
    tab1.content.modelFrame.PopOut:SetNormalAtlas("RedButton-Expand")
    tab1.content.modelFrame.PopOut:SetPushedAtlas("RedButton-Expand-Pressed")
    tab1.content.modelFrame.PopOut:SetHighlightAtlas("RedButton-Highlight")
    tab1.content.modelFrame.PopOut:SetPoint("TOPRIGHT", tab1.content.modelFrame, "TOPRIGHT")
    tab1.content.modelFrame.PopOut:SetSize(24,24)
    tab1.content.modelFrame.PopOut:SetScript("OnClick", function(self)
        tab1.content.model:SetParent(popoutFullScreenFrame)
        tab1.content.model:ClearAllPoints()
        tab1.content.model:SetAllPoints()
        tab1.content.model:SetFrameStrata("FULLSCREEN_DIALOG")
        
        tab1.content.modelFrame.variantsFrame:ClearAllPoints()
        tab1.content.modelFrame.variantsFrame:SetPoint("TOPLEFT", tab1.content.modelPopoutFullScreenFrame.bSlider, "BOTTOMLEFT", 0, -30)
        tab1.content.modelFrame.variantsFrame:SetFrameStrata("FULLSCREEN_DIALOG")

        tab1.content.modelPopoutFullScreenFrame:Show()
        tab1.content.modelPopoutFullScreenFrame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                tab1.content.modelPopoutFullScreenFrame.PopOutClose:Click("LeftButton")
            end
        end)
    end)
    tab1.content.modelPopoutFullScreenFrame.PopOutClose = CreateFrame("BUTTON", nil, tab1.content.modelPopoutFullScreenFrame, "BigRedExitButtonTemplate")
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetFrameStrata("FULLSCREEN_DIALOG")
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetFrameLevel(1000)
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetScript("OnClick", function(self)
        tab1.content.model:SetParent(tab1.content.modelFrame)
        tab1.content.model:ClearAllPoints()
        tab1.content.model:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 4, -4)
        tab1.content.model:SetPoint("BOTTOMRIGHT", tab1.content.modelFrame, "BOTTOMRIGHT", -4, 4)
        
        tab1.content.modelFrame.variantsFrame:ClearAllPoints()
        tab1.content.modelFrame.variantsFrame:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 3, -5)
        tab1.content.modelFrame.variantsFrame:SetFrameStrata("DIALOG")

        tab1.content.modelPopoutFullScreenFrame:Hide()
        tab1.content.modelPopoutFullScreenFrame:SetScript("OnKeyDown", nil)
    end)
    
    tab1.content.modelPopoutFullScreenFrame.aSlider = CreateFrame("Slider", "PETC_aSlider", tab1.content.modelPopoutFullScreenFrame, "OptionsSliderTemplate")
    tab1.content.modelPopoutFullScreenFrame.aSlider:SetFrameStrata("FULLSCREEN_DIALOG")
    tab1.content.modelPopoutFullScreenFrame.aSlider:SetFrameLevel(1000)
    tab1.content.modelPopoutFullScreenFrame.aSlider:SetPoint("TOPLEFT", tab1.content.modelPopoutFullScreenFrame.PopOutClose, "BOTTOMLEFT", 20, -40)
    tab1.content.modelPopoutFullScreenFrame.aSlider:SetValueStep(.01)
    tab1.content.modelPopoutFullScreenFrame.aSlider:SetMinMaxValues(0, 1)
    tab1.content.modelPopoutFullScreenFrame.aSlider:SetValue(UTILITIES:Ternary2(PETC_States.fullScreenBG_a, 0))
    tab1.content.modelPopoutFullScreenFrame.aSlider:SetScript("OnValueChanged", UpdateFullScreenBackgroundColor)
    PETC_aSliderLow:SetText("Alpha")
    PETC_aSliderHigh:SetText("")
    tab1.content.modelPopoutFullScreenFrame.rSlider = CreateFrame("Slider", "PETC_rSlider", tab1.content.modelPopoutFullScreenFrame, "OptionsSliderTemplate")
    tab1.content.modelPopoutFullScreenFrame.rSlider:SetFrameStrata("FULLSCREEN_DIALOG")
    tab1.content.modelPopoutFullScreenFrame.rSlider:SetFrameLevel(1000)
    tab1.content.modelPopoutFullScreenFrame.rSlider:SetPoint("TOPLEFT", PETC_aSlider, "BOTTOMLEFT", 0, -10)
    tab1.content.modelPopoutFullScreenFrame.rSlider:SetValueStep(.01)
    tab1.content.modelPopoutFullScreenFrame.rSlider:SetMinMaxValues(0, 1)
    tab1.content.modelPopoutFullScreenFrame.rSlider:SetValue(UTILITIES:Ternary2(PETC_States.fullScreenBG_r, 0))
    tab1.content.modelPopoutFullScreenFrame.rSlider:SetScript("OnValueChanged", UpdateFullScreenBackgroundColor)
    PETC_rSliderLow:SetText("Red")
    PETC_rSliderHigh:SetText("")    
    tab1.content.modelPopoutFullScreenFrame.gSlider = CreateFrame("Slider", "PETC_gSlider", tab1.content.modelPopoutFullScreenFrame, "OptionsSliderTemplate")
    tab1.content.modelPopoutFullScreenFrame.gSlider:SetFrameStrata("FULLSCREEN_DIALOG")
    tab1.content.modelPopoutFullScreenFrame.gSlider:SetFrameLevel(1000)
    tab1.content.modelPopoutFullScreenFrame.gSlider:SetPoint("TOPLEFT", PETC_rSlider, "BOTTOMLEFT", 0, -10)
    tab1.content.modelPopoutFullScreenFrame.gSlider:SetValueStep(.01)
    tab1.content.modelPopoutFullScreenFrame.gSlider:SetMinMaxValues(0, 1)
    tab1.content.modelPopoutFullScreenFrame.gSlider:SetValue(UTILITIES:Ternary2(PETC_States.fullScreenBG_g, 0))
    tab1.content.modelPopoutFullScreenFrame.gSlider:SetScript("OnValueChanged", UpdateFullScreenBackgroundColor)
    PETC_gSliderLow:SetText("Green")
    PETC_gSliderHigh:SetText("")    
    tab1.content.modelPopoutFullScreenFrame.bSlider = CreateFrame("Slider", "PETC_bSlider", tab1.content.modelPopoutFullScreenFrame, "OptionsSliderTemplate")
    tab1.content.modelPopoutFullScreenFrame.bSlider:SetFrameStrata("FULLSCREEN_DIALOG")
    tab1.content.modelPopoutFullScreenFrame.bSlider:SetFrameLevel(1000)
    tab1.content.modelPopoutFullScreenFrame.bSlider:SetPoint("TOPLEFT", PETC_gSlider, "BOTTOMLEFT", 0, -10)
    tab1.content.modelPopoutFullScreenFrame.bSlider:SetValueStep(.01)
    tab1.content.modelPopoutFullScreenFrame.bSlider:SetMinMaxValues(0, 1)
    tab1.content.modelPopoutFullScreenFrame.bSlider:SetValue(UTILITIES:Ternary2(PETC_States.fullScreenBG_b, 0))
    tab1.content.modelPopoutFullScreenFrame.bSlider:SetScript("OnValueChanged", UpdateFullScreenBackgroundColor)
    PETC_bSliderLow:SetText("Blue")
    PETC_bSliderHigh:SetText("")
    UpdateFullScreenBackgroundColor()

    tab1.content.modelFrame.variantsFrame = CreateFrame("FRAME", nil, tab1.content.modelFrame)
    tab1.content.modelFrame.variantsFrame:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 3, -5)
    tab1.content.modelFrame.variantsFrame:SetSize(200,300) --arbitrary
    tab1.content.modelFrame.variant1 = CreateVariant(1)
    tab1.content.modelFrame.variant1:SetPoint("TOPLEFT", tab1.content.modelFrame.variantsFrame, "TOPLEFT")
    tab1.content.modelFrame.variant1:SetScale(1.3)
    tab1.content.modelFrame.variant2 = CreateVariant(2)
    tab1.content.modelFrame.variant2:SetPoint("TOPLEFT", tab1.content.modelFrame.variant1, "BOTTOMLEFT")
    tab1.content.modelFrame.variant3 = CreateVariant(3)
    tab1.content.modelFrame.variant3:SetPoint("TOPLEFT", tab1.content.modelFrame.variant2, "BOTTOMLEFT")
    tab1.content.modelFrame.variant4 = CreateVariant(4)
    tab1.content.modelFrame.variant4:SetPoint("TOPLEFT", tab1.content.modelFrame.variant3, "BOTTOMLEFT")

    tab1.content.unobtainable = tab1.content.modelFrame:CreateFontString(nil, "OVERLAY", "NumberFont_Outline_Large")
    tab1.content.unobtainable:SetPoint("LEFT", tab1.content.modelFrame, "LEFT", -12, 0)
    tab1.content.unobtainable:SetPoint("TOP", tab1.content.modelFrame, "CENTER", 0, 52)
    tab1.content.unobtainable:SetText("*UNOBTAINABLE*")
    tab1.content.unobtainable:SetRotation(math.pi/4 )
    tab1.content.unobtainable:SetTextColor(.7, .4, .4)

    tab1.content.flavor = tab1.content:CreateFontString(nil, "ARTWORK", "NumberFont_Outline_Huge")
    tab1.content.flavor:SetPoint("TOP", tab1.content.modelFrame, "BOTTOM", 0, -15)
    tab1.content.flavor:SetPoint("LEFT", tab1.content, "LEFT", 30, 0)
    tab1.content.flavor:SetPoint("RIGHT", tab1.content, "RIGHT", -30, 0)
    local fontFile, fontHeight, fontFlags = tab1.content.flavor:GetFont()
    tab1.content.flavor:SetFont(fontFile, 15, nil)
    tab1.content.flavor:SetTextColor(.920, 0.858, 0.761)
    tab1.content.flavor:SetWordWrap(true)
    --bastion-zone-ability-2

    tab1.content.flavorbg = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.flavorbg:SetAtlas("bonusobjectives-title-bg")
    -- tab1.content.flavorbg:SetDesaturated(true)
    tab1.content.flavorbg:SetPoint("TOPLEFT", tab1.content.flavor, "TOPLEFT", -10, 10)
    tab1.content.flavorbg:SetPoint("BOTTOMRIGHT", tab1.content.flavor, "BOTTOMRIGHT", 10, -15)

    tab1.content.flavorbgColor = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.flavorbgColor:SetColorTexture(0,0,0)
    tab1.content.flavorbgColor:SetPoint("TOP", tab1.content.flavorbg, "TOP",0, -1)
    tab1.content.flavorbgColor:SetPoint("BOTTOM", tab1.content.flavorbg, "BOTTOM",0, 8)
    tab1.content.flavorbgColor:SetPoint("LEFT", tab1.content, "LEFT", 6,0)
    tab1.content.flavorbgColor:SetPoint("RIGHT", tab1.content, "RIGHT",-3, 0)
    tab1.content.flavorbgColorL = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.flavorbgColorL:SetColorTexture(1,1,1)
    tab1.content.flavorbgColorL:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0), CreateColor(1, 1, 1, .5))
    tab1.content.flavorbgColorL:SetPoint("TOP", tab1.content.flavorbgColor, "TOP")
    tab1.content.flavorbgColorL:SetPoint("BOTTOM", tab1.content.flavorbgColor, "BOTTOM")
    tab1.content.flavorbgColorL:SetPoint("LEFT", tab1.content, "LEFT", 20,0)
    tab1.content.flavorbgColorL:SetPoint("RIGHT", tab1.content, "CENTER")
    tab1.content.flavorbgColorR = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.flavorbgColorR:SetColorTexture(1,1,1)
    tab1.content.flavorbgColorR:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, .5), CreateColor(1, 1, 1, 0))
    tab1.content.flavorbgColorR:SetPoint("TOP", tab1.content.flavorbgColor, "TOP")
    tab1.content.flavorbgColorR:SetPoint("BOTTOM", tab1.content.flavorbgColor, "BOTTOM")
    tab1.content.flavorbgColorR:SetPoint("LEFT", tab1.content, "CENTER")
    tab1.content.flavorbgColorR:SetPoint("RIGHT", tab1.content, "RIGHT", -20, 0)


    tab1.content.tradable = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.tradable:SetText("Tradable ")
    tab1.content.tradable:SetPoint("TOPRIGHT", tab1.content.flavorbg, "BOTTOMRIGHT", -20, -5)
    tab1.content.tradable:SetAlpha(.5)
    tab1.content.tradableCheck = tab1.content:CreateTexture(nil, "ARTWORK")
    tab1.content.tradableCheck:SetAtlas("auctionhouse-icon-checkmark")
    tab1.content.tradableCheck:SetSize(16,16)
    tab1.content.tradableCheck:SetPoint("TOPLEFT", tab1.content.tradable, "TOPRIGHT", 3, 3);
    tab1.content.tradableLine = tab1.content:CreateLine(nil, "OVERLAY", nil, 7)
    tab1.content.tradableLine:SetColorTexture(.6, .4, .4, .7)
    tab1.content.tradableLine:SetStartPoint("TOPLEFT", tab1.content.tradable, -5, -6)
    tab1.content.tradableLine:SetEndPoint("TOPRIGHT", tab1.content.tradable, 2, -6)
    tab1.content.tradableLine:SetThickness(1)
    
    tab1.content.collectedLbl = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.collectedLbl:SetPoint("TOPLEFT", tab1.content.flavorbg, "BOTTOMLEFT", 0, -5)
    tab1.content.collectedLbl:SetText("Collected ")
    tab1.content.collectedCount = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.collectedCount:SetPoint("TOPLEFT", tab1.content.collectedLbl, "TOPRIGHT")
    tab1.content.collectedSlash = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.collectedSlash:SetPoint("TOPLEFT", tab1.content.collectedCount, "TOPRIGHT")
    tab1.content.collectedSlash:SetText("/")
    tab1.content.collectedMax = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.collectedMax:SetPoint("TOPLEFT", tab1.content.collectedSlash, "TOPRIGHT")
    tab1.content.collectedColon = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.collectedColon:SetPoint("TOPLEFT", tab1.content.collectedMax, "TOPRIGHT")
    tab1.content.collectedColon:SetText(":  ")

    tab1.content.collected1 = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tab1.content.collected1:SetPoint("TOPLEFT", tab1.content.collectedColon, "TOPRIGHT")
    tab1.content.collected2 = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tab1.content.collected2:SetPoint("TOPLEFT", tab1.content.collected1, "TOPRIGHT", 10,0)
    tab1.content.collected3 = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tab1.content.collected3:SetPoint("TOPLEFT", tab1.content.collected2, "TOPRIGHT", 10,0)

   --breeds & family
    local breedsHeader = tab1.content:CreateTexture(nil, "BACKGROUND", nil, 1)
    breedsHeader:SetHeight(20)
    breedsHeader:SetPoint("TOPLEFT", tab1.content.collectedLbl, "TOPLEFT", 0, -30);
    breedsHeader:SetPoint("RIGHT", tab1.content, "RIGHT", -15, 0);
    breedsHeader:SetColorTexture(39/256, 38/256, 41/256)

    local familyCirclebg = tab1.content:CreateTexture(nil, "BACKGROUND", nil, 2)
    familyCirclebg:SetPoint("TOPLEFT", breedsHeader, "TOPLEFT", -7, 10);
    familyCirclebg:SetSize(40,40)
    familyCirclebg:SetTexture("Interface/Addons/PetCollector/textures/black64")
    tab1.content.familyIcon = tab1.content:CreateTexture(nil, "ARTWORK", nil, 3)
    tab1.content.familyIcon:SetTexCoord(.1, .9, .1, .9)
    tab1.content.familyIcon:SetSize(30,30)
    tab1.content.familyIcon:SetPoint("CENTER", familyCirclebg, "CENTER");
    local familyCircle = tab1.content:CreateTexture(nil, "BACKGROUND", nil, 4)
    familyCircle:SetSize(40,40)
    familyCircle:SetAtlas("ChallengeMode-AffixRing-Lg")
    familyCircle:SetPoint("CENTER", familyCirclebg, "CENTER");
    
    local breedsLbl = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    breedsLbl:SetText("Possible Breeds")
    breedsLbl:SetPoint("TOPLEFT", breedsHeader, "TOPLEFT", 60, -4)

    local healthIcon = tab1.content:CreateTexture(nil, "BACKGROUND")
    healthIcon:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
    healthIcon:SetTexCoord(.5, 1, .5, 1)
    healthIcon:SetSize(16,16)
    healthIcon:SetPoint("TOPLEFT", breedsHeader, "BOTTOMLEFT", 58, -5)
    local powerIcon = tab1.content:CreateTexture(nil, "BACKGROUND")
    powerIcon:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
    powerIcon:SetTexCoord(0, .5, 0, .5)
    powerIcon:SetSize(16,16)
    powerIcon:SetPoint("TOPLEFT", healthIcon, "TOPRIGHT", 25, 0)
    local speedIcon = tab1.content:CreateTexture(nil, "BACKGROUND")
    speedIcon:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
    speedIcon:SetTexCoord(0, .5, .5, 1)
    speedIcon:SetSize(16,16)
    speedIcon:SetPoint("TOPLEFT", powerIcon, "TOPRIGHT", 24, 0)
    
    tab1.content.breeds = {}
    for i = 1, 10 do
        AddBreed(breedsHeader, healthIcon, powerIcon, speedIcon, tab1.content.breeds, i)
    end
    
    local borderAlpha = .3
    local leftBorderLine = tab1.content:CreateTexture(nil, "BACKGROUND")
    leftBorderLine:SetWidth(1)
    leftBorderLine:SetPoint("TOPLEFT", tab1.content.breeds[3].frame, "TOPLEFT", -1, 0)
    leftBorderLine:SetPoint("BOTTOM", tab1.content.breeds[10].frame, "BOTTOM", 0, -8)
    leftBorderLine:SetColorTexture(.7, .7, .7)
    leftBorderLine:SetGradient("VERTICAL", CreateColor(.7, .7, .7, borderAlpha), CreateColor(.7, .7, .7, 0))
    local rightBorderLine = tab1.content:CreateTexture(nil, "BACKGROUND")
    rightBorderLine:SetWidth(1)
    rightBorderLine:SetPoint("TOPLEFT", tab1.content.breeds[3].frame, "TOPRIGHT", 1, 0)
    rightBorderLine:SetPoint("BOTTOM", tab1.content.breeds[10].frame, "BOTTOM", 0, -8)
    rightBorderLine:SetColorTexture(.7, .7, .7)
    rightBorderLine:SetGradient("VERTICAL", CreateColor(.7, .7, .7, borderAlpha), CreateColor(.7, .7, .7, 0))
    tab1.content.bottomBorderLine = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.bottomBorderLine:SetHeight(1)
    tab1.content.bottomBorderLine:SetPoint("LEFT", leftBorderLine, "RIGHT")
    tab1.content.bottomBorderLine:SetPoint("RIGHT", rightBorderLine, "LEFT")
    tab1.content.bottomBorderLine:SetPoint("BOTTOM", leftBorderLine, "BOTTOM")
    tab1.content.bottomBorderLine:SetColorTexture(.7, .7, .7, borderAlpha)
                
    tab1.content.cannotBattleLbl = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.cannotBattleLbl:SetPoint("TOPLEFT", tab1.content.collectedColon, "TOPRIGHT", 0, 0)
    tab1.content.cannotBattleLbl:SetText("This pet cannot battle")

   --abilities    
    local abilitiesLbl = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    abilitiesLbl:SetText("Abilities")
    abilitiesLbl:SetPoint("TOPLEFT", breedsLbl, "TOPLEFT", 192.5, 0)

    tab1.content.abilitiesFrame = CreateFrame("FRAME", nil, tab1.content)
    tab1.content.abilitiesFrame:SetPoint("TOPRIGHT", breedsHeader, "BOTTOMRIGHT", 30, -10)
    tab1.content.abilitiesFrame:SetSize(191, 105)
    tab1.content.abilitiesCol1 = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.abilitiesCol1:SetNormalAtlas("PetJournal-PetCard-Abilities")
    tab1.content.abilitiesCol1:SetPoint("TOPLEFT", tab1.content.abilitiesFrame, "TOPLEFT")
    tab1.content.abilitiesCol1:SetSize(57, 105)
    tab1.content.ability1 = tab1.content.abilitiesCol1:CreateTexture(nil, "OVERLAY")
    tab1.content.ability1:SetPoint("TOPLEFT", tab1.content.abilitiesCol1, "TOPLEFT", 11, -12)
    tab1.content.ability1:SetSize(34,34)
    tab1.content.ability1Border = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.ability1Border:SetNormalAtlas("Adventures-Spell-Border")
    tab1.content.ability1Border:SetPoint("TOPLEFT", tab1.content.abilitiesCol1, "TOPLEFT", 8, -9)
    tab1.content.ability1Border:SetSize(41,40)
    tab1.content.ability4 = tab1.content.abilitiesCol1:CreateTexture(nil, "OVERLAY")
    tab1.content.ability4:SetPoint("TOPLEFT", tab1.content.abilitiesCol1, "TOPLEFT", 11, -60)
    tab1.content.ability4:SetSize(34,34)
    tab1.content.ability4Border = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.ability4Border:SetNormalAtlas("Adventures-Spell-Border")
    tab1.content.ability4Border:SetPoint("TOPLEFT", tab1.content.abilitiesCol1, "TOPLEFT", 8, -57)
    tab1.content.ability4Border:SetSize(41,40)
    tab1.content.abilitiesCol2 = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.abilitiesCol2:SetNormalAtlas("PetJournal-PetCard-Abilities")
    tab1.content.abilitiesCol2:SetPoint("TOPLEFT", tab1.content.abilitiesCol1, "TOPRIGHT", -5, 0)
    tab1.content.abilitiesCol2:SetSize(57, 105)
    tab1.content.ability2 = tab1.content.abilitiesCol2:CreateTexture(nil, "OVERLAY")
    tab1.content.ability2:SetPoint("TOPLEFT", tab1.content.abilitiesCol2, "TOPLEFT", 11, -12)
    tab1.content.ability2:SetSize(34,34)
    tab1.content.ability2Border = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.ability2Border:SetNormalAtlas("Adventures-Spell-Border")
    tab1.content.ability2Border:SetPoint("TOPLEFT", tab1.content.abilitiesCol2, "TOPLEFT", 8, -9)
    tab1.content.ability2Border:SetSize(41,40)
    tab1.content.ability5 = tab1.content.abilitiesCol2:CreateTexture(nil, "OVERLAY")
    tab1.content.ability5:SetPoint("TOPLEFT", tab1.content.abilitiesCol2, "TOPLEFT", 11, -60)
    tab1.content.ability5:SetSize(34,34)
    tab1.content.ability5Border = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.ability5Border:SetNormalAtlas("Adventures-Spell-Border")
    tab1.content.ability5Border:SetPoint("TOPLEFT", tab1.content.abilitiesCol2, "TOPLEFT", 8, -57)
    tab1.content.ability5Border:SetSize(41,40)
    tab1.content.abilitiesCol3 = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.abilitiesCol3:SetNormalAtlas("PetJournal-PetCard-Abilities")
    tab1.content.abilitiesCol3:SetPoint("TOPLEFT", tab1.content.abilitiesCol2, "TOPRIGHT", -5, 0)
    tab1.content.abilitiesCol3:SetSize(57, 105)
    tab1.content.ability3 = tab1.content.abilitiesCol3:CreateTexture(nil, "OVERLAY")
    tab1.content.ability3:SetPoint("TOPLEFT", tab1.content.abilitiesCol3, "TOPLEFT", 11, -12)
    tab1.content.ability3:SetSize(34,34)
    tab1.content.ability3Border = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.ability3Border:SetNormalAtlas("Adventures-Spell-Border")
    tab1.content.ability3Border:SetPoint("TOPLEFT", tab1.content.abilitiesCol3, "TOPLEFT", 8, -9)
    tab1.content.ability3Border:SetSize(41,40)
    tab1.content.ability6 = tab1.content.abilitiesCol3:CreateTexture(nil, "OVERLAY")
    tab1.content.ability6:SetPoint("TOPLEFT", tab1.content.abilitiesCol3, "TOPLEFT", 11, -60)
    tab1.content.ability6:SetSize(34,34)
    tab1.content.ability6Border = CreateFrame("BUTTON", nil, tab1.content.abilitiesFrame)
    tab1.content.ability6Border:SetNormalAtlas("Adventures-Spell-Border")
    tab1.content.ability6Border:SetPoint("TOPLEFT", tab1.content.abilitiesCol3, "TOPLEFT", 8, -57)
    tab1.content.ability6Border:SetSize(41,40)

   --tab2
    tab2.content.mapLbl = tab2.content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tab2.content.mapLbl:SetPoint("TOP", tab2.content, "TOP", 0, -10)
    tab2.content.mapLbl:SetPoint("CENTER", tab2.content)
    tab2.content.mapLbl:SetWidth(tab2.content:GetWidth() - 30)
    tab2.content.mapLbl:SetHeight(30)

    tab2.content.mapFrame = CreateFrame("Frame", nil, tab2.content)
    tab2.content.mapFrame:SetSize(350, 240)
    tab2.content.mapFrame:SetPoint("TOP", tab2.content.mapLbl, "BOTTOM",0, 0)
    tab2.content.mapFrame:SetPoint("CENTER", tab2.content)
	tab2.content.mapFrame:SetScript("OnMouseWheel", function(self, delta)
        local curScale = self:GetScale()
        if (delta>0) then
            if (curScale <4) then
                local mapFrame = self
                local scale = curScale +1
                mapFrame:SetScale(scale)
                local mapWidth = mapFrame:GetWidth() * mapFrame:GetEffectiveScale()
                local mapHeight = mapFrame:GetHeight() * mapFrame:GetEffectiveScale()
                for _, pin in pairs(mapFrame.pins) do
                    pin:SetPoint("TOPLEFT", mapWidth * (pin.coord[1]/100) - pin:GetWidth()/2, (mapHeight * (pin.coord[2]/100))*-1 + pin:GetHeight()/2)
                end
            end
        else
            if (curScale > 1) then
                local mapFrame = self
                local scale = curScale -1
                mapFrame:SetScale(scale)
                local mapWidth = mapFrame:GetWidth() * mapFrame:GetEffectiveScale()
                local mapHeight = mapFrame:GetHeight() * mapFrame:GetEffectiveScale()
                for _, pin in pairs(mapFrame.pins) do
                    pin:SetPoint("TOPLEFT", mapWidth * (pin.coord[1]/100) - pin:GetWidth()/2, (mapHeight * (pin.coord[2]/100))*-1 + pin:GetHeight()/2)
                end
            end
        end
    end);
    
    
    tab2.content.locationsFrame = CreateFrame("Frame", nil, tab2.content)
    tab2.content.locationsFrame:SetPoint("TOPLEFT", tab2.content.mapFrame, "BOTTOMLEFT")
    
    tab2.content.scrollFrame = CreateFrame("ScrollFrame", nil, tab2.content, "UIPanelScrollFrameTemplate")
    tab2.content.scrollFrame:SetClipsChildren(true)
    tab2.content.scrollFrame:SetPoint("TOPLEFT", tab2.content.locationsFrame, "BOTTOMLEFT", 0, -10);
    tab2.content.scrollFrame:SetPoint("BOTTOMRIGHT", tab2.content, "BOTTOMRIGHT",-4,5);
    tab2.content.scrollFrame.ScrollBar:ClearAllPoints();
    tab2.content.scrollFrame.ScrollBar:SetPoint("TOPLEFT", tab2.content.scrollFrame, "TOPRIGHT", -20, -18);
    tab2.content.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", tab2.content.scrollFrame, "BOTTOMRIGHT", 0, 17);
    tab2.content.scrollFrame.ScrollBar:Raise()
    tab2.content.scrollFrame.child = CreateFrame("Frame", nil, tab2.content.scrollFrame)
    tab2.content.scrollFrame:SetScrollChild(tab2.content.scrollFrame.child)
    tab2.content.scrollFrame.child:SetWidth(DISPLAY.PetCard.winWidth - 50)

    local hyperlinkEnter = function(frame, link, text, region)
        GameTooltip:SetOwner(frame, "ANCHOR_NONE")
        GameTooltip:ClearLines()
        GameTooltip:SetPoint("BOTTOM",region,"TOP",0,6)

        local linkType = strsplit(":", link)
        if (linkType == "npc" or linkType == "object" or linkType == "event") then
            GameTooltip:SetText("Click for WowHead link")
        else
            GameTooltip:SetHyperlink(link)
        end

        GameTooltip:Show()
    end
    local hyperlinkClick = function(self, link, text, button, region, left, bottom, width, height)
        local type, id = strsplit(":", link)
        if (type== "item") then
            DISPLAY.LinkWindow:Show(text, "https://www.wowhead.com/item=" .. id)
        elseif (type == "npc") then
            DISPLAY.LinkWindow:Show(text, "https://www.wowhead.com/npc=" .. id)
        elseif (type == "quest") then
            DISPLAY.LinkWindow:Show(text, "https://www.wowhead.com/quest=" .. id)
        elseif (type == "object") then
            DISPLAY.LinkWindow:Show(text, "https://www.wowhead.com/object=" .. id)
        elseif (type == "event") then
            DISPLAY.LinkWindow:Show(text, "https://www.wowhead.com/event=" .. id)
        else
            ChatFrame_OnHyperlinkShow(self, link, text, button, region, left, bottom, width, height)
        end
    end

    tab2.content.scrollFrame:SetHyperlinksEnabled(true)
    tab2.content.scrollFrame:SetScript("OnHyperlinkEnter", hyperlinkEnter)
    tab2.content.scrollFrame:SetScript("OnHyperlinkLeave", GameTooltip_HideResetCursor)
    tab2.content.scrollFrame:SetScript("OnHyperlinkClick", hyperlinkClick)
    
    tab2.content.scrollFrame.child:SetHyperlinksEnabled(true)
    tab2.content.scrollFrame.child:SetScript("OnHyperlinkEnter", hyperlinkEnter)
    tab2.content.scrollFrame.child:SetScript("OnHyperlinkLeave", GameTooltip_HideResetCursor)
    tab2.content.scrollFrame.child:SetScript("OnHyperlinkClick", hyperlinkClick)

   --tab3
end

local function UpdateWindow(pet, locationIdx)
    for _, pool in pairs(PAPetCard.pools) do
        pool:ReleaseAll()
    end

    PAPetCard.pendingPet = nil
    PAPetCard.pendingLocationIdx = nil

    local f = PAPetCard
    f.Title:SetText(pet.name)
    
 --TAB 1
    f.tab1.content.flavor:SetText(pet.flavor)
    if (pet.unobtainable == true) then
        f.tab1.content.unobtainable:Show()
    else
        f.tab1.content.unobtainable:Hide()
    end

    if (f.tab1.content.flavor:GetHeight() <= 20) then --1line (3546)
        f.tab1.content.flavorbgColor:SetPoint("BOTTOM", f.tab1.content.flavorbg, "BOTTOM",0, 5)
    elseif (f.tab1.content.flavor:GetHeight() <= 40) then --2lines (39)
        f.tab1.content.flavorbgColor:SetPoint("BOTTOM", f.tab1.content.flavorbg, "BOTTOM",0, 8)
    elseif (f.tab1.content.flavor:GetHeight() <= 50) then  --3lines (40)
        f.tab1.content.flavorbgColor:SetPoint("BOTTOM", f.tab1.content.flavorbg, "BOTTOM",0, 10)
    elseif (f.tab1.content.flavor:GetHeight() <= 60) then  --4+lines (id=4288)
        f.tab1.content.flavorbgColor:SetPoint("BOTTOM", f.tab1.content.flavorbg, "BOTTOM",0, 12)
    else --5+lines (id=1639)
        f.tab1.content.flavorbgColor:SetPoint("BOTTOM", f.tab1.content.flavorbg, "BOTTOM",0, 14)
    end
    
  --tradable
    if (pet.isTradable == true) then
        f.tab1.content.tradable:SetAlpha(1)
        f.tab1.content.tradableLine:Hide()
        f.tab1.content.tradableCheck:Show()
    else
        f.tab1.content.tradable:SetAlpha(.4)
        f.tab1.content.tradableLine:Show()
        f.tab1.content.tradableCheck:Hide()
    end
  
  --model
    local sceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(pet.speciesID)
    if (sceneID) then
        f.tab1.content.model:TransitionToModelSceneID(sceneID)
    end

    f.tab1.modelDisplayGenerator = f.tab1.content.model:GetActorByTag("unwrapped")
    f.tab1.modelDisplayGenerator:SetModelByCreatureDisplayID(pet.variants[1].id)

    f.tab1.content.model.activeCamera:SetMaxZoomDistance(50)
    f.tab1.content.model.activeCamera:SetZoomDistance(14)
    
  --collected
    local collectedCount = 0
    if (pet.collected) then
        collectedCount = #pet.collected
    end
    f.tab1.content.collectedCount:SetText(collectedCount)
    if pet.unique then
        f.tab1.content.collectedMax:SetText(1)
    else
        f.tab1.content.collectedMax:SetText(3)
    end

    if (collectedCount > 0) then
        SetPetColor(f.tab1.content.collected1, pet.collected[1].rarity)
        f.tab1.content.collected1:SetText(pet.collected[1].level .. " " .. pet.collected[1].breed)
        f.tab1.content.collected1:Show()
    end
    if (collectedCount > 1) then
        SetPetColor(f.tab1.content.collected2, pet.collected[2].rarity)
        f.tab1.content.collected2:SetText(pet.collected[2].level .. " " .. pet.collected[2].breed)
        f.tab1.content.collected2:Show()
    end
    if (collectedCount > 2) then
        SetPetColor(f.tab1.content.collected3, pet.collected[3].rarity)
        f.tab1.content.collected3:SetText(pet.collected[3].level .. " " .. pet.collected[3].breed)
        f.tab1.content.collected3:Show()
    end

    if (collectedCount < 3) then
        f.tab1.content.collected3:Hide()
    end
    if (collectedCount < 2) then
        f.tab1.content.collected2:Hide()
    end
    if (collectedCount < 1) then
        f.tab1.content.collected1:Hide()
    end

  --variants
    local checkIfVariantCollected = function(displayId, pet, ownedTexture)
        if UTILITIES:IsEmpty(pet.collected) then
            ownedTexture:Hide()
            return;
        end

        for _, collectedPet in pairs(pet.collected) do
            if (collectedPet.displayID == displayId) then
                ownedTexture:Show()
                return
            end
        end
        ownedTexture:Hide()
    end
    f.selectedVariant = 1
    f.tab1.content.modelFrame.variant1:Hide();
    f.tab1.content.modelFrame.variant2:Hide();
    f.tab1.content.modelFrame.variant3:Hide();
    f.tab1.content.modelFrame.variant4:Hide();
    f.tab1.content.modelFrame.variant1:SetAlpha(1)
    f.tab1.content.modelFrame.variant2:SetAlpha(.7)
    f.tab1.content.modelFrame.variant3:SetAlpha(.7)
    f.tab1.content.modelFrame.variant4:SetAlpha(.7)
    local variantCount = UTILITIES:Count(pet.variants)
    if variantCount >= 2 then
        f.tab1.content.modelFrame.variant1.chance:SetText(tostring(pet.variants[1].chance) .. "%")
        checkIfVariantCollected(pet.variants[1].id, pet, f.tab1.content.modelFrame.variant1.owned)
        f.tab1.content.modelFrame.variant1:Show();
        f.tab1.content.modelFrame.variant2.chance:SetText(tostring(pet.variants[2].chance) .. "%")
        checkIfVariantCollected(pet.variants[2].id, pet, f.tab1.content.modelFrame.variant2.owned)
        f.tab1.content.modelFrame.variant2:Show();
    end
    if variantCount >= 3 then
        f.tab1.content.modelFrame.variant3.chance:SetText(tostring(pet.variants[3].chance) .. "%")
        checkIfVariantCollected(pet.variants[3].id, pet, f.tab1.content.modelFrame.variant3.owned)
        f.tab1.content.modelFrame.variant3:Show(); 
    end
    if variantCount >= 4 then
        f.tab1.content.modelFrame.variant4.chance:SetText(tostring(pet.variants[4].chance) .. "%")
        checkIfVariantCollected(pet.variants[4].id, pet, f.tab1.content.modelFrame.variant4.owned)
        f.tab1.content.modelFrame.variant4:Show();
    end
    
  --family
    local famName, famIcon, famR, famG, famB = getFamilyDetails(pet.family)
    f.tab1.content.familyIcon:SetTexture("interface\\icons\\pet_type_" .. famIcon)

  --possible breeds
   --reset
    for _, breed in ipairs(f.tab1.content.breeds) do
        breed.frame:SetAlpha(.3)
        breed.health:SetText("-")
        breed.power:SetText("-")
        breed.speed:SetText("-")
    end
   --apply new values
    if (pet.possibleBreeds) then
        for breedIdx, possibleBreedId in pairs(pet.possibleBreeds) do
            local breed = f.tab1.content.breeds[possibleBreedId]
            local stats = UTILITIES:GetMaxStatsForBreed(possibleBreedId, pet.baseStats)
            breed.frame.stats = stats

            breed.frame:SetAlpha(1)
            breed.health:SetText(stats[1])
            breed.power:SetText(stats[2])
            breed.speed:SetText(stats[3])
        end
        f.tab1.content.breeds[pet.possibleBreeds[1]].frame:Click()
    end

    if (not pet.isPassive) then
        f.tab1.content.cannotBattleLbl:Hide()
        f.tab1.content.abilitiesFrame:Show()
        local abilities = C_PetJournal.GetPetAbilityListTable(pet.speciesID)
        if (abilities) then
            UpdateAbility(f.tab1.content.ability1, abilities[1].abilityID, pet.petType)
            UpdateAbility(f.tab1.content.ability2, abilities[2].abilityID, pet.petType)
            UpdateAbility(f.tab1.content.ability3, abilities[3].abilityID, pet.petType)
            UpdateAbility(f.tab1.content.ability4, abilities[4].abilityID, pet.petType)
            UpdateAbility(f.tab1.content.ability5, abilities[5].abilityID, pet.petType)
            UpdateAbility(f.tab1.content.ability6, abilities[6].abilityID, pet.petType)
        end
    else
        f.tab1.content.cannotBattleLbl:Show()
        f.tab1.content.abilitiesFrame:Hide()
    end
    
    local actualContentHeight = f.tab1.content:GetTop() - f.tab1.content.bottomBorderLine:GetBottom() +45
    if (actualContentHeight < 550) then
        actualContentHeight = 550
    end
    f:SetHeight(actualContentHeight)

 --TAB 2
    local requestedLocation = GetLocation(pet, locationIdx)

    local mapFrame = f.tab2.content.mapFrame
    local priorBottom

    if (pet.locations) then
        f.tab2.content.scrollFrame:SetPoint("TOPLEFT", f.tab2.content.locationsFrame, "BOTTOMLEFT", 0, -10);
        f.tab2.content.mapFrame:Show()
    elseif (requestedLocation) then
        f.tab2.content.scrollFrame:SetPoint("TOPLEFT", f.tab2.content.mapFrame, "BOTTOMLEFT", 0, -10);
        f.tab2.content.mapFrame:Show()
    else
        f.tab2.content.scrollFrame:SetPoint("TOPLEFT", f.tab2.content, "TOPLEFT", 20, -20);
        f.tab2.content.mapFrame:Hide()
    end
    
    if (requestedLocation) then
        local mapID = requestedLocation.mapID
        local layers = C_Map.GetMapArtLayers(mapID)

        if layers and layers[1] then
            local layerInfo = layers[1]

            local textures = C_Map.GetMapArtLayerTextures(mapID,1)

            local widthCount = ceil(layerInfo.layerWidth/layerInfo.tileWidth)
            local heightCount = ceil(layerInfo.layerHeight/layerInfo.tileHeight)

            local xScale = mapFrame:GetWidth() / layerInfo.layerWidth
            local yScale = mapFrame:GetHeight() / layerInfo.layerHeight
            local scale = math.min(xScale, yScale)

            local adjustX = mapFrame:GetWidth() / 2 - layerInfo.layerWidth * (centerX or 0.5) * scale
            local adjustY = mapFrame:GetHeight() / 2 - layerInfo.layerHeight * (centerY or 0.5) * scale

            if (not adjustX == 0) then
                mapFrame:SetWidth(layerInfo.layerWidth * scale);
            elseif (not adjustY == 0) then
                mapFrame:SetHeight(layerInfo.layerHeight * scale);
            end

            for y=1,heightCount do
                for x=1,widthCount do
                    local textureIdx = (y-1)*widthCount + x
                    local t = DISPLAY_UTIL:AcquireMapTileTexture(PAPetCard, mapFrame)

                    t:SetSize(layerInfo.tileWidth*scale,layerInfo.tileHeight*scale)
                    t:SetPoint("TOPLEFT",adjustX + layerInfo.tileWidth * (x-1) * scale,-(y-1)*layerInfo.tileHeight * scale-adjustY)

                    t:SetTexture(textures[textureIdx])
                end
            end

            if (requestedLocation.coords) then
                mapFrame.pins = {}
                for _, coord in pairs(requestedLocation.coords) do
                    local pin = DISPLAY_UTIL:AcquireMapPinTexture(PAPetCard, mapFrame)
                    local type = coord.type and coord.type or requestedLocation.type
                    if type == "start" then
                        pin:SetAtlas("Islands-QuestBang")
                        pin:SetSize(16,16)
                    elseif type == "end" then
                        pin:SetAtlas("Islands-QuestTurnin")
                        pin:SetSize(16,16)
                    elseif type == "poi" then
                        -- pin:SetAtlas("VignetteKill")
                        pin:SetAtlas("VignetteEvent-SuperTracked")
                        pin:SetSize(12,12)
                    elseif type == "dot" then
                        pin:SetAtlas("Object")
                        pin:SetSize(9,9)
                    elseif type == "prof" then
                        pin:SetAtlas("LevelUp-Icon-Book")
                        pin:SetSize(12,12)
                    elseif type == "treasure" then
                        pin:SetAtlas("VignetteLoot")
                        pin:SetSize(7,7)
                    elseif type == "fish" then
                        pin:SetAtlas("Professions_Tracking_Fish")
                        pin:SetSize(8,8)
                    elseif type == "cave" then
                        --pin:SetAtlas("CaveUnderground-Down")
                        pin:SetAtlas("poi-door-down")
                        pin:SetSize(10,10)
                    elseif type == "boss" then
                        pin:SetAtlas("ShipMission_DangerousSkull")
                        pin:SetSize(8,9)
                    elseif type == "kill" then
                        if(#requestedLocation.coords == 1) then
                            pin:SetAtlas("ShipMission_DangerousSkull")
                            pin:SetSize(8,10)
                        else
                            pin:SetAtlas("ComboPoints-ComboPoint")
                            pin:SetSize(6,6)
                        end
                    elseif requestedLocation.currencies or type == "vendor" then
                        pin:SetAtlas("Levelup-Icon-Bag")
                        pin:SetSize(8,10)
                    elseif type == "npc" then                        
                        pin:SetAtlas("GM-icon-headCount")
                        pin:SetSize(10,10)
                    else
                        -- pin:SetAtlas("Interface\\Icons\\Tracking_WildPet")                        
                        pin:SetAtlas("WildBattlePetCapturable")
                        pin:SetSize(6,6)
                    end
                    local mapWidth = mapFrame:GetWidth() * mapFrame:GetEffectiveScale()
                    local mapHeight = mapFrame:GetHeight() * mapFrame:GetEffectiveScale()
                    local x = mapWidth * (coord[1]/100) - pin:GetWidth()/2
                    local y = (mapHeight * (coord[2]/100))*-1 + pin:GetHeight()/2
                    pin:SetPoint("TOPLEFT", mapFrame, "TOPLEFT", x, y)
                    pin.coord = coord
                    table.insert(mapFrame.pins, pin)
                end
            end

            local mapName = BuildMapTitle(requestedLocation)
            f.tab2.content.mapLbl:SetText(mapName)
        end

        if (pet.locations) then
            local locationsFrame = f.tab2.content.locationsFrame
            local locationLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, locationsFrame)
            locationLbl:SetText("Locations:  ")
            locationLbl:SetPoint("TOPLEFT", locationsFrame, "TOPLEFT")
            local locationLineWidth = locationLbl:GetWidth()
            local priorLoc
            local line = 0
            for locIdx, location in ipairs(pet.locations) do        
                if location.mapID then
                    local loc
                    if (location == requestedLocation) then
                        loc = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, locationsFrame)
                    else
                        loc = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, locationsFrame)
                    end
                    loc.locationIndex = location.mapID
                    loc.pet = pet
                    loc:SetText(C_Map.GetMapInfo(location.mapID).name)
                    locationLineWidth = locationLineWidth + loc:GetWidth()
                    if (not priorLoc or locationLineWidth > DISPLAY.PetCard.winWidth -55) then
                        if (priorLoc) then
                            line = line + 1
                        end
                        locationLineWidth = locationLbl:GetWidth() + loc:GetWidth()
                        loc:SetPoint("LEFT", locationLbl, "RIGHT")
                        loc:SetPoint("TOP", locationLbl, "TOP", 0, line * locationLbl:GetHeight()*-1)
                    else
                        local comma = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, locationsFrame)
                        comma:SetText(", ")
                        comma:SetPoint("TOPLEFT", priorLoc, "TOPRIGHT")
                        loc:SetPoint("TOPLEFT", comma, "TOPRIGHT")
                        locationLineWidth = locationLineWidth + comma:GetWidth()
                    end
                    priorLoc = loc
                    if (location ~= requestedLocation) then
                        loc:SetScript("OnMouseDown",
                            function(self)
                                DISPLAY.PetCard:Show(self.pet, self.locationIndex)
                            end
                        )
                    end
                end
            end
            locationsFrame:SetSize(DISPLAY.PetCard.winWidth, (line+1) * locationLbl:GetHeight())
            locationsFrame:Show()
            priorBottom = locationsFrame
        else
            
        end
    else
        f.tab2.content.mapLbl:SetText(nil)
    end

    if (pet.achievement) then
        local link = GetLink(pet.achievement.id)
        priorBottom = AddLabelAndVal(priorBottom, "Achievement: ", link)
    end

    if (pet.pois) then
        priorBottom = GetPois(priorBottom, pet, locationIdx)
    end

    if (pet.professionDetail) then
        priorBottom = GetProfessionText(priorBottom, pet.professionDetail)
    end

    if (pet.quest) then
        local link = GetLink(pet.quest)
        priorBottom = AddLabelAndVal(priorBottom, "Quest: ", link)
    end
    
    if (pet.reputation and pet.reputation.type) then
        priorBottom = AddLabelAndVal(priorBottom, "Reputation: ", pet.reputation.type, pet.reputation.level)
    end

    if (pet.source == "World Event") then
        priorBottom = AddLabelAndVal(priorBottom, "Source: ", pet.source, pet.eventName)
    end
    
    if (pet.source == "Promotion") then
        priorBottom = AddLabelAndVal(priorBottom, "Source: ", pet.source, pet.promotion)
    end

    if (pet.source == "Trading Card Game") then
        priorBottom = AddLabelAndVal(priorBottom, "Source: ", pet.source, pet.tcg)
    end

    if (pet.source == "World Drop" or pet.source =="In-Game Shop" or pet.source == "Archaeology" or pet.source == "Pet Battle") then
        priorBottom = AddLabelAndVal(priorBottom, "Source: ", pet.source)
    end

   -- INSTRUCTIONS
    local bla = PETC.SHARED.Instr.synthForge
    if (pet.acquisition) then
        f.tab2.content.instructionLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab2.content.scrollFrame.child)
        f.tab2.content.instructionLbl:SetPoint("LEFT", f.tab2.content.scrollFrame.child, "LEFT")
        if priorBottom then
            f.tab2.content.instructionLbl:SetPoint("TOP", priorBottom, "BOTTOM", 0, -10)
        else
            f.tab2.content.instructionLbl:SetPoint("TOP", f.tab2.content.scrollFrame.child, "TOP")
        end
        f.tab2.content.instructionLbl:SetText("Instructions:")
        priorBottom = f.tab2.content.instructionLbl

        for lineNum, lineContent in ipairs(pet.acquisition) do
            local numText = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab2.content.scrollFrame.child)
            numText:SetText(tostring(lineNum))
            numText:SetPoint("LEFT", f.tab2.content.instructionLbl, "LEFT", 10, 0)
            numText:SetPoint("TOP", priorBottom, "BOTTOM", 0, -10)

            local lineText = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, f.tab2.content.scrollFrame.child)
            local lineFormat, lineArgs = GetLineText(lineContent)
            if (lineArgs) then
                lineText:SetFormattedText(lineFormat, unpack(lineArgs))
            else
                lineText:SetText(lineFormat)
            end
            lineText:SetPoint("TOPLEFT", numText, "TOPLEFT", 20, 0)
            lineText:SetPoint("RIGHT", f.tab2.content.scrollFrame.child, "RIGHT", -5, 0)
            lineText:SetJustifyH("LEFT")
            lineText:SetWordWrap(true)
            priorBottom = lineText
        end
    end

   --SEPARATOR LINE 
    local lineFrame = DISPLAY_UTIL:AcquireFrame(PAPetCard, f.tab2.content.scrollFrame.child)
    lineFrame:SetPoint("LEFT", f.tab2.content.scrollFrame.child, "LEFT", 5,0)
    lineFrame:SetPoint("RIGHT", f.tab2.content.scrollFrame.child, "RIGHT", -5,0)
    if (priorBottom) then
        lineFrame:SetPoint("TOP", priorBottom, "BOTTOM", 0, -13)
    else
        lineFrame:SetPoint("TOP", f.tab2.content.scrollFrame.child, "TOP", 0, -13)
    end
    lineFrame:SetHeight(1)

    local line = lineFrame:CreateLine()
    line:SetColorTexture(.3, .3, .3)
    line:SetThickness(1)
    line:SetStartPoint("TOPLEFT")
    line:SetEndPoint("TOPRIGHT")

   --EXTERNAL LINKS
    local externalLinksLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab2.content.scrollFrame.child)
    externalLinksLbl:SetPoint("TOP", line, "BOTTOM", 0, -10)
    externalLinksLbl:SetPoint("LEFT", f.tab2.content.scrollFrame.child, "LEFT")
    externalLinksLbl:SetText("External links:")
    local wowhead = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, f.tab2.content.scrollFrame.child)
    wowhead:SetPoint("TOPLEFT", externalLinksLbl, "TOPRIGHT", 10, 0)
    wowhead:SetText("|Hwh|hWowHead|h")
    wowhead:SetScript("OnMouseDown",
        function(self)
            DISPLAY.LinkWindow:Show("WowHead link", "https://www.wowhead.com/npc=" .. PAPetCard.pet.companionID)
        end)
    local warcraftPets = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, f.tab2.content.scrollFrame.child)    
    warcraftPets:SetPoint("TOPLEFT", wowhead, "TOPRIGHT", 10, 0)
    warcraftPets:SetText("|Hwp|hWarcraft Pets|h")
    warcraftPets:SetScript("OnMouseDown",
        function(self)
            DISPLAY.LinkWindow:Show("Warcraft Pets link", "https://www.warcraftpets.com/wow-pets/pet/pet/" .. PAPetCard.pet.name:gsub("%s+", "-"))
        end)
    local xufu = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, f.tab2.content.scrollFrame.child)    
    xufu:SetPoint("TOPLEFT", warcraftPets, "TOPRIGHT", 10, 0)
    xufu:SetText("|Hxf|hXu-Fu|h")
    xufu:SetScript("OnMouseDown",
        function(self)
            DISPLAY.LinkWindow:Show("Xu-Fu Pet Guides link", "https://www.wow-petguide.com/Pet/" .. PAPetCard.pet.companionID)
        end)
    
    f.tab2.content.scrollFrame.child:SetHeight(1000)
    f.tab2.content.scrollFrame.child:SetHeight(f.tab2.content.scrollFrame.child:GetTop() - xufu:GetBottom() + 20)
    f.tab2.content.scrollFrame:GetHeight()
    
    if (not PAPetCard.SelectedTab) then
        Tab_OnClick(PAPetCardTab1)
    end
    
    PAPetCard.pet = pet;
    PAPetCard:Show()

 --TAB 3
    local soundLinkClick = function(self)
        PlaySound(self.soundId)
    end
    local soundNum = 0
    if (not UTILITIES:IsEmpty(pet.npcSounds)) then
        for npcSoundIndex, npcSoundId in pairs(pet.npcSounds) do
            local soundLink = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, f.tab3.content)
            soundLink:SetPoint("TOPLEFT", f.tab3.content, "TOPLEFT", 30, -20 - soundNum*24)
            soundLink:SetText("NPC ".. npcSoundIndex)
            soundLink.soundId = npcSoundId
            soundLink:SetScript("OnMouseDown", soundLinkClick)
            soundNum = soundNum +1
        end
    end
    if (not UTILITIES:IsEmpty(pet.creatureSounds)) then
        for creatureSoundIndex, creatureSound in pairs(pet.creatureSounds) do
            local soundName, soundId = getCreatureSoundDetails(creatureSound)
            local soundLink = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, f.tab3.content)
            soundLink:SetPoint("TOPLEFT", f.tab3.content, "TOPLEFT", 30, -20 - soundNum*24)
            soundLink:SetText(soundName)
            soundLink.soundId = soundId
            soundLink:SetScript("OnMouseDown", soundLinkClick)
            soundNum = soundNum +1
        end
    end
end

local function PrefetchItemInfo(itemIDStr)
    local id
    if (type(itemIDStr) == "number") then
        id = itemIDStr
    else
        id = tonumber(strsub(itemIDStr, 2))
    end

    if (not PAPetCard.itemsRequiredForCache[id]) then
        local response = GetItemInfo(id)
        PAPetCard.itemsRequiredForCache[id] = "bla" -- to avoid requesting the same item multiple times
        if response == nil then
            PAPetCard.itemsNotYetCached[id] = "bla" -- to know we have events coming
        end
    end
end

local function PrefetchCurrencyInfo(currencyIDStr)
    local type = strsub(currencyIDStr, 2, 2)
    if type == "i" then
        local _,_,id = strsplit(":", currencyIDStr)
        PrefetchItemInfo("i"..id)
    end
end

local function PrefetchInfo(infoStr)
    local type = strsub(infoStr, 1, 1)
    if (type == "c") then
        return PrefetchCurrencyInfo(infoStr)
    elseif (type == "i") then
        return PrefetchItemInfo(infoStr)
    else
        return
    end
end

local function EnsureCacheThenUpdateWindow(pet, locationIdx)
    PAPetCard.pendingPet = pet
    PAPetCard.pendingLocationIdx = locationIdx
    PAPetCard.allItemsRequested = false
    PAPetCard.itemsNotYetCached = {}
    PAPetCard.itemsRequiredForCache = {}
    if (pet.pois) then
        for _, depth1 in pairs(pet.pois) do
            for _, depth2 in pairs(depth1.entries) do
                PrefetchInfo(depth2.id)
                
                if (depth2.maps) then
                    for _, depth3 in pairs(depth2.maps) do
                        if (depth3.id) then
                            PrefetchInfo(depth3.id)
                        end

                        if (depth3.currencies) then
                            for _, currency in pairs(depth3.currencies) do
                                PrefetchCurrencyInfo(currency)
                            end
                        end
                    end
                end
            end
        end
    end
    if (pet.professionDetail) then
        if (pet.professionDetail.materials) then
            for _, material in pairs(pet.professionDetail.materials) do
                PrefetchItemInfo(material.id)
            end
        end
    end

    if (pet.acquisition) then
        for _, line in pairs(pet.acquisition) do
            for idx, piece in ipairs(line) do
                if (idx > 1) then
                    PrefetchInfo(piece)
                end
            end
        end
    end

    PAPetCard.allItemsRequested = true
    if (UTILITIES:Count(PAPetCard.itemsNotYetCached) > 0) then
        --we have to wait for GET_ITEM_INFO_RECEIVED to flow in
    else
        UpdateWindow(pet, locationIdx)
    end
end

function DISPLAY.PetCard:Show(pet, locationIdx)
    if (not PAPetCard) then
        CreateWindow()

        PAPetCard:RegisterEvent('GET_ITEM_INFO_RECEIVED')
        PAPetCard:SetScript('OnEvent', function(self, event, itemID)
            if event == 'GET_ITEM_INFO_RECEIVED' then
                if PAPetCard.itemsNotYetCached[itemID] then
                    PAPetCard.itemsNotYetCached[itemID] = nil
                    if (UTILITIES:Count(PAPetCard.itemsNotYetCached) == 0 and PAPetCard.allItemsRequested) then
                        UpdateWindow(PAPetCard.pendingPet, PAPetCard.pendingLocationIdx)
                    end
                end
            end
        end)
    else
        PAPetCard.tab2.content.locationsFrame:SetSize(0,0)
        PAPetCard.tab2.content.locationsFrame:Hide()
    end

    EnsureCacheThenUpdateWindow(pet, locationIdx)
end