CAMERA_LOAD_DELAY = 5000 -- delay used at beginning and end of round (ms)
_respawnTimers = {} -- lookup table for player respawn timers

-- default map settings
local defaults = {
	fragLimit = 1, -- TODO: this should be 10
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
	-- initalize map settings
	_mapResource = resource
	local resourceName = getResourceName(resource)
	_fragLimit = tonumber(get(resourceName..".frag_limit")) and math.floor(tonumber(get(resourceName..".frag_limit"))) or defaults.fragLimit
	_timeLimit  = (tonumber(get(resourceName..".time_limit")) and math.floor(tonumber(get(resourceName..".time_limit"))) or defaults.timeLimit)*1000
	_respawnTime = (tonumber(get(resourceName..".respawn_time")) and math.floor(tonumber(get(resourceName..".respawn_time"))) or defaults.respawnTime)*1000
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
	-- TODO: refactor these globals (?)
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
	endRound(false, false)
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
--	scoreSortingFunction: used to sort a table of players by their score
--
function scoreSortingFunction(a, b)
	return (getElementData(a, "Score") or 0) > (getElementData(b, "Score") or 0)
end

--
--	calculatePlayerRanks(): calculates player ranks
--
function calculatePlayerRanks()
	local ranks = {}
	local players = getElementsByType("player")
	table.sort(players, scoreSortingFunction)
	--Take into account people with the same score
	for i, player in ipairs(players) do
		local previousPlayer = players[i-1]
		if players[i-1] then
			local previousScore = getElementData(previousPlayer, "Score")
			local playerScore = getElementData(player, "Score")
			if previousScore == playerScore then
				setElementData (player, "Rank", getElementData(previousPlayer, "Rank"))
			else
				setElementData (player, "Rank", i)
			end
		else
			setElementData(player, "Rank", 1)
		end
	end

	-- inform ready players that scores have been updated
	for _, player in ipairs(players) do
		if _playerStates[player] ~= PLAYER_JOINED then
			triggerClientEvent(player, "onDeathmatchScoreUpdate", resourceRoot)
		end
	end
end
