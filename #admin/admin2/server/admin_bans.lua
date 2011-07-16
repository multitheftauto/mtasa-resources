--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_bans.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aBans = {
	List = {}
}

addEventHandler ( "onResourceStart", _local, function ()
	for i, ban in ipairs ( getBans () ) do
		aBans.List[aBans.GenerateID ( ban )] = ban
	end
end )

addEventHandler ( "onBan", _root, function ( ban )
	local id = aBans.GenerateID ( ban )
	aBans.List[id] = ban

	data = {
		type = "a",
		id = id,
		ban = getBanData ( ban )
	}

	aSyncData ( nil, "ban", _root, data, "command.listbans" )
end )

addEventHandler ( "onPlayerBan", _root, function ( ban )
	local id = aBans.GenerateID ( ban )
	aBans.List[id] = ban

	data = {
		type = "a",
		id = id,
		ban = getBanData ( ban )
	}

	aSyncData ( nil, "ban", _root, data, "command.listbans" )
end )

addEventHandler ( "onUnban", _root, function ( ban )
	for id, b in pairs ( aBans.List ) do
		if ( b == ban ) then

			data = {
				type = "d",
				id = id
			}

			aSyncData ( nil, "ban", _root, data, "command.listbans" )

			aBans.List[id] = nil
		end
	end
end )

function aBans.GenerateID ( ban )
	local id = getBanTime ( ban )
	if ( not id or id == 0 ) then
		id = math.random ( 1, 1000000 )
	end
	while ( aBans.List[id] ) do
		id = id + 1
	end
	return tostring ( id )
end

function getBansList ()
	return aBans.List
end

function getBanData ( ban )
	t = {}

	t.nick = getBanNick ( ban ) or nil
	t.ip = getBanIP ( ban ) or nil
	t.serial = getBanSerial ( ban ) or nil
	t.username = getBanUsername ( ban ) or nil
	t.banner = getBanAdmin ( ban ) or nil
	t.reason = getBanReason ( ban ) or nil
	t.time = getBanTime ( ban ) or nil
	t.unban = getUnbanTime ( ban ) or nil
	if ( not t.unban or not t.time or t.unban <= t.time ) then
		t.unban = nil
	end

	return t
end