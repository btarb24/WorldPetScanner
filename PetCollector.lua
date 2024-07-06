---@class PetCollector
local PETC = PetCollector
local DATA = PETC.DATA
local PETS = PETC.PETS
local DISPLAY = PETC.DISPLAY
local UTILITIES = PETC.UTILITIES
local TASKFINDER = PETC.TASKFINDER

local LibQTip = LibStub("LibQTip-1.0")

-- Blizzard
local IsActive = C_TaskQuest.IsActive
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetBountiesForMapID = C_QuestLog.GetBountiesForMapID
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local GetCurrencyLink = C_CurrencyInfo.GetCurrencyLink
local L = PETC.L

local LibPetJournal = LibStub("LibPetJournal-2.0")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj =
	ldb:NewDataObject("PetCollector",
		{
			type = "data source",
			text = "PetCollector",
			icon = "Interface\\Icons\\Inv_pet_maggot"
		}
	)

local icon = LibStub("LibDBIcon-1.0")

local function CreatePetSortLists()
	local list = {}
	for _, pet in pairs(PETS.all) do
		if (pet.isWild and not pet.collected) then
			if (not pet.locations) then
				print("wild pet without location:" .. pet.name)
			end
			for _, loc in pairs(pet.locations) do
				if (not list[loc.continent]) then
					list[loc.continent] = {}
				end
				if (not list[loc.continent][loc.zone]) then
					list[loc.continent][loc.zone] = {pets = {}}
				end

				if (loc.area) then
					if (not list[loc.continent][loc.zone][loc.area]) then
						list[loc.continent][loc.zone][loc.area] = {pets = {}}
					end
					table.insert(list[loc.continent][loc.zone][loc.area].pets, pet)
				else
					table.insert(list[loc.continent][loc.zone].pets, pet)
				end
			end
		end
	end

	PETS.capturable = list
end

local function BuildPetList()
	if (PETS.built)then
		return;
	end

	PETS.built = true

	for _,petID in LibPetJournal:IteratePetIDs() do 
        local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon,
            petType, creatureID, sourceText, description, isWild, canBattle,
            tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petID)
         
		local pet = PETS.all[speciesID];
		if (not pet) then
			print("unknown speciesID: " .. tostring(speciesID) .. "  name:" .. tostring(name))
		else
			if (not pet.collected) then
				pet.collected = {}
			end

			local health, maxhealth, power, speed, rarity = C_PetJournal.GetPetStats(petID)
	
			local collectedPet = { 
				customName = customName,
				level = level,
				petID = petID,
				rarity = rarity,
			}

			if (pet.baseStats) then
				collectedPet.breed = UTILITIES:GetBreed(pet.baseStats, maxhealth, power, speed, rarity, level)
			else
				print("missing base stats for " .. speciesID .. "  " .. name)
			end
	
			table.insert(pet.collected, collectedPet)
		end
    end
end

function PETC:OnInitialize()
	self.faction = UnitFactionGroup("player")

	self.db = LibStub("AceDB-3.0"):New("PETC_DB", defaults, true)

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
	self.db = LibStub("AceDB-3.0"):New("PETC_DB", defaults, true)

	-- Minimap Icon
	icon:Register("PetCollector", dataobj, self.db.profile.options.LibDBIcon)
end

function PETC:OnEnable()
	LibPetJournal.RegisterCallback(self, "PetListUpdated", "Initialize")
end

function PETC:Initialize()
	BuildPetList()
	CreatePetSortLists()
	DISPLAY:CreateHostWindow()
	TASKFINDER:RefreshTodaysEvents(mode)
end

PETC:RegisterChatCommand("petcollector", "ChatCommand")
PETC:RegisterChatCommand("pc", "ChatCommand")
function PETC:ChatCommand(input)
	local arg1 = string.lower(input)
	if (arg1 == "petdata") then
		DISPLAY.PetDataEntryHelper:Show()
	elseif not input or input == "report" or mode == "test" then
		self:Show(arg1)
	elseif (tonumber(input))then
		DISPLAY.PetCard:Show(PETS.all[tonumber(input)])
	end
end

function PETC:UpdateMinimapIcon()
	if self.db.profile.options.LibDBIcon.hide then
		icon:Hide("PetCollector")
	else
		icon:Show("PetCollector")
	end
end

function dataobj:OnClick(button)
	local mode

	if button == "LeftButton" then
		if IsControlKeyDown() then 
			mode = "test"
		end
		
	elseif button == "RightButton" then
		if IsShiftKeyDown() then
			DISPLAY.PetDataEntryHelper:Show()
			return
		end
		if IsControlKeyDown() then
			DISPLAY.PetCard:Show(PETS.all[417])
			return
		end
		mode ="report"
	end
	
	TASKFINDER:RefreshTodaysEvents(mode)
	PETC:Show(mode)
end

function PETC:Show(mode)
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

PETC.debug = true
function PETC:Debug(...)
	if self.debug == true then
		print(...)
	end
end