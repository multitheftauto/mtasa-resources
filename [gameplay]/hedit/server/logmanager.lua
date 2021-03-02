local vehicleLogs = {}

function loadHandlingLog ( )
    local data = getElementData ( root, "hedit:vehicleLogs" )

    if data then
        vehicleLogs = data
    end

    return true
end





function unloadHandlingLog ( )
    setElementData ( root, "hedit:vehicleLogs", vehicleLogs, false )

    return true
end





function addLogEntry ( vehicle, player, textPointer, arguments, oldValue, level )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    if not isValidPlayer ( player ) then
        return false
    end
    
    if type ( textPointer ) ~= "string" then
        return false
    end
    
    if arguments and type ( arguments ) ~= "table" then
        return false
    end
    
    if type ( level ) ~= "number" or level < 1 or level > 3 then
        level = 3
    end
    
    
    
    if not vehicleLogs[vehicle] then
        vehicleLogs[vehicle] = {}
    end
    
    
    
    if #vehicleLogs[vehicle] == 25 then
        table.remove ( vehicleLogs[vehicle], 1 )
    end
    
    local realtime = getRealTime ( )
    local addingEntry = {
        responsiblePlayer = getPlayerName ( player ),
        timeStamp = {
            hour = realtime.hour,
            minute = realtime.minute,
            second = realtime.second
        },
        textPointer = textPointer,
        arguments = arguments,
        oldValue = oldValue,
        level = level
    }
    
    table.insert ( vehicleLogs[vehicle], addingEntry )
    
    local occupants = getVehicleOccupants ( vehicle )
    
    for seat=0,getVehicleMaxPassengers ( vehicle ) do
        local occupant = occupants[seat]
        
        if isValidPlayer ( occupant ) then
            triggerClientEvent ( occupant, "addToLogGUI", occupant, addingEntry )
        end
    end

    return true
end
addEvent ( "addToLog", true )
addEventHandler ( "addToLog", root, addLogEntry )





function uploadMiniLog ( vehicle, amountToSend )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    local fullLog = vehicleLogs[vehicle]
    local toSend = {}
    
    if type ( fullLog ) == "table" then
        local size = #fullLog
        
        for i=(amountToSend-1),0,-1 do
            table.insert ( toSend, fullLog[size-i] )
        end
    end
    
    triggerClientEvent ( client, "receiveMiniLog", client, toSend )
    return true
end
addEvent ( "requestMiniLog", true )
addEventHandler ( "requestMiniLog", root, uploadMiniLog )





function uploadFullLog ( vehicle )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    triggerClientEvent ( client, "receiveFullLog", client, getElementData(root,"hedit:vehicleLogs")[vehicle] )
    return true
end
addEvent ( "requestFullLog", true )
addEventHandler ( "requestFullLog", root, uploadFullLog )


-- Destroy log information when vehicle is destroyed
local function cleanupVehicleLog()
	if source.type == "vehicle" then
		vehicleLogs[source] = nil
	end
end
addEventHandler("onElementDestroy", root, cleanupVehicleLog)