--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_server.lua
*
*	Original File by lil_Toady
*
**************************************]]

_types = { "player", "team", "vehicle", "resource", "bans", "server", "admin" }
_settings = nil

aPlayers = {}
aLogMessages = {}
aInteriors = {}
aStats = {}
aReports = {}
aWeathers = {}

local aUnmuteTimerList = {}
local chatHistory = {}

function notifyPlayerLoggedIn(player)
	outputChatBox ( "Press 'p' to open your admin panel", player )
	local unread = 0
	for _, msg in ipairs ( aReports ) do
		unread = unread + ( msg.read and 0 or 1 )
	end
	if unread > 0 then
		outputChatBox( unread .. " unread Admin message" .. ( unread==1 and "" or "s" ), player, 255, 0, 0 )
	end
end

function aHandleIP2CUpdate()
    local playersToUpdate = false
    local playersTable = getElementsByType("player") -- cache result, save function call

    for playerID = 1, #playersTable do
        local playerElement = playersTable[playerID]

        if not playersToUpdate then
            playersToUpdate = {} -- create table only when there are at least one player
        end

        updatePlayerCountry(playerElement)
        playersToUpdate[#playersToUpdate + 1] = playerElement
    end

    if not playersToUpdate then
        return -- if there are no players, stop further code execution
    end

    for playerID = 1, #playersTable do
        local playerElement = playersTable[playerID]
        local hasAdminPermission = hasObjectPermissionTo(playerElement, "general.adminpanel")

        if hasAdminPermission then
            
            for playerToUpdateID = 1, #playersToUpdate do
                local playerToUpdate = playersToUpdate[playerToUpdateID]

                triggerClientEvent(playerElement, "aClientPlayerJoin", playerToUpdate,
					false, false, false, false,
					aPlayers[playerToUpdate]["country"]
				)
            end
        end
    end
end

function aHandleIp2cSetting()
	local enabled = get("*useip2c")
	if enabled and enabled == "true" then
		local ip2c = getResourceFromName("ip2c")
		if ip2c and getResourceState(ip2c) == "loaded" then
            -- Persistent
			startResource(ip2c, true)
		end
	elseif (not enabled) or (enabled == "false") then
		local ip2c = getResourceFromName("ip2c")
		if ip2c and getResourceState(ip2c) == "running" then
			stopResource(ip2c)
		end
	end
end

addEventHandler ( "onResourceStart", root, function ( resource )
	if ( resource ~= getThisResource() ) then
		local resourceName = getResourceName(resource)
		for id, player in ipairs(getElementsByType("player")) do
			if ( hasObjectPermissionTo ( player, "general.tab_resources" ) ) then
				triggerClientEvent ( player, "aClientResourceStart", root, resourceName )
			end
		end
		if resourceName == "ip2c" then
			aHandleIP2CUpdate()
		end
		return
	end
	_settings = xmlLoadFile ( "conf\\settings.xml" )
	if ( not _settings ) then
		_settings = xmlCreateFile ( "conf\\settings.xml", "main" )
		xmlSaveFile ( _settings )
	end
	aSetupACL()
	aSetupCommands()
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		aPlayerInitialize ( player )
		if ( hasObjectPermissionTo ( player, "general.adminpanel" ) ) then
			notifyPlayerLoggedIn(player)
		end
	end
	aHandleIp2cSetting()
	local node = xmlLoadFile ( "conf\\interiors.xml" )
	if ( node ) then
		local interiors = 0
		while ( xmlFindChild ( node, "interior", interiors ) ) do
			local interior = xmlFindChild ( node, "interior", interiors )
			interiors = interiors + 1
			aInteriors[interiors] = {}
			aInteriors[interiors]["world"] = tonumber ( xmlNodeGetAttribute ( interior, "world" ) )
			aInteriors[interiors]["id"] = xmlNodeGetAttribute ( interior, "id" )
			aInteriors[interiors]["x"] = xmlNodeGetAttribute ( interior, "posX" )
			aInteriors[interiors]["y"] = xmlNodeGetAttribute ( interior, "posY" )
			aInteriors[interiors]["z"] = xmlNodeGetAttribute ( interior, "posZ" )
			aInteriors[interiors]["r"] = xmlNodeGetAttribute ( interior, "rot" )
		end
		xmlUnloadFile ( node )
	end
	local node2 = xmlLoadFile ( "conf\\stats.xml" )
	if ( node2 ) then
		local stats = 0
		while ( xmlFindChild ( node2, "stat", stats ) ) do
			local stat = xmlFindChild ( node2, "stat", stats )
			local id = tonumber ( xmlNodeGetAttribute ( stat, "id" ) )
			local name = xmlNodeGetAttribute ( stat, "name" )
			aStats[id] = name
			stats = stats + 1
		end
		xmlUnloadFile ( node2 )
	end
	local node3 = xmlLoadFile ( "conf\\weathers.xml" )
	if ( node3 ) then
		local weathers = 0
		while ( xmlFindChild ( node3, "weather", weathers ) ~= false ) do
		local weather = xmlFindChild ( node3, "weather", weathers )
			local id = tonumber ( xmlNodeGetAttribute ( weather, "id" ) )
			local name = xmlNodeGetAttribute ( weather, "name" )
			aWeathers[id] = name
			weathers = weathers + 1
		end
		xmlUnloadFile ( node3 )
	end
	local node4 = xmlLoadFile ( "conf\\reports.xml" )
	if ( node4 ) then
		local messages = 0
		while ( xmlFindChild ( node4, "message", messages ) ) do
			subnode = xmlFindChild ( node4, "message", messages )
			local author = xmlFindChild ( subnode, "author", 0 )
			local subject = xmlFindChild ( subnode, "subject", 0 )
			local category = xmlFindChild ( subnode, "category", 0 )
			local text = xmlFindChild ( subnode, "text", 0 )
			local time = xmlFindChild ( subnode, "time", 0 )
			local read = ( xmlFindChild ( subnode, "read", 0 ) ~= false )
			local suspect = xmlFindChild ( subnode, "suspect", 0 )
			local id = #aReports + 1
			aReports[id] = {}
			if ( author ) then aReports[id].author = xmlNodeGetValue ( author )
			else aReports[id].author = "" end
			if ( category ) then aReports[id].category = xmlNodeGetValue ( category )
			else aReports[id].category = "" end
			if ( subject ) then aReports[id].subject = xmlNodeGetValue ( subject )
			else aReports[id].subject = "" end
			if ( text ) then aReports[id].text = xmlNodeGetValue ( text )
			else aReports[id].text = "" end
			if ( time ) then aReports[id].time = xmlNodeGetValue ( time )
			else aReports[id].time = "" end
			if ( suspect ) then
				aReports[id].suspect = {
					name = xmlNodeGetAttribute ( suspect, "name" ),
					username = xmlNodeGetAttribute ( suspect, "username" ),
					ip = xmlNodeGetAttribute ( suspect, "ip" ),
					serial = xmlNodeGetAttribute ( suspect, "serial" ),
					version = xmlNodeGetAttribute ( suspect, "version" ),
					chatLog = xmlNodeGetValue ( suspect )
				}
			else aReports[id].suspect = false end
			aReports[id].read = read
			messages = messages + 1
		end
		-- Remove duplicates
		local a = 1
		while a <= #aReports do
			local b = a + 1
			while b <= #aReports do
				if table.cmp( aReports[a], aReports[b] ) then
					table.remove( aReports, b )
					b = b - 1
				end
				b = b + 1
			end
			a = a + 1
		end
		-- Upgrade time from '4/9 5:9' to '2009-09-04 05:09'
		for id, rep in ipairs ( aReports ) do
			if string.find( rep.time, "/" ) then
				local monthday, month, hour, minute = string.match( rep.time, "^(.-)/(.-) (.-):(.-)$" )
				rep.time = string.format( '%04d-%02d-%02d %02d:%02d', 2009, month + 1, monthday, hour, minute )
			end
		end
		-- Sort messages by time
		table.sort(aReports, function(b, c) return(b.time < c.time) end)
		-- Limit number of messages
		while #aReports > g_Prefs.maxmsgs do
			table.remove( aReports, 1 )
		end
		xmlUnloadFile ( node4 )
	end

	local node5 = xmlLoadFile ( "conf\\messages.xml" )
	if ( node5 ) then
		for id, type in ipairs ( _types ) do
			local subnode = xmlFindChild ( node5, type, 0 )
			if ( subnode ) then
				aLogMessages[type] = {}
				local groups = 0
				while ( xmlFindChild ( subnode, "group", groups ) ) do
					local group = xmlFindChild ( subnode, "group", groups )
					local action = xmlNodeGetAttribute ( group, "action" )
					local r = tonumber ( xmlNodeGetAttribute ( group, "r" ) )
					local g = tonumber ( xmlNodeGetAttribute ( group, "g" ) )
					local b = tonumber ( xmlNodeGetAttribute ( group, "b" ) )
					aLogMessages[type][action] = {}
					aLogMessages[type][action]["r"] = r or 0
					aLogMessages[type][action]["g"] = g or 255
					aLogMessages[type][action]["b"] = b or 0
					if ( xmlFindChild ( group, "all", 0 ) ) then aLogMessages[type][action]["all"] = xmlNodeGetValue ( xmlFindChild ( group, "all", 0 ) ) end
					if ( xmlFindChild ( group, "admin", 0 ) ) then aLogMessages[type][action]["admin"] = xmlNodeGetValue ( xmlFindChild ( group, "admin", 0 ) ) end
					if ( xmlFindChild ( group, "player", 0 ) ) then aLogMessages[type][action]["player"] = xmlNodeGetValue ( xmlFindChild ( group, "player", 0 ) ) end
					if ( xmlFindChild ( group, "log", 0 ) ) then aLogMessages[type][action]["log"] = xmlNodeGetValue ( xmlFindChild ( group, "log", 0 ) ) end
					groups = groups + 1
				end
			end
		end
		xmlUnloadFile ( node5 )
	end
end )

addEventHandler ( "onResourceStop", root, function ( resource )
	-- Incase the resource being stopped has been deleted
	local stillExists = false
	for i, res in ipairs(getResources()) do
		if res == resource then
			stillExists = true
			break
		end
	end
	if not stillExists then return end

	if ( resource ~= getThisResource() ) then
		local resourceName = getResourceName(resource)
		for id, player in ipairs(getElementsByType("player")) do
			if ( hasObjectPermissionTo ( player, "general.tab_resources" ) ) then
				triggerClientEvent ( player, "aClientResourceStop", root, resourceName )
			end
		end
		if resourceName == "ip2c" then
			aHandleIP2CUpdate()
		end
	else
		local node = xmlLoadFile ( "conf\\reports.xml" )
		if ( node ) then
			while ( xmlFindChild ( node, "message", 0 ) ~= false ) do
				local subnode = xmlFindChild ( node, "message", 0 )
				xmlDestroyNode ( subnode )
			end
		else
			node = xmlCreateFile ( "conf\\reports.xml", "messages" )
		end
		for id, message in ipairs ( aReports ) do
			local subnode = xmlCreateChild ( node, "message" )
			for key, value in pairs ( message ) do
				if ( value ) then
					if ( type ( value ) == "table" ) then
						local child = xmlCreateChild ( subnode, key )
						xmlNodeSetValue ( child, tostring ( value.chatLog ) )
						xmlNodeSetAttribute ( child, "name", value.name )
						xmlNodeSetAttribute ( child, "username", value.username )
						xmlNodeSetAttribute ( child, "ip", value.ip )
						xmlNodeSetAttribute ( child, "serial", value.serial )
						xmlNodeSetAttribute ( child, "version", value.version )
					else
						xmlNodeSetValue ( xmlCreateChild ( subnode, key ), tostring ( value ) )
					end
				end
			end
		end
		xmlSaveFile ( node )
		xmlUnloadFile ( node )

		-- Unmute anybody muted by admin
		for i, player in ipairs(getElementsByType("player")) do
			local serial = getPlayerSerial( player )
			if (aUnmuteTimerList[serial]) then
				aUnmuteTimerList[serial] = nil
				setPlayerMuted(player, false)
			end
		end
	end
	aclSave ()
end )

function aGetSetting ( setting )
	local result = xmlFindChild ( _settings, tostring ( setting ), 0 )
	if ( result ) then
		result = xmlNodeGetValue ( result )
		if ( result == "true" ) then return true
		elseif ( result == "false" ) then return false
		else return result end
	end
	return false
end

function aSetSetting ( setting, value )
	local node = xmlFindChild ( _settings, tostring ( setting ), 0 )
	if ( not node ) then
		node = xmlCreateChild ( _settings, tostring ( setting ) )
	end
	xmlNodeSetValue ( node, tostring ( value ) )
	xmlSaveFile ( _settings )
end

function aRemoveSetting ( setting )
	local node = xmlFindChild ( _settings, tostring ( setting ), 0 )
	if ( node ) then
		xmlDestroyNode ( node )
	end
	xmlSaveFile ( _settings )
end

function iif ( cond, arg1, arg2 )
	if ( cond ) then
		return arg1
	end
	return arg2
end

local serialExp = "^" .. string.rep ( "[A-F0-9]", 32 ) .. "$"
function isValidSerial ( serial )
	return serial:match ( serialExp )
end

function getWeatherNameFromID ( weather )
	return iif ( aWeathers[weather], aWeathers[weather], "Unknown" )
end

function getPlayerAccountName( player )
	local account = getPlayerAccount ( player )
	return account and getAccountName ( account )
end

function aSetPlayerMuted ( player, state, length )
	if ( setPlayerMuted ( player, state ) ) then
		if not state then
			aRemoveUnmuteTimer( player )
		elseif state and length and length > 0 then
			aAddUnmuteTimer( player, length )
		end
		return true
	end
	return false
end

addEventHandler ( "onPlayerJoin", root, function ()
	local player = source
	if aHasUnmuteTimer( player ) then
		if not isPlayerMuted(player) then
			triggerEvent ( "aPlayer", getElementByIndex("console", 0), player, "mute" )
		end
	end
end )

-- Allows for timed mutes across reconnects
function aAddUnmuteTimer( player, length )
	aRemoveUnmuteTimer( player )
	local serial = getPlayerSerial( player )
	aUnmuteTimerList[serial] = setTimer(
								function()
									aUnmuteTimerList[serial] = nil
									for _,plr in ipairs(getElementsByType('player')) do
										if getPlayerSerial(plr) == serial then
											if isPlayerMuted(plr) then
												triggerEvent ( "aPlayer", getElementByIndex("console", 0), plr, "mute" )
											end
										end
									end
								end,
								length*1000, 1 )
end

function aRemoveUnmuteTimer( player )
	local serial = getPlayerSerial( player )
	if aUnmuteTimerList[serial] then
		killTimer( aUnmuteTimerList[serial] )
		aUnmuteTimerList[serial] = nil
	end
end

function aHasUnmuteTimer( player )
	local serial = getPlayerSerial( player )
	if aUnmuteTimerList[serial] then
		return true
	end
end


addEvent ( "onPlayerFreeze", false )
function aSetPlayerFrozen ( player, state )
	if ( toggleAllControls ( player, not state, true, false ) ) then
		aPlayers[player]["freeze"] = state
		triggerEvent ( "onPlayerFreeze", player, state )
		local vehicle = getPedOccupiedVehicle( player )
		if vehicle then
			setElementFrozen ( vehicle, state )
		end
		return true
	end
	return false
end

function isPlayerFrozen ( player )
	if ( aPlayers[player]["freeze"] == nil ) then aPlayers[player]["freeze"] = false end
	return aPlayers[player]["freeze"]
end

addEventHandler ( "onPlayerJoin", root, function ()
	if ( aGetSetting ( "welcome" ) ) then
		outputChatBox ( aGetSetting ( "welcome" ), source, 255, 100, 100 )
	end
	aPlayerInitialize ( source )
	for id, player in ipairs(getElementsByType("player")) do
		if ( hasObjectPermissionTo ( player, "general.adminpanel" ) ) then
			triggerClientEvent ( player, "aClientPlayerJoin", source, getPlayerIP ( source ), getPlayerAccountName ( source ), getPlayerSerial ( source ), hasObjectPermissionTo ( source, "general.adminpanel" ), aPlayers[source]["country"] )
		end
	end
	setPedGravity ( source, getGravity() )
end )

function updatePlayerCountry ( player )
	local isIP2CResourceRunning = getResourceFromName( "ip2c" )
	isIP2CResourceRunning = isIP2CResourceRunning and getResourceState( isIP2CResourceRunning ) == "running"
	aPlayers[player]["country"] = isIP2CResourceRunning and exports.ip2c:getPlayerCountry ( player ) or false
end

function aPlayerInitialize ( player )
	bindKey ( player, "p", "down", "admin" )
	--callRemote ( "http://community.mtasa.com/mta/verify.php", aPlayerSerialCheck, player, getPlayerSerial ( player ) )
	aPlayers[player] = {}
	aPlayers[player]["money"] = getPlayerMoney ( player )
	updatePlayerCountry ( player )
	chatHistory[player] = {}
end

addEventHandler ( "onPlayerQuit", root, function ()
	aPlayers[source] = nil
	chatHistory[source] = nil
end )

addEvent ( "aPlayerVersion", true )
addEventHandler ( "aPlayerVersion", root, function ( version )
	if checkClient( false, source, 'aPlayerVersion' ) then return end
	local bIsPre = false
	-- If not Release, mark as 'pre'
	if version.type:lower() ~= "release" then
		bIsPre = true
	else
		-- Extract rc version if there
		local _,_,rc = string.find( version.tag or "", "(%d)$" )
		rc = tonumber(rc) or 0
		-- If release, but before final rc, mark as 'pre'
		if version.mta == "1.0.2" and rc > 0 and rc < 13 then
			bIsPre = true
		elseif version.mta == "1.0.3" and rc < 9 then
			bIsPre = true
		end
		-- If version does not have a built in version check, maybe show a message box advising an upgrade
		if version.number < 259 or ( version.mta == "1.0.3" and rc < 3 ) then
			triggerClientEvent ( source, "aClientShowUpgradeMessage", source )
		end
	end

	-- Try to get new player version
	local playerVersion
	if getPlayerVersion then
		playerVersion = getPlayerVersion(client)
	else
		playerVersion = version.mta .. "-" .. ( bIsPre and "7" or "9" ) .. ".00000.0"
	end

	-- Format it all prettyful
	local _,_,ver,type,build = string.find ( playerVersion, "(.*)-([0-9])%.(.*)" )
	if aPlayers[source] then
		aPlayers[source]["version"] = ver .. ( type < '9' and " pre  " or "  " ) .. "(" .. type .. "." .. build .. ")"
	end
end )

function aPlayerSerialCheck ( player, result )
	if ( result == 0 ) then kickPlayer ( player, "Invalid serial" ) end
end

addEventHandler ( "onPlayerLogin", root, function ( previous, account, auto )
	if ( hasObjectPermissionTo ( source, "general.adminpanel" ) ) then
		triggerEvent ( "aPermissions", source )
		notifyPlayerLoggedIn( source )
	end
end )

addCommandHandler ( "register", function ( player, command, arg1, arg2 )
	local username = getPlayerName ( player )
	local password = arg1
	if ( arg2 ) then
		username = arg1
		password = arg2
	end
	if ( password ~= nil ) then
		if ( string.len ( password ) < 4 ) then
			outputChatBox ( "register: - Password should be at least 4 characters long", player, 255, 100, 70 )
		elseif ( addAccount ( username, password ) ) then
			outputChatBox ( "You have successfully registered! Username: '"..username.."', Password: '"..password.."'(Remember it)", player, 255, 100, 70 )
			outputServerLog ( "ACCOUNTS: "..getPlayerName ( player ).." registered account '"..username.."' (IP: "..getPlayerIP(player).."  Serial: "..getPlayerSerial(player)..")" )
		elseif ( getAccount ( username ) ) then
			outputChatBox ( "register: - Account with this name already exists.", player, 255, 100, 70 )
		else
			outputChatBox ( "Unknown Error", player, 255, 100, 70 )
		end
	else
		outputChatBox ( "register: - Syntax is 'register [<nick>] <password>'", player, 255, 100, 70 )
	end
end )

-- This requires "function.removeAccount" permission for both the admin resource and the player
addCommandHandler ( "unregister", function ( player, command, arg1 )
	local username = arg1 or ""
	local result = "failed - No permission"
	if ( hasObjectPermissionTo ( player, "function.removeAccount" ) ) then
		local account = getAccount ( username )
		if not account then
			result = "failed - Does not exist"
		elseif #aclGetAccountGroups ( account ) > 1 then
			result = "failed - Account in more than one ACL group"
		elseif removeAccount( account ) then
			result = "succeeded"
		else
			result = "failed - Check resource has permission"
		end
	end
	outputChatBox ( "Unregistering account '"..username.."' "..result, player, 255, 100, 70 )
	outputServerLog ( "ADMIN: "..getAdminNameForLog ( player ).." unregistering account '"..username.."' "..result.." (IP: "..getPlayerIP(player).."  Serial: "..getPlayerSerial(player)..")" )
end )

-- Returns "name" or "name(accountname)" if they differ
function getAdminNameForLog(player)
	local name = getPlayerName( player )
	if not isGuestAccount( getPlayerAccount( player ) ) then
		local accountName = getAccountName( getPlayerAccount( player ) )
		if name ~= accountName then
			return name.."("..accountName..")"
		end
	end
	return name
end

function aAdminMenu ( player, command )
	if ( hasObjectPermissionTo ( player, "general.adminpanel" ) ) then
		triggerClientEvent ( player, "aClientAdminMenu", root )
		aPlayers[player]["chat"] = true
	end
end
addCommandHandler ( "admin", aAdminMenu )

function aAction ( type, action, admin, player, data, more )
    if ( aLogMessages[type] ) then

        local function aEscapeNickname( name )
            return string.gsub( name, "%%", "%%%%" )
        end

        local function aStripString ( string )
            local adminName = aEscapeNickname( getPlayerName ( admin ) )
            string = tostring ( string )
            string = string.gsub ( string, "$admin",  adminName)
            string = string.gsub ( string, "$by_admin_4all", isAnonAdmin4All( admin )    and "" or " by " .. adminName )
            string = string.gsub ( string, "$by_admin_4plr", isAnonAdmin4Victim( admin ) and "" or " by " .. adminName )
            string = string.gsub ( string, "$data2", more or "" )

            if ( player ) then
                local playerName = aEscapeNickname( getPlayerName( player ) )
                string = string.gsub ( string, "$player", playerName)
            end

            return tostring ( string.gsub ( string, "$data", data or "" ) )
        end

        local node = aLogMessages[type][action]

        if ( node ) then
            local r, g, b = node["r"], node["g"], node["b"]
            if ( node["all"] ) then outputChatBox ( aStripString ( node["all"] ), root, r, g, b ) end
            if ( node["admin"] ) and ( admin ~= player ) then outputChatBox ( aStripString ( node["admin"] ), admin, r, g, b ) end
            if ( node["player"] ) then outputChatBox ( aStripString ( node["player"] ), player, r, g, b ) end
            if ( node["log"] ) then outputServerLog ( aStripString ( node["log"] ) ) end
        end
    end
end

-- Should admin name be hidden from public chatbox message?
function isAnonAdmin4All ( admin )
	return getElementData( admin, "AnonAdmin" ) == true
end

-- Should admin name be hidden from private chatbox message?
function isAnonAdmin4Victim ( admin )
	return false
end

addEvent ( "aTeam", true )
addEventHandler ( "aTeam", root, function ( action, name, r, g, b )
	if checkClient( "command."..action, source, 'aTeam', action ) then
		return
	end
	if ( hasObjectPermissionTo ( client or source, "command."..action ) ) then
		mdata = ""
		if ( action == "createteam" ) then
			local success
			if ( tonumber ( r ) ) and ( tonumber ( g ) ) and ( tonumber ( b ) ) then
				success = createTeam ( name, tonumber ( r ), tonumber ( g ), tonumber ( b ) )
			else
				success = createTeam ( name )
			end
			if ( not success ) then
				action = nil
				outputChatBox ( "Team \""..name.."\" could not be created.", source, 255, 0, 0 )
			end
		elseif ( action == "destroyteam" ) then
			local team = getTeamFromName ( name )
			if ( getTeamFromName ( name ) ) then
				destroyElement ( team )
			else
				action = nil
			end
		else
			action = nil
		end
		if ( action ~= nil ) then
			aAction ( "server", action, source, false, mdata )
		end
		return true
	end
	outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	return false
end )

addEvent ( "aAdmin", true )
addEventHandler ( "aAdmin", root, function ( action, ... )
	if checkClient( true, source, 'aAdmin', action ) then
		return
	end
	local mdata, mdata2
	if ( action == "password" ) then
		if ( not arg[1] ) then outputChatBox ( "Error - Password missing.", source, 255, 0, 0 )
		elseif ( not arg[2] ) then outputChatBox ( "Error - New password missing.", source, 255, 0, 0 )
		elseif ( not arg[3] ) then outputChatBox ( "Error - Confirm password.", source, 255, 0, 0 )
		elseif ( tostring ( arg[2] ) ~= tostring ( arg[3] ) ) then outputChatBox ( "Error - Passwords do not match.", source, 255, 0, 0 )
		else
			local account = getAccount ( getPlayerAccountName ( source ), tostring ( arg[1] ) )
			if ( account ) then
				setAccountPassword ( account, arg[2] )
			else
				outputChatBox ( "Error - Invalid password.", source, 255, 0, 0 )
			end
		end
	elseif ( action == "settings" ) then
		local cmd = arg[1]
		local resName = arg[2]
		local tableOut = {}
		if ( cmd == "change" ) then
			local name = arg[3]
			local value = arg[4]
			-- Get previous value
			local settings = aGetResourceSettings( resName )
			local oldvalue = settings[name].current
			-- Match type
			local changed
			if type(oldvalue) == 'boolean' then value = value=='true'   end
			if type(oldvalue) == 'number'  then value = tonumber(value) end
			if type(oldvalue) == "table" then
				value = fromJSON("[["..value.."]]")
				changed = not table.compare(value, oldvalue)
			else
				changed = value ~= oldvalue
			end
			if changed then
				if aSetResourceSetting( resName, name, value ) then
					-- Tell the resource one of its settings has changed
					local res = getResourceFromName(resName)
					local resRoot = getResourceRootElement(res)
					if resRoot then
						if getVersion().mta < "1.1" then
							triggerEvent('onSettingChange', resRoot, name, oldvalue, value, source )
						end
					end
				end
			end
		elseif ( cmd == "getall" ) then
			tableOut = aGetResourceSettings( resName )
			for name,value in pairs(tableOut) do
				if type(value.default) == "table" then
					tableOut[name].default = string.gsub(toJSON(value.default),"^(%[ %[ )(.*)( %] %])$", "%2")
					tableOut[name].current = string.gsub(toJSON(value.current),"^(%[ %[ )(.*)( %] %])$", "%2")
				end
			end
		end
		triggerClientEvent ( source, "aAdminSettings", root, cmd, resName, tableOut )
	elseif ( action == "sync" ) then
		local type = arg[1]
		local tableOut = {}
		if ( type == "aclgroups" ) then
			tableOut["groups"] = {}
			for id, group in ipairs ( aclGroupList() ) do
				table.insert ( tableOut["groups"] ,aclGroupGetName ( group ) )
			end
			tableOut["acl"] = {}
			for id, acl in ipairs ( aclList() ) do
				table.insert ( tableOut["acl"] ,aclGetName ( acl ) )
			end
			triggerClientEvent ( source, "aAdminACL", root, type, tableOut )
		elseif ( type == "aclobjects" ) then
			local group = aclGetGroup ( tostring ( arg[2] ) )
			if ( group ) then
				tableOut["name"] = arg[2]
				tableOut["objects"] = aclGroupListObjects ( group )
				tableOut["acl"] = {}
				for id, acl in ipairs ( aclGroupListACL ( group ) ) do
					table.insert ( tableOut["acl"], aclGetName ( acl ) )
				end
			end
			triggerClientEvent ( source, "aAdminACL", root, type, tableOut )
		elseif ( type == "aclrights" ) then
			local acl = aclGet ( tostring ( arg[2] ) )
			if ( acl ) then
				tableOut["name"] = arg[2]
				tableOut["rights"] = {}
				for id, name in ipairs ( aclListRights ( acl ) ) do
					tableOut["rights"][name] = aclGetRight ( acl, name )
				end
			end
			triggerClientEvent ( source, "aAdminACL", root, type, tableOut )
		elseif ( type == 'playeraclgroups') then
			local player = arg[2]
			if isElement(player) then
				local ignoredGroups = {
					['Everyone'] = true,
					['autoGroup_irc'] = true,
				}
				for _, v in ipairs(aclGroupList()) do
					local groupName = aclGroupGetName(v)
					if (not ignoredGroups[groupName]) then
						tableOut[groupName] = isObjectInACLGroup('user.'..getAccountName(getPlayerAccount(player)), v)
					end
				end
			end
			triggerClientEvent ( source, "aPermissionsSync", root, player, tableOut )
		end
	elseif ( action == "aclcreate" ) then
		local name = arg[2]
		if ( ( name ) and ( string.len ( name ) >= 1 ) ) then
			if ( arg[1] == "group" ) then
				mdata = "Group "..name
				if ( aclCreateGroup ( name ) ) then
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] created "..mdata)
				end
			elseif ( arg[1] == "acl" ) then
				mdata = "ACL "..name
				if ( aclCreate ( name ) ) then
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] created "..mdata)
				end
			end
			triggerEvent ( "aAdmin", source, "sync", "aclgroups" )
		else
			outputChatBox ( "Error - Invalid "..arg[1].." name", source, 255, 0, 0 )
		end
	elseif ( action == "acldestroy" ) then
		local name = arg[2]
		if ( arg[1] == "group" ) then
			if ( aclGetGroup ( name ) ) then
				mdata = "Group "..name
				aclDestroyGroup ( aclGetGroup ( name ) )
				outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] destroyed "..mdata)
			end
		elseif ( arg[1] == "acl" ) then
			if ( aclGet ( name ) ) then
				mdata = "ACL "..name
				aclDestroy ( aclGet ( name ) )
				outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] destroyed "..mdata)
			end
		end
		triggerEvent ( "aAdmin", source, "sync", "aclgroups" )
	elseif ( action == "acladd" ) then
		if ( arg[3] ) then
			if ( arg[1] == "object" ) then
				local group = aclGetGroup ( arg[2] )
				local object = arg[3]
				if ( not aclGroupAddObject ( group, object ) ) then
					outputChatBox ( "Error adding object '"..tostring ( object ).."' to group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] added "..object.." to ACL Group "..arg[2])
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
					if arg[4] then
						triggerClientEvent ( source, "aOnPermissionsChange", source )
					end
				end
			elseif ( arg[1] == "acl" ) then
				local group = aclGetGroup ( arg[2] )
				local acl = aclGet ( arg[3] )
				if ( not aclGroupAddACL ( group, acl ) ) then
					outputChatBox ( "Error adding ACL '"..tostring ( arg[3] ).."' to group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "ACL '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] added "..mdata2.." to Group "..arg[2])
				end
			elseif ( arg[1] == "right" ) then
				local acl = aclGet ( arg[2] )
				local right = arg[3]
				local enabled = true
				if ( not aclSetRight ( acl, right, enabled ) ) then
					outputChatBox ( "Error adding right '"..tostring ( arg[3] ).."' to group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "Right '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclrights", arg[2] )
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] added "..mdata2.." to ACL "..arg[2])
				end
			end
		end
	elseif ( action == "aclremove" ) then
		if ( arg[3] ) then
			if ( arg[1] == "object" ) then
				local group = aclGetGroup ( arg[2] )
				local object = arg[3]
				if ( not aclGroupRemoveObject ( group, object ) ) then
					outputChatBox ( "Error - object '"..tostring ( object ).."' does not exist in group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "Object '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] removed "..mdata2)
					if arg[4] then
						triggerClientEvent ( source, "aOnPermissionsChange", source )
					end
				end
			elseif ( arg[1] == "acl" ) then
				local group = aclGetGroup ( arg[2] )
				local acl = aclGet ( arg[3] )
				if ( not aclGroupRemoveACL ( group, acl ) ) then
					outputChatBox ( "Error - ACL '"..tostring ( arg[3] ).."' does not exist in group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "ACL '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] removed "..mdata2)
				end
			elseif ( arg[1] == "right" ) then
				local acl = aclGet ( arg[2] )
				local right = arg[3]
				if ( not aclRemoveRight ( acl, right ) ) then
					outputChatBox ( "Error - right '"..tostring ( arg[3] ).."' does not exist in ACL '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata = "ACL '"..arg[2].."'"
					mdata2 = "Right '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclrights", arg[2] )
					outputServerLog ("ACL: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] removed "..mdata2.." from "..mdata)
				end
			end
		end
	end
end )


-- seconds to description i.e. "10 mins"
function secondsToTimeDesc( seconds )
	if seconds then
		local tab = { {"day",60*60*24},  {"hour",60*60},  {"min",60},  {"sec",1} }
		for i,item in ipairs(tab) do
			local t = math.floor(seconds/item[2])
			if t > 0 or i == #tab then
				return tostring(t) .. " " .. item[1] .. (t~=1 and "s" or "")
			end
		end
	end
	return ""
end


function warp ( p, to )
	local x, y, z, r, dim, int
	if type ( to ) == "table" then
		x, y, z = unpack ( to )
		r, dim, int = 0, 0, 0
	else
		x, y, z = getElementPosition ( to )
		_, _, r = getElementRotation ( to )
		dim = getElementDimension ( to )
		int = getElementInterior ( to )
	end
	local target = getPedOccupiedVehicle ( p ) or p
	x = x - math.sin ( math.rad ( r ) ) * 2
	y = y + math.cos ( math.rad ( r ) ) * 2
	setTimer ( setElementPosition, 1000, 1, target, x, y, z + 1 )
	fadeCamera ( p, false, 1, 0, 0, 0 )
	setElementDimension ( target, dim )
	setElementInterior ( target, int )
	setTimer ( fadeCamera, 1000, 1, p, true, 1 )
end


addEvent ( "aPlayer", true )
addEventHandler ( "aPlayer", root, function ( player, action, data, additional, additional2 )
	if checkClient( "command."..action, source, 'aPlayer', action ) then return end
	if not isElement( player ) then
		return	-- Ignore if player is no longer valid
	end
	if ( hasObjectPermissionTo ( client or source, "command."..action ) ) then
		local admin = source
		local mdata = ""
		local more = ""
		if ( action == "kick" ) then
			local reason = data or ""
			mdata = reason~="" and ( "(" .. reason .. ")" ) or ""
			local isAnonAdmin = getElementData(source, "AnonAdmin")
			if isAnonAdmin then
				setTimer ( kickPlayer, 100, 1, player, "Anonymous admin", reason )
			else
				setTimer ( kickPlayer, 100, 1, player, source, reason )
			end
		elseif ( action == "ban" ) then
			local reason = data or ""
			local seconds = tonumber(additional) and tonumber(additional) > 0 and tonumber(additional)
			local bUseSerial = additional2
			local isAnonAdmin = getElementData(source, "AnonAdmin")
			mdata = reason~="" and ( "(" .. reason .. ")" ) or ""
			more = seconds and ( "(" .. secondsToTimeDesc(seconds) .. ")" ) or ""
			if bUseSerial and getPlayerName ( player ) and not isAnonAdmin then
				-- Add banned player name to the reason
				reason = reason .. " (nick: " .. getPlayerName ( player ) .. ")"
			end
			-- Add account name of banner to the reason
			local adminAccountName = getAccountName ( getPlayerAccount ( source ) )
			if adminAccountName and adminAccountName ~= getPlayerName( source ) and not isAnonAdmin then
				reason = reason .. " (by " .. adminAccountName .. ")"
			end
			if bUseSerial then
				outputChatBox ( "You banned serial " .. getPlayerSerial( player ), source, 255, 100, 70 )
				if isAnonAdmin then

					setTimer ( function()
						local tBan = addBan( nil, nil, getPlayerSerial(player), "Anonymous admin", reason, seconds or 0 )
						setBanAdmin(tBan,adminAccountName)
					end, 100, 1)

				else
					setTimer ( function()
						local tBan = addBan( nil, nil, getPlayerSerial(player), source, reason, seconds or 0 )
						setBanAdmin(tBan,adminAccountName)
					end, 100, 1)
				end
			else
				outputChatBox ( "You banned IP " .. getPlayerIP( player ), source, 255, 100, 70 )
				if isAnonAdmin then
					setTimer ( function()
						local tBan = banPlayer( player, true, false, false, nil, reason, seconds or 0 )
						setBanAdmin(tBan,adminAccountName)
					end, 100, 1)
				else
					setTimer ( function()
						local tBan = banPlayer( player, true, false, false, source, reason, seconds or 0 )
						setBanAdmin(tBan,adminAccountName)
					end, 100, 1)
				end
			end
			setTimer( triggerEvent, 1000, 1, "aSync", root, "bansdirty" )
		elseif ( action == "mute" )  then
			if ( isPlayerMuted ( player ) ) then action = "un"..action end
			local reason = data or ""
			local seconds = tonumber(additional) and tonumber(additional) > 0 and tonumber(additional)
			mdata = reason~="" and ( "(" .. reason .. ")" ) or ""
			more = seconds and ( "(" .. secondsToTimeDesc(seconds) .. ")" ) or ""
			aSetPlayerMuted ( player, not isPlayerMuted ( player ), seconds )
		elseif ( action == "freeze" )  then
			if ( isPlayerFrozen ( player ) ) then action = "un"..action end
			aSetPlayerFrozen ( player, not isPlayerFrozen ( player ) )
		elseif ( action == "setnick" )  then
			local playername = getPlayerName(player)
			if setPlayerName( player, data ) then
				outputChatBox ( "You changed '"..playername.."' to '"..data.."'!", source, 255, 100, 70 )
				outputChatBox ( "'"..getPlayerName( source ).."' changed your nick to '"..data.."'!", player, 255, 100, 70 )
			else
				outputChatBox ( "Invalid Nick", source, 255, 0, 0 )
			end
		elseif ( action == "shout" ) then
			local textDisplay = textCreateDisplay ()
			local textItem
			local anon = getElementData( admin, "AnonAdmin" )
			if (anon) then
				textItem = textCreateTextItem ( "ADMIN:\n\n"..data, 0.5, 0.5, 2, 255, 100, 50, 255, 4, "center", "center" )
			else
				textItem = textCreateTextItem ( "(ADMIN)"..getPlayerName ( source )..":\n\n"..data, 0.5, 0.5, 2, 255, 100, 50, 255, 4, "center", "center" )
			end
			textDisplayAddText ( textDisplay, textItem )
			textDisplayAddObserver ( textDisplay, player )
			setTimer ( textDestroyTextItem, 5000, 1, textItem )
			setTimer ( textDestroyDisplay, 5000, 1, textDisplay )
		elseif ( action == "sethealth" ) then
			local health = tonumber ( data )
			if ( health ) then
				if ( health > 200 ) then health = 100 end
				if ( not setElementHealth ( player, health ) ) then
					action = nil
				end
				mdata = health
			else
				action = nil
			end
		elseif ( action == "setarmour" ) then
			local armour = tonumber ( data )
			if ( armour ) then
				if ( armour > 200 ) then armour = 100 end
				if ( not setPedArmor ( player, armour ) ) then
					action = nil
				end
				mdata = armour
			else
				action = nil
			end
		elseif ( action == "setskin" ) then
			data = tonumber ( data )
			if ( setElementModel( player, data) ) then
				mdata = data
			else
				action = nil
				outputChatBox( "Invalid skin ID", source, 255, 0, 0 )
			end
		elseif ( action == "setmoney" ) then
			mdata = data
			if ( not setPlayerMoney ( player, data ) ) then
				outputChatBox ( "Invalid money data", source, 255, 0, 0 )
				action = nil
			end
		elseif ( action == "setstat" ) then
			if ( additional ) then
				if ( tonumber ( data ) == 300 ) then
					if ( setPedFightingStyle ( player, tonumber ( additional ) ) ) then
						mdata = "Fighting Style"
						more = additional
					else
						action = nil
					end
				else
					if ( setPedStat ( player, tonumber ( data ), tonumber ( additional ) ) ) then
						mdata = aStats[data]
						more = additional
					else
						action = nil
					end
				end
			else
				action = nil
			end
		elseif ( action == "setteam" ) then
			if ( getElementType ( data ) == "team" ) then
				setPlayerTeam ( player, data )
				mdata = getTeamName ( data )
			else
				action = nil
			end
		elseif ( action == "removefromteam" ) then
			mdata = getTeamName( getPlayerTeam( player ) )
			setPlayerTeam ( player, nil )
		elseif ( action == "setinterior" ) then
			action = nil
			for id, interior in ipairs ( aInteriors ) do
				if ( interior["id"] == data ) then
					local vehicle = getPedOccupiedVehicle ( player )
					setElementInterior ( player, interior["world"] )
					local x, y, z = interior["x"] or 0, interior["y"] or 0, interior["z"] or 0
					local rot = interior["r"] or 0
					if ( vehicle ) then
						setElementInterior ( vehicle, interior["world"] )
						setElementPosition ( vehicle, x, y, z + 0.2 )
					else
						setElementPosition ( player, x, y, z + 0.2 )
						setElementRotation ( player, 0, 0, rot, 'default', true )
					end
					action = "interior"
					mdata = data
				end
			end
		elseif ( action == "setdimension" ) then
			local dimension = tonumber ( data )
			if ( dimension ) then
				if ( dimension > 65535 ) or ( dimension < 0 ) then dimension = 0 end
				if ( not setElementDimension ( player, dimension ) ) then
					action = nil
				end
				mdata = dimension
			else
				action = nil
			end
		elseif ( action == "jetpack" ) then
			if ( isPedWearingJetpack ( player ) ) then
				setPedWearingJetpack ( player, false )
				action = "jetpackr"
			else
				if ( getPedOccupiedVehicle ( player ) ) then outputChatBox ( "Unable to give a jetpack - "..getPlayerName ( player ).." is in a vehicle", source, 255, 0, 0 )
				else
					if ( setPedWearingJetpack ( player, true ) ) then
						action = "jetpacka"
					end
				end
			end
		elseif ( action == "setgroup" ) then
			local account = getPlayerAccount ( player )
			if ( not isGuestAccount ( account ) ) then
				local group = aclGetGroup ( "Admin" )
				if ( group ) then
					if ( data == true ) then
						aclGroupAddObject ( group, "user."..getAccountName ( account ) )
						bindKey ( player, "p", "down", "admin" )
						action = "admina"
					elseif ( data == false ) then
						unbindKey ( player, "p", "down", "admin" )
						aclGroupRemoveObject ( group, "user."..getAccountName ( account ) )
						aPlayers[player]["chat"] = false
						action = "adminr"
					end
					for id, p in ipairs ( getElementsByType ( "player" ) ) do
						if ( hasObjectPermissionTo ( p, "general.adminpanel" ) ) then triggerEvent ( "aSync", p, "admins" ) end
					end
				else
					outputChatBox ( "Error - Admin group not initialized. Please reinstall admin resource.", source, 255, 0 ,0 )
				end
			else
				outputChatBox ( "Error - Player is not logged in.", source, 255, 100 ,100 )
			end
		elseif ( action == "givevehicle" ) then
			local vehicle = getPedOccupiedVehicle ( player )
			if ( vehicle ) then
				setElementModel(vehicle, data)
				fixVehicle(vehicle)
			else
				local x, y, z = getElementPosition ( player )
				local _, _, r = getElementRotation ( player )
				local vx, vy, vz = getElementVelocity ( player )
				vehicle = createVehicle ( data, x, y, z, 0, 0, r )
				setElementDimension ( vehicle, getElementDimension ( player ) )
				setElementInterior ( vehicle, getElementInterior ( player ) )
				warpPedIntoVehicle ( player, vehicle )
				setElementVelocity ( vehicle, vx, vy, vz )
			end
			mdata = getVehicleName ( vehicle )
		elseif ( action == "giveweapon" ) then
			if ( giveWeapon ( player, data, additional, true ) ) then
				mdata = getWeaponNameFromID ( data )
				more = additional
			else
				action = nil
			end
		elseif ( action == "slap" ) then
			if ( getElementHealth ( player ) > 0 ) and ( not isPedDead ( player ) ) then
				local slap = tonumber(data) or 20
				if ( slap >= 0 ) then
					if ( slap > 0 ) then
						if ( slap > getElementHealth ( player ) ) then setTimer ( killPed, 50, 1, player )
						else setElementHealth ( player, getElementHealth ( player ) - slap ) end
					end
					local x, y, z = getElementVelocity ( player )
					setElementVelocity ( player, x , y, z + 0.2 )
					mdata = slap
				else
					action = nil
				end
			else
				action = nil
			end
		elseif ( action == "warp" ) or ( action == "warpto" ) then
			function warpPlayer ( p, to )
				if ( isElement ( to ) and isPedInVehicle ( to ) ) then
					local vehicle = getPedOccupiedVehicle ( to )
					local seats = getVehicleMaxPassengers ( vehicle ) + 1
					local i = 0
					while ( i < seats ) do
						if ( not getVehicleOccupant ( vehicle, i ) ) then
							setTimer ( warpPedIntoVehicle, 1000, 1, p, vehicle, i )
							fadeCamera ( p, false, 1, 0, 0, 0 )
							setTimer ( fadeCamera, 1000, 1, p, true, 1 )
							break
						end
						i = i + 1
					end
					if ( i >= seats ) then
						warp ( p, to )
						outputConsole ( "Player's vehicle is full ("..getVehicleName ( vehicle ).." - Seats: "..seats..")", p )
					end
				else
					warp ( p, to )
				end
			end
			if ( action == "warp" ) then
				warpPlayer ( source, player )
			else
				warpPlayer ( player, data )
				mdata = type ( data ) == "table" and getZoneName ( unpack ( data ) ) or getPlayerName ( data )
			end
		else
			action = nil
		end
		if ( action ~= nil ) then aAction ( "player", action, admin, player, mdata, more ) end
		return true
	end
	outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	return false
end )

function hex2rgb(hex)
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

addEvent ( "aVehicle", true )
addEventHandler ( "aVehicle", root, function ( player, action, data )
	if checkClient( "command."..action, source, 'aVehicle', action ) then return end
	if ( hasObjectPermissionTo ( client or source, "command."..action ) ) then
		if ( not player ) then return end
		local vehicle = getPedOccupiedVehicle ( player )
		if ( vehicle ) then
			local mdata = ""
			if ( action == "repair" ) then
				fixVehicle ( vehicle )
				local rx, ry, rz = getElementRotation ( vehicle )
				if ( rx > 110 ) and ( rx < 250 ) then
					local x, y, z = getElementPosition ( vehicle )
					setElementRotation ( vehicle, rx + 180, ry, rz )
					setElementPosition ( vehicle, x, y, z + 2 )
				end
			elseif ( action == "customize" ) then
				if ( data[1] == "remove" ) then
					for id, upgrade in ipairs ( getVehicleUpgrades ( vehicle ) ) do
						removeVehicleUpgrade ( vehicle, upgrade )
					end
					action = "customizer"
				else
					for id, upgrade in ipairs ( data ) do
						addVehicleUpgrade ( vehicle, upgrade )
						if ( mdata == "" ) then mdata = tostring ( upgrade )
						else mdata = mdata..", "..upgrade end
					end
				end
			elseif ( action == "setpaintjob" ) then
				mdata = data
				if ( not setVehiclePaintjob ( vehicle, data ) ) then
					action = nil
					outputChatBox ( "Invalid Paint job ID", source, 255, 0, 0 )
				end
			elseif ( action == "setcolor" ) then
					r, g, b = hex2rgb(data[1])
					r2, g2, b2 = hex2rgb(data[2])
					r3, g3, b3 = hex2rgb(data[3])
					r4, g4, b4 = hex2rgb(data[4])
					if ( not setVehicleColor ( vehicle, r, g, b, r2, g2, b2, r3, g3, b3, r4, g4, b4 ) ) then
						action = nil
					end
			elseif ( action == "setlights" ) then
					r, g, b = hex2rgb(data[1])
					if ( not setVehicleHeadLightColor ( vehicle, r, g, b) ) then
						action = nil
					end
			elseif ( action == "setplates" ) then
				mdata = data[1]
				setVehiclePlateText ( vehicle, data[1] )
			elseif ( action == "blowvehicle" ) then
				setTimer ( blowVehicle, 100, 1, vehicle )
			elseif ( action == "destroyvehicle" ) then
				setTimer ( destroyElement, 100, 1, vehicle )
			else
				action = nil
			end
			if ( action ~= nil ) then
				local seats = getVehicleMaxPassengers ( vehicle )
				if seats then
					for i = 0, seats do
						local passenger = getVehicleOccupant ( vehicle, i )
						if ( passenger ) then
							aAction ( "vehicle", action, source, passenger, mdata )
						end
					end
				end
			end
		end
		return true
	end
	outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	return false
end )

function stopAllResources ()
for i, resource in ipairs(getResources()) do
	stopResource(resource)
end
	return true
end

addEvent ( "aResource", true )
addEventHandler ( "aResource", root, function ( name, action )
	if checkClient( "command."..action, source, 'aResource', action ) then return end
	local pname = getPlayerName ( source )
	if ( hasObjectPermissionTo ( client or source, "command."..action ) ) then
		local text = ""
		if ( action == "start" ) then
			if ( startResource ( getResourceFromName ( name ), true ) ) then
				text = "started"
			end
		elseif ( action == "restart" ) then
			if ( getResourceState ( getResourceFromName ( name ) ) == "running" ) then
				if ( restartResource ( getResourceFromName ( name ) ) ) then text = "restarted" end
			end
		elseif ( action == "stop" ) then
			if ( stopResource ( getResourceFromName ( name ) ) ) then
				text = "stopped"
			end
		elseif ( action == "delete" ) then
			if ( deleteResource ( getResourceFromName ( name ) ) ) then
				text = "deleted"
			end
		elseif ( action == "stopall" ) then
			if ( stopAllResources ( ) ) then
				text = "All Stopped"
			end
		end
		if ( text ~= "" ) then
			outputServerLog ( "ADMIN: Resource \'" .. name .. "\' " .. text .. " by " .. getAdminNameForLog ( source )  )
			for id, player in ipairs(getElementsByType("player")) do
				triggerClientEvent ( player, "aClientLog", root, text  )
			end
		end
		return true
	end
	outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	return false
end )

addEvent ( "aServer", true )
addEventHandler ( "aServer", root, function ( action, data, data2 )
	if checkClient( "command."..action, source, 'aServer', action ) then return end
	if ( hasObjectPermissionTo ( client or source, "command."..action ) ) then
		local mdata = tostring ( data )
		local mdata2 = ""
		if ( action == "setgame" ) then
			if ( not setGameType ( tostring ( data ) ) ) then
				action = nil
				outputChatBox ( "Error setting game type.", source, 255, 0, 0 )
			end
			triggerEvent ( "aSync", source, "server" )
		elseif ( action == "setmap" ) then
			if ( not setMapName ( tostring ( data ) ) ) then
				action = nil
				outputChatBox ( "Error setting map name.", source, 255, 0, 0 )
			end
			triggerEvent ( "aSync", source, "server" )
		elseif ( action == "setwelcome" ) then
			if ( ( not data ) or ( data == "" ) ) then
				action = "resetwelcome"
				aRemoveSetting ( "welcome" )
			else
				aSetSetting ( "welcome", tostring ( data ) )
				mdata = data
			end
		elseif ( action == "settime" ) then
			if ( not setTime ( tonumber ( data ), tonumber ( data2 ) ) ) then
				action = nil
				outputChatBox ( "Error setting time.", source, 255, 0, 0 )
			end
			mdata = data..":"..data2
		elseif ( action == "shutdown" ) then
			setTimer(shutdown, 2000, 1, data)
		elseif ( action == "setpassword" ) then
			if ( not data or data == "" ) then
				setServerPassword ( nil )
				action = "resetpassword"
			elseif ( string.len ( data ) > 32 ) then
				outputChatBox ( "Set password: 32 characters max", source, 255, 0, 0 )
			elseif ( not setServerPassword ( data ) ) then
				action = nil
				outputChatBox ( "Error setting password", source, 255, 0, 0 )
			end
			triggerEvent ( "aSync", source, "server" )
		elseif ( action == "setweather" ) then
			if ( not setWeather ( tonumber ( data ) ) ) then
				action = nil
				outputChatBox ( "Error setting weather.", source, 255, 0, 0 )
			end
			mdata = data.." "..getWeatherNameFromID ( tonumber ( data ) )
		elseif ( action == "blendweather" ) then
			if ( not setWeatherBlended ( tonumber ( data ) ) ) then
				action = nil
				outputChatBox ( "Error setting weather.", source, 255, 0, 0 )
			end
		elseif ( action == "setgamespeed" ) then
			if ( not setGameSpeed ( tonumber ( data ) ) ) then
				action = nil
				outputChatBox ( "Error setting game speed.", source, 255, 0, 0 )
			end
		elseif ( action == "setgravity" ) then
			if ( setGravity ( tonumber ( data ) ) ) then
				for id, player in ipairs ( getElementsByType ( "player" ) ) do
					setPedGravity ( player, getGravity() )
				end
			else
				action = nil
				outputChatBox ( "Error setting gravity.", source, 255, 0, 0 )
			end
		elseif ( action == "setwaveheight" ) then
			if ( not setWaveHeight ( data ) ) then
				outputChatBox ( "Error setting wave height.", source, 255, 0, 0 )
				action = nil
			else
				mdata = data
			end
		elseif ( action == "setfpslimit" ) then
			if ( not setFPSLimit ( tonumber ( data ) ) ) then
				action = nil
				outputChatBox ( "Error setting FPS Limit.", source, 255, 0, 0 )
			end
		elseif ( action == "clearchat" ) then
			clearChatBox()
		else
			action = nil
		end
		if ( action ~= nil ) then aAction ( "server", action, source, false, mdata, mdata2 ) end
		return true
	end
	outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	return false
end )

addEventHandler ( "onPlayerChat", root, function ( message )
	local size = #chatHistory[source]
	if ( size == g_Prefs.maxchatmsgs ) then
		table.remove( chatHistory[source], 1 )
		size = size - 1
	end
	chatHistory[source][size + 1] = message
end )

function getPlayerChatHistory ( player, chunk )
	if ( player and isElement ( player ) ) then
		local size = #chatHistory[player]
		chunk = tonumber(chunk)
		if ( chunk and chunk < size ) then
			size = chunk
		end
		local text = ""
		for i=1, size do
			text = text .. chatHistory[player][i] .. "\n"
		end
		return text
	else
		return false
	end
end

addEvent ( "aMessage", true )
addEventHandler ( "aMessage", root,
function ( action, data )
	if checkClient( false, source, 'aMessage', action ) then
		return
	end
	if ( action == "new" ) then
		local time = getRealTime()
		local id = #aReports + 1
		aReports[id] = {}
		aReports[id].author = getPlayerName ( source )
		aReports[id].category = tostring ( data.category )
		aReports[id].subject = tostring ( data.subject )
		aReports[id].text = tostring ( data.message )
		aReports[id].time = string.format( '%04d-%02d-%02d %02d:%02d', time.year + 1900, time.month + 1, time.monthday, time.hour, time.minute )
		if ( data.suspect ) then
			local suspectedPlayer = getPlayerFromName( data.suspect )
			if suspectedPlayer then
				aReports[id].suspect = {
					name = data.suspect,
					username = getPlayerAccountName ( suspectedPlayer ),
					ip = getPlayerIP ( suspectedPlayer ),
					serial = getPlayerSerial ( suspectedPlayer ),
					version = getPlayerVersion ( suspectedPlayer ),
					chatLog = getPlayerChatHistory ( suspectedPlayer )
				}
			end
		end
		aReports[id].read = false
		-- PM all admins to say a new message has arrived
		for _, p in ipairs ( getElementsByType ( "player" ) ) do
			if ( hasObjectPermissionTo ( p, "general.adminpanel" ) ) then
				outputChatBox( "New Admin message from " .. aReports[id].author .. " (" .. aReports[id].subject .. ")", p, 255, 0, 0 )
			end
		end
		-- Keep message count no greater that 'maxmsgs'
		while #aReports > g_Prefs.maxmsgs do
			table.remove( aReports, 1 )
		end
	end
	if ( hasObjectPermissionTo ( client or source, "general.adminpanel" ) ) then
		if ( action == "get" ) then
			triggerClientEvent ( source, "aMessage", source, "get", aReports )
		elseif ( action == "read" ) then
			if ( aReports[data] ) then
				aReports[data].read = true
			end
		elseif ( action == "delete" ) then
			if ( aReports[data] ) then
				outputServerLog ( "ADMIN: "..getPlayerName(client).." has deleted a report with subject '"..aReports[data].subject.."'." )
				table.remove ( aReports, data )
			end
			triggerClientEvent ( source, "aMessage", source, "get", aReports )
		end
	end
	for id, p in ipairs ( getElementsByType ( "player" ) ) do
		if ( hasObjectPermissionTo ( p, "general.adminpanel" ) ) then
			triggerEvent ( "aSync", p, "messages" )
		end
	end
end
)

addEvent ( "aModdetails", true )
addEventHandler ( "aModdetails", resourceRoot, function ( action, player )
	if checkClient( false, client, 'aModdetails', action ) then return end
	if ( hasObjectPermissionTo ( client, "general.adminpanel" ) ) then
		if ( action == "get" ) then
			triggerClientEvent ( client, "aModdetails", resourceRoot, "get", getPlayerModInfo(player), player )
		end
	end
end )

addEvent ( "aBans", true )
addEventHandler ( "aBans", root, function ( action, data, arg1, arg2, arg3 )
	if checkClient( "command."..action, source, 'aBans', action ) then return end
	if ( hasObjectPermissionTo ( client or source, "command."..action ) ) then
		local mdata = ""
		local more = ""
		if ( action == "banip" ) then
			mdata = data
			local newban = addBan ( data, nil, nil, source, arg2, arg3 )
			if ( not newban ) then
				action = nil
			else
				setBanNick (newban, arg1)
				setBanAdmin(newban, getAccountName(getPlayerAccount(source)))
			end
		elseif ( action == "banserial" ) then
			mdata = data
			local serial = string.upper ( data )
			local newban = addBan ( nil, nil, serial, source, arg2, arg3 )
			if ( not newban ) then
				action = nil
			else
				setBanAdmin(newban, getAccountName(getPlayerAccount(source)))
				setBanNick (newban, arg1)
			end
		elseif ( action == "unbanip" ) then
			mdata = data
			action = nil
			for i,ban in ipairs(getBans ()) do
				if getBanIP(ban) == data then

					action = removeBan ( ban, source )
				end
			end
		elseif ( action == "unbanserial" ) then
			mdata = data
			action = nil
			for i,ban in ipairs(getBans ()) do
				if getBanSerial(ban) == string.upper(data) then
					action = removeBan ( ban, source )
				end
			end
		else
			action = nil
		end

		if ( action ~= nil ) then
			aAction ( "bans", action, source, false, mdata, more )
			triggerEvent ( "aSync", source, "sync", "bansdirty" )
		end
		return true
	end
	outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	return false
end )

addEvent ( "aAdminChat", true )
addEventHandler ( "aAdminChat", root, function ( chat )
	if #chat > ADMIN_CHAT_MAXLENGTH then
		return
	end
	if checkClient( true, source, 'aAdminChat' ) then return end
	for id, player in ipairs(getElementsByType("player")) do
		if ( aPlayers[player]["chat"] ) then
			triggerClientEvent ( player, "aClientAdminChat", source, chat )
		end
	end
	outputServerLog ("(ADMIN CHAT) "..tostring(getPlayerName(source))..": "..chat)
end )

addCommandHandler(get("adminChatCommandName"),
	function(thePlayer, cmd, ...)
		if hasObjectPermissionTo (thePlayer, "general.tab_adminchat", false) and #arg > 0 then
			triggerEvent("aAdminChat", thePlayer, table.concat(arg, " "))
		end
	end
)

addEventHandler('onElementDataChange', root,
	function(dataName, oldValue )
		if getElementType(source)=='player' and checkClient( false, source, 'onElementDataChange', dataName ) then
			setElementData( source, dataName, oldValue )
			return
		end
	end
)

-- returns true if there is trouble
function checkClient(checkAccess,player,...)
	if client and client ~= player and g_Prefs.securitylevel >= 2 then
		local desc = table.concat({...}," ")
		local ipAddress = getPlayerIP(client)
		outputDebugString( "Admin security - Client/player mismatch from " .. tostring(ipAddress) .. " (" .. tostring(desc) .. ")", 1 )
		cancelEvent()
		if g_Prefs.clientcheckban then
			local reason = "admin checkClient (" .. tostring(desc) .. ")"
			addBan ( ipAddress, nil, nil, root, reason )
		end
		return true
	end
	if checkAccess and g_Prefs.securitylevel >= 1 then
		if type(checkAccess) == 'string' then
			if hasObjectPermissionTo ( player, checkAccess ) then
				return false	-- Access ok
			end
			if hasObjectPermissionTo ( player, "general.adminpanel" ) then
				local desc = table.concat({...}," ")
				local ipAddress = getPlayerIP(player)
				outputDebugString( "Admin security - Client does not have required rights ("..checkAccess.."). " .. tostring(ipAddress) .. " (" .. tostring(desc) .. ")" )
				return true		-- Low risk fail - Can't do specific command, but has access to admin panel
			end
		end
		if not hasObjectPermissionTo ( player, "general.adminpanel" ) then
			local desc = table.concat({...}," ")
			local ipAddress = getPlayerIP(client or player)
			outputDebugString( "Admin security - Client without admin panel rights trigged an admin panel event. " .. tostring(ipAddress) .. " (" .. tostring(desc) .. ")", 2 )
			return true			-- High risk fail - No access to admin panel
		end
	end
	return false
end

addEventHandler ("onUnban",root,function(theBan,responsibleElement)
	if isElement(responsibleElement) and getElementType (responsibleElement)=="player" then
		outputServerLog ("BAN: "..getPlayerName(responsibleElement).."["..getAccountName (getPlayerAccount(responsibleElement)).."] ["..getPlayerSerial (responsibleElement).."] ["..getPlayerIP (responsibleElement).."] unbanned player "..(getBanNick(theBan) or "unknown").." ["..(getBanIP (theBan) or getBanSerial(theBan)).."] ")
	end
end)

addEventHandler ("onBan",root,function(theBan)
	if isElement(source) and getElementType (source)=="player" then
		outputServerLog ("BAN: "..getPlayerName(source).."["..getAccountName (getPlayerAccount(source)).."] ["..getPlayerSerial (source).."] ["..getPlayerIP (source).."] banned player "..(getBanNick(theBan) or "unknown").." ["..(getBanIP (theBan) or getBanSerial(theBan)).."] ")
	end
end)
