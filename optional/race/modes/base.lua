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

function RaceMode.setPlayerFinished(player)
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
		killTimer(g_RaceEndTimer)
		g_RaceEndTimer = setTimer(raceTimeout, timeLeft, 1)
		clientCall(g_Root, 'setTimeLeft', timeLeft)
	end
end

function RaceMode.endRace()
	setTimer(votemanager.voteMap, 5000, 1, getThisResource())
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
			checkpointBackups = {}  -- { player = { goingback = true/false, i = { vehicle = id, position = {x, y, z}, rotation = {x, y, z}, velocity = {x, y, z} } } }
		},
		self
	)
	return RaceMode.instances[id]
end

function RaceMode:launch()
	self.startTick = getTickCount()
	for i,spawnpoint in ipairs(RaceMode.getSpawnpoints()) do
		spawnpoint.used = nil
	end
end

function RaceMode:getTimePassed()
	if self.startTick then
		return getTickCount() - self.startTick
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
	
	for i,player in ipairs(RaceMode.getPlayers()) do
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
	return rank
end

function RaceMode:onPlayerJoin(player, spawnpoint)
	self.checkpointBackups[player] = {}
	self.checkpointBackups[player][0] = { vehicle = spawnpoint.vehicle, position = spawnpoint.position, rotation = {0, 0, spawnpoint.rotation}, velocity = {0, 0, 0}, turnvelocity = {0, 0, 0} }
end

function RaceMode:onPlayerReachCheckpoint(player, checkpointNum)
	if checkpointNum < RaceMode.getNumberOfCheckpoints() then
		-- Regular checkpoint
		local vehicle = RaceMode.getPlayerVehicle(player)
		self.checkpointBackups[player][checkpointNum] = { vehicle = getVehicleID(vehicle), position = { getElementPosition(vehicle) }, rotation = { getVehicleRotation(vehicle) }, velocity = { getElementVelocity(vehicle) }, turnvelocity = { getVehicleTurnVelocity(vehicle) } }		
		
		self.checkpointBackups[player].goingback = true
		if self.checkpointBackups[player].timer then
			killTimer(self.checkpointBackups[player].timer)
		end
		self.checkpointBackups[player].timer = setTimer(lastCheckpointWasSafe, 5000, 1, self.id, player)
	else
		-- Finish reached
		local rank = self:getPlayerRank(player)
		RaceMode.setPlayerFinished(player)
		if rank == 1 then
			showMessage('You have won the race!', 0, 255, 0, player)
			self.rankingBoard = RankingBoard:create()
			if g_MapOptions.duration then
				self:setTimeLeft(get('race.timeafterfirstfinish') or 60000)
			end
		else
			showMessage('You finished ' .. rank .. ( (rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th' ) .. '!', 0, 255, 0, player)
		end
		self.rankingBoard:add(player, getTickCount() - self.startTick)
		if rank < getPlayerCount() then
			setTimer(clientCall, 5000, 1, player, 'startSpectate')
		else
			RaceMode.endRace()
		end
	end
end

function lastCheckpointWasSafe(id, player)
	local self = RaceMode.instances[id]
	if self.checkpointBackups[player] then
		self.checkpointBackups[player].goingback = false
		self.checkpointBackups[player].timer = nil
	end
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
		Countdown.create(RaceMode.getMapOption('respawntime')/1000, restorePlayer, 'You will respawn in:', 255, 255, 255, self.id, player):start(player)
		if RaceMode.getMapOption('respawntime') >= 10000 then
			setTimer(clientCall, 2000, 1, player, 'startSpectate')
		end
	end
end

function RaceMode:pickFreeSpawnpoint()
	local i = table.find(RaceMode.getSpawnpoints(), 'used', '[nil]')
	if not i then
		i = math.random(RaceMode.getNumberOfSpawnpoints())
	end
	local spawnpoint = RaceMode.getSpawnpoint(i)
	spawnpoint.used = true
	if self.startTick then
		setTimer(freeSpawnpoint, 10000, 1, i)
	end
	return spawnpoint
end

function freeSpawnpoint(i)
	RaceMode.getSpawnpoint(i).used = nil
end

function restorePlayer(id, player)
	local self = RaceMode.instances[id]
	clientCall(player, 'stopSpectate')

	local checkpoint = getPlayerCurrentCheckpoint(player)
	if self.checkpointBackups[player].goingback and checkpoint > 1 then
		checkpoint = checkpoint - 1
		setPlayerCurrentCheckpoint(player, checkpoint)
	end
	self.checkpointBackups[player].goingback = true
	local bkp = self.checkpointBackups[player][checkpoint - 1]
	if not RaceMode.checkpointsExist() then
		local spawnpoint = self:pickFreeSpawnpoint()
		bkp.position = spawnpoint.position
		setVehicleID(RaceMode.getPlayerVehicle(player), spawnpoint.vehicle)
	end
	spawnPlayer(player, bkp.position[1], bkp.position[2], bkp.position[3], 0, getPlayerSkin(player))

	local vehicle = RaceMode.getPlayerVehicle(player)
	if vehicle then
		setElementPosition(vehicle, unpack(bkp.position))
		setVehicleRotation(vehicle, unpack(bkp.rotation))
		fixVehicle(vehicle)
		if getVehicleID(vehicle) ~= bkp.vehicle then
			setVehicleID(vehicle, bkp.vehicle)
		end
		warpPlayerIntoVehicle(player, vehicle)
		setTimer(warpPlayerIntoVehicle, 500, 5, player, vehicle)
		
		setVehicleFrozen(vehicle, true)
		setTimer(restorePlayerUnfreeze, 2000, 1, self.id, player)
	end
end

function restorePlayerUnfreeze(id, player)
	local vehicle = RaceMode.getPlayerVehicle(player)
	setVehicleFrozen(vehicle, false)
	local bkp = RaceMode.instances[id].checkpointBackups[player][getPlayerCurrentCheckpoint(player)-1]
	setElementVelocity(vehicle, unpack(bkp.velocity))
	setVehicleTurnVelocity(g_Vehicles[player], unpack(bkp.turnvelocity))
end

function RaceMode:onPlayerQuit(player)
	self.checkpointBackups[player] = nil
end

function RaceMode:destroy()
	if self.rankingBoard then
		self.rankingBoard:destroy()
		self.rankingBoard = nil
	end
	RaceMode.instances[self.id] = nil
end
