--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_sync.lua
*
*	Original File by lil_Toady
*
**************************************]]

addEvent ( EVENT_SYNC, true )
addEventHandler ( EVENT_SYNC, _root, function ( type, data )
	local tableOut = {}
	local theSource = _root
	if ( type == SYNC_PLAYER ) then
		if ( not isElement( data ) ) then return end
		aPlayers[source]["sync"] = data
		tableOut["mute"] = isPlayerMuted ( data )
		tableOut["freeze"] = isPedFrozen ( data )
		tableOut["money"] = getPlayerMoney ( data )
		tableOut["version"] = getPlayerVersion ( data )
		local account = getPlayerAccount ( data )
		tableOut["account"] = getAccountName ( account )
		if ( not isGuestAccount ( account ) ) then
			local groups = aclGetAccountGroups ( account )
			if ( #groups > 0 ) then
				tableOut["groups"] = table.concat ( table.reverse ( groups ), ", " )
			end
		end
		tableOut["account"] = getAccountName ( account )
		theSource = data
	elseif ( type == SYNC_PLAYERS ) then
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			tableOut[player] = {}
			tableOut[player].ip = getPlayerIP ( player )
			tableOut[player].account = getAccountName ( getPlayerAccount ( player ) )
			tableOut[player].serial = getPlayerSerial ( player )
			tableOut[player].country = aPlayers[player]["country"]
			tableOut[player].countryname = aPlayers[player]["countryname"]
		end
	elseif ( type == SYNC_RESOURCES ) then
		tableOut = {}
		local resourceTable = getResources()
		for id, resource in ipairs ( resourceTable ) do
			local name = getResourceName ( resource )
			local state = getResourceState ( resource )
			local group = getResourceInfo ( resource, "type" ) or "misc"
			if ( not tableOut[group] ) then tableOut[group] = {} end
			table.insert ( tableOut[group], { name = name, state = state } )
		end
	elseif ( type == SYNC_RESOURCE ) then
		local resource = getResourceFromName ( data )
		tableOut.name = data
		tableOut.info = {}
		if ( resource ) then
			tableOut.info.name = getResourceInfo ( resource, "name" ) or nil
			tableOut.info.type = getResourceInfo ( resource, "type" ) or nil
			tableOut.info.author = getResourceInfo ( resource, "author" ) or nil
			tableOut.info.version = getResourceInfo ( resource, "version" ) or nil
			tableOut.info.description = getResourceInfo ( resource, "description" ) or nil
			tableOut.info.settings = getResourceSettings ( data, false )
		end
	elseif ( type == SYNC_ADMINS ) then
		for id, player in ipairs ( aPlayers ) do
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
	elseif ( type == SYNC_SERVER ) then
		tableOut["name"] = getServerName()
		tableOut["players"] = getMaxPlayers()
		tableOut["game"] = getGameType()
		tableOut["map"] = getMapName()
		tableOut["password"] = getServerPassword()
	elseif ( type == SYNC_BANS ) then
		for id, ban in pairs ( getBansList () ) do
			tableOut[id] = getBanData ( ban )
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
	triggerClientEvent ( source, EVENT_SYNC, theSource, type, tableOut )
end )

function requestSync ( player, type )
	triggerEvent ( EVENT_SYNC, player, type )
end

addEvent ( "onPlayerMuted", false )
addEvent ( "onPlayerFrozen", false )
addEvent ( "onPlayerMoneyChange", false )
addEventHandler ( "onResourceStart", getResourceRootElement ( getThisResource () ), function()
	setTimer ( function()
		for player, data in pairs ( aPlayers ) do
			local prev = false

			local money = getPlayerMoney ( player )
			prev = data.money or 0
			if ( money ~= prev ) then
				triggerEvent ( "onPlayerMoneyChange", player, prev, money )
				aPlayers[player].money = money
			end

			local frozen = isPedFrozen ( player )
			prev = data.frozen or false
			if ( frozen ~= prev ) then
				triggerEvent ( "onPlayerFrozen", player, frozen )
				aPlayers[player].frozen = frozen
			end

			local muted = isPlayerMuted ( player )
			prev = data.muted or false
			if ( muted ~= prev ) then
				triggerEvent ( "onPlayerMuted", player, muted )
				aPlayers[player].muted = muted
			end
		end
	end, 1500, 0 )
end )

addEventHandler ( "onPlayerMoneyChange", _root, function ( prev, new )
	for player, data in pairs ( aPlayers ) do
		if ( data.sync == source ) then
			triggerClientEvent ( player, EVENT_SYNC, source, SYNC_PLAYER, { ["money"] = new } )
		end
	end
end )

addEventHandler ( "onPlayerFrozen", _root, function ( state )
	for player, data in pairs ( aPlayers ) do
		if ( data.sync == source ) then
			triggerClientEvent ( player, EVENT_SYNC, source, SYNC_PLAYER, { ["freeze"] = state } )
		end
	end
end )

addEventHandler ( "onPlayerMuted", _root, function ( state )
	for player, data in pairs ( aPlayers ) do
		if ( data.sync == source ) then
			triggerClientEvent ( player, EVENT_SYNC, source, SYNC_PLAYER, { ["mute"] = state } )
		end
	end
end )