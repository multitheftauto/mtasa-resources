--[[
    guiCreateID ( element gui, string id )
    guiGetElementFromID ( string id )
    
    guiGetElementParent ( element gui )
    guiGetElementInputType ( element gui ) -- Only for view items!
    guiGetElementProperty ( element gui ) -- Only for config view items!
    guiGetElementInfo ( element gui )
    guiGetElementEvents ( element gui )
    
    toggleEditor ( )
    setVisible ( bool visible )
    
    setPointedElement ( element guiElement, bool pointing )
    showOriginalValue ( string key, string state )
    showPreviousValue ( string key, string state )
    handleKeyState ( string "up"/"down" )
    
    guiSetInfoText ( string header, string text )
    guiSetStaticInfoText ( string header, string text )
    guiResetInfoText ( )
    guiResetStaticInfoText ( )
    
    guiToggleUtilityDropDown ( [string utility = all] )
    guiShowView ( string view )
    guiUpdateView ( )
    
    guiTemplateGetViewButtonText ( string viewbutton )
    guiTemplateGetItemText ( string view, string item )
    
    getViewShortName ( string view )
    getViewLongName ( string view )
    getViewRedirect ( string view )
    
    guiCreateWarningMessage ( string text, int level, table {function1, args... }, table {function2, args...} )
    guiDestroyWarningWindow ( )
]]

function guiSetElementID ( guiElement, id )
    if not isElement ( guiElement ) then
        return false
    end
    
    if type ( id ) ~= "string" then
        return false
    end
    
    if guiID[id] then
        outputDebugString ( "Overwriting guiID "..tostring(id) )
    end
    
    guiID[id] = guiElement
    
    return true
end




function guiGetElementFromID ( id )
    if not guiID[id] then
        outputDebugString ( "Unexisting guiID '"..tostring(id) )
        
        return false
    end
    
    return guiID[id]
end





function guiGetElementParent ( guiElement )
    if guiElements[guiElement] then
        return guiElements[guiElement][1]
    end
    
    return nil
end





function guiGetElementInputType ( guiElement )
    if guiGetElementParent ( guiElement ) ~= "viewItem" then
        return false
    end
    
    if guiElements[guiElement] then
        return guiElements[guiElement][2]
    end
    
    return nil
end





function guiGetElementProperty ( guiElement )
    if guiGetElementParent ( guiElement ) ~= "viewItem" then
        return false
    end
    
    local inputType = guiGetElementInputType ( guiElement )
    if inputType ~= "infolabel" and inputType ~= "config" then
        return false
    end
    
    return guiElements[guiElement][3]
end





function guiGetElementInfo ( guiElement )
    if guiElements[guiElement] then
        return guiElements[guiElement][4]
    end
    
    return nil
end





function guiGetElementEvents ( guiElement )
    if guiElements[guiElement] then
        return guiElements[guiElement][5]
    end
    
    return nil
end





function toggleEditor ( )
    local window = heditGUI.window
    
    if guiGetVisible ( window ) then
        guiToggleUtilityDropDown ( currentUtil )
        
		if heditGUI.prevLockState == false then
			setVehicleLocked(pVehicle, false)
			heditGUI.prevLockState = nil
		end
		
        setVisible ( false )
        return true
    end

    if not pData.access then
        guiCreateWarningMessage ( getText ( "accessDenied" ), 1 )
        return false
    end
    
    if pVehicle then
        
        -- When you abort entering a vehicle, hedit will still think you own a vehicle. Hax for thiz
        -- I need onClientVehicleAbortEnter, NOAW
        if not getPedOccupiedVehicle ( localPlayer ) then
            outputDebugString ( "pVehicle exist, but you do not own a vehicle!" )
            
            pVehicle = false
            guiCreateWarningMessage(getText ( "needVehicle" ), 1)
            return false
        end
        
        
        
        local vehicleController = getVehicleController ( pVehicle )
        
        if vehicleController ~= localPlayer --[[and not setting.allowPassengersToEdit]] then
            guiCreateWarningMessage ( getText ( "restrictedPassenger" ), 1)
            return false
        end
        
        -- Hack to destroy the warning messages from "Youre not in a vehicle" when opening the editor WITH a vehicle
        if isElement ( warningWnd ) and guiGetVisible ( warningWnd ) then
            guiDestroyWarningWindow ( )
        end
        
        -- Show the editor before notifying updates or upgrades.
        setVisible ( true )

		-- Lock the vehicle, if the user has set the setting.
		if getUserConfig("lockVehicleWhenEditing") then
			if not isVehicleLocked(pVehicle) then
				setVehicleLocked(pVehicle, true)
				heditGUI.prevLockState = false
			end
		end

        return true
    end
    
    guiCreateWarningMessage ( getText ( "needVehicle" ), 1 )
    
    return false
end





function setVisible ( bool )
    if type ( bool ) ~= "boolean" then
        outputDebugString("Received invalid boolean", 1)
        return false
    end

    local window = heditGUI.window
    
    -- We shouldnt call all the stuff when the state of the window is already the state we want
    -- Otherwise we will call showCursor again, which will cause major problems with hiding or showing it
    if guiGetVisible ( window ) == bool then
        return false
    end
    
    local bind = unbindKey

    if bool then
        bind = bindKey
        guiSetInputMode ( "no_binds_when_editing" )
    end
    
    for _, key in ipairs{"lctrl", "rctrl", "lshift", "rshift"} do
        bind ( key, "both", showButtonValue )
    end
    --[[bind ( "mouse_wheel_up", "up", onScroll, "up" )
    bind ( "mouse_wheel_down", "up", onScroll, "down" )
    bind ( "delete", "down", tryDelete )]]
    
    guiSetVisible ( window, bool )
    
    if isElement ( warningWnd ) then
        guiSetVisible ( warningWnd, bool )
    end
    
    showCursor ( bool, bool )
    
    return true
end



function setPointedElement ( element, bool ) -- Consider another name!
    if element == pointedButton and buttonValue then
        guiSetText ( pointedButton, buttonValue )
        guiSetProperty ( pointedButton, "HoverTextColour", buttonHoverColor )
        buttonValue = nil
        pressedKey = nil
    end
    
    if bool then
        pointedButton = element
        buttonHoverColor = guiGetProperty ( element, "HoverTextColour" )
        handleKeyState ( "down" )
        return true
    end
    
    pointedButton = nil
    buttonHoverColor = nil
    --handleKeyState ( "up" )
    
    return true
end





function showButtonValue ( key, state )
    local ctrl = (key == "lctrl") or (key == "rctrl")
    local shift = (key == "lshift") or (key == "rshift")

    if not pointedButton then return false end

    if state == "down" then
        if pressedKey ~= "shift" then
            local property = guiGetElementProperty ( pointedButton )
            local new = ctrl and
                getOriginalHandling ( getElementModel ( pVehicle ) )[property] or
                getHandlingPreviousValue ( pVehicle, property )

            if property == "centerOfMass" then
                local hnd = getOriginalHandling ( getElementModel ( pVehicle ) )
                new = math.round ( hnd.centerOfMassX )..", "..math.round ( hnd.centerOfMassY )..", "..math.round ( hnd.centerOfMassZ )
            end

            if ctrl or (shift and new) then
                buttonValue = guiGetText ( pointedButton )
                guiSetText ( pointedButton, valueToString ( property, new ) )
                guiSetProperty ( pointedButton, "HoverTextColour", ctrl and "FF68F000" or "FFF0D400")
                pressedKey = ctrl and "ctrl" or "shift"
            end
        end
        
        return true
    end
    
    if buttonValue then
        guiSetText ( pointedButton, buttonValue )
        guiSetProperty ( pointedButton, "HoverTextColour", buttonHoverColor )
        buttonValue = nil
        pressedKey = nil
        
        handleKeyState ( "down" )
        return true
    end
    
    return true
end



function handleKeyState ( state )
    if getKeyState ( "lctrl" ) or getKeyState ( "rctrl" ) then
        showButtonValue ( "lctrl", state )
    elseif getKeyState ( "lshift" ) or getKeyState ( "rshift" ) then
        showButtonValue ( "lshift", state )
    end
end





function guiSetInfoText ( header, text )
    local infobox = heditGUI.specials.infobox
    
    guiSetText ( infobox.header, header )
    guiSetText ( infobox.text, text )
    
    return true
end





function guiSetStaticInfoText ( header, text )
    local infobox = heditGUI.specials.infobox
    
    guiSetText ( infobox.header, header )
    guiSetText ( infobox.text, text )
    
    staticinfo.header = header
    staticinfo.text = text
    
    return true
end





function guiResetInfoText ( )
    local infobox = heditGUI.specials.infobox
    
    guiSetText ( infobox.header, staticinfo.header )
    guiSetText ( infobox.text, staticinfo.text )
    
    return true
end





function guiResetStaticInfoText ( )
    local infobox = heditGUI.specials.infobox
    
    if guiGetText ( infobox.header ) == staticinfo.header then
        guiSetText ( infobox.header, "" )
        guiSetText ( infobox.text, "" )
    end
    
    staticinfo.header = ""
    staticinfo.text = ""
    
    return true
end




function toggleViewItemsVisibility ( view, bool )
    local function toggleVisibility ( tab )
        if type ( tab ) ~= "table" then
            outputDebugString ( "Error when showing view items from view '"..tostring ( view ).."'" )
        else
            for k,gui in pairs ( tab ) do
                if type ( gui ) == "table" then
                    toggleVisibility ( gui )
                else
                    guiSetVisible ( gui, bool )
					guiSetEnabled(gui, isHandlingPropertyEnabled(guiGetElementProperty(gui)))
                end
            end
        end
    end
    toggleVisibility ( heditGUI.viewItems[view].guiItems )
    
    return true
end





function guiToggleUtilityDropDown ( util )
    if not util then
        for util,tab in pairs ( heditGUI.menuItems ) do
            for i,gui in ipairs ( tab ) do
                guiSetVisible ( gui, false )
            end
        end
        
        currentUtil = nil
        return true
    end
    
    if currentUtil then
        for i,gui in ipairs ( heditGUI.menuItems[currentUtil] ) do
            guiSetVisible ( gui, false )
        end
    end
    
    if util == currentUtil then
        currentUtil = nil
        return false
    end
    
    local show = not guiGetVisible ( heditGUI.menuItems[util][1] )
    
    for i,gui in ipairs ( heditGUI.menuItems[util] ) do
        guiSetVisible ( gui, show )
        guiBringToFront ( gui )
    end
    
    currentUtil = util
    
    return true
end





function guiShowView ( view )
    if view == "previous" then
        guiShowView ( previousView )
        return true
    end

    if view == currentView then
        guiUpdateView ( currentView )
        return false
    end
    
    if not heditGUI.viewItems[view] then
        guiCreateWarningMessage ( getText ( "invalidView" ), 0 )
        return false
    end
    
    if heditGUI.viewItems[view].requireLogin and not pData.loggedin then
        guiCreateWarningMessage ( getText ( "needLogin" ), 1 )
        return false
    end
    
    if heditGUI.viewItems[view].requireAdmin and not pData.isadmin then
        guiCreateWarningMessage ( getText ( "needAdmin" ), 1 )
        return false
    end

    if heditGUI.viewItems[view].disabled then
        guiCreateWarningMessage ( getText ( "disabledView" ), 1 )
        return false
    end
    
    
    
    guiSetText ( heditGUI.specials.menuheader, getViewLongName ( view ) )
    
    destroyEditBox ( )
    
    guiUpdateView ( view )
    
    if currentView then
        if type ( heditGUI.viewItems[currentView].onClose ) == "function" then
            heditGUI.viewItems[currentView].onClose ( heditGUI.viewItems[currentView].guiItems )
        end

        toggleViewItemsVisibility ( currentView, false )
    end
    
    toggleViewItemsVisibility ( view, true )
    
    if type ( heditGUI.viewItems[view].onOpen ) == "function" then
        heditGUI.viewItems[view].onOpen ( heditGUI.viewItems[view].guiItems )
    end

    previousView = currentView
    currentView = view
    
    return true
end
addEvent ( "showView", true )
addEventHandler ( "showView", root, guiShowView )





function guiUpdateView ( View )
    if View then
        local veh = getPedOccupiedVehicle ( localPlayer )
        if not veh or veh ~= pVehicle then
            -- This should never happen
            outputDebugString ( "guiUpdateView is called while your vehicle differs from pVehicle or dont have a vehicle!" )
            return false
        end
        
        
        
        destroyEditBox ( )
        
        local redirect = getViewRedirect ( View )
        
        if redirect == "handlingconfig" then
            
            local content = heditGUI.viewItems[View].guiItems
            local handling = getVehicleHandling ( pVehicle )
            
            for i,gui in ipairs ( content ) do
                local input = guiGetElementInputType ( gui )
                
                if input == "config" then
                
                    local property = guiGetElementProperty ( gui )
                    local config = handling[property]
                    
                    if handlingLimits[property] and handlingLimits[property].options then
                    
                        local id = getHandlingOptionID ( property, string.lower ( config ) )
                        guiComboBoxSetSelected ( gui, id-1 )
                        
                    else
                        
                        local str = valueToString ( property, config )

                        if property == "centerOfMass" then
                            local x,y,z = handling.centerOfMassX,handling.centerOfMassY,handling.centerOfMassZ
                            str = math.round ( x )..", "..math.round ( y )..", "..math.round ( z )
                        end
                        
                        if pressedKey and pointedButton == gui then
                            if pressedKey == "ctrl" then
                                guiSetText ( gui, str )
                                buttonValue = str
                            elseif pressedKey == "shift" then
                                guiSetText ( gui, buttonValue )
                                buttonValue = str
                            end
                        else
                            guiSetText ( gui, str )
                        end
                        
                    end
                
                end
                
            end
        
        
        
        elseif redirect == "handlingflags" then
        
            local content = heditGUI.viewItems[View].guiItems
            local property = guiGetElementProperty ( content[1]["1"] )
            local config = getVehicleHandling ( pVehicle )[property]
            local reversedHex = string.reverse ( config )..string.rep ( "0", 8 - string.len ( config ) )
            local num = 1
            
            
            
            for byte in string.gmatch ( reversedHex, "." ) do
            
                local enabled = getEnabledValuesFromByteValue ( byte )
                local byteEnabled = {}
                
                for i,v in ipairs ( enabled ) do
                    byteEnabled[v] = true
                end
                
                for value,gui in pairs ( content[num] ) do
                    guiCheckBoxSetSelected ( gui, byteEnabled[value] or false )
                end
                
                num = num + 1
                
            end
            
        end
        
        
        
        return false
    end
    
    return false
end
addEvent ( "updateClientView", true )
addEventHandler ( "updateClientView", root, guiUpdateView )





function vehicleTextUpdater ( )
    local vehicleName = getVehicleName ( source )
    local saved = isVehicleSaved ( source )
    local t_vehicle = getText ( "vehicle" )
    local t_unsaved = getText ( "unsaved" )
    
    if saved then
        guiSetText ( heditGUI.specials.vehicleinfo, t_vehicle..": "..vehicleName )
        guiLabelSetColor ( heditGUI.specials.vehicleinfo, 255, 255, 255 )
        return true
    end
    
    guiSetText ( heditGUI.specials.vehicleinfo, t_vehicle..": "..vehicleName.." ("..t_unsaved..")" )
    guiLabelSetColor ( heditGUI.specials.vehicleinfo, 255, 0, 0 )
    return true
end
addEvent ( "updateVehicleText", true )
addEventHandler ( "updateVehicleText", root, vehicleTextUpdater )



function guiTemplateGetViewButtonText ( view )
    return getText ( "viewbuttons", view )
end





function guiTemplateGetItemText ( view, item )
    return getText ( "viewinfo", view, "itemtext", item )
end





function getViewShortName ( view )
    return getText ( "viewinfo", view, "shortname" )
end





function getViewLongName ( view )
    return getText ( "viewinfo", view, "longname" )
end





function getViewRedirect ( view )
    if heditGUI.viewItems and heditGUI.viewItems[view] and heditGUI.viewItems[view].redirect then
        return heditGUI.viewItems[view].redirect
    end
    
    return false
end





function destroyEditBox ( )
    if openedEditBox then
        guiResetStaticInfoText ( )
        guiSetVisible ( hiddenEditBox, true )
        destroyElement ( openedEditBox )
        openedEditBox = nil
    end
end