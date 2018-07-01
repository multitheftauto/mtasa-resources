root = getRootElement()
runningMap = false
teams = {} -- used for team game, the participating teams
createdTeams = {} -- the teams created by this resource, they are destroyed when a map stops
settings =	{	limit = 1000, tlimit = false, weather = 0, teams = false, hide = true, reset = 300, gamespeed = 1, ff = true, autobalance = true, onfootonly = false, teamskins = {},
				varteams = false, varteamsmaxplayers = 6,
				weapons = {[1] = 1, [22] = 200, [17] = 4, [29] = 250},
				cam = {x = 1468.88, y = -919.25, z = 100.15, lx = 1468.39, ly = -918.42, lz = 99.88, roll = 0, fov = 70},
				dbg = false
			}

--local teams = {}
local readyPlayers = {}

local varTeamIndex = 1
local clearVarTeamsTimer = nil
local CLEAR_VARTEAMS_DELAY = 60000---

addEvent("onPlayerReady", true)
addEvent("onPlayerBriefcaseHit", true)
addEvent("onPlayerObjectiveHit", true)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
function (resource)

	local resourceRoot = getResourceRootElement(resource)

	addEventHandler( "onGamemodeMapStart", root,		onGamemodeMapStart_brmain)

	addEventHandler( "onResourceStart", root,			onResourceStart_brmain)
	addEventHandler( "onResourceStop", resourceRoot,	onResourceStop_brmain)
end
)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GAME SETUP --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- assumes the previous gamemode must be stopped before the next one is started

function onGamemodeMapStart_brmain(resource)
--outputServerLog(tostring(resource))
	if (runningMap) then
		outputChatBox("Briefcase Race: Failed to start game. The old game mode map must be stopped before a new one is started. Stop any running game mode maps and then start a new one.", root, 255, 127, 0)
		debugMessage("Briefcase Race: Failed to start game. The old game mode map must be stopped before a new one is started. Stop any running game mode maps and then start a new one.")
--		outputConsole(getResourceName(runningMap) .. " map changed to " .. getResourceName(resource) .. " map. Ignoring settings. To use new settings, restart the game mode.")
--		removeEventHandler("onResourceStop", runningMap, onGamemodeMapStop_brmain)
--		runningMap = resource
--		addEventHandler("onResourceStop", resource, onGamemodeMapStop_brmain)
	else
		outputChatBox("Briefcase Race: " .. getResourceName(resource) .. " map started. Starting game.", root, 255, 127, 0)
		debugMessage("Briefcase Race: " .. getResourceName(resource) .. " map started. Starting game.")
		-- get settings
		--readSettingsFile(resource)
		readMapSettings(resource)
		-- get the teams that currently exist (or create them if it's a variable-teams game)
		if (settings.teams) then
			if (not settings.varteams) then
				teams = getElementsByType("team")
				if (#teams < 2) then
					outputChatBox("Briefcase Race: Error: Teams enabled in settings but not enough teams exist! Fix this map or try a different one.", root, 255, 127, 0)
					debugMessage("Briefcase Race: Error: Teams enabled in settings but not enough teams exist! Fix this map or try a different one.")
					return
				else
					-- set friendly fire
					for i,v in ipairs(teams) do
						setTeamFriendlyFire(v, settings.ff)
					end
				end
			else
				teamskins = {}
				local numPlayers = #getElementsByType("player")
				--numPlayers = 128---test thing
				-- generate colors we will use for teams
				local numColors = math.max(15, math.ceil(numPlayers/settings.varteamsmaxplayers))
				generateColors(numColors)
				-- generate teams
				createVarTeam()
				createVarTeam()
				while (numPlayers > #teams * settings.varteamsmaxplayers) do
					createVarTeam()
				end
				clearVarTeamsTimer = setTimer(removeEmptyVarTeams, CLEAR_VARTEAMS_DELAY, 0)
			end
		end
		-- set weather
		--setWeather(settings.weather)
		setTimer(setWeather, 1000, 1, settings.weather)
		-- set game speed
		setGameSpeed(settings.gamespeed)
		runningMap = resource
		addEventHandler("onResourceStop", getResourceRootElement(resource), onGamemodeMapStop_brmain)
		-- start the game (creates ready players, enables spawning/team selection, creates briefcase and objective(s))
		startGame()
	end
end

-- when the gamemode map can stops, the game can either already be started or can already be ended
--  the former will happen if admin or vote changes the map/mode in the middle of the game
--  the latter will happen if the game ends naturally (i.e. point limit reached) and the map cycler kicks in (or an admin/vote changes it)
-- to avoid calling endGame() multiple times, we use isGameStarted() to see whether or not we need to stop it
function onGamemodeMapStop_brmain(resource)
	outputChatBox("Briefcase Race: " .. getResourceName(resource) .. " map stopped. Stopping game and/or clearing settings.", root, 255, 127, 0)
	debugMessage("Briefcase Race: " .. getResourceName(resource) .. " map stopped. Stopping game and/or clearing settings.")
	if (isGameStarted()) then
		-- end the game (gets rid of all ready players, disables spawning, destroys briefcase and objective(s))
		endGame(false, false) -- don't show scores and don't call map cycler, as the map is already being stopped
	end
	-- reset stuff here
	removeEventHandler("onResourceStop", getResourceRootElement(resource), onGamemodeMapStop_brmain)
	runningMap = false
	-- stop varteams timer if it exists
	if (clearVarTeamsTimer) then
		killTimer(clearVarTeamsTimer)
		clearVarTeamsTimer = nil
	end
	-- destroy any teams created by THIS resource (this is the case if it's autoteams)
	for i,v in ipairs(createdTeams) do
		destroyElement(v)
	end
	-- reset all vars
	teams = {}
	createdTeams = {}
	varTeamIndex = 1
	settings =	{	limit = 1000, tlimit = false, weather = 0, teams = false, hide = true, reset = 300, gamespeed = 1, ff = true, autobalance = true, onfootonly = false, teamskins = {},
					varteams = false, varteamsmaxplayers = 6,
					weapons = {[1] = 1, [22] = 200, [17] = 4, [29] = 250},
					cam = {x = 1468.88, y = -919.25, z = 100.15, lx = 1468.39, ly = -918.42, lz = 99.88, roll = 0, fov = 70},
					dbg = false
				}
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCOREBOARD MANAGEMENT --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- adds 'points' column to scoreboard
function onResourceStart_brmain ( resource )
	if ( resource == getThisResource () ) then
		-- add points column to scoreboard if it's already loaded
		local scoreboardResource = getResourceFromName ( "scoreboard" )
		if ( scoreboardResource and getResourceState ( scoreboardResource ) == "running" ) then
		    setTimer ( call, 5000, 1, scoreboardResource, "addScoreboardColumn", "points" )
		    debugMessage ( "Scoreboard already started: Adding points column in 5 seconds..." )
		end
	elseif ( resource == getResourceFromName ( "scoreboard" ) ) then
		-- add points column to scoreboard if it just already loaded
	    setTimer ( call, 5000, 1, scoreboardResource, "addScoreboardColumn", "points" )
		debugMessage ( "Scoreboard just started: Adding points column in 5 seconds..." )
	end
end

-- removes 'points' column from scoreboard
function onResourceStop_brmain ( resource )
	local scoreboardResource = getResourceFromName ( "scoreboard" )
	call ( scoreboardResource, "removeScoreboardColumn", "points" )
end


-- show/hide scoreboard for all players
function forceScoreboardForAllPlayers ( status )
	local scoreboardResource = getResourceFromName ( "scoreboard" )
	if ( scoreboardResource and getResourceState ( scoreboardResource ) == "running" ) then
		for i,v in ipairs ( getElementsByType ( "player" ) ) do
	    	call ( scoreboardResource, "setPlayerScoreboardForced", v, status )
		end
		return true
	else
	    return false
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARTEAM FUNCTIONS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function createVarTeam()
	local teamName = "Team " .. varTeamIndex
	varTeamIndex = varTeamIndex + 1
	-- choose this team's color
	local r, g, b
	r, g, b = chooseRandomColor() -- chooses a color and removes it from the free list
	if (not r) then
		math.randomseed(math.floor(getTickCount()/(#teams+1)))
		r = math.random(0, 255)
		g = math.random(0, 255)
		b = math.random(0, 255)
	end
	-- generate random team skin
	local usedSkins = {}
	for teamName,skinArray in pairs(settings.teamskins) do
		table.insert(usedSkins, skinArray[1])
	end
	local randSkin = getRandomSkin(usedSkins)
	settings.teamskins[teamName] = {[1] = randSkin}
	-- create team
	local team = createTeam(teamName, r, g, b)
	table.insert(teams, team)
	-- tell br.game to add the corresponding objective marker
	gameAddVarTeam(team)
	-- insert into createdTeams table --
	table.insert(createdTeams, team)
	------------------------------------
	setTeamFriendlyFire(team, settings.ff)
	setElementData(team, "points", 0)
end

function destroyVarTeam(team)
	-- remove from createdTeams table if it exists --
	local found2 = false
	for i,v in ipairs(createdTeams) do
		if (v == team) then
			found2 = i
			break
		end
	end
	if (found2) then
		table.remove(createdTeams, found2)
	end
	-------------------------------------------------
	local found = false
	for i,v in ipairs(teams) do
		if (v == team) then
			found = i
			break
		end
	end
	if (found) then
		-- tell br.game to get rid of the corresponding objective marker
		gameRemoveVarTeam(teams[found])
		-- remove it from teams table
		settings.teamskins[getTeamName(teams[found])] = nil
		destroyElement(teams[found])
		table.remove(teams, found)
		return true
	else
		return false
	end
end

-- creates a team when player joins (if necessary)
-- note: when you join, the player count includes you
function onPlayerJoin_varTeams()
	if (not settings.varteams) then
		return
	end
	local totalPlayers = #getElementsByType("player")
	--totalPlayers = 50---test thing
	local totalTeams = #teams
	local capacity = totalTeams * settings.varteamsmaxplayers
	if (totalPlayers > capacity) then
		createVarTeam()
		updateTeamMenu()
		outputDebugString("varteams - Created one team on player join.")
	end
end
addEventHandler("onPlayerJoin", root, onPlayerJoin_varTeams)

-- destroys empty teams
function removeEmptyVarTeams()
	assert(settings.varteams)
	if (#teams > 2) then
		local teamsDestroyed = false -- whether or not any teams were destroyed
		local totalPlayers = #getElementsByType("player") -- number of players (fixed here)
		local totalTeams = #teams -- current number of teams
		local capacity = totalTeams * settings.varteamsmaxplayers -- there current capacity - decreases as teams are removed
		local noEmptyTeams = false -- true if no empty teams were found in the last iteration, tells us there is no reason to keep looping
		while (capacity - settings.varteamsmaxplayers >= totalPlayers and totalTeams > 2 and not noEmptyTeams) do
			-- destroy an empty team if one exists
			local victimTeam = false
			for i,team in ipairs(teams) do
				local numPlayers = countPlayersInTeam(team)
				if (numPlayers == 0) then
					victimTeam = team
					break
				end
			end
			if (victimTeam) then
				destroyVarTeam(victimTeam)
				totalTeams = totalTeams - 1
				capacity = capacity - settings.varteamsmaxplayers
				teamsDestroyed = true
			else
				noEmptyTeams = true
			end
		end
		if (teamsDestroyed) then
			updateTeamMenu()
			outputDebugString("varteams - Destroyed empty team(s).")
		end
	end
end

--[[-- [Note - a better way would be to periodically check the teams and see which ones can be killed.. this would avoid the problem of the player still being on the team when it's killed]
-- destroys unneeded teams when player quits
-- note: when you quit, the player count still includes you
function onPlayerQuit_varTeams()
	if (not settings.varteams) then
		return
	end
	if (#teams > 2) then
		local sourceTeam = getPlayerTeam(source)
		local teamsDestroyed = false
		local totalPlayers = #getElementsByType("player")-1
		local totalTeams = #teams--
		local capacity = totalTeams * settings.varteamsmaxplayers--
		local noEmptyTeams = false--
		while (capacity - settings.varteamsmaxplayers >= totalPlayers and totalTeams > 2 and not noEmptyTeams) do
			-- destroy an empty team if one exists
			local victimTeam = false
			for i,team in ipairs(teams) do
				local numPlayers = countPlayersInTeam(team)
				if (sourceTeam and sourceTeam == team) then
					numPlayers = numPlayers - 1
				end
				if (numPlayers == 0) then
					victimTeam = team
					break
				end
			end
			if (victimTeam) then
				destroyVarTeam(victimTeam)
				totalTeams = totalTeams - 1
				capacity = capacity - settings.varteamsmaxplayers
				teamsDestroyed = true
			else
				noEmptyTeams = true
			end
		end
		if (teamsDestroyed) then
			updateTeamMenu()
		end
	end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit_varTeams)]]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEAM/PLAYER FUNCTIONS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getValidTeams()
	return teams
end

function isPlayerOnValidTeam(player)
	local team = getPlayerTeam(player)
	if (team) then
		for i,v in ipairs(teams) do
			if (v == team) then
				return true
			end
		end
		return false
	else
		return false
	end
end

function isTeamValid(team)
	for i,v in ipairs(teams) do
		if (v == team) then
			return true
		end
	end
	return false
end

function addReadyPlayer(player)
	table.insert(readyPlayers, player)
end

function isPlayerReady(player)
	local ready = false
	for i,v in ipairs(readyPlayers) do
		if (v == player) then
			ready = true
			break
		end
	end
	return ready
end

function removeReadyPlayer(player)
	local index = false
	for i,v in ipairs(readyPlayers) do
		if (v == player) then
			index = i
			break
		end
	end
	if (index) then
		table.remove(readyPlayers, index)
	end
end

function getReadyPlayers()
	return readyPlayers
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- XML FUNCTIONS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function readMapSettings(resource)
	local mapName = getResourceName(resource)
	-- get weather
	local weather = get(mapName .. ".weather")
	if (weather) then
		settings.weather = weather
	end
	-- get cam
	local cam = get(mapName .. ".idlecam")
	if (cam) then
		-- check elements
		local valid = true
		for i=1,8 do
			if (not cam[i]) then
				valid = false
				break
			end
		end
		if (valid) then
			settings.cam = {x = cam[1], y = cam[2], z = cam[3], lx = cam[4], ly = cam[5], lz = cam[6], roll = cam[7], fov = cam[8]}
		end
	end
	-- get gamespeed
	local gamespeed = get(mapName .. ".gamespeed")
	if (gamespeed) then
		settings.gamespeed = gamespeed
	end
	-- get pointlimit
	local pointlimit = get(mapName .. ".pointlimit")
	if (pointlimit) then
		settings.limit = pointlimit
	end
	-- get timelimit
	local timelimit = get(mapName .. ".timelimit")
	if (timelimit) then
		settings.tlimit = timelimit
	end
	-- get onfootonly (boolean)
	local onfootonly = get(mapName .. ".onfootonly")
	--if (onfootonly) then
		settings.onfootonly = onfootonly
	--end
	-- get hide (boolean)
	local hide = get(mapName .. ".hide")
	--if (hide) then
		settings.hide = hide
	--end
	-- get idletime
	local idletime = get(mapName .. ".idletime")
	if (idletime) then
		settings.reset = idletime
	end
	-- get weapons
	local weapons = get(mapName .. ".weapons")
	if (weapons) then
--outputChatBox("get(mapName .. '.weapons'): " .. weapons)
		settings.weapons = {}
		for k,v in pairs(weapons) do
			settings.weapons[tonumber(k)] = v
		end
	end
	-- get teamgame (boolean)
	local teamgame = get(mapName .. ".teamgame")
	--if (teamgame) then
		settings.teams = teamgame
	--end
	-- get ff (boolean)
	local ff = get(mapName .. ".ff")
	--if (ff) then
		settings.ff = ff
	--end
	-- get teamskins
	local teamskins = get(mapName .. ".teamskins")
	if (teamskins) then
--outputChatBox("get(mapName .. '.teamskins'): " .. teamskins)
		settings.teamskins = {}
		for teamName,skinsString in pairs(teamskins) do
			settings.teamskins[teamName] = {}
			local index = 1
			local curSkin = gettok(skinsString, index, string.byte(','))
			while (curSkin) do
				-- process current skin
				curSkin = tonumber(curSkin)
				if (curSkin) then
					table.insert(settings.teamskins[teamName], curSkin)
				end
				-- get the next skin
				index = index + 1
				curSkin = gettok(skinsString, index, string.byte(','))
			end
			--outputDebugString("skins read from settings.xml from team " .. teamName .. ": " .. skinsString)
		end
	end
	-- get varteams (boolean)
	local varteams = get(mapName .. ".autoteams")
	--if (varteams) then
		settings.varteams = varteams
	--end
	-- get varteamsmaxplayers
	local varteamsmaxplayers = get(mapName .. ".autoteamsmaxplayers")
	if (varteamsmaxplayers) then
		settings.varteamsmaxplayers = varteamsmaxplayers
	end
	-- get debug
	local dbg = get(mapName .. ".debug")
	if (dbg) then
		settings.dbg = dbg
	end
end
