-- TO DO:
--  have it take your camera to a pretty place when game is idle or you're not on team

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FFA SPAWN --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- players become spectators when the game ends

function init_ffaSpawn()
	for i,v in ipairs(getElementsByType("player")) do
		spawnPlayerAtRandomSpawnpoint(v)
		-- make sure they are not a spectator (this could happen if the last game just ended and the game mode didn't restart)
		setTimer(removeSpectator, 4500, 1, v)
	end
	addEventHandler("onPlayerJoin", root, onPlayerJoin_spawnffa)
	addEventHandler("onPlayerWasted", root, onPlayerWasted_spawnffa)
end

function end_ffaSpawn()
	removeEventHandler("onPlayerJoin", root, onPlayerJoin_spawnffa)
	removeEventHandler("onPlayerWasted", root, onPlayerWasted_spawnffa)
	-- make everyone a spectator
	for i,v in ipairs(getElementsByType("player")) do
		if (not isPedDead(v)) then
			killPed(v)
		end
		if (not exports.spectator:isSpectator(v)) then
			exports.spectator:addSpectator(v)
		end
	end
end

function onPlayerJoin_spawnffa()
	spawnPlayerAtRandomSpawnpoint(source)
end

function onPlayerWasted_spawnffa()
	setTimer(spawnPlayerAtRandomSpawnpoint, 3000, 1, source)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEAM SPAWN --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- client event:
--  doCreateTeamMenu
--  doShowPlayerTeamMenu

-- enable auto balance when 5+ players?

-- players become spectators whenever they are not on a team:
--  when game starts, when they join, when game ends, when they leave their team

addEvent("onPlayerTeamSelect", true)

function init_teamSpawn()
	local players = getElementsByType("player")
	-- show everyone the team selection menu
	for i,v in ipairs(players) do
		if (not isPedDead(v)) then
			killPed(v)
		end
		-- when the gamemode map resource starts, the map isn't always loaded client-side
		--  so we wait 5 seconds and hope that it is by then
		--  (This is obviously not fool-proof, and queuing it until the gm resource loads is pointless.
		--  We should queue the triggerClientEvent call until the gm map loads client-side instead, but lazy..)
		setTimer(createAndShowTeamMenuForPlayer, 5000, 1, v)
		-- make the player a spectator
		setTimer(addSpectator, 4500, 1, v)
	end
	addEventHandler("onPlayerTeamSelect", root, onPlayerTeamSelect)
	addEventHandler("onPlayerJoin", root, onPlayerJoin_spawnteam)
	addEventHandler("onPlayerWasted", root, onPlayerWasted_spawnteam)
end

-- possible error: not all players have a team menu and have a key bound (like those that just joined or if the game just started)
function end_teamSpawn()
	removeEventHandler("onPlayerTeamSelect", root, onPlayerTeamSelect)
	removeEventHandler("onPlayerJoin", root, onPlayerJoin_spawnteam)
	removeEventHandler("onPlayerWasted", root, onPlayerWasted_spawnteam)
	local players = getElementsByType("player")
	for i,v in ipairs(players) do
		scheduleClientEvent(v, "doShowPlayerTeamMenu", root, false)
		unbindKey(v, "F3", "down", toggleTeamMenu)
	end
	-- make everyone a spectator
	for i,v in ipairs(getElementsByType("player")) do
		if (not isPedDead(v)) then
			killPed(v)
		end
		addSpectator(v)
	end
end

function onPlayerJoin_spawnteam()
	setTimer(createAndShowTeamMenuForPlayer, 5000, 1, source)
	-- make the player a spectator
	if (not isPedDead(source)) then
		killPed(source)
	end
	setTimer(addSpectator, 4500, 1, source)
end

-- usually called on a timer, so check if the player is still here
function createAndShowTeamMenuForPlayer(player)
	if (isElement(player)) then
		scheduleClientEvent(player, "doCreateTeamMenu", root, getValidTeams())
		scheduleClientEvent(player, "doShowPlayerTeamMenu", root, true)
		bindKey(player, "F3", "down", toggleTeamMenu)
	end
end

function addSpectator(player)
	if (isElement(player)) then
		if (not exports.spectator:isSpectator(player)) then
			exports.spectator:addSpectator(player)
		end
	end
end

function removeSpectator(player)
	if (isElement(player)) then
		if (exports.spectator:isSpectator(player)) then
			exports.spectator:removeSpectator(player)
		end
	end
end

-- triggered by client
function onPlayerTeamSelect(team)
	if (isTeamValid(team) and (not getPlayerTeam(source) or getPlayerTeam(source) ~= team)) then
		if (not isPedDead(source)) then
			killPed(source)
		end
		local success = true
		if (isPlayerReady(source)) then
			success = setPlayerNotReady(source)
		end
		if (success) then
			if (exports.spectator:isSpectator(source)) then
				exports.spectator:removeSpectator(source)
			end
			outputChatBox(getPlayerName(source) .. " joined " .. getTeamName(team))
			if (not isPedDead(source)) then
				killPed(source)
			end
			scheduleClientEvent(source, "doShowPlayerTeamMenu", root, false)
			setPlayerTeam(source, team)
			setPlayerReady(source)
			spawnPlayerAtRandomSpawnpoint(source)
		end
	end
end

-- possible bug: player changes teams or leaves team - it spawns him twice or spawns him when it shouldn't!
-- respawn player after death
function onPlayerWasted_spawnteam()
	if (isPlayerReady(source)) then
		setTimer(spawnPlayerAtRandomSpawnpoint, 3000, 1, source)
	end
end

function toggleTeamMenu(player, key, keyState)
	scheduleClientEvent(player, "doShowPlayerTeamMenu", root, nil)
end







function spawnPlayerAtRandomSpawnpoint ( player )
    local spawnpoints = getElementsByType ( "spawnpoint" )
    local spawnpointIndex = math.random ( # spawnpoints )
    spawnPlayerAtSpawnpoint ( player, spawnpoints[spawnpointIndex] )
end

function spawnPlayerAtSpawnpoint ( player, sp )
outputServerLog("GOING TO SPWAN PLAYER!")
	setCameraTarget ( player, player ) -- added 7/8/09, as when the player joins and you spawn him it doesn't set the camera on him
	fadeCamera ( player, true )
	return call(getResourceFromName"spawnmanager","spawnPlayerAtSpawnpoint",player,sp )
end

addEventHandler("onPlayerQuit", root,
function ()
	if (exports.spectator:isSpectator(source)) then
		exports.spectator:removeSpectator(source)
	end
end
)
