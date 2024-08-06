local file="DisplayUtil"

local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local DISPLAY_UTIL = PETC.DISPLAY.Util

DISPLAY_UTIL.Constants = {
    collapseButtonWidth = 16,
    collapseButtonHeight = 16
}

local function AddToPoolOwner(poolOwner, pool)
    if (not poolOwner.pools) then
        poolOwner.pools = {}
    end

    table.insert(poolOwner.pools, pool)
end

local function CollapseButton_OnClick(self)
    self.collapsed = not self.collapsed
    local expansionFrame = self:GetParent()
    local scrollFrameChild = expansionFrame:GetParent()
    local heightAdjustment = expansionFrame.childrenHostFrame:GetHeight()
    local currentHeight = scrollFrameChild:GetHeight()
    if (self.collapsed) then
        self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
        expansionFrame.childrenHostFrame:Hide()
        expansionFrame.movingAnchor:ClearAllPoints()
        expansionFrame.movingAnchor:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
        
        scrollFrameChild:SetHeight(currentHeight-heightAdjustment)
    else
        self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
        expansionFrame.childrenHostFrame:Show()
        expansionFrame.movingAnchor:ClearAllPoints()
        expansionFrame.movingAnchor:SetPoint("TOPLEFT", expansionFrame, "BOTTOMLEFT")
        scrollFrameChild:SetHeight(currentHeight+heightAdjustment)
    end
end

local function BuildCollapseButton(collapseButton)
    collapseButton:SetSize(DISPLAY_UTIL.Constants.collapseButtonWidth, DISPLAY_UTIL.Constants.collapseButtonHeight)
    collapseButton:SetHitRectInsets(1, -4, -2, -2)
    collapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
    collapseButton:GetNormalTexture():SetSize(DISPLAY_UTIL.Constants.collapseButtonWidth, DISPLAY_UTIL.Constants.collapseButtonHeight)
    collapseButton:GetNormalTexture():SetPoint("LEFT", 3, 0)
    collapseButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
    collapseButton:GetHighlightTexture():SetSize(DISPLAY_UTIL.Constants.collapseButtonWidth, DISPLAY_UTIL.Constants.collapseButtonHeight)
    collapseButton:GetHighlightTexture():SetPoint("LEFT", 3, 0)
    collapseButton.collapsed = false
    collapseButton:SetScript("OnClick", CollapseButton_OnClick)
    return collapseButton
end

function DISPLAY_UTIL:ReleasePools(poolOwner)
    for _, pool in pairs(poolOwner.pools) do
        pool:ReleaseAll()
    end
end

function DISPLAY_UTIL:AcquireTexture(poolOwner, controlParent)
    if (not controlParent.texturePool) then
        controlParent.texturePool = CreateTexturePool(controlParent, "OVERLAY")
        AddToPoolOwner(poolOwner, controlParent.texturePool)
    end

    local t = controlParent.texturePool:Acquire()
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetTexture(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireMapTileTexture(poolOwner, controlParent)
    if (not controlParent.mapTilePool) then
        controlParent.mapTilePool = CreateTexturePool(controlParent, "BACKGROUND")
        AddToPoolOwner(poolOwner, controlParent.mapTilePool)
    end

    local t = controlParent.mapTilePool:Acquire()
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetTexture(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireMapPinTexture(poolOwner, controlParent)
    if (not controlParent.mapPinPool) then
        controlParent.mapPinPool = CreateTexturePool(controlParent, "OVERLAY")
        AddToPoolOwner(poolOwner, controlParent.mapPinPool)
    end

    local t = controlParent.mapPinPool:Acquire()
    t:SetIgnoreParentScale(true)
    t:SetTexture(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireLabelFont(poolOwner, controlParent)
    if (not controlParent.labelFontPool) then
        controlParent.labelFontPool = CreateFontStringPool(controlParent, "OVERLAY", nil, "GameFontNormal")
        AddToPoolOwner(poolOwner, controlParent.labelFontPool)
    end

    local t = controlParent.labelFontPool:Acquire()
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetText(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquirePetLinkFont(poolOwner, controlParent, petLink)
    if (not controlParent.petLinkFontPool) then
        controlParent.petLinkFontPool = CreateFontStringPool(controlParent, "OVERLAY", nil, "GameFontHighlight")
        AddToPoolOwner(poolOwner, controlParent.petLinkFontPool)
    end

    local t = controlParent.petLinkFontPool:Acquire()
    t:SetTextColor(.4, .74, 1)

    if (petLink) then
        t.pet = petLink
        t:SetScript("OnEnter",
        function(self)
            self:SetTextColor(.5, .85, 1)
            self:SetShadowColor(1,1,1, .4)
        end
        )
        t:SetScript("OnLeave",
            function(self)
                self:SetTextColor(.4, .74, 1)
                self:SetShadowColor(0,0,0,0)
            end
        )
        t:SetScript("OnMouseDown",
            function(self)
                DISPLAY.PetCard:Show(self.pet)
            end
        )
    else
        t.pet = nil
        t:SetScript("OnEnter", nil)
        t:SetScript("OnLeave", nil)
        t:SetScript("OnMouseDown", nil)
    end
         

    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireHighlightFont(poolOwner, controlParent)
    if (not controlParent.highlightFontPool) then
        controlParent.highlightFontPool = CreateFontStringPool(controlParent, "OVERLAY", nil, "GameFontHighlight")
        AddToPoolOwner(poolOwner, controlParent.highlightFontPool)
    end

    local t = controlParent.highlightFontPool:Acquire()
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetText(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireSubduedFont(poolOwner, controlParent)
    if (not controlParent.subduedFontPool) then
        controlParent.subduedFontPool = CreateFontStringPool(controlParent, "OVERLAY", nil, "GameFontHighlight")
        AddToPoolOwner(poolOwner, controlParent.subduedFontPool)
    end

    local t = controlParent.subduedFontPool:Acquire()
    t:SetTextColor(.7, .7, .7)
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetText(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireSmallerSubduedFont(poolOwner, controlParent)
    if (not controlParent.smallerSubduedFontPool) then
        controlParent.smallerSubduedFontPool = CreateFontStringPool(controlParent, "OVERLAY", nil, "AchievementFont_Small")
        AddToPoolOwner(poolOwner, controlParent.smallerSubduedFontPool)
    end

    local t = controlParent.smallerSubduedFontPool:Acquire()
    t:SetTextColor(.7, .7, .7)
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetText(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireSmallerHighlightFont(poolOwner, controlParent)
    if (not controlParent.smallerHighlightFontPool) then
        controlParent.smallerHighlightFontPool = CreateFontStringPool(controlParent, "OVERLAY", nil, "GameFontHighlight")
        AddToPoolOwner(poolOwner, controlParent.smallerHighlightFontPool)
    end

    local t = controlParent.smallerHighlightFontPool:Acquire()
    if (not t:GetText()) then
        local fontFile, fontHeight, fontFlags = t:GetFont()
        t:SetFont(fontFile, fontHeight-2, fontFlags)
    end
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetText(nil)
    t:Show()
    return t
end

function DISPLAY_UTIL:AcquireMultiValueFont(poolOwner, controlParent)    
    if (not controlParent.multiValueFontPool) then
        controlParent.multiValueFontPool = CreateFontStringPool(controlParent, "OVERLAY", nil, "GameFontHighlight")
        AddToPoolOwner(poolOwner, controlParent.multiValueFontPool)
    end

    local t = controlParent.multiValueFontPool:Acquire()
    t:SetAlpha(.7)
    t:SetScript("OnEnter",
        function(self)
            self:SetAlpha(1)
            self:SetShadowColor(1,1,1, .4)
        end
    )
    t:SetScript("OnLeave",
        function(self)
            self:SetAlpha(.7)
            self:SetShadowColor(0,0,0, 0)
        end
    )
    t:SetText(nil)
    t:Show()    
    return t
end

function DISPLAY_UTIL:AcquireFrame(poolOwner, controlParent)    
    if (not controlParent.framePool) then
        controlParent.framePool = CreateFramePool("FRAME", controlParent)
        AddToPoolOwner(poolOwner, controlParent.framePool)
    end

    local t = controlParent.framePool:Acquire()
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetScript("OnMouseDown", nil)
    t:Show()    
    return t
end

function DISPLAY_UTIL:AcquireButton(poolOwner, controlParent)    
    if (not controlParent.buttonPool) then
        controlParent.buttonPool = CreateFramePool("BUTTON", controlParent)
        AddToPoolOwner(poolOwner, controlParent.buttonPool)
    end

    local t = controlParent.buttonPool:Acquire()
    t:SetScript("OnEnter", nil)
    t:SetScript("OnLeave", nil)
    t:SetScript("OnMouseDown", nil)
    t:Show()    
    return t
end

function DISPLAY_UTIL:AcquireListItemFrame(poolOwner, controlParent, selectable, selected)
    if (not controlParent.framePool) then
        controlParent.framePool = CreateFramePool("BUTTON", controlParent)
        AddToPoolOwner(poolOwner, controlParent.framePool)
    end

    local t = controlParent.framePool:Acquire()
    t:Enable()
    local texture = t:CreateTexture(nil, "BACKGROUND")
    texture:SetColorTexture(1, .82, 0) --gameFontNormal Color
    texture:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, .3), CreateColor(1, 1, 1, .01))
    t:SetNormalTexture(texture)
    if not selected then
        t:GetNormalTexture():Hide()
    end
    t:Show()
    t:SetFrameStrata("LOW")

    t:SetScript("OnEnter", function(self)
        if (self:GetParent().SelectedBreed ~= self) then
            self:GetNormalTexture():SetDesaturated(true)
            self:GetNormalTexture():Show()
        end
    end)
    t:SetScript("OnLeave", function(self)
        self:GetNormalTexture():SetDesaturated(false)
        if self:GetParent().SelectedBreed ~= self then
            self:GetNormalTexture():Hide()
        end
    end)

    if selectable then
        t:SetScript("OnClick", function(self)
            if (self:GetParent().SelectedBreed == self) then
                return
            end
            self:GetParent().SelectedBreed:GetNormalTexture():Hide()
            self:GetParent().SelectedBreed = self
            self:GetNormalTexture():Show()
            self:GetNormalTexture():SetDesaturated(false)
        end)
    else
        t:SetScript("OnClick", nil)
    end
    return t
end

function DISPLAY_UTIL:AcquireExpansionFrame(poolOwner, controlParent, name, headerDescription)
    if (not controlParent.expansionFramesPool) then
        controlParent.expansionFramesPool = CreateFramePool("FRAME", controlParent)
        AddToPoolOwner(poolOwner, controlParent.expansionFramesPool)
    end

    local expansionFrame = controlParent.expansionFramesPool:Acquire()
    expansionFrame:ClearAllPoints()

    if (not expansionFrame.header) then
        expansionFrame.collapseButton = CreateFrame("Button", nil, expansionFrame)
        expansionFrame.collapseButton:SetPoint("TOPLEFT", expansionFrame, "TOPLEFT", 0, 0)
        BuildCollapseButton(expansionFrame.collapseButton)

        expansionFrame.header = expansionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        expansionFrame.header:SetPoint("TOPLEFT", expansionFrame.collapseButton, "TOPRIGHT", DISPLAY.Constants.marginAfterButton, -DISPLAY.Constants.vAlignAdjustmentAfterButton);
        
        expansionFrame.childrenHostFrame = CreateFrame("Frame", nil, expansionFrame)
        expansionFrame.childrenHostFrame:SetPoint("TOPLEFT", expansionFrame.header, "BOTTOMLEFT", DISPLAY.Constants.zoneIndent,0);
        
        expansionFrame.movingAnchor = CreateFrame("Frame", nil, expansionFrame)
        expansionFrame.movingAnchor:SetSize(1, 1)
    end

    expansionFrame.header:SetText(string.format("|cff33ff33%s|r", name))
    expansionFrame.childrenHostFrame:SetSize(1,1)
    expansionFrame.movingAnchor:ClearAllPoints()
    expansionFrame.movingAnchor:SetPoint("TOPLEFT", expansionFrame, "BOTTOMLEFT")

    expansionFrame:Show()
    return expansionFrame
end

function DISPLAY_UTIL:Reset(poolOwner)
    for _, pool in pairs(poolOwner.pools) do
        pool:ReleaseAll()
    end
end