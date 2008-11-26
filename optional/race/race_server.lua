g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
scoreboard = createResourceCallInterface('scoreboard')
votemanager = createResourceCallInterface('votemanager')
mapmanager = createResourceCallInterface('mapmanager')
allowRPC('setVehicleFrozen', 'setElementPosition')
g_MotorBikeIDs = table.create({ 448, 461, 462, 463, 468, 471, 521, 522, 523, 581, 586 }, true)
g_ArmedVehicleIDs = table.create({ 425, 447, 520, 430, 464, 432 }, true)
g_AircraftIDs = table.create({ 592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513 }, true)
g_RCVehicleIDs = table.create({ 441, 464, 465, 501, 564 }, true)
g_FixedColorVehicles = {
	[{ 438, 420 }] = false
}
g_VehicleClothes = {
	[{ 490, 523, 598, 596, 597, 599}] = { [16] = false, [17] = 4 }
}

g_CurrentRaceMode = nil

g_Spawnpoints = {}			-- { i = { position={x, y, z}, rotation=rotation, vehicle=vehicleID, paintjob=paintjob, upgrades={...} } }
g_Checkpoints = {}			-- { i = { position={x, y, z}, size=size, color={r, g, b}, type=type, vehicle=vehicleID, paintjob=paintjob, upgrades={...} } }
g_Objects = {}				-- { i = { position={x, y, z}, rotation={x, y, z}, model=modelID } }
g_Pickups = {}				-- { i = { position={x, y, z}, type=type, vehicle=vehicleID, paintjob=paintjob, upgrades={...} }

g_Players = {}				-- { i = player }
g_Vehicles = {}				-- { player = vehicle }

addEventHandler('onGamemodeMapStart', g_Root,
	function(mapres)
		outputDebugString('onGamemodeMapStart(' .. getResourceName(mapres) .. ')')
		if g_CurrentRaceMode then
			outputDebugString('Unloading previous map')
			unloadAll()
		end
		if not loadMap(mapres) then
			return
		end
		g_CurrentRaceMode = RaceMode.getApplicableMode():create()
		outputDebugString('Loaded race mode ' .. g_CurrentRaceMode:getName())
		startRace()
	end
)

function loadMap(res)
	local map = RaceMap.load(res)
	if not map then
		outputDebugString('Error loading map')
		return false
	end
	
	-- set options
	if map:isRaceFormat() then
		if map.time then
			setTime(map.time:match('(%d+):(%d+)'))
		end
		if map.weather then
			setWeather(map.weather)
		end
	end
	g_MapOptions = {}
	g_MapOptions.duration = map.duration and map.duration*1000 or 1800000
	g_MapOptions.respawn = map.respawn
	if not g_MapOptions.respawn or g_MapOptions.respawn ~= 'none' then
		g_MapOptions.respawn = 'timelimit'
	end
	g_MapOptions.respawntime = g_MapOptions.respawn == 'timelimit' and (map.respawntime and map.respawntime*1000 or 5000)
	g_MapOptions.skins = map.skins or 'cj'
	g_MapOptions.vehicleweapons = map.vehicleweapons == 'true'
	g_MapOptions.ghostmode = map.ghostmode == 'true'
	
	-- read spawnpoints
	g_Spawnpoints = map:getAll('spawnpoint')
	
	-- read checkpoints
	g_Checkpoints = map:getAll('checkpoint')
	if map:isDMFormat() then
		-- sort checkpoints
		local chains = {}		-- a chain is a list of checkpoints that immediately follow each other
		local prevchainnum, chainnum, nextchainnum
		for i,checkpoint in ipairs(g_Checkpoints) do
			-- is it the finish?
			if not checkpoint.nextid then
				table.insert(chains, { checkpoint })
			else
				-- any chain we can place this checkpoint after?
				chainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
				if chainnum then
					table.insert(chains[chainnum], checkpoint)
					nextchainnum = table.find(chains, 1, 'id', checkpoint.nextid)
					if nextchainnum then
						table.merge(chains[chainnum], chains[nextchainnum])
						table.remove(chains, nextchainnum)
					end
				else
					-- any chain we can place it before?
					chainnum = table.find(chains, 1, 'id', checkpoint.nextid)
					if chainnum then
						table.insert(chains[chainnum], 1, checkpoint)
						prevchainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
						if prevchainnum then
							table.merge(chains[prevchainnum], chains[chainnum])
							table.remove(chains, chainnum)
						end
					else
						-- new chain
						table.insert(chains, { checkpoint })
					end
				end
			end
		end
		g_Checkpoints = chains[1]
	end
	
	-- read objects
	g_Objects = map:getAll('object')
	
	-- read pickups
	g_Pickups = map:getAll('pickup')
	
	-- unload map xml
	map:unload()
	return true
end

function startRace(fastStart)
	g_SpawningPlayers = getElementsByType('player')
	setTimer(joinHandler, 500, #g_SpawningPlayers)
	setTimer(startCountdown, #g_SpawningPlayers*500 + (#g_Objects > 400 and (fastStart and 2000 or 8000) or (fastStart and 500 or 5000)), 1)
	if g_CurrentRaceMode:isRanked() then
		g_RankTimer = setTimer(updateRank, 1000, 0)
	end
end

function startCountdown()
	g_RaceStartCountdown:start()
end

function launchRace()
	table.each(g_Vehicles, setVehicleFrozen, false)
	clientCall(g_Root, 'launchRace', g_MapOptions.duration, g_MapOptions.vehicleweapons)
	if g_MapOptions.duration then
		g_RaceEndTimer = setTimer(raceTimeout, g_MapOptions.duration, 1)
	end
	g_CurrentRaceMode:launch()
	g_CurrentRaceMode.running = true
end

g_RaceStartCountdown = Countdown.create(3, launchRace)
g_RaceStartCountdown:useImages('img/countdown_%d.png', 474, 204)
g_RaceStartCountdown:enableFade(true)
g_RaceStartCountdown:addClientHook(3, 'playSoundFrontEnd', 44)
g_RaceStartCountdown:addClientHook(2, 'playSoundFrontEnd', 44)
g_RaceStartCountdown:addClientHook(1, 'playSoundFrontEnd', 44)
g_RaceStartCountdown:addClientHook(0, 'playSoundFrontEnd', 45)

function restartRace()
	for i,player in pairs(g_Players) do
		clientCall(player, 'vehicleUnloading')
		destroyElement(g_Vehicles[player])
		destroyBlipsAttachedTo(player)
	end
	startRace(true)
end

function joinHandler(player)
	if #g_Spawnpoints == 0 then
		-- start vote if no map is loaded
		outputDebugString('No map loaded; showing votemanager')
		votemanager.voteMap(getThisResource())
		return
	end
	if g_SpawningPlayers then
		player = table.remove(g_SpawningPlayers)
		if #g_SpawningPlayers == 0 then
			g_SpawningPlayers = nil
		end
	end
	local playerJoined = not player
	if not player then
		player = source
	end
	
	if not table.find(g_Players, player) then
		table.insert(g_Players, player)
	end
	
	local spawnpoint = g_CurrentRaceMode:pickFreeSpawnpoint()
	
	local x, y, z = unpack(spawnpoint.position)
	if g_MapOptions.skins == 'cj' then
		spawnPlayer(player, x + 4, y, z, 0, 0)
		
		local clothes = { [16] = math.random(12, 13), [17] = 7 }
		for vehicles,vehicleclothes in pairs(g_VehicleClothes) do
			if table.find(vehicles, spawnpoint.vehicle) then
				for type,index in pairs(vehicleclothes) do
					clothes[type] = index or nil
				end
			end
		end
		local texture, model
		for type,index in pairs(clothes) do
			texture, model = getClothesByTypeIndex(type, index)
			addPlayerClothes(player, texture, model, type)
		end
	elseif g_MapOptions.skins == 'random' then
		repeat until spawnPlayer(player, x + 4, y, z, 0, math.random(9, 288))
	else
		spawnPlayer(player, x + 4, y, z, 0, getRandomFromRangeList(g_MapOptions.skins))
	end
	setPlayerStat(player, 160, 1000)
	setPlayerStat(player, 229, 1000)
	setPlayerStat(player, 230, 1000)
	
	local vehicle
	if spawnpoint.vehicle then
		local nick = getClientName(player)
		vehicle = createVehicle(spawnpoint.vehicle, x, y, z, 0, 0, spawnpoint.rotation, #nick <= 8 and nick or nick:sub(1, 8))
		setVehicleFrozen(vehicle, true)
		if playerJoined and g_CurrentRaceMode.running then
			setTimer(setVehicleFrozen, 3000, 1, vehicle, false)
		end
		
		if spawnpoint.paintjob or spawnpoint.upgrades then
			setVehiclePaintjobAndUpgrades(vehicle, spawnpoint.paintjob, spawnpoint.upgrades)
		else
			pimpVehicleRandom(vehicle)
			local vehicleColorFixed = false
			for vehicles,color in pairs(g_FixedColorVehicles) do
				if table.find(vehicles, spawnpoint.vehicle) then
					if color then
						setVehicleColor(vehicle, color, 0, 0, 0)
					end
					vehicleColorFixed = true
					break
				end
			end
			if not vehicleColorFixed then
				setVehicleColor(vehicle, math.random(0, 126), math.random(0, 126), 0, 0)
			end
		end
		setTimer(warpPlayerIntoVehicle, 500, 10, player, vehicle)
		
		g_Vehicles[player] = vehicle
	end
	
	local oldGhostMode = g_MapOptions.ghostmode
	g_MapOptions.ghostmode = getPlayerCount() >= (get('ghostmodethreshold') or 10)
	if g_MapOptions.ghostmode ~= oldGhostMode then
		clientCall(g_Root, 'setGhostMode', g_MapOptions.ghostmode)
	end
	
	clientCall(player, 'initRace', vehicle, g_Checkpoints, g_Objects, g_Pickups, g_MapOptions, g_CurrentRaceMode:isRanked(), playerJoined and (g_MapOptions.duration and (g_MapOptions.duration - g_CurrentRaceMode:getTimePassed()) or true), get('race.hurrytime') or 30000)
	
	createBlipAttachedTo(player, 0, 1, 200, 200, 200)
	g_CurrentRaceMode:onPlayerJoin(player, spawnpoint)
	
	if playerJoined and getPlayerCount() == 2 then
		-- Restart the race if someone joined a lone player
		Countdown.create(5, restartRace, 'Race will restart in:', 255, 255, 255):start()
	end
end
addEventHandler('onPlayerJoin', g_Root, joinHandler)

function updateRank()
	for i,player in ipairs(g_Players) do
		if not isPlayerFinished(player) then
			setElementData(player, 'Race rank', g_CurrentRaceMode:getPlayerRank(player))
		end
	end
end

addEvent('onPlayerReachCheckpoint', true)
addEventHandler('onPlayerReachCheckpoint', g_Root,
	function(checkpointNum)
		local vehicle = g_Vehicles[source]
		local checkpoint = g_Checkpoints[checkpointNum]
		if checkpoint.vehicle then
			setVehicleID(vehicle, checkpoint.vehicle)
			clientCall(source, 'vehicleChanging')
			if checkpoint.paintjob or checkpoint.upgrades then
				setVehiclePaintjobAndUpgrades(vehicle, checkpoint.paintjob, checkpoint.upgrades)
			else
				pimpVehicleRandom(vehicle)
			end
		end
		
		g_CurrentRaceMode:onPlayerReachCheckpoint(source, checkpointNum)
	end
)

addEvent('onPlayerPickUpRacePickup', true)
addEventHandler('onPlayerPickUpRacePickup', g_Root,
	function(pickupID)
		local pickup = g_Pickups[table.find(g_Pickups, 'id', pickupID)]
		local vehicle = g_Vehicles[source]
		if pickup.type == 'repair' then
			fixVehicle(vehicle)
		elseif pickup.type == 'nitro' then
			addVehicleUpgrade(vehicle, 1010)
		elseif pickup.type == 'vehiclechange' then
			setVehicleID(vehicle, pickup.vehicle)
			setVehiclePaintjobAndUpgrades(vehicle, pickup.paintjob, pickup.upgrades)
			clientCall(source, 'vehicleChanging', getTime())
		end
	end
)

addEventHandler('onPlayerWasted', g_Root,
	function()
		if g_CurrentRaceMode then
			if not g_CurrentRaceMode.startTick then
				local x, y, z = getElementPosition(source)
				spawnPlayer(source, x, y, z, 0, getPlayerSkin(source))
				if g_Vehicles[source] then
					setTimer(warpPlayerIntoVehicle, 500, 10, source, g_Vehicles[source])
				end
			else
				g_CurrentRaceMode:onPlayerWasted(source)
			end
		end
	end
)

function raceTimeout()
	for i,player in pairs(g_Players) do
		if not isPlayerFinished(player) then
			showMessage('Time\'s up!')
		end
	end
	clientCall(g_Root, 'raceTimeout')
	g_RaceEndTimer = nil
	setTimer(votemanager.voteMap, 10000, 1, getThisResource())
end

function unloadAll()
	clientCall(g_Root, 'unloadAll')
	if g_RaceEndTimer then
		killTimer(g_RaceEndTimer)
		g_RaceEndTimer = nil
	end
	if g_RankTimer then
		killTimer(g_RankTimer)
		g_RankTimer = nil
	end
	
	Countdown.destroyAll()

	for i,player in pairs(g_Players) do
		setPlayerFinished(player, false)
	end
	
	table.each(g_Vehicles, destroyElement)
	g_Vehicles = {}
	g_Spawnpoints = {}
	g_Checkpoints = {}
	g_Objects = {}
	g_Pickups = {}
	if g_CurrentRaceMode then
		g_CurrentRaceMode:destroy()
	end
	g_CurrentRaceMode = nil
end

addEventHandler('onGamemodeMapStop', g_Root,
	function(mapres)
		outputDebugString('onGamemodeMapStop')
		unloadAll()
	end
)

addEventHandler('onResourceStart', g_ResRoot,
	function()
		outputDebugString('Resource starting')
		scoreboard.addScoreboardColumn('Race rank')
	end
)

addEventHandler('onResourceStop', g_ResRoot,
	function()
		outputDebugString('Resource stopping')
		unloadAll()
		scoreboard.removeScoreboardColumn('Race rank')
	end
)

addEventHandler('onPlayerQuit', g_Root,
	function()
		destroyBlipsAttachedTo(source)
		table.removevalue(g_Players, source)
		if g_Vehicles[source] then
			destroyElement(g_Vehicles[source])
			g_Vehicles[source] = nil
		end
		if g_CurrentRaceMode then
			g_CurrentRaceMode:onPlayerQuit(source)
		end
		
		local oldGhostMode = g_MapOptions.ghostmode
		g_MapOptions.ghostmode = getPlayerCount() >= (get('ghostmodethreshold') or 10)
		if g_MapOptions.ghostmode ~= oldGhostMode then
			clientCall(g_Root, 'setGhostMode', g_MapOptions.ghostmode)
		end
		
		for i,player in pairs(g_Players) do
			if not isPlayerFinished(player) then
				return
			end
		end
		if #g_Players == 0 then
			outputDebugString('Stopping map')
			triggerEvent('onGamemodeMapStop', g_Root)
		else
			setTimer(votemanager.voteMap, 5000, 1, getThisResource())
		end
		
		local oldGhost = g_MapOptions.ghostmode
		g_MapOptions.ghostmode = getPlayerCount() >= (get('ghostmodethreshold') or 10)
		if oldGhost ~= g_MapOptions.ghostmode then
			clientCall(g_Root, 'setGhostMode', g_MapOptions.ghostmode)
		end
	end
)

addEventHandler('onVehicleDamage', g_Root,
	function()
		local player = table.find(g_Vehicles, source)
		if player then
			setElementHealth(player, getElementHealth(source)/10)
		end
	end
)

addEventHandler('onVehicleStartExit', g_Root, function() cancelEvent() end)

function getPlayerCurrentCheckpoint(player)
	return getElementData(player, 'race.checkpoint') or 1
end

function setPlayerCurrentCheckpoint(player, i)
	clientCall(player, 'setCurrentCheckpoint', i)
end

function setPlayerFinished(player, toggle)
	setElementData(player, 'race.finished', toggle)
end

function isPlayerFinished(player)
	return getElementData(player, 'race.finished') or false
end

function distanceFromPlayerToCheckpoint(player, i)
	local checkpoint = g_Checkpoints[i]
	local x, y, z = getElementPosition(player)
	return getDistanceBetweenPoints3D(x, y, z, unpack(checkpoint.position))
end

addCommandHandler('kill',
	function(player)
		killPlayer(player)
	end
)

addCommandHandler('ghostmode',
	function()
		g_MapOptions.ghostmode = not g_MapOptions.ghostmode
		clientCall(g_Root, 'setGhostMode', g_MapOptions.ghostmode)
		outputConsole('Ghostmode is now ' .. (g_MapOptions.ghostmode and 'on' or 'off'))
	end
)

addCommandHandler('convrace',
	function(player, command, resname)
		local map = RaceMap.load(getResourceFromName(resname))
		if not map then
			return
		end
		if map:isDMFormat() then
			outputConsole('Map is already in deathmatch format.')
			return
		end
		map:convert()
		map:save()
		map:unload()
		outputConsole('Map converted successfully')
	end
)
