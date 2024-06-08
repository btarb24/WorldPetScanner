---@class WorldPetScanner
local WPS = WorldPetScanner

local L = WPS.L
local LibQTip = LibStub("LibQTip-1.0")

function WPS:CreateQTip()
    self:Debug("CreateQTIP")
    if not LibQTip:IsAcquired("WorldPetScanner") and not self.tooltip then
        local tooltip = LibQTip:Acquire("WorldPetScanner", 2, "LEFT", "LEFT")
        self.tooltip = tooltip

        tooltip.icon = tooltip:CreateTexture("WPS_Icon", "BACKGROUND")
        tooltip.icon:SetWidth(36)
        tooltip.icon:SetHeight(36)
        tooltip.icon:SetTexture("Interface\\Icons\\Inv_pet_maggot")
        tooltip.icon:SetPoint("TOPLEFT", 7, -8);

        tooltip.title = tooltip:CreateFontString(nil, "OVERLAY");
        tooltip.title:SetFontObject(tooltip:GetHeaderFont())
        tooltip.title:SetPoint("TOPLEFT", 50, -10);
        tooltip.title:SetText("World Pet Scanner")

        tooltip.title = tooltip:CreateFontString(nil, "OVERLAY");
        tooltip.title:SetFontObject(tooltip:GetFont());
        tooltip.title:SetPoint("TOPLEFT", 50, -30);
        tooltip.title:SetText(WPS:GetRegionName() .. "   " .. date("%b %d, 20%y  %H:%M"))

        tooltip:SetScript("OnHide", function()
            if WPS.PopUp then
                WPS.PopUp:Hide()
            end
        end)

        tooltip:SetColumnLayout(5, "LEFT", "LEFT", "LEFT", "LEFT", "LEFT")
        tooltip:AddHeader("")
        tooltip:AddHeader("")
        tooltip:AddHeader("")
        tooltip:SetFrameStrata("MEDIUM")
        tooltip:SetFrameLevel(100)
        tooltip:AddSeparator()
    end
end

function WPS:UpdateQTip(tasks)
    local tooltip = self.tooltip
    if WPS:IsEmpty(tasks) then
        self:Debug("NO_QUESTS")
        tooltip:AddLine(L["NO_QUESTS"])
    else        
        local lineNum = tooltip:GetLineCount()
        local currentExpansionID, currentZoneID
        for _, task in ipairs(tasks) do

--expansion
            if (task.expansionID ~= currentExpansionID) then
                tooltip:AddLine(string.format("|cff33ff33%s|r", task:ExpansionName()))                
                tooltip:SetLineScript(tooltip:GetLineCount(), "OnMouseDown",
                    function()
                        WPS.Expansions[task.expansionID].Collapsed = not WPS.Expansions[task.expansionID].Collapsed
                        WPS:CloseWindow()
                        WPS:ShowWindow(tasks, tooltip:GetLeft(), tooltip:GetTop())
                    end
                )
                lineNum = lineNum + 1
                currentExpansionID = task.expansionID
            end

            if not WPS.Expansions[task.expansionID].Collapsed then
                tooltip:AddLine()
                lineNum = lineNum + 1
--zone col
                local colNum = 1
                if (task.zoneID ~= currentZoneID) then
                    tooltip:SetCell(lineNum, colNum, "     " .. task:ZoneName(), "LEFT", 1, LibQTip.LabelProvider, nil, nil, 200, 200)
                    currentZoneID = task.zoneID
                end
                colNum = colNum + 1

--time col
                if self.db.profile.options.popupShowTime then
                    tooltip:SetCell(lineNum, colNum, self:formatTime(task:Time()), "LEFT", 1, LibQTip.LabelProvider, nil, nil, 100, 55)
                end

--challenge col
                tooltip:SetCell(lineNum, colNum, task.challenge:Display())
                if task.challenge:Link() then
                    tooltip:SetCellScript(
                        lineNum,
                        colNum,
                        "OnEnter",
                        function(self)
                            GameTooltip_SetDefaultAnchor(GameTooltip, self)
                            GameTooltip:ClearLines()
                            GameTooltip:ClearAllPoints()
                            GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
                            if task.challenge.customTooltip then
                                GameTooltip:SetText(task.challenge.customTooltip)    
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

--reward icon col
                colNum = colNum+1
                if colNum > tooltip:GetColumnCount() then
                    tooltip:AddColumn()
                end
                
                if (not task.iconReward) then
                    tooltip:SetCell(lineNum, colNum, "", "LEFT", 1, LibQTip.LabelProvider, nil, nil, 100, 55)
                else
                    local display = task.iconReward:Display()
                    local oldFont = tooltip:GetFont()
                    local newFont = CreateFont("smallerIcon")
                    local fontFile, fontHeight, fontFlags = oldFont:GetFont()
                    newFont:SetFont(fontFile, fontHeight-2, fontFlags)
                    
                    local indent = WPS:GetIconIndent(task.iconReward.id)
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

                            if reward:Link() then
                                GameTooltip:SetHyperlink(reward:Link())
                            else
                                GameTooltip:SetText("hmmmmm....")
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

-- charm totals    
    local charms = self.charmTotal.."x".."|T"..WPS.Textures[WPS.PetCharm]..":24|t"        
    local bandages  = self.bandageTotal.."x".."|T"..WPS.Textures[WPS.Bandage]..":24|t"
    local blueStones  = self.blueStoneTotal.."x".."|T"..WPS.Textures[WPS.BlueStone]..":24|t"
    local trainingStones = ""
    for tStone, _ in pairs(WPS.TrainingStones) do
        local tStoneTotal = self.trainingStoneTotals[tStone]
        if tStoneTotal ~= nil then
            trainingStones = trainingStones .. tStoneTotal.."x".."|T"..WPS.Textures[tStone]..":24|t   "
        end
    end
    local header = charms .. "   " .. bandages .. "   " .. blueStones .. "   " .. trainingStones
    tooltip:SetCell(2, 2, header, "RIGHT", tooltip:GetColumnCount()-1)
    
    tooltip:Show()
end

function WPS:ShowWindow(tasks, left, top)
    self:Debug("ShowWindow")
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
    PopUp.shown = true

    self:CreateQTip()
    self.tooltip:SetAutoHideDelay()
    self.tooltip:ClearAllPoints()
    self.tooltip:SetPoint("TOPLEFT", PopUp, "TOPLEFT", 2, -27)
    self:UpdateQTip(tasks)
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
    if WPS.tooltip ~= nil then
        LibQTip:Release(WPS.tooltip)
        WPS.tooltip = nil
    end

    self.PopUp.shown = false
end