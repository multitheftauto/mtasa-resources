local function toggleEvents ( window, bool )
    local func = removeEventHandler
    if bool then
        func = addEventHandler
    end
    
    func("onClientClick", root, onClick)
    func("onClientCursorMove", root, onMove)
    func("onClientRender", root, onRender)

    local actions = {
        onClientGUIDoubleClick = onDoubleClick,
        onClientMouseEnter = onEnter,
        onClientMouseLeave = onLeave,
        onClientGUIFocus = onFocus,
        onClientGUIBlur = onBlur,
        onClientGUIAccepted = onEditBoxAccept,
        onClientGUIComboBoxAccepted = onComboBoxAccept
    }
    for event, fn in pairs(actions) do
        func(event, window, fn)
    end
    
    return true
end


function startBuilding ( )
    outputDebugString ( "Building the gui.." )
    
    if heditGUI.window then
        destroyGUI ( )
    end

    local window = buildMainWindow()
    buildMenubar()
    buildViewButtons()
    buildViews()
    buildSpecials()
    
    guiSetVisible ( window, false )
    
    toggleEvents ( window, true )
    
    forceVehicleChange ( )
    
    bindKey ( getUserConfig ( "usedKey" ), "down", toggleEditor )
    addCommandHandler ( getUserConfig ( "usedCommand" ), toggleEditor )
    
    return true
end



function destroyGUI ( )
    toggleEvents ( heditGUI.window, false )
    
    if heditGUI.window then
        destroyElement ( heditGUI.window )
    end
    
    unbindKey ( "lctrl", "both", showOriginalValue )
    unbindKey ( "rctrl", "both", showOriginalValue )
    unbindKey ( "lshift", "both", showPreviousValue )
    unbindKey ( "rshift", "both", showPreviousValue )
    
    guiElements = {}
    heditGUI = resetGUI
end





function buildMainWindow()
    local wnd = template.window
    heditGUI.window = guiCreateElement ( wnd.type, wnd.pos[1], wnd.pos[2], wnd.size[1], wnd.size[2], getText ( "windowHeader" ), wnd.alpha, wnd.hovercolor )
    
    if wnd.centered then
        guiSetPosition ( heditGUI.window, (scrX/2)-(wnd.size[1]/2), (scrY/2)-(wnd.size[2]/2), false )
    end
    
    guiWindowSetSizable ( heditGUI.window, wnd.sizable or false )
    guiWindowSetMovable ( heditGUI.window, wnd.movable or false )
    
    guiElements[heditGUI.window] = { "window", "window", "none", 1, wnd.events }
    
    for layer,gui in ipairs(wnd) do
        local element = guiCreateElement ( gui.type, gui.pos[1], gui.pos[2], gui.size and gui.size[1] or gui.width, gui.size and gui.size[2] or gui.width, "", gui.alpha, gui.hovercolor )
        guiSetEnabled ( element, false )
        
        table.insert ( heditGUI.background, element )
        guiElements[element] = { "window", "background", "none", layer, gui.events }
    end
    
    return heditGUI.window
end





function buildMenubar()
    local offset = 65
    local size = {60, 19}
    local pos = {10-offset, 22}
    for k,menu in ipairs ( template.menubar ) do
        pos[1] = pos[1] + offset
        local element = guiCreateElement("button", pos[1], pos[2], size[1], size[2], getText("menubar", menu.title), 255, template.menubar.hovercolor)
        
        guiElements[element] = { "menuButton", "button", "none", menu.title, nil}
        table.insert ( heditGUI.menuButtons, element )

        local buttons = {}
        
        if menu[1] then
            local longestName = 100
            
            for item,list in ipairs(menu) do
            
                local posY = ( pos[2] + 7 ) + ( 20 * item )
                local menuButton = guiCreateElement ( "button", pos[1], posY, 100, 20, getViewShortName ( list ) )
                
                local textextent = guiCreateElement ( "label", pos[1], posY, 100, 20, getViewShortName ( list ) )
                local extent = guiLabelGetTextExtent ( textextent )
                
                if extent > longestName then
                    longestName = extent
                end
                
                destroyElement ( textextent )
                
                guiSetVisible ( menuButton, false )
                
                guiElements[menuButton] = { "menuItem", "button", "none", list, nil }
                table.insert ( buttons, menuButton )
                
            end
            
            for i,v in ipairs ( buttons ) do
                guiSetSize ( v, longestName + 10, 20, false )
            end
        end
        
        heditGUI.menuItems[menu.title] = buttons
    end
end



function buildViewButtons()
    local offset = 55
    local size = {50, 50}
    local pos = {10, 54-offset}

    for k,view in ipairs ( template.views ) do
        pos[2] = pos[2] + offset

        local subContents = view.contents
        if subContents then

            local width = size[1] / #subContents
            for _, title in ipairs(subContents) do
                local element = guiCreateElement ("button", pos[1]+(width*_)-width, pos[2], width, size[2], guiTemplateGetViewButtonText ( title ), alpha, template.views.hovercolor )
                
                guiElements[element] = { "viewButton", "button", "none", title }
                table.insert ( heditGUI.viewButtons, element )
            end

        else
            local element = guiCreateElement ("button", pos[1], pos[2], size[1], size[2], guiTemplateGetViewButtonText ( view.title ), alpha, template.views.hovercolor )
            
            guiElements[element] = { "viewButton", "button", "none", view.title }
            table.insert ( heditGUI.viewButtons, element )
        end
    end
end



-- these are for views

function buildViews()
    local function scanSpecialView ( menu, itemName, gui )
        local res = {}
        for k,v in pairs ( gui ) do
            if type ( v ) == "table" then
                if not v.type then
                    res[k] = scanSpecialView ( menu, k, v )
                else
                    local text = guiTemplateGetItemText ( menu, k )
                    
                    local element = guiCreateElement ( v.type, v.pos[1], v.pos[2], v.size[1], v.size[2], text, v.alpha, v.hovercolor )
                    
                    if type ( v.runfunction ) == "function" then
                        v.runfunction ( element )
                    end
                    
                    res[k] = element
                    guiElements[element] = { "viewItem", "special", "none", k, v.events }
                end
            end
        end
        
        return res
    end
    
    for menu,v in pairs ( template.viewcontents ) do
        if v.redirect ~= "THIS_IS_ONE" then
            local items = {}
            
            
            
            if v.redirect == "handlingconfig" then
                -------------------------
                -- HANDLINGCONFIG MENU
                -------------------------
                
                local guiInfo = template.viewcontents.redirect_handlingconfig.content
                
                for i,property in ipairs ( v.content ) do
                    
                    if isHandlingPropertyValid ( property ) then
                    
                        local propertyName = getHandlingPropertyFriendlyName ( property )
                        local propertyName = getHandlingPropertyFriendlyName ( property )
                        local labelInfo = guiInfo.labels[i]
                        local label = guiCreateElement ( labelInfo.type, labelInfo.pos[1], labelInfo.pos[2], labelInfo.size[1], labelInfo.size[2], propertyName, labelInfo.alpha, labelInfo.hovercolor )
                        
                        local configInfo = guiInfo.buttons[i]
                        
                        if property == "centerOfMass" then
                        
                            local labelPosX = guiGetPosition ( label, false )
                            local labelWidth = guiLabelGetTextExtent ( label )
                            
                            guiSetSize ( label, labelWidth + 5, labelInfo.size[2], false )
                            
                            local labelX = guiCreateElement ( labelInfo.type, labelPosX + labelWidth + 20, labelInfo.pos[2], 15, 20, "X", labelInfo.alpha, labelInfo.hovercolor )
                            local labelY = guiCreateElement ( labelInfo.type, labelPosX + labelWidth + 35, labelInfo.pos[2], 15, 20, "Y", labelInfo.alpha, labelInfo.hovercolor )
                            local labelZ = guiCreateElement ( labelInfo.type, labelPosX + labelWidth + 50, labelInfo.pos[2], 15, 20, "Z", labelInfo.alpha, labelInfo.hovercolor )
                            
                            table.insert ( items, labelX )
                            table.insert ( items, labelY )
                            table.insert ( items, labelZ )
                            
                            guiElements[labelX] = { "viewItem", "infolabel", "centerOfMassX", i, labelInfo.events }
                            guiElements[labelY] = { "viewItem", "infolabel", "centerOfMassY", i, labelInfo.events }
                            guiElements[labelZ] = { "viewItem", "infolabel", "centerOfMassZ", i, labelInfo.events }
                        
                            local buttonPosX = configInfo.pos[1]
                            local buttonWidth = math.round ( configInfo.size[1] / 3, 0 )
                            
                            local buttonX = guiCreateElement ( "button", buttonPosX,                       configInfo.pos[2], buttonWidth, configInfo.size[2], "", configInfo.alpha, configInfo.hovercolor )
                            local buttonY = guiCreateElement ( "button", buttonPosX + buttonWidth,         configInfo.pos[2], buttonWidth, configInfo.size[2], "", configInfo.alpha, configInfo.hovercolor )
                            local buttonZ = guiCreateElement ( "button", buttonPosX + ( buttonWidth * 2 ), configInfo.pos[2], buttonWidth, configInfo.size[2], "", configInfo.alpha, configInfo.hovercolor )
                            
                            guiSetFont ( buttonX, "default-small" )
                            guiSetFont ( buttonY, "default-small" )
                            guiSetFont ( buttonZ, "default-small" )
                            
                            table.insert ( items, buttonX )
                            table.insert ( items, buttonY )
                            table.insert ( items, buttonZ )
                            
                            guiElements[buttonX] = { "viewItem", "config", "centerOfMassX", i, configInfo.events }
                            guiElements[buttonY] = { "viewItem", "config", "centerOfMassY", i, configInfo.events }
                            guiElements[buttonZ] = { "viewItem", "config", "centerOfMassZ", i, configInfo.events }
                            
                        else
                        
                            -- If a table, return table. Otherwise, false.
                            local propertyOptions = type ( handlingLimits[property].options ) == "table" and handlingLimits[property].options or false
                            
                            -- If propertyOptions is not false, return the combobox as type. Otherwise a button.
                            local buttonType = propertyOptions and "combobox" or "button"
                            
                            --If propertyOptions is not false, return a size needed for the height. Otherwise, the normal button size.
                            local buttonHeight = propertyOptions and ( #propertyOptions * 20 ) + 20 or configInfo.size[2]
                            
                            -- Create it with no text
                            local button = guiCreateElement ( buttonType, configInfo.pos[1], configInfo.pos[2], configInfo.size[1], buttonHeight, "", configInfo.alpha, configInfo.hovercolor )
                            
                            
                            
                            -- If we had a combobox with options
                            if propertyOptions then
                                for num,option in ipairs ( propertyOptions ) do
                                    guiComboBoxAddItem ( button, getHandlingPropertyOptionName ( property, option ) )
                                end
                            end
                            
                            table.insert ( items, button )
                            guiElements[button] = { "viewItem", "config", property, i, configInfo.events }
                            
                        end
                        
                        table.insert ( items, label )
                        guiElements[label] = { "viewItem", "infolabel", property, i, labelInfo.events }
                        
                    else
                        outputDebugString ( "Invalid property used for handling menu "..menu..": "..tostring(property) )
                    end
                end
                 
                
            elseif v.redirect == "handlingflags" then
                -------------------------
                -- HANDLINGFLAG MENU
                -------------------------
                
                local property = v.content[1]
                
                if isHandlingPropertyHexadecimal ( property ) then
                    
                    local guiInfo = template.viewcontents.redirect_handlingflags.content
                    
                    -- Make sure we have extras as it's optional
                    if type ( guiInfo.extras ) == "table" then
                        items.extra = {}
                        for i,gui in ipairs ( guiInfo.extras ) do
                            local element = guiCreateElement ( gui.type, gui.pos[1], gui.pos[2], gui.size[1], gui.size[2], tostring(gui.text), gui.alpha, gui.hovercolor )
                            
                            table.insert ( items.extra, element )
                            guiElements[element] = { "viewItem", "extra", property, i, gui.events }
                        end
                    end
                    
                    for byte,tab in ipairs ( guiInfo.checkboxes ) do
                        items[byte] = {}
                        for value,gui in pairs ( tab ) do
                            local byteName = getHandlingPropertyByteName ( property, byte, value )
                            local element = guiCreateElement ( gui.type, gui.pos[1], gui.pos[2], gui.size[1], gui.size[2], byteName, gui.alpha, gui.hovercolor )
                            
                            items[byte][value] = element
                            guiElements[element] = { "viewItem", "infolabel", property, { byte=byte, value=value }, gui.events }
                        end
                    end
                
                else
                
                    outputDebugString ( "Menu "..menu.." does not have a valid handling/model-flag property!" )
                    outputDebugString ( "Please change the first parameter of this menu to \"modelFlags\" or \"handlingFlags\"!" )
                    
                end
                
                
            else
                -------------------------
                -- SPECIAL MENU
                -------------------------
                
                items = scanSpecialView ( menu, "", v.content )
                
                if type ( v.runfunction ) == "function" then
                    v.runfunction ( items )
                end
                
            end
            
            
            
            heditGUI.viewItems[menu] = {
                redirect = v.redirect,
                requireLogin = v.requirelogin,
                requireAdmin = v.requireadmin,
                disabled = v.disable,
                onOpen = v.onOpen,
                onClose = v.onClose,
                guiItems = items
            }
            
            toggleViewItemsVisibility ( menu, false )
        end
    end
end





function buildSpecials()
    local function create ( gui, parent )
        local element = guiCreateElement ( gui.type, gui.pos[1], gui.pos[2], gui.size[1], gui.size[2], "", gui.alpha, gui.hovercolor )
        
        if type ( gui.runfunction ) == "function" then
            gui.runfunction ( element )
        end
        
        return element
    end
    
    
    
    for parent,v in pairs ( template.specials ) do
        
        local items = {}
        
        if not isValidGUI ( v ) then
            
            for sub,item in pairs ( v ) do
                
                if not isValidGUI ( item ) then -- MiniLog only! We won't go deeper!
                
                    items[sub] = {}
                
                    for logsub,logitem in pairs ( item ) do
                        
                        if isValidGUI ( logitem ) then
                            items[sub][logsub] = create ( logitem, parent )
                            guiElements[ items[sub][logsub] ] = { "special", "special", "none", parent, logitem.events }
                        end
                        
                    end
                    
                else
                
                    items[sub] = create ( item, parent )
                    guiElements[ items[sub] ] = { "special", "special", "none", parent, v.events }
                    
                end
                
            end
            
        else
            
            items = create ( v, parent )
            guiElements[items] = { "special", "special", "none", parent, v.events }
            
        end
        
        heditGUI.specials[parent] = items
    end
end