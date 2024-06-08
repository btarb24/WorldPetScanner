local WPS = WorldPetScanner

Reward = {}
Reward.__index = Reward;

WPS.REWARD_TYPE = {
    ITEM = "item",
    PET = "pet",
    ACHIEVEMENT = "achiev"
}

WPS.REWARD_ITEMCATEGORY = {
    CHARM = "charm",
    BATTLE_STONE = "battleStone",
    TRAINING_STONE = "trainingStone",
    BANDAGE = "bandage",
}

function Reward:newItem(itemID, quantity, guaranteed)
    local instance = {}
    setmetatable(instance, Reward)  
    
    instance.type = WPS.REWARD_TYPE.ITEM
    instance._itemCategory = WPS:GetItemCategory(itemID)
    instance.id = itemID
    instance._itemIcon = WPS.Textures[itemID]
    instance.guaranteed = guaranteed

    if quantity ~= nil then 
        instance.quantity = quantity
    else
        instance.quantity = 1
    end

    return instance
end

function Reward:newPet(petID, petSpellID, name, guaranteed)
    local instance = {}
    setmetatable(instance, Reward)

    instance.type = WPS.REWARD_TYPE.PET
    instance.id = petID
    instance._petSpellID = petSpellID
    instance.quantity = 0
    instance.guaranteed = guaranteed
    instance.name = name

    return instance
end

function Reward:newAchievment(achievementID)
    local instance = {}
    setmetatable(instance, Reward)  
    
    instance.type = WPS.REWARD_TYPE.ACHIEVEMENT
    instance.id = achievementID
    instance.quantity = 0
    instance.guaranteed = true

    return instance
end

function Reward:IsItem()
    return self.type == WPS.REWARD_TYPE.ITEM
end

function Reward:IsPet()
    return self.type == WPS.REWARD_TYPE.PET
end

function Reward:IsAchievement()
    return self.type == WPS.REWARD_TYPE.ACHIEVEMENT
end

function Reward:HasIcon()
    return self._itemIcon ~= nil
end

function Reward:Link()
    if self._link == nil then
        if self:IsPet() then
            self._link = WPS:BuildPetSpellLink(self._petSpellID, self.name)
        elseif self:IsItem() then
            self._link = select(2, GetItemInfo(self.id))
        elseif self:IsAchievement() then
            self._link = GetAchievementLink(self.id)
        else
            self._link = "unknown reward type"
        end
    end

    return self._link
end

function Reward:IDForLink()
    if self:IsPet() then
        return self._petSpellID
    else
        return id
    end
end

function Reward:Display()
    if self._display == nil then
        if self:IsPet() then 
            self._display = self:Link()
        elseif self:IsItem() then
            if self:HasIcon() then
                self._display = self.quantity.."x".."|T"..self._itemIcon..":20:20:0:0:32:32:2:30:2:30|t"
            else
                self._display = self.quantity.."x"..self:Link()
            end
        elseif self:IsAchievement() then
            self._display = self:Link()
        else
            self._display = "unknown reward type"
        end

        if (not self.guaranteed) then
            self._display = self._display .. "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:20|t  "
        end
    end

    return self._display
end

return Reward