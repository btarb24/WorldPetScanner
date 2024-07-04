local PETC = PetCollector
local TASKFINDER = PETC.TASKFINDER
local DISPLAY = PETC.DISPLAY
local DATA = PETC.DATA
local PETS = PETC.PETS
local UTILITIES = PETC.UTILITIES
local ZONES = PETC.ZONES

local retryTimer

local function UpdateItemTotals(task)
    if not task.iconReward then
        return
    end

    local itemID = task.iconReward.itemID
    local quantity = task.iconReward.quantity
    if itemID == PETC.PetCharm then
        DATA.charmTotal = DATA.charmTotal + quantity
    end

    if itemID == PETC.Bandage then
        DATA.bandageTotal = DATA.bandageTotal + quantity
    end

    if itemID == PETC.BlueStone then
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
    end
end

local function CleanRewards(mode, taskData)
    if mode == "test" or mode == "report" then
        return taskData.rewards
    end

    local keptRewards = {}
    for i, reward in pairs(taskData.rewards) do        
        if reward.type == PETC.REWARD_TYPE.PET or reward.type == PETC.REWARD_TYPE.PET_VIA_ITEM then
            if not PETS.all[reward.speciesID].collected then
                table.insert(keptRewards, reward)
            end
        else
            table.insert(keptRewards, reward)
        end
    end

    return keptRewards
end

local function AddTask(mode, taskData)
    if mode == "test" or mode == "report" then
        local task = Task:new(taskData.trigger, taskData.challenge, taskData.rewards)
        table.insert(DATA.taskList, task)
        UpdateItemTotals(task)
        return
    end

    if (taskData.additionalCriteria) then
        for questId, necessaryCompletionState in taskData.additionalCriteria do
            if not C_QuestLog.IsQuestFlaggedCompleted(questId) == necessaryCompletionState then
                return
            end
        end
    end

    local rewards = CleanRewards(mode, taskData)
    if not UTILITIES:IsEmpty(rewards) then
        local task = Task:new(taskData.trigger, taskData.challenge, rewards)
        table.insert(DATA.taskList, task)
        UpdateItemTotals(task)
    end
end

local function ProcessAuraTrigger(mode, taskData)
    local playerAura = C_UnitAuras.GetPlayerAuraBySpellID(taskData.trigger.auraID)
    if (playerAura) then
        AddTask(mode, taskData)
    end
end

local function ProcessQuestTrigger(mode, taskData)
    local satisfied = false
    if (taskData.trigger.questEvaluationType == PETC.QUEST_EVAL_TYPE.FLAG) then
        satisfied = not C_QuestLog.IsQuestFlaggedCompleted(taskData.trigger.questID)
    elseif taskData.trigger.questEvaluationType == PETC.QUEST_EVAL_TYPE.ISACTIVE then
        satisfied = C_TaskQuest.IsActive(taskData.trigger.questID)
    elseif taskData.trigger.questEvaluationType == PETC.QUEST_EVAL_TYPE.BYMAP then
        local questFound = DATA.scannedQuestList[taskData.trigger.questID]
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
                satisfied = true
            end
        end
    end

    if (satisfied) then
        AddTask(mode, taskData)
    end
end

local function ProcessAchievementTrigger(mode, taskData)
    local completed = select(4, GetAchievementInfo(taskData.trigger.achievementID))
    if not completed then
        AddTask(mode, taskData)
    end
end

local function ProcessAreaPoiTrigger(mode, taskData)
    for _, entry in pairs(taskData.trigger.areaPOIList) do
        if C_AreaPoiInfo.GetAreaPOISecondsLeft(entry.areaPoiID) then
            taskData.trigger.areaPoiID = entry.areaPoiID
            AddTask(mode, taskData)
            return
        end
    end
end

local function ProcessWorldQuestRewardTrigger(mode, taskData)
    local questMatch = DATA.questsWithNotableRewards[taskData.trigger.itemID]
    if questMatch then
        taskData.challenge.questID = questMatch.questId
        AddTask(mode, taskData)
        return
    end
end

local function ProcessPeriodicRotationTrigger(mode, taskData)
    local daysSinceStartDay = UTILITIES:GetDaysSince(taskData.trigger.startYear, taskData.trigger.startDayOfYear)
    local secondsInADay = 86400

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
	local rewards = {}
    local questID = taskPOI.questId
	local numQuestRewards = GetNumQuestLogRewards(questID)

	if numQuestRewards > 0 then		
		for rewardIndex = 1, numQuestRewards do
			local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex, questID)
            if (not itemID) then
                PETC:Debug("missing itemID for quest: "..questID.." idx: ".. rewardIndex)
            elseif PETC:GetItemCategory(itemID) ~= nil then
                local reward = Reward:newItem(itemID, quantity, true)
                table.insert(rewards, reward)
            elseif PETC.NotableItems[itemID] then
                table.insert(DATA.questsWithNotableRewards, itemID, taskPOI)
            end
		end			
	end

	return rewards
end

local function AnalyzeQuestRewards(taskPOI, expansionID, zoneID)
    local directQuestRewards = GetDesiredQuestRewards(taskPOI, expansionID, zoneID)
    
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

local function PerformRetry()
    retryTimer = nil
    if not UTILITIES:IsEmpty(DATA.questsToRetry) then
        for questID, questData in pairs(DATA.questsToRetry) do
            if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                C_TaskQuest.RequestPreloadRewardData(questID)
            else
                DATA.questsToRetry[questID] = nil
                AnalyzeQuestRewards(questData.taskPOI, questData.expansionID, questData.zoneID)
            end
        end
    end

    if not UTILITIES:IsEmpty(DATA.tradingPostRetry) then
        for num, tradingPostPet in ipairs(DATA.tradingPostRetry) do
            if tradingPostPet.confirmedPet ~= true then
                local itemType = select(7, GetItemInfo(tradingPostPet.itemID))
                if itemType then
                    if itemType == "Companion Pets" then
                        tradingPostPet.confirmedPet = true
                    else
                        --remove since it's not a pet
                        DATA.tradingPostRetry[num] = nil
                    end
                end
            end

            if (tradingPostPet.confirmedPet) then
                local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradeable, unique, obtainable, displayID, speciesID = C_PetJournal.GetPetInfoByItemID(tradingPostPet.itemID)
                if speciesID then
                    tradingPostPet.speciesID = speciesID
                    tradingPostPet.name = name
                    tradingPostPet.pet = PETS.all[speciesID]
                    table.insert(DATA.tradingPost, tradingPostPet)
                    DATA.tradingPostRetry[num] = nil
                end
            end
        end
    end

    if (UTILITIES:IsEmpty(DATA.questsToRetry) and UTILITIES:IsEmpty(DATA.tradingPostRetry)) then
        DATA.sortedTasks = UTILITIES:SortTaskList(DATA.taskList)
        DATA.groupedTasks = UTILITIES:GroupTasks(DATA.sortedTasks)
        DISPLAY.TodaysEvents:HideLoading()
    else
        retryTimer = PETC:ScheduleTimer(PerformRetry, 1)
    end
end

local function GetTradingPostPets()
    local items = C_PerksProgram.GetAvailableVendorItemIDs()
    for _, itemID in pairs(items) do
        local itemData = C_PerksProgram.GetVendorItemInfo(itemID)
        if (itemData.perksVendorCategoryID == 3 and not itemData.purchased) then
            local unknownPet = PETS.all[itemData.speciesID] == nil
            if (unknownPet or not PETS.all[itemData.speciesID].collected) then
               local tradingPostPet = {
                speciesID = itemData.speciesID,
                name = itemData.Name,
                price = itemData.price,
                timeRemaining = itemData.timeRemaining,
                pet = PETS.all[itemData.speciesID]
               }

               local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(itemData.speciesID)
               tradingPostPet.name = speciesName
               table.insert(DATA.tradingPost, tradingPostPet)
            end
        end
    end

    local autoPerks = C_PerksActivities.GetPerksActivitiesInfo()
    for tier, tierInfo in ipairs(autoPerks.thresholds) do
        if tierInfo.itemReward then
            local itemType = select(7, GetItemInfo(tierInfo.itemReward))
            local tradingPostPet = {
                tier = tier,
                timeRemaining = autoPerks.secondsRemaining,
                itemID = tierInfo.itemReward
            }
            if itemType == "Companion Pets" then
                tradingPostPet.confirmedPet = true
                local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradeable, unique, obtainable, displayID, speciesID = C_PetJournal.GetPetInfoByItemID(tierInfo.itemReward)
                if speciesID then
                    tradingPostPet.speciesID = speciesID
                    tradingPostPet.name = name
                    tradingPostPet.pet = PETS.all[speciesID]
                    table.insert(DATA.tradingPost, tradingPostPet)
                else
                    table.insert(DATA.tradingPostRetry, tradingPostPet)
                end
            end
            if itemType == nil then
                table.insert(DATA.tradingPostRetry, tradingPostPet)
            end
        end
    end
end

function TASKFINDER:RefreshTodaysEvents(mode)
    if (retryTimer) then
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
				if taskPOIs then
					for i = 1, #taskPOIs do
                        local questID = taskPOIs[i].questId

                        if (not DATA.scannedQuestList[questID]) then
                            local zoneID = taskPOIs[i].mapID
                            table.insert(DATA.scannedQuestList, questID, {taskPOI = taskPOIs[i], expansionID = expansionID, zoneID = zoneID})
                            if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                                C_TaskQuest.RequestPreloadRewardData(questID)
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

    GetTradingPostPets()

    --always trigger the timer, this way we see the spinner for at least 1 second, otherwise feels like it ignored your click
    retryTimer = PETC:ScheduleTimer(PerformRetry, 1)
    
	DATA.sortedTasks = UTILITIES:SortTaskList(DATA.taskList)
	DATA.groupedTasks = UTILITIES:GroupTasks(DATA.sortedTasks)
end