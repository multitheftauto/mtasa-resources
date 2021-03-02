function getResourceHandlingList ( resource )
    resource = validateResourcePointer ( resource )
    if not resource then
        if DEBUGMODE then
            error ( "Invalid resource at getResourceHandlingList!", 2 )
        end
        return false
    end
    
    return list
end


function saveHandlingToResource ( vehicle, resource, model )
    if not isValidVehicle ( vehicle ) then
        if DEBUGMODE then
            error ( "Invalid vehicle '"..tostring(vehicle).."' at saveHandlingToResource!", 2 )
        end
        return false
    end
    
    resource = validateResourcePointer ( resource )
    if not resource then
        if DEBUGMODE then
            error ( "Invalid resource at saveHandlingToResource!", 2 )
        end
        return false
    end
    
    if not isValidVehicleModel ( model ) then
        if DEBUGMODE then
            error ( "Invalid model '"..tostring(model).."' at saveHandlingToResource!", 2 )
        end
        return false
    end
    
    
    
    if clientside then
        local function trigger ( )
            return triggerServerEvent ( "saveToResource", localPlayer, vehicle, resource, model )
        end
        
        if xmlCache.resourcesaves[resource] and xmlCache.resourcesaves[resource][model] then
            guiCreateWarningMessage ( text.askToReplace, 2, {trigger} )
            return true
        end
        
        trigger ( )
        return true
    end
    
    
    
    if not fileExists ( ":"..resource.."/handling.lua" ) then
        local loader = fileCreate ( ":"..resource.."/handling.lua" )
        local copyfile = fileOpen ( "utils/resource_handlingloader" )
        local copybuffer = fileRead ( copyfile, fileGetSize ( copyfile ) )
        fileWrite ( loader, copybuffer )
        fileClose ( loader )
        fileClose ( copyfile )
        
        outputDebugString ( "Created new handling loader script for resource '"..resource.."'" )
    end
    
    
    
    local resourceMeta = xmlLoadFile ( ":"..resource.."/meta.xml" )
    local entryFound = false
    
    for _,node in ipairs ( xmlNodeGetChildren ( resourceMeta ) ) do
        if xmlNodeGetName ( node ) == "script" then
            if xmlNodeGetAttribute ( node, "src" ) == "handling.lua" then
                entryFound = true
                
                if xmlNodeGetAttribute ( node, "type" ) ~= "server" then
                    xmlNodeSetAttribute ( node, "type", "server" )
                end
                
                break
            end
        end
    end
    
    if not entryFound then
        local node = xmlCreateChild ( resourceMeta, "script" )
        xmlNodeSetAttribute ( node, "src", "handling.lua" )
        xmlNodeSetAttribute ( node, "type", "server" )
        
        outputDebugString ( "Added meta.xml entry for the handling loader script in resource '"..resource.."'" )
    end
    
    xmlSaveFile ( resourceMeta )
    xmlUnloadFile ( resourceMeta )
    
    
    
    local handlingXML = xmlLoadFile ( ":"..resource.."/handling.xml" )
    
    if not handlingXML then
        handlingXML = xmlCreateFile ( ":"..resource.."/handling.xml", "root" )
        outputDebugString ( "Created new handling file for resource '"..resource.."'" )
    end
    
    local xmlEntry = xmlFindChild ( handlingXML, tostring ( model ), 0 )
    
    if not xmlEntry then
        xmlEntry = xmlCreateChild ( handlingXML, tostring ( model ) )
    end
    
    for property,value in pairs ( getVehicleHandling ( vehicle ) ) do
        xmlNodeSetAttribute ( xmlEntry, property, value )
    end
    
    xmlSaveFile ( handlingXML )
    xmlUnloadFile ( handlingXML )
    return true
end
if serverside then
    addEvent ( "saveToResource", true )
    addEventHandler ( "saveToResource", root, saveHandlingToResource )
end


function loadHandlingFromResource ( vehicle, resource, model )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    resource = validateResourcePointer ( resource )
    if not resource then
        return false
    end
    
    if not isValidVehicleModel ( model ) then
        return false
    end
    
    if clientside then
        local function trigger ( )
            return triggerServerEvent ( "loadFromResource", root, vehicle, resource, model )
        end
        
        if not isVehicleSaved ( vehicle ) then
            guiCreateWarningMessage ( "text.askToLoad", 2, {trigger} )
            return true
        end
        
        trigger ( )
        return true
    end
    
    local handlingXML = xmlLoadFile ( ":"..resource.."/handling.xml" )
    
    if not handlingXML then
        outputDebugString ( "Can't retrieve resource handling as it has no handling file at 'loadHandlingFromResource'! ["..resource.."]", 2 )
        return false
    end
    
    local xmlEntry = xmlFindChild ( handlingXML, tostring ( model ), 0 )
    
    if not xmlEntry then
        outputDebugString ( "There's no handling for model "..tostring(model).." in resource "..resource.." at 'loadHandlingFromResource'!", 2 )
        return false
    end
    
    local handlingTable = {}
    for property,value in pairs ( xmlNodeGetAttributes ( xmlEntry ) ) do
        handlingTable[property] = stringToValue ( property, value )
    end
    
    loadHandlingTable ( handlingTable )
    return true
end
if serverside then
    addEvent ( "loadFromResource", true )
    addEventHandler ( "loadFromResource", root, loadHandlingFromResource )
end


function saveHandlingToServer ( player, vehicle, name, description )
    if not isValidPlayer ( player ) then
        return false
    end
    
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    if type ( name ) ~= "string" then
        return false
    end
    
    if type ( description ) ~= "string" then
        return false
    end
    
    local cache = xmlCache.serversaves[string.lower(name)]
    
    if clientside then
        local function trigger ( )
            return triggerServerEvent ( "saveToServer", localPlayer, player, vehicle, name, description )
        end
        
        if cache then
            guiCreateWarningMessage ( text.askToReplace, 2, {trigger} )
        end
        
        trigger ( )
        return true
    end
    
    local handlingXML = xmlGetFile ( server_handling_file )
    
    if not handlingXML then
        handlingXML = xmlAddFile ( server_handling_file )
        outputDebugString ( "Created new server handling file ["..tostring(handlingXML).."]" )
    end
    
    if cache then
        xmlDestroyNode ( cache.node.save )
    end
    
    local playerName = getPlayerName ( player )
    local vehicleModel = tostring ( getElementModel ( vehicle ) )
    local saveNode = xmlCreateChild ( handlingXML, "save" )
    local handlingNode = xmlCreateChild ( saveNode, "handling" )
    
    local addCache = {
        name = name,
        description = description,
        player = playerName,
        node = {
            save = saveNode,
            handling = handlingNode
        },
        handling = {}
    }
    
    xmlNodeSetAttribute ( saveNode, "name", name )
    xmlNodeSetAttribute ( saveNode, "description", description )
    xmlNodeSetAttribute ( saveNode, "player", playerName )
    
    for property,value in pairs ( getVehicleHandling ( vehicle ) ) do
        addCache.handling[property] = tostring ( value )
        xmlNodeSetAttribute ( handlingNode, property, tostring ( value ) )
    end
    
    xmlSaveFile ( handlingXML )
    
    cache = addCache
    
    triggerClientEvent ( player, "updateClientCache", player, "serversaves", string.lower ( name ), addCache )
    
    addLogEntry ( --[[ FILL ME ]] )
    
    return true
end


if serverside then
    addEvent ( "saveToServer", true )
    addEventHandler ( "saveToServer", root, saveHandlingToServer )
end


function saveHandlingToClient ( vehicle, name, description )
    if not isValidVehicle ( vehicle ) then
        return false
    end

    local handlingXML = xmlGetFile ( client_handling_file )
    
    if not handlingXML then
        handlingXML = xmlAddFile ( client_handling_file )
        outputDebugString ( "Created new client handling file ["..tostring(handlingXML).."]" )
    end
    
    local cache = xmlCache.clientsaves[string.lower(name)]
    
    local text = language[setting.language]
    
    --------------------------------------------------
    local function save ( )
        local vehicleModel = tostring ( getElementModel ( vehicle ) ) -- MODEL NEEDED? its included with the handling!
        local saveNode = xmlCreateChild ( handlingXML, "save" )
        local handlingNode = xmlCreateChild ( saveNode, "handling" )
        
        cache = {
            model = vehicleModel,
            name = name,
            description = description,
            node = {
                save = saveNode,
                handling = handlingNode
            },
            handling = {}
        }
        
        xmlNodeSetAttribute ( saveNode, "model", vehicleModel )
        xmlNodeSetAttribute ( saveNode, "name", name )
        xmlNodeSetAttribute ( saveNode, "description", description )
        
        for property,value in pairs ( getVehicleHandling ( vehicle ) ) do
            cache.handling[property] = tostring ( value )
            xmlNodeSetAttribute ( handlingNode, property, tostring ( value ) )
        end
        
        xmlSaveFile ( handlingXML )
        
        outputHandlingLog ( text.succesSavedClient )
        
        showMenu ( previousMenu )
        
        return true
    end
    --------------------------------------------------
    
    if cache then
        local function func ( )
            xmlDestroyNode ( cache.node.save )
            save ( )
        end
        
        guiCreateWarningMessage ( text.askToReplace, 2, {func} )
        return true
    end
    
    save ( )
    return true
end


function loadHandlingFromClient ( vehicle, lowerCaseName )
    loadHandling ( vehicle, lowerCaseName, "clientsaves" )
    return
end


function loadHandlingFromServer ( vehicle, lowerCaseName )
    loadHandling ( vehicle, lowerCaseName, "serversaves" )
    return
end


function loadHandling ( vehicle, lowerCaseName, cacheLib )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    local cache = xmlCache[cachelib][lowerCaseName]
    
    if not cache then
        outputHandlingLog ( "unexisting save" )
        return false
    end
    
    local function hndload ( )
        loadHandlingTable ( vehicle, cache.handling )
        showMenu ( previousMenu )
    end
    
    if not isSaved ( vehicle ) then
        guiCreateWarningMessage ( text.askToLoad, 2, {hndload} )
        return true
    end
    
    hndload ( )
end


function shareHandlingWithPlayer ( senderPlayer, targetPlayer, vehicle )
    if not isValidPlayer ( senderPlayer ) then
        return false
    end
    
    if not isValidPlayer ( targetPlayer ) then
        return false
    end
    
    if not isValidVehicle ( vehicle ) then
        return false
    end

    if clientside then
        triggerServerEvent ( "shareHandling", localPlayer, senderPlayer, targetPlayer, vehicle )
        
        --guiCreateWarningMessage ( "string to replace | send your handling to player "..getPlayerName ( targetPlayer ) )
        
        return true
    end
    
    triggerClientEvent ( targetPlayer, "receiveHandling", targetPlayer, senderPlayer, vehicle )
    return true
end
if serverside then
    addEvent ( "shareHandling", true )
    addEventHandler ( "shareHandling", root, shareHandlingWithPlayer )
end


function receiveSharedHandling ( senderPlayer, vehicle )
    outputDebugString ( "Recieved handling from "..getPlayerName ( senderPlayer ).." :D" )
    return true
end
addEvent ( "receiveHandling", true )
addEventHandler ( "receiveHandling", root, receiveSharedHandling )