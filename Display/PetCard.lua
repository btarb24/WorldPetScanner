---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local DISPLAY_UTIL = DISPLAY.Util
local UTILITIES = PETC.UTILITIES
local PETS = PETC.PETS

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

local function GetLineText(lineContent)
    if (#lineContent == 1) then
        return lineContent[1]
    end
    
    local links = {}
    for idx, entry in ipairs(lineContent) do
        if (idx > 1) then
            local type = strsub(entry, 1, 1)
            if (type == "i") then
                local id = tonumber(strsub(entry, 2))
                local link = select(2, GetItemInfo(id))
                if not link then
                    link = select(2, GetItemInfo(id))
                end
                table.insert(links, link)
            elseif(type == "n") then
                local detail = strsub(entry, 2)
                local id, name = strsplit(":", detail)
                local link = string.format("|Hnpc:%s|h|cffb3b3b3%s|r|h", id, name)
                table.insert(links, link)
            end
        end
    end

    return lineContent[1], links
end

local function GetQuestText(quests, selectedQuest)
    if (not selectedQuest) then
        selectedQuest = "1:1"
    end

    local selectedQuestIdx, questMapIdx = strsplit(":", selectedQuest)
    if (not questMapIdx) then
        questMapIdx = 1
    end

    local leftDock = PAPetCardTab2.content.sourceLbl
    local topDock = PAPetCardTab2.content.sourceLbl
    for idx, quest in ipairs(quests) do
        local completed = C_QuestLog.IsComplete(quest.id)

        local questState = DISPLAY_UTIL:AcquireButton(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        if completed or idx == 1 or idx ==2 then
            questState:SetNormalAtlas("auctionhouse-icon-checkmark")
            questState:SetSize(12,12)
            questState:SetPoint("TOP", topDock, "BOTTOM", 0, -5)
            questState:SetPoint("LEFT", leftDock, "LEFT", 6, 0)
        else
            questState:SetNormalAtlas("jailerstower-wayfinder-rewardcircle")
            questState:SetSize(14,14)
            questState:SetPoint("TOP", topDock, "BOTTOM", 0, -3)
            questState:SetPoint("LEFT", leftDock, "LEFT", 5, 0)
        end

        local questName = quest.name and quest.name or C_QuestLog.GetTitleForQuestID(quest.id)
        local questNameLbl = DISPLAY_UTIL:AcquireSubduedFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        questNameLbl:SetText(string.format("|cffffff00|Hquest:%d:-1:-1:-1:-1|h[%s]|h|r",quest.id, questName))
        questNameLbl:SetPoint("TOP", topDock, "BOTTOM", 0, -4)
        questNameLbl:SetPoint("LEFT", leftDock, "LEFT", 20, 0)
        topDock = questNameLbl

        if quest.maps then
            for mapIdx, map in ipairs(quest.maps) do
                local mapTipIcon = DISPLAY_UTIL:AcquireButton(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                if (map.type == "start") then
                    mapTipIcon:SetNormalAtlas("Islands-QuestBang")
                elseif (map.type == "end") then
                    mapTipIcon:SetNormalAtlas("Islands-QuestTurnin")
                end
                mapTipIcon:SetSize(16,16)
                mapTipIcon:SetPoint("TOP", topDock, "BOTTOM")
                mapTipIcon:SetPoint("LEFT", questState, "LEFT", 10, 0)

                local mapDescLbl
                if idx == tonumber(selectedQuestIdx) and mapIdx == tonumber(questMapIdx) then
                    mapDescLbl = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                else
                    mapDescLbl = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                    mapDescLbl.locationIndex = string.format("%d:%d", idx, mapIdx)
                    mapDescLbl:SetScript("OnMouseDown",
                        function(self)
                            DISPLAY.PetCard:Show(PAPetCard.pet, self.locationIndex)
                        end
                    )
                end
                mapDescLbl:SetText(map.desc)
                mapDescLbl:SetPoint("TOPLEFT", mapTipIcon, "TOPRIGHT", 2, -2)

                local zoneName = DISPLAY_UTIL:AcquireSmallerSubduedFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                zoneName:SetText(map.zone)
                zoneName:SetPoint("TOPLEFT", mapDescLbl, "TOPRIGHT", 3, -1)
                
                topDock = mapDescLbl
            end
        end

        PAPetCardTab2.content.sourceVal = topDock -- for docking of lower sections
    end

    return result;
end

local function GetNPCDropText(npcs, selectedNpcIdx)
    if (not selectedNpcIdx) then
        selectedNpcIdx = 1
    end

    local leftDock = PAPetCardTab2.content.sourceLbl
    local topDock = PAPetCardTab2.content.sourceLbl
    for idx, npc in ipairs(npcs) do
        local npcName
        if idx == selectedNpcIdx then
            npcName = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        else
            npcName = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
            npcName.locationIndex = idx    
            npcName:SetScript("OnMouseDown",
                function(self)
                    DISPLAY.PetCard:Show(PAPetCard.pet, self.locationIndex)
                end
            )
        end
        npcName:SetText(npc.name)

        npcName:SetPoint("LEFT", leftDock, "RIGHT", 5, 0)
        if idx == 1 then
            npcName:SetPoint("TOP", leftDock, "TOP", 0, 0)
        else
            npcName:SetPoint("TOP", topDock, "BOTTOM", 0, -5)
        end

        local detail = DISPLAY_UTIL:AcquireSmallerSubduedFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        detail:SetText(string.format(" %s%% %s", npc.chance, npc.locations[1].zone))
        detail:SetPoint("TOPLEFT", npcName, "TOPRIGHT", 0, -1)
        topDock = npcName
        PAPetCardTab2.content.sourceVal = npcName -- for docking of lower sections
    end

    return result;
end

local function GetVendorText(vendors, selectedVendorIdx)
    if (not selectedVendorIdx) then
        selectedVendorIdx = 1
    end

    local leftDock = PAPetCardTab2.content.sourceLbl
    local topDock = PAPetCardTab2.content.sourceLbl
    for idx, vendor in ipairs(vendors) do
        local vendorName
        if idx == selectedVendorIdx then
            vendorName = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        else
            vendorName = DISPLAY_UTIL:AcquireMultiValueFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
            vendorName.locationIndex = idx    
            vendorName:SetScript("OnMouseDown",
                function(self)
                    DISPLAY.PetCard:Show(PAPetCard.pet, self.locationIndex)
                end
            )
        end
        vendorName:SetText(vendor.name)

        vendorName:SetPoint("LEFT", leftDock, "RIGHT", 5, 0)
        if idx == 1 then
            vendorName:SetPoint("TOP", leftDock, "TOP", 0, 0)
        else
            vendorName:SetPoint("TOP", topDock, "BOTTOM", 0, -5)
        end
        topDock = vendorName

        local formerItem
        local money
        for currencyIdx, currency in ipairs(vendor.currencies) do
            local currencyVal
            if currency[1] == "gold" then
                money = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                money:SetPoint("TOPLEFT", vendorName, "TOPRIGHT", 3, 0)
                local moneyText = string.format("(%s)", C_CurrencyInfo.GetCoinTextureString(currency[2]*10000), 10)
                money:SetText(moneyText)
            else
                local item = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
                local itemLink = select(2, GetItemInfo(currency[1]))
                local currencyVal = string.format("%dx%s",currency[2], itemLink)
                item:SetText(currencyVal)
                if formerItem then
                    item:SetPoint("TOPLEFT", vendorName, "BOTTOMLEFT", 0, -3)
                    
                else
                    item:SetPoint("LEFT", vendorName, "LEFT", 15, 0)
                    item:SetPoint("TOP", vendorName, "BOTTOM", 15, -3)
                end
                formerItem = item
            end
        end

        local location = DISPLAY_UTIL:AcquireSmallerSubduedFont(PAPetCard, PAPetCardTab2.content.scrollFrame.child)
        location:SetText(vendor.locations[1].zone)
        if (money) then
            location:SetPoint("TOPLEFT", money, "TOPRIGHT", 3, -1)
        else
            location:SetPoint("TOPLEFT", vendorName, "TOPRIGHT", 3, -1)
        end

        PAPetCardTab2.content.sourceVal = vendorName -- for docking of lower sections
    end

    return result;
end

local function BuildMapTitle(location)    
    --quest
    if location.desc then
        return string.format("%s - %s", location.desc, location.zone)
    end

    local mapName = string.format("%s > %s", location.continent, location.zone)
    if (location.area) then
        mapName = string.format("%s > %s", mapName, location.area)
    end
    if (location.mapFloor) then
        mapName = string.format("%s [f. %d]", mapName, location.mapFloor)
    end

    return mapName
end

local function GetLocation(pet, locationIdx) --location, showLocList
    if (pet.source == "Quest") then
        if not locationIdx then
            locationIdx = "1:1"
        end

        local questIdx, mapTipIdx = strsplit(":", locationIdx)
        if not mapTipIdx then
            mapTipIdx = "1"
        end

        local quest = pet.quests[tonumber(questIdx)]
        if not quest.maps then
            return nil
        end

        local mapTip = quest.maps[tonumber(mapTipIdx)]
        return mapTip, false
    end

    if not locationIdx then
        locationIdx = 1
    end
    
    --specific npc source locations
    if (pet.source == "Vendor") then
        return pet.npcs[locationIdx].locations[1], false
    end

    --specific npc source locations
    if (pet.source == "Drop") then
        return pet.npcs[locationIdx].locations[1], false
    end

    --no location map
    if (not pet.locations) then
        return nil
    end

    --standard map locations    
    for _, loc in ipairs(pet.locations) do
        if loc.mapID == locationIdx then
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
    tab1.content.modelFrame.PopOut = CreateFrame("BUTTON", nil, tab1.content.modelFrame)
    tab1.content.modelFrame.PopOut:SetNormalAtlas("RedButton-Expand")
    tab1.content.modelFrame.PopOut:SetPushedAtlas("RedButton-Expand-Pressed")
    tab1.content.modelFrame.PopOut:SetHighlightAtlas("RedButton-Highlight")
    tab1.content.modelFrame.PopOut:SetPoint("TOPRIGHT", tab1.content.modelFrame, "TOPRIGHT")
    tab1.content.modelFrame.PopOut:SetSize(24,24)
    tab1.content.modelFrame.PopOut:SetScript("OnClick", function(self)
        tab1.content.model:SetParent(UIParent)
        tab1.content.model:ClearAllPoints()
        tab1.content.model:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
        tab1.content.model:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT")
        tab1.content.model:SetFrameStrata("FULLSCREEN")
        tab1.content.modelFrame.PopOutClose:Show()
    end)
    tab1.content.modelFrame.PopOutClose = CreateFrame("BUTTON", nill, UIParent, "BigRedExitButtonTemplate")
    tab1.content.modelFrame.PopOutClose:SetFrameStrata("FULLSCREEN_DIALOG")
    tab1.content.modelFrame.PopOutClose:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
    tab1.content.modelFrame.PopOutClose:Hide()
    tab1.content.modelFrame.PopOutClose:SetScript("OnClick", function(self)
        tab1.content.model:SetParent(tab1.content.modelFrame)
        tab1.content.model:ClearAllPoints()
        tab1.content.model:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 15, -15)
        tab1.content.model:SetPoint("BOTTOMRIGHT", tab1.content.modelFrame, "BOTTOMRIGHT", -15, 15)
        tab1.content.model:SetFrameStrata("DIALOG")
        tab1.content.modelFrame.PopOutClose:Hide()
    end)

    tab1.content.flavor = tab1.content:CreateFontString(nil, "ARTWORK", nil)
    tab1.content.flavor:SetPoint("TOPLEFT", tab1.content.modelFrame, "BOTTOMLEFT", 0, -20)
    tab1.content.flavor:SetPoint("RIGHT", tab1.content.modelFrame, "RIGHT")
    tab1.content.flavor:SetFont("Fonts\\skurri.ttf", 15, "OUTLINE, MONOCRHOME")
    tab1.content.flavor:SetWordWrap(true)
    --bastion-zone-ability-2

    tab1.content.tradeable = tab1.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab1.content.tradeable:SetText("Tradeable")
    tab1.content.tradeable:SetPoint("TOPRIGHT", tab1.content.flavor, "BOTTOMRIGHT", -10, -15)
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
    tab1.content.collectedLbl:SetPoint("TOPLEFT", tab1.content.flavor, "BOTTOMLEFT", 0, -15)
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
    tab1.content.abilitiesFrame:SetPoint("TOPLEFT", tab1.content.possibleBreedsTable, "TOPRIGHT", 10, 8)
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

    tab2.content.mapFrame = CreateFrame("Frame", nil, tab2.content)
    tab2.content.mapFrame:SetSize(350, 240)
    tab2.content.mapFrame:SetPoint("TOPLEFT",20,-22)
    
    tab2.content.mapLbl = tab2.content.mapFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tab2.content.mapLbl:SetPoint("BOTTOM", tab2.content.mapFrame, "TOP", 0, 0)
    tab2.content.mapLbl:SetPoint("CENTER", tab2.content.mapFrame)
    
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

    tab2.content.sourceLbl = tab2.content.scrollFrame.child:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tab2.content.sourceLbl:SetPoint("TOPLEFT", tab2.content.scrollFrame.child, "TOPLEFT")
    tab2.content.sourceLbl:SetText("SourceType:")

    local hyperlinkEnter = function(frame, link, text, region)
        GameTooltip:SetOwner(frame, "ANCHOR_NONE")
        GameTooltip:ClearLines()
        GameTooltip:SetPoint("BOTTOM",region,"TOP",0,6)

        local linkType = strsplit(":", link)
        GameTooltip:SetHyperlink(link)

        if GameTooltip:NumLines() == 0 then
            GameTooltip:SetText("Click for WowHead link")
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
        else
            ChatFrame_OnHyperlinkShow(self, link, text, button, region, left, bottom, width, height)
        end
    end

    tab2.content.scrollFrame:SetHyperlinksEnabled(true)
    tab2.content.scrollFrame:SetScript("OnHyperlinkEnter", hyperlinkEnter)
    tab2.content.scrollFrame:SetScript("OnHyperlinkLeave", GameTooltip_HideResetCursor)
    tab2.content.scrollFrame:SetScript("OnHyperlinkClick", hyperlinkClick)
    
    tab2.content.scrollFrame.child:SetHyperlinksEnabled(true)
    tab2.content.scrollFrame.child.propagateHyperlinksToParent = true
    tab2.content.scrollFrame.child:SetScript("OnHyperlinkEnter", hyperlinkEnter)
    tab2.content.scrollFrame.child:SetScript("OnHyperlinkLeave", GameTooltip_HideResetCursor)
    tab2.content.scrollFrame.child:SetScript("OnHyperlinkClick", hyperlinkClick)
end

local function UpdateWindow(pet, locationIdx)
    for _, pool in pairs(PAPetCard.pools) do
        pool:ReleaseAll()
    end

    local f = PAPetCard
    f.Title:SetText(pet.name)
    
 --TAB 1
    f.tab1.content.flavor:SetText(pet.flavor)
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
            local breedFrame = DISPLAY_UTIL:AcquireListItemFrame(PAPetCard, f.tab1.content, true)
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
        f.tab2.content.scrollFrame:SetPoint("TOPLEFT", f.tab2.content, "TOPLEFT", 20, -10);
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
                    dot:SetPoint("TOPLEFT", mapFrame:GetWidth() * (coord[1]/100), (mapFrame:GetHeight() * (coord[2]/100))*-1)
                    if requestedLocation.type == "start" then
                        dot:SetAtlas("Islands-QuestBang")           
                        dot:SetSize(20,20)             
                    elseif requestedLocation.type == "end" then
                        dot:SetAtlas("Islands-QuestTurnin")
                        dot:SetSize(20,20)
                    else
                        dot:SetTexture("Interface\\Icons\\Tracking_WildPet")
                        dot:SetSize(6,6)
                    end
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
    end

    if (pet.source == "Profession") then
        f.tab2.content.sourceLbl:SetText("Profession: ")
        f.tab2.content.sourceVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, f.tab2.content.scrollFrame.child)
        f.tab2.content.sourceVal:SetPoint("TOPLEFT", f.tab2.content.sourceLbl, "TOPRIGHT", 5, 0)
        local professionText = string.format("%s |cFFb3b3b3(%s)|r",pet.profession, pet.professionDetail)
        f.tab2.content.sourceVal:SetText(professionText)
    elseif(pet.source == "Vendor") then
        f.tab2.content.sourceLbl:SetText("Vendors: ")
        GetVendorText(pet.npcs, locationIdx)
    elseif(pet.source == "Drop") then
        f.tab2.content.sourceLbl:SetText("NPC drop: ")
        GetNPCDropText(pet.npcs, locationIdx)
    elseif(pet.source == "Quest") then
        f.tab2.content.sourceLbl:SetText("Quests: ")
        GetQuestText(pet.quests, locationIdx)
    else
        f.tab2.content.sourceLbl:SetText("Source: ")
        f.tab2.content.sourceVal = DISPLAY_UTIL:AcquireHighlightFont(PAPetCard, f.tab2.content.scrollFrame.child)
        f.tab2.content.sourceVal:SetPoint("TOPLEFT", f.tab2.content.sourceLbl, "TOPRIGHT", 5, 0)
        f.tab2.content.sourceVal:SetWordWrap(true)
        f.tab2.content.sourceVal:SetText(pet.source)
    end

    local priorBottom = f.tab2.content.sourceLbl
   -- INSTRUCTIONS
    if (pet.acquisition) then
        f.tab2.content.instructionLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab2.content.scrollFrame.child)
        f.tab2.content.instructionLbl:SetPoint("LEFT", f.tab2.content.sourceLbl, "LEFT")
        f.tab2.content.instructionLbl:SetPoint("TOP", f.tab2.content.sourceVal, "BOTTOM", 0, -10)
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
    lineFrame:SetPoint("TOP", priorBottom, "BOTTOM", 0, -10)
    lineFrame:SetHeight(1)

    local line = lineFrame:CreateLine()
    line:SetColorTexture(.3, .3, .3)
    line:SetThickness(1)
    line:SetStartPoint("TOPLEFT")
    line:SetEndPoint("TOPRIGHT")

   --EXTERNAL LINKS
    local externalLinksLbl = DISPLAY_UTIL:AcquireLabelFont(PAPetCard, f.tab2.content.scrollFrame.child)
    externalLinksLbl:SetPoint("TOP", line, "BOTTOM", 0, -10)
    externalLinksLbl:SetPoint("LEFT", f.tab2.content.sourceLbl, "LEFT")
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
end

function DISPLAY.PetCard:Show(pet, locationIdx)
    if (not PAPetCard) then
        CreateWindow()
    else
        PAPetCard.tab2.content.locationsFrame:SetSize(0,0)
        PAPetCard.tab2.content.locationsFrame:Hide()
    end

    UpdateWindow(pet, locationIdx)

    if (not PAPetCard.SelectedTab) then
        Tab_OnClick(PAPetCardTab1)
    end
    
    PAPetCard.pet = pet;
    PAPetCard:Show()
end