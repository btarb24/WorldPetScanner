---@class PetCollector
local PETC = PetCollector
local DATA = PETC.DATA
local PETS = PETC.PETS
local DISPLAY = PETC.DISPLAY
local UTILITIES = PETC.UTILITIES
local TASKFINDER = PETC.TASKFINDER
local MAPS = PETC.MAPS

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

local function TieInBliz()
	local journalButton = CreateFrame("Button", nil, PetJournalPetCard)
	journalButton:SetNormalAtlas("RedButton-Expand")
	journalButton:SetPushedAtlas("RedButton-Expand-Pressed")
	journalButton:SetHighlightAtlas("RedButton-Highlight")
	journalButton:SetPoint("TOPRIGHT", PetJournalPetCard, "TOPRIGHT", 2, 0)
    journalButton:SetSize(19,19)
    journalButton:SetScript("OnClick", function(self)
		local speciesID = PetJournalPetCard.speciesID
		DISPLAY.PetCard:Show(PETS.all[speciesID])
    end)
end

local function TieInRematch()
	local journalButton = CreateFrame("Button", nil, RematchPetCard)
	journalButton:SetNormalAtlas("RedButton-Expand")
	journalButton:SetPushedAtlas("RedButton-Expand-Pressed")
	journalButton:SetHighlightAtlas("RedButton-Highlight")
	journalButton:SetPoint("TOPRIGHT", RematchPetCard.MinimizeButton, "TOPLEFT", 0, 0)
    journalButton:SetSize(RematchPetCard.MinimizeButton:GetSize())
    journalButton:SetScript("OnClick", function(self)
		local speciesID = C_PetJournal.GetPetInfoByPetID(RematchPetCard.petID)
		DISPLAY.PetCard:Show(PETS.all[speciesID])
    end)
end

local function Event_OnEvent(self, event, name, ...)
	if (event == "ADDON_LOADED") then
		if (name == "Blizzard_Collections") then
			TieInBliz()
		elseif (name == "Rematch") then
			TieInRematch()
		end
	elseif event == "PERKS_PROGRAM_DATA_REFRESH" then
		print("PetCollector - updating perks cache")
		TASKFINDER:UpdateTradingPostCache()
	end
end

local function TieIn()
	PETC.event:RegisterEvent("ADDON_LOADED")
	if IsAddOnLoaded("Blizzard_Collections") then
		TieInBliz()
	end

	if IsAddOnLoaded("Rematch") then
		TieInRematch()
	end
end

local function CreatePetSortLists()
	local list = {}
	for _, pet in pairs(PETS.all) do
		if (pet.isWild and not pet.collected) then
			if (pet.locations) then
				for _, loc in pairs(pet.locations) do
					local continent = loc.continent
					local zone = loc.zone
					local area = loc.area
					if (not continent) then
						continent, zone, area = MAPS.GetMapInfo(loc.mapID)
					end

					if (not list[continent]) then
						list[continent] = {}
					end
					if (not list[continent][zone]) then
						list[continent][zone] = {pets = {}}
					end

					if (loc.area) then
						if (not list[continent][zone][area]) then
							list[continent][zone][area] = {pets = {}}
						end
						table.insert(list[continent][zone][area].pets, pet)
					else
						table.insert(list[continent][zone].pets, pet)
					end
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

	--get bounds for the next/prev buttons on pet card
	for idx, pet in pairs(PETS.all) do
		if idx > PETS.highest then
			PETS.highest = idx
		elseif idx < PETS.lowest then
			PETS.lowest = idx
		end
	end

end

function PETC:OnInitialize()
	self.event = CreateFrame("Frame")
	self.event:SetScript("OnEvent", Event_OnEvent)
	self.event:RegisterEvent("PERKS_PROGRAM_DATA_REFRESH")

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
	TieIn()
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
	local cmds = strsplittable(" ", input)
	local arg1 = string.lower(cmds[1])
	if (arg1 == "flip") then
		print("FlipMode engaged!")
		PETC.flipIsHere = true
		if (#cmds == 4) then
			PETC.flipR = cmds[2]
			PETC.flipG = cmds[3]
			PETC.flipB = cmds[4]
		end
	elseif (arg1 == "petdata") then
		DISPLAY.PetDataEntryHelper:Show()
	elseif not input or arg1 == "report" or arg1 == "test" then
		self:Show(arg1)
	elseif input == "debug" then
		DISPLAY.Debug:Show()
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
		--mode ="report"
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