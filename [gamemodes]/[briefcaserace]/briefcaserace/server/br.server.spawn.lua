-- TO DO:

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

-- manages player spawning and team selection
-- uses setPlayerReady() and setPlayerNotReady() to have br.server.game put the player in or take the player out of the game

local spawnTimers = {} -- a timer for each player who is set to spawn

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FFA SPAWN --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- players see cam view when the game ends

local ffaStarted = false

function init_ffaSpawn()
	for i,v in ipairs(getElementsByType("player")) do
		setPlayerReady(v)
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
		setCameraMatrix(v, settings.cam.x, settings.cam.y, settings.cam.z, settings.cam.lx, settings.cam.ly, settings.cam.lz, settings.cam.roll, settings.cam.fov)
		-- remove spawn timer if exists
		if (spawnTimers[v]) then
			killTimer(spawnTimers[v])
			spawnTimers[v] = nil
		end
	end
	ffaStarted = false
	-- make all ready players not ready
	-- (essentially it just removes them from the ready table - the briefcases and objectives are already destroyed at this point because endGame() did that)
	for i,v in ipairs(getReadyPlayers()) do
		setPlayerNotReady(v)
	end
end

function onPlayerJoin_spawnffa()
	setPlayerReady(source)
	spawnPlayerAtRandomSpawnpoint(source)
end

function onPlayerWasted_spawnffa()
	if (spawnTimers[source]) then
		killTimer(spawnTimers[source])
	end
	spawnTimers[source] = setTimer(spawnPlayerAtRandomSpawnpoint, 3000, 1, source)
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
local createGuiTimers = {} -- a timer for each player who has pending gui

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
		createGuiTimers[v] = setTimer(createAndShowTeamMenuForPlayer, 5000, 1, v)
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
		-- remove spawn timer if exists
		if (spawnTimers[v]) then
			killTimer(spawnTimers[v])
			spawnTimers[v] = nil
		end
		-- remove gui timer if exists
		if (createGuiTimers[v]) then
			killTimer(createGuiTimers[v])
			createGuiTimers[v] = nil
		end
	end
	teamsStarted = false
	-- make all ready players not ready
	-- (essentially it just removes them from the ready table - the briefcases and objectives are already destroyed at this point because endGame() did that)
	for i,v in ipairs(getReadyPlayers()) do
		setPlayerNotReady(v)
	end
end

function onPlayerJoin_spawnteam()
	createGuiTimers[source] = setTimer(createAndShowTeamMenuForPlayer, 5000, 1, source)
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
	if (createGuiTimers[player]) then
		killTimer(createGuiTimers[player])
		createGuiTimers[player] = nil
	end
	if (isElement(player)) then
		scheduleClientEvent(player, "doCreateTeamMenu", root, getValidTeams())
		scheduleClientEvent(player, "doShowPlayerTeamMenu", root, true)
		bindKey(player, "F3", "down", toggleTeamMenu)
	end
end

-- triggered by client
function onPlayerTeamSelect(team)
	if (isTeamValid(team)) then
		local refuse = false
		if (getPlayerTeam(source) and getPlayerTeam(source) == team) then
			outputChatBox("You could not join team " .. getTeamName(team) .. " because you are already on it.", source)
			refuse = true
		end
		if (not settings.varteams) then
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
								outputChatBox("You could not join team " .. getTeamName(team) .. " because it would have too many players (auto-balance is on).", source)
								break
							end
						end
					end
				end
			end
		else
			-- check if desired team is at capacity
			if (countPlayersInTeam(team) >= settings.varteamsmaxplayers) then
				refuse = true
				outputChatBox("You could not join team " .. getTeamName(team) .. " because it is at capacity.", source)
			end
		end
		-- done checking auto-balance
		if (not refuse) then
			local success = true
			if (isPlayerReady(source)) then
				success = setPlayerNotReady(source)
			end
			if (success) then
				-- set up player
				local r, g, b = getTeamColor(team)
				setPlayerNametagColor(source, r, g, b)
				outputChatBox(getPlayerName(source) .. " joined " .. getTeamName(team), root, r, g, b)
				scheduleClientEvent(source, "doShowPlayerTeamMenu", root, false, 7)
				setPlayerTeam(source, team)
				setPlayerReady(source)
				-- remove spawn timer if exists
				if (spawnTimers[source]) then
					killTimer(spawnTimers[source])
					spawnTimers[source] = nil
				end
				-- spawn player, or kill him and have him auto spawn
				if (not isPedDead(source)) then
					killPed(source)
				else
					spawnPlayerAtRandomSpawnpoint(source)
				end
			else
				outputChatBox("You could not join team " .. getTeamName(team) .. " because you have the briefcase. Try losing it or dying.", source)
			end
		end
	end
end

function updateTeamMenu()
	scheduleClientEventForPlayers(getElementsByType("player"), "doCreateTeamMenu", root, getValidTeams())
end

-- possible bug: player changes teams or leaves team - it spawns him twice or spawns him when it shouldn't!
-- respawn player after death
function onPlayerWasted_spawnteam()
	if (isPlayerReady(source)) then
		spawnTimers[source] = setTimer(spawnPlayerAtRandomSpawnpoint, 3000, 1, source)
	end
end

function toggleTeamMenu(player, key, keyState)
	scheduleClientEvent(player, "doShowPlayerTeamMenu", root, nil)
end


function spawnPlayerAtRandomSpawnpoint ( player )
	if (spawnTimers[player]) then
		killTimer(spawnTimers[player])
		spawnTimers[player] = nil
	end
    local spawnpoints = getElementsByType ( "spawnpoint" )
    local spawnpointIndex = math.random ( # spawnpoints )
    spawnPlayerAtSpawnpoint ( player, spawnpoints[spawnpointIndex] )
end

function spawnPlayerAtSpawnpoint ( player, sp )
--outputServerLog("GOING TO SPWAN PLAYER!")
	setCameraTarget ( player, player ) -- added 7/8/09, as when the player joins and you spawn him it doesn't set the camera on him
	fadeCamera ( player, true )
	return call(getResourceFromName"spawnmanager","spawnPlayerAtSpawnpoint",player,sp )
end

addEventHandler("onPlayerQuit", root,
function ()
--	if (exports.spectator:isSpectator(source)) then
--		exports.spectator:removeSpectator(source)
--	end
end
)
