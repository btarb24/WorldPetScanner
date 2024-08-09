local file="Utilities"

local PETC = PetCollector
local UTILITIES = PETC.UTILITIES

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
function UTILITIES:Count(table)
    if table == nil then
        return 0
    end
    
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function UTILITIES:Ternary(cond, yes, no)
    return cond and yes or no
end

function UTILITIES:Ternary2(cond, no)
    return cond and cond or no
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
	table.sort(list, function(a, b) return UTILITIES:SortTasks(a, b) end)
	return list
end

function UTILITIES:SortTasks(a, b)
	if a.challenge.expansionID > b.challenge.expansionID then return true end
	if a.challenge.expansionID < b.challenge.expansionID then return false end
    if a.challenge.zoneID == b.challenge.zoneID then
        return a.challenge:Display() < b.challenge:Display()
    end

	return a.challenge.zoneID < b.challenge.zoneID
end

local function GetRarityMultiplier(quality)
   --https://wago.tools/db2/BattlePetBreedQuality  .. times 2

    if (quality == 1) then --poor
        return 1
    elseif (quality == 2) then --common
        return 1.10000002384
    elseif (quality == 3) then --uncommon
        return 1.20000004768
    elseif (quality == 4) then --rare
        return 1.29999995232
    elseif (quality == 5) then --epic
        return 1.39999997616
    elseif (quality == 6) then --lego
        return 1.5
    end
end

local function round(num)
    return math.floor(num + .5)
end

-- base stat source: https://wago.tools/db2/BattlePetSpeciesState
function UTILITIES:GetBreed(baseStats, health, power, speed, rarity, level)
    local rarityMultiplier = GetRarityMultiplier(rarity)

    if health == round((baseStats[1] + 2) * 5 * level * rarityMultiplier  + 100) then 
        return "H/H"
    elseif power == round((baseStats[2] + 2) * level * rarityMultiplier) then
        return "P/P"
    elseif speed == round((baseStats[3] + 2) * level * rarityMultiplier) then
        return "S/S"
    elseif power == round((baseStats[2] + .5) * level * rarityMultiplier) then 
        return "B/B"
    elseif health == round((baseStats[1] + .9) * 5 * level * rarityMultiplier + 100) then 
        if power == round((baseStats[2] + .4) * level * rarityMultiplier) then 
            return "H/B"
        elseif power == round((baseStats[2] + .9) * level * rarityMultiplier) then 
            return "H/P"
        else
            return "H/S"
        end
    elseif power == round((baseStats[2] + .9) * level * rarityMultiplier) then 
        if speed == round((baseStats[3] + .4) * level * rarityMultiplier) then 
            return "P/B"
        else
            return "P/S"
        end
    else
        return "S/B"
    end
end

local function GetMultipliersForBreed(breed)
    if (breed == "H/H") then
        return {2, 0, 0}
    elseif (breed == "P/P") then
        return {0, 2, 0}
    elseif (breed == "S/S") then
        return {0, 0, 2}
    elseif (breed == "B/B") then
        return {.5, .5, .5}
    elseif (breed == "H/P") then
        return {.9, .9, 0}
    elseif (breed == "H/S") then
        return {.9, 0, .9}
    elseif (breed == "H/B") then
        return {.9, .4, .4}
    elseif (breed == "P/S") then
        return {0, .9, .9}
    elseif (breed == "P/B") then
        return {.4, .9, .4}
    elseif (breed == "S/B") then
        return {.4, .4, .9}
    end
end

function UTILITIES:GetMaxStatsForBreed(breed, baseStats)
    local breedMultiplier = GetMultipliersForBreed(breed)
    local rarityMultiplier = GetRarityMultiplier(4) --rare
    local health = round((baseStats[1] + breedMultiplier[1]) * 5 * 25 * rarityMultiplier  + 100)
    local power = round((baseStats[2] + breedMultiplier[2]) * 25 * rarityMultiplier)
    local speed = round((baseStats[3] + breedMultiplier[3]) * 25 * rarityMultiplier)
    return {health, power, speed}
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

-- gsplit: iterate over substrings in a string separated by a pattern
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: iterator
--
-- Usage:
-- for substr in gsplit(text, pattern, plain) do
--   doSomething(substr)
-- end
function gsplit(text, pattern, plain)
    local splitStart, length = 1, #text
    return function ()
      if splitStart then
        local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
        local ret
        if not sepStart then
          ret = string.sub(text, splitStart)
          splitStart = nil
        elseif sepEnd < sepStart then
          -- Empty separator!
          ret = string.sub(text, splitStart, sepStart)
          if sepStart < length then
            splitStart = sepStart + 1
          else
            splitStart = nil
          end
        else
          ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
          splitStart = sepEnd + 1
        end
        return ret
      end
    end
  end
  
  -- split: split a string into substrings separated by a pattern.
  -- 
  -- Parameters:
  -- text (string)    - the string to iterate over
  -- pattern (string) - the separator pattern
  -- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
  --                    string, not a Lua pattern
  -- 
  -- Returns: table (a sequence table containing the substrings)
 function UTILITIES:split(text, pattern, plain)
    local ret = {}
    for match in gsplit(text, pattern, plain) do
      table.insert(ret, match)
    end
    return ret
end