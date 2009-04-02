g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_Me = getLocalPlayer()
g_ArmedVehicleIDs = table.create({ 425, 447, 520, 430, 464, 432 }, true)
g_ModelForPickupType = { nitro = 1337, repair = 1338, vehiclechange = 1339 }
server = createServerCallInterface()

g_Checkpoints = {}
g_Pickups = {}
g_VisiblePickups = {}
g_Objects = {}

--_DEBUG = {'undef','Xopt','Xtoptimes'}   -- More error output
_TESTING = true             -- Any user can issue test commands

addEventHandler('onClientResourceStart', g_ResRoot,
	function()
		g_Players = getElementsByType('player')
		
        fadeCamera(false,0.0)
		-- create GUI
		local screenWidth, screenHeight = guiGetScreenSize()
		g_GUI = {
			rankbg = guiCreateStaticImage(screenWidth-100, screenHeight-80, 100, 45, 'img/rankbg.png', false, nil),
			rank = guiCreateLabel(screenWidth-100, screenHeight-75, 100, 20, '', false),
			checkpoint = guiCreateLabel(screenWidth-100, screenHeight-57, 100, 20, '', false),
			timepassedbg = guiCreateStaticImage(screenWidth-100, screenHeight-35, 100, 35, 'img/timepassedbg.png', false, nil),
			timepassed = guiCreateLabel(screenWidth-100, screenHeight-25, 100, 20, '', false),
			timeleftbg = guiCreateStaticImage(screenWidth/2-108/2, 15, 108, 24, 'img/timeleft.png', false, nil),
			timeleft = guiCreateLabel(screenWidth/2-108/2, 19, 108, 30, '', false),
			healthbar = FancyProgress.create(100, 1000, 'img/progress_health_bg.png', -65, 105, 123, 30, 'img/progress_health.png', 7, 7, 109, 16),
			speedbar = FancyProgress.create(0, 1.5, 'img/progress_speed_bg.png', -65, 135, 123, 30, 'img/progress_speed.png', 7, 7, 109, 16),
			miscMessage = guiCreateLabel(screenWidth/2-150, screenHeight/2, 300, 20, '', false),
		}
		guiSetAlpha(g_GUI.rankbg, 0.3)
		guiSetAlpha(g_GUI.timepassedbg, 0.3)
		hideGUIComponents('healthbar', 'speedbar', 'rankbg', 'rank', 'timepassedbg', 'timeleftbg', 'checkpoint')
		for i,name in ipairs({'rank', 'checkpoint', 'timepassed', 'timeleft'}) do
			guiSetFont(g_GUI[name], 'default-bold-small')
			guiLabelSetHorizontalAlign(g_GUI[name], 'center')
		end
		g_GUI.speedbar:setProgress(0)
        RankingBoard.precreateLabels(10)
		
		-- set update handlers
		g_PickupStartTick = getTickCount()
		addEventHandler('onClientRender', g_Root, updateBars)
		g_WaterCheckTimer = setTimer(checkWater, 1000, 0)
		
		-- load pickup models and textures
		for name,id in pairs(g_ModelForPickupType) do
			loadCustomModel(id, 'model/' .. name .. '.dff', 'model/' .. name .. '.txd')
		end
		
		setPedCanBeKnockedOffBike(g_Me, false)
        if _DEBUG then
    		setTimer( function() triggerServerEvent('onLoadedAtClient', g_Me) end, math.random(3000,5000), 1 )
        else
    		triggerServerEvent('onLoadedAtClient', g_Me)
	    end
	end
)


------------------------------------------------
-- Misc message for client feedback when loading big maps
------------------------------------------------

function showMiscMessage( text )
    guiLabelSetHorizontalAlign(g_GUI['miscMessage'], 'center')
    guiSetText(g_GUI['miscMessage'], text) 
    guiSetVisible(g_GUI['miscMessage'], true)
end

function hideMiscMessage()
	guiSetVisible(g_GUI['miscMessage'], false)
end

function notifyLoadingMap( mapName )
    fadeCamera( false, 0.0, 0,0,16 ) -- fadeout, instant, dark blue
    showMiscMessage( 'Travelling to ' .. mapName )
end


function initRace(vehicle, checkpoints, objects, pickups, mapoptions, ranked, duration, gameoptions, mapinfo, playerInfo)
    outputDebug( 'initRace start' )
    hideMiscMessage()
	unloadAll()
	
	g_Players = getElementsByType('player')
	g_MapOptions = mapoptions
	g_GameOptions = gameoptions
	g_MapInfo = mapinfo
    g_PlayerInfo = playerInfo
    triggerEvent('onMapStarting', g_Me, mapinfo )
	
	--fadeCamera(true)
	showHUD(false)
	
	g_Vehicle = vehicle
	setVehicleDamageProof(g_Vehicle, true)
	setGhostMode(g_MapOptions.ghostmode)
	
	--local x, y, z = getElementPosition(g_Vehicle)
	setCameraBehindVehicle(vehicle)
	--alignVehicleToGround(vehicle)
	local weapons = not g_ArmedVehicleIDs[getElementModel(vehicle)] or g_MapOptions.vehicleweapons
	toggleControl('vehicle_fire', weapons)
	toggleControl('vehicle_secondary_fire', weapons)
	
	-- checkpoints
	g_Checkpoints = checkpoints
	
	-- pickups
	local pickupElem
	local pos
	local colshape
	for i,pickup in pairs(pickups) do
		pos = pickup.position
		object = createObject(g_ModelForPickupType[pickup.type], pos[1], pos[2], pos[3])
		setElementCollisionsEnabled(object, false)
		colshape = createColSphere(pos[1], pos[2], pos[3], 5)
		g_Pickups[colshape] = { object = object }
		for k,v in pairs(pickup) do
			g_Pickups[colshape][k] = v
		end
        if g_Pickups[colshape].type == 'vehiclechange' then
			g_Pickups[colshape].label = guiCreateLabel(0, 0, 150, 20, getVehicleNameFromModel(g_Pickups[colshape].vehicle), false)
			guiSetVisible(g_Pickups[colshape].label, false )
			guiSetAlpha(g_Pickups[colshape].label, 0 )
        end
	end
	
	-- objects
	g_Objects = {}
	local pos, rot
	for i,object in ipairs(objects) do
		pos = object.position
		rot = object.rotation
		g_Objects[i] = createObject(object.model, pos[1], pos[2], pos[3], rot[1], rot[2], rot[3])
	end

    -- Make sure one copy of each model does not get streamed out to help caching.
    local nonStreamedModels = {}
 	for i,obj in ipairs(g_Objects) do
        local model = getElementModel ( obj )
        if model and not nonStreamedModels[model] then
            if setElementStreamable ( obj, false ) then
                nonStreamedModels[model] = obj
            else
                outputDebug( 'setElementStreamable( obj, false ) failed for ' .. tostring(model) )
            end           
        end
    end
	
	if #g_Checkpoints > 0 then
		g_CurrentCheckpoint = 0
		showNextCheckpoint()
	end
	
	-- GUI
	showGUIComponents('healthbar', 'speedbar')
	if ranked then
		showGUIComponents('rankbg', 'rank')
	else
		hideGUIComponents('rankbg', 'rank')
	end
	guiSetVisible(g_GUI.checkpoint, #g_Checkpoints > 0)
	
	g_HurryDuration = g_GameOptions.hurrytime
	if duration then
		launchRace(duration)
	end

    fadeCamera( false, 0.0 )
    setTimer(fadeCamera, 750, 1, true, 10.0)
    setTimer(fadeCamera, 1500, 1, true, 2.0)
    setTimer( function() triggerServerEvent('onClientRaceReady', g_Me) end, 3500, 1 )
    outputDebug( 'initRace end' )
end

function launchRace(duration)
	g_Players = getElementsByType('player')
	
	if type(duration) == 'number' then
		showGUIComponents('timepassedbg', 'timepassed', 'timeleftbg', 'timeleft')
		guiLabelSetColor(g_GUI.timeleft, 255, 255, 255)
		g_Duration = duration
		addEventHandler('onClientRender', g_Root, updateTime)
	else
		hideGUIComponents('timepassedbg', 'timepassed', 'timeleftbg', 'timeleft')
	end
	
	setVehicleDamageProof(g_Vehicle, false)
	
	g_StartTick = getTickCount()
end

function setGhostMode(ghostmode)
	g_GhostMode = ghostmode
	local vehicle
	for i,player in ipairs(g_Players) do
        if g_GameOptions and g_GameOptions.ghostalpha then
		    setElementAlpha(player, ghostmode and 200 or 255)
        end
		vehicle = getPedOccupiedVehicle(player)
		if vehicle then
			if player ~= g_Me then
				setElementCollisionsEnabled(vehicle, not ghostmode)
			end
            if g_GameOptions and g_GameOptions.ghostalpha then
			    setElementAlpha(vehicle, ghostmode and 200 or 255)
		    end
		end
	end
end

addEventHandler('onClientElementStreamIn', g_Root,
	function()
		local colshape = table.find(g_Pickups, 'object', source)
		if colshape then
			local pickup = g_Pickups[colshape]
			if pickup.label then
				guiSetVisible(pickup.label, false)
				guiSetAlpha(pickup.label, 0)
				guiLabelSetHorizontalAlign(pickup.label, 'center')
			end
			g_VisiblePickups[colshape] = source
			g_VisiblePickups.n = (g_VisiblePickups.n or 0) + 1
			if g_VisiblePickups.n == 1 then
				addEventHandler('onClientRender', g_Root, updatePickups)
			end
		end
	end
)

addEventHandler('onClientElementStreamOut', g_Root,
	function()
		local colshape = table.find(g_VisiblePickups, source)
		if colshape then
			local pickup = g_Pickups[colshape]
			if pickup.label then
				guiSetVisible(pickup.label, false)
				pickup.labelVisible = nil
				pickup.labelInRange = nil
			end
			g_VisiblePickups[colshape] = nil
			g_VisiblePickups.n = g_VisiblePickups.n - 1
			if g_VisiblePickups.n == 0 then
				removeEventHandler('onClientRender', g_Root, updatePickups)
			end
		end
	end
)

function updatePickups()
	local angle = math.fmod((getTickCount() - g_PickupStartTick) * 360 / 2000, 360)
	local g_Pickups = g_Pickups
	local pickup, x, y, pX, pY, pZ
	for colshape,elem in pairs(g_VisiblePickups) do
		if colshape ~= 'n' then
			setElementRotation(elem, 0, 0, angle)
			pickup = g_Pickups[colshape]
			if pickup.label then
				local pX, pY, pZ = getElementPosition(g_Me)
				x, y = getScreenFromWorldPosition(unpack(pickup.position))
                local distanceToPickup = getDistanceBetweenPoints3D(pX, pY, pZ, unpack(pickup.position))
                if distanceToPickup > 100 then
					if pickup.labelVisible then
						guiSetVisible(pickup.label, false)
						pickup.labelVisible = false
					end
				    if pickup.labelInRange then
                        guiSetAlpha(pickup.label,0)
					    pickup.labelInRange = false
				    end
				elseif x then
					if not pickup.labelVisible then
						guiSetVisible(pickup.label, true)
						pickup.labelVisible = true
					end
					if distanceToPickup < 80 then
						if not pickup.labelInRange then
							Animation.createAndPlay(
								pickup.label,
								{ from = 0, to = 1, time = 500, fn = guiSetAlpha }
							)
							pickup.labelInRange = true
						end
					else
						if pickup.labelInRange then
							Animation.createAndPlay(
								pickup.label,
								{ from = 1, to = 0, time = 1000, fn = guiSetAlpha }
							)
							pickup.labelInRange = false
						end
					end
					guiSetPosition(pickup.label, x-75, y-50, false)
				else
					if pickup.labelVisible then
						guiSetVisible(pickup.label, false)
						pickup.labelVisible = false
					end
				end
			end
		end
	end
end

addEventHandler('onClientColShapeHit', g_Root,
	function(elem)
		local pickup = g_Pickups[source]
		if elem ~= g_Vehicle or not pickup then
			return
		end
		if pickup.type == 'vehiclechange' then
			if pickup.vehicle == getElementModel(g_Vehicle) then
				return
			end
			g_PrevVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(g_Vehicle)
		end
		triggerServerEvent('onPlayerPickUpRacePickup', g_Me, pickup.id, pickup.type)
		playSoundFrontEnd(46)
	end
)

function vehicleChanging(h, m)
	local newVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(g_Vehicle)
	if g_PrevVehicleHeight and newVehicleHeight > g_PrevVehicleHeight then
		local x, y, z = getElementPosition(g_Vehicle)
		setElementPosition(g_Vehicle, x, y, z - g_PrevVehicleHeight + newVehicleHeight)
	end
	g_PrevVehicleHeight = nil
	local weapons = not g_ArmedVehicleIDs[getElementModel(g_Vehicle)] or g_MapOptions.vehicleweapons
	toggleControl('vehicle_fire', weapons)
	toggleControl('vehicle_secondary_fire', weapons)
end

function vehicleUnloading()
	g_Vehicle = nil
end

function updateBars()
	if g_Vehicle then
		g_GUI.healthbar:setProgress(getElementHealth(g_Vehicle))
		local vx, vy, vz = getElementVelocity(g_Vehicle)
		g_GUI.speedbar:setProgress(math.sqrt(vx*vx + vy*vy + vz*vz))
	end
end

function updateTime()
	local tick = getTickCount()
	local msPassed = tick - g_StartTick
	if not isPlayerFinished(g_Me) then
		guiSetText(g_GUI.timepassed, msToTimeStr(msPassed))
	end
	local timeLeft = g_Duration - msPassed
	if g_HurryDuration and g_GUI.hurry == nil and timeLeft <= g_HurryDuration then
		startHurry()
	end
	guiSetText(g_GUI.timeleft, msToTimeStr(timeLeft > 0 and timeLeft or 0))
end

addEventHandler('onClientElementDataChange', g_Me,
	function(dataName)
		if dataName == 'race rank' then
			local rank = getElementData(g_Me, 'race rank')
			guiSetText(g_GUI.rank, tostring(rank) .. ( (rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th' ))
		end
	end,
	false
)

function checkWater()
	local x, y, z = getElementPosition(g_Me)
	local waterZ = getWaterLevel(x, y, z)
	if waterZ and z < waterZ - 0.5 and not isPlayerFinished(g_Me) then
		setElementHealth(g_Me, 0)
	end
end

function showNextCheckpoint()
	g_CurrentCheckpoint = g_CurrentCheckpoint + 1
	local i = g_CurrentCheckpoint
	guiSetText(g_GUI.checkpoint, (i-1) .. ' / ' .. #g_Checkpoints)
	if i > 1 then
		destroyCheckpoint(i-1)
	else
		createCheckpoint(1)
	end
	makeCheckpointCurrent(i)
	if i < #g_Checkpoints then
		local curCheckpoint = g_Checkpoints[i]
		local nextCheckpoint = g_Checkpoints[i+1]
		local nextMarker = createCheckpoint(i+1)
		setMarkerTarget(curCheckpoint.marker, unpack(nextCheckpoint.position))
	end
	setElementData(g_Me, 'race.checkpoint', i)
end

function checkpointReached(elem)
	if elem ~= g_Vehicle then
		return
	end
	
	if g_Checkpoints[g_CurrentCheckpoint].vehicle then
		g_PrevVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(g_Vehicle)
	end
	triggerServerEvent('onPlayerReachCheckpointInternal', g_Me, g_CurrentCheckpoint)
	playSoundFrontEnd(43)
	if g_CurrentCheckpoint < #g_Checkpoints then
		showNextCheckpoint()
	else
		guiSetText(g_GUI.checkpoint, #g_Checkpoints .. ' / ' .. #g_Checkpoints)
		if g_GUI.hurry then
			Animation.createAndPlay(g_GUI.hurry, Animation.presets.guiFadeOut(500), destroyElement)
			g_GUI.hurry = false
		end
		destroyCheckpoint(#g_Checkpoints)
        triggerEvent('onPlayerReachedFinish', g_Me)
		toggleAllControls(false, true, false)
	end
end

function startHurry()
	if not isPlayerFinished(g_Me) then
		local screenWidth, screenHeight = guiGetScreenSize()
		local w, h = resAdjust(364), resAdjust(82)
		g_GUI.hurry = guiCreateStaticImage(screenWidth/2 - w/2, screenHeight - h - 40, w, h, 'img/hurry.png', false, nil)
		guiSetAlpha(g_GUI.hurry, 0)
		Animation.createAndPlay(g_GUI.hurry, Animation.presets.guiFadeIn(800))
		Animation.createAndPlay(g_GUI.hurry, Animation.presets.guiPulse(1000))
	end
	guiLabelSetColor(g_GUI.timeleft, 255, 0, 0)
end

function setTimeLeft(timeLeft)
	g_Duration = (getTickCount() - g_StartTick) + timeLeft
end

function startSpectate()
	if #g_Players == 1 or g_SpectatedPlayer then
		return
	end
	local screenWidth, screenHeight = guiGetScreenSize()
	g_GUI.specprev = guiCreateStaticImage(screenWidth/2 - 100 - 58, screenHeight - 123, 58, 82, 'img/specprev.png', false, nil)
	g_GUI.specprevhi = guiCreateStaticImage(screenWidth/2 - 100 - 58, screenHeight - 123, 58, 82, 'img/specprev_hi.png', false, nil)
	g_GUI.specnext = guiCreateStaticImage(screenWidth/2 + 100, screenHeight - 123, 58, 82, 'img/specnext.png', false, nil)
	g_GUI.specnexthi = guiCreateStaticImage(screenWidth/2 + 100, screenHeight - 123, 58, 82, 'img/specnext_hi.png', false, nil)
	g_GUI.speclabel = guiCreateLabel(screenWidth/2 - 100, screenHeight - 100, 200, 50, '', false)
	guiLabelSetHorizontalAlign(g_GUI.speclabel, 'center')
	hideGUIComponents('specprevhi', 'specnexthi')
	repeat
		g_SpectatedPlayer = g_Players[math.random(#g_Players)]
	until g_SpectatedPlayer ~= g_Me
	bindKey('arrow_l', 'down', spectatePrevious)
	bindKey('arrow_r', 'down', spectateNext)
	updateSpectate()
    startMovePlayerAway()
end

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- MovePlayerAway
--
-- Super hack - Fixes the spec cam problem
--
function startMovePlayerAway()
    if g_MoveAwayTimer then
        killTimer( g_MoveAwayTimer )
    end
 
    g_PlrWasDeadAtSpecStart = getElementHealth(g_Me) == 0

    if not g_PlrWasDeadAtSpecStart then
        return
    end

    movePlayerAway()
    g_MoveAwayTimer = setTimer(movePlayerAway,1000,0)

    setCameraTarget(g_SpectatedPlayer)
end

function movePlayerAway()
    if g_PlrWasDeadAtSpecStart then
        -- If our player is dead while specing, move him far away
        local temp = getCameraTarget()   
        local vehicle = getPedOccupiedVehicle(g_Me)
        if vehicle then
            fixVehicle( vehicle )
            setElementPosition( vehicle, 0,0,1234567 )
            setElementVelocity( vehicle, 0,0,0 )
            setVehicleTurnVelocity( vehicle, 0,0,0 )
        else
            setElementPosition( g_Me, 0,0,1234567 )
            setElementVelocity( g_Me, 0,0,0 )
        end
        server.setPlayerGravity( g_Me, 0.0001 )
        setElementHealth( g_Me, 90 )

        if temp ~= getCameraTarget() then
            setCameraTarget(temp)
        end
    end
end

function stopMovePlayerAway()
    if g_MoveAwayTimer then
        killTimer( g_MoveAwayTimer )
        g_MoveAwayTimer = nil
    end
    server.setPlayerGravity( g_Me, 0.008 )
end
-----------------------------------------------------------------------
-----------------------------------------------------------------------


function spectatePrevious()
	local i = table.find(g_Players, g_SpectatedPlayer)
	local startI = i
	repeat
		i = (i == 1) and #g_Players or (i - 1)
	until (g_Players[i] ~= g_Me and not isPlayerFinished(g_Players[i])) or i == startI
	if i ~= startI then
		g_SpectatedPlayer = g_Players[i]
		updateSpectate()
	end
	setGUIComponentsVisible({ specprev = false, specprevhi = true })
	setTimer(setGUIComponentsVisible, 100, 1, { specprevhi = false, specprev = true })
end

function spectateNext()
	local i = table.find(g_Players, g_SpectatedPlayer)
	local startI = i
	repeat
		i = (i == #g_Players) and 1 or (i + 1)
	until (g_Players[i] ~= g_Me and not isPlayerFinished(g_Players[i])) or i == startI
	if i ~= startI then
		g_SpectatedPlayer = g_Players[i]
		updateSpectate()
	end
	setGUIComponentsVisible({ specnext = false, specnexthi = true })
	setTimer(setGUIComponentsVisible, 100, 1, { specnexthi = false, specnext = true })
end

function updateSpectate()
    -- What does the timer version do? - Removed because of a problem at the end of spectating.
	--setTimer(setCameraTarget, 100, 1, g_SpectatedPlayer)
	setCameraTarget(g_SpectatedPlayer)
	guiSetText(g_GUI.speclabel, 'Currently spectating:\n' .. getPlayerName(g_SpectatedPlayer))
end

function stopSpectate()
	for i,name in ipairs({'specprev', 'specprevhi', 'specnext', 'specnexthi', 'speclabel'}) do
		if g_GUI[name] then
			destroyElement(g_GUI[name])
			g_GUI[name] = nil
		end
	end
	unbindKey('arrow_l', 'down', spectatePrevious)
	unbindKey('arrow_r', 'down', spectateNext)
    stopMovePlayerAway()
	setCameraTarget(g_Me)
	g_SpectatedPlayer = nil
end

--
-- Camera transition for our player's respawn
--
function remoteStopSpectateAndBlack()
    stopSpectate()
    fadeCamera(false,0.0, 0,0,0)            -- Instant black
end

function remoteSoonFadeIn()
    setTimer(fadeCamera,250,1,true,1.0)    -- And up
end

function raceTimeout()
	removeEventHandler('onClientRender', g_Root, updateTime)
	if g_CurrentCheckpoint then
		destroyCheckpoint(g_CurrentCheckpoint)
		destroyCheckpoint(g_CurrentCheckpoint + 1)
	end
	guiSetText(g_GUI.timeleft, msToTimeStr(0))
	guiSetText(g_GUI.timepassed, msToTimeStr(g_Duration))
	if g_GUI.hurry then
		Animation.createAndPlay(g_GUI.hurry, Animation.presets.guiFadeOut(500), destroyElement)
		g_GUI.hurry = nil
	end
	toggleAllControls(false, true, false)
end

function unloadAll()
    triggerEvent('onMapStopping', g_Me)
	for i=1,#g_Checkpoints do
		destroyCheckpoint(i)
	end
	g_Checkpoints = {}
	g_CurrentCheckpoint = nil
	
	for colshape,pickup in pairs(g_Pickups) do
		destroyElement(colshape)
		destroyElement(pickup.object)
		if pickup.label then
			destroyElement(pickup.label)
		end
	end
	g_Pickups = {}
	g_VisiblePickups = {}
	removeEventHandler('onClientRender', g_Root, updatePickups)
	
	table.each(g_Objects, destroyElement)
	g_Objects = {}
	
	setElementData(g_Me, 'race.checkpoint', nil)
	
	g_Vehicle = nil
	removeEventHandler('onClientRender', g_Root, updateTime)
	
	toggleAllControls(true)
	
	if g_GUI then
		hideGUIComponents('healthbar', 'speedbar', 'rankbg', 'rank', 'checkpoint', 'timepassed', 'timeleftbg', 'timeleft')
		if g_GUI.hurry then
			Animation.createAndPlay(g_GUI.hurry, Animation.presets.guiFadeOut(500), destroyElement)
			g_GUI.hurry = nil
		end
	end
	g_StartTick = nil
	g_HurryDuration = nil
	if g_SpectatedPlayer then
		stopSpectate()
	end
	
	setGhostMode(false)
end

function createCheckpoint(i)
	local checkpoint = g_Checkpoints[i]
	if checkpoint.marker then
		return
	end
	local pos = checkpoint.position
	local color = checkpoint.color or { 255, 0, 0 }
	checkpoint.size = checkpoint.size or 2.25
	checkpoint.marker = createMarker(pos[1], pos[2], pos[3], checkpoint.type or 'checkpoint', checkpoint.size*2, color[1], color[2], color[3])
	if (not checkpoint.type or checkpoint.type == 'checkpoint') and i == #g_Checkpoints then
		setMarkerIcon(checkpoint.marker, 'finish')
	end
	if checkpoint.type == 'ring' and i < #g_Checkpoints then
		setMarkerTarget(checkpoint.marker, unpack(g_Checkpoints[i+1].position))
	end
	checkpoint.blip = createBlip(pos[1], pos[2], pos[3], 0, isCurrent and 2 or 1, color[1], color[2], color[3])
	return checkpoint.marker
end

function makeCheckpointCurrent(i)
	local checkpoint = g_Checkpoints[i]
	local pos = checkpoint.position
	local color = checkpoint.color or { 255, 0, 0 }
	if not checkpoint.blip then
		checkpoint.blip = createBlip(pos[1], pos[2], pos[3], 0, 2, color[1], color[2], color[3])
	else
		setBlipSize(checkpoint.blip, 2)
	end
	
	if not checkpoint.type or checkpoint.type == 'checkpoint' then
		checkpoint.colshape = createColCircle(pos[1], pos[2], checkpoint.size*4)
	else
		checkpoint.colshape = createColSphere(pos[1], pos[2], pos[3], checkpoint.size*8)
	end
	addEventHandler('onClientColShapeHit', checkpoint.colshape, checkpointReached, false)
end

function destroyCheckpoint(i)
	local checkpoint = g_Checkpoints[i]
	if checkpoint and checkpoint.marker then
		destroyElement(checkpoint.marker)
		checkpoint.marker = nil
		destroyElement(checkpoint.blip)
		checkpoint.blip = nil
		if checkpoint.colshape then
			destroyElement(checkpoint.colshape)
			checkpoint.colshape = nil
		end
	end
end

function setCurrentCheckpoint(i)
	destroyCheckpoint(g_CurrentCheckpoint)
	destroyCheckpoint(g_CurrentCheckpoint + 1)
	createCheckpoint(i)
	g_CurrentCheckpoint = i - 1
	showNextCheckpoint()
end

function isPlayerFinished(player)
	return getElementData(player, 'race.finished')
end

addEventHandler('onClientPlayerJoin', g_Root,
	function()
		table.insert(g_Players, source)
	end
)

addEventHandler('onClientPedWasted', g_Root,
	function()
		if not g_StartTick then
			return
		end
		if source == g_Me then
			if #g_Players > 1 and (g_MapOptions.respawn == 'none' or g_MapOptions.respawntime >= 10000) then
				setTimer(startSpectate, 2000, 1)
			end
			if g_MapOptions.respawn == 'timelimit' and not g_GhostMode then
				setTimer(setGhostMode, g_MapOptions.respawntime + 2000, 1, false)
			end
			setGhostMode(true)
		else
			local vehicle = getPedOccupiedVehicle(source)
			if vehicle then
				setElementCollisionsEnabled(vehicle, false)
				if g_MapOptions.respawn == 'timelimit' and not g_GhostMode then
					setTimer(setElementCollisionsEnabled, g_MapOptions.respawntime + 2000, 1, vehicle, true)
				end
			end
		end
	end
)

addEventHandler('onClientPlayerQuit', g_Root,
	function()
		if source == g_SpectatedPlayer then
			if getPlayerCount() > 1 then
				spectateNext()
			else
				stopSpectate()
			end
		end
		table.removevalue(g_Players, source)
	end
)

addEventHandler('onClientResourceStop', g_ResRoot,
	function()
		unloadAll()
		removeEventHandler('onClientRender', g_Root, updateBars)
		killTimer(g_WaterCheckTimer)
		showHUD(true)
		setPedCanBeKnockedOffBike(g_Me, true)
	end
)

addCommandHandler('spec',
	function()
		if not g_PlayerInfo.testing and not g_PlayerInfo.admin then
			return
		end
		if g_SpectatedPlayer then
			stopSpectate()
		else
			startSpectate()
		end
	end
)

function setPipeDebug(bOn)
    g_bPipeDebug = bOn
    outputConsole( 'bPipeDebug set to ' .. tostring(g_bPipeDebug) )
end
