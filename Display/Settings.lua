---@class PetCollector
local PETC = PetCollector
local DISPLAY = PETC.DISPLAY

function DISPLAY.Settings:Initialize()
    local tabContent = PAMainFrameTab5.content

    tabContent.petTotal = CreateFrame("Frame", nil, tabContent)
    tabContent.petTotal:SetPoint("TOPLEFT", tabContent, "TOPLEFT", 7, -30)
    tabContent.petTotal:SetPoint("RIGHT", tabContent, "RIGHT", 5, 0)
    tabContent.petTotal.lbl = tabContent.petTotal:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tabContent.petTotal.lbl:SetText("Show total pets collected")
    tabContent.petTotal.lbl:SetPoint("TOPLEFT", tabContent.petTotal, "TOPLEFT", 35, -7)
    tabContent.petTotal.chk = CreateFrame("CheckButton", nil, tabContent.petTotal, "SettingsCheckBoxTemplate")
    DISPLAY.Settings:UpdatePetTotal()
    tabContent.petTotal.chk:SetPoint("TOPLEFT", tabContent.petTotal, "TOPLEFT", 300, 0)
    tabContent.petTotal.chk:HookScript("OnClick", function(self)
        if (self:GetChecked()) then
			DISPLAY.TotalPets:Show()
			print("Pet Total shown - scroll to change scale; drag to move")
        else            
			DISPLAY.TotalPets:Hide()
        end
    end)

    tabContent.petTotal:SetHeight(tabContent.petTotal.chk:GetHeight())
end

function DISPLAY.Settings:UpdatePetTotal()
    PAMainFrameTab5.content.petTotal.chk:SetChecked(PETC_Settings.petTotal == true)
end