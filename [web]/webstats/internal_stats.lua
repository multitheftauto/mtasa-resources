call(getThisResource(), "registerStat", getThisResource(), "getVehicleCount", "Vehicles", "The number of vehicles")
function getVehicleCount()
	return #getElementsByType("vehicle");
end

call(getThisResource(), "registerStat", getThisResource(), "getObjectCount", "Objects", "The number of objects")
function getObjectCount()
	return #getElementsByType("object");
end

call(getThisResource(), "registerStat", getThisResource(), "getPlayerCount", "Players", "The number of players")

call(getThisResource(), "registerStat", getThisResource(), "getBlipCount", "Blips", "The number of blips")
function getBlipCount()
	return #getElementsByType("blip");
end

call(getThisResource(), "registerStat", getThisResource(), "getMarkerCount", "Markers", "The number of markers")
function getMarkerCount()
	return #getElementsByType("marker");
end

call(getThisResource(), "registerStat", getThisResource(), "getPickupCount", "Pickups", "The number of pickups")
function getPickupCount()
	return #getElementsByType("pickup");
end

publichatcount = 0
teamchatcount = 0
totalchatcount = 0
addEventHandler ( "onPlayerChat",  getRootElement(),
	function(message,messageType)
		if messageType == 0 or messageType == 1 then
			publichatcount = publichatcount + 1
		else
			teamchatcount = teamchatcount + 1
		end
		totalchatcount = totalchatcount + 1
	end
)

call(getThisResource(), "registerStat", getThisResource(), "getPublicChatCount", "Public Chat Count", "The number of lines of public chat")
function getPublicChatCount()
	local ret = publichatcount;
	publichatcount = 0;
	return ret;
end

call(getThisResource(), "registerStat", getThisResource(), "getTeamChatCount", "Team Chat Count", "The number of lines of team chat")
function getTeamChatCount()
	local ret = teamchatcount;
	teamchatcount = 0;
	return ret;
end

call(getThisResource(), "registerStat", getThisResource(), "getChatCount", "Chat Count", "The number of lines of chat")
function getChatCount()
	local ret = totalchatcount;
	totalchatcount = 0;
	return ret;
end

call(getThisResource(), "registerStat", getThisResource(), "getDamageCount", "Damage Given", "The amount of damage players have taken")
damagecount = 0
addEventHandler ( "onPlayerDamage",  getRootElement(),
	function( attacker, attackerweapon, bodypart, loss )
		damagecount = damagecount + loss
	end
)

function getDamageCount()
	local ret = damagecount;
	damagecount = 0;
	return ret;
end

call(getThisResource(), "registerStat", getThisResource(), "getVehiclesWastedCount", "Vehicles Wasted", "The number of vehicles destroyed")
vehicleswasted = 0
addEventHandler ( "onVehicleExplode",  getRootElement(),
	function(  )
		vehicleswasted = vehicleswasted + 1
	end
)

function getVehiclesWastedCount()
	local ret = vehicleswasted;
	vehicleswasted = 0;
	return ret;
end
