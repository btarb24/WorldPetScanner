---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local DISPLAY_UTIL = DISPLAY.Util
local UTILITIES = PETC.UTILITIES
local PETS = PETC.PETS
local MAPS = PETC.MAPS

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

local function ParseLocation(location)
    local depth1 = 1
    local depth2 = 1
    local depth3 = 1
    if (location and type(location) == "string") then        
        local depth1Str, depth2Str, depth3Str  = strsplit(":", location)
        depth1 = tonumber(depth1Str)
        if (depth2Str) then
            depth2 = tonumber(depth2Str)
        end
        if (depth3Str) then
            depth3 = tonumber(depth3Str)
        end
    elseif location then
        depth1 = location
    end
    return depth1, depth2, depth3
end

local function AcquireMapTileTexture(parent)
    if (not parent.mapTilePool) then
        parent.mapTilePool = CreateTexturePool(parent, "BACKGROUND")
        table.insert(PAPetCard.pools, parent.mapTilePool)
    end

    local t = parent.mapTilePool:Acquire()
    t:Show()
    return t
end
local function AcquireMapPinTexture(parent)
    if (not parent.mapPinPool) then
        parent.mapPinPool = CreateTexturePool(parent, "OVERLAY")
        table.insert(PAPetCard.pools, parent.mapPinPool)
    end

    local t = parent.mapPinPool:Acquire()
    t:Show()
    return t
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
        link = GetSpellLink(id)
    elseif (type == "a") then
        id = tonumber(strsub(idStr, 2))
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

local function GetPois(pois, selectedIdx)
    local selectedDepth1, selectedDepth2, selectedDepth3 = ParseLocation(selectedIdx)
    
    local topDock 
    for poiTypeIdx, poiRoot in ipairs(pois) do
        local mainPoiLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        mainPoiLbl:SetText(poiRoot.name)
        if (poiTypeIdx == 1) then            
            mainPoiLbl:SetPoint("TOPLEFT", PAPetCardTab2.content.scrollFrame.child, "TOPLEFT")
        else
            mainPoiLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT")
            mainPoiLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -10)
        end
        
        topDock = mainPoiLbl
        local leftDock = mainPoiLbl
        for entryIdx, entry in ipairs(poiRoot.entries) do
            local poiLbl = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
            local poiLink, poiID, _, poiType
            if (entry.id and entry.id ~= "") then
                poiLink, poiID, _, poiType = GetLink(entry.id);
                poiLbl:SetText(poiLink)
                poiLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -5)

                if (poiType == "q") then                
                    local completed = C_QuestLog.IsComplete(poiID)

                    local questState = DISPLAY_UTIL:AcquireTexture(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                    if completed or entryIdx == 2 then
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
                topDock = poiLbl
            else
                leftDock = mainPoiLbl
            end

            if (entry.maps) then
                for mapIdx, map in ipairs(entry.maps) do
                    local mapDescLbl
                    if map.coords then
                        local isSelected = poiTypeIdx == selectedDepth1 and entryIdx == selectedDepth2 and mapIdx == selectedDepth3
                        if isSelected then
                            mapDescLbl = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                            if (map.desc) then
                                mapDescLbl:SetText(map.desc)
                            else
                                mapDescLbl:SetText(select(1, GetLink(map.id, "ffffff")))
                            end
                        else
                            mapDescLbl = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                            if (map.desc) then
                                mapDescLbl:SetText(map.desc)
                            else
                                mapDescLbl:SetText(select(3, GetLink(map.id, "ffffff")))
                            end
                            if (map.coords) then
                                mapDescLbl.locationIndex = string.format("%d:%d:%d", poiTypeIdx, entryIdx, mapIdx)
                                mapDescLbl:SetScript("OnMouseDown",
                                    function(self)
                                        DISPLAY.PetCard:Show(PAPetCard.pet, self.locationIndex)
                                    end
                                )
                            end
                        end
                    else
                        mapDescLbl = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                        mapDescLbl:SetText(GetLink(map.id))
                    end
                    mapDescLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -2)
                    mapDescLbl:SetPoint("LEFT", leftDock, "LEFT", 15, 0)

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
                    mapDetails:SetPoint("TOPLEFT", mapDescLbl, "TOPRIGHT", 3, -1)
                    
                    local poiIconAtlas = GetPoiIconAtlas(map.type)
                    if (poiIconAtlas) then
                        local mapTipIcon = DISPLAY_UTIL:AcquireTexture(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                        mapTipIcon:SetAtlas(poiIconAtlas)
                        mapTipIcon:SetSize(16,16)
                        mapTipIcon:SetPoint("TOP", topDock, "BOTTOM")
                        mapTipIcon:SetPoint("LEFT", leftDock, "LEFT", 15, 0)
                        mapDescLbl:SetPoint("LEFT", mapTipIcon, "RIGHT", 0, 0)
                    end

                    topDock = mapDescLbl
                end
            end
        end
    end
    
    return topDock
end

local function GetProfessionText(professionDetail, topDock)    
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
        recipeVal:SetText(GetSpellLink(professionDetail.recipe))
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

local function GetAchievementText(achievement, topDock)
    local achievementLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
    if (topDock) then
        achievementLbl:SetPoint("LEFT", PAPetCardTab2.content.scrollFrame.child, "LEFT")
        achievementLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -10)
    else
        achievementLbl:SetPoint("TOPLEFT", PAPetCardTab2.content.scrollFrame.child, "TOPLEFT")        
    end
    achievementLbl:SetText("Achievement: ")

    local achievementVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
    achievementVal:SetText(GetLink(achievement.id))
    achievementVal:SetPoint("TOPLEFT", achievementLbl, "TOPRIGHT")
    topDock = achievementLbl

    return topDock
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
    local depth1, depth2, depth3 = ParseLocation(location)
    if (pet.pois) then
        local poi = pet.pois[depth1]
        if not poi.entries then
            return nil
        end

        local entry = poi.entries[depth2]
        return entry.maps[depth3], false
    end

    if (not pet.isWild) then
        return nil
    end

    --no location map
    if (not pet.locations) then
        return nil
    end

    --standard map locations    
    for _, loc in ipairs(pet.locations) do
        if loc.mapID == location then
            return loc, true
        end
    end

    return pet.locations[1], true
end

local function UpdateAbility(texture, abilityID, petType)
    local _, icon = C_PetJournal.GetPetAbilityInfo(abilityID)
    texture:SetTexture(icon)
    texture:SetScript("OnEnter",
        function(self)
            local stats = PAPetCardTab1.content.SelectedBreed.stats
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

local function CreateWindow()
    DISPLAY.PetCard.winWidth = 400;

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
    PAPetCard.numTabs = 2
    local tab1 = CreateTab(1, "Pet Info")
    f.tab1 = tab1
    tab1:SetPoint("TOPRIGHT", PAPetCardTopLeft, "TOPLEFT", 4, -45)
    tab1:SetPoint("TOPLEFT", PAPetCardTopLeft, "TOPLEFT", -28, -45)

    local tab2 = CreateTab(2, "Acquisition")
    f.tab2 = tab2
    tab2:SetPoint("TOPRIGHT", tab1, "BOTTOMRIGHT", 0, -10)
    tab2:SetPoint("TOPLEFT", tab1, "BOTTOMRIGHT", -32, -10)

    tab1.content.modelFrame = CreateFrame("FRAME", nil, tab1.content, "InsetFrameTemplate4")
    tab1.content.modelFrame:SetPoint("TOP", tab1.content, "TOP", 0, -25)
    tab1.content.modelFrame:SetPoint("LEFT", tab1.content, "LEFT", 30, 0)
    tab1.content.modelFrame:SetPoint("RIGHT", tab1.content, "RIGHT", -30, 0)
    tab1.content.modelFrame:SetHeight(200)
    tab1.content.modelFrame.bg = tab1.content.modelFrame:CreateTexture(nil, "BACKGROUND")
    tab1.content.modelFrame.bg:SetAllPoints(true)
    tab1.content.modelFrame.bg:SetColorTexture(0,0,0)
    tab1.content.model = CreateFrame("ModelScene", nil, tab1.content.modelFrame, "WrappedAndUnwrappedModelScene")
    tab1.content.model:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 15, -15)
    tab1.content.model:SetPoint("BOTTOMRIGHT", tab1.content.modelFrame, "BOTTOMRIGHT", -15, 15)
    tab1.content.modelPopoutFullScreenFrame = CreateFrame("FRAME", nill, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    tab1.content.modelPopoutFullScreenFrame:Hide()
    tab1.content.modelPopoutFullScreenFrame:SetFrameStrata("FULLSCREEN")
    tab1.content.modelPopoutFullScreenFrame:SetAllPoints()
    tab1.content.modelPopoutFullScreenFrame.bg = tab1.content.modelPopoutFullScreenFrame:CreateTexture(nil, "BACKGROUND")
    tab1.content.modelPopoutFullScreenFrame.bg:Hide()
    tab1.content.modelPopoutFullScreenFrame.bg:SetAllPoints(true)
    tab1.content.modelPopoutFullScreenFrame.bg:SetColorTexture(0,0,0)

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
        tab1.content.modelPopoutFullScreenFrame:Show()
        if (PETC.flipIsHere) then
            tab1.content.modelPopoutFullScreenFrame.bg:Show()
            if (PETC.flipR) then
                tab1.content.modelPopoutFullScreenFrame.bg:SetColorTexture(tonumber(PETC.flipR), tonumber(PETC.flipG), tonumber(PETC.flipB))
            end
        end
    end)
    tab1.content.modelPopoutFullScreenFrame.PopOutClose = CreateFrame("BUTTON", nill, tab1.content.modelPopoutFullScreenFrame, "BigRedExitButtonTemplate")
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetFrameStrata("FULLSCREEN_DIALOG")
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetFrameLevel(1000)
    tab1.content.modelPopoutFullScreenFrame.PopOutClose:SetScript("OnClick", function(self)
        tab1.content.model:SetParent(tab1.content.modelFrame)
        tab1.content.model:ClearAllPoints()
        tab1.content.model:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 15, -15)
        tab1.content.model:SetPoint("BOTTOMRIGHT", tab1.content.modelFrame, "BOTTOMRIGHT", -15, 15)
        tab1.content.modelPopoutFullScreenFrame:Hide()
    end)

    tab1.content.unobtainable = tab1.content.modelFrame:CreateFontString(nil, "OVERLAY", "NumberFont_Outline_Large")
    tab1.content.unobtainable:SetPoint("LEFT", tab1.content.modelFrame, "LEFT", -12, 0)
    tab1.content.unobtainable:SetPoint("TOP", tab1.content.modelFrame, "CENTER", 0, 52)
    tab1.content.unobtainable:SetText("*UNOBTAINABLE*")
    tab1.content.unobtainable:SetRotation(math.pi/4 )
    tab1.content.unobtainable:SetTextColor(.7, .4, .4)

    tab1.content.flavor = tab1.content:CreateFontString(nil, "ARTWORK", "NumberFont_Outline_Huge")
    tab1.content.flavor:SetPoint("TOPLEFT", tab1.content.modelFrame, "BOTTOMLEFT", 0, -20)
    tab1.content.flavor:SetPoint("RIGHT", tab1.content.modelFrame, "RIGHT")
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


    tab1.content.tradeable = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.tradeable:SetText("Tradeable")
    tab1.content.tradeable:SetPoint("TOPRIGHT", tab1.content.flavorbg, "BOTTOMRIGHT", -10, -5)
    tab1.content.tradeable:SetAlpha(.5)
    tab1.content.tradeableCheck = CreateFrame("Button", nil, tab1.content)
    tab1.content.tradeableCheck:SetNormalAtlas("auctionhouse-icon-checkmark")
    tab1.content.tradeableCheck:SetSize(16,16)
    tab1.content.tradeableCheck:SetPoint("TOPLEFT", tab1.content.tradeable, "TOPRIGHT", 2, 3);
    tab1.content.tradeableLine = tab1.content:CreateLine(nil, "OVERLAY", nil, 7)
    tab1.content.tradeableLine:SetColorTexture(.6, .4, .4, .7)
    tab1.content.tradeableLine:SetStartPoint("TOPLEFT", tab1.content.tradeable, -5, -6)
    tab1.content.tradeableLine:SetEndPoint("TOPRIGHT", tab1.content.tradeable, 5, -6)
    tab1.content.tradeableLine:SetThickness(1)
    
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

    tab1.content.possibleBreedsLbl = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.possibleBreedsLbl:SetPoint("TOPLEFT", tab1.content.collectedLbl, "BOTTOMLEFT", 0, -25)
    tab1.content.possibleBreedsLbl:SetText("Possible Breeds")
    tab1.content.possibleBreedsLbl:SetWidth(180)
    tab1.content.possibleBreedsLbl:SetJustifyH("CENTER")

    tab1.content.possibleBreedsTable = CreateFrame("Frame", nil, tab1.content, "ThinBorderTemplate")
    tab1.content.possibleBreedsTable:SetPoint("TOPLEFT", tab1.content.possibleBreedsLbl, "TOPLEFT", 0, 7)
    tab1.content.possibleBreedsTable:SetPoint("TOPRIGHT", tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 180, -5)
    tab1.content.possibleBreedsTable:SetAlpha(.25)
    
    tab1.content.healthIcon = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.healthIcon:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
    tab1.content.healthIcon:SetTexCoord(.5, 1, .5, 1)
    tab1.content.healthIcon:SetSize(16,16)
    tab1.content.healthIcon:SetPoint("TOPLEFT", tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 58, -8)
    tab1.content.powerIcon = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.powerIcon:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
    tab1.content.powerIcon:SetTexCoord(0, .5, 0, .5)
    tab1.content.powerIcon:SetSize(16,16)
    tab1.content.powerIcon:SetPoint("TOPLEFT", tab1.content.healthIcon, "TOPRIGHT", 25, 0)
    tab1.content.speedIcon = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.speedIcon:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
    tab1.content.speedIcon:SetTexCoord(0, .5, .5, 1)
    tab1.content.speedIcon:SetSize(16,16)
    tab1.content.speedIcon:SetPoint("TOPLEFT", tab1.content.powerIcon, "TOPRIGHT", 24, 0)
            
    tab1.content.cannotBattleLbl = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.cannotBattleLbl:SetPoint("TOPLEFT", tab1.content.possibleBreedsTable, "TOPRIGHT", 10, -30)
    tab1.content.cannotBattleLbl:SetText("This pet cannot battle")
    tab1.content.cannotBattleLbl:SetWidth(191)
    tab1.content.cannotBattleLbl:SetJustifyH("CENTER")
    
    tab1.content.abilitiesFrame = CreateFrame("FRAME", nil, tab1.content)
    tab1.content.abilitiesFrame:SetPoint("TOPLEFT", tab1.content.possibleBreedsTable, "TOPRIGHT", 15, 8)
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

    tab2.content.mapLbl = tab2.content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tab2.content.mapLbl:SetPoint("TOP", tab2.content, "TOP", 0, -10)
    tab2.content.mapLbl:SetPoint("CENTER", tab2.content)
    tab2.content.mapLbl:SetWidth(tab2.content:GetWidth() - 30)
    tab2.content.mapLbl:SetHeight(30)

    tab2.content.mapFrame = CreateFrame("Frame", nil, tab2.content)
    tab2.content.mapFrame:SetSize(350, 240)
    tab2.content.mapFrame:SetPoint("TOP", tab2.content.mapLbl, "BOTTOM",0, 0)
    tab2.content.mapFrame:SetPoint("LEFT", tab2.content, 20, 0)
	tab2.content.mapFrame:SetScript("OnMouseWheel", function(self, delta)
        local curScale = self:GetScale()
        if (delta>0) then
            if (curScale <4) then
                self:SetScale(curScale +1)
            end
        else
            if (curScale > 1) then
                self:SetScale(curScale - 1)
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
    else --4+lines (4288)
        f.tab1.content.flavorbgColor:SetPoint("BOTTOM", f.tab1.content.flavorbg, "BOTTOM",0, 12)
    end
  --tradeable
    if (pet.isTradeable == true) then
        f.tab1.content.tradeable:SetAlpha(1)
        f.tab1.content.tradeableLine:Hide()
        f.tab1.content.tradeableCheck:Show()
    else
        f.tab1.content.tradeable:SetAlpha(.4)
        f.tab1.content.tradeableLine:Show()
        f.tab1.content.tradeableCheck:Hide()
    end
  
  --model
    local sceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(pet.speciesID)
    f.tab1.content.model:TransitionToModelSceneID(sceneID)

    local actor = f.tab1.content.model:GetActorByTag("unwrapped")
    if actor then
        actor:SetModelByCreatureDisplayID(pet.displayID)
    end

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

  --posible breeds
    local statsForAbilities
    if (pet.possbileBreeds) then
        for breedIdx, breed in pairs(pet.possbileBreeds) do
            local breedFrame = DISPLAY_UTIL:AcquireListItemFrame(PAPetCard, f.tab1.content, true, breedIdx == 1)
            breedFrame:SetFrameStrata("DIALOG")
            breedFrame:SetPoint("LEFT", f.tab1.content.possibleBreedsLbl, "LEFT", 2, 0)
            breedFrame:SetPoint("RIGHT", f.tab1.content.possibleBreedsTable, "RIGHT")

            local stats = UTILITIES:GetMaxStatsForBreed(breed, pet.baseStats)
            breedFrame.stats = stats

            local breedName = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab1.content)
            breedName:SetText(breed)
            if (breedIdx == 1) then
                breedName:SetPoint("TOPRIGHT", f.tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 40, -31)
                f.tab1.content.SelectedBreed = breedFrame
                breedFrame:Click()
            else
                breedName:SetPoint("TOPRIGHT", f.tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 40, breedIdx * -20 - 10)
            end

            local health = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, f.tab1.content)
            health:SetText(stats[1])
            health:SetWidth(40)
            health:SetJustifyH("CENTER")
            health:SetPoint("TOPLEFT", breedName, "TOPRIGHT", 5, 0)
            local power = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, f.tab1.content)
            power:SetText(stats[2])
            power:SetWidth(35)
            power:SetJustifyH("CENTER")
            power:SetPoint("TOPLEFT", health, "TOPRIGHT", 5, 0)
            local speed = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, f.tab1.content)
            speed:SetText(stats[3])
            speed:SetWidth(35)
            speed:SetJustifyH("CENTER")
            speed:SetPoint("TOPLEFT", power, "TOPRIGHT", 5, 0)
            
            breedFrame:SetPoint("TOP", breedName, "TOP")
            breedFrame:SetPoint("BOTTOM", breedName, "BOTTOM")
            
            f.tab1.content.possibleBreedsTable:SetPoint("BOTTOMLEFT", breedName, "BOTTOMLEFT", 0, -10)
        end
    else
        f.tab1.content.possibleBreedsTable:SetPoint("BOTTOMLEFT", f.tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 0, -40)
    end

    if (not pet.isPassive) then
        f.tab1.content.cannotBattleLbl:Hide()
        f.tab1.content.abilitiesFrame:Show()
        local abilities = C_PetJournal.GetPetAbilityListTable(pet.speciesID)
        UpdateAbility(f.tab1.content.ability1, abilities[1].abilityID, pet.petType)
        UpdateAbility(f.tab1.content.ability2, abilities[2].abilityID, pet.petType)
        UpdateAbility(f.tab1.content.ability3, abilities[3].abilityID, pet.petType)
        UpdateAbility(f.tab1.content.ability4, abilities[4].abilityID, pet.petType)
        UpdateAbility(f.tab1.content.ability5, abilities[5].abilityID, pet.petType)
        UpdateAbility(f.tab1.content.ability6, abilities[6].abilityID, pet.petType)
    else
        f.tab1.content.cannotBattleLbl:Show()
        f.tab1.content.abilitiesFrame:Hide()
    end

    local actualContentHeight = f.tab1.content.possibleBreedsTable:GetBottom() - f.tab1.content:GetTop() - 75
    if (actualContentHeight < 550) then
        actualContentHeight = 550
    end
    f:SetHeight(actualContentHeight)

 --TAB 2
    local requestedLocation, showLocationList = GetLocation(pet, locationIdx)

    local mapFrame = f.tab2.content.mapFrame
    local lastElement

    if (showLocationList) then
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
                    local t = AcquireMapTileTexture(mapFrame)

                    t:SetSize(layerInfo.tileWidth*scale,layerInfo.tileHeight*scale)
                    t:SetPoint("TOPLEFT",adjustX + layerInfo.tileWidth * (x-1) * scale,-(y-1)*layerInfo.tileHeight * scale-adjustY)

                    t:SetTexture(textures[textureIdx])
                end
            end

            if (requestedLocation.coords) then
                for _, coord in pairs(requestedLocation.coords) do
                    local dot = AcquireMapPinTexture(mapFrame)
                    local type = coord.type and coord.type or requestedLocation.type
                    if type == "start" then
                        dot:SetAtlas("Islands-QuestBang")
                        dot:SetSize(20,20)
                    elseif type == "end" then
                        dot:SetAtlas("Islands-QuestTurnin")
                        dot:SetSize(20,20)
                    elseif type == "poi" then
                        dot:SetAtlas("VignetteKill")
                        dot:SetSize(12,12)
                    elseif type == "dot" then
                        dot:SetAtlas("Object")
                        dot:SetSize(12,12)
                    elseif type == "treasure" then
                        dot:SetAtlas("VignetteLoot")
                        dot:SetSize(12,12)
                    elseif type == "cave" then
                        dot:SetAtlas("CaveUnderground-Down")
                        dot:SetSize(14,14)
                    elseif type == "boss" then
                        dot:SetAtlas("ShipMission_DangerousSkull")
                        dot:SetSize(12,14)
                    elseif type == "kill" then
                        if(#requestedLocation.coords == 1) then
                            dot:SetAtlas("ShipMission_DangerousSkull")
                            dot:SetSize(12,14)
                        else
                            dot:SetAtlas("ComboPoints-ComboPoint")
                            dot:SetSize(10,10)
                        end
                    elseif pet.source == "Vendor" or type == "npc" then                        
                        dot:SetAtlas("GM-icon-headCount")
                        dot:SetSize(16,16)
                    else
                        dot:SetTexture("Interface\\Icons\\Tracking_WildPet")
                        dot:SetSize(6,6)
                    end
                    dot:SetPoint("TOPLEFT", mapFrame:GetWidth() * (coord[1]/100) - dot:GetWidth()/2, (mapFrame:GetHeight() * (coord[2]/100))*-1 + dot:GetHeight()/2)
                end
            end

            local mapName = BuildMapTitle(requestedLocation)
            f.tab2.content.mapLbl:SetText(mapName)
        end

        if (showLocationList) then
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
                    lastElement = loc
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
        else
            
        end
    else
        f.tab2.content.mapLbl:SetText(nil)
    end

    local bottomOfSourceSection
    if (pet.pois) then
        bottomOfSourceSection = GetPois(pet.pois, locationIdx)
    end

    if (pet.source == "Profession") then
        bottomOfSourceSection = GetProfessionText(pet.professionDetail, bottomOfSourceSection)
    elseif (pet.source == "Achievement" and pet.achievement) then
        bottomOfSourceSection = GetAchievementText(pet.achievement, bottomOfSourceSection)
    elseif pet.source == "World Event" or pet.source == "Promotion" or pet.source == "Trading Card Game" or pet.source == "Quest" or not bottomOfSourceSection then
        local sourceLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab2.content.scrollFrame.child)
        if (pet.source == "Quest" and pet.quest) then
            sourceLbl:SetText("Quest: ")
        else
            sourceLbl:SetText("Source: ")
        end
        
        if (bottomOfSourceSection) then
            sourceLbl:SetPoint("TOP", bottomOfSourceSection, "BOTTOM", 0, -10)
        else
            sourceLbl:SetPoint("TOP", f.tab2.content.scrollFrame.child, "TOP")
        end

        sourceLbl:SetPoint("LEFT", f.tab2.content.scrollFrame.child, "LEFT")
        local sourceVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, f.tab2.content.scrollFrame.child)
        sourceVal:SetPoint("TOPLEFT", sourceLbl, "TOPRIGHT", 5, 0)
        sourceVal:SetWordWrap(true)
        local source = pet.source
        if (pet.source == "World Event") then
            source = string.format("%s |cFFb3b3b3(%s)|r", pet.source, pet.eventName)
        elseif (pet.source == "Trading Card Game") then
            source = string.format("%s |cFFb3b3b3(%s)|r", pet.source, pet.tcg)
        elseif (pet.source == "Quest" and pet.quest) then
            source = GetLink(pet.quest)
        end
        sourceVal:SetText(source)
        bottomOfSourceSection = sourceVal
    end

   -- INSTRUCTIONS
   local bla = PETC.SHARED.Instr.synthForge
    local priorBottom = bottomOfSourceSection
    if (pet.acquisition) then
        f.tab2.content.instructionLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab2.content.scrollFrame.child)
        f.tab2.content.instructionLbl:SetPoint("LEFT", f.tab2.content.scrollFrame.child, "LEFT")
        f.tab2.content.instructionLbl:SetPoint("TOP", priorBottom, "BOTTOM", 0, -10)
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
    lineFrame:SetPoint("TOP", priorBottom, "BOTTOM", 0, -13)
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
        return false
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