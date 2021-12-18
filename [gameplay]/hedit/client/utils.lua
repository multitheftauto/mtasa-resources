function getText ( ... )
    local entry = getUserLanguage()

    if not entry then
        return false
    end

    for i,tab in ipairs{...} do

        entry = entry[tab]

        if not entry then
            local path = table.concat ( {...}, "." )
            outputDebugString ( "No language entry in " .. getUserConfig ("language") .. ": ".. path, 2)

            -- Returning path is more friendly, helps developer find source of issue and can give user an idea of what was supposed to be said
            return path

        elseif type ( entry ) == "string" then
            return entry
        end

    end

    if DEBUGMODE then
        error ( "No valid arguments were passed!", 2 )
    end

    return ""
end


function getHandlingPropertyFriendlyName ( property )
    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingPropertyFriendlyName!", 2 )
        end
        return nil
    end

    return getText ( "handlingPropertyInformation", property, "friendlyName" ) or "NO_FRIENDLY_NAME"
end


function getHandlingPropertyInformationText ( property )
    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingPropertyInformationText!", 2 )
        end
        return nil
    end

    return getText ( "handlingPropertyInformation", property, "information" ) or "NO_INFORMATION_TEXT"
end


function getHandlingPropertyValueType ( property )
    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingPropertyValueType!", 2 )
        end
        return nil
    end

    return getText ( "handlingPropertyInformation", property, "syntax", 1 ) or "NO_VALUE_TYPE"
end


function getHandlingPropertyValueInformation ( property )
    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingPropertyValueInformation!", 2 )
        end
        return nil
    end

    return getText ( "handlingPropertyInformation", property, "syntax", 2 ) or "NO_VALUE_INFORMATION"
end


function getHandlingPropertyOptionName ( property, option )
    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingPropertyOptionNames!", 2 )
        end
        return nil
    end

    return getText ( "handlingPropertyInformation", property, "options", option ) or "NO_OPTION_NAME"
end


function getHandlingPropertyByteName ( property, byte, value )
    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingPropertyByteName!", 2 )
        end
        return nil
    end

    if not isHandlingPropertyHexadecimal ( property ) then
        if DEBUGMODE then
            error ( "Property '"..tostring(property).."' is not hexadecimal at getHandlingPropertyByteName!", 2 )
        end
        return nil
    end

    return getText ( "handlingPropertyInformation", property, "items", byte, value, 1 ) or "NO_BYTE_NAME"
end


function getHandlingPropertyByteInformation ( property, byte, value )
    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingPropertyByteInformation!", 2 )
        end
        return nil
    end

    if not isHandlingPropertyHexadecimal ( property ) then
        if DEBUGMODE then
            error ( "Property '"..tostring(property).."' is not hexadecimal at getHandlingPropertyByteInformation!", 2 )
        end
        return nil
    end

    return getText ( "handlingPropertyInformation", property, "items", byte, value, 2 ) or "NO_BYTE_INFORMATION"
end


function getHandlingHexadecimalChangeDetails ( vehicle, property, value )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle '"..tostring(vehicle).."' at getHandlingHexadecimalChangeDetails!", 2 )
        end

        return false
    end

    if not isHandlingPropertyValid ( property ) then
        if DEBUGMODE then
            error ( "Invalid property '"..tostring(property).."' at getHandlingHexadecimalChangeDetails!", 2 )
        end

        return false
    end

    if not isHandlingPropertyHexadecimal ( property ) then
        if DEBUGMODE then
            error ( "Property '"..tostring(property).."' is not hexadecimal at getHandlingHexadecimalChangeDetails!", 2 )
        end
        return nil
    end


    return hexChanges, hexByte, hexValue, hexBool
end


function cacheClientSaves ( )
    local saves = xmlLoadFile ( client_handling_file )
    xmlCache.clientsaves = {}


    if not saves then
        saves = xmlCreateFile ( client_handling_file, "saves" )

        outputDebugString ( "Added new client handling saves file." )
    end

    for i,node in ipairs ( xmlNodeGetChildren ( saves ) ) do

        local model = xmlNodeGetAttribute ( node, "model" )
        local name = xmlNodeGetAttribute ( node, "name" )
        local description = xmlNodeGetAttribute ( node, "description" )
        local lowername = string.lower ( name )
        local handlingNode = xmlFindChild ( node, "handling", 0 )
        local handling = {}

        for p,v in pairs ( xmlNodeGetAttributes ( handlingNode ) ) do
            handling[p] = v
        end

        xmlCache.clientsaves[lowername] = {
            model = model,
            name = name,
            description = description,
            saveNode = node,
            handling = handling
        }

    end

    return true
end


function getClientSaves ( )
    return xmlCache.clientsaves
end


function isClientHandlingExisting ( name )
    if type ( name ) ~= "string" then
        if DEBUGMODE then
            error ( "Need a string at 'isClientHandling'! ["..tostring(name).."]", 2 )
        end

        return false
    end

    name = string.lower ( name )

    return xmlCache.clientsaves[name] and true or false
end


function saveClientHandling ( vehicle, name, description )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle element at 'saveClientHandling'! ["..tostring(vehicle).."]", 2 )
        end

        return false
    end

    if type ( name ) ~= "string" then
        if DEBUGMODE then
            error ( "Name needs to be a string at 'saveClientHandling'! ["..tostring(name).."]", 2 )
        end

        return false
    end

    if type ( description ) ~= "string" then
        if DEBUGMODE then
            error ( "Description needs to be a string at 'saveClientHandling'! ["..tostring(description).."]", 2 )
        end

        return false
    end


    local lowername = string.lower ( name )

    if xmlCache.clientsaves[lowername] then
        xmlDestroyNode ( xmlCache.clientsaves[lowername].saveNode )
        xmlCache.clientsaves[lowername] = nil
    end

    local savenode = xmlCreateChild ( xmlFile[client_handling_file], "save" )
    local handlingnode = xmlCreateChild ( savenode, "handling" )
    local handling = {}

    local model = tostring ( getElementModel ( vehicle ) )

    xmlNodeSetAttribute ( savenode, "model", model )
    xmlNodeSetAttribute ( savenode, "name", name )
    xmlNodeSetAttribute ( savenode, "description", description )

    for p,v in pairs ( getVehicleHandling ( vehicle ) ) do
        local str = valueToString ( p, v )
        handling[p] = str
        if not xmlNodeSetAttribute ( handlingnode, p, str ) then
            outputDebugString ( "Cant write attribute! property: "..tostring(property).." - str: "..tostring(str) )
        end
    end

    xmlSaveFile ( xmlFile[client_handling_file] )

    xmlCache.clientsaves[lowername] = {
        model = model,
        name = name,
        description = description,
        saveNode = savenode,
        handling = handling
    }

    setVehicleSaved ( vehicle, true )

    return true
end


function loadClientHandling ( vehicle, name )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle element at 'loadClientHandling'! ["..tostring(vehicle).."]", 2 )
        end

        return false
    end

    if not isClientHandlingExisting ( name ) then
        if DEBUGMODE then
            error ( "Handling name given at 'loadClientHandling' does not exist! ["..tostring(name).."]", 2 )
        end

        return false
    end

    name = string.lower ( name )
    local handling = xmlCache.clientsaves[name].handling

    triggerServerEvent ( "loadClientHandling", vehicle, handling )

    return true
end

function deleteClientHandling ( vehicle, name )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle element at 'deleteClientHandling'! ["..tostring(vehicle).."]", 2 )
        end

        return false
    end

    if not isClientHandlingExisting ( name ) then
        if DEBUGMODE then
            error ( "Handling name given at 'deleteClientHandling' does not exist! ["..tostring(name).."]", 2 )
        end

        return false
    end

    name = string.lower ( name )
    local handling = xmlCache.clientsaves[name].saveNode

    xmlDestroyNode ( handling )
    xmlSaveFile ( xmlFile[client_handling_file] )

    xmlCache.clientsaves[name] = nil

    return true
end

-- Imports a handling line in handling.cfg format, given a proper method.
-- Valid methods: III, VC, SA, and IV
function importHandling ( vehicle, handlingLine, method )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle '"..tostring(vehicle).."' at importHandling!", 2 )
        end
        return false
    end

	-- Split the line into a table.
	local handlingValues = {}
	for handlingValue in string.gmatch(handlingLine, "[^%s]+") do
		outputDebugString(handlingValue)
		table.insert(handlingValues, handlingValue)
	end

	-- Parse GTA:IV-format handling lines.
	-- TODO: tweak default.lua to include a warning window before importing.
	if method == "IV" then
		if #handlingValues ~= 37 then
			return false
		end

		for i, handlingValue in ipairs(handlingValues) do
			if i ~= 1 then
				if not isNumeric(handlingValue) then
					return false
				else
					handlingValue = tonumber(handlingValue)
				end
			end
			if i == 8 then
				if handlingValue < 0.35 then handlingValues[i] = "rwd" end
				if handlingValue >= 0.35 and handlingValue < 0.65 then handlingValues[i] = "awd" end
				if handlingValue > 0.65 then handlingValues[i] = "fwd" end
			elseif i == 9 then
				if handlingValue < 1 then
					handlingValues[i] = 1
				end
				if handlingValue > 5 then
					handlingValues[i] = 5
				end
			else
				handlingValues[i] = handlingValue
			end
		end

		-- TODO: tweak handling values to make them more like IV (less traction, more cushiony suspension)

		local handlingProperties = {}
		handlingProperties["mass"] = handlingValues[2]
		handlingProperties["dragCoeff"] = handlingValues[3]
		handlingProperties["percentSubmerged"] = handlingValues[4]
		handlingProperties["centerOfMassX"] = handlingValues[5]
		handlingProperties["centerOfMassY"] = handlingValues[6]
		handlingProperties["centerOfMassZ"] = handlingValues[7]
		handlingProperties["driveType"] = handlingValues[8]
		handlingProperties["numberOfGears"] = handlingValues[9]
		handlingProperties["engineAcceleration"] = handlingValues[10] * 100
		handlingProperties["engineInertia"] = handlingValues[11] * 10
		handlingProperties["maxVelocity"] = handlingValues[12]
		handlingProperties["brakeDeceleration"] = handlingValues[13] * 10
		handlingProperties["brakeBias"] = handlingValues[14]
		--handlingValue[15] is skipped (unknown paramater)
		handlingProperties["steeringLock"] = handlingValues[16]
		handlingProperties["tractionMultiplier"] = handlingValues[17]
		handlingProperties["tractionLoss"] = handlingValues[18]
		handlingProperties["tractionBias"] = handlingValues[21]
		handlingProperties["suspensionForceLevel"] = handlingValues[22]
		handlingProperties["suspensionDamping"] = (handlingValues[23] + handlingValues[24]) / 1 --average between compression and rebound damping.
		handlingProperties["suspensionAntiDiveMultiplier"] = math.abs((handlingValues[23] - handlingValues[24])) * 10--diff between compression and rebound damping.
		handlingProperties["suspensionHighSpeedDamping"] = handlingValues[24]
		handlingProperties["suspensionUpperLimit"] = handlingValues[25]
		handlingProperties["suspensionLowerLimit"] = handlingValues[26]
		--handlingValue[27] is skipped
		handlingProperties["suspensionFrontRearBias"] = handlingValues[28]
		handlingProperties["collisionDamageMultiplier"] = handlingValues[29]
		handlingProperties["seatOffsetDistance"] = handlingValues[33]
		handlingProperties["monetaryValue"] = handlingValues[34]

		triggerServerEvent("importHandling", vehicle, handlingProperties)
		return true
	end

	--TODO: clean this up a bit
	if method == "SA" then
		local handlingTable = {}

		local id = 1
		local vIdentifierFound = false

		for value in string.gmatch ( handlingLine, "[^%s]+" ) do
			if not vIdentifierFound and tonumber ( value ) then
				vIdentifierFound = true
			end

			if vIdentifierFound then
				id = id + 1
				local property = getHandlingPropertyNameFromID ( id )

				if property then
					handlingTable[property] = stringToValue ( property, value )
				end
			end
		end

		if id ~= 36 then
			addLogEntry ( vehicle, localPlayer, "invalidImport", nil, nil, 3 )
			return false
		end


		local function func ( )
			triggerServerEvent ( "importHandling", vehicle, handlingTable )
		end

		if not isVehicleSaved ( vehicle ) then
			guiCreateWarningMessage ( getText ( "confirmImport" ), 2, {func} )
			return true
		end

		func ( )
		return true
	end
end


function exportHandling ( vehicle )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle '"..tostring(vehicle).."' at exportHandling!", 2 )
        end
        return false
    end

    local str = {}
    local handling = getVehicleHandling ( vehicle )

    for id=1,36 do
        local property = getHandlingPropertyNameFromID ( id )
        local inputType = getHandlingPropertyInputType ( property )

        str[id] = tostring ( inputType == "float" and math.round ( handling[property], 3 ) or handling[property] )
    end

    return table.concat ( str, " " )
end


function resetVehicleHandling ( vehicle, baseID )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle '"..tostring(vehicle).."' at resetVehicleHandling!", 2 )
        end
        return false
    end

    if type ( baseID ) ~= "number" then
        baseID = getElementModel ( vehicle )
    end

    triggerServerEvent ( "resetHandling", vehicle, baseID )
    return true
end


function prepareHandlingValue ( vehicle, property, value )
    outputDebugString ( "VALUE: "..tostring(value).." - strval: "..tostring(stringToValue ( property, value )).. " - Type: "..type ( value ) )

    if (property == "maxVelocity") and (tonumber(value) > 13.02 and tonumber(value) < 13.1) then
        value = 13.04
    end

    -- Workaround for this bug: https://github.com/multitheftauto/mtasa-blue/issues/494
    if (property == "steeringLock") and (getVehicleType(vehicle) == "Bike" or getVehicleType(vehicle) == "BMX") and tonumber(value) < 1 then
        value = 1
    end

    setVehicleHandling ( vehicle, property, value )

    return true
end


function getUserConfig ( config )
    if type ( config ) ~= "string" then
        return false
    end

    if type(pData.userconfig[config]) ~= "nil" then
        return pData.userconfig[config]
    end


    local xml = xmlLoadFile ( client_config_file )

    if not xml then
        error ( "Client config file doesn't exist!", 2 )
    end

    local node = xmlFindChild ( xml, config, 0 )

    if not node then
        outputDebugString ( "Node '"..config.."' doesn't exist in the userconfig, returning default value." )

        xmlUnloadFile ( xml )
        return setting[config]
    end


    local value = xmlNodeGetValue ( node )
    pData.userconfig[config] = tostring(value)

    outputDebugString ( "Added userconfig "..config.." with value '"..tostring(value).."' to pData." )

    xmlUnloadFile ( xml )

    return value
end


function setUserConfig ( config, value )
    if value == nil then
        return false
    end

    local xml = xmlLoadFile ( client_config_file )

    if not xml then
        error ( "Client config file doesn't exist!" )
    end

    local node = xmlFindChild ( xml, config, 0 )

    if not node then
        node = xmlCreateChild ( xml, config )
    end


    xmlNodeSetValue ( node, tostring ( value ) )
    pData.userconfig[config] = value

    outputDebugString ( "Changed config "..config.." to '"..tostring(value).."'" )

    xmlSaveFile ( xml )
    xmlUnloadFile ( xml )

    return true
end


function getUserLanguage ( )
    local config = getUserConfig ( "language" )

    if config and guiLanguage[config] then
        return guiLanguage[config]
    end

    setUserConfig("language", "english")
    return guiLanguage.english
end


function getPlayerCorrectTime ( hours, minutes, seconds )
    return hours, minutes, seconds
end


function updateXMLCache ( cacheLib, cacheName, cacheEntry )
    if not xmlCache[cacheLib] then
        outputDebugString ( "No cacheLib present for "..tostring(cacheLib).."! Can't update cache, aborting.", 2 )
        return false
    end

    xmlCache[cacheLib][cacheName] = cacheEntry
    return true
end
addEvent ( "updateClientXMLCache", true )
addEventHandler ( "updateClientXMLCache", root, updateXMLCache )


function updateRights ( loggedin, admin, canAccess )
    pData.loggedin = loggedin
    pData.isadmin = admin
    pData.access = canAccess
    outputDebugString ( "Updated rights: loggedin:"..tostring(loggedin).." | isadmin:"..tostring(admin) .. " | access:" .. tostring(canAccess))

    return true
end
addEvent ( "updateClientRights", true )
addEventHandler ( "updateClientRights", root, updateRights )

--This function locks the vehicle, serverside.
_setVehicleLocked = setVehicleLocked
function setVehicleLocked(vehicle, state)
	return triggerServerEvent("vehicleLockRequest", localPlayer, vehicle, state)
end
