_playerStates = {} -- lookup table for player states (see shared/shared.lua)
_respawnTimers = {} -- lookup table for respawn timers

-- default map settings
local defaults = {
	fragLimit = 10, -- TODO: this should be 10
	timeLimit = 600, --10 minutes
	respawnTime = 10,
	spawnWeapons = "22:100", -- "weaponID:ammo,weaponID:ammmo"
}

--
--	startDeathmatchMode: initializes the deathmatch gamemode
--
local function startDeathmatchMode()
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_WAITING)
	-- set default player state on gamemode start (clients will report in when ready)
	for _, player in ipairs(getElementsByType("player")) do
		_playerStates[player] = PLAYER_JOINED
	end
end
addEventHandler("onGamemodeStart", resourceRoot, startDeathmatchMode)

--
--	stopDeathmatchMode: cleans up the deathmatch gamemode
--
local function stopDeathmatchMode()
	-- cleanup player score data, make sure scoreboard isn't forced
	for _, player in ipairs(getElementsByType("player")) do
		removeElementData(player, "Score")
		removeElementData(player, "Rank")
	end
end
addEventHandler("onGamemodeStop", resourceRoot, stopDeathmatchMode)

--
--	startDeathmatchMap: initializes a deathmatch map
--
local function startDeathmatchMap(resource)
	-- load map settings
	_mapResource = resource
	local resourceName = getResourceName(resource)
	_fragLimit = tonumber(get(resourceName..".frag_limit")) and math.floor(tonumber(get(resourceName..".frag_limit"))) or defaults.fragLimit
	_timeLimit  = (tonumber(get(resourceName..".time_limit")) and math.floor(tonumber(get(resourceName..".time_limit"))) or defaults.timeLimit)*1000
	_respawnTime = (tonumber(get(resourceName..".respawn_time")) and math.floor(tonumber(get(resourceName..".respawn_time"))) or defaults.respawnTime)*1000
	-- use a default frag and time limit if both are zero (infinite)
	if _fragLimit == 0 and _timeLimit == 0 then
		outputDebugString("deathmatch: map frag_limit and time_limit both disabled; using default values", 2)
		_fragLimit = defaults.fragLimit
		_timeLimit = defaults.timeLimit
	end
	_spawnWeapons = {}
	local weaponsString = get(resourceName..".spawn_weapons") or defaults.spawnWeapons
	for _, weaponSub in ipairs(split(weaponsString, 44)) do
		local weapon = tonumber(gettok(weaponSub, 1, 58))
		local ammo = tonumber(gettok(weaponSub, 2, 58))
		if weapon and ammo then
			_spawnWeapons[weapon] = ammo
		end
	end
	-- if the map title is not defined in the map's meta.xml, use the resource name
	_mapTitle = getResourceInfo(resource, "name")
	if not _mapTitle then
		_mapTitle = resourceName
	end
	_mapAuthor = getResourceInfo(resource, "author")
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_STARTING)
	-- inform all ready players that the game is about to start
	for player, state in pairs(_playerStates) do
		if state == PLAYER_READY then
			triggerClientEvent(player, "onClientDeathmatchMapStart", resourceRoot, _mapTitle, _mapAuthor, _fragLimit, _respawnTime)
		end
	end
	-- schedule round to begin
	setTimer(beginRound, CAMERA_LOAD_DELAY, 1)
end
addEventHandler("onGamemodeMapStart", root, startDeathmatchMap)

--
--	stopDeathmatchMap: cleans up a deathmatch map
--
local function stopDeathmatchMap(resource)
	-- end the round
	endRound(false, false, true)
	-- update game state
	setElementData(resourceRoot, "gameState", GAME_WAITING)
	-- inform all clients that the map was stopped
	for player, state in pairs(_playerStates) do
		if state ~= PLAYER_JOINED then
			triggerClientEvent(player, "onClientDeathmatchMapStop", resourceRoot)
		end
	end
end
addEventHandler("onGamemodeMapStop", root, stopDeathmatchMap)

--
--	calculatePlayerRanks: calculates player ranks
--
function calculatePlayerRanks()
	local ranks = {}
	local players = getElementsByType("player")
	table.sort(players, scoreSortingFunction)
	--Take into account people with the same score
	for i = 1, #players do
		if players[i-1] then
			local previousScore = getElementData(players[i-1], "Score")
			local playerScore = getElementData(players[i], "Score")
			if previousScore == playerScore then
				setElementData (players[i], "Rank", getElementData(players[i-1], "Rank"))
			else
				setElementData (players[i], "Rank", i)
			end
		else
			setElementData(players[i], "Rank", 1)
		end
	end
end
