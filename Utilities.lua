---@class PetAdvisor
local PETAD = PetAdvisor
local UTILITIES = PETAD.UTILITIES

local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID

local function IsLeapYear(year)
    local knownLeapYear = 2024
    local dif = year - knownLeapYear
    return dif % 4 == 0
end

local function ShouldReduceServerDayBy1DueToResetTime()
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

function UTILITIES:IsEmpty(table)
    if table == nil then
        return true
    end

    return next(table) == nil
end

function UTILITIES:GetDaysSince(startYear, startDayOfYear)
    local currentYear = date("%Y")
    local currentDayOfYear = date("*t").yday

    local yearsDelta = currentYear - startYear
    local daysDelta
    if (yearsDelta == 0) then
        daysDelta = currentDayOfYear - startDayOfYear
    else
        for i = startYear, currentYear do
            if (i == startYear) then
                if (IsLeapYear(i)) then
                    daysDelta = 366-startDayOfYear
                else
                    daysDelta = 365-startDayOfYear
                end
            elseif (i < currentYear) then
                if (IsLeapYear(i)) then
                    daysDelta = daysDelta + 366
                else
                    daysDelta = daysDelta + 365
                end
            else
                daysDelta = daysDelta + currentDayOfYear
            end
        end
    end

    if (ShouldReduceServerDayBy1DueToResetTime()) then
        return daysDelta -1
    else
        return daysDelta
    end
end

function UTILITIES:formatTime(t)
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

function UTILITIES:GetRegionName()
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

function UTILITIES:BuildQuestLink(questID, name)
    return "|cffffff00|Hquest:".. questID .. "|h[" .. name .."]|h|r"
end

function UTILITIES:SortTaskList(list)
	table.sort(list, function(a, b) return UTILITIES:Sort(a, b) end)
	return list
end

function UTILITIES:Sort(a, b)
	if a.challenge.expansionID > b.challenge.expansionID then return true end
	if a.challenge.expansionID < b.challenge.expansionID then return false end
	return a.challenge.zoneID < b.challenge.zoneID
end

function UTILITIES:GroupTasks(list)
	local groupedTasks = {}

    local currentExpansionID, currentZoneID
	for _, task in ipairs(list) do
		if (task.challenge.expansionID ~= currentExpansionID) then			
			local expansion = {
				[ID] = task.challenge.expansionID
			}
			expansion.zones = {
				[1] = {
					ID = task.challenge.zoneID,
					tasks = {
						[1] = task
					}
				}
			}
			table.insert(groupedTasks, #groupedTasks+1, expansion)
		elseif currentZoneID ~= task.challenge.zoneID then
			local expansion = groupedTasks[#groupedTasks]
			local zone = {
				ID = task.challenge.zoneID,
				tasks = {
					[1] = task
				}
			}
			table.insert(expansion.zones, #expansion.zones+1, zone)
		else
			local expansion = groupedTasks[#groupedTasks]
			local zone = expansion.zones[#expansion.zones]
			table.insert(zone.tasks, #zone.tasks+1, task)
		end

		currentExpansionID = task.challenge.expansionID
		currentZoneID = task.challenge.zoneID
	end

	return groupedTasks
end