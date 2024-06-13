---@class WorldPetScanner
local WPS = WorldPetScanner
local DISPLAY = WPS.DISPLAY
local UTILITIES = WPS.UTILITIES
local TASKFINDER = WPS.TASKFINDER


DISPLAY.Constants = {
    zoneIndent = 20,
    vAlignAdjustmentAfterButton = 1,
    lineHeight = 12,
    lineSeparation = 4,
    expansionIndent = 20,
    columnSeparation = 10,
    marginAfterButton = 5,
    collapseButtonWidth = 16,
    collapseButtonHeight = 16,
    minWidth = 600,
    minHeight = 400
}

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())
    if (self:GetParent().content) then
        self:GetParent().content:Hide()
    end
    self:GetParent().content = self.content
    self.content:Show()
    WPSMainFrame:SetWidth(self.content.contentWidth)
    WPSMainFrame.SelectedTab = self
end

local function CollapseButton_OnClick(self, button)
    self.collapsed = not self.collapsed
    local heightAdjustment = self:GetParent().childrenHostFrame:GetHeight()
    local currentHeight = WPSMainFrameTab1.content.scrollFrame.child:GetHeight()
    if (self.collapsed) then
        self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
        self:GetParent().childrenHostFrame:Hide()
        self:GetParent().movingAnchor:ClearAllPoints()
        self:GetParent().movingAnchor:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
        
        WPSMainFrameTab1.content.scrollFrame.child:SetHeight(currentHeight-heightAdjustment)
    else
        self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
        self:GetParent().childrenHostFrame:Show()
        self:GetParent().movingAnchor:ClearAllPoints()
        self:GetParent().movingAnchor:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT")
        WPSMainFrameTab1.content.scrollFrame.child:SetHeight(currentHeight+heightAdjustment)
    end
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20);
	
	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end
	
	self:SetVerticalScroll(newValue);
end

local function UpdateHostWindow()
    if (WPSMainFrame.mode == "test") then
        WPSMainFrame.TitleNote:SetText("*test mode*")
    else
        WPSMainFrame.TitleNote:SetText("")
    end
end

function DISPLAY:BuildCollapseButton(parent)
    local collapseButton = CreateFrame("Button", nil, parent)
    collapseButton:SetSize(DISPLAY.Constants.collapseButtonWidth, DISPLAY.Constants.collapseButtonHeight)
    collapseButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    collapseButton:SetHitRectInsets(1, -4, -2, -2)
    collapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
    collapseButton:GetNormalTexture():SetSize(DISPLAY.Constants.collapseButtonWidth, DISPLAY.Constants.collapseButtonHeight)
    collapseButton:GetNormalTexture():SetPoint("LEFT", 3, 0)
    collapseButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
    collapseButton:GetHighlightTexture():SetSize(DISPLAY.Constants.collapseButtonWidth, DISPLAY.Constants.collapseButtonHeight)
    collapseButton:GetHighlightTexture():SetPoint("LEFT", 3, 0)
    collapseButton.collapsed = false
    collapseButton:SetScript("OnClick", CollapseButton_OnClick)
    return collapseButton
end

function DISPLAY:CreateHostWindow()
    if WPSMainFrame then
        WPSMainFrame:Hide()
        return WPSMainFrame
    end

    local mainFrame = CreateFrame("Frame", "WPSMainFrame", UIParent, "ButtonFrameBaseTemplate")
    mainFrame:Hide()
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:Lower()
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(DISPLAY.Constants.minWidth, DISPLAY.Constants.minHeight)
    mainFrame:SetSize(DISPLAY.Constants.minWidth,DISPLAY.Constants.minHeight)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
	mainFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);
    ButtonFrameTemplate_HideButtonBar(WPSMainFrame) -- maybe show the button bar with some toggle options in it??
    --only enable drag on the titlebar
    mainFrame.TitleContainer:GetParent():EnableMouse(true)
    mainFrame.TitleContainer:GetParent():RegisterForDrag("LeftButton")
    mainFrame.TitleContainer:GetParent():SetScript("OnDragStart",
        function(self)
            WPSMainFrame.moving = true
            WPSMainFrame:StartMoving()
        end
    )
    mainFrame.TitleContainer:GetParent():SetScript("OnDragStop",
        function(self)
            WPSMainFrame.moving = nil
            WPSMainFrame:StopMovingOrSizing()
        end
    )

    WPSMainFramePortrait:SetTexture("Interface\\Icons\\Inv_pet_maggot")
    WPSMainFrameTitleText:SetText("The Pet Advisor")
    mainFrame.TitleNote = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    mainFrame.TitleNote:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 40,10);

  --  WPSMainFrameInset:Hide()
    --WPSMainFrameBg:Hide()
    WPSMainFrameBg:SetTexture(nil)
    WPSMainFrameBg:SetColorTexture(.1, .1,.1,.8)
    WPSMainFrame.TopTileStreaks:Hide()
    
    local resizeButton = CreateFrame("Button", nil, mainFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnMouseDown", 
        function(self, button)
            WPSMainFrame:StartSizing("BOTTOMRIGHT")
            WPSMainFrame:SetUserPlaced(true)
        end)     
    resizeButton:SetScript("OnMouseUp", 
        function(self, button)
            WPSMainFrame:StopMovingOrSizing()
        end)


    WPSMainFrame.numTabs = 6
    local tab1 = CreateFrame("Button", "WPSMainFrameTab1", WPSMainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab1:SetID(1)
    tab1:SetText("Today's events")
    tab1:SetWidth(100)
    tab1.Text:SetWidth(100)
    tab1:ClearAllPoints()
    tab1:SetPoint("TOPLEFT", WPSMainFrame, "BOTTOMLEFT", 11, 2)
    tab1:SetScript("OnClick", Tab_OnClick)
    tab1.content = CreateFrame("Frame", nil, WPSMainFrame)
    tab1.content:Hide()
    tab1.content.contentWidth = DISPLAY.Constants.minWidth
	tab1.content:SetPoint("TOPLEFT", WPSMainFrame, "TOPLEFT", 4, -25);
	tab1.content:SetPoint("BOTTOMRIGHT", WPSMainFrame, "BOTTOMRIGHT", -3, 4);
    tab1.content.bg = tab1.content:CreateTexture(nil, "BACKGROUND")
    tab1.content.bg:SetAllPoints(true)
    tab1.content.bg:SetColorTexture(.2, 0,.6,.05)    
    tab1.content.spinner = CreateFrame("Frame", nil, tab1, "SpinnerTemplate")
    tab1.content.spinner:SetPoint("TOPLEFT", tab1.content, "TOPLEFT", 60, -4)
    tab1.content.spinner:SetSize(32,32)
    tab1.content.spinner:Hide()
    tab1.content.refreshButton = CreateFrame("Button", nil, tab1, "RefreshButtonTemplate")
    tab1.content.refreshButton:SetPoint("TOPLEFT", tab1.content, "TOPLEFT", 60, -4)
	tab1.content.refreshButton:SetScript("OnClick", 
        function() 
            TASKFINDER:RefreshTodaysEvents(WPSMainFrame.mode); 
            DISPLAY.TodaysEvents:Update();
        end
    );

    local tab2 = CreateFrame("Button", "WPSMainFrameTab2", WPSMainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab2:SetID(2)
    tab2:SetText("Capturable")
    tab2:SetWidth(100)
    tab2.Text:SetWidth(100)
    tab2:ClearAllPoints()
    tab2:SetPoint("TOPLEFT", tab1, "TOPRIGHT", 3, 0)
    tab2:SetScript("OnClick", Tab_OnClick)
    tab2.content = CreateFrame("Frame", nil, WPSMainFrame)
    tab2.content.contentWidth = DISPLAY.Constants.minWidth
    tab2.content:SetPoint("TOPLEFT", WPSMainFrame, "TOPLEFT", 50, 50)
    tab2.content:SetSize(DISPLAY.Constants.minWidth,DISPLAY.Constants.minHeight)
    tab2.content.bg = tab2.content:CreateTexture(nil, "BACKGROUND")
    tab2.content.bg:SetAllPoints(true)
    tab2.content.bg:SetColorTexture(0, .6,0,.1)
    tab2.content:Hide()
    
    local tab3 = CreateFrame("Button", "WPSMainFrameTab3", mainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab3:SetID(3)
    tab3:SetText("Loot drops")
    tab3:SetWidth(100)
    tab3.Text:SetWidth(100)
    tab3:ClearAllPoints()
    tab3:SetPoint("TOPLEFT", tab2, "TOPRIGHT", 3, 0)
    tab3:SetScript("OnClick", Tab_OnClick)
    tab3.content = CreateFrame("Frame", nil, mainFrame)
    tab3.content.contentWidth = DISPLAY.Constants.minWidth
    tab3.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab3.content:SetSize(DISPLAY.Constants.minWidth,DISPLAY.Constants.minHeight)
    tab3.content.bg = tab3.content:CreateTexture(nil, "BACKGROUND")
    tab3.content.bg:SetAllPoints(true)
    tab3.content.bg:SetColorTexture(0, 0,.6,.1)
    tab3.content:Hide()
    
    local tab4 = CreateFrame("Button", "WPSMainFrameTab4", mainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab4:SetID(4)
    tab4:SetText("Random suggestion")
    tab4:SetWidth(120)
    tab4.Text:SetWidth(120)
    tab4:ClearAllPoints()
    tab4:SetPoint("TOPLEFT", tab3, "TOPRIGHT", 3, 0)
    tab4:SetScript("OnClick", Tab_OnClick)
    tab4.content = CreateFrame("Frame", nil, mainFrame)
    tab4.content.contentWidth = DISPLAY.Constants.minWidth
    tab4.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab4.content:SetSize(DISPLAY.Constants.minWidth,DISPLAY.Constants.minHeight)
    tab4.content.bg = tab4.content:CreateTexture(nil, "BACKGROUND")
    tab4.content.bg:SetAllPoints(true)
    tab4.content.bg:SetColorTexture(0, 0,.6,.1)
    tab4.content:Hide()
    
    local tab5 = CreateFrame("Button", "WPSMainFrameTab5", mainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab5:SetID(5)
    tab5:SetText("Settings")
    tab5:SetWidth(80)
    tab5.Text:SetWidth(80)
    tab5:ClearAllPoints()
    tab5:SetPoint("TOPRIGHT", WPSMainFrame, "BOTTOMRIGHT", -11, 2)
    tab5:SetScript("OnClick", Tab_OnClick)
    tab5.content = CreateFrame("Frame", nil, mainFrame)
    tab5.content.contentWidth = DISPLAY.Constants.minWidth
    tab5.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab5.content:SetSize(DISPLAY.Constants.minWidth,DISPLAY.Constants.minHeight)
    tab5.content.bg = tab5.content:CreateTexture(nil, "BACKGROUND")
    tab5.content.bg:SetAllPoints(true)
    tab5.content.bg:SetColorTexture(0, 0,.6,.1)
    tab5.content:Hide()

    local tab6 = CreateFrame("Button", "WPSMainFrameTab6", mainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab6:SetID(6)
    tab6:SetText("Help")
    tab6:SetWidth(80)
    tab6.Text:SetWidth(80)
    tab6:ClearAllPoints()
    tab6:SetPoint("TOPRIGHT", tab5, "TOPLEFT", -3, 0)
    tab6:SetScript("OnClick", Tab_OnClick)
    tab6.content = CreateFrame("Frame", nil, mainFrame)
    tab6.content.contentWidth = DISPLAY.Constants.minWidth
    tab6.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab6.content:SetSize(DISPLAY.Constants.minWidth,DISPLAY.Constants.minHeight)
    tab6.content.bg = tab6.content:CreateTexture(nil, "BACKGROUND")
    tab6.content.bg:SetAllPoints(true)
    tab6.content.bg:SetColorTexture(0, 0,.6,.1)
    tab6.content:Hide()

    mainFrame.content = tab1.content

    return mainFrame
end

function DISPLAY.Main:ShowWindow(mode)
    if (not WPSMainFrame) then 
        CreateHostWindow()
    end
    
    WPSMainFrame.mode = mode
    UpdateHostWindow()

    DISPLAY.TodaysEvents:Update()

    if (not WPSMainFrame.SelectedTab) then
        Tab_OnClick(WPSMainFrameTab1)
    end

    WPSMainFrame:Show()

    --Hack to make it so the window doesn't load empty
    local currentHeight = WPSMainFrameTab1.content.scrollFrame.child:GetHeight()
end