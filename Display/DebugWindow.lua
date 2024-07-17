---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY

local function CreateWindow()
    local f = CreateFrame("Frame", "PCDebug", UIParent, "UIPanelDialogTemplate", "TitleDragAreaTemplate")
    f.pools = {}
    f:SetResizable(true)
    f:SetSize(600, 800)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:SetResizable(true)

    f.TitleArea = CreateFrame("Frame", nil, f)
    f.TitleArea:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -40)
    f.TitleArea:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -50, 0)
    f.TitleArea:EnableMouse(true)
    f.TitleArea:RegisterForDrag("LeftButton")
    f.TitleArea:SetScript("OnDragStart",
        function(self)
            PCDebug.moving = true
            PCDebug:StartMoving()
        end
    )
    f.TitleArea:SetScript("OnDragStop",
        function(self)
            PCDebug.moving = nil
            PCDebug:StopMovingOrSizing()
        end
    )
    f.Title:SetText("PetCollector Debug Logger")

    f.Close = CreateFrame("Button", "$parentClose", f)
    f.Close:SetSize(24, 24)
    f.Close:SetPoint("TOPRIGHT")
    f.Close:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    f.Close:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
    f.Close:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
    f.Close:SetScript("OnClick", function(self)
        PCDebug:Hide()
        PCDebug.Text:SetText("")
    end)

    f.SelectAll = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.SelectAll:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -40)
    f.SelectAll:SetWidth(150)
    f.SelectAll:SetText("Select All")
    f.SelectAll:SetScript("OnClick", function(self)
        PCDebug.Text:HighlightText()
        PCDebug.Text:SetFocus()
    end)

    f.Clear = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.Clear:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -40)
    f.Clear:SetWidth(150)
    f.Clear:SetText("Clear")
    f.Clear:SetScript("OnClick", function(self)
        PCDebug.Text:SetText("")
    end)

    local resizeButton = CreateFrame("Button", nil, f)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4,6)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnMouseDown", 
        function(self, button)
            PCDebug:StartSizing("BOTTOMRIGHT")
            PCDebug:SetUserPlaced(true)
        end)     
    resizeButton:SetScript("OnMouseUp", 
        function(self, button)
            PCDebug:StopMovingOrSizing()
        end)
    
    f.SF = CreateFrame("ScrollFrame", "$parent_DF", f, "UIPanelScrollFrameTemplate")
    f.SF:SetPoint("TOPLEFT", f.SelectAll, "BOTTOMLEFT", 5, -3)
    f.SF:SetPoint("BOTTOMRIGHT", f, -30, 18)
    f.Text = CreateFrame("EditBox", nil, f)
    f.Text:SetMultiLine(true)
    f.Text:SetSize(1000, 5000)
    f.Text:SetPoint("TOPLEFT", f.SF)
    f.Text:SetPoint("BOTTOMRIGHT", f.SF)
    f.Text:SetMaxLetters(99999)
    f.Text:SetFontObject(GameFontNormal)
    f.Text:SetAutoFocus(false)
    f.Text:SetScript("OnEscapePressed", function(self) self:ClearFocus() end) 
    f.SF:SetScrollChild(f.Text)
end

function DISPLAY.Debug:Show()    
    if not PCDebug then
        CreateWindow()
    end

    PCDebug:Show()
end

function DISPLAY.Debug:AddLine(file, method, ...)
    if (PCDebug and PCDebug:IsVisible()) then
        local arg={...}
        local msg = string.format("%s\n%s.%s - ", PCDebug.Text:GetText(), file, method)
        for _, val in ipairs(arg) do
            msg = msg .. tostring(val)
        end
        PCDebug.Text:SetText(msg)
    end
end