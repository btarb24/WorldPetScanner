---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local UTILITIES = PETC.UTILITIES
local DATA = PETC.DATA
local EXPANSIONS = PETC.EXPANSIONS

local L = PETC.L
local LibQTip = LibStub("LibQTip-1.0")

local function CreateQTip(mode, isPartialResult)
    if not LibQTip:IsAcquired("PetCollector") and not DISPLAY.Report.tooltip then
        local tooltip = LibQTip:Acquire("PetCollector", 2, "LEFT", "LEFT")
        DISPLAY.Report.tooltip = tooltip

 --title icon
        if (tooltip.icon) then
            tooltip.icon:SetTexture()
        end
        tooltip.icon = tooltip:CreateTexture("PA_Icon", "BACKGROUND")
        tooltip.icon:SetWidth(38)
        tooltip.icon:SetHeight(38)
        tooltip.icon:SetTexture("Interface\\Icons\\Inv_pet_maggot")
        tooltip.icon:SetTexCoord(.1,.9,.1,.9)
        tooltip.icon:SetPoint("TOPLEFT", 10, -10);
 --app title
        if (tooltip.title) then
            tooltip.title:SetText()
        end
        tooltip.title = tooltip:CreateFontString(nil, "OVERLAY");        
        local fontFile, fontHeight, fontFlags = tooltip:GetHeaderFont():GetFont()
        tooltip.title:SetFont(fontFile, fontHeight+3, fontFlags)
        tooltip.title:SetPoint("TOPLEFT", 53, -12);
        tooltip.title:SetText("World Pet Scanner")
 --date 
        if (tooltip.date) then
            tooltip.date:SetText()
        end
        tooltip.date = tooltip:CreateFontString(nil, "OVERLAY");
        tooltip.date:SetFont(fontFile, fontHeight-2, fontFlags)
        tooltip.date:SetPoint("TOPLEFT", 55, -34);

        local partialDisplay = ""
        if isPartialResult then
            partialDisplay = "  |cffFF0000[PARTIAL RESULT]|r"
        end
        tooltip.date:SetText(UTILITIES:GetRegionName() .. "   " .. date("%b %d, %Y  %H:%M") .. modeDisplay .. partialDisplay)
 -- item totals
        local charms = DATA.charmTotal.."x".."|T"..PETC.Textures[PETC.PetCharm]..":20:20:0:0:32:32:2:30:2:30|t"        
        local bandages  = DATA.bandageTotal.."x".."|T"..PETC.Textures[PETC.Bandage]..":20:20:0:0:32:32:2:30:2:30|t"
        local blueStones  = DATA.blueStoneTotal.."x".."|T"..PETC.Textures[PETC.BlueStone]..":20:20:0:0:32:32:2:30:2:30|t"
        local trainingStones = ""
        for tStone, _ in pairs(PETC.TrainingStones) do
            local tStoneTotal = DATA.trainingStoneTotals[tStone]
            if tStoneTotal ~= nil then
                trainingStones = trainingStones .. tStoneTotal.."x".."|T"..PETC.Textures[tStone]..":20:20:0:0:32:32:2:30:2:30|t   "
            end
        end
        local header = charms .. "    " .. bandages .. "    " .. blueStones .. "    " .. trainingStones
        
        if (tooltip.totals1) then
            tooltip.totals1:SetText()
        end
        tooltip.totals1 = tooltip:CreateFontString(nil, "OVERLAY");
        tooltip.totals1:SetFont(fontFile, fontHeight-1, fontFlags)
        tooltip.totals1:SetPoint("TOPRIGHT", -4, -7);
        tooltip.totals1:SetText(header)
 --pet/ach totals
        local achievs = "0x".."|TInterface\\Icons\\Achievement_guildperk_mrpopularity:18:18:0:0:32:32:2:30:2:30|t"
        local certainPets  = "0x".."|TInterface\\Icons\\Tracking_WildPet:20|t"
        local chancePets  = "0x".."|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:20|t"
        local header = achievs .. "    " .. certainPets .. "    " .. chancePets 
        
        if (tooltip.totals2) then
            tooltip.totals2:SetText()
        end
        tooltip.totals2 = tooltip:CreateFontString(nil, "OVERLAY");
        tooltip.totals2:SetFont(fontFile, fontHeight-1, fontFlags)
        tooltip.totals2:SetPoint("TOPRIGHT", -10, -29);
        tooltip.totals2:SetText(header)

        tooltip:SetScript("OnHide", function()
            if PETC.PopUp then
                PETC.PopUp:Hide()
            end
        end)



        tooltip:SetColumnLayout(5, "LEFT", "LEFT", "LEFT", "LEFT", "LEFT")
        tooltip:AddLine(" ")
        tooltip:AddLine(" ")
        tooltip:AddLine(" ")
        tooltip:SetFrameStrata("MEDIUM")
        tooltip:SetFrameLevel(100)
        tooltip:AddSeparator()
    end
end

local function UpdateReportQTip(mode, isPartialResult)
    local tooltip = DISPLAY.Report.tooltip
    if UTILITIES:IsEmpty(DATA.sortedTasks) then
        tooltip:AddLine("There are currently no tasks available")
    else        
        local lineNum = tooltip:GetLineCount()
        local currentExpansionID, currentZoneID
        for _, task in ipairs(DATA.sortedTasks) do

 --expansion
            if (task.challenge.expansionID ~= currentExpansionID) then
                tooltip:AddLine(string.format("|cff33ff33%s|r", task:ExpansionName()))                
                tooltip:SetLineScript(tooltip:GetLineCount(), "OnMouseDown",
                    function()
                        EXPANSIONS.list[task.challenge.expansionID].Collapsed = not EXPANSIONS.list[task.challenge.expansionID].Collapsed
                        DISPLAY.Report:CloseWindow()
                        PETC:ShowReportWindow(DATA.sortedTasks, mode, isPartialResult, tooltip:GetLeft(), tooltip:GetTop())
                    end
                )
                lineNum = lineNum + 1
                currentExpansionID = task.challenge.expansionID
            end

            local collapseForReport = mode == "report" and EXPANSIONS.list[task.challenge.expansionID].CollapseInReportMode
            if not EXPANSIONS.list[task.challenge.expansionID].Collapsed and not collapseForReport then
                tooltip:AddLine()
                lineNum = lineNum + 1
 --zone col
                local colNum = 1
                if (task.challenge.zoneID ~= currentZoneID) then
                    tooltip:SetCell(lineNum, colNum, "     " .. task:ZoneName(), "LEFT", 1, LibQTip.LabelProvider, nil, nil, 200, 200)
                    currentZoneID = task.challenge.zoneID
                end
                colNum = colNum + 1
                if colNum > tooltip:GetColumnCount() then
                    tooltip:AddColumn()
                end

 --time col
               tooltip:SetCell(lineNum, colNum, UTILITIES:formatTime(task:Time()), "RIGHT", 1, LibQTip.LabelProvider, nil, nil, 140, 55)
               colNum = colNum + 1
               if colNum > tooltip:GetColumnCount() then
                   tooltip:AddColumn()
               end

 --challenge col
                tooltip:SetCell(lineNum, colNum, task.challenge:Display())
                if task.challenge:HasTooltip() then
                    tooltip:SetCellScript(
                        lineNum,
                        colNum,
                        "OnEnter",
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
                    tooltip:SetCellScript(
                        lineNum,
                        colNum,
                        "OnLeave",
                        function()
                            GameTooltip:Hide()
                        end
                    )
                end
                colNum = colNum+1
                if colNum > tooltip:GetColumnCount() then
                    tooltip:AddColumn()
                end

 --reward icon col
                
                if (not task.iconReward) then
                    tooltip:SetCell(lineNum, colNum, "", "LEFT", 1, LibQTip.LabelProvider, nil, nil, 100, 55)
                else
                    local display = task.iconReward:Display()
                    local oldFont = tooltip:GetFont()
                    local newFont = CreateFont("smallerIcon")
                    local fontFile, fontHeight, fontFlags = oldFont:GetFont()
                    newFont:SetFont(fontFile, fontHeight-2, fontFlags)
                    
                    local indent = PETC:GetIconIndent(task.iconReward.itemCategory)
                    tooltip:SetCell(lineNum, colNum, display, newFont, "LEFT", 1, LibQTip.LabelProvider, indent, 0, 170, 55)         
                    if task.iconReward:Link() then           
                        tooltip:SetCellScript(
                            lineNum,
                            colNum,
                            "OnEnter",
                            function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_NONE")
                                GameTooltip:ClearLines()
                                ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip)
                                GameTooltip:SetHyperlink(task.iconReward:Link())
                                GameTooltip:Show()
                            end
                        )
                        tooltip:SetCellScript(
                            lineNum,
                            colNum,
                            "OnLeave",
                            function()
                                GameTooltip_HideResetCursor()
                            end
                        )
                    end
                end

 -- reward link col
                for idx =1, #task.nonIconRewards do
                    local reward = task.nonIconRewards[idx]
                    colNum = colNum + 1
                    if colNum > tooltip:GetColumnCount() then
                        tooltip:AddColumn()
                    end

                    tooltip:SetCell(lineNum, colNum, reward:Display(), "LEFT")
                    tooltip:SetCellScript(
                        lineNum,
                        colNum,
                        "OnEnter",
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
                    tooltip:SetCellScript(
                        lineNum,
                        colNum,
                        "OnLeave",
                        function()
                            GameTooltip_HideResetCursor()
                        end
                    )
                end
            end
        end
    end
    
    tooltip:Show()
end

function DISPLAY.Report:ShowWindow(mode, isPartialResult, left, top)
    if not DISPLAY.Report.PopUp then
        local PopUp = CreateFrame("Frame", "PetCollectorPopUp", UIParent)

        DISPLAY.Report.PopUp = PopUp
        PopUp:SetMovable(true)
        PopUp:EnableMouse(true)
        PopUp:RegisterForDrag("LeftButton")
        PopUp:SetResizable(true)
        PopUp:SetScript("OnDragStart",
            function(self)
                self.moving = true
                self:StartMoving()
            end
        )
        PopUp:SetScript("OnDragStop",
            function(self)
                self.moving = nil
                self:StopMovingOrSizing()
                if PETC.db.profile.options.popupRememberPosition then
                    PETC.db.profile.options.popupX = self:GetLeft()
                    PETC.db.profile.options.popupY = self:GetTop()
                end
            end
        )

        PopUp:SetWidth(300)
        PopUp:SetHeight(100)
        if left then 
            PopUp:SetPoint("TOPLEFT")
            PopUp:SetLeft(left)
            PopUp:SetTop(top)
        else
            PopUp:SetPoint("CENTER")
        end
        PopUp:Hide()

        PopUp:SetScript("OnHide",
            function()
                DISPLAY.Report:CloseWindow()
            end
        )
    end

    local PopUp = DISPLAY.Report.PopUp
    PopUp:Show()

    CreateQTip(mode, isPartialResult)
    DISPLAY.Report.tooltip:SetAutoHideDelay()
    DISPLAY.Report.tooltip:ClearAllPoints()
    DISPLAY.Report.tooltip:SetPoint("TOPLEFT", PopUp, "TOPLEFT", 2, -27)
    UpdateReportQTip(mode, isPartialResult)
    local tooltip = DISPLAY.Report.tooltip
    PopUp:SetWidth(tooltip:GetWidth() + 8.5)
    PopUp:SetHeight(tooltip:GetHeight() + 32)
    PopUp:SetScale(tooltip:GetScale())
    if (PopUp:GetEffectiveScale() ~= tooltip:GetEffectiveScale()) then
        PopUp:SetScale(PopUp:GetScale() * tooltip:GetEffectiveScale() / PopUp:GetEffectiveScale())
    end
    PopUp:SetFrameLevel(tooltip:GetFrameLevel())
end

function DISPLAY.Report:CloseWindow()
    if DISPLAY.Report.tooltip ~= nil then
        DISPLAY.Report.tooltip:Release()
        DISPLAY.Report.tooltip = nil
    end
    if (DISPLAY.Report.PopUp) then
        DISPLAY.Report.PopUp:Hide()
        DISPLAY.Report.PopUp = nil
    end
end