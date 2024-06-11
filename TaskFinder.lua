local WPS = WorldPetScanner

function WPS:ScanWorldQuests()
    local scannedQuestList = {}
    local questsToRetry = {}
    local worldQuestTaskResults = {}
    local questsWithNotableRewards = {}
	for expansionID in pairs(self.ZoneIDList) do
		for mapID, mapDetails in pairs(self.ZoneIDList[expansionID]) do
			if mapDetails.scanWorldQuests then
				local taskPOIs = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
				if taskPOIs then
					for i = 1, #taskPOIs do
                        local questID = taskPOIs[i].questId

                        if (not scannedQuestList[questID]) then
                            local zoneID = taskPOIs[i].mapID
                            table.insert(scannedQuestList, questID, {expansionID = expansionID , zoneID = zoneID})
                            if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                                C_TaskQuest.RequestPreloadRewardData(questID)
                                table.insert(questsToRetry, questID, {expansionID = expansionID , zoneID = zoneID})
                            end
                            
                            local directQuestRewards = WPS:GetDesiredQuestRewards(taskPOIs[i], expansionID, zoneID, questsWithNotableRewards)
                            
                            if (not WPS:IsEmpty(directQuestRewards)) then
                                local trigger = {type = WPS.TRIGGER_TYPE.WORLD_QUEST, questID = questID}
                                local challenge = Challenge:newWorldQuest(questID, expansionID, zoneID)
                                local task = Task:new(trigger, challenge, directQuestRewards)
                                table.insert(self.taskList, task)
                                worldQuestTaskResults[questID] = task
                            end
                        end
					end
				end
			end
		end
	end

    return scannedQuestList, worldQuestTaskResults, questsWithNotableRewards, questsToRetry
end

function WPS:ProcessTaskData(mode, scannedQuestList, worldQuestTaskResults, questsWithNotableRewards)
    for _,taskData in pairs(WPS.TaskData) do
        local triggerType = taskData.trigger.type

        if (mode == "report" and taskData.excludeFromReport) then
            --skip
        elseif triggerType == WPS.TRIGGER_TYPE.AURA then
            WPS:ProcessAuraTrigger(mode, taskData)
        elseif triggerType == WPS.TRIGGER_TYPE.WORLD_QUEST or triggerType == WPS.TRIGGER_TYPE.DAILY_QUEST then
            WPS:ProcessQuestTrigger(mode, taskData, scannedQuestList, worldQuestTaskResults)
        elseif triggerType == WPS.TRIGGER_TYPE.ACHIEVEMENT then
            WPS:ProcessAchievementTrigger(mode, taskData)
        elseif triggerType == WPS.TRIGGER_TYPE.AREA_POI then
            WPS:ProcessAreaPoiTrigger(mode, taskData)
        elseif triggerType == WPS.TRIGGER_TYPE.WORLD_QUEST_REWARD then
            WPS:ProcessWorldQuestRewardTrigger(mode, taskData, questsWithNotableRewards)
        elseif triggerType == WPS.TRIGGER_TYPE.PERIODIC_ROTATION then
            WPS:ProcessPeriodicRotationTrigger(mode, taskData)
        end
    end
end

function WPS:ProcessAuraTrigger(mode, taskData)
    local playerAura = C_UnitAuras.GetPlayerAuraBySpellID(taskData.trigger.auraID)
    if (playerAura) then
        WPS:AddTask(mode, taskData)
    end
end

function WPS:ProcessQuestTrigger(mode, taskData, scannedQuestList, worldQuestTaskResults)
    local satisfied = false
    if (taskData.trigger.questEvaluationType == WPS.QUEST_EVAL_TYPE.FLAG) then
        satisfied = not C_QuestLog.IsQuestFlaggedCompleted(taskData.trigger.questID)
    elseif taskData.trigger.questEvaluationType == WPS.QUEST_EVAL_TYPE.ISACTIVE then
        satisfied = C_TaskQuest.IsActive(taskData.trigger.questID)
    elseif taskData.trigger.questEvaluationType == WPS.QUEST_EVAL_TYPE.BYMAP then
        local questFound = scannedQuestList[taskData.trigger.questID]
        if (questFound) then
            local existingTask = worldQuestTaskResults[taskData.trigger.questID]
            if (taskData.challenge.checkForExistingTask and existingTask) then
                local rewards = WPS:CleanRewards(mode, taskData)
                if (not WPS:IsEmpty(rewards)) then
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
        WPS:AddTask(mode, taskData)
    end
end

function WPS:ProcessAchievementTrigger(mode, taskData)
    local completed = select(4, GetAchievementInfo(taskData.trigger.achievementID))
    if not completed then
        WPS:AddTask(mode, taskData)
    end
end

function WPS:ProcessAreaPoiTrigger(mode, taskData)
    for _, entry in pairs(taskData.trigger.areaPOIList) do
        if C_AreaPoiInfo.GetAreaPOISecondsLeft(entry.areaPoiID) then
            taskData.trigger.areaPoiID = entry.areaPoiID
            WPS:AddTask(mode, taskData)
            return
        end
    end
end

function WPS:ProcessWorldQuestRewardTrigger(mode, taskData, questsWithNotableRewards)
    local questMatch = questsWithNotableRewards[taskData.trigger.itemID]
    if questMatch then
        taskData.challenge.questID = questMatch.questId
        WPS:AddTask(mode, taskData)
        return
    end
end

function WPS:ProcessPeriodicRotationTrigger(mode, taskData)
    local daysSinceStartDay = WPS:GetDaysSince(taskData.trigger.startYear, taskData.trigger.startDayOfYear)
    local secondsInADay = 86400

    for i = 0, taskData.trigger.daysDuration-1 do
        if (daysSinceStartDay - i) % taskData.trigger.daysInCycle == 0 then
            if (taskData.trigger.daysDuration == 1) then
                taskData.trigger.timeRemaining = GetQuestResetTime()
            else
                taskData.trigger.timeRemaining = GetQuestResetTime() + ((taskData.trigger.daysDuration -1 - i)*secondsInADay)
            end
            WPS:AddTask(mode, taskData)
            return
        end
    end
end

function WPS:AddTask(mode, taskData)
    if mode == "test" or mode == "report" then
        table.insert(self.taskList, Task:new(taskData.trigger, taskData.challenge, taskData.rewards))
        return
    end

    if (taskData.additionalCriteria) then
        for questId, necessaryCompletionState in taskData.additionalCriteria do
            if not C_QuestLog.IsQuestFlaggedCompleted(questId) == necessaryCompletionState then
                return
            end
        end
    end

    local rewards = WPS:CleanRewards(mode, taskData)
    if not WPS:IsEmpty(rewards) then
        table.insert(self.taskList, Task:new(taskData.trigger, taskData.challenge, rewards))
    end
end

function WPS:CleanRewards(mode, taskData)
    if mode == "test" or mode == "report" then
        return taskData.rewards
    end

    local keptRewards = {}
    for i, reward in pairs(taskData.rewards) do        
        if reward.type == WPS.REWARD_TYPE.PET or reward.type == WPS.REWARD_TYPE.PET_VIA_ITEM then
            if not WPS.PetList[reward.creatureID] then
                table.insert(keptRewards, reward)
            end
        else
            table.insert(keptRewards, reward)
        end
    end

    return keptRewards
end

function WPS:GetDesiredQuestRewards(taskPOI, expansionID, zoneID, questsWithNotableRewards)
	local rewards = {}
    local questID = taskPOI.questId
	local numQuestRewards = GetNumQuestLogRewards(questID)

	if numQuestRewards > 0 then		
		for rewardIndex = 1, numQuestRewards do
			local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex, questID)
            if (not itemID) then
                WPS:Debug("missing itemID for quest: "..questID.." idx: ".. rewardIndex)
            elseif WPS:GetItemCategory(itemID) ~= nil then
                local reward = Reward:newItem(itemID, quantity, true)
                WPS:UpdateItemTotals(itemID, quantity)
                table.insert(rewards, reward)
            elseif WPS.NotableItems[itemID] then
                table.insert(questsWithNotableRewards, itemID, taskPOI)
            end
		end			
	end

	return rewards
end

function WPS:UpdateItemTotals(itemID, quantity)
	if itemID == WPS.PetCharm then
		self.charmTotal = self.charmTotal + quantity
	end

	if itemID == WPS.Bandage then
		self.bandageTotal = self.bandageTotal + quantity
	end

	if itemID == WPS.BlueStone then
		self.blueStoneTotal = self.blueStoneTotal + quantity
	end

	if WPS.TrainingStones[itemID] then
		local existingTrainingStones = self.trainingStoneTotals[itemID]
		self.hasTrainingStones = true
		if (existingTrainingStones == nil) then
			table.insert(self.trainingStoneTotals, itemID, quantity)
		else
			self.trainingStoneTotals[itemID] = existingTrainingStones + quantity
		end
	end
end