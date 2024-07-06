---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local UTILITIES = PETC.UTILITIES
local TASKFINDER = PETC.TASKFINDER


DISPLAY.Constants = {
    zoneIndent = 20,
    vAlignAdjustmentAfterButton = 1,
    lineHeight = 12,
    lineSeparation = 4,
    expansionIndent = 20,
    columnSeparation = 10,
    marginAfterButton = 5,
    minWidth = 800,
    minHeight = 400
}

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())
    if (self:GetParent().content) then
        self:GetParent().content:Hide()
    end

    self:GetParent().content = self.content
    self.content:Show()
    PAMainFrame:SetWidth(self.content.contentWidth)
    PAMainFrame.SelectedTab = self
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
    if (PAMainFrame.mode == "test") then
        PAMainFrame.TitleNote:SetText("*test mode*")
    else
        PAMainFrame.TitleNote:SetText("")
    end
end

local function CreateTab(idNum, name, tabButtonWidth)
    if not tabButtonWidth then
        tabButtonWidth = 100
    end

    local tab = CreateFrame("Button", "PAMainFrameTab"..idNum, PAMainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab:SetID(idNum)
    tab:SetText(name)
    tab:SetWidth(tabButtonWidth)
    tab.Text:SetWidth(tabButtonWidth)
    tab:ClearAllPoints()
    tab:SetScript("OnClick", Tab_OnClick)
    tab.content = CreateFrame("Frame", nil, PAMainFrame)
    tab.content:Hide()
    tab.content.contentWidth = DISPLAY.Constants.minWidth
	tab.content:SetPoint("TOPLEFT", PAMainFrame, "TOPLEFT", 4, -25);
	tab.content:SetPoint("BOTTOMRIGHT", PAMainFrame, "BOTTOMRIGHT", -3, 4);
    tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND")
    tab.content.bg:SetAllPoints(true)
    tab.content.bg:SetColorTexture(.2, 0,.6,.05)

    return tab
end

function DISPLAY:CreateHostWindow()
    if PAMainFrame then
        PAMainFrame:Hide()
        return PAMainFrame
    end

    local mainFrame = CreateFrame("Frame", "PAMainFrame", UIParent, "ButtonFrameBaseTemplate")
    mainFrame:Hide()
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:Lower()
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(DISPLAY.Constants.minWidth, DISPLAY.Constants.minHeight, GetScreenWidth()-100, GetScreenHeight()-100)
    mainFrame:SetSize(DISPLAY.Constants.minWidth,DISPLAY.Constants.minHeight)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
	mainFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);
    ButtonFrameTemplate_HideButtonBar(PAMainFrame) -- maybe show the button bar with some toggle options in it??
    --only enable drag on the titlebar
    mainFrame.TitleContainer:EnableMouse(true)
    mainFrame.TitleContainer:RegisterForDrag("LeftButton")
    mainFrame.TitleContainer:SetScript("OnDragStart",
        function(self)
            PAMainFrame.moving = true
            PAMainFrame:StartMoving()
        end
    )
    mainFrame.TitleContainer:SetScript("OnDragStop",
        function(self)
            PAMainFrame.moving = nil
            PAMainFrame:StopMovingOrSizing()
        end
    )

    PAMainFramePortrait:SetTexture("Interface\\Icons\\Inv_pet_maggot")
    PAMainFrameTitleText:SetText("Pet Collector")
    mainFrame.TitleNote = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    mainFrame.TitleNote:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 40,10);

  --  PAMainFrameInset:Hide()
    --PAMainFrameBg:Hide()
    PAMainFrameBg:SetTexture(nil)
    PAMainFrameBg:SetColorTexture(.1, .1,.1,.8)
    PAMainFrame.TopTileStreaks:Hide()
    
    local resizeButton = CreateFrame("Button", nil, mainFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnMouseDown", 
        function(self, button)
            PAMainFrame:StartSizing("BOTTOMRIGHT")
            PAMainFrame:SetUserPlaced(true)
        end)     
    resizeButton:SetScript("OnMouseUp", 
        function(self, button)
            PAMainFrame:StopMovingOrSizing()
        end)

    --left tabs
    PAMainFrame.numTabs = 6
    local tab1 = CreateTab(1, "Today's events")
    tab1:SetPoint("TOPLEFT", PAMainFrame, "BOTTOMLEFT", 11, 2)
    tab1.content.spinner = CreateFrame("Frame", nil, tab1.content, "SpinnerTemplate")
    tab1.content.spinner:SetPoint("TOPLEFT", tab1.content, "TOPLEFT", 60, -4)
    tab1.content.spinner:SetSize(32,32)
    tab1.content.spinner:Hide()
    tab1.content.refreshButton = CreateFrame("Button", nil, tab1.content, "RefreshButtonTemplate")
    tab1.content.refreshButton:SetPoint("TOPLEFT", tab1.content, "TOPLEFT", 60, -4)
	tab1.content.refreshButton:SetScript("OnClick", 
        function() 
            TASKFINDER:RefreshTodaysEvents(PAMainFrame.mode); 
            DISPLAY.TodaysEvents:Update();
        end
    );

    local tab2 = CreateTab(2, "Wild")
    tab2:SetPoint("TOPLEFT", tab1, "TOPRIGHT", 3, 0)
	DISPLAY.Capturable:Update()
    local tab3 = CreateTab(3, "Loot drops")
    tab3:SetPoint("TOPLEFT", tab2, "TOPRIGHT", 3, 0)
    local tab4 = CreateTab(4, "Random suggestion", 120)
    tab4:SetPoint("TOPLEFT", tab3, "TOPRIGHT", 3, 0)
    --right tabs
    local tabSettings = CreateTab(5, "Settings")
    tabSettings:SetPoint("TOPRIGHT", PAMainFrame, "BOTTOMRIGHT", -11, 2)
    local tabHelp = CreateTab(6, "Help")
    tabHelp:SetPoint("TOPRIGHT", tabSettings, "TOPLEFT", -3, 0)

    mainFrame.content = tab1.content

    return mainFrame
end

function DISPLAY.Main:ShowWindow(mode)
    if (not PAMainFrame) then 
        CreateHostWindow()
    end
    
    PAMainFrame.mode = mode
    UpdateHostWindow()

    DISPLAY.TodaysEvents:Update()

    if (not PAMainFrame.SelectedTab) then
        Tab_OnClick(PAMainFrameTab1)
    end

    PAMainFrame:Show()
end