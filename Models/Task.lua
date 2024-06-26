local PETC = PetCollector
local ZONES = PETC.ZONES
local EXPANSIONS = PETC.EXPANSIONS

Task = {}
Task.__index = Task


function Task:new(trigger, challenge, rewardData)
    local instance = {}
    setmetatable(instance, Task)
    
    instance.trigger = trigger
    instance.challenge = Challenge:new(challenge)
    instance.iconReward = nil
    instance.nonIconRewards = {}

    if (rewardData) then
        if type(rewardData) == "table" then
            instance:AddRewards(rewardData)
        else
            instance:AddReward(rewardData)
        end
    end

    return instance
end

function Task:AddRewards(rewardData)
    if rewardData ~= nil then
        for i, reward in ipairs(rewardData) do
            self:AddReward(reward)
        end
    end
end

function Task:AddReward(rewardData)
    if (rewardData ~= nil) then
        local reward = Reward:new(rewardData)
        if (reward:HasIcon()) then
            self.iconReward = reward
        else
            table.insert(self.nonIconRewards, reward)
        end
    end
end

function Task:ExpansionName()
    if self._expansionName == nil then
        self._expansionName = EXPANSIONS:GetName(self.challenge.expansionID)
    end

    return self._expansionName
end

function Task:ZoneName()
    if self._zoneName == nil then
        self._zoneName = ZONES:GetName(self.challenge.expansionID, self.challenge.zoneID)
    end

    return self._zoneName
end

function Task:Time()
    if self.trigger.type == PETC.TRIGGER_TYPE.AURA then
        return nil
    elseif self.trigger.type == PETC.TRIGGER_TYPE.PERIODIC_ROTATION then
        return self.trigger.timeRemaining / 60
    elseif self.trigger.type == PETC.TRIGGER_TYPE.WORLD_QUEST or self.trigger.type == PETC.TRIGGER_TYPE.DAILY_QUEST or self.trigger.type == PETC.TRIGGER_TYPE.WORLD_QUEST_REWARD then
        return C_TaskQuest.GetQuestTimeLeftMinutes(self.challenge.questID)
    elseif self.trigger.type == PETC.TRIGGER_TYPE.AREA_POI then
        return C_AreaPoiInfo.GetAreaPOISecondsLeft(self.trigger.areaPoiID)/60
    end
end

return Task