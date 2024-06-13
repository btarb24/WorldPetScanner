---@class WorldPetScanner
local WPS = WorldPetScanner
local DATA = WPS.DATA
local DISPLAY = WPS.DISPLAY
local UTILITIES = WPS.UTILITIES
local TASKFINDER = WPS.TASKFINDER

local LibQTip = LibStub("LibQTip-1.0")

-- Blizzard
local IsActive = C_TaskQuest.IsActive
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetBountiesForMapID = C_QuestLog.GetBountiesForMapID
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink
local L = WPS.L

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj =
	ldb:NewDataObject("WorldPetScanner",
		{
			type = "data source",
			text = "WPS",
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

function WPS:OnInitialize()
	self.faction = UnitFactionGroup("player")

	self.db = LibStub("AceDB-3.0"):New("WPSDB", defaults, true)

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
	self.db = LibStub("AceDB-3.0"):New("WPSDB", defaults, true)

	-- Minimap Icon
	icon:Register("WorldPetScanner", dataobj, self.db.profile.options.LibDBIcon)
end

function WPS:OnEnable()
	BuildPetList()
	DISPLAY:CreateHostWindow()
	TASKFINDER:RefreshTodaysEvents(mode)
end

WPS:RegisterChatCommand("petscan", "ChatCommand")
WPS:RegisterChatCommand("wps", "ChatCommand")
function WPS:ChatCommand(input)
	local arg1 = string.lower(input)
	self:Show(arg1)
end

function WPS:UpdateMinimapIcon()
	if self.db.profile.options.LibDBIcon.hide then
		icon:Hide("WorldPetScanner")
	else
		icon:Show("WorldPetScanner")
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
	WPS:Show(mode)
end

function WPS:Show(mode)
	if (DISPLAY.Report.PopUp) then		
		DISPLAY.Report:CloseWindow()
		return
	end
	
	local isPartialResult = not UTILITIES:IsEmpty(DATA.questsToRetry)
	print(mode)
	if (mode == "report") then
		DISPLAY.Report:ShowWindow(mode, isPartialResult)
	else
		DISPLAY.Main:ShowWindow(mode)
	end
end

WPS.debug = true
function WPS:Debug(...)
	if self.debug == true then
		print(...)
	end
end