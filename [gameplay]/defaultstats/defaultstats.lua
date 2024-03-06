local statsTable = {
	[69] = 500,  -- Pistol
	[70] = 999,  -- Silenced pistol
	[71] = 999,  -- Desert eagle
	[72] = 999,  -- Shotgun
	[73] = 500,  -- Sawnoff, 999 for duel wield
	[74] = 999,  -- Spas-12
	[75] = 500,  -- Micro-uzi & Tec-9, 999 for duel wield
	[76] = 999,  -- MP5
	[77] = 999,  -- AK-47
	[78] = 999,  -- M4
	[79] = 999,  -- Sniper rifle & country rifle
	[160] = 999, -- Driving
	[229] = 999, -- Biking
	[230] = 999  -- Cycling
}

local function applyStatsForPlayer(playerElement)
	for statName, statValue in pairs(statsTable) do
		setPedStat(playerElement, statName, statValue)
	end
end

local function applyStatsForSource()
	applyStatsForPlayer(source)
end
addEventHandler("onPlayerJoin", root, applyStatsForSource)

local function applyStatsForEveryone(loadedResource)
	local resourceType = getResourceInfo(loadedResource, "type")
	local isGamemodeResource = resourceType == "gamemode"
	local isMapResource = resourceType == "map"
	
	if not (loadedResource == resource or isGamemodeResource or isMapResource) then return end

	local playersTable = getElementsByType("player")

	for playerID = 1, #playersTable do
		applyStatsForPlayer(playersTable[playerID])
	end
end
addEventHandler("onResourceStart", root, applyStatsForEveryone)
addEventHandler("onGamemodeMapStart", root, applyStatsForEveryone)
