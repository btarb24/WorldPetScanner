local PETAD = PetAdvisor

Reward = {}
Reward.__index = Reward;

PETAD.REWARD_TYPE = {
    ITEM = "item",
    PET = "pet",
    ACHIEVEMENT = "achiev",
    PET_VIA_ITEM = "petViaItem",
}

PETAD.REWARD_ITEMCATEGORY = {
    CHARM = "charm",
    BATTLE_STONE = "battleStone",
    TRAINING_STONE = "trainingStone",
    BANDAGE = "bandage",
}

function Reward:new(rewardData)
    local instance = {}
    setmetatable(instance, Reward)
    
    instance.type = rewardData.type
    instance.creatureID = rewardData.creatureID
    instance.creatureName = rewardData.creatureName
    instance.spellID = rewardData.spellID
    instance.itemID = rewardData.itemID
    instance.itemName = rewardData.itemName
    instance.itemIcon = PETAD.Textures[rewardData.itemID]
    instance.itemCategory = PETAD:GetItemCategory(rewardData.itemID)
    instance.chance = rewardData.chance
    instance.note = rewardData.note
    instance.achievementID = rewardData.achievementID
    instance.achievementName = rewardData.achievementName
    
    if rewardData.quantity ~= nil then 
        instance.quantity = rewardData.quantity
    else
        instance.quantity = 1
    end

    return instance
end

function Reward:newItem(itemID, quantity)
    local instance = {}
    setmetatable(instance, Reward)  
    
    instance.type = PETAD.REWARD_TYPE.ITEM
    instance.itemID = itemID
    instance.itemCategory = PETAD:GetItemCategory(itemID)
    instance.itemIcon = PETAD.Textures[itemID]

    if quantity ~= nil then 
        instance.quantity = quantity
    else
        instance.quantity = 1
    end

    return instance
end

function Reward:IsItem()
    return self.type == PETAD.REWARD_TYPE.ITEM
end

function Reward:IsPet()
    return self.type == PETAD.REWARD_TYPE.PET
end

function Reward:IsPetViaItem()
    return self.type == PETAD.REWARD_TYPE.PET_VIA_ITEM
end

function Reward:IsAchievement()
    return self.type == PETAD.REWARD_TYPE.ACHIEVEMENT
end

function Reward:HasIcon()
    return self.itemIcon ~= nil
end


local function BuildPetSpellLink(spellID, name)
    if (spellID) then
        return "|cff67BCFF|Hspell:".. spellID .. "|h[" .. name .."]|h|r"
    else
        return "|cff67BCFF[" .. name .."]|r"
    end
end

function Reward:Link()
    if self._link == nil then
        if self:IsPet() or self:IsPetViaItem() then
            self._link = BuildPetSpellLink(self.spellID, self.creatureName)
        elseif self:IsItem() then
            self._link = select(2, GetItemInfo(self.itemID))
        elseif self:IsAchievement() then
            self._link = GetAchievementLink(self.achievementID)
        else
            self._link = "unknown reward type"
        end
    end

    return self._link
end

function Reward:IDForLink()
    if self:IsPet() then
        return self.spellID
    else
        return self.itemID
    end
end

function Reward:Display()
    if self._display == nil then
        if self:IsPet() or self:IsPetViaItem() then 
            self._display = self:Link()
        elseif self:IsItem() then
            if self:HasIcon() then
                self._display = self.quantity.."x".."|T"..self.itemIcon..":20:20:0:0:32:32:2:30:2:30|t"
            else
                self._display = self.quantity.."x"..self:Link()
            end
        elseif self:IsAchievement() then
            self._display = self:Link()
        else
            self._display = "unknown reward type"
        end

        if (self.chance) then
            self._display = self._display .. "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:20|t  "
        end
    end

    return self._display
end

return Reward