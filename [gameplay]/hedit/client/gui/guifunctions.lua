function guiCreateElement ( guiType, x, y, w, h, text, alpha, hovercolor )
    local func = {
        -- { function, has_text }
        window = { guiCreateWindow, true },
        button = { guiCreateButton, true },
        editbox = { guiCreateEdit, true },
        line = { guiCreateLabel, true },
        label = { guiCreateLabel, true },
        gridlist = { guiCreateGridList, false },
        button = { guiCreateButton, true },
        checkbox = { guiCreateCheckBox, true },
        radiobutton = { guiCreateRadioButton, true },
        image = { guiCreateStaticImage, true },
        memo = { guiCreateMemo, true },
        combobox = { guiCreateComboBox, true },
        scrollpane = { guiCreateScrollPane, false }
    }
    
    if not func[guiType] then
        outputDebugString ( "Invalid gui type found for some element in template '"..tostring(getUserConfig(localplayer,"template")).."'!" )
        outputDebugString ( "[GUITYPE: "..tostring(guiType).."]" )
        
        return false
    end
    
    
    
    local element = nil
    
    if guiType == "line" then
        text = string.rep ( "_", 100 )
        h = 15
    elseif not func[guiType][2] then
        element = func[guiType][1] ( x, y, w, h, false, heditGUI.window )
    end
    
    if not element then
        if guiType == "window" then
            element = func[guiType][1] ( x, y, w, h, text, false )
        else
            if guiType == "checkbox" then
                element = func[guiType][1] ( x, y, w, h, text, false, false, heditGUI.window )
            else
                element = func[guiType][1] ( x, y, w, h, text, false, heditGUI.window )
            end
        end
    end
    
    if type ( alpha ) == "number" then
        guiSetAlpha ( element, ( ( alpha <= 255 and alpha >= 0 ) and alpha or 255 ) / 255 )
    end
    
    if type ( hovercolor ) == "table" then
        local h = hovercolor
        
        if guiType == "label" then
        
            addEventHandler ( "onClientMouseEnter", element, function ( )
                guiLabelSetColor ( element, h[1], h[2], h[3] )
                guiSetAlpha ( element, h[4] / 255 )
            end, false )
            
            addEventHandler ( "onClientMouseLeave", element, function ( )
                guiLabelSetColor ( element, 255, 255, 255 )
                guiSetAlpha ( element, 1 )
            end, false )
                
        else
        
            guiSetProperty ( element, "HoverTextColour", RGBtoHEX ( h[4], h[1], h[2], h[3] ) )
            
        end
    end
    
    return element
end




function isValidGUI ( tab )
    if type ( tab.type ) ~= "string" then
        return false
    end
    
    if type ( tab.pos ) ~= "table" then
        return false
    end
    
    if type ( tab.pos[1] ) ~= "number" or type ( tab.pos[2] ) ~= "number" then
        return false
    end
    
    if type ( tab.size ) ~= "table" then
        return false
    end
    
    if type ( tab.size[1] ) ~= "number" or type ( tab.size[2] ) ~= "number" then
        return false
    end
    
    return true
end