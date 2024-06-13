---@class WorldPetScanner
local WPS = WorldPetScanner

WPS.DisplayConstants = {
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
end

function WPS:ShowMainWindow(groupedTasks, mode, isPartialResult)
    WPS:CreateWindow(mode)
    WPS:ResetDynamicTabs(mode)

    WPS:BuildDailyEventsTab1(WPSMainFrameTab1.content, groupedTasks, mode, isPartialResult)
    Tab_OnClick(WPSMainFrameTab1)

    WPSMainFrame:Show()

    --Hack to make it so the window doesn't load empty
    local currentHeight = WPSMainFrameTab1.content.scrollFrame.child:GetHeight()
    WPSMainFrameTab1.content.scrollFrame.child:SetHeight(currentHeight)
end

function WPS:ResetDynamicTabs(mode)

    if (mode == "test") then
        WPSMainFrame.TitleNote:SetText("*test mode*")
    else
        WPSMainFrame.TitleNote:SetText("")
    end

    if (WPSMainFrameTab1.content) then
        WPSMainFrameTab1.content:Hide()
        WPSMainFrameTab1.content:ClearAllPoints()
        WPSMainFrameTab1.content = nil
    end

    WPSMainFrameTab1.content = CreateFrame("Frame", nil, WPSMainFrame)
    WPSMainFrameTab1.content:Hide()
    WPSMainFrameTab1.content.contentWidth = WPS.DisplayConstants.minWidth
	WPSMainFrameTab1.content:SetPoint("TOPLEFT", WPSMainFrame, "TOPLEFT", 4, -25);
	WPSMainFrameTab1.content:SetPoint("BOTTOMRIGHT", WPSMainFrame, "BOTTOMRIGHT", -3, 4);
    WPSMainFrameTab1.content.bg = WPSMainFrameTab1.content:CreateTexture(nil, "BACKGROUND")
    WPSMainFrameTab1.content.bg:SetAllPoints(true)
    WPSMainFrameTab1.content.bg:SetColorTexture(.2, 0,.6,.05)
    WPSMainFrameTab1.content.scrollFrame = CreateFrame("ScrollFrame", nil, WPSMainFrameTab1.content, "UIPanelScrollFrameTemplate")
    WPSMainFrameTab1.content.scrollFrame:SetClipsChildren(true)
	WPSMainFrameTab1.content.scrollFrame:SetPoint("TOPLEFT", WPSMainFrameTab1.content, "TOPLEFT", 10, -55);
	WPSMainFrameTab1.content.scrollFrame:SetPoint("BOTTOMRIGHT", WPSMainFrameTab1.content, "BOTTOMRIGHT",0,4);
	WPSMainFrameTab1.content.scrollFrame.ScrollBar:ClearAllPoints();
    WPSMainFrameTab1.content.scrollFrame.ScrollBar:SetPoint("TOPLEFT", WPSMainFrameTab1.content.scrollFrame, "TOPRIGHT", -12, -18);
    WPSMainFrameTab1.content.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", WPSMainFrameTab1.content.scrollFrame, "BOTTOMRIGHT", -7, 24);
    local scrollFrameChild = CreateFrame("Frame", nil, WPSMainFrameTab1.content.scrollFrame)
    WPSMainFrameTab1.content.scrollFrame:SetScrollChild(scrollFrameChild)
    WPSMainFrameTab1.content.scrollFrame.child = scrollFrameChild
end

function WPS:CreateWindow(mode)

    if WPSMainFrame then
        WPSMainFrame:Hide()
        return WPSMainFrame
    end

    local mainFrame = CreateFrame("Frame", "WPSMainFrame", UIParent, "ButtonFrameBaseTemplate")
    mainFrame:Hide()
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:Lower()
    mainFrame:SetResizable(true)
    mainFrame:SetResizeBounds(WPS.DisplayConstants.minWidth, WPS.DisplayConstants.minHeight)
    mainFrame:SetSize(WPS.DisplayConstants.minWidth,WPS.DisplayConstants.minHeight)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
	mainFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);
    WPS:Debug(mainFrame.TitleContainer)
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

    local tab2 = CreateFrame("Button", "WPSMainFrameTab2", WPSMainFrame, "PanelTabButtonTemplate") --"CharacterFrameTabButtonTemplate"
    tab2:SetID(2)
    tab2:SetText("Capturable")
    tab2:SetWidth(100)
    tab2.Text:SetWidth(100)
    tab2:ClearAllPoints()
    tab2:SetPoint("TOPLEFT", tab1, "TOPRIGHT", 3, 0)
    tab2:SetScript("OnClick", Tab_OnClick)
    tab2.content = CreateFrame("Frame", nil, WPSMainFrame)
    tab2.content.contentWidth = WPS.DisplayConstants.minWidth
    tab2.content:SetPoint("TOPLEFT", WPSMainFrame, "TOPLEFT", 50, 50)
    tab2.content:SetSize(WPS.DisplayConstants.minWidth,WPS.DisplayConstants.minHeight)
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
    tab3.content.contentWidth = WPS.DisplayConstants.minWidth
    tab3.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab3.content:SetSize(WPS.DisplayConstants.minWidth,WPS.DisplayConstants.minHeight)
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
    tab4.content.contentWidth = WPS.DisplayConstants.minWidth
    tab4.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab4.content:SetSize(WPS.DisplayConstants.minWidth,WPS.DisplayConstants.minHeight)
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
    tab5.content.contentWidth = WPS.DisplayConstants.minWidth
    tab5.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab5.content:SetSize(WPS.DisplayConstants.minWidth,WPS.DisplayConstants.minHeight)
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
    tab6.content.contentWidth = WPS.DisplayConstants.minWidth
    tab6.content:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, 50)
    tab6.content:SetSize(WPS.DisplayConstants.minWidth,WPS.DisplayConstants.minHeight)
    tab6.content.bg = tab6.content:CreateTexture(nil, "BACKGROUND")
    tab6.content.bg:SetAllPoints(true)
    tab6.content.bg:SetColorTexture(0, 0,.6,.1)
    tab6.content:Hide()

    mainFrame.content = tab1.content

    return mainFrame
end

function WPS:BuildDailyEventsTab1(tab1Content, groupedTasks, mode, isPartialResult)
    local scrollFrame = tab1Content.scrollFrame
    if WPS:IsEmpty(groupedTasks) then
        self:Debug("NO_QUESTS")
        local noResults = scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        noResults:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 50,0);
        noResults:SetText("There are currently no tasks available")
        return
    end

    local totalWidth, maxZoneWidth, maxTimeWidth, maxChallengeWidth, maxRewardLinkWidth = WPS:DetermineTab1Width(tab1Content:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), groupedTasks)
    tab1Content.contentWidth = totalWidth + 100 --arbitrary

    --ITEM TOTALS AT TOP
    
    local charms = self.charmTotal.."x".."|T"..WPS.Textures[WPS.PetCharm]..":26:26:0:0:32:32:2:30:2:30|t"        
    local bandages  = self.bandageTotal.."x".."|T"..WPS.Textures[WPS.Bandage]..":26:26:0:0:32:32:2:30:2:30|t"
    local blueStones  = self.blueStoneTotal.."x".."|T"..WPS.Textures[WPS.BlueStone]..":26:26:0:0:32:32:2:30:2:30|t"
    local trainingStones = ""
    for tStone, _ in pairs(WPS.TrainingStones) do
        local tStoneTotal = self.trainingStoneTotals[tStone]
        if tStoneTotal ~= nil then
            trainingStones = trainingStones .. tStoneTotal.."x".."|T"..WPS.Textures[tStone]..":26:26:0:0:32:32:2:30:2:30|t   "
        end
    end
    local header = charms .. "    " .. bandages .. "    " .. blueStones .. "    " .. trainingStones
    
    if (WPSMainFrameTab1.content.totals1) then
        WPSMainFrameTab1.content.totals1:SetText()
    end
    WPSMainFrameTab1.content.totals1 = WPSMainFrameTab1.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    local fontFile, fontHeight, fontFlags = WPSMainFrameTab1.content.totals1:GetFont()
    WPSMainFrameTab1.content.totals1:SetFont(fontFile, fontHeight+2, fontFlags)
    WPSMainFrameTab1.content.totals1:SetPoint("TOPRIGHT", -2, -4);
    WPSMainFrameTab1.content.totals1:SetText(header)

    --SEPARATOR LINE
    local line = WPSMainFrameTab1.content:CreateLine()
    line:SetColorTexture(.3, .3, 0)
    line:SetStartPoint("TOPLEFT", 10, -40)
    line:SetEndPoint("TOPRIGHT", -10, -40)
    line:SetThickness(1)
    
    local sumHeight = 0
    local widest = 0
    local currentExpansionID, currentZoneID
    local priorExpansionIDFrame
    local totalHeight = 0
    for expansionIdx, expansion in ipairs(groupedTasks) do
        local expansionHeight = 0
        local expansionLargestWidth = 0
        --EXPANSION HEADER
        local expansionIDFrame = CreateFrame("Frame", nil, scrollFrame)
        if (priorExpansionIDFrame) then
            expansionIDFrame:SetPoint("TOPLEFT", priorExpansionIDFrame.movingAnchor, "BOTTOMLEFT", 0, -WPS.DisplayConstants.lineHeight -WPS.DisplayConstants.lineSeparation)
        else
            expansionIDFrame:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", expansionIndent, 0)
        end
        priorExpansionIDFrame = expansionIDFrame
        local expansionCollapseButton = WPS:BuildCollapseButton(expansionIDFrame)
        expansionWidth = expansionCollapseButton:GetWidth()
        local expansionHeader = expansionIDFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        expansionHeader:SetText(string.format("|cff33ff33%s|r", WPS:GetExpansionName(expansion.ID)))
        expansionHeader:SetPoint("TOPLEFT", expansionCollapseButton, "TOPRIGHT", WPS.DisplayConstants.marginAfterButton, -WPS.DisplayConstants.vAlignAdjustmentAfterButton);
        
        expansionIDFrame.childrenHostFrame = CreateFrame("Frame", nil, expansionIDFrame)
        expansionIDFrame.childrenHostFrame:SetPoint("TOPLEFT", expansionHeader, "BOTTOMLEFT", WPS.DisplayConstants.zoneIndent,0);
        
        expansionIDFrame.movingAnchor = CreateFrame("Frame", nil, expansionIDFrame)
        expansionIDFrame.movingAnchor:SetSize(1, 1)
        expansionIDFrame.movingAnchor:SetPoint("TOPLEFT", expansionIDFrame, "BOTTOMLEFT")
        
        local zonesFrame = expansionIDFrame.childrenHostFrame
        --ZONE HEADER
        for zoneIdx, zone in ipairs(expansion.zones) do
            local zoneWidth = 0
            local zoneHeight = 0
            local zoneHeader = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
            zoneHeader:SetText(WPS:GetZoneName(expansion.ID, zone.ID))
            zoneHeader:SetPoint("TOPLEFT", zonesFrame, "TOPLEFT", 0, -expansionHeight -WPS.DisplayConstants.lineSeparation);
            
            for taskIdx, task in ipairs(zone.tasks) do
                --TASK TIME
                local taskTime = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
                taskTime:SetText(self:formatTime(task:Time()))
                taskTime:SetPoint("TOPRIGHT", zonesFrame, "TOPLEFT", maxZoneWidth + maxTimeWidth -WPS.DisplayConstants.zoneIndent, -expansionHeight-zoneHeight);

                --CHALLENGE
                local challenge = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
                challenge:SetText(task.challenge:Display())
                challenge:SetPoint("TOPLEFT", taskTime, "TOPRIGHT", WPS.DisplayConstants.columnSeparation, 0);
                if task.challenge:HasTooltip() then
                    challenge:SetScript("OnEnter",
                        function(self)
                            GameTooltip_SetDefaultAnchor(GameTooltip, self)
                            GameTooltip:ClearLines()
                            GameTooltip:ClearAllPoints()
                            GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
                            if task.challenge.note then
                                GameTooltip:SetText(task.challenge.note)    
                            else
                                GameTooltip:SetHyperlink(task.challenge:Link())
                            end
                            GameTooltip:Show()
                        end
                    )
                    challenge:SetScript("OnLeave",
                        function()
                            GameTooltip:Hide()
                        end
                    )
                end

                --REWARD ICON                
                if (task.iconReward) then
                    local iconIndent = WPS:GetIconIndent(task.iconReward.itemCategory)
                    local iconReward = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
                    local fontFile, fontHeight, fontFlags = iconReward:GetFont()
                    iconReward:SetFont(fontFile, fontHeight-2, fontFlags)
                    iconReward:SetText(task.iconReward:Display())
                    iconReward:SetPoint("TOPLEFT", taskTime, "TOPRIGHT", WPS.DisplayConstants.columnSeparation +maxChallengeWidth +WPS.DisplayConstants.columnSeparation +iconIndent, 0);   
                    if task.iconReward:Link() then           
                        iconReward:SetScript("OnEnter",
                            function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_NONE")
                                GameTooltip:ClearLines()
                                ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)
                                GameTooltip:SetHyperlink(task.iconReward:Link())
                                GameTooltip:Show()
                            end
                        )
                        iconReward:SetScript("OnLeave",
                            function()
                                GameTooltip_HideResetCursor()
                            end
                        )
                    end
                    
                end

                --REWARD LINKS
                local linkAnchor = nil
                for rewardLinkIdx, reward in ipairs(task.nonIconRewards) do
                    local iconLink = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
                    iconLink:SetText(reward:Display())
                    if (linkAnchor) then
                        iconLink:SetPoint("TOPLEFT", linkAnchor, "TOPRIGHT", WPS.DisplayConstants.columnSeparation, 0);   
                    else
                        iconLink:SetPoint("TOPLEFT", taskTime, "TOPRIGHT", maxChallengeWidth +WPS.IconColumnWidth +(WPS.DisplayConstants.columnSeparation*4), 0);
                    end
                    linkAnchor = iconLink
                    iconLink:SetScript("OnEnter",
                        function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_NONE")
                            GameTooltip:ClearLines()
                            ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)

                            if reward.note then
                                GameTooltip:SetText(reward.note)    
                            else
                                GameTooltip:SetHyperlink(reward:Link())
                            end
                            GameTooltip:Show()
                        end
                    )
                    iconLink:SetScript("OnLeave",
                        function()
                            GameTooltip_HideResetCursor()
                        end
                    )
                end

                zoneHeight = zoneHeight +WPS.DisplayConstants.lineHeight +WPS.DisplayConstants.lineSeparation
                zonesFrame:SetSize(totalWidth, zoneHeight + zonesFrame:GetHeight())
            end
            expansionHeight = expansionHeight +zoneHeight + WPS.DisplayConstants.lineSeparation
            expansionIDFrame:SetSize(totalWidth, expansionHeight)
        end
        totalHeight = totalHeight + expansionHeight +WPS.DisplayConstants.lineHeight +WPS.DisplayConstants.lineSeparation
    end

    scrollFrame.child:SetSize(totalWidth, totalHeight)
end

function WPS:BuildCollapseButton(parent)    
    local collapseButton = CreateFrame("Button", nil, parent)
    collapseButton:SetSize(WPS.DisplayConstants.collapseButtonWidth, WPS.DisplayConstants.collapseButtonHeight)
    collapseButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    collapseButton:SetHitRectInsets(1, -4, -2, -2)
    collapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
    collapseButton:GetNormalTexture():SetSize(WPS.DisplayConstants.collapseButtonWidth, WPS.DisplayConstants.collapseButtonHeight)
    collapseButton:GetNormalTexture():SetPoint("LEFT", 3, 0)
    collapseButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
    collapseButton:GetHighlightTexture():SetSize(WPS.DisplayConstants.collapseButtonWidth, WPS.DisplayConstants.collapseButtonHeight)
    collapseButton:GetHighlightTexture():SetPoint("LEFT", 3, 0)
    collapseButton.collapsed = false
    collapseButton:SetScript("OnClick", CollapseButton_OnClick)
    return collapseButton
end

function CollapseButton_OnClick(self, button)
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

function WPS:DetermineTab1Width(fontString, groupedTasks)
    local maxZoneWidth = 0
    local maxTimeWidth = 0
    local maxChallengeWidth = 0
    local maxRewardIconWidth = WPS.IconColumnWidth
    local maxRewardLinkWidth = 0

    for _, expansion in pairs(groupedTasks) do
        fontString:SetText(WPS:GetExpansionName(expansion.ID))
        maxZoneWidth = math.max(maxZoneWidth, fontString:GetStringWidth() + WPS.DisplayConstants.collapseButtonWidth + WPS.DisplayConstants.marginAfterButton)
        

        for _, zone in pairs(expansion.zones) do            
            fontString:SetText(WPS:GetZoneName(expansion.ID, zone.ID))
            maxZoneWidth = math.max(maxZoneWidth, fontString:GetStringWidth() + WPS.DisplayConstants.collapseButtonWidth + WPS.DisplayConstants.marginAfterButton + WPS.DisplayConstants.zoneIndent)

            for _, task in pairs(zone.tasks) do
                fontString:SetText(self:formatTime(task:Time()))
                maxTimeWidth = math.max(maxTimeWidth, fontString:GetStringWidth())
                
                fontString:SetText(task.challenge:Display())
                maxChallengeWidth = math.max(maxChallengeWidth, fontString:GetStringWidth())
                
                local rewardTally = 0
                for _, reward in pairs(task.nonIconRewards) do
                    fontString:SetText(reward:Display())
                    rewardTally = rewardTally + fontString:GetStringWidth()+WPS.DisplayConstants.columnSeparation
                end
                maxRewardLinkWidth = math.max(maxRewardLinkWidth, rewardTally)
            end
        end
    end

    local total = maxZoneWidth + maxTimeWidth + maxChallengeWidth + maxRewardIconWidth + maxRewardLinkWidth
    return total,  maxZoneWidth, maxTimeWidth, maxChallengeWidth, maxRewardLinkWidth
end