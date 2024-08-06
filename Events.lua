local file="Events"

local PETC = PetCollector
local UTILITIES = PETC.UTILITIES
local DEBUG = PETC.DISPLAY.Debug
local EVENTS = PETC.EVENTS

function EVENTS.Subscribe(source, eventName, callback)
    local method = "Subscribe"
    DEBUG:AddLine(file, method, " eventName:", eventName, " callback:", callback)

    if (not source[eventName]) then
        source[eventName] = {}
    end

    table.insert(source[eventName], callback)
end

function EVENTS.UnSubscribe(source, eventName, callback)
    local method = "Unsubscribe"
    DEBUG:AddLine(file, method, " eventName:", eventName, " callback:", callback)
    
    if (not source[eventName]) then
        source[eventName] = {}
    end

    table.remove(source[eventName], callback)
end


function EVENTS.Raise(source, eventName, ...)
    local method = "Raise"
    if (UTILITIES:IsEmpty(source[eventName])) then
        DEBUG:AddLine(file, method, " eventName:", eventName, " no listeners")
        return;
    end

    DEBUG:AddLine(file, method, " eventName: ", eventName)
    for _, callback in pairs(source[eventName]) do
        callback(eventName, ...)
    end
end