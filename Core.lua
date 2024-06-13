---@class WorldPetScanner : AceAddon
---@field tooltip LibQTip.Tooltip
WorldPetScanner = LibStub("AceAddon-3.0"):NewAddon("WorldPetScanner", "AceConsole-3.0", "AceTimer-3.0")

---@class WorldPetScanner
local WPS = WorldPetScanner
WPS.UTILITIES = {}
WPS.TASKFINDER = {}
WPS.DISPLAY = {Report = {}, Main = {}, TodaysEvents = {}}
WPS.DATA = {}
WPS.ZONES = {}
WPS.EXPANSIONS = {}
WPS.links = {}