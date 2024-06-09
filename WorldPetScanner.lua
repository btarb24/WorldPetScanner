---@class WorldPetScanner
local WPS = WorldPetScanner

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

function WPS:OnInitialize()
	self.faction = UnitFactionGroup("player")

	-- Defaults
	local defaults = {
		char = {
			["*"] = {
				["profession"] = {
					["*"] = {
						isMaxLevel = true
					}
				}
			}
		},
		profile = {
			options = {
				["*"] = true,
				chat = true,
				PopUp = false,
				popupRememberPosition = false,
				popupX = 600,
				popupY = 800,
				zone = { ["*"] = true },
				reward = {
					currency = {},
					craftingreagent = { ["*"] = false },
					["*"] = {
						["*"] = true,
						profession = {
							["*"] = {
								skillup = true
							}
						}
					}
				},
				emissary = { ["*"] = false },
				missionTable = {
					reward = {
						gold = false,
						goldMin = 0,
						["*"] = {
							["*"] = false
						}
					}
				},
				delay = 5,
				LibDBIcon = { hide = false }
			},
			["achievements"] = { exclusive = {}, ["*"] = "default" },
			["pets"] = { exclusive = {}, ["*"] = "default" },
			custom = {
				["*"] = { ["*"] = true }
			},
			["*"] = { ["*"] = true }
		},
		global = {
			completed = { ["*"] = false },
			custom = {
				["*"] = { ["*"] = false }
			}
		}
	}
	self.db = LibStub("AceDB-3.0"):New("WPSDB", defaults, true)

	-- copy old data
	if type(self.db.global.custom) == "table" then
		for k, v in pairs(self.db.global.custom) do
			if type(k) == "number" then
				self.db.global.custom.worldQuest[k] = v
				self.db.global.custom[k] = nil
			end
		end
	end
	if type(self.db.global.customReward) == "table" then
		for k, v in pairs(self.db.global.customReward) do
			self.db.global.custom.worldQuestReward[k] = true
		end
		self.db.global.customReward = nil
	end

	-- Minimap Icon
	icon:Register("WorldPetScanner", dataobj, self.db.profile.options.LibDBIcon)
end

function WPS:OnEnable()
	local name, server = UnitFullName("player")
	self.playerName = name .. "-" .. server
	------------------
	-- 	Options
	------------------
	LibStub("AceConfig-3.0"):RegisterOptionsTable(
		"WorldPetScanner",
		function()
			return self:GetOptions()
		end
	)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WorldPetScanner", "WorldPetScanner")
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WorldPetScanProfiles", profiles)
	self.optionsFrame.Profiles =
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WorldPetScanProfiles", "Profiles", "WorldPetScanner")

	self.event = CreateFrame("Frame")
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:SetScript(
		"OnEvent",
		function(...)
			local _, name, id = ...
			if name == "PLAYER_ENTERING_WORLD" then
				self:ScheduleTimer(
					function()
						--self:BuildPetList()
						self.PetList = {}
					end,
					self.db.profile.options.delay
				)

				self.event:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end
		end
	)

	LoadAddOn("Blizzard_GarrisonUI")
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
	if button == "LeftButton" then
		WPS:Show()
		start = 2135
	elseif button == "RightButton" then
		Settings.OpenToCategory("WorldPetScanner")
	end
end

function WPS:Show(mode)
	self:Debug("Show")
	if (self.PopUp) then		
		WPS:CloseWindow()
		return
	end
	
	self.taskList = {}
	self.charmTotal = 0;
	self.bandageTotal = 0;
	self.blueStoneTotal = 0;
	self.hasTrainingStones = false
	self.trainingStoneTotals = {}

	local scannedQuestList, worldQuestTaskResults = self:ScanWorldQuests()
	self:ProcessTaskData(mode, scannedQuestList, worldQuestTaskResults)

	local sortedTasks = self:SortTaskList(self.taskList)
	self:ShowWindow(sortedTasks)
end

function WPS:BuildPetList()
	self.PetList = {}
	local total = C_PetJournal.GetNumPets()
	for i = 1, total do
		local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)
		if (petID ~= nil) then
			table.Insert(PetList, petID, owned)
		end
	end
end

function WPS:SortTaskList(list)
	table.sort(list, function(a, b) return WPS:Sort(a, b) end)
	return list
end

function WPS:Sort(a, b)
	if a.challenge.expansionID > b.challenge.expansionID then return true end
	if a.challenge.expansionID < b.challenge.expansionID then return false end
	return a.challenge.zoneID < b.challenge.zoneID
end