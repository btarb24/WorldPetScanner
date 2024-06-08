local WPS = WorldPetScanner

Challenge = {}
Challenge.__index = Challenge;

WPS.CHALLENGE_TYPE = {
    WORLD_QUEST = "worldQuest",
    DAILY = "daily",
    RARE_KILL = "rareKill",
    ACHIEVEMENT = "achievement",
}

function Challenge:newWorldQuest(questID, name, customTooltip)
    local instance = {}
    setmetatable(instance, Challenge)  
    
    instance.type = WPS.CHALLENGE_TYPE.WORLD_QUEST
    instance.questID = questID
    instance.name = name
    instance.customTooltip = customTooltip

    return instance
end

function Challenge:newDailyQuest(questID, name, customTooltip)
    local instance = {}
    setmetatable(instance, Challenge)  
    
    instance.type = WPS.CHALLENGE_TYPE.DAILY
    instance.questID = questID
    instance.name = name
    instance.customTooltip = customTooltip

    return instance
end

function Challenge:newRareKill(npcID, npcName, associatedQuestID, customTooltip)
    local instance = {}
    setmetatable(instance, Challenge)  
    
    instance.type = WPS.CHALLENGE_TYPE.RARE_KILL
    instance.id = npcID
    instance._npcName = npcName
    instance.questID = associatedQuestID
    instance.customTooltip = customTooltip

    return instance
end

function Challenge:newAchievement(achievmentID, associatedQuestID, customTooltip)
    local instance = {}
    setmetatable(instance, Challenge)  
    
    instance.type = WPS.CHALLENGE_TYPE.ACHIEVEMENT
    instance.id = achievmentID
    instance.questID = associatedQuestID
    instance.customTooltip = customTooltip

    return instance
end

function Challenge:IsWorldQuest()
    return self.type == WPS.CHALLENGE_TYPE.WORLD_QUEST
end

function Challenge:IsDaily()
    return self.type == WPS.CHALLENGE_TYPE.DAILY
end

function Challenge:IsRareKill()
    return self.type == WPS.CHALLENGE_TYPE.RARE_KILL
end

function Challenge:IsAchievement()
    return self.type == WPS.CHALLENGE_TYPE.ACHIEVEMENT
end

function Challenge:IsQuest()
    return self:IsDaily() or self:IsWorldQuest()
end

function Challenge:Link()
    if not self:IsQuest() then
        return nil
    end

    if self._link == nil then
        local cachedLink = WPS.links[self.questID]
        if self:IsQuest() then
            self._link = GetQuestLink(self.questID)
            if (not self._link) then
                self._link = WPS:BuildQuestLink(self.questID, self.name)
            end
        elseif self:IsAchievement() then
            self._link = GetAchievementLink(self.id)
        end
    end

    return self._link
end

function Challenge:Display()
    if self._display == nil then
        if self:IsQuest() then
            self._display = self:Link()
        elseif self:IsAchievement() then
            self._display = self:Link()
        elseif self:IsRareKill() then
            return "Kill rare: " .. _npcName
        else
            self._display = "unknown Challenge type"
        end
    end

    return self._display
end

return Challenge