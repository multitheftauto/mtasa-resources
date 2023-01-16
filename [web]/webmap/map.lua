function getAllPlayers()
	local tbl = {}
	for _, v in ipairs(getElementsByType("player")) do
		local x, y, z = getElementPosition(v)
		local _, _, rot = getElementRotation(v)
		tbl[#tbl + 1] = {
			name = getPlayerName(v),
			pos = {
				x = x,
				y = y,
				z = z,
			},
			rot = rot,
			isdead = isPedDead(v),
		}
		if (isPedInVehicle(v)) then
			tbl[#tbl].vehicle = getVehicleName(getPedOccupiedVehicle(v))
		end
	end
	return tbl
end

function getAllRadarBlips()
	local tbl = {}
	for _, v in ipairs(getElementsByType("blip")) do
		local x, y, z = getElementPosition(v)
		tbl[#tbl + 1] = {
			element = v,
			icon = getBlipIcon(v),
			size = getBlipSize(v),
			color = {
				getBlipColor(v),
			},
			pos = {
				x = x,
				y = y,
				z = z,
			},
		}
	end
	return tbl
end

function sendPlayerMessage(playername, message)
	local player = getPlayerFromName(playername)
	if (not player) then return end
	outputServerLog("<webmap> <message sent to " .. playername .. "> " .. message, player)
	outputChatBox("<webmap> " .. message, player)
end
