---@class PetAdvisor
local PETAD = PetAdvisor
local DATA = PETAD.DATA
local DISPLAY = PETAD.DISPLAY
local UTILITIES = PETAD.UTILITIES
local TASKFINDER = PETAD.TASKFINDER

local LibQTip = LibStub("LibQTip-1.0")

-- Blizzard
local IsActive = C_TaskQuest.IsActive
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetBountiesForMapID = C_QuestLog.GetBountiesForMapID
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink
local L = PETAD.L

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj =
	ldb:NewDataObject("PetAdvisor",
		{
			type = "data source",
			text = "PetAdvisor",
			icon = "Interface\\Icons\\Inv_pet_maggot"
		}
	)

local icon = LibStub("LibDBIcon-1.0")

local function BuildPetList()
	DATA.petList = {}
	local total, collected = C_PetJournal.GetNumPets()
	for i = 1, total do
		local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)		
		if (petID ~= nil and owned) then
			table.insert(DATA.petList, companionID, owned)
		end
	end
end

function PETAD:OnInitialize()
	self.faction = UnitFactionGroup("player")

	self.db = LibStub("AceDB-3.0"):New("PETAD_DB", defaults, true)

	-- Defaults
	local defaults = {
		profile = {
			options = {
				LibDBIcon = { hide = false }
			},
		},
		global = {
		}
	}
	self.db = LibStub("AceDB-3.0"):New("PETAD_DB", defaults, true)

	-- Minimap Icon
	icon:Register("PetAdvisor", dataobj, self.db.profile.options.LibDBIcon)
end

function PETAD:OnEnable()
	BuildPetList()
	DISPLAY:CreateHostWindow()
	TASKFINDER:RefreshTodaysEvents(mode)
end

PETAD:RegisterChatCommand("tpa", "ChatCommand")
PETAD:RegisterChatCommand("pa", "ChatCommand")
function PETAD:ChatCommand(input)
	local arg1 = string.lower(input)
	self:Show(arg1)
end

function PETAD:UpdateMinimapIcon()
	if self.db.profile.options.LibDBIcon.hide then
		icon:Hide("PetAdvisor")
	else
		icon:Show("PetAdvisor")
	end
end

function dataobj:OnClick(button)
	local mode

	if button == "LeftButton" then
		if IsControlKeyDown() then 
			mode = "test"
		end
		
	elseif button == "RightButton" then
		mode ="report"
	end
	
	TASKFINDER:RefreshTodaysEvents(mode)
	PETAD:Show(mode)
end

function PETAD:Show(mode)
	if (DISPLAY.Report.PopUp) then		
		DISPLAY.Report:CloseWindow()
		return
	end
	
	local isPartialResult = not UTILITIES:IsEmpty(DATA.questsToRetry)
	if (mode == "report") then
		DISPLAY.Report:ShowWindow(mode, isPartialResult)
	else
		DISPLAY.Main:ShowWindow(mode)
	end
end

PETAD.debug = true
function PETAD:Debug(...)
	if self.debug == true then
		print(...)
	end
end