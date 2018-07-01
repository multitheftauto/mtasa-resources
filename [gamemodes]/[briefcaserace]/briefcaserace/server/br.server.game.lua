--TO DO
-- in server.spawn, track timers that spawn players and timers that show gui, so they can be destroyed if the map ends, etc. (done, need testing)
-- make team menu gui support higher number of teams (screen only shows up to 17 teams right now)
-- make variable teams option.. teams are auto-generated as player count increases. 6 players per team? what skins do they use? (done, needs testing)
-- maybe carrier vehicle 'gravity' is too low, needs testing (needs testing)
-- maybe when briefcase is stuck in air, make it slowly lower to the ground
-- make cars only drop from collision damage, not from weapon damage (done, REALLY needs testing)
-- do player blips work? make them color-coded to team? (done, need testing) (sometimes blips get left behind?)
-- some garage cols are bad, gonna need to get the sizes of those myself (done, at least for san fierro)
-- dead guys sometimes get briefcase? (maybe when they spawn they hit it if it was at theit death location).. REALLY needs testing --> one solution, make it not hittable for a few secs after spawn
-- on finish, victory message isn't displayed (in team mode): for enemy, works on delivery? (fixed?)
-- make teams more easily identifiable.. nametag colors etc.. team skins option? (done, but more could be done)
-- think of better ways to have cars drop briefcases (maybe they drop too easily when damaged, use x^2?) (irrelevant now)
-- have passenger-only drivebys (done)
-- find a better briefcase icon
-- add FF option in settings (done)
-- add briefcases to places inaccessible by cars.. rooftops, interiors.. so people get out of their cars sometimes. maybe create a different map for that? (done)
-- make waiting screens pretty, so players see it whenever they are not ready (kind of done, but doesn't always work)
-- add spectator mode? add click to spawn?? (no, forget it... well maybe as a seperate option selectable frmo the team menu)
-- add time-limit? as it approaches, increase game speed? play sound from gta3?
-- play objective complete sound on delivery
-- IN TEAM MODE, CAN'T SEE OBJECTIVE MARKER AFTER FIRST DELIVERY (fixed)
-- prevent teams for cheating to get points: (done)
--  don't give them points from jacking the orb from eachother's cars
--  limit points after drop.. e.g. they only get the 20 the first couple of times they pick up a particular briefcase (make this for non-teams as well?)
-- make bike fall-off make you drop briefcase!! (or whenever startExit doesn't trigger and only exit triggers? so for all involuntary exits...) (done)
-- make it so... the faster the vehicle, the easier it drops (or classify into: coupes, sedans, old cars, trucks, big trucks, etc) (done)
-- add spray shops for vehicle repairs, or repair pickups? (done)
-- add weapon pickups (randomly placed?)
-- add a volatility meter client-side so people see how easily they can drop the orb (done) (removed, irrelevant now)
-- put stuff into settings and make some of it adjustable in the middle of the game (hiding/showing destiantion to players, etc.) (done)
-- finish implementing team support (done)
--  make each team have a different objective
--  make negative annoucements red for teams, positive blue (done?)
-- display who carrier is (done, press tab)
-- objective not accurate at high speeds (or is it?) (it is)
-- reset flag after idle time (done?)
-- make enter/exit vehicle events be triggered from client script (why?)
-- too many add event handlers? (huh?)
-- make vehicle hit detection client-side for the player hitting the orb carrier? (why?) (maybe to distinguish between car hits and gun hits.. car hits should drop more easily than gun hits)
--SUGGESTIONS
-- don't show objective until orb is picked up (done)
-- don't show objective to other players while someone has orb (done)
--BUG
-- onCarrierEnterVehicle is not always triggered for some unknown reason (should be fixed, updated event name...)
-- onVehicleStartExit_brgame not called when falling from bike (fixed?)
-- MTA BUGS:
--  vehicles take damage when being jacked from another player, possible reason:
--    [14:53] <erorr404> my theory is that when you call fixVehicle() server-side, the server sets the vehicle's health variable to 1000, but the synching client (who does not know the new health yet) sends a packet with the old vehicle health, which is lower than 1000
--    [14:53] <erorr404> then it compares the new health (sent by client) and the old health and sees that it has dropped
--    [14:53] <erorr404> and calls onVehicleDamage
--   one solution: after calling repair vehicle (from spray shops), have it ignore damage done for the next second or so (done)
--  colshape hit events sometimes seem to get triggered for no reason? (could be my fault)
--  setGarageOpen() only takes effect after reconnect, not when the resource starts [server] (works when first starting, when connecting, but not after restarting resource)
--  getGarageSize() returns shitty values (mostly for the X, sometimes for Y) [client]

-- client events:
--  clientGiveBriefcaseToPlayer			r, g, b
--  clientTakeBriefcaseFromPlayer
--  clientCreateIdleBriefcase 			x, y, z
--  clientDestroyIdleBriefcase

--  clientCreateObjective				x, y, z, showBlip
--  clientSetObjectiveHittable			hittable, showBlip
--  clientDestroyObjective
--  clientCreateTeamObjective			team, friendly, x, y, z -- friendly determines what the blip looks like: true - large flag icon, large blip
--  clientSetTeamObjectiveHittable		team, hittable
--  clientDestroyTeamObjective			team

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local DELIVER_PTS = 100
local PICKUP_PTS = 25

local gameStarted = false
local timerElement = false

local theBriefcase = nil
local theObjective = nil
local teamObjectives = {}
local lastCarrier = false -- last player/team that got briefcase - used to prevent multiple point adding. sets on add, clears on last carrier quit, briefcase reset, briefcase deliver, add carrier. Note: one possible problem - need to clear if team gets destroyed? (as in auto-teams)
local resetBriefcaseTimer = nil
local resetObjectivesTimer = nil
local idleBriefcaseTimer = nil

-- element data:
--  carrierVehicle - 'false' if carrier doesn't have vehicle events attached (onCarrierVehicleDamage), 'vehicle' if carrier's vehicle still has events attached
--  justDroppedBriefcase - 'true' if carrier just dropped the orb and is given a penalty, 'false' if not (used to prevent player from picking up the orb the instant after he dropped it)
-- RESET THESE?

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GAME SETUP --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- gets settings
-- creates a briefcase and an objective and sets player points to 0 when map starts
function startGame()

		displayMessageForPlayers(1, "Briefcase Race")
   		-- set players' points to 0
		local players = getElementsByType("player")
		for k,v in ipairs(players) do
			setElementData(v, "points", 0)
		end
		-- store teams and set their points to 0
		if (settings.teams) then
			for i,v in ipairs(teams) do
				setElementData(v, "points", 0)
			end
		end
		--[[-- set players to ready if there are no teams
		if (not settings.teams) then
			for i,v in ipairs(players) do
				addReadyPlayer(v)
			end
		end]] -- this is now done in br.server.spawn
		-- create briefcase and objective
	  	resetBriefcase()
	  	resetObjectives()

	-- add events
	--addEventHandler( "onPlayerReady", root,				onPlayerReady_brgame);
	addEventHandler( "onPlayerJoin", root,				onPlayerJoin_brgame)
	addEventHandler( "onPlayerSpawn", root, 			onPlayerSpawn_brgame);
	addEventHandler( "onVehicleStartExit", root, 		onVehicleStartExit_brgame);
	addEventHandler( "onPlayerBriefcaseHit", root,		onPlayerBriefcaseHit_brgame)
	addEventHandler( "onPlayerObjectiveHit", root,		onPlayerObjectiveHit_brgame);
	addEventHandler( "onPlayerQuit", root,				onPlayerQuit_brgame)

	-- spawn players who are ready or show them a team menu
	-- this also makes them ready
	if (not settings.teams) then
		init_ffaSpawn()
	else
		init_teamSpawn()
	end

	-- set a time limit if there is one
	if (settings.tlimit) then
		timerElement = exports.missiontimer:createMissionTimer(settings.tlimit*60*1000, true, false, 0.5, 20, true, "default-bold", 1)
		addEventHandler("onMissionTimerElapsed", timerElement, onTimeLimitReached)
	end

	gameStarted = true
end

function isGameStarted()
	return gameStarted
end

function endGame(showScores, tellMapCycler)
	-- remove carrier if he exists
	if (theBriefcase and theBriefcase:getCarrier()) then
		removeCarrier(theBriefcase:getCarrier(), 2)
	end
	-- delete briefcase and objective(s)
	if (theBriefcase) then
		theBriefcase:destroy()
		theBriefcase = nil
	end
	if (theObjective) then
		theObjective:destroy()
		theObjective = nil
	end
	for k,v in pairs(teamObjectives) do
		v:destroy()
	end
	teamObjectives = {}
	lastCarrier = false
	if (resetBriefcaseTimer) then
		killTimer(resetBriefcaseTimer)
		resetBriefcaseTimer = nil
	end
	if (resetObjectivesTimer) then
		killTimer(resetObjectivesTimer)
		resetObjectivesTimer = nil
	end
	if (idleBriefcaseTimer) then
		killTimer(idleBriefcaseTimer)
		idleBriefcaseTimer = nil
	end

	-- remove events
	--removeEventHandler( "onPlayerReady", root,				onPlayerReady_brgame)
	removeEventHandler( "onPlayerJoin", root,				onPlayerJoin_brgame)
	removeEventHandler( "onPlayerSpawn", root, 				onPlayerSpawn_brgame)
	removeEventHandler( "onVehicleStartExit", root, 		onVehicleStartExit_brgame)
	removeEventHandler( "onPlayerBriefcaseHit", root,		onPlayerBriefcaseHit_brgame)
	removeEventHandler( "onPlayerObjectiveHit", root,		onPlayerObjectiveHit_brgame)
	removeEventHandler( "onPlayerQuit", root,				onPlayerQuit_brgame)

	-- stop players from spawning [or selecting teams?]
	if (not settings.teams) then
		end_ffaSpawn()
	else
		end_teamSpawn()
	end

	-- remove all players from readyPlayers -- unecessary as they're removed in br.server.spawn now ?
	local tempTable = {}
	for i,v in ipairs(getReadyPlayers()) do -- copy the table of ready players
		tempTable[i] = v
	end
	for i,v in ipairs(tempTable) do -- remove them from the original table
		removeReadyPlayer(v)
	end

	if (showScores) then
		--[[forceScoreboardForAllPlayers(true)
		setTimer(forceScoreboardForAllPlayers, 10000, 1, false)
		addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), onStopSetScoreboardNotForced)
		setTimer(removeEventHandler, 10000, 1, "onResourceStop", getResourceRootElement(getThisResource()), onStopSetScoreboardNotForced)]]
--		local mapmanagerResource = getResourceFromName("mapmanager")
--		if (mapmanagerResource and getResourceState(mapmanagerResource) == "running") then
--			setTimer(outputConsole, 9000, 1, "[Gamemode finished]")
--			setTimer(call, 10000, 1, mapmanagerResource, "stopGamemode") -- server crashes?
--		end
	end

	if (tellMapCycler) then
		local mapCyclerResource = getResourceFromName("mapcycler")
		if (mapCyclerResource and getResourceState(mapCyclerResource) == "running") then
			triggerEvent("onRoundFinished", getResourceRootElement(getThisResource()))
		end
	end

	-- remove the time limit timer if there is one
	if (timerElement) then
		destroyElement(timerElement)
		timerElement = false
	end

	gameStarted = false
end

-- used for auto teams mode - let the script know there is a new team
function gameAddVarTeam(team)
	assert(settings.teams and settings.varteams, "requested to create var team, but this is not the game mode")
	assert(not teamObjectives[team], "requested to create var team, but team is already in objectives table")
	-- check if any other objectives exist - this tells us whether we should create one
	local empty = true
	for k,v in pairs(teamObjectives) do
		empty = false
		break
	end
	-- create and add this objective to the table if necessary
	if (not empty) then
		addObjectiveForTeam(team)
	end
end

-- used for auto teams mode - let the script know a team is about to be destroyed
-- the given team MUST be empty or this will not work
function gameRemoveVarTeam(team)
	assert(settings.teams and settings.varteams, "requested to destroy var team, but this is not the game mode")
	assert(team and isElement(team) and getElementType(team) == "team", "requested to destroy var team, but team does not exist")
	assert(countPlayersInTeam(team) == 0, "requested to destroy var team, but team is not empty")
	-- remove team from objective markers if they exist
	if (teamObjectives[team]) then
		teamObjectives[team]:destroy()
		teamObjectives[team] = nil
	end
end

--[[function onStopSetScoreboardNotForced(resource)
	forceScoreboardForAllPlayers(false)
end]]

-- sets player's points to 0 when they join
function onPlayerJoin_brgame()
	if (runningMap) then
		setElementData(source, "points", 0)
	end
end

-- increases player's points, returns true if point limit reached
function increasePoints(player, points)
	local pointLimitReached = false
	if (settings.teams) then
		assert(isPlayerOnValidTeam(player), "Point increaser expected on team but is not")
		local team = getPlayerTeam(player)
		local playerPoints = getElementData(player, "points") + points
		local teamPoints = getElementData(team, "points") + points
		setElementData(player, "points", playerPoints)
		setElementData(team, "points", teamPoints)
		if (teamPoints >= settings.limit) then
            local r, g, b = getTeamColor(team)
			displayMessageForPlayers(1, "Point limit reached, team " .. getTeamName ( team ) .. " wins!", 10000, nil, nil, 0, 0, 255, team)
			displayMessageForPlayers(1, "Point limit reached, team " .. getTeamName ( team ) .. " wins!", 10000, nil, nil, 255, 0, 0, team, true)
           	pointLimitReached = true
		end
	else
		local playerPoints = getElementData(player, "points") + points
		setElementData(player, "points", playerPoints)
		if (playerPoints >= settings.limit) then
			displayMessageForPlayers(1, "Point limit reached, " .. getPlayerName ( player ) .. " wins!", 10000)
           	pointLimitReached = true
		end
	end
	return pointLimitReached
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER SETUP --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- give player weapons when they spawn
function onPlayerSpawn_brgame(spawnpoint)
	-- set player skin if on a team and team skin(s) exist(s)
	if (settings.teams) then
		assert(isPlayerOnValidTeam(source), "Player not on valid team")
		local teamName = getTeamName(getPlayerTeam(source))
		if (settings.teamskins[teamName] and #settings.teamskins[teamName] > 0) then
			local randSkin = math.random(1,#settings.teamskins[teamName])
			setPedSkin(source, settings.teamskins[teamName][randSkin])
		end
	end
	-- give player weapons
	for k,v in pairs(settings.weapons) do
		giveWeapon(source, k, v)
	end
    setPedFightingStyle(source, 6)
end

-- creates briefcase and objective for new player (if needed) to bring the current state of the game
-- called when a player becomes a 'valid' player who can play
--  for team game, must be called right after player joins team
--  for non-team game, can be called onPlayerJoin
function setPlayerReady(source)
	assert(not isPlayerReady(source))

	addReadyPlayer(source)

	-- create a briefcase if it exists
	if (theBriefcase) then
		if (theBriefcase:getCarrier()) then -- carried
			-- get color of indicator marker
			local r, g, b = 255, 0, 0
			if (settings.teams) then
				r, g, b = getTeamColor(getPlayerTeam(theBriefcase:getCarrier()))
			end
			-- attach briefcase to player
			scheduleClientEvent(source, "clientGiveBriefcaseToPlayer", theBriefcase:getCarrier(), r, g, b)
		elseif (theBriefcase:isIdle()) then -- idle
			local x, y, z = theBriefcase:getPosition()
			scheduleClientEvent(source, "clientCreateIdleBriefcase", root, x, y, z)
		end
	end

	-- create objective(s) if it exist(s)
	if (not settings.teams) then
		if (theObjective) then
			local x, y, z = theObjective:getPosition()
			scheduleClientEvent(source, "clientCreateObjective", root, x, y, z, not settings.hide)
		end
	else
		assert(isPlayerOnValidTeam(source), "Player not on valid team")
		local playerTeam = getPlayerTeam(source)
		for team,objective in pairs(teamObjectives) do
			local x, y, z = objective:getPosition()
			if (playerTeam == team) then
				scheduleClientEvent(source, "clientCreateTeamObjective", root, team, true, x, y, z)
			else
				scheduleClientEvent(source, "clientCreateTeamObjective", root, team, false, x, y, z)
			end
		end
	end

	return true
end

-- will fail if he has the briefcase!
-- intended to be used when players leave their team
function setPlayerNotReady(source)
	assert(isPlayerReady(source))

	-- fail if this player has the briefcase
	if (theBriefcase and theBriefcase:getCarrier() and theBriefcase:getCarrier() == source) then
		return false
	end
	-- fail if this player can hit the objective (redundant since players can only hit when he has briefcase, but safer..)
	if (not settings.teams) then
		if (theObjective and theObjective:getHitter() and theBriefcase:getHitter() == source) then
			return false
		end
	else
		for k,v in pairs(teamObjectives) do
			if (v:getHitter() and v:getHitter() == source) then
				return false
			end
		end
	end

	removeReadyPlayer(source)

	-- remove the briefcase if it exists
	if (theBriefcase) then
		if (theBriefcase:getCarrier()) then -- carried
			scheduleClientEvent(source, "clientTakeBriefcaseFromPlayer", theBriefcase:getCarrier())
		elseif (theBriefcase:isIdle()) then -- idle
			local x, y, z = theBriefcase:getPosition()
			scheduleClientEvent(source, "clientDestroyIdleBriefcase", root)
		end
	end

	-- remove objective(s) if it exist(s)--
	if (not settings.teams) then
		if (theObjective) then
			scheduleClientEvent(source, "clientDestroyObjective", root)
		end
	else
		for team,objective in pairs(teamObjectives) do
			scheduleClientEvent(source, "clientDestroyTeamObjective", root, team)
		end
	end

	return true
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GAME EVENTS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- game event - player hits the briefcase
function onPlayerBriefcaseHit_brgame()
	assert(theBriefcase and theBriefcase:isIdle(), "Briefcase hit - the briefcase does not exist or is not idle")---asserts, but it's ok since client has multiple hits in one short period
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
	-- make sure the player isn't dead (the latter might be the case if this event is triggered more than once)
	if (not isPedDead(source)) then
		local inVehicle = isPedInVehicle(source)
		-- make sure the player didn't just drop the orb from a vehicle and isn't a passenger
		if (not getElementData(source, "justDroppedBriefcase") and (not inVehicle or getPedOccupiedVehicleSeat(source) == 0 )) then
			-- announce that player has orb
			if (settings.teams) then
				--local r, g, b = getTeamColor ( getPlayerTeam ( source ) )
				displayMessageForPlayers(1, getPlayerName(source) .. " has the briefcase!", nil, nil, nil, 0, 0, 255, getPlayerTeam(source))
				displayMessageForPlayers(1, getPlayerName(source) .. " has the briefcase!", nil, nil, nil, 255, 0, 0, getPlayerTeam(source), true)
			else
				displayMessageForPlayers(1, getPlayerName(source) .. " has the briefcase!")
			end
			-- give him the briefcase
			debugMessage("Adding carrier " .. getPlayerName(source) .. " due to briefcase hit.")
			addCarrier(source)
		end
	end
end

-- game event - player delivers the briefcase
function onPlayerObjectiveHit_brgame()
		assert(theBriefcase and theBriefcase:getCarrier() == source, "Objective hit - the briefcase does not exist or the carrier isn't the guy who hit the objective")---asserts, but it's ok since client has multiple hits in one short period
		assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
		if ( not settings.onfootonly or not isPedInVehicle ( source ) ) then
			debugMessage("Removing carrier " .. getPlayerName(source) .. " due to objective hit.")
			removeCarrier(source, 2)
	        -- increase player health
	        setElementHealth(source, 100)
			-- restore ammo if less (or just give more)
	        -- increase vehicle health
	        local vehicle = getPedOccupiedVehicle(source)
	        if (vehicle and getPedOccupiedVehicleSeat(source) == 0) then
	        	fixVehicle(vehicle)
	        end
			-- reset lastCarrier
			if (lastCarrier) then
				lastCarrier = false
			end
	        -- remove any instructions message the player might have
			clearMessageForPlayer(source, 2)
	  		-- announce that player reached the objective
	  		if (settings.teams) then
				displayMessageForPlayers(1, getPlayerName(source) .. " reached the destination!", nil, nil, nil, 0, 0, 255, getPlayerTeam(source))
				displayMessageForPlayers(1, getPlayerName(source) .. " reached the destination!", nil, nil, nil, 255, 0, 0, getPlayerTeam(source), true)
	  		else
				displayMessageForPlayers(1, getPlayerName(source) .. " reached the destination!")
	  		end
			-- increase score
			local pointLimitReached = increasePoints(source, DELIVER_PTS)
			if (pointLimitReached) then
				endGame(true, true)
			else
			    -- reset orb and objective
	   			resetBriefcaseTimer = setTimer(resetBriefcase, 5000, 1)
	           	resetObjectivesTimer = setTimer(resetObjectives, 5000, 1)
			end
		else
		    --outputChatBox ( "Get out of your vehicle!", source, 147, 112, 219 )
			displayMessageForPlayer(source, 2, "Get out of your vehicle first!", 5000, 0.5, 0.535, 170, 0, 0, 1.75)
		end
end

-- game event - carrier dies
function onCarrierWasted(ammo, killer, weapon, bodypart)
	assert(theBriefcase and theBriefcase:getCarrier() == source, "Carrier wasted - the briefcase does not exist or the carrier isn't the guy who was wasted")
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
	debugMessage("Removing carrier " .. getPlayerName(source) .. " due to carrier death.")
	removeCarrier(source, 1)
	-- remove any instructions message the player might have
	clearMessageForPlayer(source, 2)
	-- announce that the player dropped the orb
	if (settings.teams) then
		displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 255, 0, 0, getPlayerTeam(source))
		displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 0, 0, 255, getPlayerTeam(source), true)
	else
		displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!")
	end
end

-- game event - carrier quits
function onCarrierQuit(reason)
	assert(theBriefcase and theBriefcase:getCarrier() == source, "Carrier quit - the briefcase does not exist or the carrier isn't the guy who quit")
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
	debugMessage("Removing carrier " .. getPlayerName(source) .. " due to carrier quit.")
	removeCarrier(source, 3)
	-- remove any instructions message the player might have
	clearMessageForPlayer(source, 2)
	-- announce that the player dropped the orb
	if (settings.teams) then
		displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 255, 0, 0, getPlayerTeam(source))
		displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 0, 0, 255, getPlayerTeam(source), true)
	else
		displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!")
	end
end

-- game event - carrier gets run over
function onCarrierDamage(attacker, attackerweapon, bodypart, loss)
	if ((attackerweapon == 49 or attackerweapon == 50) and loss > 8) then --if they were hit by a vehicle
		assert(theBriefcase and theBriefcase:getCarrier() == source, "Carrier run over - the briefcase does not exist or the carrier isn't the guy who was run over")
		assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
		debugMessage("Removing carrier " .. getPlayerName(source) .. " due to carrier damage from vehicle.")
		removeCarrier(source, 1)
		-- remove any instructions message the player might have
		clearMessageForPlayer(source, 2)
		-- announce that the player dropped the orb
		if (settings.teams) then
			displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 255, 0, 0, getPlayerTeam(source))
			displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 0, 0, 255, getPlayerTeam(source), true)
		else
			displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!")
		end
		-- make briefcase not hittable to player for 5 seconds
		setElementData(source, "justDroppedBriefcase", true)
		setTimer(setElementData, 5000, 1, source, "justDroppedBriefcase", false)
        -- tell the player he can't pick the orb up for 5 seconds
		displayMessageForPlayer(source, 2, "[Five second pickup penalty]", 5000, 0.5, 0.535, 170, 0, 0, 1.75)
	end
end

-- game event - carrier enters vehicle
-- adds vehicle damage event
function onCarrierVehicleEnter(vehicle, seat, jacked)
	-- When jacking, onCarrierVehicleExit gets called and adds onVehicleNonWeaponDamage event for player. Then this event triggers and tries to add it again, producing an error.
	-- So, we check to see if it has been added yet be checking the element data:
	if (not getElementData(source, "carrierVehicle")) then
		--addEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage) -- added when it already exists sometimes (like when jacking)
		addEventHandler("onVehicleNonWeaponDamage", vehicle, onCarrierVehicleDamage) -- added when it already exists sometimes (like when jacking)
		setElementData(source, "carrierVehicle", vehicle)
	end
end

-- game event - someone starts to exit their vehicle
-- if that someone is the carrier, remove vehicle damage event
-- Note0: we need to remove the onVehicleDamage event handler when the carrier STARTS to exit the vehicle because otherwise, if he jumps
--  out and the vehicle hits a wall, the orb will still drop, since the handler wasn't removed yet (because onPlayerVehicleExit was used
--  which gets triggered too late)
-- Note1: a better option would be to use onPlayerStartVehicleExit as we could attach it to the carrier, but this event does not exist
-- Note2: this function is not called sometimes, like when falling off a bike, so there is also a check in onCarrierVehicleExit
function onVehicleStartExit_brgame(player, seat, jacker)
	if (theBriefcase and theBriefcase:getCarrier() and player == theBriefcase:getCarrier()) then
		assert(not settings.teams or isPlayerOnValidTeam(player), "Player not on valid team")
		-- remove vehicle damage
		--removeEventHandler("onVehicleDamage", source, onCarrierVehicleDamage)
		removeEventHandler("onVehicleNonWeaponDamage", source, onCarrierVehicleDamage)
		setElementData(player, "carrierVehicle", false)
	end
end

-- game event - carrier fully exits the vehicle, possibly jacked
-- if jacked:
--  removes carrier events from jacked, makes jacked carrier not a carrier, detaches orb marker from jacked
--  increases jacker's score, attaches orb to jacker, adds carrier events to jacker, makes jacker a carrier
-- removes vehicle damage handler if it wasn't already removed (this can happen in the case of falling off a bike, for example)
function onCarrierVehicleExit(vehicle, seat, jacker)
	assert(theBriefcase and theBriefcase:getCarrier() == source, "Carrier exitted vehicle - the briefcase does not exist or the carrier isn't the guy who exitted")
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
	if (jacker) then
		assert(not settings.teams or isPlayerOnValidTeam(jacker), "Player not on valid team")
		debugMessage("Removing carrier " .. getPlayerName(source) .. " due to carrier jacked.")
  		removeCarrier(source, 0)
		-- remove any instructions message the jacked player might have
		clearMessageForPlayer(source, 2)
		-- announce that jacker jacked the orb carrier
		if (teamGame) then
			displayMessageForPlayers(1, getPlayerName(jacker) .. " stole the briefcase from " .. getPlayerName(source) .. "!", nil, nil, nil, 0, 0, 255, getPlayerTeam(jacker))
			displayMessageForPlayers(1, getPlayerName(jacker) .. " stole the briefcase from " .. getPlayerName(source) .. "!", nil, nil, nil, 255, 0, 0, getPlayerTeam(jacker), true)
		else
			displayMessageForPlayers(1, getPlayerName(jacker) .. " stole the briefcase from " .. getPlayerName(source) .. "!")
		end
		-- give him the briefcase
		debugMessage("Adding carrier " .. getPlayerName(jacker) .. " due to jacking.")
		addCarrier(jacker)
	elseif (getElementData(source, "carrierVehicle")) then
		-- NEW -- make him drop the briefcase and give him a pickup penalty (this usually happens when he falls of a bike, or in any other case where onStartExit doesn't get triggered first)
		------------------------------------
		removeCarrier(source, 1)
		debugMessage("Removing carrier " .. getPlayerName(source) .. " due to bike fall.")
		-- remove any instructions message the player might have
		clearMessageForPlayer(source, 2)
		-- announce that the player dropped the orb
		if (settings.teams) then
			displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 255, 0, 0, getPlayerTeam(source))
			displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!", nil, nil, nil, 0, 0, 255, getPlayerTeam(source), true)
		else
			displayMessageForPlayers(1, getPlayerName(source) .. " dropped the briefcase!")
		end
		-- make briefcase not hittable to player for 5 seconds
		setElementData(source, "justDroppedBriefcase", true)
		setTimer(setElementData, 5000, 1, source, "justDroppedBriefcase", false)
        -- tell the player he can't pick the briefcase up for 5 seconds
		displayMessageForPlayer(source, 2, "[Five second pickup penalty]", 5000, 0.5, 0.535, 170, 0, 0, 1.75)
		------------------------------------
	end
	-- in the case where the carrier falls of a bike (ie. onVehicleStartExit isn't triggered, but the player has in fact exitted the vehicle!),
	-- the code below will catch the exit and remove the onCarrierVehicleDamageEvent
	local vehicle = getElementData(source, "carrierVehicle")
	if (vehicle) then
		--outputDebugString ( "removing onCarrierVehicleDamage for " .. getPlayerName ( source ) .. " (caught in onCarrierVehicleExit)" )
		--removeEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage)
		removeEventHandler("onVehicleNonWeaponDamage", vehicle, onCarrierVehicleDamage)
		setElementData(source, "carrierVehicle", false)
	end
end

-- game event - carrier's vehicle gets damaged
-- makes orb not pickup-able by this player for 5 seconds, makes player drop orb
function onCarrierVehicleDamage(loss)
	assert(theBriefcase and theBriefcase:getCarrier(), "Carrier vehicle damage - the briefcase does not exist or a carrier does not exist")
	local player = theBriefcase:getCarrier()
	assert(not settings.teams or isPlayerOnValidTeam(player), "Player not on valid team")
	assert(isPedInVehicle(player) and getPedOccupiedVehicle(player) == source, "onCarrierVehicleDamage - carrier not in a vehicle or his vehicle isn't the one that was damaged.")
	-- dropLoss is the least amount of damage that needs to be done to drop the orb
	--local dropLoss = 25 -- old value
	--local dropLoss = (getElementHealth(source) + loss)^3/5000000 -- make it a function of current vehicle health - if healthy, more damage is required to drop orb, if unhealthy, less damage is required
	-- dropLoss = the minimum health loss required in order to drop the briefcase: a function of the vehicle type and it's health
	--local dropLoss = getDropLossFromHealth(source, getElementHealth(source) + loss)
	local dropThreshold = getDropThresholdFromVehicle(source)
	debugMessage("Carrier damaged vehicle: damage - " .. loss .. ", threshold - " .. dropThreshold)
	if (loss >= dropThreshold) then
		--local player = theBriefcase:getCarrier()
		removeCarrier(player, 1)
		debugMessage("Removing carrier " .. getPlayerName(player) .. " due to vehicle damage.")
		-- remove any instructions message the player might have
		clearMessageForPlayer(player, 2)
		-- announce that the player dropped the orb
		if (settings.teams) then
			displayMessageForPlayers(1, getPlayerName(player) .. " dropped the briefcase!", nil, nil, nil, 255, 0, 0, getPlayerTeam(player))
			displayMessageForPlayers(1, getPlayerName(player) .. " dropped the briefcase!", nil, nil, nil, 0, 0, 255, getPlayerTeam(player), true)
		else
			displayMessageForPlayers(1, getPlayerName(player) .. " dropped the briefcase!")
		end
		-- make briefcase not hittable to player for 5 seconds
		setElementData(player, "justDroppedBriefcase", true)
		setTimer(setElementData, 5000, 1, player, "justDroppedBriefcase", false)
        -- tell the player he can't pick the briefcase up for 5 seconds
		displayMessageForPlayer(player, 2, "[Five second pickup penalty]", 5000, 0.5, 0.535, 170, 0, 0, 1.75)
	end
end

function onTimeLimitReached()
	-- remove carrier if there is one
	if (theBriefcase and theBriefcase:getCarrier()) then
		local player = theBriefcase:getCarrier()
		debugMessage("Removing carrier " .. getPlayerName(player) .. " due to time limit expiration.")
		removeCarrier(player, 2)
	end
	-- get player/team with most points
	if (settings.teams) then
		-- get the team with the max score, if any
		local maxScore = 0
		local maxScoreTeam = false
		for i,v in ipairs(getValidTeams()) do
			local points = getElementData(v, "points")
			if (points > maxScore) then
				maxScore = points
				maxScoreTeam = v
			elseif (points == maxScore) then
				maxScoreTeam = false
			end
		end
		-- show the message
		if (maxScoreTeam) then
			local r, g, b = getTeamColor(maxScoreTeam)
			displayMessageForPlayers(1, "Time limit expired, team " .. getTeamName ( maxScoreTeam ) .. " wins!", 10000, nil, nil, 0, 0, 255, maxScoreTeam)
			displayMessageForPlayers(1, "Time limit expired, team " .. getTeamName ( maxScoreTeam ) .. " wins!", 10000, nil, nil, 255, 0, 0, maxScoreTeam, true)
		else
			displayMessageForPlayers(1, "Time limit expired, the game is a draw", 10000)
		end
	else
		-- get the player with the max score, if any
		local maxScore = 0
		local maxScorePlayer = false
		for i,v in ipairs(getReadyPlayers()) do
			local points = getElementData(v, "points")
			if (points > maxScore) then
				maxScore = points
				maxScorePlayer = v
			elseif (points == maxScore) then
				maxScorePlayer = false
			end
		end
		-- show the message
		if (maxScorePlayer) then
			displayMessageForPlayers(1, "Time limit expired, " .. getPlayerName ( maxScorePlayer ) .. " wins!", 10000)
		else
			displayMessageForPlayers(1, "Time limit expired, the game is a draw", 10000)
		end
	end
	-- end the game
	endGame(true, true)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CARRIER MANAGEMENT FUNCTIONS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1) removes old briefcase, 2) creates new briefcase for player, 3) makes objective hittable
function addCarrier(player)
	assert(not settings.teams or isPlayerOnValidTeam(player), "Player not on valid team")

	-- kill the reset timer if it exists
	if (idleBriefcaseTimer) then
		killTimer(idleBriefcaseTimer)
		idleBriefcaseTimer = false
	end

	-- block this player's points if he was lastCarrier
	local blockPoints = false
	if (lastCarrier) then
		if (not settings.teams) then
			if (lastCarrier == player) then
				blockPoints = true
			end
		else
			if (isElement(lastCarrier)) then -- if team lastCarrier was destroyed, this will no longer be an element and we skip the check
				if (lastCarrier == getPlayerTeam(player)) then
					blockPoints = true
				end
			end
		end
	end

	-- set this player/team to lastCarrier
	if (not settings.teams) then
		lastCarrier = player
	else
		lastCarrier = getPlayerTeam(player)
	end

	-- increase points if not blocked
	local pointLimitReached = false
	if (not blockPoints) then
		-- increase score
		pointLimitReached = increasePoints(player, PICKUP_PTS)
	end

	if (pointLimitReached) then
		endGame(true, true)
	else
		-- remove old briefcase
		if (theBriefcase:isIdle()) then
			theBriefcase:notIdle()
		elseif (theBriefcase:getCarrier()) then
			theBriefcase:detach()
		end
		-- get color of indicator marker
		local r, g, b = 255, 0, 0
		if (settings.teams) then
			r, g, b = getTeamColor(getPlayerTeam(player))
		end
		-- attach briefcase to player
		theBriefcase:attach(player, r, g, b)
		-- add events
		addCarrierEvents(player)

		if (not settings.teams) then
			-- make objective hittable
			theObjective:hitter(player)
			-- show message
			local x, y, z = theObjective:getPosition()
			displayMessageForPlayer(player, 2, "Deliver the briefcase to the destination in " .. getZoneName(x, y, z) .. "!", 7500, 0.5, 0.535, 147, 112, 219, 1.75)
		else
			assert(isPlayerOnValidTeam(player), "Player not on valid team")
			local team = getPlayerTeam(player)
			-- make this team's objective hittable
			teamObjectives[team]:hitter(player)
			-- show message
			local x, y, z = teamObjectives[team]:getPosition()
			displayMessageForPlayer(player, 2, "Deliver the briefcase to the destination in " .. getZoneName(x, y, z) .. "!", 7500, 0.5, 0.535, 147, 112, 219, 1.75)
		end
	end
end

-- removes carrier events, removes carrier client-side, detaches orb from player
-- the action argument indicates what to do with the orb after removing it
--  0 - take no action 1 - place the orb at the carrier's location, 2 - destroy orb and objective, 3 - destroy and reset the orb and objective
function removeCarrier(player, action)
	-- detach briefcase
	theBriefcase:detach()
	-- make objective not hittable
	if (not settings.teams) then
		theObjective:hitter(false)
	else
		assert(isPlayerOnValidTeam(player), "Player not on valid team")
		local team = getPlayerTeam(player)
		teamObjectives[team]:hitter(false)
	end
    -- remove events for carrier
	removeCarrierEvents(player)
	if (action == 1) then
		-- place briefcase at the player's location
		local x, y, z = getElementPosition(player)
		theBriefcase:idle(x, y, z)
		-- set reset timer
		idleBriefcaseTimer = setTimer(destroyAndResetIdleBriefcase, settings.reset*1000, 1)
	elseif ( action == 2 ) then
		-- destroy briefcase
		theBriefcase:destroy()
		theBriefcase = nil
		-- destroy objective(s)
		if (not settings.teams) then
			theObjective:destroy()
			theObjective = nil
		else
			assert(isPlayerOnValidTeam(player), "Player not on valid team")
			for i,v in ipairs(teams) do
				teamObjectives[v]:destroy()
				teamObjectives[v] = nil
			end
		end
	elseif ( action == 3 ) then
		-- destroy briefcase
		theBriefcase:destroy()
		theBriefcase = nil
		-- destroy objective(s)
		if (not settings.teams) then
			theObjective:destroy()
			theObjective = nil
		else
			assert(isPlayerOnValidTeam(player), "Player not on valid team")
			for i,v in ipairs(teams) do
				teamObjectives[v]:destroy()
				teamObjectives[v] = nil
			end
		end
		-- reset orb and objective
		resetBriefcaseTimer = setTimer(resetBriefcase, 5000, 1)
		resetObjectivesTimer = setTimer(resetObjectives, 5000, 1)
	end
end

-- adds game events for carrier
function addCarrierEvents(player)
	addEventHandler("onPlayerWasted", player, onCarrierWasted)
	addEventHandler("onPlayerDamage", player, onCarrierDamage)
	local success
	success = addEventHandler("onPlayerVehicleEnter", player, onCarrierVehicleEnter) -- unreliable
	if (not success) then outputDebugString("could not add onPlayerVehicleEnter event for carrier")	end---
	success = addEventHandler("onPlayerVehicleExit", player, onCarrierVehicleExit) -- unreliable -- onPlayerStartExitVehicle?
	if (not success) then outputDebugString("could not add onPlayerVehicleExit event for carrier")	end---
	addEventHandler("onPlayerQuit", player, onCarrierQuit)
	local vehicle = getPedOccupiedVehicle(player)
	if (vehicle) then
		--addEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage)
		addEventHandler("onVehicleNonWeaponDamage", vehicle, onCarrierVehicleDamage)
		setElementData(player, "carrierVehicle", vehicle)
	end
end

-- removes game events for carrier
function removeCarrierEvents(player)
	removeEventHandler("onPlayerWasted", player, onCarrierWasted)
	removeEventHandler("onPlayerDamage", player, onCarrierDamage)
	removeEventHandler("onPlayerVehicleEnter", player, onCarrierVehicleEnter)
	removeEventHandler("onPlayerVehicleExit", player, onCarrierVehicleExit)
	removeEventHandler("onPlayerQuit", player, onCarrierQuit)
	local vehicle = getElementData(player, "carrierVehicle")
	if (vehicle) then
		--removeEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage)
		removeEventHandler("onVehicleNonWeaponDamage", vehicle, onCarrierVehicleDamage)
		setElementData(player, "carrierVehicle", false)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MARKER MANAGEMENT FUNCTIONS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- zzz shouldnt it be set no hittable client-side?
-- destroys and resets orb after inactivity
function destroyAndResetIdleBriefcase()
	-- kill timer
    idleBriefcaseTimer = false
	-- destroy briefcase
	theBriefcase:notIdle()
    -- reset briefcase
 	resetBriefcaseTimer = setTimer(resetBriefcase, 5000, 1)
	-- reset lastCarrier if exists
	if (lastCarrier) then
		lastCarrier = false
	end
	-- display message that orb is being reset
	displayMessageForPlayers(1, "[Reseting briefcase due to inactivity]")
end

-- chooses a random briefcase spawn location from map file, creates idle briefcase
function resetBriefcase()
	resetBriefcaseTimer = nil
	---MODIFIED FROM ERORR'S ORIGINAL CODE.  More editor compatible, as there's no unnecessary parent group anymore.
	-- get coords from map
	--local runningMap = call(getResourceFromName"mapmanager","getRunningGamemodeMap") -- commented out because this returns nil when resetOrb is called when the gm map is started because mapmanager does not have the gm map set yet at this point.. this is because it triggers the event gm map start event before setting the gm map (currentGamemodeMap is nil at this point) -- erorr404
--outputServerLog(tostring(runningMap))
	local mapRoot = getResourceRootElement(runningMap)
	local briefcases = getElementsByType("briefcase", mapRoot) -- changed from orb to briefcase
	local briefcaseCount = #briefcases
	--outputDebugString ( briefcaseCount .. " briefcases total")---
	if (briefcaseCount > 0) then
		math.randomseed(getTickCount())
		local briefcaseIndex = math.random(1, briefcaseCount)
		--outputDebugString("briefcase " .. briefcaseIndex .. " chosen")---
		local briefcaseElem = briefcases[briefcaseIndex]
		local x = tonumber(getElementData(briefcaseElem, "posX"))
		local y = tonumber(getElementData(briefcaseElem, "posY"))
		local z = tonumber(getElementData(briefcaseElem, "posZ"))
		z = z - 0.3 -- correction, since in briefcaserace-sf are the old orb positions which are higher than the suitcase
		--outputDebugString("briefcase: " .. x .. " " .. y .. " " .. z)---
		-- create briefcase
		theBriefcase = Briefcase:new({})
		theBriefcase:idle(x, y, z)
		return true
	else
	    outputChatBox("Error: no briefcases")
	    return false
	end
end

-- chooses a random desstination spawn location from map file, creates destination
function resetObjectives()
	resetObjectivesTimer = nil
	---MODIFIED FROM ERORR'S ORIGINAL CODE.  More editor compatible, as there's no unnecessary parent group anymore.
	-- get coords from map
	--local runningMap = call(getResourceFromName"mapmanager","getRunningGamemodeMap") -- commented out because this returns nil when resetOrb is called when the gm map is started because mapmanager does not have the gm map set yet at this point.. this is because it triggers the event gm map start event before setting the gm map (currentGamemodeMap is nil at this point) -- erorr404
	local mapRoot = getResourceRootElement(runningMap)
	local objectives = getElementsByType("objective", mapRoot)
	local objectiveCount = #objectives
	if (objectiveCount > 0) then
		--outputDebugString(objectiveCount .. " objectives total")---
	 	-- create objective
		math.randomseed(getTickCount())
		if (not settings.teams) then
			local objectiveIndex = math.random(1, objectiveCount)
			--outputDebugString("objective " .. objectiveIndex .. " chosen")---
			local objectiveElem = objectives[objectiveIndex]
			local x = tonumber(getElementData(objectiveElem, "posX"))
			local y = tonumber(getElementData(objectiveElem, "posY"))
			local z = tonumber(getElementData(objectiveElem, "posZ"))
			--outputDebugString("objective: " .. x .. " " .. y .. " " .. z)---
			theObjective = Objective:new({x = x, y = y, z = z})
		else
			for i,v in ipairs(teams) do
				local objectiveIndex = math.random(1, objectiveCount)
				--outputDebugString("objective " .. objectiveIndex .. " chosen")---
				local objectiveElem = objectives[objectiveIndex]
				local x = tonumber(getElementData(objectiveElem, "posX"))
				local y = tonumber(getElementData(objectiveElem, "posY"))
				local z = tonumber(getElementData(objectiveElem, "posZ"))
				--outputDebugString("objective: " .. x .. " " .. y .. " " .. z)---
				teamObjectives[v] = Objective:new({x = x, y = y, z = z, team = v})
			end
		end
	 	return true
	else
	    outputChatBox("Error: no objectives")
	    return false
	end
end

function addObjectiveForTeam(team)
	local mapRoot = getResourceRootElement(runningMap)
	local objectives = getElementsByType("objective", mapRoot)
	local objectiveCount = #objectives
	if (objectiveCount > 0) then
		--outputDebugString(objectiveCount .. " objectives total")---
	 	-- create objective
		math.randomseed(getTickCount())
		local objectiveIndex = math.random(1, objectiveCount)
		--outputDebugString("objective " .. objectiveIndex .. " chosen")---
		local objectiveElem = objectives[objectiveIndex]
		local x = tonumber(getElementData(objectiveElem, "posX"))
		local y = tonumber(getElementData(objectiveElem, "posY"))
		local z = tonumber(getElementData(objectiveElem, "posZ"))
		--outputDebugString("objective: " .. x .. " " .. y .. " " .. z)---
		teamObjectives[team] = Objective:new({x = x, y = y, z = z, team = team})
	 	return true
	else
	    outputChatBox("Error: no objectives")
	    return false
	end
end

function onPlayerQuit_brgame(quitType, reason, responsibleElement)
	if (lastCarrier and not settings.teams) then
		if (source == lastCarrier) then
			lastCarrier = false
		end
	end
	-- remove him from the ready players (if he's not a ready player, it will just ignore him)
	removeReadyPlayer(source)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTILITIES --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function displayMessageForPlayers ( ID, message, displayTime, posX, posY, r, g, b, team, displayForAllTeamsButThis )
	assert ( ID and message )
	local easyTextResource = getResourceFromName ( "easytext" )
	displayTime = displayTime or 5000
	posX = posX or 0.5
	posY = posY or 0.5
	r = r or 255
	g = g or 127
	b = b or 0
	if ( team ) then
		-- display message for team(s)
		if ( displayForAllTeamsButThis ) then
			-- display message for every team but the one provided
			for i,v in ipairs ( getElementsByType ( "team" ) ) do
				if ( v ~= team ) then
					displayMessageForPlayers ( ID, message, displayTime, posX, posY, r, g, b, v, false ) -- donno if works?
				end
			end
		else
			-- display message for the team provided
			for i,v in ipairs ( getPlayersInTeam ( team ) ) do
				outputConsole ( message, v )
				call ( easyTextResource, "displayMessageForPlayer", v, ID, message, displayTime, posX, posY, r, g, b )
			end
		end
	else
		-- display message for everyone
		outputConsole ( message, root )
		for i,v in ipairs ( getElementsByType ( "player" ) ) do
			call ( easyTextResource, "displayMessageForPlayer", v, ID, message, displayTime, posX, posY, r, g, b )
		end
	end
end

function displayMessageForPlayer ( player, ID, message, displayTime, posX, posY, r, g, b, scale )
	assert ( player and ID and message )
	local easyTextResource = getResourceFromName ( "easytext" )
	displayTime = displayTime or 5000
	posX = posX or 0.5
	posY = posY or 0.5
	r = r or 255
	g = g or 127
	b = b or 0
	-- display message for everyone
	outputConsole ( message, player )
	call ( easyTextResource, "displayMessageForPlayer", player, ID, message, displayTime, posX, posY, r, g, b, nil, scale )
end

function clearMessageForPlayer ( player, ID )
	assert ( player and ID )
	call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", player, ID )
end
