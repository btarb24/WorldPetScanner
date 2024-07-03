---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
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
        PAPetCard.SelectedTab.Text:SetPoint("LEFT", PAPetCard.SelectedTab, "LEFT", -30, 2)
    end
    PAPetCard.SelectedTab = self    
    self.Text:SetPoint("LEFT", self, "LEFT", -36, 2)
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
local function AcquireLabelFont(parent)    
    if (not parent.labelFontPool) then
        parent.labelFontPool = CreateFontStringPool(parent, "OVERLAY", nil, "GameFontNormal")
        table.insert(PAPetCard.pools, parent.labelFontPool)
    end

    local t = parent.labelFontPool:Acquire()
    t:Show()
    return t
end
local function AcquireMultiValueFont(parent)    
    if (not parent.multiValueFontPool) then
        parent.multiValueFontPool = CreateFontStringPool(parent, "OVERLAY", nil, "GameFontHighlight")
        table.insert(PAPetCard.pools, parent.multiValueFontPool)
    end

    local t = parent.multiValueFontPool:Acquire()
    t:SetTextColor(.7, .7, .7)
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetScript("OnMouseDown", nil)
    t:Show()    
    return t
end
local function AcquireValueFont(parent)    
    if (not parent.valueFontPool) then
        parent.valueFontPool = CreateFontStringPool(parent, "OVERLAY", nil, "GameFontHighlight")
        table.insert(PAPetCard.pools, parent.valueFontPool)
    end

    local t = parent.valueFontPool:Acquire()
    t:Show()    
    return t
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
    tab.Text:SetPoint("LEFT", tab, "LEFT", -30, 3)
    local AnimationGroup = tab.Text:CreateAnimationGroup();
    local Rotation = AnimationGroup:CreateAnimation("Rotation");
    Rotation:SetDegrees(90);
    Rotation:SetDuration(0);
    Rotation:SetEndDelay(604800);
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
    tab1:SetPoint("TOPRIGHT", PAPetCard, "TOPLEFT", 4, -45)

    local tab2 = CreateTab(2, "Acquisition")
    f.tab2 = tab2
    tab2:SetPoint("TOPRIGHT", tab1, "BOTTOMRIGHT", 0, -10)

    tab1.content.modelFrame = CreateFrame("FRAME", nil, tab1.content, "InsetFrameTemplate4")
    tab1.content.modelFrame:SetPoint("TOP", tab1.content, "TOP", 0, -25)
    tab1.content.modelFrame:SetPoint("LEFT", tab1.content, "LEFT", 30, 0)
    tab1.content.modelFrame:SetPoint("RIGHT", tab1.content, "RIGHT", -30, 0)
    tab1.content.modelFrame:SetHeight(200)
    tab1.content.modelFrame.bg = tab1.content.modelFrame:CreateTexture(nil, "BACKGROUND")
    tab1.content.modelFrame.bg:SetAllPoints(true)
    tab1.content.modelFrame.bg:SetColorTexture(0,0,0)
    tab1.content.model = CreateFrame("PlayerModel", nil, tab1.content.modelFrame)
    tab1.content.model:SetPoint("TOPLEFT", tab1.content.modelFrame, "TOPLEFT", 15, -15)
    tab1.content.model:SetPoint("BOTTOMRIGHT", tab1.content.modelFrame, "BOTTOMRIGHT", -15, 15)

    tab1.content.flavor = tab1.content:CreateFontString(nil, "ARTWORK", nil)
    tab1.content.flavor:SetPoint("TOPLEFT", tab1.content.modelFrame, "BOTTOMLEFT", 0, -20)
    tab1.content.flavor:SetPoint("RIGHT", tab1.content.modelFrame, "RIGHT")
    tab1.content.flavor:SetFont("Fonts\\skurri.ttf", 15, nil)
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

--PetJournal_GetPetAbilityHyperlink(self.abilityID, self.petID)
--PetJournal_ShowAbilityTooltip(self, self.abilityID, self.speciesID, self.petID, self.additionalText);
--PetJournal_HideAbilityTooltip(self);
    tab2.content.mapFrame = CreateFrame("Frame", nil, tab2.content)
    tab2.content.mapFrame:SetSize(350, 240)
    tab2.content.mapFrame:SetPoint("TOPLEFT",20,-40)
    
    tab2.content.mapLbl = tab2.content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    tab2.content.mapLbl:SetPoint("BOTTOM", tab2.content.mapFrame, "TOP", 0, 0)
    tab2.content.mapLbl:SetPoint("CENTER", tab2.content.mapFrame)
    
    tab2.content.locationsFrame = CreateFrame("Frame", nil, tab2.content)
    tab2.content.locationsFrame:SetPoint("TOPLEFT", tab2.content.mapFrame, "BOTTOMLEFT")
    
    tab2.content.scrollFrame = CreateFrame("ScrollFrame", nil, tab2.content, "UIPanelScrollFrameTemplate")
    tab2.content.scrollFrame.expansionFramesPool = {}
    tab2.content.scrollFrame:SetClipsChildren(true)
    tab2.content.scrollFrame:SetPoint("TOPLEFT", tab2.content.locationsFrame, "BOTTOMLEFT", 0, -10);
    tab2.content.scrollFrame:SetPoint("BOTTOMRIGHT", tab2.content, "BOTTOMRIGHT",0,4);
    tab2.content.scrollFrame.ScrollBar:ClearAllPoints();
    tab2.content.scrollFrame.ScrollBar:SetPoint("TOPLEFT", tab2.content.scrollFrame, "TOPRIGHT", -30, -18);
    tab2.content.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", tab2.content.scrollFrame, "BOTTOMRIGHT", 0, 24);
    tab2.content.scrollFrame.child = CreateFrame("Frame", nil, tab2.content.scrollFrame)
    tab2.content.scrollFrame:SetScrollChild(tab2.content.scrollFrame.child)
end

local function GetFirstMapWithCoords(pet)
    for idx, loc in ipairs(pet.locations) do
        if (loc.mapID and loc.coords) then
            return idx
        end
    end
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

local function UpdateWindow(pet, locationIdx)
    for _, pool in pairs(PAPetCard.pools) do
        pool:ReleaseAll()
    end

    local f = PAPetCard
    f.Title:SetText(pet.name)

 --TAB 1
    f.tab1.content.flavor:SetText(pet.tooltip)
  --tradeable
    if (pet.tradeable == true) then
        f.tab1.content.tradeable:SetAlpha(1)
        f.tab1.content.tradeableLine:Hide()
        f.tab1.content.tradeableCheck:Show()
    else
        f.tab1.content.tradeable:SetAlpha(.4)
        f.tab1.content.tradeableLine:Show()
        f.tab1.content.tradeableCheck:Hide()
    end

  --collected
    f.tab1.content.model:SetDisplayInfo(pet.displayID)
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
    if (pet.possbileBreeds) then
        for breedIdx, breed in pairs(pet.possbileBreeds) do
            local stats = UTILITIES:GetMaxStatsForBreed(breed, pet.baseStats)
            local breedName = AcquireLabelFont(f.tab1.content)
            breedName:SetText(breed)
            if (breedIdx == 1) then
                breedName:SetPoint("TOPRIGHT", f.tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 40, -30)
            else
                breedName:SetPoint("TOPRIGHT", f.tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 40, breedIdx * -20 - 10)
            end

            local health = AcquireValueFont(f.tab1.content)
            health:SetText(stats[1])
            health:SetWidth(40)
            health:SetJustifyH("CENTER")
            health:SetPoint("TOPLEFT", breedName, "TOPRIGHT", 5, 0)
            local power = AcquireValueFont(f.tab1.content)
            power:SetText(stats[2])
            power:SetWidth(35)
            power:SetJustifyH("CENTER")
            power:SetPoint("TOPLEFT", health, "TOPRIGHT", 5, 0)
            local speed = AcquireValueFont(f.tab1.content)
            speed:SetText(stats[3])
            speed:SetWidth(35)
            speed:SetJustifyH("CENTER")
            speed:SetPoint("TOPLEFT", power, "TOPRIGHT", 5, 0)
            
            f.tab1.content.possibleBreedsTable:SetPoint("BOTTOMLEFT", breedName, "BOTTOMLEFT", 0, -10)
        end
    else
        f.tab1.content.possibleBreedsTable:SetPoint("BOTTOMLEFT", f.tab1.content.possibleBreedsLbl, "BOTTOMLEFT", 0, -40)
    end

    if (not pet.isPassive) then
        f.tab1.content.cannotBattleLbl:Hide()
        f.tab1.content.abilitiesFrame:Show()
        local abilities = C_PetJournal.GetPetAbilityListTable(pet.speciesID)
        local _, icon = C_PetJournal.GetPetAbilityInfo(abilities[1].abilityID)
        f.tab1.content.ability1:SetTexture(icon)
        local _, icon = C_PetJournal.GetPetAbilityInfo(abilities[2].abilityID)
        f.tab1.content.ability2:SetTexture(icon)
        local _, icon = C_PetJournal.GetPetAbilityInfo(abilities[3].abilityID)
        f.tab1.content.ability3:SetTexture(icon)
        local _, icon = C_PetJournal.GetPetAbilityInfo(abilities[4].abilityID)
        f.tab1.content.ability4:SetTexture(icon)
        local _, icon = C_PetJournal.GetPetAbilityInfo(abilities[5].abilityID)
        f.tab1.content.ability5:SetTexture(icon)
        local _, icon = C_PetJournal.GetPetAbilityInfo(abilities[6].abilityID)
        f.tab1.content.ability6:SetTexture(icon)
    else
        f.tab1.content.cannotBattleLbl:Show()
        f.tab1.content.abilitiesFrame:Hide()
    end

    if (f.SelectedTab == f.tab1 or not f.SelectedTab) then
        f:SetHeight(f.tab1.content.possibleBreedsTable:GetBottom() - f.tab1.content:GetTop() - 75)
    end

   --TAB 2
    if not locationIdx then 
        locationIdx = GetFirstMapWithCoords(pet)
    end

    local mapFrame = f.tab2.content.mapFrame
    local lastElement
    local showLocations = pet.locations and pet.locations[locationIdx] and pet.locations[locationIdx].mapID and pet.locations[locationIdx].coords
    if (showLocations) then
        local mapID = pet.locations[locationIdx].mapID
        local layers = C_Map.GetMapArtLayers(mapID)

        if layers and layers[1] then
            local layerInfo = layers[1]

            local textures = C_Map.GetMapArtLayerTextures(mapID,1)

            local widthCount = ceil(layerInfo.layerWidth/layerInfo.tileWidth)
            local heightCount = ceil(layerInfo.layerHeight/layerInfo.tileHeight)

            local xScale = mapFrame:GetWidth() / layerInfo.layerWidth
            local yScale = mapFrame:GetHeight() / layerInfo.layerHeight
            scale = math.min(xScale, yScale)

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

            for _, coord in pairs(pet.locations[locationIdx].coords) do
                local dot = AcquireMapPinTexture(mapFrame)
                dot:SetSize(6,6)
                dot:SetPoint("TOPLEFT", mapFrame:GetWidth() * (coord[1]/100), (mapFrame:GetHeight() * (coord[2]/100))*-1)
                dot:SetTexture("Interface\\Icons\\Tracking_WildPet")
            end

            f.tab2.content.mapLbl:SetText(C_Map.GetMapInfo(pet.locations[locationIdx].mapID).name)
        end

        if (pet.locations) then
            local locationsFrame = f.tab2.content.locationsFrame
            local locationLbl = AcquireLabelFont(locationsFrame)
            locationLbl:SetText("Locations:  ")
            locationLbl:SetPoint("TOPLEFT", locationsFrame, "TOPLEFT")
            local locationLineWidth = locationLbl:GetWidth()
            local priorLoc
            local line = 0
            for locIdx, location in ipairs(pet.locations) do        
                if (location.mapID and location.coords) then
                    local loc
                    if (locIdx == locationIdx) then
                        loc = AcquireValueFont(locationsFrame)
                    else
                        loc = AcquireMultiValueFont(locationsFrame)
                    end
                    loc.locationIndex = locIdx
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
                        local comma = AcquireValueFont(locationsFrame)
                        comma:SetText(", ")
                        comma:SetPoint("TOPLEFT", priorLoc, "TOPRIGHT")
                        loc:SetPoint("TOPLEFT", comma, "TOPRIGHT")
                        locationLineWidth = locationLineWidth + comma:GetWidth()
                    end
                    priorLoc = loc
                    lastElement = loc
                    if (locIdx ~= locationIdx) then
                        loc:SetScript("OnEnter",
                            function(self)
                                self:SetTextColor(1,1,1)
                                self:SetShadowColor(1,1,1, .4)
                            end
                        )
                        loc:SetScript("OnLeave",
                            function(self)
                                self:SetTextColor(.7, .7, .7)
                                self:SetShadowColor(0,0,0,0)
                            end
                        )
                        loc:SetScript("OnMouseDown",
                            function(self)
                                DISPLAY.PetCard:Show(self.pet, self.locationIndex)
                            end
                        )
                    end
                end
            end
            print ((line+1) * locationLbl:GetHeight())
            locationsFrame:SetSize(DISPLAY.PetCard.winWidth, (line+1) * locationLbl:GetHeight())
            locationsFrame:Show()
        end
    end

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

    PAPetCard:Show()
end