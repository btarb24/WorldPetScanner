---@class PetAdvisor : AceAddon
---@field tooltip LibQTip.Tooltip
PetAdvisor = LibStub("AceAddon-3.0"):NewAddon("PetAdvisor", "AceConsole-3.0", "AceTimer-3.0")

---@class PetAdvisor
local PETAD = PetAdvisor
PETAD.UTILITIES = {}
PETAD.TASKFINDER = {}
PETAD.DISPLAY = {Report = {}, Main = {}, TodaysEvents = {}, TestWindow = {}, PetDataEntryHelper = {}}
PETAD.DATA = {}
PETAD.ZONES = {}
PETAD.EXPANSIONS = {}
PETAD.PETS = {}
PETAD.links = {}