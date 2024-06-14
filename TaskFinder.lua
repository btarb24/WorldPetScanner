local PETAD = PetAdvisor
local TASKFINDER = PETAD.TASKFINDER
local DISPLAY = PETAD.DISPLAY
local DATA = PETAD.DATA
local UTILITIES = PETAD.UTILITIES
local ZONES = PETAD.ZONES

local retryTimer

local function UpdateItemTotals(itemID, quantity)
	if itemID == PETAD.PetCharm then
		DATA.charmTotal = DATA.charmTotal + quantity
	end

	if itemID == PETAD.Bandage then
		DATA.bandageTotal = DATA.bandageTotal + quantity
	end

	if itemID == PETAD.BlueStone then
		DATA.blueStoneTotal = DATA.blueStoneTotal + quantity
	end

	if PETAD.TrainingStones[itemID] then
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
        if reward.type == PETAD.REWARD_TYPE.PET or reward.type == PETAD.REWARD_TYPE.PET_VIA_ITEM then
            if not DATA.petList[reward.creatureID] then
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
        table.insert(DATA.taskList, Task:new(taskData.trigger, taskData.challenge, taskData.rewards))
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
        table.insert(DATA.taskList, Task:new(taskData.trigger, taskData.challenge, rewards))
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
    if (taskData.trigger.questEvaluationType == PETAD.QUEST_EVAL_TYPE.FLAG) then
        satisfied = not C_QuestLog.IsQuestFlaggedCompleted(taskData.trigger.questID)
    elseif taskData.trigger.questEvaluationType == PETAD.QUEST_EVAL_TYPE.ISACTIVE then
        satisfied = C_TaskQuest.IsActive(taskData.trigger.questID)
    elseif taskData.trigger.questEvaluationType == PETAD.QUEST_EVAL_TYPE.BYMAP then
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
                PETAD:Debug("missing itemID for quest: "..questID.." idx: ".. rewardIndex)
            elseif PETAD:GetItemCategory(itemID) ~= nil then
                local reward = Reward:newItem(itemID, quantity, true)
                UpdateItemTotals(itemID, quantity)
                table.insert(rewards, reward)
            elseif PETAD.NotableItems[itemID] then
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
        local trigger = {type = PETAD.TRIGGER_TYPE.WORLD_QUEST, questID = questID}
        local challenge = Challenge:newWorldQuest(questID, expansionID, zoneID)
        local task = Task:new(trigger, challenge, directQuestRewards)
        table.insert(DATA.taskList, task)
        DATA.worldQuestTaskResults[questID] = task
    end
end

local function PerformRetry()
    retryTimer = nil
    for questID, questData in pairs(DATA.questsToRetry) do        
        if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
            C_TaskQuest.RequestPreloadRewardData(questID)
        else
            DATA.questsToRetry[questID] = nil
            AnalyzeQuestRewards(questData.taskPOI, questData.expansionID, questData.zoneID)
        end
    end

    if (UTILITIES:IsEmpty(DATA.questsToRetry)) then
        DATA.sortedTasks = UTILITIES:SortTaskList(DATA.taskList)
        DATA.groupedTasks = UTILITIES:GroupTasks(DATA.sortedTasks)
        DISPLAY.TodaysEvents:HideLoading()
    else
        retryTimer = PETAD:ScheduleTimer(PerformRetry, 1)
    end
end

function TASKFINDER:RefreshTodaysEvents(mode)
    if (retryTimer) then
        PETAD:CancelTimer(retryTimer)
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

    for _,taskData in pairs(PETAD.TaskData) do
        local triggerType = taskData.trigger.type

        if (mode == "report" and taskData.excludeFromReport) then
            --skip
        elseif triggerType == PETAD.TRIGGER_TYPE.AURA then
            ProcessAuraTrigger(mode, taskData)
        elseif triggerType == PETAD.TRIGGER_TYPE.WORLD_QUEST or triggerType == PETAD.TRIGGER_TYPE.DAILY_QUEST then
            ProcessQuestTrigger(mode, taskData)
        elseif triggerType == PETAD.TRIGGER_TYPE.ACHIEVEMENT then
            ProcessAchievementTrigger(mode, taskData)
        elseif triggerType == PETAD.TRIGGER_TYPE.AREA_POI then
            ProcessAreaPoiTrigger(mode, taskData)
        elseif triggerType == PETAD.TRIGGER_TYPE.WORLD_QUEST_REWARD then
            ProcessWorldQuestRewardTrigger(mode, taskData)
        elseif triggerType == PETAD.TRIGGER_TYPE.PERIODIC_ROTATION then
            ProcessPeriodicRotationTrigger(mode, taskData)
        end
    end

    if UTILITIES:IsEmpty(DATA.questsToRetry) then
        DISPLAY.TodaysEvents:HideLoading()
    else
        retryTimer = PETAD:ScheduleTimer(PerformRetry, 1)
    end
    
	DATA.sortedTasks = UTILITIES:SortTaskList(DATA.taskList)
	DATA.groupedTasks = UTILITIES:GroupTasks(DATA.sortedTasks)
end