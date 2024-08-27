local file="TodaysEvents"

local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local DISPLAY_UTIL = DISPLAY.Util
local UTILITIES = PETC.UTILITIES
local DATA = PETC.DATA
local PETS = PETC.PETS
local ZONES = PETC.ZONES
local EXPANSIONS = PETC.EXPANSIONS

local function DetermineTab1Width(fontString)
    local maxZoneWidth = 0
    local maxTimeWidth = 0
    local maxChallengeWidth = 0
    local maxRewardIconWidth = PETC.IconColumnWidth
    local maxRewardLinkWidth = 0

    for _, expansion in pairs(DATA.groupedTasks) do
        fontString:SetText(EXPANSIONS:GetName(expansion.ID))
        maxZoneWidth = math.max(maxZoneWidth, fontString:GetStringWidth() + DISPLAY_UTIL.Constants.collapseButtonWidth + DISPLAY.Constants.marginAfterButton)
        

        for _, zone in pairs(expansion.zones) do            
            fontString:SetText(ZONES:GetName(expansion.ID, zone.ID))
            maxZoneWidth = math.max(maxZoneWidth, fontString:GetStringWidth() + DISPLAY_UTIL.Constants.collapseButtonWidth + DISPLAY.Constants.marginAfterButton + DISPLAY.Constants.zoneIndent)

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
    if (PAMainFrameTab1.content.scrollFrame) then
        DISPLAY_UTIL:Reset(PAMainFrameTab1)
    else
        PAMainFrameTab1.content.scrollFrame = CreateFrame("ScrollFrame", nil, PAMainFrameTab1.content, "UIPanelScrollFrameTemplate")
        PAMainFrameTab1.content.scrollFrame:SetClipsChildren(true)
        PAMainFrameTab1.content.scrollFrame:SetPoint("TOPLEFT", PAMainFrameTab1.content, "TOPLEFT", 10, -45);
        PAMainFrameTab1.content.scrollFrame:SetPoint("BOTTOMRIGHT", PAMainFrameTab1.content, "BOTTOMRIGHT",0,4);
        PAMainFrameTab1.content.scrollFrame.ScrollBar:ClearAllPoints();
        PAMainFrameTab1.content.scrollFrame.ScrollBar:SetPoint("TOPLEFT", PAMainFrameTab1.content.scrollFrame, "TOPRIGHT", -20, -18);
        PAMainFrameTab1.content.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", PAMainFrameTab1.content.scrollFrame, "BOTTOMRIGHT", 0, 24);
        PAMainFrameTab1.content.scrollFrame.ScrollBar:SetWidth(20);
        local scrollFrameChild = CreateFrame("Frame", nil, PAMainFrameTab1.content.scrollFrame)
        PAMainFrameTab1.content.scrollFrame:SetScrollChild(scrollFrameChild)
        PAMainFrameTab1.content.scrollFrame.child = scrollFrameChild
    end
end

local function Filter(unfilteredTasks)
    local currentDays = UTILITIES:GetDaysSince(2024, 1)
    
    if (not PETC_States.TodaysEvents.lastStateSetPoint or PETC_States.TodaysEvents.lastStateSetPoint < currentDays) then
        PETC_States.TodaysEvents.lastStateSetDate = -1
        PETC_States.TodaysEvents.Filters = {}
        PETC_States.TodaysEvents.CollapsedGroups = {}
        return unfilteredTasks
    end

    if UTILITIES:IsEmpty(PETC_States.TodaysEvents.Filters) then
        return unfilteredTasks
    end

    local filteredResult = {}
    for _, expansion in ipairs(unfilteredTasks) do
        local filteredExpansion = { ID = expansion.ID, zones = {} }
        for _, zone in ipairs(expansion.zones) do
            local filteredZone = { ID = zone.ID, tasks = {} }
            for _, task in ipairs(zone.tasks) do
                local skip = false
                if (task.iconReward) then
                    local itemID = task.iconReward.itemID
                    if itemID == PETC.PetCharm then
                        if not PETC_States.TodaysEvents.Filters["charms"] then
                            skip = true
                        end
                    end

                    if itemID == PETC.Bandage then
                        if not PETC_States.TodaysEvents.Filters["bandages"] then
                            skip = true
                        end
                    end

                    if itemID == PETC.BlueStone then
                        if not PETC_States.TodaysEvents.Filters["bluestones"] then
                            skip = true
                        end
                    end

                    if PETC.TrainingStones[itemID] then
                        if not PETC_States.TodaysEvents.Filters[itemID] then
                            skip = true
                        end
                    end
                elseif not PETC_States.TodaysEvents.Filters["pets"] then
                    skip = true
                end

                if not skip then
                    tinsert(filteredZone.tasks, task)
                end
            end
            if not UTILITIES:IsEmpty(filteredZone.tasks) then
                tinsert(filteredExpansion.zones, filteredZone)
            end
        end
        
        if not UTILITIES:IsEmpty(filteredExpansion.zones) then
            tinsert(filteredResult, filteredExpansion)
        end
    end

    return filteredResult
end

function DISPLAY.TodaysEvents:ShowLoading()
    PAMainFrameTab1.content.refreshButton:Hide()
    PAMainFrameTab1.content.spinner:Show()
end

function DISPLAY.TodaysEvents:HideLoading()
    PAMainFrameTab1.content.refreshButton:Show()
    PAMainFrameTab1.content.spinner:Hide()
    DISPLAY.TodaysEvents:Update()
end

function DISPLAY.TodaysEvents:Update()
    ResetTabContent()
    local tab1Content = PAMainFrameTab1.content
    local scrollFrame = tab1Content.scrollFrame
    if UTILITIES:IsEmpty(DATA.groupedTasks) then
        local noResults = scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        noResults:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 50,0);
        noResults:SetText("There are currently no tasks available")
        return
    end

    local filteredTasks = Filter(DATA.groupedTasks)

    local totalWidth, maxZoneWidth, maxTimeWidth, maxChallengeWidth, maxRewardLinkWidth = DetermineTab1Width(tab1Content:CreateFontString(nil, "OVERLAY", "GameFontHighlight"))
    tab1Content.contentWidth = totalWidth + 100 --arbitrary

   --ITEM TOTALS AT TOP
    local petsButton = DISPLAY_UTIL:AcquireToggleFilterButtonFrame(PAMainFrameTab1, PAMainFrameTab1.content, "pets", DATA.petTotal + UTILITIES:Count(DATA.tradingPost), PETC.Textures["pet"])
    petsButton:SetPoint("TOPRIGHT", PAMainFrameTab1.content, "TOPRIGHT", -10, -2)
    local priorFilterButton = petsButton;

    for tStone, _ in pairs(PETC.TrainingStones) do
        local tStoneTotal = DATA.trainingStoneTotals[tStone]
        if tStoneTotal ~= nil then
            local stoneButton = DISPLAY_UTIL:AcquireToggleFilterButtonFrame(PAMainFrameTab1, PAMainFrameTab1.content, tStone, tStoneTotal, PETC.Textures[tStone])
            stoneButton:SetPoint("TOPRIGHT", priorFilterButton, "TOPLEFT", -5, 0)
            priorFilterButton = stoneButton;
        end
    end

    local blueStoneButton = DISPLAY_UTIL:AcquireToggleFilterButtonFrame(PAMainFrameTab1, PAMainFrameTab1.content, "bluestones", DATA.blueStoneTotal, PETC.Textures[PETC.BlueStone])
    blueStoneButton:SetPoint("TOPRIGHT", priorFilterButton, "TOPLEFT", -5, 0)

    local bandagesButton = DISPLAY_UTIL:AcquireToggleFilterButtonFrame(PAMainFrameTab1, PAMainFrameTab1.content, "bandages", DATA.bandageTotal, PETC.Textures[PETC.Bandage])
    bandagesButton:SetPoint("TOPRIGHT", blueStoneButton, "TOPLEFT", -5, 0)
    local charmsButton = DISPLAY_UTIL:AcquireToggleFilterButtonFrame(PAMainFrameTab1, PAMainFrameTab1.content, "charms", DATA.charmTotal, PETC.Textures[PETC.PetCharm])
    charmsButton:SetPoint("TOPRIGHT", bandagesButton, "TOPLEFT", -5, 0)

   --SEPARATOR LINE
    local line = PAMainFrameTab1.content:CreateLine()
    line:SetColorTexture(.3, .3, 0)
    line:SetStartPoint("TOPLEFT", 10, -40)
    line:SetEndPoint("TOPRIGHT", -10, -40)
    line:SetThickness(1)
    
   --TRADING POST
    if not scrollFrame.child.tradingPostBox then
        scrollFrame.child.tradingPostBox = CreateFrame("Frame", nil, scrollFrame.child, "ThinGoldEdgeTemplate")
        scrollFrame.child.tradingPostBox:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", 0, 0)
        scrollFrame.child.tradingPostBox:SetWidth(675)
        scrollFrame.child.tradingPostBox:SetAlpha(.4)
        scrollFrame.child.tradingPostOverlay = CreateFrame("Frame", nil, scrollFrame.child)
        scrollFrame.child.tradingPostOverlay:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", 0, 0)
        scrollFrame.child.tradingPostOverlay:SetWidth(scrollFrame.child.tradingPostBox:GetWidth())
        scrollFrame.child.tradingPostOverlay:SetHeight(30)
    end
    
    if not UTILITIES:IsEmpty(DATA.tradingPost) then
        scrollFrame.child.tradingPostBox:SetHeight(30)
        scrollFrame.child.tradingPostBox:Show()
        scrollFrame.child.tradingPostBox.icon = DISPLAY_UTIL:AcquireTexture(PAMainFrameTab1, scrollFrame.child.tradingPostOverlay)
        scrollFrame.child.tradingPostBox.icon:SetAtlas("trading-post-minimap-icon")
        scrollFrame.child.tradingPostBox.icon:SetSize(20,20)
        scrollFrame.child.tradingPostBox.icon:SetPoint("TOPLEFT", scrollFrame.child.tradingPostOverlay, "TOPLEFT", 8, -6)
        scrollFrame.child.tradingPostBoxHeader = DISPLAY_UTIL:AcquireLabelFont(PAMainFrameTab1, scrollFrame.child.tradingPostOverlay)
        scrollFrame.child.tradingPostBoxHeader:SetText("Trading Post: ")
        scrollFrame.child.tradingPostBoxHeader:SetPoint("TOPLEFT", scrollFrame.child.tradingPostBox.icon, "TOPRIGHT", 5,-4)
        local tradingPostPetAnchor = scrollFrame.child.tradingPostBoxHeader
        for _, tradingPostPet in pairs(DATA.tradingPost) do
            local tradingPostPetDisplay = DISPLAY_UTIL:AcquirePetLinkFont(PAMainFrameTab1, scrollFrame.child.tradingPostOverlay, tradingPostPet.pet)
            if (tradingPostPet.tier) then
                tradingPostPetDisplay:SetFormattedText("[%s] |cffffffFF(tier %d reward)|r", tradingPostPet.name, tradingPostPet.tier)
            else
                tradingPostPetDisplay:SetFormattedText("[%s] |cffffffFF(%d|T4696085:14:14:0:0:32:32:2:30:2:30|t)|r", tradingPostPet.name, tradingPostPet.price)
            end
            tradingPostPetDisplay.pet = tradingPostPet.pet
            tradingPostPetDisplay:SetPoint("TOPLEFT", tradingPostPetAnchor, "TOPRIGHT", 20, 0);
            tradingPostPetAnchor = tradingPostPetDisplay
        end
    else
        scrollFrame.child.tradingPostBox:SetHeight(1)
        scrollFrame.child.tradingPostBox:Hide()
    end

   --EXPANSION BOX
    local sumHeight = 0
    local widest = 0
    local currentExpansionID, currentZoneID
    local priorExpansionFrame = nil
    local totalHeight = 0
    for _, expansion in ipairs(filteredTasks) do
        local expansionHeight = 0
        local expansionLargestWidth = 0
       --EXPANSION HEADER
        local expansionFrame = DISPLAY_UTIL:AcquireExpansionFrame(PAMainFrameTab1, scrollFrame, EXPANSIONS:GetName(expansion.ID), PETC_States.TodaysEvents.CollapsedGroups, expansion.ID)
        if (priorExpansionFrame) then
            expansionFrame:SetPoint("TOPLEFT", priorExpansionFrame.movingAnchor, "BOTTOMLEFT", 0, -DISPLAY.Constants.lineHeight -DISPLAY.Constants.lineSeparation)
        else
            expansionFrame:SetPoint("TOP", scrollFrame.child.tradingPostBox, "BOTTOM", 0, -5)
            expansionFrame:SetPoint("LEFT", scrollFrame.child.tradingPostBox, "LEFT", expansionIndent, 0)
        end
        priorExpansionFrame = expansionFrame
                        
        local zonesFrame = expansionFrame.childrenHostFrame
       --ZONE HEADER
        for _, zone in ipairs(expansion.zones) do
            local zoneWidth = 0
            local zoneHeight = 0
            local zoneHeader = DISPLAY_UTIL:AcquireHighlightFont(PAMainFrameTab1, expansionFrame.childrenHostFrame);
            zoneHeader:SetText(ZONES:GetName(expansion.ID, zone.ID))
            zoneHeader:SetPoint("TOPLEFT", zonesFrame, "TOPLEFT", 0, -expansionHeight -DISPLAY.Constants.lineSeparation);
            
            for _, task in ipairs(zone.tasks) do
                local lineHighlight = DISPLAY_UTIL:AcquireListItemFrame(PAMainFrameTab1, expansionFrame.childrenHostFrame, false)
                --TASK TIME
                local taskTime = DISPLAY_UTIL:AcquireHighlightFont(PAMainFrameTab1, expansionFrame.childrenHostFrame);
                taskTime:SetText(UTILITIES:formatTime(task:Time()))
                taskTime:SetPoint("TOPRIGHT", zonesFrame, "TOPLEFT", maxZoneWidth + maxTimeWidth -DISPLAY.Constants.zoneIndent, -expansionHeight-zoneHeight -DISPLAY.Constants.lineSeparation);

                --CHALLENGE
                local challenge = DISPLAY_UTIL:AcquireHighlightFont(PAMainFrameTab1, expansionFrame.childrenHostFrame);
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
                    local iconIndent = PETC:GetIconIndent(task.iconReward.itemCategory)
                    local iconReward = DISPLAY_UTIL:AcquireSmallerHighlightFont(PAMainFrameTab1, expansionFrame.childrenHostFrame)                    
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
                    lineHighlight:SetPoint("BOTTOM", iconReward, "BOTTOM")
                end

                --REWARD LINKS
                local linkAnchor = nil
                for rewardLinkIdx, reward in ipairs(task.nonIconRewards) do
                    local rewardLink = DISPLAY_UTIL:AcquirePetLinkFont(PAMainFrameTab1, expansionFrame.childrenHostFrame, reward.pet)
                    rewardLink:SetFormattedText("[%s]", reward.pet.name)
                    if (linkAnchor) then
                        rewardLink:SetPoint("TOPLEFT", linkAnchor, "TOPRIGHT", DISPLAY.Constants.columnSeparation, 0);   
                    else
                        rewardLink:SetPoint("TOPLEFT", taskTime, "TOPRIGHT", maxChallengeWidth +PETC.IconColumnWidth +(DISPLAY.Constants.columnSeparation*4), 0);
                    end
                    linkAnchor = rewardLink
                    if (reward:IsItem()) then
                        rewardLink:HookScript("OnEnter",
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
                        rewardLink:HookScript("OnLeave",
                            function()
                                GameTooltip_HideResetCursor()
                            end
                        )
                    end
                    lineHighlight:SetPoint("BOTTOM", rewardLink, "BOTTOM")
                end
                lineHighlight:SetPoint("LEFT", expansionFrame, "LEFT")
                lineHighlight:SetPoint("RIGHT", scrollFrame, "RIGHT")
                lineHighlight:SetPoint("TOP", taskTime, "TOP")

                zoneHeight = zoneHeight +DISPLAY.Constants.lineHeight +DISPLAY.Constants.lineSeparation
                zonesFrame:SetSize(totalWidth, zoneHeight + zonesFrame:GetHeight())
            end
            expansionHeight = expansionHeight +zoneHeight + DISPLAY.Constants.lineSeparation
        end
        expansionFrame:SetSize(totalWidth, expansionHeight)
        expansionFrame.expansionHeight = expansionFrame:GetHeight()
        expansionFrame.movingAnchor:GetHeight()
        totalHeight = totalHeight + expansionHeight +DISPLAY.Constants.lineHeight +DISPLAY.Constants.lineSeparation

        if (PETC_States.TodaysEvents.CollapsedGroups[expansion.ID] and not expansionFrame.collapseButton.collapsed) then
            expansionFrame.collapseButton:Click()
        end
    end

    scrollFrame.child:SetSize(totalWidth, totalHeight)
    
    --Hack to make it so the window doesn't load empty
    local currentHeight = PAMainFrameTab1.content.scrollFrame.child:GetHeight()
end