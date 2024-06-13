local WPS = WorldPetScanner
local DISPLAY = WPS.DISPLAY
local UTILITIES = WPS.UTILITIES
local DATA = WPS.DATA
local ZONES = WPS.ZONES
local EXPANSIONS = WPS.EXPANSIONS

local function DetermineTab1Width(fontString)
    local maxZoneWidth = 0
    local maxTimeWidth = 0
    local maxChallengeWidth = 0
    local maxRewardIconWidth = WPS.IconColumnWidth
    local maxRewardLinkWidth = 0

    for _, expansion in pairs(DATA.groupedTasks) do
        fontString:SetText(EXPANSIONS:GetName(expansion.ID))
        maxZoneWidth = math.max(maxZoneWidth, fontString:GetStringWidth() + DISPLAY.Constants.collapseButtonWidth + DISPLAY.Constants.marginAfterButton)
        

        for _, zone in pairs(expansion.zones) do            
            fontString:SetText(ZONES:GetName(expansion.ID, zone.ID))
            maxZoneWidth = math.max(maxZoneWidth, fontString:GetStringWidth() + DISPLAY.Constants.collapseButtonWidth + DISPLAY.Constants.marginAfterButton + DISPLAY.Constants.zoneIndent)

            for _, task in pairs(zone.tasks) do
                fontString:SetText(UTILITIES:formatTime(task:Time()))
                maxTimeWidth = math.max(maxTimeWidth, fontString:GetStringWidth())
                
                fontString:SetText(task.challenge:Display())
                maxChallengeWidth = math.max(maxChallengeWidth, fontString:GetStringWidth())
                
                local rewardTally = 0
                for _, reward in pairs(task.nonIconRewards) do
                    fontString:SetText(reward:Display())
                    rewardTally = rewardTally + fontString:GetStringWidth()+DISPLAY.Constants.columnSeparation
                end
                maxRewardLinkWidth = math.max(maxRewardLinkWidth, rewardTally)
            end
        end
    end

    local total = maxZoneWidth + maxTimeWidth + maxChallengeWidth + maxRewardIconWidth + maxRewardLinkWidth
    return total,  maxZoneWidth, maxTimeWidth, maxChallengeWidth, maxRewardLinkWidth
end

local function ResetTabContent()
    if (WPSMainFrameTab1.content.scrollFrame) then
        WPSMainFrameTab1.content.scrollFrame:Hide()
        WPSMainFrameTab1.content.scrollFrame:ClearAllPoints()
        WPSMainFrameTab1.content.scrollFrame = nil
    end

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

function DISPLAY.TodaysEvents:ShowLoading()
    WPSMainFrameTab1.content.refreshButton:Hide()
    WPSMainFrameTab1.content.spinner:Show()
end

function DISPLAY.TodaysEvents:HideLoading()
    WPSMainFrameTab1.content.refreshButton:Show()
    WPSMainFrameTab1.content.spinner:Hide()
    DISPLAY.TodaysEvents:Update()
end

function DISPLAY.TodaysEvents:Update()
    ResetTabContent()
    local tab1Content = WPSMainFrameTab1.content
    local scrollFrame = tab1Content.scrollFrame
    if UTILITIES:IsEmpty(DATA.groupedTasks) then
        local noResults = scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        noResults:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 50,0);
        noResults:SetText("There are currently no tasks available")
        return
    end

    local totalWidth, maxZoneWidth, maxTimeWidth, maxChallengeWidth, maxRewardLinkWidth = DetermineTab1Width(tab1Content:CreateFontString(nil, "OVERLAY", "GameFontHighlight"))
    tab1Content.contentWidth = totalWidth + 100 --arbitrary

    --ITEM TOTALS AT TOP
    
    local charms = DATA.charmTotal.."x".."|T"..WPS.Textures[WPS.PetCharm]..":26:26:0:0:32:32:2:30:2:30|t"        
    local bandages  = DATA.bandageTotal.."x".."|T"..WPS.Textures[WPS.Bandage]..":26:26:0:0:32:32:2:30:2:30|t"
    local blueStones  = DATA.blueStoneTotal.."x".."|T"..WPS.Textures[WPS.BlueStone]..":26:26:0:0:32:32:2:30:2:30|t"
    local trainingStones = ""
    for tStone, _ in pairs(WPS.TrainingStones) do
        local tStoneTotal = DATA.trainingStoneTotals[tStone]
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
    for expansionIdx, expansion in ipairs(DATA.groupedTasks) do
        local expansionHeight = 0
        local expansionLargestWidth = 0
        --EXPANSION HEADER
        local expansionIDFrame = CreateFrame("Frame", nil, scrollFrame)
        if (priorExpansionIDFrame) then
            expansionIDFrame:SetPoint("TOPLEFT", priorExpansionIDFrame.movingAnchor, "BOTTOMLEFT", 0, -DISPLAY.Constants.lineHeight -DISPLAY.Constants.lineSeparation)
        else
            expansionIDFrame:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", expansionIndent, 0)
        end
        priorExpansionIDFrame = expansionIDFrame
        local expansionCollapseButton = DISPLAY:BuildCollapseButton(expansionIDFrame)
        expansionWidth = expansionCollapseButton:GetWidth()
        local expansionHeader = expansionIDFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        expansionHeader:SetText(string.format("|cff33ff33%s|r", EXPANSIONS:GetName(expansion.ID)))
        expansionHeader:SetPoint("TOPLEFT", expansionCollapseButton, "TOPRIGHT", DISPLAY.Constants.marginAfterButton, -DISPLAY.Constants.vAlignAdjustmentAfterButton);
        
        expansionIDFrame.childrenHostFrame = CreateFrame("Frame", nil, expansionIDFrame)
        expansionIDFrame.childrenHostFrame:SetPoint("TOPLEFT", expansionHeader, "BOTTOMLEFT", DISPLAY.Constants.zoneIndent,0);
        
        expansionIDFrame.movingAnchor = CreateFrame("Frame", nil, expansionIDFrame)
        expansionIDFrame.movingAnchor:SetSize(1, 1)
        expansionIDFrame.movingAnchor:SetPoint("TOPLEFT", expansionIDFrame, "BOTTOMLEFT")
        
        local zonesFrame = expansionIDFrame.childrenHostFrame
        --ZONE HEADER
        for zoneIdx, zone in ipairs(expansion.zones) do
            local zoneWidth = 0
            local zoneHeight = 0
            local zoneHeader = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
            zoneHeader:SetText(ZONES:GetName(expansion.ID, zone.ID))
            zoneHeader:SetPoint("TOPLEFT", zonesFrame, "TOPLEFT", 0, -expansionHeight -DISPLAY.Constants.lineSeparation);
            
            for taskIdx, task in ipairs(zone.tasks) do
                --TASK TIME
                local taskTime = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
                taskTime:SetText(UTILITIES:formatTime(task:Time()))
                taskTime:SetPoint("TOPRIGHT", zonesFrame, "TOPLEFT", maxZoneWidth + maxTimeWidth -DISPLAY.Constants.zoneIndent, -expansionHeight-zoneHeight -DISPLAY.Constants.lineSeparation);

                --CHALLENGE
                local challenge = zonesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
                challenge:SetText(task.challenge:Display())
                challenge:SetPoint("TOPLEFT", taskTime, "TOPRIGHT", DISPLAY.Constants.columnSeparation, 0);
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
                    iconReward:SetPoint("TOPLEFT", taskTime, "TOPRIGHT", DISPLAY.Constants.columnSeparation +maxChallengeWidth +DISPLAY.Constants.columnSeparation +iconIndent, 0);   
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
                        iconLink:SetPoint("TOPLEFT", linkAnchor, "TOPRIGHT", DISPLAY.Constants.columnSeparation, 0);   
                    else
                        iconLink:SetPoint("TOPLEFT", taskTime, "TOPRIGHT", maxChallengeWidth +WPS.IconColumnWidth +(DISPLAY.Constants.columnSeparation*4), 0);
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

                zoneHeight = zoneHeight +DISPLAY.Constants.lineHeight +DISPLAY.Constants.lineSeparation
                zonesFrame:SetSize(totalWidth, zoneHeight + zonesFrame:GetHeight())
            end
            expansionHeight = expansionHeight +zoneHeight + DISPLAY.Constants.lineSeparation
            expansionIDFrame:SetSize(totalWidth, expansionHeight)
        end
        totalHeight = totalHeight + expansionHeight +DISPLAY.Constants.lineHeight +DISPLAY.Constants.lineSeparation
    end

    scrollFrame.child:SetSize(totalWidth, totalHeight)
end