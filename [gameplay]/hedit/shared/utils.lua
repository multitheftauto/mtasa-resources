--[[
    checkArguments ( table { "type", argument }, ... ) -- UNUSED
    
    validateResourcePointer ( string/userdata resource )
    
    isValidPlayer ( element player )
    isValidVehicle ( element vehicle )
    isValidVehicleModel ( int model )
    
    isHandlingPropertyValid ( string property )
    isHandlingPropertyCorrectable ( string property )
    isHandlingPropertyCenterOfMass ( string property )
    isHandlingPropertyHexadecimal ( string property )
    getHandlingLimits ( string property )
    isHandlingValueWithinLimits ( string property, int/float value )
    
    getVehicleIdentifierByModel ( integer model )
    getVehicleModelsByIdentifier ( string identifier )
    
    getHandlingPropertyNameFromID ( int id )
    getHandlingPropertyIDFromName ( string property )
    getHandlingPropertyInputType ( string property )
    
    getHandlingByteEnabled ( element vehicle, string property, integer byte, string value )
    
    getHandlingPreviousValue ( element vehicle, string property )
    
    setVehicleSaved ( element vehicle, bool saved )
    isVehicleSaved ( element vehicle )
    
    updateCache ( string cacheLib, string cacheChild, table cacheEntry )
    getEnabledValuesFromByteValue ( string byteValue )
    valueToString ( string property, var value )
    stringToValue ( string property, string value )
    numberToHex ( int integer )
    tobool ( var variable )
    RGBtoHEX ( ... )
    math.round ( int number )
    table.size ( table table )
]]

_emptyfn = function()end

colors = {
    yellow = {255, 255, 128, 255},
    cyan = {27, 224, 224, 255}
}

-- Debug utility
Debug = setmetatable({}, {
        __index = function(t, k)
            return DEBUGMODE and _G[k] or _emptyfn
        end
    }
)

function checkArguments ( ... ) -- return success, type, value
    local types = {
        player = isValidPlayer,
        vehicle = isValidVehicle,
        vehicleModel = isValidVehicleModel,
        --resource = validateResourcePointer,
        property = isHandlingPropertyValid
    }
    
    for _,tab in ipairs ( {...} ) do
        if not types[ tab[1] ] ( tab[2] ) then
            return false, tab[1], tab[2]
        end
    end
    
    return false, nil, nil
end





function validateResourcePointer ( resource )
    if type ( resource ) == "userdata" then
        resource = getResourceName ( resource )
        
        if not resource then
            return false
        end
    end
    
    if type ( resource ) == "string" and not getResourceFromName ( resource )  then
        return false
    end
    
    return resource
end





function isValidPlayer ( player )
    if not isElement ( player ) or getElementType ( player ) ~= "player" then
        return false
    end
    
    return true
end





function isValidVehicle ( vehicle )
    if not isElement ( vehicle ) or getElementType ( vehicle ) ~= "vehicle" then
        return false
    end
    
    return true
end





function isValidVehicleModel ( model )
    if type ( model ) ~= "number" then
        error ( "Need a number!", 2 )
        return false
    end

    return (model >= 400) and (model <= 611)
end


function isVehicleATrailer ( model )
    if isElement ( model ) then
        model = getElementModel ( model )
    end

    local trailers = {
        [606] = true, [607] = true, [610] = true,
        [611] = true, [584] = true, [608] = true,
        [435] = true, [450] = true, [591] = true
    }

    return trailers[model] == true
end



--This function returns true if a setting is enabled in the meta, false otherwise.
function isHandlingPropertyEnabled(property)
	if getLocalPlayer then
		return (getElementData(resourceRoot, "propertySettings", false)[property]) or true
	else
		return tobool(get("*enable_"..property))
	end
end

function isHandlingPropertyValid ( property )
    if property == "centerOfMass" or handlingLimits[property] then
        return true
    end
    
    return false
end





function isHandlingPropertySupported ( property )
    local unsupported = {
        ["ABS"]=true, ["monetary"]=true, 
        ["headLight"]=true, ["tailLight"]=true,
        ["animGroup"]=true, ["identifier"]=true
    }
    
    return not unsupported[property]
end





function isHandlingPropertyCorrectable ( property )
    local props ={ 
        ["driveType"]=true, ["engineType"]=true,
        ["headLight"]=true, ["tailLight"]=true
    }
    
    return props[property] or false
end





function isHandlingPropertyCenterOfMass ( property )
    local props = {
        ["centerOfMassX"]=true, ["centerOfMassY"]=true,
        ["centerOfMassZ"]=true
    }
    
    return props[property] or false
end





function isHandlingPropertyHexadecimal ( property )
    if property == "modelFlags" or property == "handlingFlags" then
        return true 
    end
    
    return false
end





function getHandlingLimits ( property )
    if not isHandlingPropertyValid ( property ) then
        return false
    end

    if handlingLimits[property] and handlingLimits[property].limits then
        if tonumber ( handlingLimits[property].limits[1] ) then
            local min = tonumber(handlingLimits[property].limits[1])
            local max = tonumber(handlingLimits[property].limits[2])

            return min,max
        end

        return nil
    end

    return nil
end




--Returns true if the given value is within the limits for the handling type (as defined in shared\variables\handlingMTA.lua), false otherwise.
function isHandlingValueWithinLimits ( property, value )
    if handlingLimits[property] and handlingLimits[property].limits then
		local isNumeric = tonumber(handlingLimits[property].limits[1])
		if isNumeric and type ( value ) == "number" then
			local min,max = getHandlingLimits ( property )
			
			if value >= min then
				if value <= max then
					return true
				else
					return false
				end
			else
				return false
			end
        end
    end
    
    return true
end





function getVehicleIdentifierByModel ( model )
    if isValidVehicleModel ( model ) then
        return vehicleModelIdentifier[model]
    end
    
    return nil
end





function getVehicleModelsByIdentifier ( identifier )
    return vehicleIdentifierModels[identifier]
end





function getHandlingPropertyNameFromID ( id )
    id = tonumber ( id )
    
    if not id then
        return false
    end
    
    return propertyID[id]
end





function getHandlingPropertyIDFromName ( property )
    if not isHandlingPropertyValid ( property ) then
        return false
    end
    
    return handlingLimits[property].id 
end





function getHandlingPropertyInputType ( property )
    if not isHandlingPropertyValid ( property ) then
        return false
    end
    
    return handlingLimits[property].input
end





function getHandlingOptionID ( property, option )
    if not isHandlingPropertyValid ( property ) then
        return false
    end
    
    if not handlingLimits[property] or type ( handlingLimits[property].options ) ~= "table" then
        return false
    end
    
    for i,v in ipairs ( handlingLimits[property].options ) do
        if v == option then
            return i
        end
    end
    
    return false
end





function getHandlingByteEnabled ( property, byte, value, byteValue ) -- Seems to be invalid!
    if not isHandlingPropertyValid ( property ) then
        return nil
    end
    
    if not isHandlingPropertyHexadecimal ( property ) then
        return nil
    end
    
    local function toValue ( hex )
        local tbl = { ["1"]={"1"},         ["2"]={"2"},         ["3"]={"1","2"},     ["4"]={"4"},     ["5"]={"1","4"},
                      ["6"]={"2","4"},     ["7"]={"1","2","4"}, ["8"]={"8"},         ["9"]={"1","8"}, ["A"]={"2","8"}, 
                      ["B"]={"1","2","8"}, ["C"]={"4","8"},     ["D"]={"1","4","8"}, ["E"]={"1","2","4","8"} }
        return tbl[hex]
    end
    
    local val = toValue ( byteValue )
    if val[value] then 
        return true
    end
    
    return false
end





function getHandlingPreviousValue ( vehicle, property )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    if not isHandlingPropertyValid ( property ) then
        return false
    end
    
    return getElementData ( vehicle, "hedit:vehiclepreviousvalue."..property )
end





function setVehicleSaved ( vehicle, saved )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    if clientside then
        triggerServerEvent ( "setSaved", root, vehicle, saved )
        return true
    end
    
    setElementData ( vehicle, "hedit:saved", tostring ( saved ) )
    
    local occupants = getVehicleOccupants ( vehicle )
    local seats = getVehicleMaxPassengers ( vehicle )
    
    for seat=0,seats do
        local player = occupants[seat]
        
        if isValidPlayer ( player ) then
            triggerClientEvent ( player, "updateVehicleText", vehicle )
        end
    end
    
    return true
end
if serverside then
    addEvent ( "setSaved", true )
    addEventHandler ( "setSaved", root, setVehicleSaved )
end




function isVehicleSaved ( vehicle )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    if not getElementData ( vehicle, "hedit:saved" ) then
        setElementData ( vehicle, "hedit:saved", "true" )
    end
    
    return tobool ( getElementData ( vehicle, "hedit:saved" ) )
end





function getEnabledValuesFromByteValue ( byteValue )
    local tbl = { ["1"]={"1"},         ["2"]={"2"},         ["3"]={"1","2"},     ["4"]={"4"},     ["5"]={"1","4"},
                  ["6"]={"2","4"},     ["7"]={"1","2","4"}, ["8"]={"8"},         ["9"]={"1","8"}, ["A"]={"2","8"}, 
                  ["B"]={"1","2","8"}, ["C"]={"4","8"},     ["D"]={"1","4","8"}, ["F"]={"1","2","4","8"} }          
    return tbl[byteValue] or {}
end





function valueToString ( property, value )
    if type ( value ) == "number" then
        
        value = math.round ( value )
        
    elseif type ( value ) == "table" then -- Previously for centerOfMass, but property is disabled.
        
        local str = ""
        
        for i,v in ipairs ( value ) do
            str = str..math.round ( v ).. ( i < #value and ", " or "" )
        end
        
        value = str

    end
    
    return tostring ( value )
end





function stringToValue ( property, value )
    if property == "ABS" then
        return tobool ( value )
    end
    
    if isHandlingPropertyHexadecimal ( property ) then
        return tonumber ( "0x"..value )
    end
    
    if property == "driveType" or property == "engineType" then
        return value
    end
    
    return tonumber ( value ) or value
end





function numberToHex ( num )
    if type ( num ) ~= "number" then
        error ( "Need a number!", 2 )
        return false
    end
    
    local hexnums = {
        "0","1","2","3","4","5","6","7",
        "8","9","A","B","C","D","E","F"
    }
    local hex,m = "",num%16
    
    if (num-m) == 0 then
        return hexnums[m+1]
    end
    
    if not hexnums[m+1] then
        outputChatBox ( tostring ( m ) )
    end

    return numberToHex((num-m)/16)..hexnums[m+1]
end





function tobool ( var )
    if type(var) == "nil" then return nil end
    local conform = {
        [0]=false, [1] = true,
        ["0"]=false, ["1"] = true,
        ["false"] = false, ["true"] = true,
        [true] = true, [false] = false,
    }
    local t = type ( var )
    if t == "number" or t == "string" or t == "boolean" then
        if conform[var] == nil then
            error ( "Invalid string or number given to convert at 'tobool'! [arg:1,"..tostring(var).."]", 2 )
        end
        return conform[var]
    end
    error ( "Invalid value to convert at 'tobool'! [arg:1,"..tostring(var).."]", 2 )
    return nil
end


--Returns true if the given value is numeric, false otherwise.
function isNumeric(value)
	return (tonumber(value) and true) or false
end



function RGBtoHEX(...)
    return string.format ( string.rep ( "%.2X", #{...} ), unpack ( {...} ) )
end





function math.round ( number, float )
    if not float then
        float = 3
    end
    
    if type ( number ) == "number" then
        return tonumber ( string.format ( "%."..tostring(float).."f", number ) )
    end
    
    outputDebugString ( "Not a number at math.round! ["..tostring(number).."]" )
    return number
end





function table.size ( tab )
    local length = 0
    
    for _ in pairs ( tab ) do
        length = length + 1
    end
    
    return length
end
