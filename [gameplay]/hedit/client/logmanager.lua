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
    
    
    triggerServerEvent ( "addToLog", root, vehicle, player, textPointer, arguments, oldValue, level )
    return true
end





function clearLog ( )
    local minilog = heditGUI.specials.minilog
    local size = #minilog
    
    for i=1,#minilog do
        guiSetText ( minilog[i].timestamp, "" )
        guiSetText ( minilog[i].text,      "" )
        guiLabelSetColor ( minilog[i].text, 255, 255, 255 )
        guiElements[minilog[i].timestamp] = { "handlingLogItem", "special", "none", nil, guiGetElementEvents ( minilog[i].timestamp ) }
        guiElements[minilog[i].text] = { "handlingLogItem", "special", "none", nil, guiGetElementEvents ( minilog[i].timestamp ) }
    end
    
    for i,v in ipairs ( logItems ) do
        destroyElement ( v[1] )
        destroyElement ( v[2] )
    end
    
    logCreated = false
    logItems = {}
    
    return true
end





function addToMiniLog ( entry )
    local minilog = heditGUI.specials.minilog
    local size = #minilog
    
    for i=1,size-1 do
        guiSetText ( minilog[i].timestamp, guiGetText ( minilog[i+1].timestamp ) )
        guiSetText ( minilog[i].text,      guiGetText ( minilog[i+1].text      ) )
        guiLabelSetColor ( minilog[i].text, unpack ( {guiLabelGetColor ( minilog[i+1].text )} ) )
        guiElements[minilog[i].timestamp] = guiElements[minilog[i+1].timestamp]
        guiElements[minilog[i].text] = guiElements[minilog[i+1].text]
    end
    
    if not entry.arguments then
        entry.arguments = {}
    end
    
    local property = entry.arguments[1]
    local value = entry.arguments[2]
    
    --if isHandlingPropertHexadecimal ( property ) then
        -- todo


    if property == "centerOfMass" then

        entry.arguments[1] = getHandlingPropertyFriendlyName ( "centerOfMass" )

    elseif handlingLimits[property] then

        entry.arguments[1] = getHandlingPropertyFriendlyName ( property )
        if handlingLimits[property].options and value then
            entry.arguments[2] = getHandlingPropertyOptionName ( property, value )
        end

    end



    for i,v in ipairs ( entry.arguments ) do
        entry.arguments[i] = tostring ( v )
    end
    
    local timeStamp = string.format ( "[%02d:%02d:%02d]", getPlayerCorrectTime ( entry.timeStamp.hour, entry.timeStamp.minute, entry.timeStamp.second ) )
    local text = string.format ( getText ( entry.textPointer ), unpack ( entry.arguments ) )
    
    guiSetText ( minilog[size].timestamp, timeStamp )
    guiSetText ( minilog[size].text, text )
    guiLabelSetColor ( minilog[size].text, unpack ( errorColor[entry.level] ) )
    
    guiElements[minilog[size].timestamp] = { "handlingLogItem", "special", "none", { entry.responsiblePlayer, entry.previousValue }, guiGetElementEvents ( minilog[size].timestamp ) }
    guiElements[minilog[size].text] = { "handlingLogItem", "special", "none", { entry.responsiblePlayer, entry.previousValue }, guiGetElementEvents ( minilog[size].text ) }
    
    return true
end





function addToFullLog ( entry )
    if logCreated then
        local logpane = heditGUI.menuItems.handlinglog.guiItems.logpane
        local line = #logItems * 15
        
        local timeStamp = "["..table.concat(getPlayerCorrectTime(entry.timeStamp.hour,entry.timeStamp.minute,entry.timeStamp.second),":").."]"
        local text = string.format ( getText ( entry.textPointer ), unpack ( entry.arguments ) )
        
        local labelTime = guiCreateLabel ( 0, line, 45, 20, timeStamp, false, logpane )
        local labelText = guiCreateLabel ( 45, line, 220, 20, text, false, logpane )
        guiSetFont ( labelTime, "default-small" )
        guiSetFont ( labelText, "default-small" )
        
        logItems[#line+1] = { labelTime, labelText }
        guiElements[labelTime] = { "handlingLogItem", "special", "none", { entry.responsiblePlayer, entry.previousValue }, nil }
        guiElements[labelText] = { "handlingLogItem", "special", "none", { entry.responsiblePlayer, entry.previousValue }, nil }
        
        guiScrollPaneSetVerticalScrollPosition ( logpane, 100 )
        guiLabelSetColor ( labelText, unpack ( errorColor[entry.level] ) )
        
        return true
    end
    
    return false
end





function addToLogGUI ( entry )
    addToMiniLog ( entry )
    addToFullLog ( entry )
    guiUpdateView ( currentView )
    
    return true
end
addEvent ( "addToLogGUI", true )
addEventHandler ( "addToLogGUI", root, addToLogGUI )





function requestMiniLog ( vehicle )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    triggerServerEvent ( "requestMiniLog", root, vehicle, #heditGUI.specials.minilog )
    return true
end





function requestFullLog ( vehicle )
    if not isValidVehicle ( vehicle ) then
        return false
    end
    
    triggerServerEvent ( "requestFullLog", root, vehicle )
    return true
end





function receiveMiniLog ( miniLog )
    for i,entry in ipairs ( miniLog ) do
        addToMiniLog ( entry )
    end
    
    return true
end
addEvent ( "receiveMiniLog", true )
addEventHandler ( "receiveMiniLog", root, receiveMiniLog )





function receiveFullLog ( fullLog )
    logCreated = true
    
    for i,entry in ipairs ( fullLog ) do
        addToFullLog ( entry )
    end
    
    return true
end
addEvent ( "receiveFullLog", true )
addEventHandler ( "receiveFullLog", root, receiveFullLog )