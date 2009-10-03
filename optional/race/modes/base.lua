RaceMode = {}
RaceMode.__index = RaceMode

RaceMode.registeredModes = {}
RaceMode.instances = {}

function RaceMode:register(name)
	RaceMode.registeredModes[name] = self
	self.name = name
end

function RaceMode.getApplicableMode()
	for modeName,mode in pairs(RaceMode.registeredModes) do
		if mode:isApplicable() then
			return mode
		end
	end
	return RaceMode
end

function RaceMode:getName()
	return self.name
end

function RaceMode.getCheckpoints()
	return g_Checkpoints
end

function RaceMode.getCheckpoint(i)
	return g_Checkpoints[i]
end

function RaceMode.getNumberOfCheckpoints()
	return #g_Checkpoints
end

function RaceMode.checkpointsExist()
	return #g_Checkpoints > 0
end

function RaceMode.getSpawnpoints()
	return g_Spawnpoints
end

function RaceMode.getNumberOfSpawnpoints()
	return #g_Spawnpoints
end

function RaceMode.getSpawnpoint(i)
	return g_Spawnpoints[i]
end

function RaceMode.getMapOption(option)
	return g_MapOptions[option]
end

function RaceMode.getPlayers()
	return g_Players
end

function RaceMode.setPlayerIsFinished(player)
	setPlayerFinished(player, true)
end

function RaceMode.isPlayerFinished(player)
	return isPlayerFinished(player)
end

function RaceMode.getPlayerVehicle(player)
	return g_Vehicles[player]
end

function RaceMode:setTimeLeft(timeLeft)
	if g_MapOptions.duration - self:getTimePassed() > timeLeft then
		g_MapOptions.duration = self:getTimePassed() + timeLeft
        g_RaceEndTimer:killTimer()
		g_RaceEndTimer:setTimer(raceTimeout, timeLeft, 1)
		clientCall(g_Root, 'setTimeLeft', timeLeft)
	end
end

function RaceMode.endMap()
    if stateAllowsPostFinish() then
        gotoState('PostFinish')
        local text = g_GameOptions.randommaps and 'Next map starts in:' or 'Vote for next map starts in:'
        Countdown.create(5, RaceMode.startNextMapSelect, text, 255, 255, 255):start()
		triggerEvent('onPostFinish', g_Root)
    end
end

function RaceMode.startNextMapSelect()
	if stateAllowsNextMapSelect() then
		gotoState('NextMapSelect')
		Countdown.destroyAll()
		destroyAllMessages()
		if g_GameOptions.randommaps then
			startRandomMap()
		else
			startNextMapVote()
		end
	end
end

-- Default functions

function RaceMode.isApplicable()
	return false
end

function RaceMode:create()
	local id = #RaceMode.instances + 1
	RaceMode.instances[id] = setmetatable(
		{
			id = id,
			checkpointBackups = {},  -- { player = { goingback = true/false, i = { vehicle = id, position = {x, y, z}, rotation = {x, y, z}, velocity = {x, y, z} } } }
			activePlayerList = {},
			finishedPlayerList = {},
		},
		self
	)
	return RaceMode.instances[id]
end

function RaceMode:launch()
	self.startTick = getTickCount()
	for _,spawnpoint in ipairs(RaceMode.getSpawnpoints()) do
		spawnpoint.used = nil
	end
	-- Put all relevant players into the active player list
	for _,player in ipairs(getElementsByType("player")) do
		if not isPlayerFinished(player) then
			addActivePlayer( player )
		end
	end
end

function RaceMode:getTimePassed()
	if self.startTick then
		return getTickCount() - self.startTick
	else
		return 0
	end
end

function RaceMode:getTimeRemaining()
	if self.startTick then
		return self.startTick + g_MapOptions.duration - getTickCount()
	else
		return 0
	end
end

function RaceMode:isRanked()
	return true
end

function RaceMode:getPlayerRank(queryPlayer)
	local rank = 1
	local queryCheckpoint = getPlayerCurrentCheckpoint(queryPlayer)
	local checkpoint

	-- Figure out rank amoung the active players
	for i,player in ipairs(getActivePlayers()) do
		if player ~= queryPlayer then
			checkpoint = getPlayerCurrentCheckpoint(player)
			if RaceMode.isPlayerFinished(player) or checkpoint > queryCheckpoint then
				rank = rank + 1
			elseif checkpoint == queryCheckpoint then
				if distanceFromPlayerToCheckpoint(player, checkpoint) < distanceFromPlayerToCheckpoint(queryPlayer, checkpoint) then
					rank = rank + 1
				end
			end
		end
	end

	-- Then add on the players that have finished
	rank = rank + getFinishedPlayerCount()
	return rank
end

function RaceMode:onPlayerJoin(player, spawnpoint)
	self.checkpointBackups[player] = {}
	self.checkpointBackups[player][0] = { vehicle = spawnpoint.vehicle, position = spawnpoint.position, rotation = {0, 0, spawnpoint.rotation}, velocity = {0, 0, 0}, turnvelocity = {0, 0, 0}, geardown = true }
end

function RaceMode:onPlayerReachCheckpoint(player, checkpointNum)
	local rank = self:getPlayerRank(player)
	local time = self:getTimePassed()
	if checkpointNum < RaceMode.getNumberOfCheckpoints() then
		-- Regular checkpoint
		local vehicle = RaceMode.getPlayerVehicle(player)
		self.checkpointBackups[player][checkpointNum] = { vehicle = getElementModel(vehicle), position = { getElementPosition(vehicle) }, rotation = { getVehicleRotation(vehicle) }, velocity = { getElementVelocity(vehicle) }, turnvelocity = { getVehicleTurnVelocity(vehicle) }, geardown = getVehicleLandingGearDown(vehicle) or false }		
		
		self.checkpointBackups[player].goingback = true
		if self.checkpointBackups[player].timer then
			killTimer(self.checkpointBackups[player].timer)
		end
		self.checkpointBackups[player].timer = setTimer(lastCheckpointWasSafe, 5000, 1, self.id, player)
	else
		-- Finish reached
		RaceMode.setPlayerIsFinished(player)
		finishActivePlayer( player )
		setPlayerStatus( player, nil, "finished" )
		if rank == 1 then
            gotoState('SomeoneWon')
			showMessage('You have won the race!', 0, 255, 0, player)
			if self.rankingBoard then	-- Remove lingering labels
				self.rankingBoard:destroy()
			end
			self.rankingBoard = RankingBoard:create()
			if g_MapOptions.duration then
				self:setTimeLeft( g_GameOptions.timeafterfirstfinish )
			end
		else
			showMessage('You finished ' .. rank .. ( (rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th' ) .. '!', 0, 255, 0, player)
		end
		--Output a killmessage
		exports.killmessages:outputMessage(
			{
				{"image",path="img/killmessage.png",resource=getThisResource(),width=24},
				getPlayerName(player),
			},
			g_Root,
			255,0,0
		)
		self.rankingBoard:add(player, time)
		if getActivePlayerCount() > 0 then
			setTimer(clientCall, 5000, 1, player, 'Spectate.start', 'auto')
		else
			setTimer(
				function()
					gotoState('EveryoneFinished')
					self:setTimeLeft( 0 )
					RaceMode.endMap()
				end,
				50, 1 )
		end
	end
	return rank, time
end

function lastCheckpointWasSafe(id, player)
	if not isValidPlayer(player) then
		return
	end
	local self = RaceMode.instances[id]
	if self.checkpointBackups[player] then
		self.checkpointBackups[player].goingback = false
		self.checkpointBackups[player].timer = nil
	end
end

function isValidPlayer(player)
 	return g_Players and table.find(g_Players, player)
end

function isValidPlayerVehicle(player,vehicle)
	if isValidPlayer(player) then
		if vehicle and g_Vehicles[player] == vehicle then
			return true
		end
	end
	return false
end


function RaceMode:onPlayerWasted(player)
	if not self.checkpointBackups[player] then
		return
	end
	if self.checkpointBackups[player].timer then
		killTimer(self.checkpointBackups[player].timer)
		self.checkpointBackups[player].timer = nil
	end
	if RaceMode.getMapOption('respawn') == 'timelimit' and not RaceMode.isPlayerFinished(source) then
        -- See if its worth doing a respawn
        local respawnTime       = RaceMode.getMapOption('respawntime')
        if self:getTimeRemaining() - respawnTime > 3000 then
            Countdown.create(respawnTime/1000, restorePlayer, 'You will respawn in:', 255, 255, 255, self.id, player):start(player)
        end
	    if RaceMode.getMapOption('respawntime') >= 10000 then
		    setTimer(clientCall, 2000, 1, player, 'Spectate.start', 'auto')
	    end
	end
	if g_MapOptions.respawn == 'none' then
		removeActivePlayer( player )
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			RaceMode.endMap()
		end
	end
end


function distanceFromVehicleToSpawnpoint(vehicle, spawnpoint)
    if vehicle then
	    local x, y, z = getElementPosition(vehicle)
	    return getDistanceBetweenPoints3D(x, y, z, unpack(spawnpoint.position))
    end
    return 0
end

function getSpaceAroundSpawnpoint(ignore,spawnpoint)
    local space = 100000
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			space = math.min(space, distanceFromVehicleToSpawnpoint(g_Vehicles[player], spawnpoint))
		end
    end
    return space
end

function hasSpaceAroundSpawnpoint(ignore,spawnpoint, requiredSpace)
    for i,player in ipairs(g_Players) do
		if player ~= ignore then
			if distanceFromVehicleToSpawnpoint(g_Vehicles[player], spawnpoint) < requiredSpace then
				return false
			end
        end
    end
    return true
end

function RaceMode:pickFreeSpawnpoint(ignore)
    -- Use the spawnpoints from #1 to #numplayers as a pool to use
    local numToScan = math.min(getPlayerCount(), #g_Spawnpoints)
    -- Starting at a random place in the pool...
    local scanPos = math.random(1,numToScan)
    -- ...loop through looking for a free spot
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        if hasSpaceAroundSpawnpoint(ignore,g_Spawnpoints[idx], 1) then
            return g_Spawnpoints[idx]
        end
    end
    -- If one can't be found, find the spot which has the most space
    local bestSpace = 0
    local bestMatch = 1
    for i=1,numToScan do
        local idx = (i + scanPos) % numToScan + 1
        local space = getSpaceAroundSpawnpoint(ignore,g_Spawnpoints[idx])
        if space > bestSpace then
            bestSpace = space
            bestMatch = idx
        end
    end
    return g_Spawnpoints[bestMatch]
end

function freeSpawnpoint(i)
	if RaceMode.getSpawnpoint(i) then
		RaceMode.getSpawnpoint(i).used = nil
	end
end

function restorePlayer(id, player)
	if not isValidPlayer(player) then
		return
	end
	local self = RaceMode.instances[id]
	clientCall(player, 'remoteStopSpectateAndBlack')

	local checkpoint = getPlayerCurrentCheckpoint(player)
	if self.checkpointBackups[player].goingback and checkpoint > 1 then
		checkpoint = checkpoint - 1
		setPlayerCurrentCheckpoint(player, checkpoint)
	end
	self.checkpointBackups[player].goingback = true
	local bkp = self.checkpointBackups[player][checkpoint - 1]
	if not RaceMode.checkpointsExist() or checkpoint==1 then
		local spawnpoint = self:pickFreeSpawnpoint(player)
		bkp.position = spawnpoint.position
		bkp.rotation = {0, 0, spawnpoint.rotation}
		bkp.geardown = true                 -- Fix landing gear state
		bkp.vehicle = spawnpoint.vehicle    -- Fix spawn'n'blow
		--setVehicleID(RaceMode.getPlayerVehicle(player), spawnpoint.vehicle)
	end
	-- Validate some bkp variables
	if type(bkp.rotation) ~= "table" or #bkp.rotation < 3 then
		bkp.rotation = {0, 0, 0}
	end
	spawnPlayer(player, 0, 0, 0, 0, getElementModel(player))

	local vehicle = RaceMode.getPlayerVehicle(player)
	if vehicle then
        setElementVelocity( vehicle, 0,0,0 )
        setVehicleTurnVelocity( vehicle, 0,0,0 )
		setElementPosition(vehicle, unpack(bkp.position))
		setVehicleRotation(vehicle, unpack(bkp.rotation))
		fixVehicle(vehicle)
		if getElementModel(vehicle) ~= bkp.vehicle then
			setVehicleID(vehicle, bkp.vehicle)
		end
		warpPedIntoVehicle(player, vehicle)	
		--setTimer(warpPedIntoVehicle, 500, 5, player, vehicle)
		
        setVehicleLandingGearDown(vehicle,bkp.geardown)

        RaceMode.playerFreeze(player, true)
        outputDebug( 'MISC', 'restorePlayer: setVehicleFrozen true for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
        removeVehicleUpgrade(vehicle, 1010) -- remove nitro
		setTimer(restorePlayerUnfreeze, 2000, 1, self.id, player)
	end
    setCameraTarget(player)
	setPlayerStatus( player, "alive", "" )
    clientCall(player, 'remoteSoonFadeIn')
end

function restorePlayerUnfreeze(id, player)
	if not isValidPlayer(player) then
		return
	end
    RaceMode.playerUnfreeze(player)
	local vehicle = RaceMode.getPlayerVehicle(player)
    outputDebug( 'MISC', 'restorePlayerUnfreeze: vehicle false for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
	local bkp = RaceMode.instances[id].checkpointBackups[player][getPlayerCurrentCheckpoint(player)-1]
	setElementVelocity(vehicle, unpack(bkp.velocity))
	setVehicleTurnVelocity(g_Vehicles[player], unpack(bkp.turnvelocity))
end

--------------------------------------
-- For use when starting or respawing
--------------------------------------
function RaceMode.playerFreeze(player, bRespawn)
    toggleAllControls(player,true)
	local vehicle = RaceMode.getPlayerVehicle(player)

	-- Reset move away stuff
	setVehicleCollideOthers( "ForMoveAway", vehicle, nil )
	setAlphaOverride( "ForMoveAway", {player, vehicle}, nil )

	-- Setup ghost mode for this vehicle
	setVehicleCollideOthers( "ForGhostCollisions", vehicle, g_MapOptions.ghostmode and 0 or nil )
	setAlphaOverride( "ForGhostAlpha", {player, vehicle}, g_MapOptions.ghostmode and g_GameOptions.ghostalpha and 180 or nil )

	-- Show non-ghost vehicles as semi-transparent while respawning
	setAlphaOverride( "ForRespawnEffect", {player, vehicle}, bRespawn and not g_MapOptions.ghostmode and 120 or nil )

	-- No collisions while frozen
	setVehicleCollideOthers( "ForVehicleSpawnFreeze", vehicle, 0 )

    fixVehicle(vehicle)
	setVehicleFrozen(vehicle, true)
    setVehicleDamageProof(vehicle, true)
	setVehicleCollideWorld( "ForVehicleJudder", vehicle, 0 )
	flushOverrides()
end

function RaceMode.playerUnfreeze(player)
    toggleAllControls(player,true)
	local vehicle = RaceMode.getPlayerVehicle(player)
    fixVehicle(vehicle)
    setVehicleDamageProof(vehicle, false)
    setVehicleEngineState(vehicle, true)
	setVehicleFrozen(vehicle, false)

	-- Remove things added for freeze only
	setVehicleCollideWorld( "ForVehicleJudder", vehicle, nil )
	setVehicleCollideOthers( "ForVehicleSpawnFreeze", vehicle, nil )
	setAlphaOverride( "ForRespawnEffect", {player, vehicle}, nil )
	flushOverrides()
	end
--------------------------------------

--------------------------------------------------------
-- This allows addons to manipulate player 'collide others' and 'alpha'
-- If calling serverside, ensure setElementData has [synchronize = false] to reduce bandwidth usage. Examples:
--		setElementData( player, "overrideCollide.ForMyAddonName", 0, false )		-- Collide 'off' for this player
--		setElementData( player, "overrideCollide.ForMyAddonName", nil, false )		-- Collide 'default' for this player
--		setElementData( player, "overrideAlpha.ForMyAddonName", 120, false )		-- Alpha '120 maximum' for this player
--		setElementData( player, "overrideAlpha.ForMyAddonName", nil, false )		-- Alpha 'default' for this player
--------------------------------------------------------
addEventHandler('onElementDataChange', g_Root,
	function(dataName)
		if string.find( dataName, "override" ) == 1 then
			local player = source
			local vehicle = RaceMode.getPlayerVehicle( player )
			if vehicle then
				local value = getElementData( source, dataName )
				if string.find( dataName, "overrideCollide" ) == 1 then
					setVehicleCollideOthers( dataName, vehicle, value )
				elseif string.find( dataName, "overrideAlpha" ) == 1 then
					setAlphaOverride( dataName, {player, vehicle}, value )
				end
			end
		end
	end
)
--------------------------------------------------------


g_Override = {}
g_Override.list = {}
g_Override.timer = Timer:create()

addEventHandler( "onPlayerQuit", g_Root,
	function()
		g_Override.list [ source ] = nil
		g_Override.list [ RaceMode.getPlayerVehicle(source) or source ] = nil
	end
)

function setVehicleCollideWorld( reason, element, value )
	setOverride( reason, element, value, "race.collideworld", 1 )
end

function setVehicleCollideOthers( reason, element, value )
	setOverride( reason, element, value, "race.collideothers", 1 )
end

function setAlphaOverride( reason, element, value )
	setOverride( reason, element, value, "race.alpha", 255 )
end

function getVehicleCollideWorld( reason, element, value )
	return getOverride( reason, element, "race.collideworld" )
end

function getVehicleCollideOthers( reason, element, value )
	return getOverride( reason, element, "race.collideothers" )
end

function getAlphaOverride( reason, element, value )
	return getOverride( reason, element, "race.alpha" )
end


function setOverride( reason, element, value, var, default )
	-- Recurse for each item if element is a table
	if type(element) == "table" then
		for _,item in ipairs(element) do
			setOverride( reason, item, value, var, default )
		end
		return
	end
	-- Add to override list
	if not g_Override.list[element] then		g_Override.list[element] = {}		end
	if not g_Override.list[element][var] then	g_Override.list[element][var] = { default=default}	end
	g_Override.list[element][var][reason] = value
	-- Set timer to auto-flush incase it is not done manually
	if not g_Override.timer:isActive() then
		g_Override.timer:setTimer( flushOverrides, 50, 1 )
	end
end

function getOverride( reason, element, var )
	return g_Override.list[element] and g_Override.list[element][var] and g_Override.list[element][var][reason] or nil
end

function flushOverrides()
	g_Override.timer:killTimer()
	-- For each element
	for element,varlist in pairs(g_Override.list) do
		-- For each var
		for var,valuelist in pairs(varlist) do
			-- Find the lowest value
			local lowestValue = var.default or 1000
			for _,value in pairs(valuelist) do
				lowestValue = math.min( lowestValue, value )
			end
			-- Set the lowest value for this element's var
			setElementData ( element, var, lowestValue )		
		end
	end
end

function resetOverrides()
	-- For each element
	for element,varlist in pairs(g_Override.list) do
		-- For each var
		for var,valuelist in pairs(varlist) do
			-- Set the default value for this element's var
			if isElement ( element ) then
				setElementData ( element, var, var.default )		
			end
		end
	end
	g_Override.list = {}
end

--------------------------------------


function RaceMode:onPlayerQuit(player)
	self.checkpointBackups[player] = nil
	removeActivePlayer( player )
	if g_MapOptions.respawn == 'none' then
		if getActivePlayerCount() < 1 and g_CurrentRaceMode.running then
			RaceMode.endMap()
		end
	end
end

function RaceMode:destroy()
	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end 
    if self.checkpointBackups then      -- Stop timers
        for plr,bkp in pairs(self.checkpointBackups) do
            if bkp.timer then
                killTimer(bkp.timer)
                bkp.timer = nil
            end
        end
    end
	RaceMode.instances[self.id] = nil
end
