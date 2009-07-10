--TO DO
-- finish implementing team support
--  make negative annoucements red for teams, positive blue (done?)
--  make each team have a different objective
-- objective not accurate at high speeds
-- reset flag after idle time
-- display who carrier is
-- make enter/exit vehicle events be triggered from client script (why?)
-- too many add event handlers?
-- make vehicle hit detection client-side for the player hitting the orb carrier? (why?)
--SUGGESTIONS
-- don't show objective until orb is picked up
-- don't show objective to other players while someone has orb
--BUG
-- onCarrierEnterVehicle is not always triggered for some unknown reason (should be fixed, updated event name...)
-- onVehicleStartExit_cto not called when falling from bike (fixed?)

local POINT_LIMIT = 1000

local root = getRootElement ()
local mapStarted = false
local teamGame = false
local orbMarker
local objectiveMarker
local orbCarrier
local resetOrbTimer
local runningMapResource

function onGamemodeMapStart_cto ( resource )
	if (not mapStarted) then
	    mapStarted = true
	    runningMapResource = resource
		displayMessage ( "Capture the Orb (debug version)" )
		-- create orb and objective
--outputServerLog("G O ING  TO  RE S E T   ORB !!!!!!!")
	  	resetOrb ()
	  	resetObjective ()
   		-- set players' points to 0
		local players = getElementsByType ( "player" )
		for k,v in ipairs ( players ) do
			setElementData ( v, "points", 0 )
		end
		teamGame = false
		local teams = getElementsByType ( "team" )
		for k,v in ipairs ( teams ) do
			setElementData ( v, "points", 0 )
			if ( not teamGame ) then
				teamGame = true
			end
		end
	end
end
		
function onResourceStart_cto ( resource )
	if ( resource == getThisResource () ) then
		-- add points column to scoreboard if it's already loaded
		local scoreboardResource = getResourceFromName ( "scoreboard" )
		if ( scoreboardResource and getResourceState ( scoreboardResource ) == "running" ) then
		    setTimer ( call, 5000, 1, scoreboardResource, "addScoreboardColumn", "points" )
		    outputDebugString ( "Scoreboard already started: Adding scoreboard column in 5 seconds..." )
		end
	elseif ( resource == getResourceFromName ( "scoreboard" ) ) then
		-- add points column to scoreboard if it just already loaded
	    setTimer ( call, 5000, 1, scoreboardResource, "addScoreboardColumn", "points" )
		outputDebugString ( "Scoreboard just started: Adding scoreboard column in 5 seconds..." )
	end
end -- done

-------------
function onResourceStop_cto ( resource )
	local scoreboardResource = getResourceFromName ( "scoreboard" )
	call ( scoreboardResource, "removeScoreboardColumn", "points" )
end
-------------

addEvent ( "onPlayerClientScriptLoad", true )
function onPlayerClientScriptLoad_cto ()
	if ( orbMarker and not isElementAttached ( orbMarker ) ) then
assert(orbMarker, "from server: orbMarker doesn't exist") -- appears...
assert(isElement(orbMarker), "from server: orbMarker isn't an element")
setTimer ( outputConsole, 1000, 1, "debug: triggering client event doSetOrbHittable for " .. getClientName ( source ) )
		setTimer ( triggerClientEvent, 2500, 1, source, "doSetOrbHittable", root, true, orbMarker ) -- sometimes doesn't exit in client yet?
	end
end -- done

function onPlayerJoin_cto ()
	setElementData ( source, "points", 0 )
end -- done

addEvent ( "onPlayerOrbHit", true )
function onPlayerOrbHit_cto ( marker )
	assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( source ) ), "Orb hitter expected on team but is not" )
	-- make sure the player doesn't already have a marker attached and isn't dead
	-- (the latter might happen if this event is triggered more than once)
	if ( not isElementAttached ( marker ) and not isPlayerDead ( source ) ) then
		local inVehicle = isPlayerInVehicle ( source )
		-- make sure the player didn't just drop the orb from a vehicle
		if ( not inVehicle or ( not getElementData ( source, "justDroppedOrb" ) and getPlayerOccupiedVehicleSeat ( source ) == 0 ) ) then
			triggerClientEvent ( root, "doSetOrbHittable", root, false )
			-- kill the reset timer if it exists
			if ( resetOrbTimer ) then
			    killTimer ( resetOrbTimer )
			    resetOrbTimer = false
			end
   			-- announce that player has orb
   			if ( teamGame ) then
   				--local r, g, b = getTeamColor ( getPlayerTeam ( source ) )
   				displayMessage ( getClientName ( source ) .. " has the orb!", 0, 0, 255, getPlayerTeam ( source ) )
   				displayMessage ( getClientName ( source ) .. " has the orb!", 255, 0, 0, getPlayerTeam ( source ), true )
   			else
   				displayMessage ( getClientName ( source ) .. " has the orb!" )
   			end
			-- increase score
			local pointLimitReached = increasePoints ( source, 20 )
			if ( not pointLimitReached ) then
			    -- attach orb to player
	   			attachElementToElement ( marker, source, 0, 0, 1.25 )
			    -- add events for player
			    addCarrierEvents ( source )
			    -- let the player's client know that he has orb
			    triggerClientEvent ( source, "onClientCarrier", root, true )
			    orbCarrier = source
				outputConsole ( "Deliver the orb to the objective in " .. getZoneName ( getElementPosition ( objectiveMarker ) ) .. "!", source )
				call ( getResourceFromName ( "easytext" ), "displayMessageForPlayer", source, 2, "Deliver the orb to the objective in " .. getZoneName ( getElementPosition ( objectiveMarker ) ) .. "!", 7500, 0.5, 0.535, 147, 112, 219, 255, 1.75 )
			end
		end
	end
end -- done

function onCarrierObjectiveHit ( marker, matchingDimension )
	assert ( orbCarrier == source, "onCarrierObjectiveHit triggered for a non-carrier" )
	assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( source ) ), "Carrier expected on team but is not" )
	if ( marker == objectiveMarker ) then
--		if ( not isPlayerInVehicle ( source ) ) then
	        -- remove events for orb carrier
	        removeCarrierEvents ( source )
			triggerClientEvent ( source, "onClientCarrier", root, false )
	        orbCarrier = nil
		    -- destroy objective
			destroyBlipsAttachedTo ( marker )
			destroyElement ( marker )
	        objectiveMarker = nil
	        -- detach orb from player
	        detachElementFromElement ( orbMarker )
			-- destroy orb
			destroyBlipsAttachedTo ( orbMarker )
			destroyElement ( orbMarker )
	        orbMarker = nil
	        -- increase player health
	        setPlayerHealth ( source, 100 )
	        -- increase vehicle health
	        local vehicle = getPlayerOccupiedVehicle ( source )
	        if ( vehicle and getPlayerOccupiedVehicleSeat ( source ) == 0 ) then
	        	fixVehicle ( vehicle )
	        end
	        -- remove any instructions message the player might have
	        call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", source, 2 )
   			-- announce that player reached the objective
   			if ( teamGame ) then
   				displayMessage ( getClientName ( source ) .. " reached the objective!", 0, 0, 255, getPlayerTeam ( source ) )
   				displayMessage ( getClientName ( source ) .. " reached the objective!", 255, 0, 0, getPlayerTeam ( source ), true )
   			else
   				displayMessage ( getClientName ( source ) .. " reached the objective!" )
   			end
			-- increase score
			local pointLimitReached = increasePoints ( source, 100 )
			if ( not pointLimitReached ) then
			    -- reset orb and objective
	   			setTimer ( resetOrb, 5000, 1 )
	           	setTimer ( resetObjective, 5000, 1 )
			end
--		else
--		    outputChatBox ( "Get out of your vehicle!", source, 147, 112, 219 )
--		end
	end
end -- done

function onCarrierWasted ( ammo, killer, weapon, bodypart )
	assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( source ) ), "Wasted carrier expected on team but is not" )
outputConsole ( "[debug] carrier wasted" )
    -- remove events for orb carrier
	removeCarrierEvents ( source )
	triggerClientEvent ( source, "onClientCarrier", root, false )
    orbCarrier = nil
    -- detach orb from player
    detachElementFromElement ( orbMarker )
    setElementPosition( orbMarker, getElementPosition ( source ) )
    -- make orb hittable
	--addEventHandler ( "onMarkerHit", orbMarker, onOrbHit )
	triggerClientEvent ( root, "doSetOrbHittable", root, true, orbMarker )
	--orbMarkerHittable = true
	-- set reset timer
	resetOrbTimer = setTimer ( destroyAndResetIdleOrb, 300000, 1 )
    -- remove any instructions message the player might have
    call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", source, 2 )
	-- announce that the player dropped the orb
	if ( teamGame ) then
		displayMessage ( getClientName ( source ) .. " dropped the orb!", 255, 0, 0, getPlayerTeam ( source ) )
		displayMessage ( getClientName ( source ) .. " dropped the orb!", 0, 0, 255, getPlayerTeam ( source ), true )
	else
		displayMessage ( getClientName ( source ) .. " dropped the orb!" )
	end
end -- done

-------------
function onCarrierDamage ( attacker, attackerweapon, bodypart, loss )
	if ( attackerweapon == 49 or attackerweapon == 50 ) and loss > 8 then --if they were hit by a vehicle
		assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( source ) ), "Damaged carrier expected on team but is not" )
		outputConsole ( "[debug] carrier damaged" )
	    -- remove events for orb carrier
		removeCarrierEvents ( source )
		triggerClientEvent ( source, "onClientCarrier", root, false )
	    orbCarrier = nil
	    -- detach orb from player
	    detachElementFromElement ( orbMarker )
	    setElementPosition( orbMarker, getElementPosition ( source ) )
	    -- make orb hittable
		--addEventHandler ( "onMarkerHit", orbMarker, onOrbHit )
		triggerClientEvent ( root, "doSetOrbHittable", root, true, orbMarker )
		--orbMarkerHittable = true
		-- set reset timer
		resetOrbTimer = setTimer ( destroyAndResetIdleOrb, 300000, 1 )
        -- remove any instructions message the player might have
        call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", source, 2 )
		-- announce that the player dropped the orb
		if ( teamGame ) then
			displayMessage ( getClientName ( source ) .. " dropped the orb!", 255, 0, 0, getPlayerTeam ( source ) )
			displayMessage ( getClientName ( source ) .. " dropped the orb!", 0, 0, 255, getPlayerTeam ( source ), true )
		else
			displayMessage ( getClientName ( source ) .. " dropped the orb!" )
		end
	end
end -- done
-------------

function onCarrierVehicleEnter ( vehicle, seat, jacked )
outputDebugString ( "adding onCarrierVehicleDamage for " .. getClientName ( source ) .. "..." )
	addEventHandler ( "onVehicleDamage", vehicle, onCarrierVehicleDamage ) -- added when it already exists sometimes
	setElementData ( source, "carrierVehicle", vehicle )
end -- done

function onCarrierVehicleExit ( vehicle, seat, jacker )
	if ( jacker ) then
		assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( jacker ) ), "Jacker expected on team but is not" )
		assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( source ) ), "Old carrier expected on team but is not" )
  		-- remove events for old orb carrier
		removeCarrierEvents ( source )
		triggerClientEvent ( source, "onClientCarrier", root, false )
		orbCarrier = nil
   	 	-- detach orb from old orb carrier
	    detachElementFromElement ( orbMarker )
        -- remove any instructions message the jacked player might have
        call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", source, 2 )
		-- announce that jacker jacked the orb carrier
		if ( teamGame ) then		
			displayMessage ( getClientName ( source ) .. " was jacked by " .. getClientName ( jacker ) .. "!", 0, 0, 255, getPlayerTeam ( jacker ) )
			displayMessage ( getClientName ( source ) .. " was jacked by " .. getClientName ( jacker ) .. "!", 255, 0, 0, getPlayerTeam ( jacker ), true )
		else
			displayMessage ( getClientName ( source ) .. " was jacked by " .. getClientName ( jacker ) .. "!" )
		end
		-- increase score
		local pointLimitReached = increasePoints ( jacker, 20 )
		if ( not pointLimitReached ) then
		    -- attach orb to jacker
	   		attachElementToElement ( orbMarker, jacker, 0, 0, 1.25 )
		    -- add events for jacker
		    addCarrierEvents ( jacker )
	   		-- let the jacker's client know that he has orb
			triggerClientEvent ( jacker, "onClientCarrier", root, true )
		    orbCarrier = jacker
			outputConsole ( "Deliver the orb to the objective in " .. getZoneName ( getElementPosition ( objectiveMarker ) ) .. "!", jacker )
			call ( getResourceFromName ( "easytext" ), "displayMessageForPlayer", jacker, 2, "Deliver the orb to the objective in " .. getZoneName ( getElementPosition ( objectiveMarker ) ) .. "!", 7500, 0.5, 0.535, 147, 112, 219, 255, 1.75 )
		end
	end
	-- in the case where the carrier falls of a bike (ie. onVehicleStartExit isn't triggered, but the player has in fact exitted the vehicle!),
	-- the code below will catch the exit and remove the onCarrierVehicleDamageEvent
	local vehicle = getElementData ( source, "carrierVehicle" )
	if ( vehicle ) then
outputDebugString ( "removing onCarrierVehicleDamage for " .. getClientName ( source ) .. " (caught in onCarrierVehicleExit)" )
		removeEventHandler ( "onVehicleDamage", vehicle, onCarrierVehicleDamage )
		setElementData ( source, "carrierVehicle", false )
	end
end -- done

function onCarrierQuit ( reason )
	assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( source ) ), "Old carrier expected on team but is not" )
    -- destroy objective
	destroyBlipsAttachedTo ( objectiveMarker )
	destroyElement ( objectiveMarker )
	objectiveMarker = nil
    -- detach orb from player
    detachElementFromElement ( orbMarker )
	-- destroy orb
	destroyBlipsAttachedTo ( orbMarker )
	destroyElement ( orbMarker )
    orbMarker = nil
    -- reset orb and objective
	setTimer ( resetOrb, 5000, 1 )
   	setTimer ( resetObjective, 5000, 1 )
	if ( teamGame ) then
		displayMessage ( getClientName ( source ) .. " dropped the orb!", 255, 0, 0, getPlayerTeam ( source ) )
		displayMessage ( getClientName ( source ) .. " dropped the orb!", 0, 0, 255, getPlayerTeam ( source ), true )
	else
		displayMessage ( getClientName ( source ) .. " dropped the orb!" )
	end
end -- done

function onCarrierVehicleDamage ( loss )
outputDebugString("damage: " .. loss)
	if ( loss >= 25 ) then
		assert ( ( not teamGame ) or ( teamGame and getPlayerTeam ( orbCarrier ) ), "Old carrier expected on team but is not" )
	    local player = orbCarrier
  		-- remove events for orb carrier
		removeCarrierEvents ( orbCarrier )
		triggerClientEvent ( orbCarrier, "onClientCarrier", root, false )
		orbCarrier = nil
	 	-- detach orb from player
	    detachElementFromElement ( orbMarker )
	    setElementPosition ( orbMarker, getElementPosition ( player ) )
		-- make orb not hittable to player for 5 seconds
		setElementData ( player, "justDroppedOrb", true )
		setTimer ( setElementData, 5000, 1, player, "justDroppedOrb", false )
	    -- make orb marker hittable
		--addEventHandler ( "onMarkerHit", orbMarker, onOrbHit )
		triggerClientEvent ( root, "doSetOrbHittable", root, true, orbMarker )
		-- set reset timer
		resetOrbTimer = setTimer ( destroyAndResetIdleOrb, 300000, 1 )
		--orbMarkerHittable = true
        -- tell the player he can't pick the orb up for 5 seconds
        call ( getResourceFromName ( "easytext" ), "displayMessageForPlayer", player, 2, "[Five second pickup penalty]", 5000, 0.5, 0.535, 170, 0, 0, 255, 1.75 )
        -- announce that jacker jacked the orb carrier
		if ( teamGame ) then
			displayMessage ( getClientName ( player ) .. " dropped the orb!", 255, 0, 0, getPlayerTeam ( player ) )
			displayMessage ( getClientName ( player ) .. " dropped the orb!", 0, 0, 255, getPlayerTeam ( player ), true )
		else
			displayMessage ( getClientName ( player ) .. " dropped the orb!" )
		end
	end
end -- done

function destroyAndResetIdleOrb ()
	-- kill timer
    resetOrbTimer = false
	-- destroy orb
	destroyBlipsAttachedTo ( orbMarker )
	destroyElement ( orbMarker )
    orbMarker = nil
    -- reset orb
 	setTimer ( resetOrb, 5000, 1 )
	-- display message that orb is being reset
	outputConsole ( "[Reseting orb due to inactivity]" )
	displayMessage ( "[Reseting orb due to inactivity]" )
end

function onPlayerSpawn_cto ( spawnpoint )
    giveWeapon ( source, 22, 250 )
    giveWeapon ( source, 33, 300 )
	giveWeapon ( source, 41, 300 )
    giveWeapon ( source, 18, 4 )
    giveWeapon ( source, 1, 1 )
end -- done

function resetOrb ()
	---MODIFIED FROM ERORR'S ORIGINAL CODE.  More editor compatible, as there's no unnecessary parent group anymore.
	-- get coords from map
	--local runningMap = call(getResourceFromName"mapmanager","getRunningGamemodeMap") -- commented out because this returns nil when resetOrb is called when the gm map is started because mapmanager does not have the gm map set yet at this point.. this is because it triggers the event gm map start event before setting the gm map (currentGamemodeMap is nil at this point) -- erorr404
	local runningMap = runningMapResource
--outputServerLog(tostring(runningMap))
	local mapRoot = getResourceRootElement(runningMap)
	local orbs = getElementsByType ( "orb",mapRoot )
	local orbCount = #orbs
	--outputDebugString ( orbCount .. " orbs total")
	if (orbCount > 0) then
		local orbIndex = math.random ( 1, orbCount )
--outputDebugString ( "orb " .. orbIndex .. " chosen")
		local orbElem = orbs[orbIndex]
		local x = tonumber ( getElementData ( orbElem, "posX" ) )
		local y = tonumber ( getElementData ( orbElem, "posY" ) )
		local z = tonumber ( getElementData ( orbElem, "posZ" ) )
		--outputDebugString("orb: " .. x .. " " .. y .. " " .. z)
		-- create orb
		orbMarker = createMarker ( x, y, z, "corona", .5, 255, 255, 0, 255 )
	 	createBlipAttachedTo ( orbMarker, 56, 3 )
		--addEventHandler ( "onMarkerHit", orbMarker, onOrbHit )
		triggerClientEvent ( root, "doSetOrbHittable", root, true, orbMarker )
		--orbMarkerHittable = true
		return true
	else
	    outputChatBox ( "Error: no orbs" )
	    return false
	end
end -- done

function resetObjective ()
	---MODIFIED FROM ERORR'S ORIGINAL CODE.  More editor compatible, as there's no unnecessary parent group anymore.
	-- get coords from map
	--local runningMap = call(getResourceFromName"mapmanager","getRunningGamemodeMap") -- commented out because this returns nil when resetOrb is called when the gm map is started because mapmanager does not have the gm map set yet at this point.. this is because it triggers the event gm map start event before setting the gm map (currentGamemodeMap is nil at this point) -- erorr404
	local runningMap = runningMapResource
	local mapRoot = getResourceRootElement(runningMap)
	local objectives = getElementsByType ( "objective",mapRoot )
	local objectiveCount = #objectives
	if (objectiveCount > 0) then
	--outputDebugString ( objectiveCount .. " objectives total")
		local objectiveIndex = math.random ( 1, objectiveCount )
	--outputDebugString ( "objective " .. objectiveIndex .. " chosen")
	 	local objectiveElem = objectives[objectiveIndex]
	 	local x = tonumber ( getElementData ( objectiveElem, "posX" ) )
	 	local y = tonumber ( getElementData ( objectiveElem, "posY" ) )
	 	local z = tonumber ( getElementData ( objectiveElem, "posZ" ) )
	 	-- create objective
		objectiveMarker = createMarker ( x, y, z, "cylinder", 3, 147, 112, 219, 170 )
	 	createBlipAttachedTo ( objectiveMarker, 53, 3 )
	 	return true
	else
	    outputChatBox ( "Error: no objectives" )
	    return false
	end
end -- done

function addCarrierEvents ( player )
	addEventHandler ( "onPlayerMarkerHit", player, onCarrierObjectiveHit )
	addEventHandler ( "onPlayerWasted", player, onCarrierWasted )
	addEventHandler ( "onPlayerDamage", player, onCarrierDamage ) -- new event
	local success = addEventHandler ( "onPlayerVehicleEnter", player, onCarrierVehicleEnter ) -- unreliable
	if (not success) then outputDebugString("could not add onPlayerVehicleEnter event for carrier")	end---
	success = addEventHandler ( "onPlayerVehicleExit", player, onCarrierVehicleExit ) -- unreliable -- onPlayerStartExitVehicle?	
	if (not success) then outputDebugString("could not add onPlayerVehicleExit event for carrier")	end---
	addEventHandler ( "onPlayerQuit", player, onCarrierQuit )
	local vehicle = getPlayerOccupiedVehicle ( player )
	if ( vehicle ) then
outputDebugString ( "adding onCarrierVehicleDamage for " .. getClientName ( player ) .. "..." )
		addEventHandler ( "onVehicleDamage", vehicle, onCarrierVehicleDamage )
		setElementData ( player, "carrierVehicle", vehicle )
	end
end -- done

function removeCarrierEvents ( player )
	removeEventHandler ( "onPlayerMarkerHit", player, onCarrierObjectiveHit )
	removeEventHandler ( "onPlayerWasted", player, onCarrierWasted )
	removeEventHandler ( "onPlayerDamage", player, onCarrierDamage ) -- new event
	removeEventHandler ( "onPlayerVehicleEnter", player, onCarrierVehicleEnter )
	removeEventHandler ( "onPlayerVehicleExit", player, onCarrierVehicleExit )
	removeEventHandler ( "onPlayerQuit", player, onCarrierQuit )
	local vehicle = getElementData ( player, "carrierVehicle" )
	if ( vehicle ) then
outputDebugString ( "removing onCarrierVehicleDamage for " .. getClientName ( player ) .. "..." )
		removeEventHandler ( "onVehicleDamage", vehicle, onCarrierVehicleDamage )
		setElementData ( player, "carrierVehicle", false )
	end
end -- done

function increasePoints ( player, points )
	local pointLimitReached = false
	if ( teamGame ) then
		assert ( getPlayerTeam ( player ), "Point increaser expected on team but is not" )
		local team = getPlayerTeam ( player )
		local playerPoints = getElementData ( player, "points" ) + points
		local teamPoints = getElementData ( team, "points" ) + points
		setElementData ( player, "points", playerPoints )
		setElementData ( team, "points", teamPoints )
		if ( teamPoints >= POINT_LIMIT ) then
            setTimer ( endGame, 2500, 1 )
            local r, g, b = getTeamColor ( team )
			displayMessage ( "Point limit reached, " .. getTeamName ( team ) .. " win!", 0, 0, 255, team )
			displayMessage ( "Point limit reached, " .. getTeamName ( team ) .. " win!", 255, 0, 0, team, true )
           	pointLimitReached = true
		end
	else
		local playerPoints = getElementData ( player, "points" ) + points
		setElementData ( player, "points", playerPoints )
		if ( playerPoints >= POINT_LIMIT ) then
            setTimer ( endGame, 2500, 1 )
           	displayMessage ( "Point limit reached, " .. getClientName ( player ) .. " wins!" )
           	pointLimitReached = true
		end
	end
	return pointLimitReached
end

function endGame ()
	forceScoreboardForAllPlayers ( true )
	setTimer ( forceScoreboardForAllPlayers, 8000, 1, false )
	local mapmanagerResource = getResourceFromName ( "mapmanager" )
	if ( mapmanagerResource and getResourceState ( mapmanagerResource ) == "running" ) then
		--setTimer ( call, 10000, 1, mapmanagerResource, "stopGamemode" ) -- server crashes
		setTimer ( outputConsole, 10000, 1, "[Gamemode finished, resource can be stopped]" )
	end
end  -- done

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

-- temp until onPlayerStartExitVehicle
-- not called when falling from bike!?
function onVehicleStartExit_cto ( player, seat, jacker )
	if ( player == orbCarrier ) then
outputDebugString ( "removing onCarrierVehicleDamage for " .. getClientName ( player ) .. "..." )
		removeEventHandler ( "onVehicleDamage", source, onCarrierVehicleDamage )
		setElementData ( player, "carrierVehicle", false )
	end
end

function displayMessage ( message, r, g, b, team, displayForAllTeamsButThis )
	local easyTextResource = getResourceFromName ( "easytext" )
	r = r or 255
	g = g or 255
	b = b or 0
	if ( team ) then
		-- display message for team(s)
		if ( displayForAllTeamsButThis ) then
			-- display message for every team but the one provided
			for i,v in ipairs ( getElementsByType ( "team" ) ) do
				if ( v ~= team ) then
					displayMessage ( message, r, g, b, v )
				end
			end
		else
			-- display message for the team provided
			for i,v in ipairs ( getPlayersInTeam ( team ) ) do
				outputConsole ( message, v )
				call ( easyTextResource, "displayMessageForPlayer", v, 1, message, 5000, 0.5, 0.5, r, g, b )
			end
		end
	else
		-- display message for everyone
		outputConsole ( message, root )
		for i,v in ipairs ( getElementsByType ( "player" ) ) do
			call ( easyTextResource, "displayMessageForPlayer", v, 1, message, 5000, 0.5, 0.5, r, g, b )
		end
	end
end

addEventHandler ( "onGamemodeMapStart", root, onGamemodeMapStart_cto )
addEventHandler ( "onResourceStart", root, onResourceStart_cto )
addEventHandler ( "onResourceStop", getResourceRootElement(getThisResource()), onResourceStop_cto )
addEventHandler ( "onPlayerClientScriptLoad", root, onPlayerClientScriptLoad_cto )
addEventHandler ( "onPlayerJoin", root, onPlayerJoin_cto )
addEventHandler ( "onPlayerOrbHit", root, onPlayerOrbHit_cto )
addEventHandler ( "onPlayerSpawn", root, onPlayerSpawn_cto )
addEventHandler ( "onVehicleStartExit", root, onVehicleStartExit_cto )

function destroyBlipsAttachedTo ( player )
	local attached = getAttachedElements ( player )
	if ( attached ) then
		for k,element in ipairs(attached) do
			if getElementType ( element ) == "blip" then
				destroyElement ( element )
			end
		end
	end
end