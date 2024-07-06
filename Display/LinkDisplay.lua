---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY

local function CreateWindow()
    local f = CreateFrame("Frame", "PALinkWindow", UIParent, "UIPanelDialogTemplate", "TitleDragAreaTemplate")
    f:SetSize(500, 110)
    f:SetPoint("CENTER")
    f:SetFrameStrata("TOOLTIP")
    f:SetMovable(true)
    f:EnableMouse(true)

    f.TitleArea = CreateFrame("Frame", nil, f)
    f.TitleArea:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -40)
    f.TitleArea:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -50, 0)
    f.TitleArea:EnableMouse(true)
    f.TitleArea:RegisterForDrag("LeftButton")
    f.TitleArea:SetScript("OnDragStart",
        function(self)
            PALinkWindow.moving = true
            PALinkWindow:StartMoving()
        end
    )
    f.TitleArea:SetScript("OnDragStop",
        function(self)
            PALinkWindow.moving = nil
            PALinkWindow:StopMovingOrSizing()
        end
    )

    f.title = f.TitleArea:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.title:SetPoint("TOP", f.TitleArea, "TOP", 20, -10)

    f.tip = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    f.tip:SetText("Copy the url and paste into your browser")
    f.tip:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -40)

    f.Text = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.Text:SetMultiLine(true)
    f.Text:SetSize(180, 170)
    f.Text:SetPoint("TOPLEFT", f.tip, "BOTTOMLEFT", 0, -20)
    f.Text:SetPoint("RIGHT", f, "RIGHT", -10, 0)
    f.Text:SetMaxLetters(99999)
    f.Text:SetFontObject(GameFontHighlight)
    f.Text:SetAutoFocus(false)
    f.Text:SetScript("OnEscapePressed", function(self) 
        self:ClearFocus() 
        f:Hide()
    end) 
end

function DISPLAY.LinkWindow:Show(title, text)    
    if not PALinkWindow then
        CreateWindow()
    end

    PALinkWindow.Text:SetText(text)
    PALinkWindow.title:SetText(title)
    PALinkWindow:Show()
    PALinkWindow.Text:HighlightText()
    PALinkWindow.Text:SetFocus()
end