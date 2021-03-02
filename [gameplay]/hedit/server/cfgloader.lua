function initiateCFGLoader ( )
end





function loadCFGIntoMemory ( cfgstr )
    local function isValidChar ( char )
        local num = string.byte ( char )
        
        if ( num == 9 ) or ( num == 32 ) or ( num >= 48 and num <= 57 ) or ( num >= 65 and num <= 90 ) or ( num >= 97 and num <= 122 ) then
            return true
        end
        
        return false
    end
    
    
    
    local lines = {}
    local ignore = false
    local waitForLine = false
    
    for token in string.gmatch ( cfgstr, "." ) do
        
        if not isValidChar ( token ) then
        
            ignore = true
            waitForLine = false
            
            if addingEntry then
                print ( "[HEDIT] Error while adding line #"..tostring(#lines)..", invalid character found: "..token )
                table.remove ( lines, #lines )
                addingEntry = false
            end
            
        elseif token == "\r" or token == "\n" then
        
            waitForLine = true
            
        else
            
            if waitForLine then
            
                waitForLine = false
                ignore      = false
                
                if addingEntry then
                    table.insert ( lines, "" )
                    addingEntry = false
                end
                
            end
            
            
            
            if not ignore and not waitForLine then
            
                lines[#lines] = lines[#lines]..token
                addingEntry = true
                
            end
            
        end
        
    end
    
    
    
    if #lines > 0 then
        print ( "[HEDIT] Loaded "..tostring(#lines).." handling entries from "..tostring(string.len(cfgstr)).." bytes into the memory." )
        print ( "[HEDIT] Type 'exportcfg' to import the handling entries into defaults.xml." )
        print ( "[HEDIT] This may take some time." )
        
        addCommandHandler ( "exportcfg", function ( player )
            
            if getElementType ( player ) ~= "console" then
                return false
            end
            
            print ( "[HEDIT] Importing "..line.." handling entries into defaults.xml." )
            print ( "[HEDIT] This may take a while. Please wait." )
            
            setTimer ( function ( )
                exportToDefaults ( lines )
                removeCommandHandler ( "exportcfg" )
            end, 100, 1 )
        end )
        
        return true
    end
    
    print ( "[HEDIT] No handling entries found in "..tostring(string.len(cfgstr)).." bytes!")
    print ( "[HEDIT] Make sure handling.cfg is correct and try again." )
    
    return true
end





function exportToDefaults ( linetabs )
    if type ( linetabs ) ~= "table" then
        error ( "Not a table at 'exportToDefaults'!", 2 )
        return false
    end
    
    
    
    local xml = xmlLoadFile ( "handling.xml" )
    if not xml then
        xml = xmlCreateFile ( "handling.xml" )
    end
    
    for num,line in ipairs ( linetabs ) do
        
        local id = 1
        local vehicleNode = nil
        
        for value in string.gmatch ( line, "[^%s]+" ) do
            
            if id == 1 then
                if not tonumber ( value ) then
                    print ( "[HEDIT] Handling line #"..tostring(num).." is invalid, can't import!" )
                    break
                end
                
                local models = getVehicleModelsByIdentifier ( value )
                
            else
                
                
                
            end
            
            local property = getHandlingPropertyFromID ( id )
            
            
            id = id + 1
        end
    
    end
    
    
    xmlSaveFile ( xml )
    xmlUnloadFile ( xml )

    return true
end




function loadDefaults ( )
end





addCommandHandler ( "loadcfg", function ( player )
    if getElementType ( player ) ~= "console" then
        return false
    end
    
    if fileExists ( "handling.cfg" ) then
        local cfgFile = fileExists ( "handling.cfg" )
        local str = ""
        
        while not fileIsEOF ( cfgFile ) do
            str = str..fileRead ( cfgFile, 500 )
        end
        
        fileClose ( cfgFile )
        
        print ( "[HEDIT] handling.cfg has been read." )
        print ( "[HEDIT] Please wait while loading the lines into the memory." )
        
        setTimer ( function ( )
            loadCFGIntoMemory ( str )
        end, 100, 1 )
        
        return true
    end
    
    print ( "[HEDIT] No handling.cfg found. Make sure it's in the root of this resource." )
    return false
end )