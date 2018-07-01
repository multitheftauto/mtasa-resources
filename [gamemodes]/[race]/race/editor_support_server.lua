--
-- editor_support_server.lua
--


function isEditor()
	-- see if editor resource running
	if g_IsEditor == nil then
		local editorRes = getResourceFromName( "editor" )
		g_IsEditor = editorRes and getResourceState( editorRes ) == 'running'
		outputDebug ( "Server: Is editor " .. tostring(g_IsEditor == true) )
	end
	return g_IsEditor
end

-- set global element data to indicate if editor is running
setElementData(resourceRoot,"isEditor",isEditor())


-- Hacks start here
if isEditor() then

	-- Change: g_RaceStartCountdown
	g_RaceStartCountdown = Countdown.create(0, launchRace)
	g_RaceStartCountdown:setValueText(0, " ")


	-- Patch: howManyPlayersNotReady
	_howManyPlayersNotReady = howManyPlayersNotReady
	function howManyPlayersNotReady()
		if isEditor() then
			return 0
		end
		return _howManyPlayersNotReady()
	end


	-- From client - Use freeroam F1 menu to change vehicle
	addEvent('onEditorSelectCustomVehicle',true)
	addEventHandler('onEditorSelectCustomVehicle', resourceRoot,
		function(player, vehicle)
			local source = client
			if checkClient( false, source, 'onEditorSelectCustomVehicle' ) then return end
			-- See if custom vehicle selected in F1 menu
			if getElementType(vehicle) == "vehicle" then
				local x,y,z = getElementPosition(player)
				local distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(vehicle))
				-- Is nearby, not mine and has no driver?
				if distance < 5 and vehicle ~= g_Vehicles[player] and not getVehicleController(vehicle) then
					local modelid = getElementModel( vehicle )
					setElementModel( g_Vehicles[player], modelid )
					fixVehicle(g_Vehicles[player])
					setElementData( player, "race.editor.lastCustomVehicle", modelid )
					destroyElement(vehicle)
				end
			end
		end
	)

	-- From client - Step through vehicle models defined in the map
	addEvent('onEditorSelectMapVehicle',true)
	addEventHandler('onEditorSelectMapVehicle', resourceRoot,
		function(player, dir)
			local source = client
			if checkClient( false, source, 'onEditorChangeForCheckpoint' ) then return end
			local vehicle = g_Vehicles[client]

			if not dir then
				-- Last used custom model
				local modelid = getElementData( player, "race.editor.lastCustomVehicle" )
				if modelid then
					setElementModel(vehicle,modelid)
				end
				fixVehicle(vehicle)
				return
			end


			-- Make list of vehicle models
			local vehicleList = {}
			-- Look in cps,spawns,pickups
			for _,cp in ipairs(g_Checkpoints) do
				table.insertUnique( vehicleList, cp.vehicle )
			end
			for _,sp in ipairs(g_Spawnpoints) do
				table.insertUnique( vehicleList, sp.vehicle )
			end
			for _,pickup in ipairs(g_Pickups) do
				table.insertUnique( vehicleList, pickup.vehicle )
			end
			table.removevalue( vehicleList, nil )
			table.removevalue( vehicleList, false )

			-- Find index of current model
			local curmodel = getElementModel(vehicle)
			local curidx = table.find( vehicleList, curmodel )
			-- Get new index
			local nextidx = ((((curidx or 1) + dir ) - 1 ) % #vehicleList ) + 1
			-- Set new model
			local nextmodel = vehicleList[nextidx]
			setElementModel(vehicle,nextmodel)
			fixVehicle(vehicle)
		end
	)


	-- From client - Ensure vehicle has correct model id for checkpoint
	addEvent('onEditorChangeForCheckpoint',true)
	addEventHandler('onEditorChangeForCheckpoint', resourceRoot,
		function(player, checkpointNum)
			local source = client
			if checkClient( false, source, 'onEditorChangeForCheckpoint' ) then return end
			-- Starting from cp, go backwards until a vehicle change is found
			local vehicle = g_Vehicles[source]
			fixVehicle(vehicle)
			for i=checkpointNum,0,-1 do
				local checkpoint = i>0 and g_Checkpoints[i] or g_Spawnpoints[1]
				if checkpoint.vehicle then
					if getElementModel(vehicle) ~= tonumber(checkpoint.vehicle) then
						clientCall(source, 'alignVehicleWithUp')
						setVehicleID(vehicle, checkpoint.vehicle)
						clientCall(source, 'vehicleChanging', g_MapOptions.classicchangez, tonumber(checkpoint.vehicle))
						if checkpoint.paintjob or checkpoint.upgrades then
							setVehiclePaintjobAndUpgrades(vehicle, checkpoint.paintjob, checkpoint.upgrades)
						else
							if g_MapOptions.autopimp then
								pimpVehicleRandom(vehicle)
							end
						end
					end
					break
				end
			end

			-- Set any missing bkp checkpoints
			local modelid
			for i=0,RaceMode.getNumberOfCheckpoints() do
				local checkpoint = i>0 and g_Checkpoints[i] or g_Spawnpoints[1]
				if checkpoint.vehicle then
					modelid = checkpoint.vehicle
				end
				if i > 0 and not g_CurrentRaceMode.checkpointBackups[player][i] then

					local rz = 0
					if i < RaceMode.getNumberOfCheckpoints() then
						local curpos = checkpoint.position;
						local nextpos = g_Checkpoints[i+1].position;
						rz = -math.deg( math.atan2 ( ( nextpos[1] - curpos[1] ), ( nextpos[2] - curpos[2] ) ) )
					end
					g_CurrentRaceMode.checkpointBackups[player][i] = { vehicle = modelid,
															position = { checkpoint.position[1], checkpoint.position[2], checkpoint.position[3]+1 },
															rotation = { 0, 0, rz },
															velocity = { 0, 0, 0 },
															turnvelocity = { 0, 0, 0 },
															geardown = false }

					g_CurrentRaceMode.checkpointBackups[player].goingback = false
				end
			end
		end
	)

	-- Override game options
	_cacheGameOptions = cacheGameOptions
	function cacheGameOptions()
		_cacheGameOptions()
		g_GameOptions.joinspectating					= false
		g_GameOptions.joinrandomvote					= false
		g_GameOptions.ghostmode_map_can_override		= true
		g_GameOptions.skins_map_can_override			= true
		g_GameOptions.vehicleweapons_map_can_override   = true
		g_GameOptions.autopimp_map_can_override			= true
		g_GameOptions.firewater_map_can_override		= true
		g_GameOptions.classicchangez_map_can_override	= true
	end

	_cacheMapOptions = cacheMapOptions
	function cacheMapOptions(map)
		_cacheMapOptions(map)
		g_MapOptions.respawn = 'timelimit'
	end
end

