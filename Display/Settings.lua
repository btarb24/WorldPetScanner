local file="Settings"

local PETC = PetCollector
local EVENTS = PETC.EVENTS
local DISPLAY = PETC.DISPLAY
local SETTINGS = DISPLAY.Settings
local DEBUG = PETC.DISPLAY.Debug

local summonPetTrigger_Options = {
    [1]={value = "login", display="Login"},
    [2]={value = "dismount", display="Dismount"},
    [3]={value = "zone", display="Zone change"},
    [4]={value = "petWin", display="Win pet battle"},
    [5]={value = "petLose", display="Lose pet battle"},
    [6]={value = "jump", display="Jump"},
    [7]={value = "periodic", display="Periodic time"},
    [8]={value = "random", display="Random time"},
    [9]={value = "spec", display="Spec change"},
}
local function GetTriggerByValue(val)
    for trigger in ipairs(summonPetTrigger_Options) do
        if (trigger.value == val) then
            return trigger
        end
    end
end

local function SetSettingValue(backingVariable, value)
    local method = "SetSettingValue"
    local oldVal = PETC_Settings[backingVariable];
    if (oldVal == value) then
        return
    end

    DEBUG:AddLine(file, method, "var:", backingVariable, " oldVal:", oldVal, " newVal:", value)
    PETC_Settings[backingVariable] = value
    EVENTS.Raise(SETTINGS, backingVariable.."_Changed", oldVal, value)
end

local function PetTotal_Click(checkbox)
    PETC_Settings.petTotal = checkbox:GetChecked()
    if (PETC_Settings.petTotal) then
        DISPLAY.TotalPets:Show()
        print("Pet Total shown - scroll to change scale; drag to move")
    else
        DISPLAY.TotalPets:Hide()
    end
end

local function GenericCheckbox_Click(checkbox)
    SetSettingValue(checkbox.backingVariable, checkbox:GetChecked())
end

local function SummonPetTrigger_MenuClosed(hmm, dropdown)
    local selectedTrigger = PETC_Settings[dropdown.backingVariable]
    if (selectedTrigger == "periodic") then
        PAMainFrameTab5.content.summonPetPeriodicMinutes:Show()
    else
        PAMainFrameTab5.content.summonPetPeriodicMinutes:Hide()
    end

    if (selectedTrigger == "random") then
        PAMainFrameTab5.content.summonPetRandomMinMinutes:Show()
        PAMainFrameTab5.content.summonPetRandomMaxMinutes:Show()
    else
        PAMainFrameTab5.content.summonPetRandomMinMinutes:Hide()
        PAMainFrameTab5.content.summonPetRandomMaxMinutes:Hide()
    end
end

local function CreateSettingFrame(parent, topDock)
    local settingFrame = CreateFrame("Frame", nil, parent)
    if (topDock) then
       settingFrame:SetPoint("TOPLEFT", topDock, "BOTTOMLEFT", 0, -5)
       settingFrame:SetPoint("RIGHT", topDock, "RIGHT", 5, 0)
    else
       settingFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 7, -30)
       settingFrame:SetPoint("RIGHT", parent, "RIGHT", 5, 0)
    end

    return settingFrame
end

local function CreateSettingLabel(parent, settingFrame, label, depth)
    settingFrame.lbl = settingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    settingFrame.lbl:SetText(label)
    settingFrame.lbl:SetPoint("TOPLEFT", settingFrame, "TOPLEFT", 35 + (depth*20), -7)
end

local function CreateCheckBoxSetting(parent, topDock, label, clickFunction, backingVariable, depth)
    if (depth == nil) then 
        depth = 0
    end

    local settingFrame = CreateSettingFrame(parent, topDock)
    settingFrame.lbl = CreateSettingLabel(parent, settingFrame, label, depth)

    settingFrame.chk = CreateFrame("CheckButton", nil, settingFrame, "SettingsCheckBoxTemplate")
    settingFrame.chk:SetPoint("TOPLEFT", settingFrame, "TOPLEFT", 300, 0)    
    settingFrame.chk:SetChecked(PETC_Settings[backingVariable] == true)
    settingFrame.chk:SetScript("OnEnter", nil)
    settingFrame.chk:HookScript("OnClick", clickFunction)
    settingFrame.chk.backingVariable = backingVariable

    settingFrame:SetHeight(settingFrame.chk:GetHeight())    
    return settingFrame
end

local function CreateSubTextboxSetting(parent, leftDock, label, backingVariable)
    local subFrame = CreateFrame("Frame", nil, parent)
    local hMargin = 15
    subFrame:SetPoint("LEFT", leftDock, "RIGHT", hMargin, 0)
    subFrame:SetPoint("CENTER", leftDock, "CENTER")

    local lbl = subFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    lbl:SetPoint("LEFT", subFrame, "LEFT")    
    lbl:SetPoint("CENTER", subFrame, "CENTER", 0, 0)
    lbl:SetText(label)

    local txtBox = CreateFrame("EditBox", nil, subFrame, "InputBoxTemplate")
    txtBox:SetNumeric(true)
    txtBox:SetAutoFocus(false)
    txtBox:SetPoint("LEFT", lbl, "RIGHT", hMargin, 0)
    txtBox:SetPoint("CENTER", subFrame, "CENTER", 0, 0)
    txtBox:SetWidth(50)
    txtBox:SetHeight(leftDock:GetHeight())
    txtBox:SetText(PETC_Settings[backingVariable])
    txtBox.backingVariable = backingVariable
    txtBox:SetScript("OnTextChanged", function(self)
        local num = tonumber(self:GetText())
        if num then
            SetSettingValue(backingVariable, num)
        end
    end)

    subFrame:SetWidth(lbl:GetWidth() + hMargin + txtBox:GetWidth())
    subFrame:SetHeight(leftDock:GetHeight())
    return subFrame
end

local function CreateDropdownSetting(parent, topDock, label, options, menuClosedFunction, backingVariable, depth)
    if (depth == nil) then 
        depth = 0
    end

    local settingFrame = CreateSettingFrame(parent, topDock)
    settingFrame.lbl = CreateSettingLabel(parent, settingFrame, label, depth)

    local function IsSelected(menuItem)
        return menuItem.value == PETC_Settings[backingVariable]
    end
    local function SetSelected(menuItem)
        SetSettingValue(backingVariable, menuItem.value)
    end
    
    local function GeneratorFunction(dropdown, rootDescription)        
        local function OnEnter(button)
            button.HighlightBGTex:SetAlpha(0.15);

            local description = button:GetElementDescription();
            if description:IsEnabled() and not description:IsSelected() then
                button.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
            end
        end

        local function OnLeave(button)
            button.HighlightBGTex:SetAlpha(0);

            local description = button:GetElementDescription();
            if description:IsEnabled() and not description:IsSelected() then
                button.Text:SetTextColor(VERY_LIGHT_GRAY_COLOR:GetRGB());
            end

            MenuUtil.HideTooltip(button);
        end
    
        for idx, data in ipairs(dropdown.optionsList) do
            local menuItem = rootDescription:CreateTemplate("SettingsDropdownButtonTemplate");
            MenuUtil.SetElementText(menuItem, data.display);
            menuItem:SetIsSelected(IsSelected);
            menuItem:SetResponder(SetSelected);
            menuItem:SetOnEnter(OnEnter); 
            menuItem:SetOnLeave(OnLeave);
            menuItem:SetRadio(true);
            menuItem:SetData({
                label = data.display,
                text = data.display,
                value = data.value
            });
            
            menuItem:AddInitializer(function(button, description, menu)
                button:SetScript("OnClick", function(button, buttonName)
                    description:Pick(MenuInputContext.MouseButton, buttonName);
                end);

                button.Text:Show();
                button.Text:SetTextToFit(data.display);
                button.Text:SetWidth(button.Text:GetWidth() + 10);
                button.HighlightBGTex:SetAlpha(0);

                if description:IsSelected() then
                    button.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGBA());
                elseif description:IsEnabled() then
                    button.Text:SetTextColor(VERY_LIGHT_GRAY_COLOR:GetRGB());
                else
                    button.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
                end

                button:Layout();
            end);
        end
    end

    --AddOns\Blizzard_Menu\11_0_0_MenuImplementationGuide.lua
    settingFrame.cmb = CreateFrame("DropdownButton", nil, settingFrame, "WowStyle2DropdownTemplate")
    settingFrame.cmb.optionsList = options
    settingFrame.cmb:SetPoint("TOPLEFT", settingFrame, "TOPLEFT", 300, 0)
    settingFrame.cmb:SetupMenu(GeneratorFunction);
    settingFrame.cmb:RegisterCallback(DropdownButtonMixin.Event.OnMenuClose, menuClosedFunction)
    settingFrame.cmb.backingVariable = backingVariable

    settingFrame:SetHeight(settingFrame.cmb:GetHeight())
    return settingFrame
end

function SETTINGS:EstablishDefaults()
    if PETC_Settings == nil then
        PETC_Settings = {}
    end
    if (PETC_Settings.petTotal == nil) then
        PETC_Settings.petTotal = false
    end
    if (PETC_Settings.summonPet == nil) then
        PETC_Settings.summonPet = false
    end
    if (PETC_Settings.summonPet_Trigger == nil) then
        PETC_Settings.summonPet_Trigger = "login"
    end
    if (PETC_Settings.summonPet_LimitToFaves == nil) then
        PETC_Settings.summonPet_LimitToFaves = false
    end
    if (PETC_Settings.summonPet_PeriodicMinutes == nil) then
        PETC_Settings.summonPet_PeriodicMinutes = 15
    end
    if (PETC_Settings.summonPet_RandomMinMinutes == nil) then
        PETC_Settings.summonPet_RandomMinMinutes = 5
    end
    if (PETC_Settings.summonPet_RandomMaxMinutes == nil) then
        PETC_Settings.summonPet_RandomMaxMinutes = 120
    end
    
    if PETC_States == nil then
        PETC_States = {}
    end
end

function SETTINGS:Initialize()
    local tabContent = PAMainFrameTab5.content

    tabContent.petTotal = CreateCheckBoxSetting(tabContent, nil, "Show total pets collected", PetTotal_Click, "petTotal")
    tabContent.summonPet = CreateCheckBoxSetting(tabContent, tabContent.petTotal, "Summon random pet", GenericCheckbox_Click, "summonPet")
    tabContent.summonPetLimitToFaves = CreateCheckBoxSetting(tabContent, tabContent.summonPet, "Limit to only favorites", GenericCheckbox_Click, "summonPet_LimitToFaves", 1)
    tabContent.summonPetTrigger = CreateDropdownSetting(tabContent, tabContent.summonPetLimitToFaves, "When to summon a new pet", summonPetTrigger_Options, SummonPetTrigger_MenuClosed, "summonPet_Trigger", 1)
    tabContent.summonPetPeriodicMinutes = CreateSubTextboxSetting(tabContent, tabContent.summonPetTrigger.cmb, "Minutes:", "summonPet_PeriodicMinutes")
    tabContent.summonPetRandomMinMinutes = CreateSubTextboxSetting(tabContent, tabContent.summonPetTrigger.cmb, "Min minutes:", "summonPet_RandomMinMinutes")
    tabContent.summonPetRandomMaxMinutes = CreateSubTextboxSetting(tabContent, tabContent.summonPetRandomMinMinutes, "Max minutes:", "summonPet_RandomMaxMinutes")
    SummonPetTrigger_MenuClosed(nil, tabContent.summonPetTrigger.cmb)

end

function SETTINGS:UpdatePetTotal()
    PAMainFrameTab5.content.petTotal.chk:SetChecked(PETC_Settings.petTotal == true)
end