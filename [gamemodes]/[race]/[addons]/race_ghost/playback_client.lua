GhostPlayback = {}
GhostPlayback.__index = GhostPlayback

addEvent( "onClientGhostDataReceive", true )
addEvent( "clearMapGhost", true )

function GhostPlayback:create( recording, ped, vehicle )
	local result = {
		ped = ped,
		vehicle = vehicle,
		recording = recording,
		isPlaying = false,
		startTick = nil,
	}
	setElementCollisionsEnabled( result.ped, false )
	setElementCollisionsEnabled( result.vehicle, false )
	setVehicleFrozen( result.vehicle, true )
	setElementAlpha( result.ped, 100 )
	setElementAlpha( result.vehicle, 100 )
	return setmetatable( result, self )
end

function GhostPlayback:destroy( finished )
	self:stopPlayback( finished )
	if self.checkForCountdownEnd_HANDLER then removeEventHandler( "onClientRender", g_Root, self.checkForCountdownEnd_HANDLER ) self.checkForCountdownEnd_HANDLER = nil end
	if self.updateGhostState_HANDLER then removeEventHandler( "onClientRender", g_Root, self.updateGhostState_HANDLER ) self.updateGhostState_HANDLER = nil end
	if isTimer( self.ghostFinishTimer ) then
		killTimer( self.ghostFinishTimer )
		self.ghostFinishTimer = nil
	end
	self = nil
end

function GhostPlayback:preparePlayback()
	self.checkForCountdownEnd_HANDLER = function() self:checkForCountdownEnd() end
	addEventHandler( "onClientRender", g_Root, self.checkForCountdownEnd_HANDLER )
	self:createNametag()
end

function GhostPlayback:createNametag()
	self.nametagInfo = {
		name = "Ghost (" .. globalInfo.racer .. ")",
		time = msToTimeStr( globalInfo.bestTime )
	}
	self.drawGhostNametag_HANDLER = function() self:drawGhostNametag( self.nametagInfo ) end
	addEventHandler( "onClientRender", g_Root, self.drawGhostNametag_HANDLER )
end

function GhostPlayback:destroyNametag()
	if self.drawGhostNametag_HANDLER then removeEventHandler( "onClientRender", g_Root, self.drawGhostNametag_HANDLER ) self.drawGhostNametag_HANDLER = nil end
end

function GhostPlayback:checkForCountdownEnd()
	local vehicle = getPedOccupiedVehicle( getLocalPlayer() )
	if vehicle then
		local frozen = isVehicleFrozen( vehicle )
		if not frozen then
			outputDebug( "Playback started." )
			setVehicleFrozen( self.vehicle, false )
			if self.checkForCountdownEnd_HANDLER then removeEventHandler( "onClientRender", g_Root, self.checkForCountdownEnd_HANDLER ) self.checkForCountdownEnd_HANDLER = nil end
			self:startPlayback()
		end
	end
end

function GhostPlayback:startPlayback()
	self.startTick = getTickCount()
	self.isPlaying = true
	self.updateGhostState_HANDLER = function() self:updateGhostState() end
	addEventHandler( "onClientRender", g_Root, self.updateGhostState_HANDLER )
end

function GhostPlayback:stopPlayback( finished )
	self:destroyNametag()
	self:resetKeyStates()
	self.isPlaying = false
	if self.updateGhostState_HANDLER then removeEventHandler( "onClientRender", g_Root, self.updateGhostState_HANDLER ) self.updateGhostState_HANDLER = nil end
	if finished then
		self.ghostFinishTimer = setTimer(
			function()
				local blip = getBlipAttachedTo( self.ped )
				if blip then
					setBlipColor( blip, 0, 0, 0, 0 )
				end
				setElementPosition( self.vehicle, 0, 0, 0 )
				setVehicleFrozen( self.vehicle, true )
				setElementAlpha( self.vehicle, 0 )
				setElementAlpha( self.ped, 0 )
			end, 5000, 1
		)
	end
end

function GhostPlayback:updateGhostState()
	self.currentIndex = self.currentIndex or 1
	local ticks = getTickCount() - self.startTick
	setElementHealth( self.ped, 100 ) -- we don't want the ped to die
	while (self.recording[self.currentIndex] and self.recording[self.currentIndex].t < ticks) do
		local theType = self.recording[self.currentIndex].ty
		if theType == "st" then
			-- Skip
		elseif theType == "po" then
			local x, y, z = self.recording[self.currentIndex].x, self.recording[self.currentIndex].y, self.recording[self.currentIndex].z
			local rX, rY, rZ = self.recording[self.currentIndex].rX, self.recording[self.currentIndex].rY, self.recording[self.currentIndex].rZ
			local vX, vY, vZ = self.recording[self.currentIndex].vX, self.recording[self.currentIndex].vY, self.recording[self.currentIndex].vZ
			local lg = self.recording[self.currentIndex].lg
			local health = self.recording[self.currentIndex].h or 1000
			setElementPosition( self.vehicle, x, y, z )
			setElementRotation( self.vehicle, rX, rY, rZ )
			setElementVelocity( self.vehicle, vX, vY, vZ )
			setElementHealth( self.vehicle, health )
			if lg then setVehicleLandingGearDown( self.vehicle, lg ) end
		elseif theType == "k" then
			local control = self.recording[self.currentIndex].k
			local state = self.recording[self.currentIndex].s
			setPedControlState( self.ped, control, state )
		elseif theType == "pi" then
			local item = self.recording[self.currentIndex].i
			if item == "n" then
				addVehicleUpgrade( self.vehicle, 1010 )
			elseif item == "r" then
				fixVehicle( self.vehicle )
			end
		elseif theType == "sp" then
			fixVehicle( self.vehicle )
		elseif theType == "v" then
			local vehicleType = self.recording[self.currentIndex].m
			setElementModel( self.vehicle, vehicleType )
		end
		self.currentIndex = self.currentIndex + 1
		
		if not self.recording[self.currentIndex] then
			self:stopPlayback( true )
		end
	end
end

function GhostPlayback:resetKeyStates()
	if isElement( self.ped ) then
		for _, v in ipairs( keyNames ) do
			setPedControlState( self.ped, v, false )
		end
	end
end

addEventHandler( "onClientGhostDataReceive", g_Root,
	function( recording, bestTime, racer, ped, vehicle )
		if playback then
			playback:destroy()
		end
		
		globalInfo.bestTime = bestTime
		globalInfo.racer = racer
		
		playback = GhostPlayback:create( recording, ped, vehicle )
		playback:preparePlayback()
	end
)

addEventHandler( "clearMapGhost", g_Root,
	function()
		if playback then
			playback:destroy()
			globalInfo.bestTime = math.huge
			globalInfo.racer = ""
		end
	end
)

function getBlipAttachedTo( elem )
	local elements = getAttachedElements( elem )
	for _, element in ipairs( elements ) do
		if getElementType( element ) == "blip" then
			return element
		end
	end
	return false
end