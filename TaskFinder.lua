local file="TaskFinder"

local PETC = PetCollector
local TASKFINDER = PETC.TASKFINDER
local DISPLAY = PETC.DISPLAY
local DATA = PETC.DATA
local PETS = PETC.PETS
local UTILITIES = PETC.UTILITIES
local ZONES = PETC.ZONES
local DEBUG = PETC.DISPLAY.Debug

local retryTimer

local function UpdateItemTotals(task)
    local method = "CleanRewards"
    if not task.iconReward then
        return
    end

    local itemID = task.iconReward.itemID
    local quantity = task.iconReward.quantity
    if itemID == PETC.PetCharm then
        DEBUG:AddLine(file, method, "task: ", task.trigger.id, " charms ", DATA.charmTotal, "+", quantity, "=", DATA.charmTotal+quantity)
        DATA.charmTotal = DATA.charmTotal + quantity
    end

    if itemID == PETC.Bandage then
        DEBUG:AddLine(file, method, "task: ", task.trigger.id, " bandages ", DATA.bandageTotal, "+", quantity, "=", DATA.bandageTotal+quantity)
        DATA.bandageTotal = DATA.bandageTotal + quantity
    end

    if itemID == PETC.BlueStone then
        DEBUG:AddLine(file, method, "task: ", task.trigger.id, " blueStones ", DATA.blueStoneTotal, "+", quantity, "=", DATA.blueStoneTotal+quantity)
        DATA.blueStoneTotal = DATA.blueStoneTotal + quantity
    end

    if PETC.TrainingStones[itemID] then
        local existingTrainingStones = DATA.trainingStoneTotals[itemID]
        DATA.hasTrainingStones = true
        if (existingTrainingStones == nil) then
            table.insert(DATA.trainingStoneTotals, itemID, quantity)
        else
            DATA.trainingStoneTotals[itemID] = existingTrainingStones + quantity
        end
        DEBUG:AddLine(file, method, "task: ", task.trigger.id, " trainingStoneID ", itemID, " qty: ", quantity, " newTotal: ", DATA.trainingStoneTotals[itemID])
    end
end

local function CleanRewards(mode, taskData)
    local method = "CleanRewards"
    if mode == "test" or mode == "report" then
        return taskData.rewards
    end

    local keptRewards = {}
    for i, reward in pairs(taskData.rewards) do        
        if reward.pet then
            DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " speciesID: ", reward.pet.speciesID, " collected: ", reward.pet.collected, " ADDING")
            if not reward.pet.collected then
                table.insert(keptRewards, reward)
            else
                DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " speciesID: ", reward.pet.speciesID, " collected: ", reward.pet.collected, " SKIPPING")
            end
        else
            DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " itemID: ", reward.itemID, " qty: ", reward.quantity, " ADDING")
            table.insert(keptRewards, reward)
        end
    end

    DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " total: ", UTILITIES:Count(keptRewards))
    return keptRewards
end

local function AddTask(mode, taskData)
    local method = "AddTask"
    if mode == "test" or mode == "report" then
        DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " adding due to test/report")
        local task = Task:new(taskData.trigger, taskData.challenge, taskData.rewards)
        table.insert(DATA.taskList, task)
        UpdateItemTotals(task)
        return
    end

    if (taskData.additionalCriteria) then
        for questId, necessaryCompletionState in taskData.additionalCriteria do
            if not C_QuestLog.IsQuestFlaggedCompleted(questId) == necessaryCompletionState then
                DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " NOT adding due to quest completion state")
                return
            end
        end
    end

    local rewards = CleanRewards(mode, taskData)
    if not UTILITIES:IsEmpty(rewards) then
        DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " adding due to having rewards")
        local task = Task:new(taskData.trigger, taskData.challenge, rewards)
        table.insert(DATA.taskList, task)
        UpdateItemTotals(task)
    end
end

local function ProcessAuraTrigger(mode, taskData)
    local method = "ProcessAuraTrigger"
    local playerAura = C_UnitAuras.GetPlayerAuraBySpellID(taskData.trigger.auraID)
    DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " playerAura: ", playerAura)
    if (playerAura) then
        AddTask(mode, taskData)
    end
end

local function ProcessQuestTrigger(mode, taskData)
    local method = "ProcessQuestTrigger"
    local satisfied = false
    if (taskData.trigger.questEvaluationType == PETC.QUEST_EVAL_TYPE.FLAG) then
        satisfied = not C_QuestLog.IsQuestFlaggedCompleted(taskData.trigger.questID)
        DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " IsQuestFlaggedCompleted: ", satisfied)
    elseif taskData.trigger.questEvaluationType == PETC.QUEST_EVAL_TYPE.ISACTIVE then
        satisfied = C_TaskQuest.IsActive(taskData.trigger.questID)
        DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " IsActive: ", satisfied)
    elseif taskData.trigger.questEvaluationType == PETC.QUEST_EVAL_TYPE.BYMAP then
        local questFound = DATA.scannedQuestList[taskData.trigger.questID]
        DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " questFound: ", questFound)
        if (questFound) then
            local existingTask = DATA.worldQuestTaskResults[taskData.trigger.questID]
            if (taskData.challenge.checkForExistingTask and existingTask) then
                local rewards = CleanRewards(mode, taskData)
                if (not UTILITIES:IsEmpty(rewards)) then
                    for _, rewardData in pairs(rewards) do
                        existingTask:AddReward(Reward:new(rewardData))
                    end
                end
            else
                DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " no existing task")
                satisfied = true
            end
        end
    end

    if (satisfied) then
        AddTask(mode, taskData)
    end
end

local function ProcessAchievementTrigger(mode, taskData)
    local method = "ProcessAchievementTrigger"

    local completed = select(4, GetAchievementInfo(taskData.trigger.achievementID))
    DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " completed: ", completed)

    if not completed then
        AddTask(mode, taskData)
    end
end

local function ProcessAreaPoiTrigger(mode, taskData)
    local method = "ProcessAreaPoiTrigger"
    DEBUG:AddLine(file, method, "task: ", taskData.trigger.id)

    for _, entry in pairs(taskData.trigger.areaPOIList) do
        if C_AreaPoiInfo.GetAreaPOISecondsLeft(entry.areaPoiID) then
            taskData.trigger.areaPoiID = entry.areaPoiID
            DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " areaPoidID with remaining time: ", entry.areaPoiID)
            AddTask(mode, taskData)
            return
        end
    end
end

local function ProcessWorldQuestRewardTrigger(mode, taskData)
    local method = "ProcessWorldQuestRewardTrigger"
    local questMatch = DATA.questsWithNotableRewards[taskData.trigger.itemID]
    DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " questMatch: ", questMatch)

    if questMatch then
        taskData.challenge.questID = questMatch.questId
        AddTask(mode, taskData)
        return
    end
end

local function ProcessPeriodicRotationTrigger(mode, taskData)
    local method = "ProcessPeriodicRotationTrigger"
    local daysSinceStartDay = UTILITIES:GetDaysSince(taskData.trigger.startYear, taskData.trigger.startDayOfYear)
    local secondsInADay = 86400
    DEBUG:AddLine(file, method, "task: ", taskData.trigger.id, " daysSinceStartDay: ", daysSinceStartDay)

    for i = 0, taskData.trigger.daysDuration-1 do
        if (daysSinceStartDay - i) % taskData.trigger.daysInCycle == 0 then
            if (taskData.trigger.daysDuration == 1) then
                taskData.trigger.timeRemaining = GetQuestResetTime()
            else
                taskData.trigger.timeRemaining = GetQuestResetTime() + ((taskData.trigger.daysDuration -1 - i)*secondsInADay)
            end

            AddTask(mode, taskData)
            return
        end
    end
end

local function GetDesiredQuestRewards(taskPOI, expansionID, zoneID)
    local method = "GetDesiredQuestRewards"
	local rewards = {}
    local questID = taskPOI.questId
	local numQuestRewards = GetNumQuestLogRewards(questID)

    DEBUG:AddLine(file, method, "questID: ", questID, " numQuestRewards: ", numQuestRewards)
	if numQuestRewards > 0 then		
		for rewardIndex = 1, numQuestRewards do
			local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex, questID)
            if (not itemID) then
                DEBUG:AddLine(file, method, "missing itemID for quest: ", questID, " idx: ", rewardIndex)
            elseif PETC:GetItemCategory(itemID) ~= nil then
                local reward = Reward:newItem(itemID, quantity, true)
                table.insert(rewards, reward)
                DEBUG:AddLine(file, method, "added reward. itemID: ", itemID, " qty: ", quantity)
            elseif PETC.NotableItems[itemID] then
                table.insert(DATA.questsWithNotableRewards, itemID, taskPOI)
                DEBUG:AddLine(file, method, "added questsWithNotableRewards. itemID: ", itemID)
            end
		end			
	end

	return rewards
end

local function AnalyzeQuestRewards(taskPOI, expansionID, zoneID)
    local method = "AnalyzeQuestRewards"
    local directQuestRewards = GetDesiredQuestRewards(taskPOI, expansionID, zoneID)
    DEBUG:AddLine(file, method, "questID: ", taskPOI.questId, " exp:", expansionID, " z: ", zoneID, " desired reward count: ", UTILITIES:Count(directQuestRewards))
    
    if (not UTILITIES:IsEmpty(directQuestRewards)) then
        local questID = taskPOI.questId
        local trigger = {type = PETC.TRIGGER_TYPE.WORLD_QUEST, questID = questID}
        local challenge = Challenge:newWorldQuest(questID, expansionID, zoneID)
        local task = Task:new(trigger, challenge, directQuestRewards)
        table.insert(DATA.taskList, task)
        UpdateItemTotals(task)
        DATA.worldQuestTaskResults[questID] = task
    end
end

local function AddTradingPostPet(tradingPostPet, mode)
    local method = "AddTradingPostPet"
    local unknownPet = tradingPostPet.pet == nil
    local collected = false
    if mode ~= "test" and tradingPostPet.pet then
        collected = tradingPostPet.pet.collected
    end

    DEBUG:AddLine(file, method, " speciesID:", tradingPostPet.speciesID, " collected: ", collected, "unknownPet: ", unknownPet)

    if unknownPet or not collected then
        DEBUG:AddLine(file, method, "added to tradingPost speciesID: ", tradingPostPet.speciesID)
        table.insert(DATA.tradingPost, tradingPostPet)
    end

    if unknownPet then
        local msg = string.format("Unknown pet: %s speciesID: %s", tradingPostPet.name, tradingPostPet.speciesID)
        DEBUG:AddLine(file, method, msg)
        print(msg)
    end
end

local function PerformRetry(mode)
    local method = "PerformRetry"
    retryTimer = nil
    DEBUG:AddLine(file, method, mode)
    if not UTILITIES:IsEmpty(DATA.questsToRetry) then
        DEBUG:AddLine(file, method, "questsToRetry: ", UTILITIES:Count(DATA.questsToRetry))
        for questID, questData in pairs(DATA.questsToRetry) do
            if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                C_TaskQuest.RequestPreloadRewardData(questID)
                DEBUG:AddLine(file, method, "requestPreload: ", questID)
            else
                DATA.questsToRetry[questID] = nil
                AnalyzeQuestRewards(questData.taskPOI, questData.expansionID, questData.zoneID)
            end
        end
    end

    if not UTILITIES:IsEmpty(DATA.tradingPostRetry) then
        DEBUG:AddLine(file, method, "tradingPostRetry: ", UTILITIES:Count(DATA.tradingPostRetry))
        for num, tradingPostPet in ipairs(DATA.tradingPostRetry) do
            if tradingPostPet.confirmedPet ~= true then
                local itemType = select(7, GetItemInfo(tradingPostPet.itemID))
                if itemType then
                    if itemType == "Companion Pets" then
                        tradingPostPet.confirmedPet = true
                        DEBUG:AddLine(file, method, "confirmedPet  iID: ", tradingPostPet.itemID)
                    else
                        --remove since it's not a pet
                        DATA.tradingPostRetry[num] = nil
                        DEBUG:AddLine(file, method, "confirmed not a Pet  iID: ", tradingPostPet.itemID)
                    end
                end
            end

            if (tradingPostPet.confirmedPet) then
                local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradeable, unique, obtainable, displayID, speciesID = C_PetJournal.GetPetInfoByItemID(tradingPostPet.itemID)
                if speciesID then
                    tradingPostPet.speciesID = speciesID
                    tradingPostPet.name = name
                    tradingPostPet.pet = PETS.all[speciesID]
                    AddTradingPostPet(tradingPostPet, mode)
                    DATA.tradingPostRetry[num] = nil
                else
                    DEBUG:AddLine(file, method, "still no speciesID  iID: ", tradingPostPet.itemID)
                end
            end
        end
    end

    if (UTILITIES:IsEmpty(DATA.questsToRetry) and UTILITIES:IsEmpty(DATA.tradingPostRetry)) then
        DEBUG:AddLine(file, method, "got all our data. done with retries")
        DATA.sortedTasks = UTILITIES:SortTaskList(DATA.taskList)
        DATA.groupedTasks = UTILITIES:GroupTasks(DATA.sortedTasks)
        DISPLAY.TodaysEvents:HideLoading()
    else
        retryTimer = PETC:ScheduleTimer(PerformRetry, 1, mode)
        DEBUG:AddLine(file, method, "scheduling retry")
    end
end

function TASKFINDER:UpdateTradingPostCache()
    local method="UpdateTradingPostCache"

    local autoPerks = C_PerksActivities.GetPerksActivitiesInfo()
    local items = C_PerksProgram.GetAvailableVendorItemIDs()

    if (not PETC_tradingPostVendor) then
        PETC_tradingPostVendor = {}
    end

    if (autoPerks.activePerksMonth ~= PETC_tradingPostVendor.month) then
        DEBUG:AddLine(file, method, "new month detected, clearing cache")
        PETC_tradingPostVendor = {}
    end

    if UTILITIES:Count(items) == 0 then
        if (PETC_tradingPostVendor and type(PETC_tradingPostVendor.expiration) == "number" and PETC_tradingPostVendor.expiration > GetTime()) then
            items = PETC_tradingPostVendor.items
            DEBUG:AddLine(file, method, "no response from server.  Used our cache")
        else
            DEBUG:AddLine(file, method, "no response from server and cache is invalid")
        end
    else
        DEBUG:AddLine(file, method, "good response from server. updated cache")
        local timeRemaining = C_PerksProgram.GetTimeRemaining(items[1])
        local expiration = GetTime() + timeRemaining
        PETC_tradingPostVendor.expiration = expiration
        PETC_tradingPostVendor.items = items
        PETC_tradingPostVendor.month = autoPerks.activePerksMonth
        PETC_tradingPostVendor.itemDetails = {}
    end

    return autoPerks, items
end

local function GetTradingPostPets(mode)
    local method="GetTradingPostPets"

    local autoPerks, items = TASKFINDER:UpdateTradingPostCache()

    DEBUG:AddLine(file, method, "vendor item count: ", UTILITIES:Count(items))
    for _, itemID in pairs(items) do
        local itemData = C_PerksProgram.GetVendorItemInfo(itemID)
        if (not itemData or itemData.perksVendorItemID == 0) then
            itemData = PETC_tradingPostVendor.itemDetails[itemID]
            itemData.timeRemaining = PETC_tradingPostVendor.expiration - GetTime()
        else
            PETC_tradingPostVendor.itemDetails[itemID] = itemData
        end

        DEBUG:AddLine(file, method, "id: ", itemID, " cat: ", itemData.perksVendorCategoryID)
        if (itemData.perksVendorCategoryID == 3) then
            local tradingPostPet = {
                speciesID = itemData.speciesID,
                name = itemData.Name,
                price = itemData.price,
                timeRemaining = itemData.timeRemaining,
                pet = PETS.all[itemData.speciesID]
            }
            
            local speciesName, speciesIcon, petType, companionID, tooltipSource, flavor, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(itemData.speciesID)
            tradingPostPet.name = speciesName
            DEBUG:AddLine(file, method, "speciesID: ", itemData.speciesID, " name: ", speciesName)
            AddTradingPostPet(tradingPostPet, mode)
        end
    end

    for tier, tierInfo in ipairs(autoPerks.thresholds) do
        if tierInfo.itemReward then
            local itemType = select(7, GetItemInfo(tierInfo.itemReward))
            local tradingPostPet = {
                tier = tier,
                timeRemaining = autoPerks.secondsRemaining,
                itemID = tierInfo.itemReward
            }
            DEBUG:AddLine(file, method, "itemType: ", itemType, " itemReward: ", tierInfo.itemReward)
            if itemType == "Companion Pets" then
                tradingPostPet.confirmedPet = true
                local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradeable, unique, obtainable, displayID, speciesID = C_PetJournal.GetPetInfoByItemID(tierInfo.itemReward)
                if speciesID then
                    tradingPostPet.speciesID = speciesID
                    tradingPostPet.name = name
                    tradingPostPet.pet = PETS.all[speciesID]
                    AddTradingPostPet(tradingPostPet, mode)
                else
                    DEBUG:AddLine(file, method, "adding to tradingPostRetry")
                    table.insert(DATA.tradingPostRetry, tradingPostPet)
                end
            end
            if itemType == nil then
                DEBUG:AddLine(file, method, "adding to tradingPostRetry")
                table.insert(DATA.tradingPostRetry, tradingPostPet)
            end
        end
    end
end

function TASKFINDER:RefreshTodaysEvents(mode)
    local method="RefreshTodaysEvents"
    DEBUG:AddLine(file, method, mode)
    if (retryTimer) then
        DEBUG:AddLine(file, method, "clearing retry timer")
        PETC:CancelTimer(retryTimer)
    end
    
    DISPLAY.TodaysEvents:ShowLoading()
    DATA.taskList = {}
    DATA.sortedTasks = {}
    DATA.groupedTasks = {}
    DATA.scannedQuestList = {}
    DATA.questsToRetry = {}
    DATA.worldQuestTaskResults = {}
    DATA.questsWithNotableRewards = {}	
	DATA.taskList = {}
	DATA.charmTotal = 0;
	DATA.bandageTotal = 0;
	DATA.blueStoneTotal = 0;
	DATA.hasTrainingStones = false
	DATA.trainingStoneTotals = {}
    DATA.tradingPost = {}
    DATA.tradingPostRetry = {}
	for expansionID in pairs(ZONES.list) do
		for mapID, mapDetails in pairs(ZONES.list[expansionID]) do
			if mapDetails.scanWorldQuests then
				local taskPOIs = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
                DEBUG:AddLine(file, method, "scanned ", mapID, " received ", taskPOIs, " with amt of ", UTILITIES:Count(taskPOIs))
				if taskPOIs then
					for i = 1, #taskPOIs do
                        local questID = taskPOIs[i].questId

                        if (not DATA.scannedQuestList[questID]) then
                            local zoneID = taskPOIs[i].mapID
                            table.insert(DATA.scannedQuestList, questID, {taskPOI = taskPOIs[i], expansionID = expansionID, zoneID = zoneID})
                            DEBUG:AddLine(file, method, "added to scannedQuestList q:", questID, " exp: ", expansionID, " z:", zoneID)
                            if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                                C_TaskQuest.RequestPreloadRewardData(questID)
                                DEBUG:AddLine(file, method, "added to questsToRetry q:", questID, " exp: ", expansionID, " z:", zoneID)
                                table.insert(DATA.questsToRetry, questID, {taskPOI = taskPOIs[i], expansionID = expansionID , zoneID = zoneID})
                            else
                                AnalyzeQuestRewards(taskPOIs[i], expansionID, zoneID)
                            end                            
                        end
					end
				end
			end
		end
	end

    for _,taskData in pairs(PETC.TaskData) do
        local triggerType = taskData.trigger.type

        if (mode == "report" and taskData.excludeFromReport) then
            --skip
        elseif triggerType == PETC.TRIGGER_TYPE.AURA then
            ProcessAuraTrigger(mode, taskData)
        elseif triggerType == PETC.TRIGGER_TYPE.WORLD_QUEST or triggerType == PETC.TRIGGER_TYPE.DAILY_QUEST then
            ProcessQuestTrigger(mode, taskData)
        elseif triggerType == PETC.TRIGGER_TYPE.ACHIEVEMENT then
            ProcessAchievementTrigger(mode, taskData)
        elseif triggerType == PETC.TRIGGER_TYPE.AREA_POI then
            ProcessAreaPoiTrigger(mode, taskData)
        elseif triggerType == PETC.TRIGGER_TYPE.WORLD_QUEST_REWARD then
            ProcessWorldQuestRewardTrigger(mode, taskData)
        elseif triggerType == PETC.TRIGGER_TYPE.PERIODIC_ROTATION then
            ProcessPeriodicRotationTrigger(mode, taskData)
        end
    end

    GetTradingPostPets(mode)

    --always trigger the timer, this way we see the spinner for at least 1 second, otherwise feels like it ignored your click
    retryTimer = PETC:ScheduleTimer(PerformRetry, 1, mode)
    
	DATA.sortedTasks = UTILITIES:SortTaskList(DATA.taskList)
	DATA.groupedTasks = UTILITIES:GroupTasks(DATA.sortedTasks)
end