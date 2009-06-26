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
	if ( type == "player" ) then
		aPlayers[source]["sync"] = data
		tableOut["mute"] = isPlayerMuted ( data )
		tableOut["freeze"] = isPlayerFrozen ( data )
		tableOut["money"] = getPlayerMoney ( data )
		theSource = data
	elseif ( type == "players" ) then
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			tableOut[player] = {}
			tableOut[player]["name"] = getPlayerName ( player )
			tableOut[player]["IP"] = getPlayerIP ( player )
			tableOut[player]["username"] = getPlayerUserName ( player )
			tableOut[player]["serial"] = getPlayerSerial ( player )
			tableOut[player]["country"] = aPlayers[player]["country"]
			tableOut[player]["admin"] = hasObjectPermissionTo ( player, "general.adminpanel" )
		end
	elseif ( type == "resources" ) then
		local resourceTable = getResources()
		for id, resource in ipairs(resourceTable) do
			local name = getResourceName ( resource )
			local state = getResourceState ( resource )
			tableOut[id] = {}
			tableOut[id].name = name
			tableOut[id].state = state
		end
	elseif ( type == "resource" ) then
		local resource = getResourceFromName ( data )
		tableOut.name = data
		tableOut.info = {}
		if ( resource ) then
			tableOut.info.name = getResourceInfo ( resource, "name" ) or nil
			tableOut.info.type = getResourceInfo ( resource, "type" ) or nil
			tableOut.info.author = getResourceInfo ( resource, "author" ) or nil
			tableOut.info.version = getResourceInfo ( resource, "version" ) or nil
			tableOut.info.description = getResourceInfo ( resource, "description" ) or nil
		end
	elseif ( type == "admins" ) then
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			tableOut[player] = {}
			tableOut[player]["admin"] = hasObjectPermissionTo ( player, "general.adminpanel" )
			if ( tableOut[player]["admin"] ) then
				tableOut[player]["chat"] = aPlayers[player]["chat"]
			end
			tableOut[player]["groups"] = "None"
			local account = getPlayerAccount ( player )
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
	elseif ( type == "server" ) then
		tableOut["name"] = getServerName()
		tableOut["players"] = getMaxPlayers()
		tableOut["game"] = getGameType()
		tableOut["map"] = getMapName()
		tableOut["password"] = getServerPassword()
	elseif ( type == "rights" ) then
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
	elseif ( type == "bans" ) then
		for id, ban in pairs ( getBansList () ) do
			tableOut[id] = getBanData ( ban )
		end
	elseif ( type == "messages" ) then
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

function aSyncData ( player, type, source, data, right )
	if ( player ) then
		triggerClientEvent ( player, "aClientSync", source, type, data )
	else
		for i, p in ipairs ( getElementsByType ( "player" ) ) do
			if ( hasObjectPermissionTo ( p, right ) ) then
				triggerClientEvent ( p, "aClientSync", source, type, data )
			end
		end
	end
end

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
		local account = "user."..getAccountName ( getPlayerAccount ( source ) )
		for gi, group in ipairs ( aclGroupList() ) do
			for oi, object in ipairs ( aclGroupListObjects ( group ) ) do
				if ( ( object == account ) or ( object == "user.*" ) ) then
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

function getMonthName ( month )
	local names = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	return names[month]
end