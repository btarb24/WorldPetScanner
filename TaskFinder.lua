local WPS = WorldPetScanner

function WPS:CreateTaskList()
	self:Debug("CreateTaskList")
	self.taskList = {}
	self.charmTotal = 0;
	self.bandageTotal = 0;
	self.blueStoneTotal = 0;
	self.hasTrainingStones = false
	self.trainingStoneTotals = {}

	local availableQuests = self:ScanWorldQuests()
    self:CheckForPetsViaAchievements(availableQuests)
	self:ScanDailies()
end

function WPS:ScanDailies()
	self:Debug("ScanDailies")
	for questID, questData in pairs(WPS.ItemsViaDaily) do
		local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)
		if not questCompleted then
			if questData.Reward.Type == "item" then
				local challenge = Challenge:newDailyQuest(questID, questData.Name)
				local reward = Reward:newItem(questData.Reward.ItemID, questData.Reward.Quantity, questData.Reward.Guaranteed)
				local task = Task:new(questData.ExpansionID, questData.ZoneID, challenge)
                task:AddReward(reward)
				self:UpdateItemTotals(questData.Reward.ItemID, questData.Reward.Quantity)
				table.insert(self.taskList, task)
			end
		end
	end
end

function WPS:CheckForPetsViaAchievements(availableQuests)
    for achID, achDetail in pairs(WPS.PetViaAchievement) do        
        WPS:checkAchievement(availableQuests, achID, achDetail)
    end
end

function WPS:checkAchievement(availableQuests, achID, achDetail)
    if (self.PetList[achDetail.CreatureID]) then
        return
    end

    local numCriteria = GetAchievementNumCriteria(achID)
    for idx = 1, numCriteria do
        local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(achID, idx)
        completed = false
        local questLoc = availableQuests[assetID]
        if not completed and questLoc then
            local challenge = Challenge:newAchievement(achID, questID, achDetail.CustomToolitp)
            local reward = Reward:newPet(achDetail.CreatureID, achDetail.SpellID, achDetail.CreatureName, true)
            local task = Task:new(questLoc.expansionID, questLoc.zoneID, challenge)
            task:AddReward(reward)
            table.insert(self.taskList, task)
            return
        end
    end
end

function WPS:ScanWorldQuests()
	self:Debug("ScanWorldQuests")
    local questIDs = {}
	for expansionID in pairs(self.ZoneIDList) do
		for mapID, mapDetails in pairs(self.ZoneIDList[expansionID]) do
			if mapDetails.scanWorldQuests then
				local taskPOIs = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
				if taskPOIs then
					for i = 1, #taskPOIs do
                        local questID = taskPOIs[i].questId

                        if (mapID == 2112) then
                            WPS:Debug(questID)
                        end
                        if (questID == 73124) then WPS.Debug("found quest") end
                        if (not questIDs[questID]) then
                            local zoneID = taskPOIs[i].mapID
                            table.insert(questIDs, questID, {expansionID = expansionID , zoneID = zoneID})
                            if HaveQuestData(questID) and not HaveQuestRewardData(questID) then
                                C_TaskQuest.RequestPreloadRewardData(questID)
                                self:Debug("RequestPreloadRewardData"..questID)
                                retry = true
                            end
                            
                            local directQuestRewards = WPS:GetDesiredQuestRewards(questID, expansionID, zoneID)
                            local petRewards, questName, customTooltip = WPS:CheckForPetsViaQuest(questID, taskPOIs)
                            
                            if (not WPS:IsEmpty(directQuestRewards) or not WPS:IsEmpty(petRewards)) then
                                local challenge = Challenge:newWorldQuest(questID, questName, customTooltip)
                                local task = Task:new(expansionID, zoneID, challenge, directQuestRewards)                                
                                task:AddRewards(petRewards)
                                table.insert(self.taskList, task)
                            end
                            
                            WPS:CheckForPetsViaRareDrop(questID, expansionID, zoneID)
                        end
					end
				end
			end
		end
	end

    return questIDs
end

function WPS:GetDesiredQuestRewards(questID, expansionID, zoneID)
	local rewards = {}
	local numQuestRewards = GetNumQuestLogRewards(questID)

	if numQuestRewards > 0 then		
		for rewardIndex = 1, numQuestRewards do
			local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(rewardIndex, questID)
            if (not itemID) then
                WPS:Debug("missing itemID for quest: "..questID.." idx: ".. rewardIndex)
            else
                if (WPS:GetItemCategory(itemID) ~= nil) then
                    local reward = Reward:newItem(itemID, quantity, true)
                    WPS:UpdateItemTotals(itemID, quantity)
                    table.insert(rewards, reward)
                end
            end
		end			
	end

	return rewards
end

function WPS:CheckForPetsViaQuest(questID, allQuestsInZone)
	local pets = {}
    local petViaQuest = WPS.PetsViaQuests[questID]
    if (petViaQuest) then
        local customTooltip = petViaQuest.CustomTooltip
        for rewardIdx, reward in pairs(petViaQuest.Rewards) do
            if not self.PetList[reward.CreatureID] and WPS:DoesAdditionalRewardCriteriaPass(reward.AdditionalCriteria, allQuestsInZone) then
                if (type(petViaQuest.CustomTooltip) == "table" and petViaQuest.CustomTooltip[rewardIdx]) then
                    if (customTooltip == petViaQuest.CustomTooltip) then
                        customTooltip = petViaQuest.CustomTooltip[rewardIdx]
                    else
                        customTooltip = customTooltip .. "\n" .. petViaQuest.CustomTooltip[rewardIdx]
                    end
                end

                table.insert(pets, Reward:newPet(reward.CreatureID, reward.SpellID, reward.CreatureName, reward.Guaranteed))
            end 
        end

        return pets, petViaQuest.Name, customTooltip
    end
end

function WPS:DoesAdditionalRewardCriteriaPass(additionalCriteia, allQuestsInZone)
    if not additionalCriteia then
        return true
    end

    if (additionalCriteia.QuestNotAvailable) then
        if WPS:TaskPoiListContainsQuestId(allQuestsInZone, additionalCriteia.QuestNotAvailable) then
            return false;
        end
    end

    if additionalCriteia.QuestAvailable then
        if not WPS:TaskPoiListContainsQuestId(allQuestsInZone, additionalCriteia.QuestNotAvailable) then
            return false;
        end
    end

    return true
end

function WPS:TaskPoiListContainsQuestId(taskPOIs, questId)
    for _, taskPOI in pairs(taskPOIs) do
        if taskPOI.questId == questID then
            return true
        end
    end

    return false
end

function WPS:CheckForPetsViaRareDrop(questId, expansionID, zoneID)
	local PetsViaRareDrop = WPS.PetsViaRareDrop[questID]
	if (PetsViaRareDrop) then
		for dropDetail in pairs(PetsViaRareDrop.Rewards) do
			if (not self.PetList[dropDetail.CreatureID]) then
				local challenge = Challenge:newRareKill(dropDetail.RareID, dropDetail.RareName, questID, PetsViaRareDrop.CustomToolitp)
				local reward = Reward:newPet(dropDetail.CreatureID, dropDetail.SpellID, dropDetail.CreatureName, dropDetail.Guaranteed)
				local task = Task:new(expansionID, zoneID, challenge, reward)
				task:AddReward(petReward)
				table.insert(self.taskList, task)
			end
		end
	end
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