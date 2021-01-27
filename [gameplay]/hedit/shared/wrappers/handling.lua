_getOriginalHandling = getOriginalHandling
_getVehicleHandling = getVehicleHandling
if serverside then
    _setVehicleHandling = setVehicleHandling
end





function getVehicleHandling ( vehicle )
    if not isValidVehicle ( vehicle ) then 
        error ( "Invalid vehicle element at 'getVehicleHandling'! [arg:1]", 2 )
    end
    
    local handling = _getVehicleHandling ( vehicle )
    if not handling then
        error ( "Something went wrong. Does the vehicle still exist?", 2 )
    end
    
    return conformHandlingTable ( handling, getElementModel ( vehicle ) )
end





function setVehicleHandling ( vehicle, property, value, withLog )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    if not isHandlingPropertyValid ( property ) then
        return false
    end
    
    if not value then
        return false
    end
    
    if withLog ~= false then
        withLog = true
    end
    
    
    
    if clientside then
        triggerServerEvent ( "setHandling", root, vehicle, property, value, withLog )
        return true
    end
    
    
    
    local setValue = value
    
    
    
    if not source then
        withLog = false
    end 
    
    
    if not isHandlingPropertyEnabled(property) then
		addLogEntry(vehicle, client, "disabledProperty", {property, value}, nil, 3)
		return false
	end
	
    if isHandlingPropertyCorrectable ( property ) then
        local corrected = isValueCorrected ( value )
        
        if not corrected then
            setValue = getOriginalHandlingValue ( value )
            
        elseif corrected == nil then
        
            if withLog then
                addLogEntry ( vehicle, client, "invalidValue", { property, value }, nil, 3 )
            end
        
            return false
        end
        
        
        
    elseif isHandlingPropertyCenterOfMass ( property ) then
        
        local com = _getVehicleHandling ( vehicle )["centerOfMass"]
        if property == "centerOfMassX" then
            setValue = { value, com[2], com[3] }
        elseif property == "centerOfMassY" then
            setValue = { com[1], value, com[3] }
        elseif property == "centerOfMassZ" then
            setValue = { com[1], com[2], value }
        end
        
        
        
    elseif isHandlingPropertyHexadecimal ( property ) and type ( value ) == "string" then

        setValue = tonumber ( "0x"..value )
        
        
        
    elseif property == "centerOfMass" then

        if type ( value ) ~= "table" then
            setValue  = {
                tonumber ( gettok ( value, 1, 44 ) ),
                tonumber ( gettok ( value, 2, 44 ) ),
                tonumber ( gettok ( value, 3, 44 ) )
            }
        end



    else

        local num = tonumber ( value )

        if not num then
            if withLog then
                addLogEntry ( vehicle, client, "needNumber", { property }, nil, 2 )
            end

            return false
        end

        setValue = num
    end
    




    if not isHandlingPropertySupported ( property ) then
        if withLog then
            addLogEntry ( vehicle, client, "unsupportedProperty", { property }, nil, 2 )
        end
        
        return false
    end
    
    if not isHandlingValueWithinLimits ( property, setValue ) then
        if withLog then
            addLogEntry ( vehicle, client, "exceedLimits", { property, value }, nil, 3 )
        end
        
        return false
    end
    
    
    
    
    
    local oldValue = getVehicleHandling(vehicle)[property]
    if property == "centerOfMass" then
        local hnd = getVehicleHandling ( vehicle )
        oldValue = math.round ( hnd.centerOfMassX )..", "..math.round ( hnd.centerOfMassY )..", "..math.round ( hnd.centerOfMassZ )
    end
    
    -- Compare to see if the values are the same!
    
    local setProperty = isHandlingPropertyCenterOfMass ( property ) and "centerOfMass" or property

    --[[if isHandlingPropertyHexadecimal ( property ) then
        outputChatBox ( property..": value="..tostring(value).." - setValue="..tostring(setValue) )
    end]]
    
    if not _setVehicleHandling ( vehicle, setProperty, setValue ) then
        if withLog then
            addLogEntry ( vehicle, client, "unableToChange", { property, value }, nil, 3 )
        end
        
        outputDebugString ( "Can't change property "..property.." to value '"..tostring(value).."'" )
        
        return false
    end
    
    
    if withLog then

        local data = getVehicleHandling ( vehicle )[property]
        if property == "centerOfMass" then
            local hnd = getVehicleHandling ( vehicle )
            data = math.round ( hnd.centerOfMassX )..", "..math.round ( hnd.centerOfMassY )..", "..math.round ( hnd.centerOfMassZ )
        elseif type ( data ) == "number" then
            data = tostring ( math.round ( data ) )
        end

        addLogEntry ( vehicle, client, "successRegular", { property, data }, oldValue, 1 )
        

        setVehicleSaved ( vehicle, false )
    end
    
    
    
    
    
    setElementData ( vehicle, "hedit:vehiclepreviousvalue."..property, oldValue )
   
    triggerEvent ( "onVehicleHandlingChange", client, vehicle, property, oldValue, value )
    
    if isValidPlayer ( client ) then
        triggerClientEvent ( client, "onClientVehicleHandlingChange", vehicle, property, oldValue, value )
    end
    
    return true
end
if serverside then
    addEvent ( "setHandling", true )
    addEventHandler ( "setHandling", root, setVehicleHandling )
end





function getOriginalHandling ( model, force )
    if not force and not isValidVehicleModel ( model ) then
        error ( "Invalid model given at 'getOrignalHandling'! [arg:1,"..tostring(model).."]", 2 )
        return nil
    end
    
    local data = getElementData ( root, "originalHandling."..tostring(model) )
    if not data or force then
        data = conformHandlingTable ( _getOriginalHandling ( model ), model )
    end
    
    return data
end





local correctedValues = {
    ["fwd"] = "f",
    ["rwd"] = "r",
    ["awd"] = "4",
    ["petrol"] = "p",
    ["diesel"] = "d",
    ["electric"] = "e",
    ["long"] = 0,
    ["small"] = 1,
    ["big"] = 2,
}

local originalValues = {}
for k,v in pairs ( correctedValues ) do
    originalValues[v] = k
end    

function getCorrectedHandlingValue ( value )
    return correctedValues[value] or 3 -- or 3 is when head or taillight is 'tall', this has not been implemented in MTA
end

function getOriginalHandlingValue ( value )
    return originalValues[value] or "big" -- as 3 cant be converted to 'tall', we use 'big'
end

function isValueCorrected ( value )
    if correctedValues[value] then
        return true
    end
    if originalValues[value] then
        return false
    end
    return nil
end



function conformHandlingTable ( handling, model )
    handling["identifier"] = getVehicleIdentifierByModel ( model )
    handling["centerOfMassX"] = handling["centerOfMass"][1]
    handling["centerOfMassY"] = handling["centerOfMass"][2]
    handling["centerOfMassZ"] = handling["centerOfMass"][3]
    handling["driveType"] = getCorrectedHandlingValue ( handling["driveType"] )
    handling["engineType"] = getCorrectedHandlingValue ( handling["engineType"] )
    handling["headLight"] = getCorrectedHandlingValue ( handling["headLight"] )
    handling["tailLight"] = getCorrectedHandlingValue ( handling["tailLight"] )
    handling["modelFlags"] = string.format ( "%X", handling["modelFlags"] )
    handling["handlingFlags"] = string.format ( "%X", handling["handlingFlags"] )
    
    handling["centerOfMass"] = nil
    return handling
end