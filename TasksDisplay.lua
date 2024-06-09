---@class WorldPetScanner
local WPS = WorldPetScanner

local L = WPS.L
local LibQTip = LibStub("LibQTip-1.0")

function WPS:CreateQTip(mode, isPartialResult)
    if not LibQTip:IsAcquired("WorldPetScanner") and not self.tooltip then
        local tooltip = LibQTip:Acquire("WorldPetScanner", 2, "LEFT", "LEFT")
        self.tooltip = tooltip

--title icon
        if (tooltip.icon) then
            tooltip.icon:SetTexture()
        end
        tooltip.icon = tooltip:CreateTexture("WPS_Icon", "BACKGROUND")
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
        local modeDisplay = ""
        if mode == "report" then 
            modeDisplay = "  [Report mode]"
        elseif mode == "test" then
            modeDisplay = "  [Test mode]"
        end

        local partialDisplay = ""
        if isPartialResult then
            partialDisplay = "  |cffFF0000[PARTIAL RESULT]|r"
        end
        tooltip.date:SetText(WPS:GetRegionName() .. "   " .. date("%b %d, 20%y  %H:%M") .. modeDisplay .. partialDisplay)
-- item totals    
        local charms = self.charmTotal.."x".."|T"..WPS.Textures[WPS.PetCharm]..":20:20:0:0:32:32:2:30:2:30|t"        
        local bandages  = self.bandageTotal.."x".."|T"..WPS.Textures[WPS.Bandage]..":20:20:0:0:32:32:2:30:2:30|t"
        local blueStones  = self.blueStoneTotal.."x".."|T"..WPS.Textures[WPS.BlueStone]..":20:20:0:0:32:32:2:30:2:30|t"
        local trainingStones = ""
        for tStone, _ in pairs(WPS.TrainingStones) do
            local tStoneTotal = self.trainingStoneTotals[tStone]
            if tStoneTotal ~= nil then
                trainingStones = trainingStones .. tStoneTotal.."x".."|T"..WPS.Textures[tStone]..":20:20:0:0:32:32:2:30:2:30|t   "
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
            if WPS.PopUp then
                WPS.PopUp:Hide()
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

function WPS:UpdateQTip(tasks, mode, isPartialResult)
    local tooltip = self.tooltip
    if WPS:IsEmpty(tasks) then
        self:Debug("NO_QUESTS")
        tooltip:AddLine(L["NO_QUESTS"])
    else        
        local lineNum = tooltip:GetLineCount()
        local currentExpansionID, currentZoneID
        for _, task in ipairs(tasks) do

--expansion
            if (task.challenge.expansionID ~= currentExpansionID) then
                tooltip:AddLine(string.format("|cff33ff33%s|r", task:ExpansionName()))                
                tooltip:SetLineScript(tooltip:GetLineCount(), "OnMouseDown",
                    function()
                        WPS.Expansions[task.challenge.expansionID].Collapsed = not WPS.Expansions[task.challenge.expansionID].Collapsed
                        WPS:CloseWindow()
                        WPS:ShowWindow(tasks, mode, isPartialResult, tooltip:GetLeft(), tooltip:GetTop())
                    end
                )
                lineNum = lineNum + 1
                currentExpansionID = task.challenge.expansionID
            end

            local collapseForReport = mode == "report" and WPS.Expansions[task.challenge.expansionID].CollapseInReportMode
            if not WPS.Expansions[task.challenge.expansionID].Collapsed and not collapseForReport then
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
               tooltip:SetCell(lineNum, colNum, self:formatTime(task:Time()), "LEFT", 1, LibQTip.LabelProvider, nil, nil, 100, 55)
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
                    
                    local indent = WPS:GetIconIndent(task.iconReward.itemCategory)
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

function WPS:ShowWindow(tasks, mode, isPartialResult, left, top)
    if not self.PopUp then
        local PopUp = CreateFrame("Frame", "WorldPetScannerPopUp", UIParent)

        self.PopUp = PopUp
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
                if WPS.db.profile.options.popupRememberPosition then
                    WPS.db.profile.options.popupX = self:GetLeft()
                    WPS.db.profile.options.popupY = self:GetTop()
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
                WPS:CloseWindow()
            end
        )
    end
    
    local PopUp = self.PopUp
    PopUp:Show()

    self:CreateQTip(mode, isPartialResult)
    self.tooltip:SetAutoHideDelay()
    self.tooltip:ClearAllPoints()
    self.tooltip:SetPoint("TOPLEFT", PopUp, "TOPLEFT", 2, -27)
    self:UpdateQTip(tasks, mode, isPartialResult)
    PopUp:SetWidth(self.tooltip:GetWidth() + 8.5)
    PopUp:SetHeight(self.tooltip:GetHeight() + 32)
    PopUp:SetScale(self.tooltip:GetScale())
    if (PopUp:GetEffectiveScale() ~= self.tooltip:GetEffectiveScale()) then
        PopUp:SetScale(PopUp:GetScale() * self.tooltip:GetEffectiveScale() / PopUp:GetEffectiveScale())
    end
    PopUp:SetFrameLevel(self.tooltip:GetFrameLevel())

    if self.db.profile.options.popupRememberPosition then
        PopUp:ClearAllPoints()
        PopUp:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.profile.options.popupX, self.db.profile.options.popupY)
    end
end

function WPS:CloseWindow()
    if self.tooltip ~= nil then
        self.tooltip:Release()
        self.tooltip = nil
    end
    if (self.PopUp) then
        self.PopUp:Hide()
        self.PopUp = nil
    end
end