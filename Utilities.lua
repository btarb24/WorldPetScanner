---@class WorldPetScanner
local WPS = WorldPetScanner

local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID

ExpansionByZoneID = {
    -- BfA
    [1169] = 8 -- Tol Dagor
}

WPS.debug = true
function WPS:Debug(...)
	if self.debug == true then
		print(...)
	end
end

function WPS:IsEmpty(table)
    if table == nil then
        return true
    end

    return next(table) == nil
end

function WPS:GetExpansionByMapId(mapId)
    if ExpansionByZoneID[mapId] then
        return ExpansionByZoneID[mapId]
    end

    for expansion, zones in pairs(WPS.ZoneIDList) do
        for mapID, mapEnabled in pairs(zones) do
            if mapId == mapID then
                return expansion
            end
        end
    end

    return -1
end

function WPS:GetDaysSince(startYear, startDayOfYear)
    local currentYear = date("%Y")
    local currentDayOfYear = date("*t").yday

    local yearsDelta = currentYear - startYear
    local daysDelta
    if (yearsDelta == 0) then
        daysDelta = currentDayOfYear - startDayOfYear
    else
        for i = startYear, currentYear do
            if (i == startYear) then
                if (WPS:IsLeapYear(i)) then
                    daysDelta = 366-startDayOfYear
                else
                    daysDelta = 365-startDayOfYear
                end
            elseif (i < currentYear) then
                if (WPS:IsLeapYear(i)) then
                    daysDelta = daysDelta + 366
                else
                    daysDelta = daysDelta + 365
                end
            else
                daysDelta = daysDelta + currentDayOfYear
            end
        end
    end

    if (WPS:ShouldReduceServerDayBy1DueToResetTime()) then
        return daysDelta -1
    else
        return daysDelta
    end
end

function WPS:IsLeapYear(year)
    local knownLeapYear = 2024
    local dif = year - knownLeapYear
    return dif % 4 == 0
end

function WPS:ShouldReduceServerDayBy1DueToResetTime()
    local serverTimeH, serverTimeM = GetGameTime()
    local resetSeconds = GetQuestResetTime()
    
    local hourDelta = 23 - serverTimeH
    local minDelta = 60 - serverTimeM
    local secondsUntilEndOfDay = (hourDelta*3600) + (minDelta*60)
    local questResetIsToday = resetSeconds < secondsUntilEndOfDay
    
    local currentDayOfYear = date("*t").yday
    if (questResetIsToday) then 
        return true
    else
        return false
    end
end

function WPS:formatTime(t)
    if (not t) then return "-" end

	local t = math.floor(t or 0)
	local d, h, m, timeString
	d = math.floor(t / 60 / 24)
	h = math.floor(t / 60 % 24)
	m = t % 60
    local mString = m
    if m < 10 then
        mString = "0"
    else
        mString = m
    end

	if d > 0 then
		if h > 0 then
			timeString = string.format("%dd %dh %dm", d, h, mString)
		else
			timeString = string.format("%dd", d)
		end
	elseif h > 0 then
		if m > 0 then
			timeString = string.format("%dh %dm", h, mString)
		else
			timeString = string.format("%dh", h)
		end
	else
		timeString = string.format("%dm", m)
	end

	if t > 0 then
		if t <= 180 then
			if t <= 30 then
				timeString = string.format("|cffff3333%s|r", timeString)
			else
				timeString = string.format("|cffffff00%s|r", timeString)
			end
		end
	end

	return timeString
end

function WPS:GetRegionName()
    local regionID = GetCurrentRegion()
    if regionID == 1 then
        return "US"
    elseif regionID == 2 then
        return "Korea"
    elseif regionID == 3 then
        return "EU"
    elseif regionID == 4 then
        return "Taiwan"
    elseif regionID == 5 then
        return "China"
    end
end

function WPS:BuildQuestLink(questID, name)
    return "|cffffff00|Hquest:".. questID .. "|h[" .. name .."]|h|r"
end

function WPS:BuildPetSpellLink(spellID, name)
    if (spellID) then
        return "|cff67BCFF|Hspell:".. spellID .. "|h[" .. name .."]|h|r"
    else
        return "|cff67BCFF[" .. name .."]|r"
    end
end

function WPS.GetSpellLink(spellID)
    return "|cff71d5ff|Hspell:2061:0|h[Flash Heal]|h|r"
end

function WPS:ListZones()
    
    local textToShow = ""
    for n = 1, 3000 do 
        local info = C_Map.GetMapInfo(n)
        if (info) then
            textToShow = textToShow .. "mapID: "..info.mapID .. "  name: " .. info.name .. "  parentMapID: " ..info.parentMapID .. "  mapType: "..info.mapType .. "  flags: " .. info.flags .. "\n"
        end
    end
    WPS:SetTextInFrame(textToShow)
    
    local f = CreateFrame("Frame", "MyScrollMessageTextFrame", UIParent)
    f:SetSize(150, 150)
    f:SetPoint("CENTER")
    f:SetFrameStrata("BACKGROUND")
    f.Close = CreateFrame("Button", "$parentClose", f)
    f.Close:SetSize(24, 24)
    f.Close:SetPoint("TOPRIGHT")
    f.Close:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    f.Close:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
    f.Close:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
    f.Close:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)
    f.Select = CreateFrame("Button", "$parentSelect", f, "UIPanelButtonTemplate")
    f.Select:SetSize(14, 14)
    f.Select:SetPoint("RIGHT", f.Close, "LEFT")
    f.Select:SetText("S")
    f.Select:SetScript("OnClick", function(self)
        self:GetParent().Text:HighlightText() -- parameters (start, end) or default all
        self:GetParent().Text:SetFocus()
    end)
    
    f.SF = CreateFrame("ScrollFrame", "$parent_DF", f, "UIPanelScrollFrameTemplate")
    f.SF:SetPoint("TOPLEFT", f, 12, -30)
    f.SF:SetPoint("BOTTOMRIGHT", f, -30, 10)
    f.Text = CreateFrame("EditBox", nil, f)
    f.Text:SetMultiLine(true)
    f.Text:SetSize(180, 170)
    f.Text:SetPoint("TOPLEFT", f.SF)
    f.Text:SetPoint("BOTTOMRIGHT", f.SF)
    f.Text:SetMaxLetters(99999)
    f.Text:SetFontObject(GameFontNormal)
    f.Text:SetAutoFocus(false)
    f.Text:SetScript("OnEscapePressed", function(self) self:ClearFocus() end) 
    f.SF:SetScrollChild(f.Text)
    
    f.Text:SetText(textToShow)
end