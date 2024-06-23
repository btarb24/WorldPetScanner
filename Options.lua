local PETC = PetCollector
local L = PETC.L

-- Blizzard
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID

local optionsTimer

local worldQuestType = {
	["LE_QUEST_TAG_TYPE_PET_BATTLE"] = Enum.QuestTagType.PetBattle
}

PETC.EmissaryQuestIDList = {
	[7] = {
		42233, -- Highmountain Tribes
		42420, -- Court of Farondis
		42170, -- The Dreamweavers
		42422, -- The Wardens
		42421, -- The Nightfallen
		42234, -- Valarjar
		48639, -- Army of the Light
		48642, -- Argussian Reach
		48641, -- Armies of Legionfall
		43179 -- Kirin Tor
	},
	[8] = {
		50604,                          -- Tortollan Seekers
		50562,                          -- Champions of Azeroth
		{ id = 50599, faction = "Alliance" }, -- Proudmoore Admiralty
		{ id = 50600, faction = "Alliance" }, -- Order of Embers
		{ id = 50601, faction = "Alliance" }, -- Storm's Wake
		{ id = 50605, faction = "Alliance" }, -- 7th Legion
		{ id = 50598, faction = "Horde" }, -- Zandalari Empire
		{ id = 50603, faction = "Horde" }, -- Voldunai
		{ id = 50602, faction = "Horde" }, -- Talanji's Expedition
		{ id = 50606, faction = "Horde" }, -- The Honorbound
		-- 8.2
		-- 2391, -- Rustbolt Resistance
		{ id = 56119, faction = "Alliance" }, -- Waveblade Ankoan
		{ id = 56120, faction = "Horde" } -- The Unshackled
	}
}

local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

function PETC:UpdateOptions()
	------------------
	-- 	Options Table
	------------------
	self.options = {
		type = "group",
		childGroups = "tab",
		args = {
			general = {
				order = newOrder(),
				type = "group",
				childGroups = "tree",
				name = "General",
				args = {}
			},
			reward = {
				order = newOrder(),
				type = "group",
				name = "Rewards",
				args = {
					general = {
						order = newOrder(),
						name = "General",
						type = "group",
						-- inline = true,
						args = {
							gold = {
								type = "toggle",
								name = "Gold",
								set = function(info, val)
									PETC.db.profile.options.reward.general.gold = val
								end,
								descStyle = "inline",
								get = function()
									return PETC.db.profile.options.reward.general.gold
								end,
								order = newOrder()
							},
							goldMin = {
								name = "minimum Gold",
								type = "input",
								order = newOrder(),
								set = function(info, val)
									PETC.db.profile.options.reward.general.goldMin = tonumber(val)
								end,
								get = function()
									return tostring(PETC.db.profile.options.reward.general.goldMin)
								end
							}
						}
					},
				}
			},
			options = {
				order = newOrder(),
				type = "group",
				name = "Options",
				args = {
					desc1 = {
						type = "description",
						fontSize = "medium",
						name = "Select where WPS is allowed to post",
						order = newOrder()
					},
					chat = {
						type = "toggle",
						name = "Chat",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.chat = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.chat
						end,
						order = newOrder()
					},
					PopUp = {
						type = "toggle",
						name = "PopUp",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.PopUp = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.PopUp
						end,
						order = newOrder()
					},
					popupRememberPosition = {
						type = "toggle",
						name = "Remember PopUp position",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.popupRememberPosition = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.popupRememberPosition
						end,
						order = newOrder()
					},
					sortByName = {
						type = "toggle",
						name = "Sort quests by name",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.sortByName = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.sortByName
						end,
						order = newOrder()
					},
					sortByZoneName = {
						type = "toggle",
						name = "Sort quests by zone name",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.sortByZoneName = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.sortByZoneName
						end,
						order = newOrder()
					},
					chatShowExpansion = {
						type = "toggle",
						name = "Show expansion in chat",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.chatShowExpansion = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.chatShowExpansion
						end,
						order = newOrder()
					},
					chatShowZone = {
						type = "toggle",
						name = "Show zone in chat",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.chatShowZone = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.chatShowZone
						end,
						order = newOrder()
					},
					chatShowTime = {
						type = "toggle",
						name = "Show time left in chat",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.chatShowTime = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.chatShowTime
						end,
						order = newOrder()
					},
					popupShowExpansion = {
						type = "toggle",
						name = "Show expansion in popup",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.popupShowExpansion = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.popupShowExpansion
						end,
						order = newOrder()
					},
					popupShowZone = {
						type = "toggle",
						name = "Show zone in popup",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.popupShowZone = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.popupShowZone
						end,
						order = newOrder()
					},
					popupShowTime = {
						type = "toggle",
						name = "Show time left in popup",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.popupShowTime = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.popupShowTime
						end,
						order = newOrder()
					},
					delay = {
						name = "Delay on login in s",
						type = "input",
						order = newOrder(),
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.delay = tonumber(val)
						end,
						get = function()
							return tostring(PETC.db.profile.options.delay)
						end
					},
					delayCombat = {
						name = "Delay output while in combat",
						type = "toggle",
						order = newOrder(),
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.delayCombat = val
						end,
						get = function()
							return PETC.db.profile.options.delayCombat
						end
					},
					esc = {
						type = "toggle",
						name = "Close PopUp with ESC",
						desc = "Requires a reload",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.esc = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.esc
						end,
						order = newOrder()
					},
					LibDBIcon = {
						type = "toggle",
						name = "Show Minimap Icon",
						width = "double",
						set = function(info, val)
							PETC.db.profile.options.LibDBIcon.hide = not val
							PETC:UpdateMinimapIcon()
						end,
						descStyle = "inline",
						get = function()
							return not PETC.db.profile.options.LibDBIcon.hide
						end,
						order = newOrder()
					}
				}
			}
		}
	}

	-- General
	-- worldQuestType
	local args = self.options.args.reward.args.general.args
	args.header1 = {
		type = "header",
		name = "World Quest Type",
		order = newOrder()
	}
	for k, v in pairs(worldQuestType) do
		args[k] = {
			type = "toggle",
			name = L[k],
			set = function(info, val)
				PETC.db.profile.options.reward.general.worldQuestType[v] = val
			end,
			descStyle = "inline",
			get = function()
				return PETC.db.profile.options.reward.general.worldQuestType[v] or false
			end,
			order = newOrder()
		}
	end

	for i in pairs(self.ExpansionList) do
		local v = self.data[i] or nil
		if v ~= nil then
			self.options.args.general.args[v.name] = {
				order = i,
				name = v.name,
				type = "group",
				inline = true,
				args = {}
			}
			self:CreateGroup(self.options.args.general.args[v.name].args, v, "achievements")
			self:CreateGroup(self.options.args.general.args[v.name].args, v, "pets")
		end
	end

	for i = 6, 10 do
		self.options.args.reward.args[self.ExpansionList[i]] = {
			order = newOrder(),
			name = self.ExpansionList[i],
			type = "group",
			args = {}
		}

		-- World Quests
		if i > 6 then
			self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i] .. "WorldQuests"] = {
				order = newOrder(),
				name = "World Quests",
				type = "group",
				args = {}
			}
			local args = self.options.args.reward.args[self.ExpansionList[i]].args
				[self.ExpansionList[i] .. "WorldQuests"].args

			-- Zones
			if ZONES.list[i] then
				args.zone = {
					order = newOrder(),
					name = "Zones",
					type = "group",
					args = {},
					inline = false
				}
				for k, v in pairs(ZONES.list[i]) do
					local name = C_Map.GetMapInfo(v).name
					args.zone.args[name] = {
						type = "toggle",
						name = name,
						set = function(info, val)
							PETC.db.profile.options.zone[v] = val
						end,
						descStyle = "inline",
						get = function()
							return PETC.db.profile.options.zone[v] or false
						end,
						order = newOrder()
					}
				end
			end

			-- Emissary
			if self.EmissaryQuestIDList[i] then
				args.emissary = {
					order = newOrder(),
					name = "Emissary Quests",
					type = "group",
					args = {}
				}
				for k, v in pairs(self.EmissaryQuestIDList[i]) do
					if not (type(v) == "table" and v.faction ~= self.faction) then
						if type(v) == "table" then
							v = v.id
						end
						args.emissary.args[GetTitleForQuestID(v) or tostring(v)] = {
							type = "toggle",
							name = GetTitleForQuestID(v) or tostring(v),
							set = function(info, val)
								PETC.db.profile.options.emissary[v] = val
							end,
							descStyle = "inline",
							get = function()
								return PETC.db.profile.options.emissary[v]
							end,
							order = newOrder()
						}
					end
				end
			end
		end

		-- Mission Table
		self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i] .. "MissionTable"] = {
			order = newOrder(),
			name = (i ~= 6 and "Mission Table" or "Mission Table & Shipyard"),
			type = "group",
			args = {}
		}
		local args = self.options.args.reward.args[self.ExpansionList[i]].args[self.ExpansionList[i] .. "MissionTable"]
			.args

	end

	self:UpdateCustom()
end

function PETC:GetOptions()
	self:UpdateOptions()
	self:SortOptions()
	return self.options
end

function PETC:ToggleSet(info, val, ...)
	-- print(info[#info-2],info[#info-1],info[#info])
	local expansion = info[#info - 2]
	local category = info[#info - 1]
	local option = info[#info]
	PETC.db.profile[category][tonumber(option)] = val
	if val == "exclusive" then
		local name, server = UnitFullName("player")
		PETC.db.profile[category].exclusive[tonumber(option)] = name .. "-" .. server
	elseif PETC.db.profile[category].exclusive[tonumber(option)] then
		PETC.db.profile[category].exclusive[tonumber(option)] = nil
	end
	-- if not PETC.db.profile[expansion] then PETC.db.profile[expansion] = {} end
	--[[if not PETC.db.profile[category] then PETC.db.profile[category] = {} end
if not val == true then
PETC.db.profile[category][option] = true
else
PETC.db.profile[category][option] = nil
end-- ]]
end

function PETC:ToggleGet()
end

function PETC:CreateGroup(options, data, groupName)
	if data[groupName] then
		options[groupName] = {
			order = 1,
			name = L[groupName],
			type = "group",
			args = {}
		}
		local args = options[groupName].args

		args["completed"] = {
			type = "header",
			name = L["completed"],
			order = newOrder(),
			hidden = true
		}
		args["notCompleted"] = {
			type = "header",
			name = L["notCompleted"],
			order = newOrder(),
			hidden = true
		}

		local expansion = data.name
		local data = data[groupName]
		for _, object in pairs(data) do
			local id = object.id or object.spellID or object.creatureID or object.itemID
			local idString = tostring(id)
			args[idString .. "Name"] = {
				type = "description",
				name = idString,
				fontSize = "medium",
				order = newOrder(),
				width = 1.5
			}
			args[idString] = {
				type = "select",
				values = {
					disabled = L["tracking_disabled"],
					default = L["tracking_default"],
					always = L["tracking_always"],
					wasEarnedByMe = L["tracking_wasEarnedByMe"],
					exclusive = L["tracking_exclusive"]
				},
				width = 1.4,
				-- type = "toggle",
				name = "", -- idString,
				handler = WPS,
				set = "ToggleSet",
				-- descStyle = "inline",
				get = function(info)
					local value = PETC.db.profile[groupName][id]
					if value == "exclusive" then
						local name, server = UnitFullName("player")
						name = name .. "-" .. server
						if PETC.db.profile[info[#info - 1]].exclusive[id] ~= name then
							info.option.values.other = string.format(L["tracking_other"],
								PETC.db.profile[info[#info - 1]].exclusive[id])
							return "other"
						end
					end
					return value
				end,
				order = newOrder()
			}
			if object.itemID then
				if not select(2, GetItemInfo(object.itemID)) then
					self:CancelTimer(optionsTimer)
					optionsTimer =
						self:ScheduleTimer(
							function()
								LibStub("AceConfigRegistry-3.0"):NotifyChange("PetCollector")
							end,
							2
						)
				end
				args[idString .. "Name"].name = select(2, GetItemInfo(object.itemID)) or object.name
			else
				args[idString .. "Name"].name = GetAchievementLink(object.id) or object.name
			end
		end
	end
end

function PETC:CreateCustomQuest()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.worldQuest then
		self.db.global.custom.worldQuest = {}
	end
	self.db.global.custom.worldQuest[tonumber(self.data.custom.wqID)] = {
		questType = self.data.custom.questType,
		mapID = self.data.custom.mapID
	} -- {rewardID = tonumber(self.data.custom.rewardID), rewardType = self.data.custom.rewardType}
	self:UpdateCustomQuests()
end

function PETC:UpdateCustomQuests()
	local data = self.db.global.custom.worldQuest
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.quest.args
	for id, object in pairs(data) do
		args[tostring(id)] = {
			type = "toggle",
			name = GetQuestLink(id) or GetTitleForQuestID(id) or tostring(id),
			set = function(info, val)
				PETC.db.profile.custom.worldQuest[id] = val
			end,
			descStyle = "inline",
			get = function()
				return PETC.db.profile.custom.worldQuest[id]
			end,
			order = newOrder(),
			width = 1.2
		}

		args[id .. "questType"] = {
			name = "Quest type",
			order = newOrder(),
			desc =
			"IsActive:\nUse this as a last resort. Works for some daily quests.\n\nIsQuestFlaggedCompleted:\nUse this for quests, that are always active.\n\nQuest Pin:\nUse this, if the daily is marked with a quest pin on the world map.\n\nWorld Quest:\nUse this, if you want to track a world quest.",
			type = "select",
			values = {
				WORLD_QUEST = "World Quest",
				QUEST_PIN = "Quest Pin",
				QUEST_FLAG = "IsQuestFlaggedCompleted",
				IsActive = "IsActive"
			},
			width = .8,
			set = function(info, val)
				self.db.global.custom.worldQuest[id].questType = val
			end,
			get = function()
				return tostring(self.db.global.custom.worldQuest[id].questType or "")
			end
		}
		args[id .. "mapID"] = {
			name = "mapID",
			desc = "Quest pin tracking needs a mapID.\nSee https://wow.gamepedia.com/UiMapID for help.",
			type = "input",
			width = .4,
			order = newOrder(),
			set = function(info, val)
				self.db.global.custom.worldQuest[id].mapID = val
			end,
			get = function()
				return tostring(self.db.global.custom.worldQuest[id].mapID or "")
			end
		}

		--[[
		args[id.."Reward"] = {
		name = "Reward (optional)",
		desc = "Enter an achievementID or itemID",
		type = "input",
		width = .6,
		order = newOrder(),
		set = function(info,val)
		self.db.global.custom.worldQuest[id].rewardID = tonumber(val)
		end,
		get = function() return
		tostring(self.db.global.custom.worldQuest[id].rewardID or "")
		end
		}
		args[id.."RewardType"] = {
		name = "Reward type",
		order = newOrder(),
		type = "select",
		values = {item = "Item", achievement = "Achievement", none = "none"},
		width = .6,
		set = function(info,val)
		self.db.global.custom.worldQuest[id].rewardType = val
		end,
		get = function() return self.db.global.custom.worldQuest[id].rewardType or nil end
		}--]]
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = "Delete",
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Reward"] = nil
				args[id .. "RewardType"] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.worldQuest[id] = nil
				self:UpdateCustomQuests()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
			width = .25,
			order = newOrder(),
			type = "description"
		}
	end
end

function PETC:CreateCustomReward()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.worldQuestReward then
		self.db.global.custom.worldQuestReward = {}
	end
	self.db.global.custom.worldQuestReward[tonumber(self.data.custom.worldQuestReward)] = true
	self:UpdateCustomRewards()
end

function PETC:UpdateCustomRewards()
	local data = self.db.global.custom.worldQuestReward
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.reward.args
	for id, _ in pairs(data) do
		local _, itemLink = GetItemInfo(id)
		args[tostring(id)] = {
			type = "toggle",
			name = itemLink or tostring(id),
			--width = "double",
			set = function(info, val)
				PETC.db.profile.custom.worldQuestReward[id] = val
			end,
			descStyle = "inline",
			get = function()
				return PETC.db.profile.custom.worldQuestReward[id]
			end,
			order = newOrder(),
			width = 1.2
		}
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = "Delete",
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.worldQuestReward[id] = nil
				self:UpdateCustomRewards()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
			width = 1,
			order = newOrder(),
			type = "description"
		}
	end
end

function PETC:CreateCustomMission()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.mission then
		self.db.global.custom.mission = {}
	end
	self.db.global.custom.mission[tonumber(self.data.custom.mission.missionID)] = {
		rewardID = tonumber(self.data.custom.mission.rewardID),
		rewardType = self.data.custom.mission.rewardType
	}
	self:UpdateCustomMissions()
end

function PETC:UpdateCustomMissions()
	local data = self.db.global.custom.mission
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.mission.args
	for id, object in pairs(data) do
		args[tostring(id)] = {
			type = "toggle",
			name = C_Garrison.GetMissionLink(id) or tostring(id),
			set = function(info, val)
				PETC.db.profile.custom.mission[id] = val
			end,
			descStyle = "inline",
			get = function()
				return PETC.db.profile.custom.mission[id]
			end,
			order = newOrder(),
			width = 1.2
		}
		args[id .. "Reward"] = {
			name = "Reward (optional)",
			desc = "Enter an achievementID or itemID",
			type = "input",
			width = .6,
			order = newOrder(),
			set = function(info, val)
				self.db.global.custom.mission[id].rewardID = tonumber(val)
			end,
			get = function()
				return tostring(self.db.global.custom.mission[id].rewardID or "")
			end
		}
		args[id .. "RewardType"] = {
			name = "Reward type",
			order = newOrder(),
			type = "select",
			values = { item = "Item", achievement = "Achievement", none = "none" },
			width = .6,
			set = function(info, val)
				self.db.global.custom.mission[id].rewardType = val
			end,
			get = function()
				return self.db.global.custom.mission[id].rewardType or nil
			end
		}
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = "Delete",
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Reward"] = nil
				args[id .. "RewardType"] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.mission[id] = nil
				self:UpdateCustomMissions()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
			width = .25,
			order = newOrder(),
			type = "description"
		}
	end
end

function PETC:CreateCustomMissionReward()
	if not self.db.global.custom then
		self.db.global.custom = {}
	end
	if not self.db.global.custom.missionReward then
		self.db.global.custom.missionReward = {}
	end
	self.db.global.custom.missionReward[tonumber(self.data.custom.missionReward)] = true
	self:UpdateCustomMissionRewards()
end

function PETC:UpdateCustomMissionRewards()
	local data = self.db.global.custom.missionReward
	if type(data) ~= "table" then
		return false
	end
	local args = self.options.args.custom.args.missionReward.args
	for id, _ in pairs(data) do
		local _, itemLink = GetItemInfo(id)
		args[tostring(id)] = {
			type = "toggle",
			name = itemLink or tostring(id),
			set = function(info, val)
				PETC.db.profile.custom.missionReward[id] = val
			end,
			descStyle = "inline",
			get = function()
				return PETC.db.profile.custom.missionReward[id]
			end,
			order = newOrder(),
			width = 1.2
		}
		args[id .. "Delete"] = {
			order = newOrder(),
			type = "execute",
			name = "Delete",
			width = .5,
			func = function()
				args[tostring(id)] = nil
				args[id .. "Delete"] = nil
				args[id .. "space"] = nil
				self.db.global.custom.missionReward[id] = nil
				self:UpdateCustomMissionRewards()
				GameTooltip:Hide()
			end
		}
		args[id .. "space"] = {
			name = " ",
			width = 1,
			order = newOrder(),
			type = "description"
		}
	end
end

function PETC:SortOptions()
	for k, v in pairs(PETC.options.args.general.args) do
		for kk, vv in pairs(v.args) do
			local t = {}
			for kkk, vvv in pairs(vv.args) do
				local completed = false
				local id = select(3, string.find(kkk, "(%d*)Name"))
				if id then
					id = tonumber(id)
					if kk == "achievements" then
						completed = select(4, GetAchievementInfo(id))
					elseif kk == "pets" then
						local total = C_PetJournal.GetNumPets()
						for i = 1, total do
							local petID, _, owned, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(i)
							if companionID == id then
								completed = owned
								break
							end
						end
					end
					vvv.disabled = completed
					table.insert(
						t,
						{
							key = kkk,
							name = select(3, string.find(vvv.name, "%[(.+)%]")) or vvv.name,
							completed = completed,
							id = tostring(id)
						}
					)
				end
			end
			table.sort(
				t,
				function(a, b)
					return a.name < b.name
				end
			)
			local completedHeader = false
			for order, object in pairs(t) do
				if not object.completed then
					vv.args["notCompleted"].order = 0
					vv.args["notCompleted"].hidden = false
				end
				if object.completed then
					order = order + 100
					if not completedHeader then
						vv.args["completed"].order = order * 2 - .5
						vv.args["completed"].hidden = false
						completedHeader = true
					end
				end
				vv.args[object.key].order = order * 2
				vv.args[object.id].order = order * 2 + 1
			end
		end
	end
end
