--[[
    |> EVENTS
        requestRights [ source = player | args ( ) ]
        importHandling [ source = player | args ( element vehicle, table toImport ) ]
        resetHandling [ source = player | args ( element vehicle, int baseVehicleID ) ]

    |> FUNCTIONS
        setHandlingFromTable ( element vehicle, table tab )
]]

addEvent ( "requestRights", true )
addEventHandler ( "requestRights", root, function ( )
    if not isValidPlayer ( client ) then
        if DEBUGMODE then
            error ( "Invalid client at event 'requestRights'!", 2 )
        end
        return false
    end

    local pAccount = getPlayerAccount ( client )
    local canAccess = hasObjectPermissionTo(client, "resource.hedit.access", true)
    if isGuestAccount ( pAccount ) then
        triggerClientEvent ( client, "updateClientRights", client, false, false, canAccess )
    else
        local admin = isObjectInACLGroup ( "user."..getAccountName ( pAccount ), aclGetGroup ( "Admin" ) )
        triggerClientEvent ( client, "updateClientRights", client, true, admin, canAccess )
    end
end )


function handlingMod ( arg )
    if not isValidPlayer ( client ) then
        if DEBUGMODE then
            error ( "Invalid sourceplayer at event '"..eventName.."'!", 2 )
        end
        return false
    end

    if not isValidVehicle ( source ) then
        if DEBUGMODE then
            error ( "Invalid vehicle at event '"..eventName.."'!", 2 )
        end
        return false
    end

    local executeEvent = {
        resetHandling = function ( )
            setHandlingFromTable ( source, getOriginalHandling ( arg ) )
            setVehicleSaved ( source, true )
            addLogEntry ( source, client, "resetted", nil, nil, 1 )
        end,
        loadClientHandling = function ( )
            setHandlingFromTable ( source, arg )
            setVehicleSaved ( source, true )
            addLogEntry ( source, client, "loaded", nil, nil, 1 )
        end,
        importHandling = function ( )
            setHandlingFromTable ( source, arg )
            setVehicleSaved ( source, false )
            addLogEntry ( source, client, "imported", nil, nil, 1 )
        end
    }

    executeEvent[eventName]()
    triggerClientEvent ( client, "showView", client, "previous" )

    return true
end


addEvent ( "resetHandling", true )
addEvent ( "loadClientHandling", true )
addEvent ( "importHandling", true )
addEventHandler ( "resetHandling", root, handlingMod )
addEventHandler ( "loadClientHandling", root, handlingMod )
addEventHandler ( "importHandling", root, handlingMod )


--


function setHandlingFromTable ( vehicle, tab, exe )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle at event 'setHandlingFromTable'!", 2 )
        end
        return false
    end

    for property,value in pairs ( tab ) do
        outputDebugString ( "PROPERTY: "..property.." - VALUE: "..tostring(value).." - TYPE: "..type(value) )

        if property == "maxVelocity" and (tonumber(value) > 13.02 and tonumber(value) < 13.1) then
            value = 13.04
        end

        if (property == "steeringLock") and (getVehicleType(vehicle) == "Bike" or getVehicleType(vehicle) == "BMX") and tonumber(value) < 1 then
            value = 1
        end

        setVehicleHandling ( vehicle, property, value, false )
    end

    return true
end

local function onRemoteLockRequest(vehicle, state)
	if source ~= client then
		return
	end

	setVehicleLocked(vehicle, state)
end
addEvent("vehicleLockRequest", true)
addEventHandler("vehicleLockRequest", root, onRemoteLockRequest)

--This function parses the meta.xml settings, storing them all as element data of resourceRoot (for use clientside).
function parseMetaSettings()
	local propertySettings = {}
	for handlingProperty,_ in pairs(handlingLimits) do
		local settingExists = get("*enable_"..handlingProperty)
		if settingExists then
			propertySettings[handlingProperty] = tobool(settingExists)
		else
			propertySettings[handlingProperty] = false
			print("Missing setting for "..handlingProperty..", defaulting to false.")
			outputDebugString("Missing setting for "..handlingProperty..", defaulting to false.", 2)
		end
	end
	setElementData(resourceRoot, "propertySettings", propertySettings)
end
