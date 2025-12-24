addEventHandler ( "onResourceStart", resourceRoot, function ( )

    -- !HIGH PRIORITY!
    -- KEEP THIS IN ORDER TO LET CLIENTS SYNC THEIR SAVED HANDLINGS BETWEEN SERVERS!
    -- BY KEEPING THE DEFAULT RESOURCENAME PLAYERS CAN STORE THEIR HANDLINGS CLIENTSIDE,
    -- SO WHENEVER THEY JOIN ANOTHER SERVER, THEY WILL BE ABLE TO LOAD THEIR OWN HANDLINGS!

    local resName = getResourceName ( resource )

    if resName ~= "hedit" and not DEBUGMODE then
        outputDebugString ( "[HEDIT] Please rename resource '"..resName.."' to 'hedit' to use the handling editor.", 1)
        return cancelEvent ( true, "Rename the handling editor resource to 'hedit' in order to use the resource." )
    end

    if fileExists ( "handling.cfg" ) then
        outputDebugString ( "[HEDIT] Handling.cfg found; type 'loadcfg' to load handling.cfg into the memory.")
    end

	--Parse meta settings
	parseMetaSettings()
	addEventHandler("onSettingChange", root, parseMetaSettings)

	for model=400,611 do
        setElementData ( resourceRoot, "hedit:originalHandling."..tostring ( model ), getOriginalHandling ( model, true ), true, "deny" )
    end

    --initiateCFGLoader ( )
    loadHandlingLog ( )

    return true
end )


addEventHandler ( "onResourceStop", resourceRoot, function ( )
    unloadHandlingLog ( )
    return true
end )


local function account_update()
    local admin = isObjectInACLGroup ( "user."..getAccountName ( getPlayerAccount ( source ) ), aclGetGroup ( "Admin" ) )
    local canAccess = hasObjectPermissionTo(source, "resource.hedit.access", true)
    triggerClientEvent ( source, "updateClientRights", source, not isGuestAccount(getPlayerAccount(source)), admin, canAccess)
end

addEventHandler("onPlayerLogin", root, account_update)
addEventHandler("onPlayerLogout", root, account_update)
