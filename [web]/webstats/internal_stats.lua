local publichatcount = 0
local teamchatcount = 0
local totalchatcount = 0
local vehicleswasted = 0
local damagecount = 0

registerStat(resource, "getVehicleCount", "Vehicles", "The number of vehicles")
function getVehicleCount()
	return #getElementsByType("vehicle")
end

registerStat(resource, "getObjectCount", "Objects", "The number of objects")
function getObjectCount()
	return #getElementsByType("object")
end

registerStat(resource, "getPlayerCount", "Players", "The number of players")
function getPlayerCount()
	return #getElementsByType("player")
end

registerStat(resource, "getBlipCount", "Blips", "The number of blips")
function getBlipCount()
	return #getElementsByType("blip")
end

registerStat(resource, "getMarkerCount", "Markers", "The number of markers")
function getMarkerCount()
	return #getElementsByType("marker")
end

registerStat(resource, "getPickupCount", "Pickups", "The number of pickups")
function getPickupCount()
	return #getElementsByType("pickup")
end

registerStat(resource, "getPublicChatCount", "Public Chat Count", "The number of lines of public chat")
addEventHandler("onPlayerChat", root, function (message, messageType)
	if (messageType == 0) or (messageType == 1) then
		publichatcount = publichatcount + 1
	else
		teamchatcount = teamchatcount + 1
	end
	totalchatcount = totalchatcount + 1
end)

function getPublicChatCount()
	local ret = publichatcount
	publichatcount = 0
	return ret
end

registerStat(resource, "getTeamChatCount", "Team Chat Count", "The number of lines of team chat")
function getTeamChatCount()
	local ret = teamchatcount
	teamchatcount = 0
	return ret
end

registerStat(resource, "getChatCount", "Chat Count", "The number of lines of chat")
function getChatCount()
	local ret = totalchatcount
	totalchatcount = 0
	return ret
end

registerStat(resource, "getDamageCount", "Damage Given", "The amount of damage players have taken")
addEventHandler("onPlayerDamage", root, function (_, _, _, loss)
	damagecount = damagecount + loss
end)

function getDamageCount()
	local ret = damagecount
	damagecount = 0
	return ret
end

registerStat(resource, "getVehiclesWastedCount", "Vehicles Wasted", "The number of vehicles destroyed")
addEventHandler("onVehicleExplode", root, function ()
	vehicleswasted = vehicleswasted + 1
end)

function getVehiclesWastedCount()
	local ret = vehicleswasted
	vehicleswasted = 0
	return ret
end
