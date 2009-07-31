g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
scoreboard = createResourceCallInterface('scoreboard')
votemanager = createResourceCallInterface('votemanager')
mapmanager = createResourceCallInterface('mapmanager')
allowRPC('setElementPosition')
g_MotorBikeIDs = table.create({ 448, 461, 462, 463, 468, 471, 521, 522, 523, 581, 586 }, true)
g_ArmedVehicleIDs = table.create({ 425, 447, 520, 430, 464, 432 }, true)
g_AircraftIDs = table.create({ 592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513 }, true)
g_RCVehicleIDs = table.create({ 441, 464, 465, 501, 564 }, true)
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

-- Timers
g_SpawnTimer = Timer:create()
g_RankTimer  = Timer:create()
g_RaceEndTimer = Timer:create()
g_WatchDogTimer = Timer:create()
local pickupTimers = {}
local unloadedPickups = {}


addEventHandler('onPlayerJoin', g_Root,
	function()
		-- Race welcome message
		outputChatBox ( 'Race version ' .. getBuildString(), source, 255, 127, 0 )
		for _,line in ipairs(Addons.report) do
			outputConsole ( 'Race addon: ' .. line, source )
		end
	end
)


addEventHandler('onGamemodeMapStart', g_Root,
	function(mapres)
		outputDebugString('onGamemodeMapStart(' .. getResourceName(mapres) .. ')')
		if getTotalPlayerCount() == 0 then
			outputDebugString('Stopping map')
			triggerEvent('onGamemodeMapStop', g_Root)
            return
		end
        gotoState('LoadingMap')
        -- set up all players as not ready
        for i,player in ipairs(getElementsByType('player')) do
            setPlayerNotReady(player)
        end
        -- tell clients new map is loading
        clientCall(g_Root, 'notifyLoadingMap', getResourceInfo(mapres, "name") or getResourceName(mapres) )

		if g_CurrentRaceMode then
			outputDebugString('Unloading previous map')
			unloadAll()
		end
		setTimer(doLoadMap,50,1,mapres)
	end
)
-- continue loading map after onGamemodeMapStart has completed
function doLoadMap(mapres)
	if not loadMap(mapres) then
        -- Select another map on load error
        problemChangingMap()
		return
	end
	g_CurrentRaceMode = RaceMode.getApplicableMode():create()
	g_MapInfo.modename  = g_CurrentRaceMode:getName()
	outputDebugString('Loaded race mode ' .. g_MapInfo.modename)
	startRace()
end

-- Called from the admin panel when a setting is changed there
addEvent ( "onSettingChange" )
addEventHandler('onSettingChange', g_ResRoot,
	function(name, oldvalue, value, player)
		outputDebug( 'MISC', 'Setting changed: ' .. tostring(name) .. '  value:' .. tostring(value) .. '  value:' .. tostring(oldvalue).. '  by:' .. tostring(player and getPlayerName(player) or 'n/a') )
		cacheGameOptions()
		if g_SavedMapSettings then
			cacheMapOptions(g_SavedMapSettings)
			clientCall(g_Root,'updateOptions', g_GameOptions, g_MapOptions)
		end
	end
)

function cacheGameOptions()
	g_GameOptions = {}
	g_GameOptions.timeafterfirstfinish  = getNumber('race.timeafterfirstfinish',30) * 1000
	g_GameOptions.hurrytime				= getNumber('race.hurrytime',15) * 1000
	g_GameOptions.defaultrespawntime	= getNumber('race.respawntime',5) * 1000
	g_GameOptions.ghostmode				= getBool('race.ghostmode',false)
	g_GameOptions.ghostalpha			= getBool('race.ghostalpha',false)
	g_GameOptions.randommaps			= getBool('race.randommaps',false)
	g_GameOptions.statskey				= getString('race.statskey','name')
	g_GameOptions.vehiclecolors			= getString('race.vehiclecolors','file')
	g_GameOptions.skins					= getString('race.skins','cj')
	g_GameOptions.autopimp				= getBool('race.autopimp',true)
	g_GameOptions.vehicleweapons		= getBool('race.vehicleweapons',true)
	g_GameOptions.firewater				= getBool('race.firewater',false)
	g_GameOptions.cachemodels			= getBool('race.cachemodels',true)
	g_GameOptions.admingroup			= getString('race.admingroup','Admin')
	g_GameOptions.blurlevel				= getNumber('race.blur',36)
	g_GameOptions.cloudsenable			= getBool('race.clouds',true)
	g_GameOptions.ghostmode_map_can_override		= getBool('race.ghostmode_map_can_override',true)
	g_GameOptions.skins_map_can_override			= getBool('race.skins_map_can_override',true)
	g_GameOptions.vehicleweapons_map_can_override   = getBool('race.vehicleweapons_map_can_override',true)
	g_GameOptions.autopimp_map_can_override			= getBool('race.autopimp_map_can_override',true)
	g_GameOptions.firewater_map_can_override		= getBool('race.firewater_map_can_override',true)
	g_GameOptions.cachemodels_map_can_override		= getBool('race.cachemodels_map_can_override',true)
	g_GameOptions.ghostmode_warning_if_map_override			= getBool('race.ghostmode_warning_if_map_override',true)
	g_GameOptions.vehicleweapons_warning_if_map_override	= getBool('race.vehicleweapons_warning_if_map_override',true)

	if g_GameOptions.statskey ~= 'name' and g_GameOptions.statskey ~= 'serial' then
		outputWarning( "statskey is not set to 'name' or 'serial'" )
		g_GameOptions.statskey = 'name'
	end
end


function cacheMapOptions(map)
	g_MapOptions = {}
	g_MapOptions.duration = map.duration and tonumber(map.duration) > 0 and map.duration*1000 or 600000
	if g_MapOptions.duration > 86400000 then
		g_MapOptions.duration = 86400000
	end
	g_MapOptions.respawn = map.respawn
	if not g_MapOptions.respawn or g_MapOptions.respawn ~= 'none' then
		g_MapOptions.respawn = 'timelimit'
	end
	g_MapOptions.respawntime	= g_MapOptions.respawn == 'timelimit' and (map.respawntime and map.respawntime*1000 or g_GameOptions.defaultrespawntime)
	g_MapOptions.time			= map.time or '12:00'
	g_MapOptions.weather		= map.weather or 0

	g_MapOptions.skins			= map.skins or 'cj'
	g_MapOptions.vehicleweapons = map.vehicleweapons == 'true'
	g_MapOptions.ghostmode		= map.ghostmode == 'true'
	g_MapOptions.autopimp		= map.autopimp == 'true'
	g_MapOptions.firewater		= map.firewater == 'true'
	g_MapOptions.cachemodels	= map.cachemodels == 'true'
	
	outputDebug("MISC", "duration = "..g_MapOptions.duration.."  respawn = "..g_MapOptions.respawn.."  respawntime = "..tostring(g_MapOptions.respawntime).."  time = "..g_MapOptions.time.."  weather = "..g_MapOptions.weather)
	
	if g_MapOptions.time then
		setTime(g_MapOptions.time:match('(%d+):(%d+)'))
	end
	if g_MapOptions.weather then
		setWeather(g_MapOptions.weather)
	end
	
	-- Set ghostmode from g_GameOptions if not defined in the map, or map override not allowed
	if not map.ghostmode or not g_GameOptions.ghostmode_map_can_override then
		g_MapOptions.ghostmode = g_GameOptions.ghostmode
	elseif g_GameOptions.ghostmode_warning_if_map_override and g_MapOptions.ghostmode ~= g_GameOptions.ghostmode then
		if g_MapOptions.ghostmode then
			outputChatBox( 'Notice: Collisions are turned off for this map' )
		else
			outputChatBox( 'Notice: Collisions are turned on for this map' )
		end
	end

	-- Set skins from g_GameOptions if not defined in the map, or map override not allowed
	if not map.skins or not g_GameOptions.skins_map_can_override then
		g_MapOptions.skins = g_GameOptions.skins
	end

	-- Set vehicleweapons from g_GameOptions if not defined in the map, or map override not allowed
	if not map.vehicleweapons or not g_GameOptions.vehicleweapons_map_can_override then
		g_MapOptions.vehicleweapons = g_GameOptions.vehicleweapons
	elseif g_GameOptions.vehicleweapons_warning_if_map_override and g_MapOptions.vehicleweapons ~= g_GameOptions.vehicleweapons then
		if g_MapOptions.vehicleweapons then
			outputChatBox( 'Notice: Vehicle weapons are turned on for this map' )
		else
			outputChatBox( 'Notice: Vehicle weapons are turned off for this map' )
		end
	end

	-- Set autopimp from g_GameOptions if not defined in the map, or map override not allowed
	if not map.autopimp or not g_GameOptions.autopimp_map_can_override then
		g_MapOptions.autopimp = g_GameOptions.autopimp
	end

	-- Set firewater from g_GameOptions if not defined in the map, or map override not allowed
	if not map.firewater or not g_GameOptions.firewater_map_can_override then
		g_MapOptions.firewater = g_GameOptions.firewater
	end

	-- Set cachemodels from g_GameOptions if not defined in the map, or map override not allowed
	if not map.cachemodels or not g_GameOptions.cachemodels_map_can_override then
		g_MapOptions.cachemodels = g_GameOptions.cachemodels
	end
end



-- Called from:
--      onGamemodeMapStart
function loadMap(res)
	local map = RaceMap.load(res)
	if not map then
		outputDebugString( 'Error loading map ' .. tostring(getResourceName(res)) )
        outputChatBox( 'Error loading map ' .. tostring(getResourceName(res)) )
		return false
	end

	-- set options
    g_MapInfo = {}
    g_MapInfo.name      = map.info['name'] or 'unnamed'
    g_MapInfo.resname   = map.info['resname'] or getResourceName(res)

	g_SavedMapSettings = {}
	g_SavedMapSettings.duration			= map.duration
	g_SavedMapSettings.respawn			= map.respawn
	g_SavedMapSettings.respawntime		= map.respawntime
	g_SavedMapSettings.time				= map.time
	g_SavedMapSettings.weather			= map.weather
	g_SavedMapSettings.skins			= map.skins
	g_SavedMapSettings.vehicleweapons	= map.vehicleweapons
	g_SavedMapSettings.ghostmode		= map.ghostmode
	g_SavedMapSettings.autopimp			= map.autopimp
	g_SavedMapSettings.firewater		= map.firewater
	g_SavedMapSettings.cachemodels		= map.cachemodels
	g_SavedMapSettings.firewater		= map.firewater

	cacheMapOptions(g_SavedMapSettings)

	-- Check race can start ok
	if not g_MapOptions.ghostmode then
		local numSpawnPoints = #map:getAll('spawnpoint')
		if getTotalPlayerCount() > numSpawnPoints then
			-- unload map xml
			map:unload()
			outputRace( (numSpawnPoints).." or less players are required to start '"..tostring(getResourceName(res)).."' if not using ghostmode" )
			return false
		end
	end
	
	-- read spawnpoints
	g_Spawnpoints = map:getAll('spawnpoint')
	
	-- read checkpoints
	g_Checkpoints = map:getAll('checkpoint')
	for i,checkpoint in ipairs(g_Checkpoints) do
		checkpoint.size = checkpoint.size and checkpoint.size*4 or 4
	end
	if map:isDMFormat() then
		-- sort checkpoints
		local chains = {}		-- a chain is a list of checkpoints that immediately follow each other
		local prevchainnum, chainnum, nextchainnum
		for i,checkpoint in ipairs(g_Checkpoints) do
			-- any chain we can place this checkpoint after?
			chainnum = table.find(chains, '[last]', 'nextid', checkpoint.id)
			if chainnum then
				table.insert(chains[chainnum], checkpoint)
				if checkpoint.nextid then
					nextchainnum = table.find(chains, 1, 'id', checkpoint.nextid)
					if nextchainnum then
						table.merge(chains[chainnum], chains[nextchainnum])
						table.remove(chains, nextchainnum)
					end
				end
			elseif checkpoint.nextid then
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
			else
				table.insert(chains, { checkpoint })
			end
		end
		g_Checkpoints = chains[1] or {}
	end
	
	-- read objects
	g_Objects = map:getAll('object')
	
	-- read pickups
	g_Pickups = map:getAll('pickup')
	
	-- unload map xml
	map:unload()
	return true
end

-- Called from:
--      onGamemodeMapStart
function startRace()
    gotoState('PreGridCountdown')
    triggerEvent('onMapStarting', g_Root, g_MapInfo, g_MapOptions, g_GameOptions )
	g_Players = {}
	g_SpawnTimer:setTimer(joinHandlerByTimer, 500, 0)
	if g_CurrentRaceMode:isRanked() then
		g_RankTimer:setTimer(updateRank, 1000, 0)
	end
end


-- Called from:
--      g_RaceStartCountdown
function launchRace()
	for i,player in pairs(g_Players) do
		unfreezePlayerWhenReady(player)
	end
	clientCall(g_Root, 'launchRace', g_MapOptions.duration, g_MapOptions.vehicleweapons)
	if g_MapOptions.duration then
		g_RaceEndTimer:setTimer(raceTimeout, g_MapOptions.duration, 1)
	end
	g_CurrentRaceMode:launch()
	g_CurrentRaceMode.running = true
    gotoState('Running')
end

g_RaceStartCountdown = Countdown.create(6, launchRace)
g_RaceStartCountdown:useImages('img/countdown_%d.png', 474, 204)
g_RaceStartCountdown:enableFade(true)
g_RaceStartCountdown:addClientHook(3, 'playSoundFrontEnd', 44)
g_RaceStartCountdown:addClientHook(2, 'playSoundFrontEnd', 44)
g_RaceStartCountdown:addClientHook(1, 'playSoundFrontEnd', 44)
g_RaceStartCountdown:addClientHook(0, 'playSoundFrontEnd', 45)


-- Called from:
--      Currently unused
function restartRace()
	for i,player in pairs(g_Players) do
		clientCall(player, 'vehicleUnloading')
		destroyElement(g_Vehicles[player])
		destroyBlipsAttachedTo(player)
	end
	startRace()
end


-- Called from:
--      event onPlayerJoin
--      g_SpawnTimer = setTimer(joinHandler, 500, 0) in startRace
-- Interesting calls to:
--      g_RaceStartCountdown:start()
--
-- note: player is always nil on entry

function joinHandlerByEvent()
    setPlayerNotReady(source)
    joinHandlerBoth()
end

function joinHandlerByTimer()
    joinHandlerBoth()
end

function joinHandlerBoth(player)
	if #g_Spawnpoints == 0 then
 		-- start vote if no map is loaded
       if not g_WatchDogTimer:isActive() then
            g_WatchDogTimer:setTimer(
                function()
                    if #g_Spawnpoints == 0 then
                        outputDebugString('No map loaded; showing votemanager')
                        g_SpawnTimer:killTimer()
                        RaceMode.endMap()
                    end
                end,
                1000, 1 )
        end
        return
    else
        g_WatchDogTimer:killTimer()
    end
	if g_SpawnTimer:isActive() then
		for i,p in ipairs(getElementsByType('player')) do
			if not table.find(g_Players, p) then
				player = p
				break
			end
		end
		if not player then
            -- Is everyone ready?
            if howManyPlayersNotReady() == 0 then
                g_SpawnTimer:killTimer()
                if stateAllowsGridCountdown() then
                    gotoState('GridCountdown')
			        g_RaceStartCountdown:start()
                end
    		end
			return
		end
	end
    local respawn = true
	local bPlayerJoined = not player
	if bPlayerJoined then
		player = source
        setElementData(player, "state", "joined")
	else
        setElementData(player, "state", "not ready")
    end
    if not player then
        outputDebug( 'MISC', 'joinHandler: player==nil' )
        return
    end

	table.insert(g_Players, player)
    local vehicle
	if respawn then
        local spawnpoint = g_CurrentRaceMode:pickFreeSpawnpoint(player)
        
        local x, y, z = unpack(spawnpoint.position)
        -- Set random seed dependant on map name, so everyone gets the same models
        setRandomSeedForMap('clothes')

        if g_MapOptions.skins == 'cj' then
            spawnPlayer(player, x + 4, y, z, 0, 0)
            
            local clothes = { [16] = math.random(12, 13), [17] = 7 }    -- 16=Hats(12:helmet 13:moto) 17=Extra(7:garageleg)
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
                addPedClothes(player, texture, model, type)
            end
        elseif g_MapOptions.skins == 'random' then
            repeat until spawnPlayer(player, x + 4, y, z, 0, math.random(9, 288))
        else
            local ok
            for i=1,20 do
                ok = spawnPlayer(player, x + 4, y, z, 0, getRandomFromRangeList(g_MapOptions.skins))
                if ok then break end
            end
            if not ok then
                spawnPlayer(player, x + 4, y, z, 0, 264)
            end
        end

        setPlayerNotReady( player )
        setPedStat(player, 160, 1000)
        setPedStat(player, 229, 1000)
        setPedStat(player, 230, 1000)
        
        if spawnpoint.vehicle then
            local nick = getPlayerName(player)
            setRandomSeedForMap('vehiclecolors')
            vehicle = createVehicle(spawnpoint.vehicle, x, y, z, 0, 0, spawnpoint.rotation, #nick <= 8 and nick or nick:sub(1, 8))
            g_Vehicles[player] = vehicle
            RaceMode.playerFreeze(player)
            outputDebug( 'MISC', 'joinHandlerBoth: setVehicleFrozen true for ' .. tostring(getPlayerName(player)) .. '  vehicle:' .. tostring(vehicle) )
            if bPlayerJoined and g_CurrentRaceMode.running then
                unfreezePlayerWhenReady(player)
            end
            
            if spawnpoint.paintjob or spawnpoint.upgrades then
                setVehiclePaintjobAndUpgrades(vehicle, spawnpoint.paintjob, spawnpoint.upgrades)
            else
                if g_MapOptions.autopimp then
                    pimpVehicleRandom(vehicle)
                end
                if g_GameOptions.vehiclecolors == 'random' then
                    setRandomSeedForMap('vehiclecolors')
                    local vehicleColorFixed = false
                    for vehicleID,color in pairs(g_FixedColorVehicles) do
                        if vehicleID == tonumber(spawnpoint.vehicle) then
                            if color then
                                setVehicleColor(vehicle, color[1], color[2], color[3], color[4])
                            end
                            vehicleColorFixed = true
                            break
                        end
                    end
                    if not vehicleColorFixed then
                        setVehicleColor(vehicle, math.random(0, 126), math.random(0, 126), 0, 0)
                    end
                end
            end
            setTimer(warpPedIntoVehicle, 500, 10, player, vehicle)	
        end
        
        setPlayerSpectating( player, false )
        createBlipAttachedTo(player, 0, 1, 200, 200, 200)
        g_CurrentRaceMode:onPlayerJoin(player, spawnpoint)
    else
        vehicle = createVehicle(400,0,0,0)
    end
    -- Tell all clients to re-apply ghostmode settings in 100ms
    setTimer(function() clientCall(g_Root, 'setGhostMode', g_MapOptions.ghostmode) end, 100, 1 )

    -- Send client all info
    local playerInfo = {}
    playerInfo.admin    = isPlayerInACLGroup(player, g_GameOptions.admingroup)
    playerInfo.testing  = _TESTING
    playerInfo.joined   = bPlayerJoined
	local duration = bPlayerJoined and (g_MapOptions.duration and (g_MapOptions.duration - g_CurrentRaceMode:getTimePassed()) or true)
	clientCall(player, 'initRace', vehicle, g_Checkpoints, g_Objects, g_Pickups, g_MapOptions, g_CurrentRaceMode:isRanked(), duration, g_GameOptions, g_MapInfo, playerInfo )

    -- Tell all clients to re-apply ghostmode settings in 1000ms
    setTimer(function() clientCall(g_Root, 'setGhostMode', g_MapOptions.ghostmode) end, 1000, 1 )
	
	if bPlayerJoined and getPlayerCount() == 2 and stateAllowsRandomMapVote() then
		-- Start random map vote if someone joined a lone player mid-race
        setTimer(startMidMapVoteForRandomMap,7000,1)
	end
end
addEventHandler('onPlayerJoin', g_Root, joinHandlerByEvent)



-- Called from:
--      joinHandler
--      unfreezePlayerWhenReady
--      launchRace
function unfreezePlayerWhenReady(player)
	if not isValidPlayer(player) then
        outputDebug( 'MISC', 'unfreezePlayerWhenReady: not isValidPlayer(player)' )
		return
	end
    if isPlayerNotReady(player) then
        outputDebug( 'MISC', 'unfreezePlayerWhenReady: isPlayerNotReady(player) for ' .. tostring(getPlayerName(player)) )
        setTimer( unfreezePlayerWhenReady, 500, 1, player )
    else
        RaceMode.playerUnfreeze(player)
        outputDebug( 'MISC', 'unfreezePlayerWhenReady: setVehicleFrozen false for ' .. tostring(getPlayerName(player)) )
    end
end



-- Called from:
--      g_RankTimer = setTimer(updateRank, 1000, 0) in startRace
function updateRank()
    if g_CurrentRaceMode then
	    for i,player in ipairs(g_Players) do
		    if not isPlayerFinished(player) then
			    setElementData(player, 'race rank', g_CurrentRaceMode:getPlayerRank(player))
		        setElementData(player, 'checkpoint', getPlayerCurrentCheckpoint(player)-1 .. '/' .. #g_Checkpoints )
		    else
                setElementData(player, 'checkpoint', #g_Checkpoints .. '/' .. #g_Checkpoints )
	        end
	    end
    end
end


-- Set random seed dependent on map name
--
-- Note: Some clients will experience severe stutter and stalls if any
-- players have different skin/clothes.
-- For smooth gameplay, ensure everyone has the same skin setup including crash helmet etc.
function setRandomSeedForMap( type )
    local seed = 0
    if type == 'clothes' then
        seed = 100                  -- All players get the same driver skin/clothes
    elseif type == 'upgrades' then
        seed = 0                    -- All players get the same set of vehicle upgrades
    elseif type == 'vehiclecolors' then
        seed = getTickCount()       -- Allow vehicle colors to vary between players
    else
        outputWarning( 'Unknown setRandomSeedForMap type ' .. type )
    end
    for i,char in ipairs( { string.byte(g_MapInfo.name,1,g_MapInfo.name:len()) } ) do
        seed = math.mod( seed * 11 + char, 216943)
    end
    math.randomseed(seed)    
end



addEvent('onPlayerReachCheckpointInternal', true)
addEventHandler('onPlayerReachCheckpointInternal', g_Root,
	function(checkpointNum)
        if not stateAllowsCheckpoint() then
            return
        end
		local vehicle = g_Vehicles[source]
		local checkpoint = g_Checkpoints[checkpointNum]
		if checkpoint.vehicle then
			if getElementModel(vehicle) ~= tonumber(checkpoint.vehicle) then
				local rx, ry, rz = getVehicleRotation (vehicle)
				setVehicleRotation(vehicle, 0, 0, (rx > 90 and rx < 270) and (rz + 180) or rz)
				setVehicleID(vehicle, checkpoint.vehicle)
				clientCall(source, 'vehicleChanging')
				if checkpoint.paintjob or checkpoint.upgrades then
					setVehiclePaintjobAndUpgrades(vehicle, checkpoint.paintjob, checkpoint.upgrades)
				else
					if g_MapOptions.autopimp then
						pimpVehicleRandom(vehicle)
					end
				end
			end
		end
		
		local rank, time = g_CurrentRaceMode:onPlayerReachCheckpoint(source, checkpointNum)
		if checkpointNum < #g_Checkpoints then
			triggerEvent('onPlayerReachCheckpoint', source, checkpointNum, time)
		else
			triggerEvent('onPlayerFinish', source, rank, time)
		end
	end
)

addEvent('onPlayerPickUpRacePickup', true)
addEventHandler('onPlayerPickUpRacePickup', g_Root,
	function(pickupID, respawntime)
		if not stateAllowsPickup() then
            return
        end
		local pickup = g_Pickups[table.find(g_Pickups, 'id', pickupID)]
		local vehicle = g_Vehicles[source]
		if respawntime then
			table.insert(unloadedPickups, pickupID)
			clientCall(g_Root, 'unloadPickup', pickupID)
			pickupTimers[pickupID] = setTimer(ServerLoadPickup, tonumber(respawntime), 1, pickupID)
		end
		if pickup.type == 'repair' then
			fixVehicle(vehicle)
		elseif pickup.type == 'nitro' then
			addVehicleUpgrade(vehicle, 1010)
		elseif pickup.type == 'vehiclechange' then
			if getElementModel(vehicle) ~= tonumber(pickup.vehicle) then
				local rx, ry, rz = getVehicleRotation (vehicle)
				setVehicleRotation(vehicle, 0, 0, (rx > 90 and rx < 270) and (rz + 180) or rz)
				setVehicleID(vehicle, pickup.vehicle)
				setVehiclePaintjobAndUpgrades(vehicle, pickup.paintjob, pickup.upgrades)
				clientCall(source, 'vehicleChanging', getTime())
			end
		end
	end
)

function ServerLoadPickup(pickupID)
	pickupTimers[pickupID] = nil
	table.removevalue(unloadedPickups, pickupID)
	clientCall(g_Root, 'loadPickup', pickupID)
end

addEventHandler('onPlayerWasted', g_Root,
	function()
		if g_CurrentRaceMode then
			if not g_CurrentRaceMode.startTick then
				local x, y, z = getElementPosition(source)
				spawnPlayer(source, x, y, z, 0, getElementModel(source))
				if g_Vehicles[source] then
					setTimer(warpPedIntoVehicle, 500, 10, source, g_Vehicles[source])
				end
			else
				setElementData(source, "state", "dead")
				g_CurrentRaceMode:onPlayerWasted(source)
			end
		end
	end
)


-- Called from:
--		g_RaceEndTimer = setTimer(raceTimeout, g_MapOptions.duration, 1)
function raceTimeout()
    gotoState('TimesUp')
	for i,player in pairs(g_Players) do
		if not isPlayerFinished(player) then
			showMessage('Time\'s up!')
		end
	end
	clientCall(g_Root, 'raceTimeout')
	g_RaceEndTimer:killTimer()
    RaceMode.endMap()
end

-- Called from:
--      onGamemodeMapStart
--      onGamemodeMapStop
--      onResourceStop
function unloadAll()
	if getPlayerCount() > 0 then
		clientCall(g_Root, 'unloadAll')
	end
    g_RaceEndTimer:killTimer()
    g_RankTimer:killTimer()
    g_SpawnTimer:killTimer()

	Countdown.destroyAll()

	for i,player in pairs(g_Players) do
		setPlayerFinished(player, false)
		destroyMessage(player)
	end
	destroyMessage(g_Root)
	
	table.each(g_Vehicles, destroyElement)
	g_Vehicles = {}
	g_Spawnpoints = {}
	g_Checkpoints = {}
	g_Objects = {}
	g_Pickups = {}
	unloadedPickups = {}
	table.each(pickupTimers,killTimer)
	pickupTimers = {}
	if g_CurrentRaceMode then
		g_CurrentRaceMode:destroy()
	end
	g_CurrentRaceMode = nil
end

addEventHandler('onGamemodeMapStop', g_Root,
	function(mapres)
		--Clear the scoreboard
		for i,player in ipairs(getElementsByType"player") do
			setElementData ( player, "race rank", "" )
			setElementData ( player, "checkpoint", "" )
		end
        fadeCamera ( g_RootPlayers, false, 0.0, 0,0, 0 )
        gotoState('NoMap')
		unloadAll()
	end
)

-- Called from:
--      nowhere
addEventHandler('onPollDraw', g_Root,
	function()
		outputDebugString('Poll ended in a draw')
	end
)

-- Re-get resource call interfaces
addEventHandler('onResourceStart', g_Root,
	function(res)
        local resourceName = getResourceName(res)
        if resourceName == 'scoreboard' then
            scoreboard = createResourceCallInterface('scoreboard')
        elseif resourceName == 'votemanager' then
            votemanager = createResourceCallInterface('votemanager')
        elseif resourceName == 'mapmanager' then
            mapmanager = createResourceCallInterface('mapmanager')
	    end
	end
)

addEventHandler('onResourceStart', g_ResRoot,
	function()
		outputDebugString('Race resource starting')
		startAddons()
	end
)

addEventHandler('onGamemodeStart', g_ResRoot,
    function()
	    outputDebugString('Race onGamemodeStart')
		scoreboard.addScoreboardColumn('race rank')
		scoreboard.addScoreboardColumn('checkpoint')
		scoreboard.addScoreboardColumn('state')
		if not g_GameOptions then
	        cacheGameOptions()
		end
    end
)

addEventHandler('onResourceStop', g_ResRoot,
	function()
        gotoState( 'Race resource stopping' )
        fadeCamera ( g_Root, false, 0.0, 0,0, 0 )
		outputDebugString('Resource stopping')
		unloadAll()
		scoreboard.removeScoreboardColumn('race rank')
		scoreboard.removeScoreboardColumn('checkpoint')
		scoreboard.removeScoreboardColumn('state')
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
		
		for i,player in pairs(g_Players) do
			if not isPlayerFinished(player) then
				return
			end
		end
        
		if getTotalPlayerCount() < 2 then
			outputDebugString('Stopping map')
			triggerEvent('onGamemodeMapStop', g_Root)
		else
            gotoState('EveryoneFinished')
            RaceMode.endMap()
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

addEvent('onRequestKillPlayer', true)
addEventHandler('onRequestKillPlayer', g_Root,
    function()
        local player = source
        if stateAllowsKillPlayer() then
            setElementHealth(player, 0)
            toggleAllControls(player,false, true, false)
        end
    end
)

addCommandHandler('ghostmode',
	function(player)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		g_MapOptions.ghostmode = not g_MapOptions.ghostmode
		g_GameOptions.ghostmode = not g_GameOptions.ghostmode
		set('*ghostmode', g_GameOptions.ghostmode and 'true' or 'false' )
		clientCall(g_Root, 'setGhostMode', g_GameOptions.ghostmode)
		if g_GameOptions.ghostmode then
			outputChatBox('Ghostmode enabled by ' .. getPlayerName(player), g_Root, 0, 240, 0)
		else
			outputChatBox('Ghostmode disabled by ' .. getPlayerName(player), g_Root, 240, 0, 0)
		end
	end
)

-- Handle client request for manual spectate
addEvent('onClientRequestSpectate', true)
addEventHandler('onClientRequestSpectate', g_Root,
	function(enable)
		-- Checks if switching on
		if enable then
			if not stateAllowsManualSpectate() then return end
		end
		if isPlayerSpectating(source) ~= enable then
			setPlayerSpectating( source, enable )
			if enable then
				clientCall(source, "Spectate.start", 'manual' )
			else
				clientCall(source, "Spectate.stop", 'manual' )
			end
		end
	end
)

function setPlayerSpectating(player, toggle)
	setElementData(player, 'race.spectating', toggle)
end

function isPlayerSpectating(player)
	return getElementData(player, 'race.spectating') or false
end


addEvent('onNotifyPlayerReady', true)
addEventHandler('onNotifyPlayerReady', g_Root,
	function()
        setPlayerReady( source )
		for i, pickupID in ipairs(unloadedPickups) do
			-- outputDebugString(getPlayerName(source).." unload "..tostring(pickupID))
			clientCall(source, "unloadPickup", pickupID )
		end
	end
)

------------------------
-- Players not ready stuff
g_NotReady = {}             -- { player = bool }
g_NotReadyTimer = nil
g_NotReadyDisplay = nil
g_NotReadyTextItems = {}
g_NotReadyDisplayOnTime = 0
g_JoinerExtraWait = nil
g_NotReadyTimeout = nil
g_NotReadyMaxWait = nil

-- Remove ref if player quits
addEventHandler('onPlayerQuit', g_Root,
	function()
        g_NotReady[source] = nil
	end
)

-- Give 10 seconds for joining players to become not ready
addEventHandler('onPlayerJoining', g_Root,
	function()
        g_JoinerExtraWait = getTickCount() + 10000
	end
)

-- Give 5 seconds for first player to start joining
addEventHandler('onGamemodeMapStart', g_Root,
	function(mapres)
        g_JoinerExtraWait = getTickCount() + 5000
		g_NotReadyMaxWait = false
	end
)

-- Give 30 seconds for not ready players to become ready
function setPlayerNotReady( player )
    g_NotReady[player] = true
    g_NotReadyTimeout = getTickCount() + 20000 + 10000
    if _DEBUG_TIMING then g_NotReadyTimeout = g_NotReadyTimeout - 15000 end
    activateNotReadyText()
end

-- Alter not ready timeout 
function setPlayerReady( player )
	setElementData(player, "state", "alive")
    g_NotReady[player] = false
    g_NotReadyTimeout = getTickCount() + 20000
    if _DEBUG_TIMING then g_NotReadyTimeout = g_NotReadyTimeout - 10000 end
	-- Set max timeout to 30 seconds after first person is ready
	if not g_NotReadyMaxWait then
		g_NotReadyMaxWait = getTickCount() + 30000
	end
end

function isPlayerNotReady( player )
    return g_NotReady[player]
end


function howManyPlayersNotReady()
    local count = 0
    for i,player in ipairs(g_Players) do
        if isPlayerNotReady(player) then
            count = count + 1
        end
    end
    if g_JoinerExtraWait and g_JoinerExtraWait > getTickCount() then
        count = count + 1 -- If the JoinerExtraWait is set, pretend someone is not ready
    end
    if g_NotReadyTimeout and g_NotReadyTimeout < getTickCount() then
        count = 0       -- If the NotReadyTimeout has passed, pretend everyone is ready
    end
    if g_NotReadyMaxWait and g_NotReadyMaxWait < getTickCount() then
        count = 0       -- If the NotReadyMaxWait has passed, pretend everyone is ready
    end
    return count, names
end


function activateNotReadyText()
    if stateAllowsNotReadyMessage() then
        if not g_NotReadyTimer then
            g_NotReadyTimer = setTimer( updateNotReadyText, 100, 0 )
	        g_NotReadyDisplay = textCreateDisplay()
	        g_NotReadyTextItems[1] = textCreateTextItem('', 0.5, 0.7, 'medium', 255, 235, 215, 255, 1.5, 'center', 'center')
	        textDisplayAddText(g_NotReadyDisplay, g_NotReadyTextItems[1])
        end
    end
end

function updateNotReadyText()
    if howManyPlayersNotReady() == 0 then
        deactiveNotReadyText()
    end
	if g_NotReadyDisplay then
        -- Make sure all ready players are observers
        for i,player in ipairs(g_Players) do
            if isPlayerNotReady(player) then
                textDisplayRemoveObserver(g_NotReadyDisplay, player)
            else
                if not textDisplayIsObserver(g_NotReadyDisplay, player) then
                    textDisplayAddObserver(g_NotReadyDisplay, player)
                    g_NotReadyDisplayOnTime = getTickCount()
                end
            end
        end
		-- Only show 'Waiting for other players...' if there actually are any other players
		if getTotalPlayerCount() > 1 then
			textItemSetText(g_NotReadyTextItems[1], 'Waiting for other players...' )
		end
	end
end

function deactiveNotReadyText()
    if g_NotReadyTimer then
        killTimer( g_NotReadyTimer )
        -- Ensure message is displayed for at least 2 seconds
        local hideDisplayDelay  = math.max(50,math.min(2000,2000+g_NotReadyDisplayOnTime - getTickCount()))
        local display           = g_NotReadyDisplay;
        local textItems         = { g_NotReadyTextItems[1] };
		setTimer(
            function()
		        textDestroyDisplay(display)
		        textDestroyTextItem(textItems[1])
            end,
            hideDisplayDelay, 1 )
        g_NotReadyTimer = nil
		g_NotReadyDisplay = nil
		g_NotReadyTextItems[1] = nil
    end
end


------------------------
-- addon management
Addons = {}
Addons.report = {}
Addons.reportShort = ''

-- Start addon resources listed in the setting 'race.addons'
function startAddons()
	Addons.report = {}
	Addons.reportShort = ''

	-- Check permissions
	local bCanStartResource = hasObjectPermissionTo ( getThisResource(), "function.startResource", false )
	local bCanStopResource = hasObjectPermissionTo ( getThisResource(), "function.stopResource", false )
	if not bCanStartResource or not bCanStopResource then
		local line1 = 'WARNING: Race does not have permission to start/stop resources'
		local line2 = 'WARNING: Addons may not function correctly'
		outputDebugString( line1 )
		outputDebugString( line2 )
		table.insert(Addons.report,line1)
		table.insert(Addons.report,line2)
	end

	for idx,name in ipairs(string.split(getString('race.addons'),',')) do
		if name ~= '' then
			local resource = getResourceFromName(name)
			if not resource then
				outputWarning( "Can't use addon '" .. name .. "', as it is not the name of a resource" )
			else
				if getResourceInfo ( resource, 'addon' ) ~= 'race' then
					outputWarning( "Can't use addon " .. name .. ', as it does not have addon="race" in the info section' )
				else
					-- Start or restart resource
					if getResourceState(resource) == 'running' then
						-- restartResource(resource)
					else
						startResource(resource)
					end
					-- Update Addons.report
					local tag = getResourceInfo ( resource, 'name' ) or getResourceName(resource)
					local build = getResourceInfo ( resource, 'build' ) or ''
					local version = getResourceInfo ( resource, 'version' ) or ''
					local author = getResourceInfo ( resource, 'author' ) or ''
					local description = getResourceInfo ( resource, 'description' ) or ''
					local line = tag .. ' - ' .. description .. ' - by ' .. author .. ' - version [' .. version .. '] [' .. build .. ']'
					table.insert(Addons.report,line)
					-- Update Addons.reportShort
					if  Addons.reportShort ~= '' then
						Addons.reportShort = Addons.reportShort .. ', '
					end
					Addons.reportShort = Addons.reportShort .. tag
				end
			end
		end
	end
end


------------------------
-- Testing commands

addCommandHandler('restartracemode',
	function(player)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
        exports.mapmanager:changeGamemode( getResourceFromName('race') )
	end
)


addCommandHandler('pipedebug',
	function(player, command, arg)
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
        if g_PipeDebugTo then
            clientCall(g_PipeDebugTo, 'setPipeDebug', false)
        end
        g_PipeDebugTo = (arg == "1") and player
        if g_PipeDebugTo then
            clientCall(g_PipeDebugTo, 'setPipeDebug', true)
        end
	end
)


------------------------
-- Exported functions

function getPlayerRank(player)
	if not g_CurrentRaceMode or not g_CurrentRaceMode:isRanked() then
		return false
	end
	return g_CurrentRaceMode:getPlayerRank(player)
end

function getTimePassed()
	if not g_CurrentRaceMode then
		return false
	end
	return g_CurrentRaceMode:getTimePassed()
end

