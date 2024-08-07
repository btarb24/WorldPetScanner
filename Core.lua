---@class PetCollector : AceAddon
---@field tooltip LibQTip.Tooltip
PetCollector = LibStub("AceAddon-3.0"):NewAddon("PetCollector", "AceConsole-3.0", "AceTimer-3.0")

---@class PetCollector
local PETC = PetCollector
PETC.EVENTS = {}
PETC.UTILITIES = {}
PETC.TASKFINDER = {}
PETC.SUMMON = {}
PETC.DISPLAY = { Util = {}, Report = {}, Main = {}, TodaysEvents = {}, Capturable = {}, Settings = {}, 
                 TestWindow = {}, PetDataEntryHelper = {}, PetCard = {}, LinkWindow = {}, Debug = {}, TotalPets = {}}
PETC.DATA = {}
PETC.ZONES = {}
PETC.EXPANSIONS = {}
PETC.CONTINENTS = {}
PETC.PETS = {}
PETC.MAPS = {}
PETC.SHARED = {}
PETC.links = {}