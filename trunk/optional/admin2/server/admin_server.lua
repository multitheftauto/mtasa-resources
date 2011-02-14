--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_server.lua
*
*	Original File by lil_Toady
*
**************************************]]

_root = getRootElement()
_types = { "player", "team", "vehicle", "resource", "bans", "server", "admin" }

aPlayers = {}
aLogMessages = {}
aInteriors = {}
aStats = {}
aReports = {}
aWeathers = {}

addCommandHandler ( "adminpanel", function ( player )
	if ( hasObjectPermissionTo ( player, "general.adminpanel" ) ) then
		triggerClientEvent ( player, "aClientAdminMenu", _root )
		aPlayers[player]["chat"] = true
	end
end )

addEventHandler ( "onResourceStart", _root, function ( resource )
	if ( resource ~= getThisResource() ) then
		for id, player in ipairs(getElementsByType("player")) do
			if ( hasObjectPermissionTo ( player, "general.tab_resources" ) ) then
				triggerClientEvent ( player, "aClientResourceStart", _root, getResourceName ( resource ) )
			end
		end
		return
	end
	aSetupACL()
	aSetupCommands()
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		aPlayerInitialize ( player )
	end
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
	local node = xmlLoadFile ( "conf\\stats.xml" )
	if ( node ) then
		local stats = 0
		while ( xmlFindChild ( node, "stat", stats ) ) do
			local stat = xmlFindChild ( node, "stat", stats )
			local id = tonumber ( xmlNodeGetAttribute ( stat, "id" ) )
			local name = xmlNodeGetAttribute ( stat, "name" )
			aStats[id] = name
			stats = stats + 1
		end
		xmlUnloadFile ( node )
	end
	local node = xmlLoadFile ( "conf\\weathers.xml" )
	if ( node ) then
		local weathers = 0
		while ( xmlFindChild ( node, "weather", weathers ) ~= false ) do
		local weather = xmlFindChild ( node, "weather", weathers )
			local id = tonumber ( xmlNodeGetAttribute ( weather, "id" ) )
			local name = xmlNodeGetAttribute ( weather, "name" )
			aWeathers[id] = name
			weathers = weathers + 1
		end
		xmlUnloadFile ( node )
	end
	local node = xmlLoadFile ( "conf\\reports.xml" )
	if ( node ) then
		local messages = 0
		while ( xmlFindChild ( node, "message", messages ) ) do
			subnode = xmlFindChild ( node, "message", messages )
			local author = xmlFindChild ( subnode, "author", 0 )
			local subject = xmlFindChild ( subnode, "subject", 0 )
			local category = xmlFindChild ( subnode, "category", 0 )
			local text = xmlFindChild ( subnode, "text", 0 )
			local time = xmlFindChild ( subnode, "time", 0 )
			local read = ( xmlFindChild ( subnode, "read", 0 ) ~= false )
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
			aReports[id].read = read
			messages = messages + 1
		end
	end
	local node = xmlLoadFile ( "conf\\messages.xml" )
	if ( node ) then
		for id, type in ipairs ( _types ) do
			local subnode = xmlFindChild ( node, type, 0 )
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
		xmlUnloadFile ( node )
	end
end )

addEventHandler ( "onResourceStop", _root, function ( resource )
	if ( resource ~= getThisResource() ) then
		for id, player in ipairs(getElementsByType("player")) do
			if ( hasObjectPermissionTo ( player, "general.tab_resources" ) ) then
				triggerClientEvent ( player, "aClientResourceStop", _root, getResourceName ( resource ) )
			end
		end
	else
		local node = xmlLoadFile ( "conf\\reports.xml" )
		if ( node ) then 
			local messages = 0
			while ( xmlFindChild ( node, "message", messages ) ~= false ) do
				local subnode = xmlFindChild ( node, "message", messages )
				xmlDestroyNode ( subnode )
				messages = messages + 1
			end
		else
			node = xmlCreateFile ( "conf\\reports.xml", "messages" )
		end
		for id, message in ipairs ( aReports ) do
			local subnode = xmlCreateChild ( node, "message" )
			for key, value in pairs ( message ) do
				if ( value ) then
					xmlNodeSetValue ( xmlCreateChild ( subnode, key ), tostring ( value ) )
				end
			end
		end
		xmlSaveFile ( node )
		xmlUnloadFile ( node )
	end
	aclSave ()
end )

function iif ( cond, arg1, arg2 )
	if ( cond ) then
		return arg1
	end
	return arg2
end

function getVehicleOccupants ( vehicle )
	local tableOut = {}
	local seats = getVehicleMaxPassengers ( vehicle ) + 1
	for i = 0, seats do
		local passenger = getVehicleOccupant ( vehicle, i )
		if ( passenger ) then table.insert ( tableOut, passenger ) end
	end
	return tableOut
end

function isValidSerial ( serial )
	return string.gmatch ( serial, "%w%w%w%w-%w%w%w%w-%w%w%w%w-%w%w%w%w" )
end

function getWeatherNameFromID ( weather )
	return iif ( aWeathers[weather], aWeathers[weather], "Unknown" )
end

addEventHandler ( "onPlayerJoin", _root, function ()
	if ( aGetSetting ( "welcome" ) ) then
		outputChatBox ( aGetSetting ( "welcome" ), source, 255, 100, 100 )
	end
	aPlayerInitialize ( source )
	for id, player in ipairs(getElementsByType("player")) do
		if ( hasObjectPermissionTo ( player, "general.adminpanel" ) ) then
			triggerClientEvent ( player, "aClientPlayerJoin", source, getPlayerIP ( source ), getPlayerUserName ( source ), getPlayerSerial ( source ), hasObjectPermissionTo ( source, "general.adminpanel" ), aPlayers[source]["country"], aPlayers[source]["countryname"] )
		end
	end
	setPedGravity ( source, getGravity() )
end )

function aPlayerInitialize ( player )
	aPlayers[player] = {}
	aPlayers[player]["country"] = getPlayerCountry ( player )
	aPlayers[player]["countryname"] = getPlayerCountryName ( player )
	aPlayers[player]["money"] = getPlayerMoney ( player )
end

addEventHandler ( "onPlayerLogin", _root, function ( previous, account, auto )
	if ( hasObjectPermissionTo ( source, "general.adminpanel" ) ) then
        if ( aPlayers[source]["aClientInitialized"] ) then
    		triggerEvent ( "aPermissions", source )
        end
	end
end )

function aAction ( type, action, admin, player, data, more )
	if ( aLogMessages[type] ) then
		function aStripString ( string )
			string = tostring ( string )
			string = string.gsub ( string, "$admin", getPlayerName ( admin ) )
			string = string.gsub ( string, "$data2", more or "" )
			if ( player ) then string = string.gsub ( string, "$player", getPlayerName ( player ) ) end
			return tostring ( string.gsub ( string, "$data", data or "" ) )
		end
		local node = aLogMessages[type][action]
		if ( node ) then
			local r, g, b = node["r"], node["g"], node["b"]
			if ( node["all"] ) then outputChatBox ( aStripString ( node["all"] ), _root, r, g, b ) end
			if ( node["admin"] ) and ( admin ~= player ) then outputChatBox ( aStripString ( node["admin"] ), admin, r, g, b ) end
			if ( node["player"] ) then outputChatBox ( aStripString ( node["player"] ), player, r, g, b ) end
			if ( node["log"] ) then outputServerLog ( aStripString ( node["log"] ) ) end
		end
	end
end

addEvent ( "aTeam", true )
addEventHandler ( "aTeam", _root, function ( action, name, ... )
	if ( hasObjectPermissionTo ( source, "command."..action ) ) then
		local func = aFunctions.team[action]
		if ( func ) then
			local result, mdata1, mdata2 = func ( name, ... )
			if ( result ~= false ) then
				if ( type ( result ) == "string" ) then action = result end
				aAction ( "team", action, source, false, mdata1, mdata2 ) 
			end
		end
	else
		outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	end
end )

addEvent ( "aAdmin", true )
addEventHandler ( "aAdmin", _root, function ( action, ... )
	local mdata = ""
	local mdata2 = ""
	if ( action == "password" ) then
		action = nil
		if ( not arg[1] ) then outputChatBox ( "Error - Password missing.", source, 255, 0, 0 )
		elseif ( not arg[2] ) then outputChatBox ( "Error - New password missing.", source, 255, 0, 0 )
		elseif ( not arg[3] ) then outputChatBox ( "Error - Confirm password.", source, 255, 0, 0 )
		elseif ( tostring ( arg[2] ) ~= tostring ( arg[3] ) ) then outputChatBox ( "Error - Passwords do not match.", source, 255, 0, 0 )
		else
			local account = getAccount ( getPlayerUserName ( source ), tostring ( arg[1] ) )
			if ( account ) then
				action = "password"
				setAccountPassword ( account, arg[2] )
				mdata = arg[2]
			else
				outputChatBox ( "Error - Invalid password.", source, 255, 0, 0 )
			end
		end
	elseif ( action == "autologin" ) then

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
		elseif ( type == "aclrights" ) then
			local acl = aclGet ( tostring ( arg[2] ) )
			if ( acl ) then
				tableOut["name"] = arg[2]
				tableOut["rights"] = {}
				for id, name in ipairs ( aclListRights ( acl ) ) do
					tableOut["rights"][name] = aclGetRight ( acl, name )
				end
			end
		end
		triggerClientEvent ( source, "aAdminACL", _root, type, tableOut )
	elseif ( action == "aclcreate" ) then
		local name = arg[2]
		if ( ( name ) and ( string.len ( name ) >= 1 ) ) then
			if ( arg[1] == "group" ) then
				mdata = "Group "..name
				if ( not aclCreateGroup ( name ) ) then
					action = nil
				end
			elseif ( arg[1] == "acl" ) then
				mdata = "ACL "..name
				if ( not aclCreate ( name ) ) then
					action = nil
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
			else
				action = nil
			end
		elseif ( arg[1] == "acl" ) then
			if ( aclGet ( name ) ) then
				mdata = "ACL "..name
				aclDestroy ( aclGet ( name ) )
			else
				action = nil
			end
		end
		triggerEvent ( "aAdmin", source, "sync", "aclgroups" )
	elseif ( action == "acladd" ) then
		if ( arg[3] ) then
			action = action
			mdata = "Group '"..arg[2].."'"
			if ( arg[1] == "object" ) then
				local group = aclGetGroup ( arg[2] )
				local object = arg[3]
				if ( not aclGroupAddObject ( group, object ) ) then
					action = nil
					outputChatBox ( "Error adding object '"..tostring ( object ).."' to group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "Object '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
				end
			elseif ( arg[1] == "acl" ) then
				local group = aclGetGroup ( arg[2] )
				local acl = aclGet ( arg[3] )
				if ( not aclGroupAddACL ( group, acl ) ) then
					action = nil
					outputChatBox ( "Error adding ACL '"..tostring ( arg[3] ).."' to group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "ACL '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
				end
			elseif ( arg[1] == "right" ) then
				local acl = aclGet ( arg[2] )
				local right = arg[3]
			end
		else
			action = nil
		end
	elseif ( action == "aclremove" ) then
		--action = nil
		if ( arg[3] ) then
			action = action
			mdata = "Group '"..arg[2].."'"
			if ( arg[1] == "object" ) then
				local group = aclGetGroup ( arg[2] )
				local object = arg[3]
				if ( not aclGroupRemoveObject ( group, object ) ) then
					action = nil
					outputChatBox ( "Error - object '"..tostring ( object ).."' does not exist in group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "Object '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
				end
			elseif ( arg[1] == "acl" ) then
				local group = aclGetGroup ( arg[2] )
				local acl = aclGet ( arg[3] )
				if ( not aclGroupRemoveACL ( group, acl ) ) then
					action = nil
					outputChatBox ( "Error - ACL '"..tostring ( arg[3] ).."' does not exist in group '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata2 = "ACL '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclobjects", arg[2] )
				end
			elseif ( arg[1] == "right" ) then
				local acl = aclGet ( arg[2] )
				local right = arg[3]
				if ( not aclRemoveRight ( acl, right ) ) then
					action = nil
					outputChatBox ( "Error - right '"..tostring ( arg[3] ).."' does not exist in ACL '"..tostring ( arg[2] ).."'", source, 255, 0, 0 )
				else
					mdata = "ACL '"..arg[2].."'"
					mdata2 = "Right '"..arg[3].."'"
					triggerEvent ( "aAdmin", source, "sync", "aclrights", arg[2] )
				end
			end
		else
			action = nil
		end
	end
	if ( action ~= nil ) then aAction ( "admin", action, source, false, mdata, mdata2 ) end
end )

addEvent ( "aPlayer", true )
addEventHandler ( "aPlayer", _root, function ( player, action, ... )
	if ( hasObjectPermissionTo ( source, "command."..action ) ) then
		local mdata1 = ""
		local mdata2 = ""
		local func = aFunctions.player[action]
		if ( func ) then
			local result = nil
			result, mdata1, mdata2 = func ( player, ... )
			if ( result ~= false ) then
				if ( type ( result ) == "string" ) then action = result end
				aAction ( "player", action, source, player, mdata1, mdata2 )
			end
		end
	else
		outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	end
end )

addEvent ( "aVehicle", true )
addEventHandler ( "aVehicle", _root, function ( player, action, ... )
	if ( not player ) then return end
	local vehicle = getPedOccupiedVehicle ( player )
	if ( not vehicle ) then
		return
	end
	if ( hasObjectPermissionTo ( source, "command."..action ) ) then
		local mdata1 = ""
		local mdata2 = ""
		local func = aFunctions.vehicle[action]
		if ( func ) then
			local result = nil
			result, mdata1, mdata2 = func ( player, vehicle, ... )
			if ( result ~= false ) then
				if ( type ( result ) == "string" ) then action = result end
				local seats = getVehicleMaxPassengers ( vehicle ) + 1
				for i = 0, seats do
					local passenger = getVehicleOccupant ( vehicle, i )
					if ( passenger ) then
						if ( ( passenger == player ) and ( getPedOccupiedVehicle ( source ) ~= vehicle ) ) then aAction ( "vehicle", action, source, passenger, mdata )
   						else aAction ( "vehicle", action, passenger, passenger, mdata1, mdata2 ) end
					end
				end
			end
		end
	else
		outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	end
end )

addEvent ( "aResource", true )
addEventHandler ( "aResource", _root, function ( name, action, ... )
	if ( not name or not action ) then
		return
	end
	local resource = getResourceFromName ( name )
	if ( not resource ) then
		return
	end
	if ( hasObjectPermissionTo ( source, "command."..action ) ) then
		local func = aFunctions.resource[action]
		if ( func ) then
			local result, mdata1, mdata2 = func ( resource, ... )
			if ( result ~= false ) then
				if ( type ( result ) == "string" ) then action = result end
				aAction ( "resource", action, source, player, mdata1, mdata2 )
			end
		end
	else
		outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	end
end )

addEvent ( "aServer", true )
addEventHandler ( "aServer", _root, function ( action, ... )
	if ( hasObjectPermissionTo ( source, "command."..action ) ) then
		local func = aFunctions.server[action]
		if ( func ) then
			local result, mdata1, mdata2 = func ( ... )
			if ( result ~= false ) then
				if ( type ( result ) == "string" ) then action = result end
				aAction ( "server", action, source, player, mdata1, mdata2 )
			end
		end
	else
		outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	end
end )

addEvent ( "aMessage", true )
addEventHandler ( "aMessage", _root, function ( action, data )
	if ( action == "new" ) then
		local time = getRealTime()
		local id = #aReports + 1
		aReports[id] = {}
		aReports[id].author = getPlayerName ( source )
		aReports[id].category = tostring ( data.category )
		aReports[id].subject = tostring ( data.subject )
		aReports[id].text = tostring ( data.message )
		aReports[id].time = time.monthday.."/"..time.month.." "..time.hour..":"..time.minute
		aReports[id].read = false
	elseif ( action == "get" ) then
		triggerClientEvent ( source, "aMessage", source, "get", aReports )
	elseif ( action == "read" ) then
		if ( aReports[data] ) then
			aReports[data].read = true
		end
	elseif ( action == "delete" ) then
		if ( aReports[data] ) then
			table.remove ( aReports, data )
		end
		triggerClientEvent ( source, "aMessage", source, "get", aReports )
	else
		action = nil
	end
	for id, p in ipairs ( getElementsByType ( "player" ) ) do
		if ( hasObjectPermissionTo ( p, "general.adminpanel" ) ) then triggerEvent ( "aSync", p, "messages" ) end
	end
end )

addEvent ( "aBans", true )
addEventHandler ( "aBans", _root, function ( action, data )
	if ( hasObjectPermissionTo ( source, "command."..action ) ) then
		local mdata = ""
		local more = ""
		if ( action == "banip" ) then
			mdata = data
			if ( not BanIP ( data, source ) ) then
				action = nil
			end
		elseif ( action == "banserial" ) then
			mdata = data
			if ( isValidSerial ( data ) ) then
				if ( not BanSerial ( string.upper ( data ), source ) ) then
					action = nil
				end
			else
				outputChatBox ( "Error - Invalid serial", source, 255, 0, 0 )
				action = nil
			end
		elseif ( action == "unbanip" ) then
			mdata = data
			if ( not UnbanIP ( data, source ) ) then
				action = nil
			end
		elseif ( action == "unbanserial" ) then
			mdata = data
			if ( not UnbanSerial ( data, source ) ) then
				action = nil
			end
		else
			action = nil
		end
	
		if ( action ~= nil ) then
			aAction ( "bans", action, source, false, mdata, more )
			triggerEvent ( "aSync", source, "sync", "bans" )
		end
		return true
	end
	outputChatBox ( "Access denied for '"..tostring ( action ).."'", source, 255, 168, 0 )
	return false
end )

addEvent ( "aExecute", true )
addEventHandler ( "aExecute", _root, function ( action, echo )
	if ( hasObjectPermissionTo ( source, "command.execute" ) ) then 
		local result = loadstring("return " .. action)()
		if ( echo == true ) then
			local restring = ""
			if ( type ( result ) == "table" ) then
				for k,v in pairs ( result ) do restring = restring..tostring ( v )..", " end
				restring = string.sub(restring,1,-3)
				restring = "Table ("..restring..")"
			elseif ( type ( result ) == "userdata" ) then
				restring = "Element ("..getElementType ( result )..")"
			else
				restring = tostring ( result )
			end
			outputChatBox( "Command executed! Result: " ..restring, source, 0, 0, 255 )
		end
		outputServerLog ( "ADMIN: "..getPlayerName ( source ).." executed command: "..action )
	end
end )

addEvent ( "aAdminChat", true )
addEventHandler ( "aAdminChat", _root, function ( chat )
	for id, player in ipairs(getElementsByType("player")) do
		if ( aPlayers[player]["chat"] ) then
			triggerClientEvent ( player, "aClientAdminChat", source, chat )
		end
	end
end )

addEvent ( "aClientInitialized", true )
addEventHandler ( "aClientInitialized", _root, function ()
    if ( aPlayers[source] ) then
        aPlayers[source]["aClientInitialized"] = true
    end
end )

function UnbanIP ( IP, responsible )
	local bans = getBans()
	for k,v in ipairs(bans) do
		if (getBanIP(v) == IP) then
			return removeBan(v, responsible)
		end
	end
	return false
end
function UnbanSerial ( IP, responsible )
	local bans = getBans()
	for k,v in ipairs(bans) do
		if (getBanSerial(v) == IP) then
			return removeBan(v, responsible)
		end
	end
	return false
end
function UnbanPlayer ( playerName, responsible )
	local bans = getBans()
	for k,v in ipairs(bans) do
		if (getBanUsername(v) == playername) then
			return removeBan(v, responsible)
		end
	end
end
function banPlayer ( playerName, responsible )
	return addBan(nil, playerName, nil, responsible)
end
function BanIP ( IP, responsible )
	return addBan(IP, nil, nil, responsible)
end
function BanSerial ( Serial, responsible )
	return addBan(nil, nil, Serial, responsible)
end

function warpPlayer ( p, to )
	function warp ( p, to )
		local x, y, z = getElementPosition ( to )
		local r = getPedRotation ( to )
		x = x - math.sin ( math.rad ( r ) ) * 2
		y = y + math.cos ( math.rad ( r ) ) * 2
		setTimer ( setElementPosition, 1000, 1, p, x, y, z + 1 )
		fadeCamera ( p, false, 1, 0, 0, 0 )
		setElementDimension ( p, getElementDimension ( to ) )
		setElementInterior ( p, getElementInterior ( to ) )
		setTimer ( fadeCamera, 1000, 1, p, true, 1 )
	end
  	if ( isPedInVehicle ( to ) ) then
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
