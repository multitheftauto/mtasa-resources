--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_sync.lua
*
*	Original File by lil_Toady
*
**************************************]]

addEvent ( "aSync", true )
addEventHandler ( "aSync", _root, function ( type, data )
	local tableOut = {}
	local theSource = _root
	if ( type == SYNC_PLAYER ) then
		aPlayers[source]["sync"] = data
		tableOut["mute"] = isPlayerMuted ( data )
		tableOut["freeze"] = isPlayerFrozen ( data )
		tableOut["money"] = getPlayerMoney ( data )
		theSource = data
	elseif ( type == SYNC_PLAYERS ) then
		for id, player in ipairs(getElementsByType("player")) do
			tableOut[player] = {}
			tableOut[player]["name"] = getClientName ( player )
			tableOut[player]["IP"] = getClientIP ( player )
			tableOut[player]["username"] = getPlayerUserName ( player )
			tableOut[player]["serial"] = getPlayerSerial ( player )
			tableOut[player]["country"] = aPlayers[player]["country"]
			tableOut[player]["admin"] = hasObjectPermissionTo ( player, "general.adminpanel" )
		end
	elseif ( type == SYNC_RESOURCES ) then
		local resourceTable = getResources()
		for id, resource in ipairs(resourceTable) do
			local name = getResourceName ( resource )
			local state = getResourceState ( resource )
			tableOut[id] = {}
			tableOut[id]["name"] = name
			tableOut[id]["state"] = state
		end
	elseif ( type == SYNC_ADMINS ) then
		for id, player in ipairs(getElementsByType("player")) do
			tableOut[player] = {}
			tableOut[player]["admin"] = hasObjectPermissionTo ( player, "general.adminpanel" )
			if ( tableOut[player]["admin"] ) then
				tableOut[player]["chat"] = aPlayers[player]["chat"]
			end
			tableOut[player]["groups"] = "None"
			local account = getClientAccount ( player )
			if ( isGuestAccount ( account ) ) then
				tableOut[player]["groups"] = "Not logged in"
			else
				local groups = aclGetAccountGroups ( account )
				if ( #groups <= 0 ) then
					tableOut[player]["groups"] = "None"
				else
					tableOut[player]["groups"] = unpack ( groups )
				end
			end
		end
	elseif ( type == SYNC_SERVER ) then
		tableOut["name"] = getServerName()
		tableOut["players"] = getMaxPlayers()
		tableOut["game"] = getGameType()
		tableOut["map"] = getMapName()
		tableOut["password"] = getServerPassword()
	elseif ( type == SYNC_RIGHTS ) then
		for gi, group in ipairs ( aclListGroups() ) do
			for oi, object in ipairs ( aclGroupListObjects ( group ) ) do
				if ( ( object == data ) or ( object == "user.*" ) ) then
					for ai, acl in ipairs ( aclGroupListACL ( group ) ) do
						for ri, right in ipairs ( aclListRights ( acl ) ) do
							local access = aclGetRight ( acl, string )
							if ( access ) then table.insert ( tableOut, right ) end
						end
					end
					break
				end
			end
		end
	elseif ( type == SYNC_BANS ) then
		local node = getBansXML()
		if ( node ) then
			tableOut["IP"] = {}
			tableOut["Serial"] = {}
			local bans = 0
			while ( xmlFindSubNode ( node, "ip", bans ) ~= false ) do
				local ban = xmlFindSubNode ( node, "ip", bans )
				local ip = xmlNodeGetAttribute ( ban, "address" )
				tableOut["IP"][ip] = {}
				local nick = xmlFindSubNode ( ban, "nick", 0 )
				local banner = xmlFindSubNode ( ban, "banner", 0 )
				local reason = xmlFindSubNode ( ban, "reason", 0 )
				local date = xmlFindSubNode ( ban, "date", 0 )
				local time = xmlFindSubNode ( ban, "time", 0 )
				if ( nick ) then tableOut["IP"][ip]["nick"] = xmlNodeGetValue ( nick ) end
				if ( banner ) then tableOut["IP"][ip]["banner"] = xmlNodeGetValue ( banner ) end
				if ( reason ) then tableOut["IP"][ip]["reason"] = xmlNodeGetValue ( reason ) end
				if ( date ) then tableOut["IP"][ip]["date"] = xmlNodeGetValue ( date ) end
				if ( time ) then tableOut["IP"][ip]["time"] = xmlNodeGetValue ( time ) end
				bans = bans + 1
			end
			local bans = 0
			while ( xmlFindSubNode ( node, "serial", bans ) ~= false ) do
				local ban = xmlFindSubNode ( node, "serial", bans )
				local serial = xmlNodeGetAttribute ( ban, "value" )
				tableOut["Serial"][serial] = {}
				local nick = xmlFindSubNode ( ban, "nick", 0 )
				local banner = xmlFindSubNode ( ban, "banner", 0 )
				local reason = xmlFindSubNode ( ban, "reason", 0 )
				local date = xmlFindSubNode ( ban, "date", 0 )
				local time = xmlFindSubNode ( ban, "time", 0 )
				if ( nick ) then tableOut["Serial"][serial]["nick"] = xmlNodeGetValue ( nick ) end
				if ( banner ) then tableOut["Serial"][serial]["banner"] = xmlNodeGetValue ( banner ) end
				if ( reason ) then tableOut["Serial"][serial]["reason"] = xmlNodeGetValue ( reason ) end
				if ( date ) then tableOut["Serial"][serial]["date"] = xmlNodeGetValue ( date ) end
				if ( time ) then tableOut["Serial"][serial]["time"] = xmlNodeGetValue ( time ) end
				bans = bans + 1
			end
		end
	elseif ( type == SYNC_MESSAGES ) then
		local unread, total = 0, 0
		for id, msg in ipairs ( aReports ) do
			if ( not msg.read ) then
				unread = unread + 1
			end
			total = total + 1
		end
		tableOut["unread"] = unread
		tableOut["total"] = total
	end
	triggerClientEvent ( source, "aClientSync", theSource, type, tableOut )
end )

addEvent ( "onPlayerMoneyChange", false )
addEventHandler ( "onResourceStart", getResourceRootElement ( getThisResource () ), function()
	setTimer ( function()
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			local money = getPlayerMoney ( player )
			local prev = aPlayers[player]["money"]
			if ( money ~= prev ) then
				triggerEvent ( "onPlayerMoneyChange", player, prev, money )
				aPlayers[player]["money"] = money
			end
		end
	end, 1500, 0 )
end )

addEventHandler ( "onPlayerMoneyChange", _root, function ( prev, new )
	for player, sync in pairs ( aPlayers ) do
		if ( sync["sync"] == source ) then
			triggerClientEvent ( player, "aClientSync", source, "player", { ["money"] = new } )
		end
	end
end )

addEventHandler ( "onPlayerMute", _root, function ( state )
	for player, sync in pairs ( aPlayers ) do
		if ( sync["sync"] == source ) then
			triggerClientEvent ( player, "aClientSync", source, "player", { ["mute"] = state } )
		end
	end
end )

addEventHandler ( "onPlayerFreeze", _root, function ( state )
	for player, sync in pairs ( aPlayers ) do
		if ( sync["sync"] == source ) then
			triggerClientEvent ( player, "aClientSync", source, "player", { ["freeze"] = state } )
		end
	end
end )

addEvent ( "aPermissions", true )
addEventHandler ( "aPermissions", _root, function()
	if ( hasObjectPermissionTo ( source, "general.adminpanel" ) ) then
		local tableOut = {}
		for gi, group in ipairs ( aclGroupList() ) do
			for oi, object in ipairs ( aclGroupListObjects ( group ) ) do
				if ( ( object == aclGetAccount ( source ) ) or ( object == "user.*" ) ) then
					for ai, acl in ipairs ( aclGroupListACL ( group ) ) do
						for ri, right in ipairs ( aclListRights ( acl ) ) do
							local access = aclGetRight ( acl, right )
							if ( access ) then table.insert ( tableOut, right ) end
						end
					end
					break
				end
			end
		end
		triggerClientEvent ( source, "aPermissions", source, tableOut )
	end
end )