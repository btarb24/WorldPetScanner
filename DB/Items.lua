local PETC = PetCollector

PETC.PetCharm = 163036
PETC.Bandage = 86143
PETC.BlueStone = 98715

PETC.BattleStones = {
    [137627] = true, -- ultimate - upgrade to epic
    [98715] = true,  -- marked flawless - upgrade to rare
    [92741] = true,  -- flawless - upgrade to rare
    [92742] = true,  -- polished - upgrade to uncommn
    [137391] = true, -- aquatic epic
    [137394] = true, -- beast epic
    [137393] = true, -- critter epic
    [137387] = true, -- dragonkin epic
    [137395] = true, -- elemental epic
    [137396] = true, -- flying epic
    [137388] = true, -- human epic
    [137392] = true, -- magic epic
    [137390] = true, -- mechanical epic
    [137389] = true, -- undead epic
    [92697] = true,  -- aquatic rare
    [92675] = true,  -- beast rare
    [92676] = true,  -- critter rare
    [92683] = true,  -- dragon rare
    [92665] = true,  -- elemental rare
    [92677] = true,  -- flying rare
    [92682] = true,  -- human rare
    [92678] = true,  -- magic rare
    [92680] = true,  -- mech rare
    [92681] = true  -- undead rare
}

PETC.TrainingStones = {
    [122457] = true, -- ultimate - train to 25
    [127755] = true, -- felTouched - 10k xp
    [116429] = true, -- flawless - 2k xp
    [116374] = true, -- beast
    [116418] = true, -- critter
    [116419] = true, -- dragonkin
    [116420] = true, -- elemental
    [116421] = true, -- flying
    [116416] = true, -- humanoid
    [116422] = true, -- magic
    [116417] = true, -- mechanical
    [116423] = true, -- undead
    [116424] = true  -- aqauatic
}

PETC.NotableItems = {
    [183111] = true, -- Animated Ulna
}

PETC.Textures = {
    ["pet"] = 613074,
    [PETC.PetCharm] = 2004597, -- charm
    [PETC.Bandage] = 133675, -- bandage
    [PETC.BlueStone] = 667492, -- rare upgrade
    [122457] = 667491, -- ultimate to 25
    [127755] = 667493, -- feltouched 10k
    [116429] = 1045111, -- flawless 2k
    [116374] = 1045105, -- beast 2k
    [116418] = 1045106, -- critter 2k
    [116419] = 1045107, -- dragon 2k
    [116420] = 1045108, -- elemental 2k
    [116421] = 1045109, -- flying 2k
    [116416] = 1045110, -- human 2k
    [116422] = 1045112, -- magic 2k
    [116417] = 1045113, -- mech 2k
    [116423] = 1045114, -- undead 2k
    [116424] = 1045115, -- aqua 2k
}

function PETC:GetItemCategory(itemID)
    if itemID == PETC.PetCharm then
        return PETC.REWARD_ITEMCATEGORY.CHARM
    elseif itemID == PETC.Bandage then
        return PETC.REWARD_ITEMCATEGORY.BANDAGE
    elseif PETC.TrainingStones[itemID] then
        return PETC.REWARD_ITEMCATEGORY.TRAINING_STONE
    elseif PETC.BattleStones[itemID] then
        return PETC.REWARD_ITEMCATEGORY.BATTLE_STONE
    else 
        return nil
    end
end

PETC.IconColumnWidth = 120
function PETC:GetIconIndent(itemCategory)
    if itemCategory == PETC.REWARD_ITEMCATEGORY.CHARM then
        return 0
    elseif itemCategory == PETC.REWARD_ITEMCATEGORY.BANDAGE then
        return 30
    elseif itemCategory == PETC.REWARD_ITEMCATEGORY.BATTLE_STONE then
        return 60
    elseif itemCategory == PETC.REWARD_ITEMCATEGORY.TRAINING_STONE then
        return 90
    else 
        return -30 -- just to notice it
    end
end