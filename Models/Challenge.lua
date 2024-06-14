local PETAD = PetAdvisor
local UTILITIES = PETAD.UTILITIES

Challenge = {}
Challenge.__index = Challenge;

PETAD.CHALLENGE_TYPE = {
    QUEST = "quest",
    RARE_KILL = "rareKill",
    ACHIEVEMENT = "achievement",
    VENDOR = "vendor",
    PETBATTLE = "petbattle",
}

function Challenge:new(challengeData)
    local instance = {}
    setmetatable(instance, Challenge)  

    instance.expansionID = challengeData.expansionID
    instance.note = challengeData.note
    instance.type = challengeData.type
    instance.questID = challengeData.questID
    instance.questName = challengeData.questName
    instance.vendorID = challengeData.vendorID
    instance.vendorName = challengeData.vendorName
    instance.npcID = challengeData.npcID
    instance.npcName = challengeData.npcName
    instance.achievementID = challengeData.achievementID
    instance.achievementName = challengeData.achievementName

    if (type(challengeData.zoneID) == "table") then
        instance.zoneID = challengeData.zoneID[PETAD.faction]
    else
        instance.zoneID = challengeData.zoneID
    end

    return instance
end

function Challenge:newWorldQuest(questID, expansionID, zoneID)
    local instance = {}
    setmetatable(instance, Challenge)  

    instance.type = PETAD.CHALLENGE_TYPE.QUEST
    instance.expansionID = expansionID
    instance.zoneID = zoneID
    instance.questID = questID

    return instance
end

function Challenge:IsRareKill()
    return self.type == PETAD.CHALLENGE_TYPE.RARE_KILL
end

function Challenge:IsAchievement()
    return self.type == PETAD.CHALLENGE_TYPE.ACHIEVEMENT
end

function Challenge:IsQuest()
    return self.type == PETAD.CHALLENGE_TYPE.QUEST
end

function Challenge:IsVendor()
    return self.type == PETAD.CHALLENGE_TYPE.VENDOR
end

function Challenge:IsPetBattle()
    return self.type == PETAD.CHALLENGE_TYPE.PETBATTLE
end

function Challenge:HasTooltip()
    return self.note or self:Link()
end

function Challenge:Link()
    if not self:IsQuest() then
        return nil
    end

    if self._link == nil then
        local cachedLink = PETAD.links[self.questID]
        if self:IsQuest() then
            self._link = GetQuestLink(self.questID)
            if (not self._link) then
                self._link = UTILITIES:BuildQuestLink(self.questID, self.questName)
            end
        elseif self:IsVendor() then
            self._link = nil
        elseif self:IsAchievement() then
            self._link = GetAchievementLink(self.achievementID)
        elseif self:IsPetBattle() then
            self._link = nil
        end
    end

    return self._link
end

function Challenge:Display()
    if self._display == nil then
        if self:IsQuest() then
            self._display = self:Link()
        elseif self:IsVendor() then
            self._display = self.vendorName
        elseif self:IsAchievement() then
            self._display = self:Link()
        elseif self:IsRareKill() then
            return "Kill rare: " .. self.npcName
        elseif self:IsPetBattle() then
            return "Pet battle: " .. self.npcName
        else
            self._display = "unknown Challenge type"
        end
    end

    return self._display
end

return Challenge