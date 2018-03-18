function players()
	local players = getElementsByType("player")
	local tbl = {}
	for k,v in ipairs(players) do
		local x,y = getElementPosition(v)
		local playerinfo = {name=getPlayerName(v), pos={x=x,y=y}, isdead=isPedDead(v)}
		if ( isPedInVehicle(v) ) then
			playerinfo.vehicle = getVehicleName(getPedOccupiedVehicle(v))
		end
		table.insert(tbl, playerinfo)
	end
	return tbl
end

function sendPlayerMessage(playername, message)
	local player = getPlayerFromName(playername)
	if ( player ) then
		outputChatBox("<webmap> " .. message, player)
	end
end

function getAllBlips()
	local tbl = {}
	local blips = getElementsByType("blip")
	for k,v in ipairs(blips) do
		local x,y = getElementPosition(v)
		table.insert(tbl, {element=v, icon=getBlipIcon(v), pos={x=x,y=y}})
	end
	return tbl
end
