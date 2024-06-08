local WPS = WorldPetScanner

Task = {}
Task.__index = Task

function Task:new(expansionID, zoneID, challenge, rewards)
    local instance = {}
    setmetatable(instance, Task)
    
    instance.expansionID = expansionID
    instance.zoneID = zoneID
    instance.challenge = challenge
    instance.iconReward = nil
    instance.nonIconRewards = {}

    instance:AddRewards(rewards)

    return instance
end

function Task:AddRewards(rewards)
    if rewards ~= nil then
        for i, reward in ipairs(rewards) do
            self:AddReward(reward)
        end
    end
end

function Task:AddReward(reward)
    if (reward ~= nil) then
        if (reward:HasIcon()) then
            self.iconReward = reward
        else
            table.insert(self.nonIconRewards, reward)
        end
    end
end

function Task:ExpansionName()
    if self._expansionName == nil then
        self._expansionName = WPS:GetExpansionName(self.expansionID)
    end

    return self._expansionName
end

function Task:ZoneName()
    if self._zoneName == nil then
        self._zoneName = WPS:GetZoneName(self.expansionID, self.zoneID)
    end

    return self._zoneName
end

function Task:Time()
    return C_TaskQuest.GetQuestTimeLeftMinutes(self.challenge.questID)
end

return Task