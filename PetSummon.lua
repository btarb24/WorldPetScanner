local file="PetSummon"

local PETC = PetCollector
local EVENTS = PETC.EVENTS
local SETTINGS = PETC.DISPLAY.Settings
local PETS = PETC.PETS
local DEBUG = PETC.DISPLAY.Debug
local SUMMON = PETC.SUMMON

local previouslyMounted
local priorZone
local priorSummonedPet
local summonPending
local triggerTimer

local function DismissPet(currentPet)
    local method = "DismissPet"
    DEBUG:AddLine(file, method)

    C_PetJournal.SummonPetByGUID(currentPet)
end


local function SummonRandomPet(isRetry)
    local method = "SummonRandomPet"

    if summonPending and not isRetry then
        DEBUG:AddLine(file, method, "ignoring new summon request since there's already one pending")
        return
    end

    if (IsFalling()) then
        DEBUG:AddLine(file, method, "retry in 1s due to falling")
        C_Timer.After(2, function() SummonRandomPet(true); end)
        return
    end

    --unreached stuff down here

    priorSummonedPet = nil
    local currentPet = C_PetJournal.GetSummonedPetGUID()
    if currentPet then
        summonPending = true
        DismissPet(currentPet)
        DEBUG:AddLine(file, method, "tick")
        C_Timer.After(2, function() SummonRandomPet(true); end)
    else
        summonPending = false
        C_PetJournal.SummonRandomPet(PETC_Settings.summonPet_LimitToFaves)
        local newPet = C_PetJournal.GetSummonedPetGUID()
        DEBUG:AddLine(file, method, "summoned:", newPet)
    end
end

local function Event_OnEvent(self, event, arg1, arg2, ...)
    local method = "Event_OnEvent"
    if not PETC_Settings.summonPet then
        return
    end

    local trigger = PETC_Settings.summonPet_Trigger
    DEBUG:AddLine(file, method, "event:", event, " trigger:", trigger)

	if (event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED") then
        local isInitialLogin = arg1
        if (event == "VARIABLES_LOADED" or isInitialLogin) then
            if (trigger == "login") then
                C_Timer.After(3, function() SummonRandomPet(); end)                
            end

            previouslyMounted = IsMounted()
            priorZone = C_Map.GetBestMapForUnit("player")
            priorSummonedPet = C_PetJournal.GetSummonedPetGUID()
		end
	elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        if (trigger == "dismount") then
            if previouslyMounted and not IsMounted() then
                SummonRandomPet() 
            end
        else
            local hasPet = C_PetJournal.GetSummonedPetGUID()
            if (not hasPet and not IsMounted()) then
                if (priorSummonedPet) then
                    DEBUG:AddLine(file, method, "no pet summoned after dismount, summoning prior one")
                    C_PetJournal.SummonPetByGUID(priorSummonedPet)
                else
                    DEBUG:AddLine(file, method, "no pet summoned after dismount, summoning new one")
                    SummonRandomPet()
                end
            end
		end
        previouslyMounted = IsMounted()
	elseif event == "ZONE_CHANGED" then
        local newZone = C_Map.GetBestMapForUnit("player")
        if (trigger == "zone" and priorZone ~= newZone) then
            SummonRandomPet()
        end

        priorZone = newZone
	elseif event == "PET_BATTLE_FINAL_ROUND" then
        local won = arg1 == 1
        if (trigger == "petWin" and won) then
            SummonRandomPet()
        elseif (trigger == "petLose" and not won) then
            SummonRandomPet() 
		end
	elseif event == "ACTIVE_COMBAT_CONFIG_CHANGED" then
        if (trigger == "spec") then
            SummonRandomPet()
		end
    elseif event == "COMPANION_UPDATE" and arg1 == "CRITTER" then
        local curPet = C_PetJournal.GetSummonedPetGUID()
        if curPet then
            DEBUG:AddLine(file, method, "prior pet set: ", curPet)
            priorSummonedPet = curPet
        end
    end
end

local function CreatePeriodic()
    local method = "CreatePeriodic"
    local seconds = PETC_Settings.summonPet_PeriodicMinutes * 60
    DEBUG:AddLine(file, method, "seconds:", seconds)

    if (seconds == 0) then
        return;
    end

    triggerTimer = C_Timer.NewTimer(seconds, function()
        SummonRandomPet()
        CreatePeriodic()
    end)
end

local function CreateRandom()
    local method = "CreateRandom"
    
    local min = math.min(PETC_Settings.summonPet_RandomMinMinutes, PETC_Settings.summonPet_RandomMaxMinutes)
    local max = math.max(PETC_Settings.summonPet_RandomMinMinutes, PETC_Settings.summonPet_RandomMaxMinutes)

    local seconds = math.random(min, max) * 60
    DEBUG:AddLine(file, method, " min:", min, " max:", max, " seconds:", seconds)
    
    if (seconds == 0) then
        return;
    end

    triggerTimer = C_Timer.NewTimer(seconds, function()
        SummonRandomPet()
        CreateRandom()
    end)
end

local function Settings_Changed(eventName, oldValue, newValue)
    local method = "Settings_Changed"
    if (triggerTimer) then
        DEBUG:AddLine(file, method, "timer canceled")
        triggerTimer:Cancel()
        triggerTimer = nil
    end

    if (not PETC_Settings.summonPet) then
        DEBUG:AddLine(file, method, "feature off")
        return
    end

    local trigger = PETC_Settings.summonPet_Trigger
    if (trigger == "periodic") then
        CreatePeriodic()
    elseif (trigger == "random") then
        CreateRandom()
    end
end

function SUMMON:Initialize()
	self.event = CreateFrame("Frame")
	self.event:SetScript("OnEvent", Event_OnEvent)
	self.event:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.event:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
	self.event:RegisterEvent("ZONE_CHANGED")
	self.event:RegisterEvent("PET_BATTLE_FINAL_ROUND")
	self.event:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED")
	self.event:RegisterEvent("COMPANION_UPDATE")
	self.event:RegisterEvent("VARIABLES_LOADED")
	--self.event:RegisterEvent("PLAYER_STOPPED_MOVING")
	--self.event:RegisterEvent("PLAYER_LOGIN")
    
    hooksecurefunc( "JumpOrAscendStart", function()
        if PETC_Settings.summonPet and PETC_Settings.summonPet_Trigger == "jump" then
            SummonRandomPet()
        end
    end );

    EVENTS.Subscribe(SETTINGS, "summonPet_Trigger_Changed", Settings_Changed)
    EVENTS.Subscribe(SETTINGS, "summonPet_Changed", Settings_Changed)
    EVENTS.Subscribe(SETTINGS, "summonPet_PeriodicMinutes_Changed", Settings_Changed)
    EVENTS.Subscribe(SETTINGS, "summonPet_RandomMinMinutes_Changed", Settings_Changed)
    EVENTS.Subscribe(SETTINGS, "summonPet_RandomMaxMinutes_Changed", Settings_Changed)

end