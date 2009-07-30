-- TO DO:
--  have it take your camera to a pretty place when game is idle or you're not on team

--[[addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
function (resource)
	for i,v in ipairs(getElementsByType("player")) do
		fadeCamera(v, true)
	end
		outputChatBox("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
end
)

addEventHandler("onPlayerJoin", root,
function ()
	fadeCamera(source, true)
end
)]]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FFA SPAWN --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- players see cam view when the game ends

local ffaStarted = false

function init_ffaSpawn()
	for i,v in ipairs(getElementsByType("player")) do
		spawnPlayerAtRandomSpawnpoint(v)
	end
	addEventHandler("onPlayerJoin", root, onPlayerJoin_spawnffa)
	addEventHandler("onPlayerWasted", root, onPlayerWasted_spawnffa)
	ffaStarted = true
end

function end_ffaSpawn()
	removeEventHandler("onPlayerJoin", root, onPlayerJoin_spawnffa)
	removeEventHandler("onPlayerWasted", root, onPlayerWasted_spawnffa)
	-- kill everyone and show them a nice view
	for i,v in ipairs(getElementsByType("player")) do
		if (not isPedDead(v)) then
			killPed(v)
		end
		fadeCamera(v, true)
		setCameraMatrix(v, settings.cam.x, settings.cam.y, settings.cam.z, settings.cam.lx, settings.cam.ly, settings.cam.lz, settings.cam.x, settings.cam.roll, settings.cam.fov)
	end
	ffaStarted = false
end

function onPlayerJoin_spawnffa()
	setPlayerReady(source)
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

-- players see cam view whenever they are not on a team:
--  when game starts, when they join, when game ends, when they leave their team

addEvent("onPlayerTeamSelect", true)

local teamsStarted = false

function init_teamSpawn()
	local players = getElementsByType("player")
	-- kill everyone and show them the team selection menu and a nice view
	for i,v in ipairs(players) do
		if (not isPedDead(v)) then
			killPed(v)
		end
		-- when the gamemode map resource starts, the map isn't always loaded client-side
		--  so we wait 5 seconds and hope that it is by then
		--  (This is obviously not fool-proof, and queuing it until the gm resource loads is pointless.
		--  We should queue the triggerClientEvent call until the gm map loads client-side instead, but lazy..)
		setTimer(createAndShowTeamMenuForPlayer, 5000, 1, v)
		-- set their camera
		--fadeCamera(v, true)
		fadeCamera(v, true)
		setCameraMatrix(v, settings.cam.x, settings.cam.y, settings.cam.z, settings.cam.lx, settings.cam.ly, settings.cam.lz, settings.cam.roll, settings.cam.fov)
	end
	addEventHandler("onPlayerTeamSelect", root, onPlayerTeamSelect)
	addEventHandler("onPlayerJoin", root, onPlayerJoin_spawnteam)
	addEventHandler("onPlayerWasted", root, onPlayerWasted_spawnteam)
	teamsStarted = true
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
	-- kill everyone and show them a nice view
	for i,v in ipairs(getElementsByType("player")) do
		if (not isPedDead(v)) then
			killPed(v)
		end
		-- set their camera
		fadeCamera(v, true)
		setCameraMatrix(v, settings.cam.x, settings.cam.y, settings.cam.z, settings.cam.lx, settings.cam.ly, settings.cam.lz, settings.cam.roll, settings.cam.fov)
	end
	teamsStarted = false
end

function onPlayerJoin_spawnteam()
	setTimer(createAndShowTeamMenuForPlayer, 5000, 1, source)
	-- kill the player and show him a nice view
	if (not isPedDead(source)) then
		killPed(source)
	end
	-- set their camera
--outputDebugString(tostring(source) .. settings.cam.x .. settings.cam.fov)
	fadeCamera(source, true)
	setCameraMatrix(source, settings.cam.x, settings.cam.y, settings.cam.z, settings.cam.lx, settings.cam.ly, settings.cam.lz, settings.cam.roll, settings.cam.fov)
end

-- usually called on a timer, so check if the player is still here
function createAndShowTeamMenuForPlayer(player)
	if (isElement(player)) then
		scheduleClientEvent(player, "doCreateTeamMenu", root, getValidTeams())
		scheduleClientEvent(player, "doShowPlayerTeamMenu", root, true)
		bindKey(player, "F3", "down", toggleTeamMenu)
	end
end

-- triggered by client
function onPlayerTeamSelect(team)
	if (isTeamValid(team) and (not getPlayerTeam(source) or getPlayerTeam(source) ~= team)) then
		local refuse = false
		-- check auto-balance
		if (settings.autobalance) then
			if (#getReadyPlayers() > 5) then
				-- don't let him join the team if it has 2+ more players than any other team
				local thisTeamPlayerCount = countPlayersInTeam(team)
				for i,v in ipairs(getValidTeams()) do
					if (v ~= team) then
						local otherTeamPlayerCount = countPlayersInTeam(v)
						if (otherTeamPlayerCount+2 <= thisTeamPlayerCount) then
							refuse = true
							outputConsole("You could not join team " .. getTeamName(team) .. " because it has too many players.", source)
							break
						end
					end
				end
			end
		end
		-- done checking auto-balance
		if (not refuse) then
			local success = true
			if (isPlayerReady(source)) then
				success = setPlayerNotReady(source)
			end
			if (success) then
				local r, g, b = getTeamColor(team)
				outputChatBox(getPlayerName(source) .. " joined " .. getTeamName(team), root, r, g, b)
				scheduleClientEvent(source, "doShowPlayerTeamMenu", root, false)
				setPlayerTeam(source, team)
				setPlayerReady(source)
				if (not isPedDead(source)) then
					killPed(source)
				else
					spawnPlayerAtRandomSpawnpoint(source)
				end
			else
				outputConsole("You could not join team " .. getTeamName(team) .. " because you have the briefcase. Try losing it or dying.", source)
			end
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
