local file="TotalPets"

local PETC = PetCollector
local DISPLAY = PETC.DISPLAY
local PETS = PETC.PETS
local UTILITIES = PETC.UTILITIES

local function UpdateCount()
    local uniqueOwnedCount = 0

    for _, pet in pairs(PETS.all) do
        if (not UTILITIES:IsEmpty(pet.collected)) then
            uniqueOwnedCount = uniqueOwnedCount +1;
        end
    end
    PCTotalPets.content.petCount:SetText(uniqueOwnedCount)
end

local function Event_OnEvent(self, event, name, ...)
    UpdateCount()
end

local function CreateWindow()
    local f = CreateFrame("Frame", "PCTotalPets", UIParent)
    local fWidth = 350
    local fHeight = 80
    f:SetSize(fWidth, fHeight)
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)

    f.content = CreateFrame("Frame", nil, f)
    f.content:SetPoint("Center", f)
    f.content:SetSize(fWidth, fHeight)
    f.content:EnableMouse(true)
    f.content:SetClampedToScreen(true)

    f.content:RegisterForDrag("LeftButton")
    f.content:SetScript("OnDragStart",
        function(self)
            PCTotalPets.moving = true
            PCTotalPets:StartMoving()
        end
    )
    f.content:SetScript("OnDragStop",
        function(self)
            PCTotalPets.moving = nil
            PCTotalPets:StopMovingOrSizing()
            PETC_States.totalPet_Bottom = PCTotalPets:GetBottom()
            PETC_States.totalPet_Left = PCTotalPets:GetLeft()
        end
    )
    
	f.content:SetScript("OnMouseWheel", function(self, delta)
        local curScale = self:GetScale()
        if (delta>0) then
            if (curScale < 8) then
                local scale = curScale + .05
                self:SetScale(scale)
                PETC_States.totalPet_Scale = scale
            end
        else
            if (curScale > .1) then
                local scale = curScale - .05
                self:SetScale(scale)
                PETC_States.totalPet_Scale = scale
            end
        end
    end);

    f.content.bgGradientL = f.content:CreateTexture(nil, "BACKGROUND")
    f.content.bgGradientL:SetColorTexture(0,0,0)
    f.content.bgGradientL:SetGradient("HORIZONTAL", CreateColor(0,0,0, .2), CreateColor(0,0,0, .75))
    f.content.bgGradientL:SetPoint("TOP", f.content, "TOP", 0, -2)
    f.content.bgGradientL:SetPoint("BOTTOM", f.content, "BOTTOM", 0, 11)
    f.content.bgGradientL:SetPoint("LEFT", f.content, "LEFT", 0,0)
    f.content.bgGradientL:SetPoint("RIGHT", f.content, "CENTER")
    f.content.bgGradientR = f.content:CreateTexture(nil, "BACKGROUND")
    f.content.bgGradientR:SetColorTexture(1,1,1)
    f.content.bgGradientR:SetGradient("HORIZONTAL", CreateColor(0,0,0, .75), CreateColor(0,0,0, .2))
    f.content.bgGradientR:SetPoint("TOP", f.content, "TOP", 0, -2)
    f.content.bgGradientR:SetPoint("BOTTOM", f.content, "BOTTOM", 0, 11)
    f.content.bgGradientR:SetPoint("LEFT", f.content, "CENTER")
    f.content.bgGradientR:SetPoint("RIGHT", f.content, "RIGHT", -0, 0)

    f.content.topBar = f.content:CreateTexture(nil, "BACKGROUND")
    f.content.topBar:SetAtlas("UI-World-Quest-golden-line")
    f.content.topBar:SetSize(350, 5)
    f.content.topBar:SetPoint("TOP", f.content, "TOP")
    f.content.topBar:SetPoint("CENTER", f.content, "CENTER")

    f.content.bottomBar = f.content:CreateTexture(nil, "BACKGROUND")
    f.content.bottomBar:SetAtlas("UI-World-Quest-golden-line")
    f.content.bottomBar:SetSize(350, 5)
    f.content.bottomBar:SetPoint("BOTTOM", f.content, "BOTTOM", 0, 7)
    f.content.bottomBar:SetPoint("CENTER", f.content, "CENTER")

    f.content.filigree = f.content:CreateTexture(nil, "BACKGROUND")
    f.content.filigree:SetAtlas("UI-World-Quest-filigree")
    f.content.filigree:SetSize(49, 19)
    f.content.filigree:SetPoint("BOTTOM", f.content, "BOTTOM")
    f.content.filigree:SetPoint("CENTER", f.content, "CENTER")

    f.content.title = f.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge4")
    f.content.title:SetText("Pets Collected")
    f.content.title:SetPoint("TOP", f.content, "TOP", 0, -8)
    f.content.title:SetPoint("CENTER", f.content, "CENTER")

    f.content.petCount = f.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    f.content.petCount:SetTextColor(1,1,1,1)
    f.content.petCount:SetPoint("BOTTOM", f.content, "BOTTOM", 0, 20)
    f.content.petCount:SetPoint("CENTER", f.content, "CENTER")

    if (PETC_States.totalPet_Scale) then
        f.content:SetScale(PETC_States.totalPet_Scale)
    end

    if (PETC_States.totalPet_Bottom) then
        f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, PETC_States.totalPet_Bottom)
    else
        f:SetPoint("TOP", UIParent, "TOP", 0, -5)
    end

    if (PETC_States.totalPet_Left) then
        f:SetPoint("LEFT", UIParent, "LEFT", PETC_States.totalPet_Left, 0)
    else
        f:SetPoint("LEFT", UIParent, "LEFT", 20, 0)
    end
    
	f:SetScript("OnEvent", Event_OnEvent)
end

DISPLAY.TotalPets.Shown = false

function DISPLAY.TotalPets:Show()    
    if not PCTotalPets then
        CreateWindow()
        
	    PCTotalPets:RegisterEvent("NEW_PET_ADDED")
	    PCTotalPets:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
	    PCTotalPets:RegisterEvent("COMPANION_LEARNED")
	    PCTotalPets:RegisterEvent("COMPANION_UNLEARNED")
    end

    UpdateCount()
    PCTotalPets:Show()
    DISPLAY.TotalPets.Shown = true
    PETC_Settings.petTotal = true
end

function DISPLAY.TotalPets:Hide()
    PCTotalPets:Hide()
    DISPLAY.TotalPets.Shown = false
    PETC_Settings.petTotal = false
end