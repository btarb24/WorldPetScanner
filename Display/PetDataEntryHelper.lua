---@class PetAdvisor
local PETAD = PetAdvisor
local DISPLAY = PETAD.DISPLAY
local UTILITIES = PETAD.UTILITIES
local PETS = PETAD.PETS

local function EnsureBPBIDLoaded()
    --must have BattlePetBreedID addon loaded
    if (not BPBID_Arrays) then
        print("must have BattlePetBreedID addon loaded to get breed info")
        return
    end

    if (not BPBID_Arrays.BreedsPerSpecies) then
        BPBID_Arrays.InitializeArrays()
    end
end

local function DeserializeCommaDelim(locationsStr)
    local split = strsplittable(",", locationsStr)
    local result = ""
    for i = 1, #split do
        result = result.."\""..strtrim(split[i]).."\""
        if i ~= #split then
            result = result..", "
        end
    end
    return result
end

local function ExtractNPC(locationsStr)
    local split = UTILITIES:split(locationsStr, "|r", true)
    return DeserializeCommaDelim(UTILITIES:split(split[2], "|n", true)[1])
end

local function ExtractZones(locationsStr)
    local split = UTILITIES:split(locationsStr, "|r", true) -- |r
    return DeserializeCommaDelim(split[#split])
end

local function ExtractVendorZone(locationsStr)
    local split = UTILITIES:split(locationsStr, "|r", true)
    return DeserializeCommaDelim(UTILITIES:split(split[3], "|n", true)[1])
end

local function GetPossibleBreedsBySpeciesID(speciesID)
    local breedIds = BPBID_Arrays.BreedsPerSpecies[tonumber(speciesID)]
    local result = ""
    for i = 1, #breedIds do
        result = result..tostring(breedIds[i])
        if i ~= #breedIds then
            result = result..", "
        end
    end

    return result
end

local function GetBaseStatsBySpeciesID(speciesID)
    local baseStats = BPBID_Arrays.BasePetStats[tonumber(speciesID)]
    local result = ""
    for i = 1, #baseStats do
        result = result..tostring(baseStats[i])
        if i ~= #baseStats then
            result = result..", "
        end
    end

    return result
end

local function GetCurrency(tooltipSource)
    if strfind(tooltipSource, "MONEYFRAME") then
        return "gold"
    elseif strfind(tooltipSource, "Currency_PetBattle") then
        return "charms"
    else
        return "item"
    end
end

local function ParseMoreSourceData(tooltipSource)
    print("-------------------------")
    print(tooltipSource)
    local source, locations = strsplit(":", tooltipSource);
    if strfind(tooltipSource, "Achievement") then
        return "        source = \"Achievement\",\n"..
               "        achievementName = "..ExtractNPC(tooltipSource)..",\n"..
               "        achievementId = \"\",\n"
    elseif strfind(tooltipSource, "Pet Battle") then
        return "        source = \"Pet Battle\",\n"..
               "        locationsRaw = {"..DeserializeCommaDelim(locations).."},\n"
    elseif strfind(tooltipSource, "Fishing") then
        return "        source = \"Fishing\",\n"..
               "        locationsRaw = {"..ExtractZones(tooltipSource).."},\n"
    elseif strfind(tooltipSource, "Archaeology") then
        return "        source = \"Archaeology\",\n"
    elseif strfind(tooltipSource, "Profession") then
        return "        source = \"Profession\",\n"..
               "        profession = \""..strtrim(locations).."\",\n"
    elseif strfind(tooltipSource, "World Event") then
        return "        source = \"World Event\",\n"..
               "        event = "..ExtractNPC(tooltipSource)..",\n"
    elseif strfind(tooltipSource, "Vendor") then
        return "        source = \"Vendor\",\n"..
               "        currency = \""..GetCurrency(tooltipSource).."\",\n"..
               "        npc = {"..ExtractNPC(tooltipSource).."},\n"..
               "        locationsRaw = {"..ExtractVendorZone(tooltipSource).."},\n"
    elseif strfind(tooltipSource, "World Drop") then
        return "        source = \"World Drop\",\n"..
               "        locationsRaw = {"..ExtractZones(tooltipSource).."},\n"
    elseif strfind(tooltipSource, "Drop") then
        return "        source = \"Drop\",\n"..
               "        npc = {"..ExtractNPC(tooltipSource).."},\n"..
               "        locationsRaw = {"..ExtractZones(tooltipSource).."},\n"
    elseif strfind(tooltipSource, "Quest") then
        return "        source = \"Quest\",\n"..
               "        quest = "..ExtractNPC(tooltipSource)..",\n"..
               "        locationsRaw = {"..ExtractVendorZone(tooltipSource).."},\n"
    elseif strfind(tooltipSource, "Promotion") then
        return "        source = \"Promotion\",\n"..
               "        promotion = "..ExtractNPC(tooltipSource)..",\n"
    elseif strfind(tooltipSource, "Trading Card Game") then
        return "        source = \"Trading Card Game\",\n"..
               "        tcg = "..ExtractNPC(tooltipSource)..",\n"
    elseif strfind(tooltipSource, "Treasure") then
        return "        source = \"Treasure\",\n"..
               "        item = "..ExtractNPC(tooltipSource)..",\n"..
               "        locationsRaw = {"..ExtractVendorZone(tooltipSource).."},\n"
    elseif strfind(tooltipSource, "Game Shop") then
        return "        source = \"In-Game Shop\",\n"
    elseif strfind(tooltipSource, "Trading Post") then
        return "        source = \"Trading Post\",\n"
    end
    
end

local function FindPetBySpeciesID(speciesID, raw)
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID
           = C_PetJournal.GetPetInfoBySpeciesID(speciesID)

    if not tooltipSource or tooltipSource == "" then
        return false
    end

    local result = ""..
    ",\n"..
    "    ["..speciesID.."] = {\n"..
    "        name = \""..speciesName.."\",\n"..
    "        speciesID = "..tostring(speciesID)..",\n"..
    "        companionID = "..tostring(companionID)..",\n"..
    "        petType = \""..PETS.FAMILIES[petType].."\",\n"..
    "        possibleBreeds = {"..GetPossibleBreedsBySpeciesID(speciesID).."},\n"..
    "        baseStats = {"..GetBaseStatsBySpeciesID(speciesID).."},\n"..
    "        isWild = "..tostring(isWild)..",\n"..
    "        isTradeable = "..tostring(isTradeable)..",\n"..
    "        isUnique = "..tostring(isUnique)..",\n"..
    "        canBattle = "..tostring(canBattle)..",\n"

        if raw then
            result = result .. tooltipSource.."\n"
        else
            local more = ParseMoreSourceData(tooltipSource)
            if more then
                result = result..more
            end
        end
    
    if tooltipDescription then
        result = result..
    "        tooltipDescription = \""..tooltipDescription.."\",\n"
    end
    if speciesIcon then
        result = result..
    "        iconPath = \""..speciesIcon.."\",\n"
    end
    if creatureDisplayID then
        result = result..
    "        displayID = "..creatureDisplayID..",\n"
    end
    result = result..
    "    }";

    PAPetDataEntryHelper.Text:SetText(result)
    PAPetDataEntryHelper.Text:HighlightText()
    PAPetDataEntryHelper.Text:SetFocus()
    return true
end

local function GetNextPet(raw)
    local curSpeciesIDTxt = PAPetDataEntryHelper.SpeciesEntry:GetText()
    if not curSpeciesIDTxt or curSpeciesIDTxt == "" then
        curSpeciesIDTxt = "1"
    end

    local curSpeciesID = tonumber(curSpeciesIDTxt)

    for i = curSpeciesID+1, #BPBID_Arrays.BreedsPerSpecies do
        if (BPBID_Arrays.BreedsPerSpecies[i]) then
            local isCollectable = FindPetBySpeciesID(i, raw)
            if (isCollectable) then
                PAPetDataEntryHelper.SpeciesEntry:SetText(i)
                return
            end
        end
    end
end

local function CreateWindow()
    local f = CreateFrame("Frame", "PAPetDataEntryHelper", UIParent, "UIPanelDialogTemplate", "TitleDragAreaTemplate")
    f:SetResizable(true)
    f:SetSize(1200, 600)
    f:SetPoint("CENTER")
    f:SetFrameStrata("BACKGROUND")
    f:SetMovable(true)
    f:SetResizeBounds(200, 200)

    f.TitleArea = CreateFrame("Frame", nil, f)
    f.TitleArea:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -40)
    f.TitleArea:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -50, 0)
    f.TitleArea:EnableMouse(true)
    f.TitleArea:RegisterForDrag("LeftButton")
    f.TitleArea:SetScript("OnDragStart",
        function(self)
            PAPetDataEntryHelper.moving = true
            PAPetDataEntryHelper:StartMoving()
        end
    )
    f.TitleArea:SetScript("OnDragStop",
        function(self)
            PAPetDataEntryHelper.moving = nil
            PAPetDataEntryHelper:StopMovingOrSizing()
        end
    )
        
    f.ResizeButton = CreateFrame("Button", nil, f)
    f.ResizeButton:SetSize(16, 16)
    f.ResizeButton:SetPoint("BOTTOMRIGHT", f, -3,6)
    f.ResizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.ResizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    f.ResizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    f.ResizeButton:SetScript("OnMouseDown", 
        function(self, button)
            PAPetDataEntryHelper:StartSizing("BOTTOMRIGHT")
            PAPetDataEntryHelper:SetUserPlaced(true)
        end)     
        f.ResizeButton:SetScript("OnMouseUp", 
        function(self, button)
            PAPetDataEntryHelper:StopMovingOrSizing()
        end)

    f.Close = CreateFrame("Button", "$parentClose", f)
    f.Close:SetSize(24, 24)
    f.Close:SetPoint("TOPRIGHT")
    f.Close:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    f.Close:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
    f.Close:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
    f.Close:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)

    f.Select = CreateFrame("Button", "$parentSelect", f, "UIPanelButtonTemplate")
    f.Select:SetSize(14, 14)
    f.Select:SetPoint("RIGHT", f.Close, "LEFT")
    f.Select:SetText("S")
    f.Select:SetScript("OnClick", function(self)
        self:GetParent().Text:HighlightText() -- parameters (start, end) or default all
        self:GetParent().Text:SetFocus()
    end)

    local speciesEntryLbl = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    speciesEntryLbl:SetPoint("TOPLEFT", f, 20, -50)
    speciesEntryLbl:SetText("speciesID: ")
    f.SpeciesEntry = CreateFrame("EditBox", nil, f)
    f.SpeciesEntry:SetSize(100, 20)
    f.SpeciesEntry:SetPoint("LEFT", speciesEntryLbl, "RIGHT")
    f.SpeciesEntry:SetFontObject(GameFontNormal)
    f.SpeciesEntry:SetMaxLetters(100)
    f.SpeciesEntry.bg = f.SpeciesEntry:CreateTexture(nil, "BACKGROUND")
    f.SpeciesEntry.bg:SetAllPoints(true)
    f.SpeciesEntry.bg:SetColorTexture(.4, .4,.4,.7)
    f.SpeciesEntry:SetScript("OnEnterPressed", function(self) FindPetBySpeciesID(self:GetText()); self:SetText(""); end) 
    f.SpeciesEntry:SetScript("OnEscapePressed", function(self) self:ClearFocus() end) 

    f.NextButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.NextButton:SetPoint("LEFT", f.SpeciesEntry, "RIGHT", 20,0)
    f.NextButton:SetSize(80, 24)
    f.NextButton:SetText("next")
    f.NextButton:SetScript("OnClick", function(self)
        GetNextPet()
    end)

    f.RawButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.RawButton:SetPoint("LEFT", f.NextButton, "RIGHT", 20,0)
    f.RawButton:SetSize(80, 24)
    f.RawButton:SetText("raw")
    f.RawButton:SetScript("OnClick", function(self)
        GetNextPet(true)
    end)
    
    f.SF = CreateFrame("ScrollFrame", "$parent_DF", f, "UIPanelScrollFrameTemplate")
    f.SF:SetPoint("TOPLEFT", f, 12, -80)
    f.SF:SetPoint("BOTTOMRIGHT", f, -30, 30)
    f.SF.bg = f.SF:CreateTexture(nil, "BACKGROUND")
    f.SF.bg:SetAllPoints(true)
    f.SF.bg:SetColorTexture(.2, .2,.2,.1)

    f.Text = CreateFrame("EditBox", nil, f.SF)
    f.Text:SetSize(1400, 1000)
    f.Text:SetMultiLine(true)
    f.Text:SetPoint("TOPLEFT", f.SF)
    f.Text:SetPoint("BOTTOMRIGHT", f.SF)
    f.Text:SetMaxLetters(99999)
    f.Text:SetFontObject(GameFontNormal)
    f.Text:SetAutoFocus(false)
    f.Text.bg = f.Text:CreateTexture(nil, "BACKGROUND")
    f.Text.bg:SetAllPoints(true)
    f.Text.bg:SetColorTexture(.4, .4,.4,.7)
    f.Text:SetScript("OnEscapePressed", function(self) self:ClearFocus() end) 
    f.SF:SetScrollChild(f.Text)
    
    f.SF:GetHeight()
    f.Text:GetHeight()
end

function DISPLAY.PetDataEntryHelper:Show()
    EnsureBPBIDLoaded()
    if not PAPetDataEntryHelper then
        CreateWindow()
    end

    PAPetDataEntryHelper:Show()
end