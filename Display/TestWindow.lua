---@class PetAdvisor
local PETAD = PetAdvisor
local DISPLAY = PETAD.DISPLAY

local function CreateWindow()
    local f = CreateFrame("Frame", "PATestWindow", UIParent)
    f:SetSize(150, 150)
    f:SetPoint("CENTER")
    f:SetFrameStrata("BACKGROUND")
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
    
    f.SF = CreateFrame("ScrollFrame", "$parent_DF", f, "UIPanelScrollFrameTemplate")
    f.SF:SetPoint("TOPLEFT", f, 12, -30)
    f.SF:SetPoint("BOTTOMRIGHT", f, -30, 10)
    f.Text = CreateFrame("EditBox", nil, f)
    f.Text:SetMultiLine(true)
    f.Text:SetSize(180, 170)
    f.Text:SetPoint("TOPLEFT", f.SF)
    f.Text:SetPoint("BOTTOMRIGHT", f.SF)
    f.Text:SetMaxLetters(99999)
    f.Text:SetFontObject(GameFontNormal)
    f.Text:SetAutoFocus(false)
    f.Text:SetScript("OnEscapePressed", function(self) self:ClearFocus() end) 
    f.SF:SetScrollChild(f.Text)
end

function DISPLAY.TestWindow:ShowEditBox(text)    
    if not PATestWindow then
        CreateWindow()
    end

    PATestWindow.Text:SetText(text)
end


function DISPLAY.TestWindow:ShowPetData()    
    if not PATestWindow then
        CreateWindow()
    end

    PATestWindow.Text:SetText(text)
end