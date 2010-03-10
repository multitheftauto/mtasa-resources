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
	if checkClient( source, 'aSync', type ) then return end
	local tableOut = {}
	local theSource = _root
	if ( type == "player" ) then
		if not isElement( data ) then return end
		aPlayers[source]["sync"] = data
		tableOut["mute"] = isPlayerMuted ( data )
		tableOut["freeze"] = isPlayerFrozen ( data )
		tableOut["money"] = getPlayerMoney ( data )
		tableOut["username"] = getPlayerUserName ( data ) or "N/A"
		tableOut["version"] = aPlayers[data]["version"]
		tableOut["accountname"] = getPlayerAccountName ( data ) or "N/A"
		tableOut["groups"] = "None"
		local account = getPlayerAccount ( data )
		if ( isGuestAccount ( account ) ) then
			tableOut["groups"] = "Not logged in"
		else
			local groups = aclGetAccountGroups ( account )
			if ( #groups <= 0 ) then
				tableOut["groups"] = "None"
			else
				tableOut["groups"] = table.concat(table.reverse(groups), ", ")
			end
		end
		theSource = data
	elseif ( type == "players" ) then
		for id, player in ipairs(getElementsByType("player")) do
			if aPlayers[player] then
				tableOut[player] = {}
				tableOut[player]["name"] = getPlayerName ( player )
				tableOut[player]["IP"] = getPlayerIP ( player )
				tableOut[player]["username"] = getPlayerUserName ( player ) or "N/A"
				tableOut[player]["version"] = aPlayers[player]["version"]
				tableOut[player]["accountname"] = getPlayerAccountName ( player ) or "N/A"
				tableOut[player]["serial"] = getPlayerSerial ( player )
				tableOut[player]["country"] = aPlayers[player]["country"]
				tableOut[player]["admin"] = hasObjectPermissionTo ( player, "general.adminpanel" )
			end
		end
	elseif ( type == "resources" ) then
		local resourceTable = getResources()
		for id, resource in ipairs(resourceTable) do
			local name = getResourceName ( resource )
			local state = getResourceState ( resource )
			local type = getResourceInfo ( resource, "type" )
			local numsettings = 0
			for k,v in pairs(aGetResourceSettings(name)) do numsettings = numsettings + 1 end
			tableOut[id] = {}
			tableOut[id]["name"] = name
			tableOut[id]["numsettings"] = numsettings
			tableOut[id]["state"] = state
			tableOut[id]["type"] = type
		end
	elseif ( type == "admins" ) then
		for id, player in ipairs(getElementsByType("player")) do
			if aPlayers[player] then
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
						tableOut[player]["groups"] = table.concat(table.reverse(groups), ", ")
					end
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
	elseif ( type == "bansdirty" ) then
		tableOut = nil
		g_Bans = nil
	elseif ( type == "bans" or type == "bansmore" ) then
		if not g_Bans then
			local bans = getBans()
			g_Bans = {}
			-- Reverse
			for i = #bans,1,-1 do
				table.insert( g_Bans, bans[i] )
			end
		end
		local from = ( tonumber( data ) or 0 ) + 1
		local to = math.min( from+14, #g_Bans )
		tableOut.total = #g_Bans
		for b=from,to do
			i = b - from + 1
			ban = g_Bans[b]
			local seconds = getBanTime(ban)
			tableOut[i] = {}
			tableOut[i].nick = getBanUsername(ban) or getBanNick(ban)
			tableOut[i].seconds = seconds
			tableOut[i].banner = getBanAdmin(ban)
			tableOut[i].ip = getBanIP(ban)
			tableOut[i].serial = getBanSerial(ban)
			tableOut[i].reason = getBanReason(ban)
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

addEvent ( "onPlayerMoneyChange", false )
addEventHandler ( "onResourceStart", getResourceRootElement ( getThisResource () ), function()
	setTimer ( function()
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			if aPlayers[player] then
				local money = getPlayerMoney ( player )
				local prev = aPlayers[player]["money"]
				if ( money ~= prev ) then
					triggerEvent ( "onPlayerMoneyChange", player, prev, money )
					aPlayers[player]["money"] = money
				end
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
	if checkClient( source, 'aPermissions' ) then return end
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

addEventHandler ( "onBan", _root,
	function()
		setTimer( triggerEvent, 200, 1, "aSync", _root, "bansdirty" )
	end
)

addEventHandler ( "onUnban", _root,
	function()
		setTimer( triggerEvent, 200, 1, "aSync", _root, "bansdirty" )
	end
)

function table.reverse(t)
	local newt = {}
	for idx,item in ipairs(t) do
		newt[#t - idx + 1] = item
	end
	return newt
end

function table.cmp(t1, t2)
	if not t1 or not t2 or #t1 ~= #t2 then
		return false
	end
	for k,v in pairs(t1) do
		if v ~= t2[k] then
			return false
		end
	end
	return true
end
