--TO DO
-- prevent teams for cheating to get points: (done)
--  don't give them points from jacking the orb from eachother's cars
--  limit points after drop.. e.g. they only get the 20 the first couple of times they pick up a particular briefcase (make this for non-teams as well?)
-- make bike fall-off make you drop briefcase!! (or whenever startExit doesn't trigger and only exit triggers? so for all involuntary exits...) (done)
-- make it so... the faster the vehicle, the easier it drops (or classify into: coupes, sedans, old cars, trucks, big trucks, etc)
-- add spray shops for vehicle repairs, or repair pickups?
-- add weapon pickups (randomly placed?)
-- add a volatility meter client-side so people see how easily they can drop the orb (waiting on paths to get fixed)
-- put stuff into settings and make some of it adjustable in the middle of the game (hiding/showing destiantion to players, etc.) (waiting on paths to get fixed)
-- finish implementing team support
--  make each team have a different objective
--  make negative annoucements red for teams, positive blue (done?)
-- display who carrier is
-- objective not accurate at high speeds (or is it?)
-- reset flag after idle time (done?)
-- make enter/exit vehicle events be triggered from client script (why?)
-- too many add event handlers? (huh?)
-- make vehicle hit detection client-side for the player hitting the orb carrier? (why?)
--SUGGESTIONS
-- don't show objective until orb is picked up
-- don't show objective to other players while someone has orb
--BUG
-- onCarrierEnterVehicle is not always triggered for some unknown reason (should be fixed, updated event name...)
-- onVehicleStartExit_br not called when falling from bike (fixed?)

-- client events:
--  clientGiveBriefcaseToPlayer
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

root = getRootElement()
mapStarted = false
teams = {} -- used for team game, the participating teams
settings = {	limit = 1000, teams = false, hide = false, reset = 300,
				weapons = {[1] = 1, [22] = 200, [17] = 4, [29] = 250}	}
theBriefcase = nil
theObjective = nil
teamObjectives = {}
--local state = {	briefcase = false, objective = false, carrier = false	} -- game stat flags
--local briefcasePosition = {x = 0, y = 0, z = 0}
--local objectivePosition = {x = 0, y = 0, z = 0}
--local teamObjectivePosition = {} -- used for team game, the objectives of each team
--local carrier = false -- player element of guy who has briefcase
local lastCarrier = false -- sets on carrier run over, jacked, bike fall, vehicle damage. clears on last carrier quit, briefcase reset, briefcase deliver, add carrier.
local resetBriefcaseTimer

-- element data:
--  carrierVehicle - 'false' if carrier doesn't have vehicle events attached (onCarrierVehicleDamage), 'vehicle' if carrier's vehicle still has events attached
--  justDroppedBriefcase - 'true' if carrier just dropped the orb and is given a penalty, 'false' if not (used to prevent player from picking up the orb the instant after he dropped it)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
function (resource)

	local resourceRoot = getResourceRootElement(resource)

	addEvent("onPlayerReady", true)
	addEvent("onPlayerBriefcaseHit", true)
	addEvent("onPlayerObjectiveHit", true)

	addEventHandler( "onResourceStart", root,			onResourceStart_br)
	addEventHandler( "onResourceStop", resourceRoot,	onResourceStop_br)
	addEventHandler( "onGamemodeMapStart", root,		onGamemodeMapStart_br)
	addEventHandler( "onPlayerJoin", root,				onPlayerJoin_br)
	addEventHandler( "onPlayerJoin", root,				onPlayerJoinCheckReady_br)
	addEventHandler( "onPlayerSpawn", root, 			onPlayerSpawn_br)

	addEventHandler( "onVehicleStartExit", root, 		onVehicleStartExit_br)

	addEventHandler( "onPlayerBriefcaseHit", root,		onPlayerBriefcaseHit_br)
	addEventHandler( "onPlayerObjectiveHit", root,		onPlayerObjectiveHit_br)

	addEventHandler( "onPlayerQuit", root,				onPlayerQuit_br)
end
)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS MANAGEMENT --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- adds 'points' column to scoreboard
function onResourceStart_br ( resource )
	if ( resource == getThisResource () ) then
		-- add points column to scoreboard if it's already loaded
		local scoreboardResource = getResourceFromName ( "scoreboard" )
		if ( scoreboardResource and getResourceState ( scoreboardResource ) == "running" ) then
		    setTimer ( call, 5000, 1, scoreboardResource, "addScoreboardColumn", "points" )
		    outputDebugString ( "Scoreboard already started: Adding points column in 5 seconds..." )
		end
	elseif ( resource == getResourceFromName ( "scoreboard" ) ) then
		-- add points column to scoreboard if it just already loaded
	    setTimer ( call, 5000, 1, scoreboardResource, "addScoreboardColumn", "points" )
		outputDebugString ( "Scoreboard just started: Adding points column in 5 seconds..." )
	end
end

-- removes 'points' column from scoreboard
function onResourceStop_br ( resource )
	local scoreboardResource = getResourceFromName ( "scoreboard" )
	call ( scoreboardResource, "removeScoreboardColumn", "points" )
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GAME SETUP --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- gets settings
-- creates a briefcase and an objective and sets player points to 0 when map starts
function onGamemodeMapStart_br(resource)
	if (mapStarted) then
	else
	    mapStarted = true
		displayMessageForPlayers(1, "Briefcase Race")
		-- get settings
		readSettingsFile(resource)
		-- create briefcase and objective
	  	resetBriefcase(resource)
	  	resetObjective(resource)
   		-- set players' points to 0
		local players = getElementsByType("player")
		for k,v in ipairs(players) do
			setElementData(v, "points", 0)
		end
		-- store teams and set their points to 0
		if (settings.teams) then
			teams = getElementsByType("team")
			for i,v in ipairs(teams) do
				setElementData(v, "points", 0)
			end
		end
		addEventHandler("onPlayerReady", root, onPlayerReady_br) -- only called from server
	end
end

-- sets player's points to 0 when they join
function onPlayerJoin_br()
	if (mapStarted) then
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
            setTimer(endGame, 2500, 1)
            local r, g, b = getTeamColor(team)
			displayMessageForPlayers(1, "Point limit reached, team " .. getTeamName ( team ) .. " wins!", nil, nil, nil, 0, 0, 255, team)
			displayMessageForPlayers(1, "Point limit reached, team " .. getTeamName ( team ) .. " wins!", nil, nil, nil, 255, 0, 0, team, true)
           	pointLimitReached = true
		end
	else
		local playerPoints = getElementData(player, "points") + points
		setElementData(player, "points", playerPoints)
		if (playerPoints >= settings.limit) then
            setTimer(endGame, 2500, 1)
			displayMessageForPlayers(1, "Point limit reached, " .. getPlayerName ( player ) .. " wins!")
           	pointLimitReached = true
		end
	end
	return pointLimitReached
end

-- shows scoreboard to all players and then stops the game mode
function endGame()
	forceScoreboardForAllPlayers(true)
	setTimer(forceScoreboardForAllPlayers, 8000, 1, false)
	addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), onStopSetScoreboardNotForced)
	setTimer(removeEventHandler, 8000, 1, "onResourceStop", getResourceRootElement(getThisResource()), onStopSetScoreboardNotForced)
	local mapmanagerResource = getResourceFromName("mapmanager")
	if (mapmanagerResource and getResourceState(mapmanagerResource) == "running") then
		setTimer(outputConsole, 9000, 1, "[Gamemode finished]")
		setTimer(call, 10000, 1, mapmanagerResource, "stopGamemode") -- server crashes?
	end
end

function onStopSetScoreboardNotForced(resource)
	forceScoreboardForAllPlayers(false)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER SETUP --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- give player weapons when they spawn
function onPlayerSpawn_br(spawnpoint)
	for k,v in pairs(settings.weapons) do
		giveWeapon(source, k, v)
	end
    setPedFightingStyle(source, 6)
end

-- if teams display team menu for this player
-- if no teams, trigger ready event right away
function onPlayerJoinCheckReady_br()
	if (not settings.team) then
		triggerEvent("onPlayerReady", source)
	else
		-- show a team menu ... when they choose team we spawn them and add the ready event
	end
end

-- creates briefcase and objective for new player (if needed) to bring the current state of the game
-- called when a player becomes a 'valid' player who can play
--  for team game, must be called right after player joins team
--  for non-team game, can be called onPlayerJoin
function onPlayerReady_br()

	-- create a briefcase if it exists
	if (theBriefcase) then
		if (theBriefcase:getCarrier()) then -- carried
			scheduleClientEvent(source, "clientGiveBriefcaseToPlayer", carrier)
		elseif (theBriefcase:isIdle()) then -- idle
			local x, y, z = theBriefcase:getPosition()
			scheduleClientEvent(source, "clientCreateIdleBriefcase", root, x, y, z)
		end
	end

	-- create objective if it exists
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
	
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GAME EVENTS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- game event - player hits the briefcase
function onPlayerBriefcaseHit_br()
	assert(theBriefcase and theBriefcase:isIdle(), "blah blah blah")---asserts, but it's ok since client has multiple hits in one short period
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
	-- make sure the player isn't dead (the latter might be the case if this event is triggered more than once)
	if (not isPedDead(source)) then
		local inVehicle = isPedInVehicle(source)
		-- make sure the player didn't just drop the orb from a vehicle and isn't a passenger
		if (not getElementData(source, "justDroppedBriefcase") and (not inVehicle or getPedOccupiedVehicleSeat(source) == 0 )) then
			addCarrier(source)
			-- announce that player has orb
			if (settings.teams) then
				--local r, g, b = getTeamColor ( getPlayerTeam ( source ) )
				displayMessageForPlayers(1, getPlayerName(source) .. " has the briefcase!", nil, nil, nil, 0, 0, 255, getPlayerTeam(source))
				displayMessageForPlayers(1, getPlayerName(source) .. " has the briefcase!", nil, nil, nil, 255, 0, 0, getPlayerTeam(source), true)
			else
				displayMessageForPlayers(1, getPlayerName(source) .. " has the briefcase!")
			end
		end
	end
end

-- game event - player delivers the briefcase
function onPlayerObjectiveHit_br()
		assert(theBriefcase and theBriefcase:getCarrier() == source, "blah blah blah")---asserts, but it's ok since client has multiple hits in one short period
		assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
	--	if ( not isPlayerInVehicle ( source ) ) then
			removeCarrier(source, 2)
	        -- increase player health
	        setPlayerHealth(source, 100)
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
			local pointLimitReached = increasePoints(source, 100)
			if (not pointLimitReached) then
			    -- reset orb and objective
	   			setTimer(resetBriefcase, 5000, 1)
	           	setTimer(resetObjective, 5000, 1)
			end
	--	else
	--	    outputChatBox ( "Get out of your vehicle!", source, 147, 112, 219 )
	--	end
end

-- game event - carrier dies
function onCarrierWasted(ammo, killer, weapon, bodypart)
	assert(theBriefcase and theBriefcase:getCarrier() == source, "blah blah blah")
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
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
	assert(theBriefcase and theBriefcase:getCarrier() == source, "blah blah blah")
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
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
		assert(theBriefcase and theBriefcase:getCarrier() == source, "blah blah blah")
		assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
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
		-- set him to lastCarrier
		lastCarrier = source
        -- tell the player he can't pick the orb up for 5 seconds
		displayMessageForPlayer(source, 2, "[Five second pickup penalty]", 5000, 0.5, 0.535, 170, 0, 0, 1.75)
	end
end

-- game event - carrier enters vehicle
-- adds vehicle damage event
function onCarrierVehicleEnter(vehicle, seat, jacked)
	addEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage) -- added when it already exists sometimes
	setElementData(source, "carrierVehicle", vehicle)
end

-- game event - someone starts to exit their vehicle
-- if that someone is the carrier, remove vehicle damage event
-- Note0: we need to remove the onVehicleDamage event handler when the carrier STARTS to exit the vehicle because otherwise, if he jumps
--  out and the vehicle hits a wall, the orb will still drop, since the handler wasn't removed yet (because onPlayerVehicleExit was used
--  which gets triggered too late)
-- Note1: a better option would be to use onPlayerStartVehicleExit as we could attach it to the carrier, but this event does not exist
-- Note2: this function is not called sometimes, like when falling off a bike, so there is also a check in onCarrierVehicleExit
function onVehicleStartExit_br(player, seat, jacker)
	if (theBriefcase and theBriefcase:getCarrier() and player == theBriefcase:getCarrier()) then
		assert(not settings.teams or isPlayerOnValidTeam(player), "Player not on valid team")
		-- remove vehicle damage
		removeEventHandler("onVehicleDamage", source, onCarrierVehicleDamage)
		setElementData(player, "carrierVehicle", false)
	end
end

-- game event - carrier fully exits the vehicle, possibly jacked
-- if jacked:
--  removes carrier events from jacked, makes jacked carrier not a carrier, detaches orb marker from jacked
--  increases jacker's score, attaches orb to jacker, adds carrier events to jacker, makes jacker a carrier
-- removes vehicle damage handler if it wasn't already removed (this can happen in the case of falling off a bike, for example)
function onCarrierVehicleExit(vehicle, seat, jacker)
	assert(theBriefcase and theBriefcase:getCarrier() == source, "blah blah blah")
	assert(not settings.teams or isPlayerOnValidTeam(source), "Player not on valid team")
	if (jacker) then
		assert(not settings.teams or isPlayerOnValidTeam(jacker), "Player not on valid team")
  		removeCarrier(source, 0)
		addCarrier(jacker)
		---- set him to lastCarrier
		--lastCarrier = source
		-- remove any instructions message the jacked player might have
		clearMessageForPlayer(source, 2)
		-- announce that jacker jacked the orb carrier
		if (teamGame) then
			displayMessageForPlayers(1, getPlayerName(jacker) .. " stole the briefcase from " .. getPlayerName(source) .. "!", nil, nil, nil, 0, 0, 255, getPlayerTeam(jacker))
			displayMessageForPlayers(1, getPlayerName(jacker) .. " stole the briefcase from " .. getPlayerName(source) .. "!", nil, nil, nil, 255, 0, 0, getPlayerTeam(jacker), true)
		else
			displayMessageForPlayers(1, getPlayerName(jacker) .. " stole the briefcase from " .. getPlayerName(source) .. "!")
		end
	elseif (getElementData(source, "carrierVehicle")) then
		-- NEW -- make him drop the briefcase and give him a pickup penalty (this usually happens when he falls of a bike, or in any other case where onStartExit doesn't get triggered first)
		------------------------------------
		removeCarrier(source, 1)
		-- set him to lastCarrier
		lastCarrier = source
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
		removeEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage)
		setElementData(source, "carrierVehicle", false)
	end
end

-- game event - carrier's vehicle gets damaged
-- makes orb not pickup-able by this player for 5 seconds, makes player drop orb
function onCarrierVehicleDamage(loss)
--outputDebugString("damage: " .. loss)
	-- dropLoss is the least amount of damage that needs to be done to drop the orb           
	--local dropLoss = 25 -- old value
	--local dropLoss = (getElementHealth(source) + loss)^3/5000000 -- make it a function of current vehicle health - if healthy, more damage is required to drop orb, if unhealthy, less damage is required 
	-- dropLoss = the minimum health loss required in order to drop the briefcase: a function of the vehicle type and it's health
	local dropLoss = getDropLossFromHealth(source, getElementHealth(source) + loss)
	if (loss >= dropLoss) then
		assert(theBriefcase and theBriefcase:getCarrier(), "blah blah blah")
		local player = theBriefcase:getCarrier()
		assert(not settings.teams or isPlayerOnValidTeam(player), "Player not on valid team")
		removeCarrier(player, 1)
		-- set him to lastCarrier
		lastCarrier = player
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

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CARRIER MANAGEMENT FUNCTIONS --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1) removes old briefcase, 2) creates new briefcase for player, 3) makes objective hittable
function addCarrier(player)
	-- kill the reset timer if it exists
	if (resetBriefcaseTimer) then
		killTimer(resetBriefcaseTimer)
		resetBriefcaseTimer = false
	end
	
	-- block this player's points if he was lastCarrier, reset lastCarrier
	local blockPoints = false
	if (lastCarrier) then
		if (not settings.teams) then
			if (lastCarrier == player) then
				blockPoints = true
			end
		else
			if (getPlayerTeam(lastCarrier) == getPlayerTeam(player)) then
				blockPoints = true
			end
		end
		lastCarrier = false
	end
	
	local pointLimitReached = false
	if (not blockPoints) then
		-- increase score
		pointLimitReached = increasePoints(player, 20)
	end
	
	if (not pointLimitReached) then
		-- remove old briefcase
		if (theBriefcase:isIdle()) then
			theBriefcase:notIdle()
		elseif (theBriefcase:getCarrier()) then
			theBriefcase:detach()
		end
		-- attach briefcase to player
		theBriefcase:attach(player)
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
			local x, y, z = objectives[team]:getPosition()
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
		resetBriefcaseTimer = setTimer(destroyAndResetIdleBriefcase, settings.reset*1000, 1)
	elseif ( action == 2 ) then
		-- destroy briefcase
		theBriefcase:destroy()
		theBriefcase = nil
		-- destroy objective(s)
		if (not settings.teams) then
			theObjective:destroy()
			theObjective = nil
		else
			assert(isPlayerOnValidTeam(source), "Player not on valid team")
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
			assert(isPlayerOnValidTeam(source), "Player not on valid team")
			for i,v in ipairs(teams) do
				teamObjectives[v]:destroy()
				teamObjectives[v] = nil
			end
		end
		-- reset orb and objective
		setTimer(resetBriefcase, 5000, 1)
		setTimer(resetObjective, 5000, 1)
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
		addEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage)
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
		removeEventHandler("onVehicleDamage", vehicle, onCarrierVehicleDamage)
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
    resetBriefcaseTimer = false
	-- destroy briefcase
	theBriefcase:notIdle()
    -- reset briefcase
 	setTimer(resetBriefcase, 5000, 1)
	-- reset lastCarrier if exists
	if (lastCarrier) then
		lastCarrier = false
	end
	-- display message that orb is being reset
	displayMessageForPlayers(1, "[Reseting briefcase due to inactivity]")
end

-- chooses a random briefcase spawn location from map file, creates idle briefcase
function resetBriefcase(runningMapResource)
	---MODIFIED FROM ERORR'S ORIGINAL CODE.  More editor compatible, as there's no unnecessary parent group anymore.
	-- get coords from map
	--local runningMap = call(getResourceFromName"mapmanager","getRunningGamemodeMap") -- commented out because this returns nil when resetOrb is called when the gm map is started because mapmanager does not have the gm map set yet at this point.. this is because it triggers the event gm map start event before setting the gm map (currentGamemodeMap is nil at this point) -- erorr404
	local runningMap = runningMapResource or exports.mapmanager:getRunningGamemodeMap()
--outputServerLog(tostring(runningMap))
	local mapRoot = getResourceRootElement(runningMap)
	local briefcases = getElementsByType("briefcase", mapRoot) -- changed from orb to briefcase
	local briefcaseCount = #briefcases
	--outputDebugString ( briefcaseCount .. " briefcases total")---
	if (briefcaseCount > 0) then
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
function resetObjective(runningMapResource)
	---MODIFIED FROM ERORR'S ORIGINAL CODE.  More editor compatible, as there's no unnecessary parent group anymore.
	-- get coords from map
	--local runningMap = call(getResourceFromName"mapmanager","getRunningGamemodeMap") -- commented out because this returns nil when resetOrb is called when the gm map is started because mapmanager does not have the gm map set yet at this point.. this is because it triggers the event gm map start event before setting the gm map (currentGamemodeMap is nil at this point) -- erorr404
	local runningMap = runningMapResource or exports.mapmanager:getRunningGamemodeMap()
	local mapRoot = getResourceRootElement(runningMap)
	local objectives = getElementsByType("objective", mapRoot)
	local objectiveCount = #objectives
	if (objectiveCount > 0) then
		--outputDebugString(objectiveCount .. " objectives total")---
		local objectiveIndex = math.random ( 1, objectiveCount )
		--outputDebugString("objective " .. objectiveIndex .. " chosen")---
	 	local objectiveElem = objectives[objectiveIndex]
	 	local x = tonumber(getElementData(objectiveElem, "posX"))
	 	local y = tonumber(getElementData(objectiveElem, "posY"))
	 	local z = tonumber(getElementData(objectiveElem, "posZ"))
		--outputDebugString("objective: " .. x .. " " .. y .. " " .. z)---
	 	-- create objective
		if (not settings.teams) then
			theObjective = Objective:new({x = x, y = y, z = z})
		else
			for i,v in ipairs(teams) do
				teamObjectives[v] = Objective:new({x = x, y = y, z = z, team = v})
			end
		end
	 	return true
	else
	    outputChatBox("Error: no objectives")
	    return false
	end
end

function onPlayerQuit_br(quitType, reason, responsibleElement)
	if (lastCarrier and lastCarrier == source) then
		lastCarrier = false
	end
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
	g = g or 255
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
	g = g or 255
	b = b or 0
	-- display message for everyone
	outputConsole ( message, player )
	call ( easyTextResource, "displayMessageForPlayer", player, ID, message, displayTime, posX, posY, r, g, b, nil, scale )
end

function clearMessageForPlayer ( player, ID )
	assert ( player and ID )
	call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", player, ID )
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

function readSettingsFile(resource)
	local settingsRoot = xmlLoadFile("settings.xml", resource)
	if (settingsRoot) then
		-- get point limit
		local node, val
		node = xmlFindChild(settingsRoot, "pointlimit", 0)
		if (node) then
			val = xmlNodeGetValue(node)
			if (val and tonumber(val)) then
				settings.limit = tonumber(val)
				outputDebugString("pointlimit read from settings.xml " .. val)
			end
		end
		-- get team game
		node = xmlFindChild(settingsRoot, "teamgame", 0)
		if (node) then
			val = xmlNodeGetValue(node)
			if (val and tonumber(val)) then
				if (val == "0") then
					settings.teams = false
					outputDebugString("teamgame read from settings.xml " .. val)
				elseif (val == "1") then
					settings.teams = true
					outputDebugString("teamgame read from settings.xml " .. val)
				end
			end
		end
		-- get hide objective
		node = xmlFindChild(settingsRoot, "hideobj", 0)
		if (node) then
			val = xmlNodeGetValue(node)
			if (val and tonumber(val)) then
				if (val == "0") then
					settings.hide = false
					outputDebugString("hideobj read from settings.xml " .. val)
				elseif (val == "1") then
					settings.hide = true
					outputDebugString("hideobj read from settings.xml " .. val)
				end
			end
		end
		-- get point limit
		node = xmlFindChild(settingsRoot, "idletime", 0)
		if (node) then
			val = xmlNodeGetValue(node)
			if (val and tonumber(val)) then
				settings.reset = tonumber(val)
				outputDebugString("idletime read from settings.xml: " .. val)
			end
		end
		-- get spawn weapons
		node = xmlFindChild(settingsRoot, "weapons", 0)
		if (node) then
			settings.weapons = {}
			local children = xmlNodeGetChildren(node)
			if (children) then
				for i,v in ipairs(children) do
					local id = xmlNodeGetAttribute(v, "id")
					local ammo = xmlNodeGetAttribute(v, "ammo")
					id = tonumber(id)
					ammo = tonumber(ammo)
					if (id and ammo) then
						settings.weapons[id] = ammo
						outputDebugString("weapon read from settings.xml: " .. id .. ":" .. ammo)
					end
				end
			end
		end
		xmlUnloadFile(settingsRoot)
	end
end

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

function getReadyPlayers()
	-- generate array of ready players
	if (not settings.teams) then
		return getElementsByType("player")
	else
		local playerTable = {}
		for i,team in ipairs(getElementsByType("team")) do
			if (isTeamValid(team)) then
				for j,player in ipairs(getPlayersInTeam(team)) do
					table.insert(playerTable, player)
				end
			end
		end
		return playerTable
	end
end
