_outputChatBox = outputChatBox
if serverside then
    function outputChatBox ( str, r, g, b )
        return _outputChatBox ( "#FFFFFF[HEDIT] #D00000"..str, root, r or 255, g or 255, b or 255, true )
    end
else
    function outputChatBox ( str, r, g, b )
        return _outputChatBox ( "#FFFFFF[HEDIT] #D00000"..str, r or 255, g or 255, b or 255, true )
    end
end


_outputDebugString = outputDebugString
function outputDebugString(...)
    if DEBUGMODE then
       return _outputDebugString(...)
    end
end


_getVehicleNameFromModel = getVehicleNameFromModel
function getVehicleNameFromModel ( model )
    if not isValidVehicleModel ( model ) then
        outputDebugString ( "Invalid model "..tostring(model).." in 'getVehicleFromModel'!" )
        
        return false
    end
   
    local name = _getVehicleNameFromModel ( model )
    
    if not name or name == "" then
        name = "ID: ".. model
    end
    
    return name
end


_getVehicleModelFromName = getVehicleModelFromName
function getVehicleModelFromName ( name )
    local subname = string.gsub ( name, "ID: ", "" )
    
    if subname ~= name then
        return tonumber ( subname )
    end
    
    return _getVehicleModelFromName ( name )
end


-- Fix for trailers
_getVehicleOccupants = getVehicleOccupants
function getVehicleOccupants ( vehicle )
    return isVehicleATrailer ( vehicle )
        and {[0] = getVehicleController ( vehicle )}
        or _getVehicleOccupants ( vehicle )
end


-- Fix for trailers
_getVehicleMaxPassengers = getVehicleMaxPassengers
function getVehicleMaxPassengers ( vehicle )
    return isVehicleATrailer ( vehicle )
        and 1
        or _getVehicleMaxPassengers ( vehicle )
end


_xmlLoadFile = xmlLoadFile
function xmlLoadFile ( file )
    if type ( file ) ~= "string" then
        outputDebugString ( "Need a string at xmlLoadFile!" )

        return false
    end

    if not fileExists ( file ) then
        outputDebugString ( "XML '"..file.."' does not exist." ) 

        return false
    end

    if xmlFile[file] then
        return xmlFile[file]
    end

    local xml = _xmlLoadFile ( file )
    
    if not xml then
        outputDebugString ( "Cannot open XML '"..tostring(file).."' for some reason." )

        return false
    end

    xmlFile[file] = xml
    return xml
end


_xmlCreateFile = xmlCreateFile
function xmlCreateFile ( file, rootNode )
    local xml = _xmlCreateFile ( file, rootNode )
    
    if not xml then
        return false
    end

	xmlSaveFile(xml)
	xmlUnloadFile(xml)
	
	xml = xmlLoadFile(file)
	
    xmlFile[file] = xml
    return xml
end


_xmlSaveFile = xmlSaveFile
function xmlSaveFile ( file )
    if type ( file ) == "string" then
        file = xmlFile[file]
    end
    
    if type ( file ) ~= "userdata" then
        return false
    end

    _xmlSaveFile ( file )

    return true
end


_xmlUnloadFile = xmlUnloadFile
function xmlUnloadFile ( file )
    local strfile
    
    if type ( file ) == "string" then
        strfile = file
        file = xmlFile[file]
    end

    if type ( file ) ~= "userdata" then
        return false
    end

    _xmlUnloadFile ( file )
    
    if strfile then
        xmlFile[file] = nil
        return true
    end
    
    for k,v in pairs ( xmlFile ) do
        if v == file then
            xmlFile[k] = nil
        end
    end
    
    return false
end