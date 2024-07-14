local PETC = PetCollector
local PETS = PETC.PETS

Reward = {}
Reward.__index = Reward;

PETC.REWARD_ITEMCATEGORY = {
    CHARM = "charm",
    BATTLE_STONE = "battleStone",
    TRAINING_STONE = "trainingStone",
    BANDAGE = "bandage",
}

function Reward:new(rewardData)
    local instance = {}
    setmetatable(instance, Reward)
    
    instance.pet = rewardData.pet
    instance.itemID = rewardData.itemID
    instance.itemName = rewardData.itemName
    instance.itemIcon = PETC.Textures[rewardData.itemID]
    instance.itemCategory = PETC:GetItemCategory(rewardData.itemID)
    
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
    
    instance.itemID = itemID
    instance.itemCategory = PETC:GetItemCategory(itemID)
    instance.itemIcon = PETC.Textures[itemID]

    if quantity ~= nil then 
        instance.quantity = quantity
    else
        instance.quantity = 1
    end

    return instance
end

function Reward:IsItem()
    return self.itemID ~= nil
end

function Reward:IsPet()
    return self.pet ~= nil
end

function Reward:HasIcon()
    return self.itemIcon ~= nil
end

function Reward:Link()
    if self._link == nil then
        if self:IsPet() then
            self._link = nil
        elseif self:IsItem() then
            self._link = select(2, GetItemInfo(self.itemID))
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
        if self:IsPet() then 
            self._display = self:Link()
        elseif self:IsItem() then
            if self:HasIcon() then
                self._display = self.quantity.."x".."|T"..self.itemIcon..":20:20:0:0:32:32:2:30:2:30|t"
            else
                self._display = self.quantity.."x"..self:Link()
            end
        else
            self._display = "unknown reward type"
        end
    end

    return self._display
end

return Reward