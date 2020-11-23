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
		disableCollision = true,
		lastData = {},
	}
	setElementCollisionsEnabled( result.ped, false )
	setElementCollisionsEnabled( result.vehicle, false )
	setElementFrozen( result.vehicle, true )
	setElementAlpha( result.ped, g_GameOptions.alphavalue )
	setElementAlpha( result.vehicle, g_GameOptions.alphavalue )
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
		local frozen = isElementFrozen( vehicle )
		if not frozen then
			outputDebug( "Playback started." )
			setElementFrozen( self.vehicle, false )
			if self.checkForCountdownEnd_HANDLER then removeEventHandler( "onClientRender", g_Root, self.checkForCountdownEnd_HANDLER ) self.checkForCountdownEnd_HANDLER = nil end
			self:startPlayback()
			setElementAlpha( self.vehicle, g_GameOptions.alphavalue )
			setElementAlpha( self.ped, g_GameOptions.alphavalue )
		end

        -- If at the start and ghost is very close to a player vehicle, make it invisible
		if frozen and not self.isPlaying then
			local x, y, z = getElementPosition(self.vehicle)
			for _,player in ipairs(getElementsByType('player')) do
				local plrveh = getPedOccupiedVehicle( player )
				if plrveh then
					local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(plrveh))
					if dist < 0.1 then
						setElementAlpha( self.vehicle, 0 )
						setElementAlpha( self.ped, 0 )
						break
					end
				end
			end
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
				setElementFrozen( self.vehicle, true )
				setElementAlpha( self.vehicle, 0 )
				setElementAlpha( self.ped, 0 )
			end, 5000, 1
		)
	end
end

function GhostPlayback:getNextIndexOfType( reqType, start, dir )
	local idx = start
	while (self.recording[idx] and self.recording[idx].ty ~= reqType ) do
		idx = idx + dir
	end
	return self.recording[idx] and idx
end

function GhostPlayback:updateGhostState()
	if not self.currentIndex then
		Interpolator.Reset()
	end
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
			-- Interpolate with next position depending on current time
			local idx = self:getNextIndexOfType( "po", self.currentIndex + 1, 1 )
			local period = nil
			if idx then
				local other = self.recording[idx]
				local alpha = math.unlerp( self.recording[self.currentIndex].t, other.t, ticks )
				period = other.t - ticks
				x = math.lerp( x, other.x, alpha )
				y = math.lerp( y, other.y, alpha )
				z = math.lerp( z, other.z, alpha )
				vX = math.lerp( vX, other.vX, alpha )
				vY = math.lerp( vY, other.vY, alpha )
				vZ = math.lerp( vZ, other.vZ, alpha )
				Interpolator.SetPoints( self.recording[self.currentIndex], other )
			else
				Interpolator.Reset()
			end
			local lg = self.recording[self.currentIndex].lg
			local health = self.recording[self.currentIndex].h or 1000
			if self.disableCollision then
				health = 1000
				self.lastData.vZ = vZ
				self.lastData.time = getTickCount()
			end
			ErrorCompensator.handleNewPosition( self.vehicle, x, y, z, period )
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
			-- Respawn clears the control states
			for _, v in ipairs( keyNames ) do
				setPedControlState( self.ped, v, false )
			end
		elseif theType == "v" then
			local vehicleType = self.recording[self.currentIndex].m
			setElementModel( self.vehicle, vehicleType )
		end
		self.currentIndex = self.currentIndex + 1

		if not self.recording[self.currentIndex] then
			self:stopPlayback( true )
			self.fadeoutStart = getTickCount()
		end
	end
	ErrorCompensator.updatePosition( self.vehicle )
	Interpolator.Update( ticks, self.vehicle )
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


--------------------------------------------------------------------------
--Interpolator
--------------------------------------------------------------------------
Interpolator = {}
last = {}

function Interpolator.Reset()
	last.from = nil
	last.to = nil
end

function Interpolator.SetPoints( from, to )
	last.from = from
	last.to = to
end

function Interpolator.Update( ticks, vehicle )
	if not last.from or not last.to then return end
	local x,y,z,rX,rY,rZ
	local alpha = math.unlerp( last.from.t, last.to.t, ticks )
	x = math.lerp( last.from.x, last.to.x, alpha )
	y = math.lerp( last.from.y, last.to.y, alpha )
	z = math.lerp( last.from.z, last.to.z, alpha )
	rX = math.lerprot( last.from.rX, last.to.rX, alpha )
	rY = math.lerprot( last.from.rY, last.to.rY, alpha )
	rZ = math.lerprot( last.from.rZ, last.to.rZ, alpha )
	local ox,oy,oz = getElementPosition( vehicle )
	setElementPosition( vehicle, ox, oy, math.max( oz, z ) )
	setElementRotation( vehicle, rX, rY, rZ )
end

--------------------------------------------------------------------------
-- Error Compensator
--------------------------------------------------------------------------
ErrorCompensator = {}
error = { timeEnd = 0 }

function ErrorCompensator.handleNewPosition( vehicle, x, y, z, period )
	local vx, vy, vz = getElementPosition( vehicle )
	-- Check if the distance to interpolate is too far.
	local dist = getDistanceBetweenPoints3D( x, y, z, vx, vy, vz )
	if dist > 5 or not period then
		-- Just do move if too far to interpolate or period is not valid
		setElementPosition( vehicle, x, y, z )
		error.x = 0
		error.y = 0
		error.z = 0
		error.timeStart = 0
		error.timeEnd = 0
		error.fLastAlpha = 0
	else
		-- Set error correction to apply over the next few frames
		error.x = x - vx
		error.y = y - vy
		error.z = z - vz
		error.timeStart = getTickCount()
		error.timeEnd = error.timeStart + period * 1.0
		error.fLastAlpha = 0
	end
end


-- Apply a portion of the error
function ErrorCompensator.updatePosition( vehicle )
	if error.timeEnd == 0 then return end

	-- Grab the current game position
	local vx, vy, vz = getElementPosition( vehicle )

	-- Get the factor of time spent from the interpolation start to the current time.
	local fAlpha = math.unlerp ( error.timeStart, error.timeEnd, getTickCount() )

	-- Don't let it overcompensate the error too much
	fAlpha = math.clamp ( 0.0, fAlpha, 1.5 )

	if fAlpha == 1.5 then
		error.timeEnd = 0
		return
	end

	-- Get the current error portion to compensate
	local fCurrentAlpha = fAlpha - error.fLastAlpha
	error.fLastAlpha = fAlpha

	-- Apply
	local nx = vx + error.x * fCurrentAlpha
	local ny = vy + error.y * fCurrentAlpha
	local nz = vz + error.z * fCurrentAlpha
	setElementPosition( vehicle, nx, ny, nz )
end


--------------------------------------------------------------------------
-- Update admin changing options
--------------------------------------------------------------------------
function GhostPlayback:onUpdateOptions()
	if isElement( self.vehicle ) and isElement( self.ped ) then
		setElementAlpha( self.vehicle, g_GameOptions.alphavalue )
		setElementAlpha( self.ped, g_GameOptions.alphavalue )
	end
end


--------------------------------------------------------------------------
-- Fade out ghost at end of race
--------------------------------------------------------------------------
addEventHandler('onClientPreRender', root,
	function()
		if playback and playback.fadeoutStart and isElement( playback.vehicle ) and isElement( playback.ped ) then
			playback:updateFadeout()
		end
	end
)

function GhostPlayback:updateFadeout()
	local alpha = math.unlerp( self.fadeoutStart+2000, self.fadeoutStart+500, getTickCount() )
	if alpha > -1 and alpha < 1 then
		alpha = math.clamp( 0, alpha, 1 )
		setElementAlpha( self.vehicle, alpha * g_GameOptions.alphavalue )
		setElementAlpha( self.ped, alpha * g_GameOptions.alphavalue )
	end
end


--------------------------------------------------------------------------
-- Counter side effects of having collisions disabled
--------------------------------------------------------------------------
addEventHandler('onClientPreRender', root,
	function()
		if playback and playback.disableCollision and isElement( playback.vehicle ) and isElement( playback.ped ) then
			playback:disabledCollisionTick()
		end
	end
)


local dampCurve = { { 0, 1 }, { 200, 1 }, { 15000, 0 } }

function GhostPlayback:disabledCollisionTick()
	setVehicleDamageProof( self.vehicle, true ) -- we don't want the vehicle to explode
	setElementCollisionsEnabled( self.ped, false )
	setElementCollisionsEnabled( self.vehicle, false  )

	-- Slow down everything when its been more than 200ms since the last position change
	local timeSincePos = getTickCount() - ( self.lastData.time or 0 )
	local damp = math.evalCurve( dampCurve, timeSincePos )

	-- Stop air floating
	local vx, vy, vz = getElementVelocity ( self.vehicle )
	if vz < -0.01 then
		damp = 1	-- Always allow falling
		self.lastData.time = getTickCount()
	end
	vz = self.lastData.vZ or vz
	vx = vx * 0.999 * damp
	vy = vy * 0.999 * damp
	vz = vz * damp
	if vz > 0 then
		vz = vz * 0.999
	end
	if vz > 0 and getDistanceBetweenPoints2D(0, 0, vx, vy) < 0.001 then
		vz = 0
	end
	if self.lastData.vZ then
		self.lastData.vZ = vz
	end
	setElementVelocity( self.vehicle, vx, vy, vz  )

	-- Stop crazy spinning
	local vehicle = self.vehicle
	local ax, ay, az = getElementAngularVelocity ( self.vehicle )
	local angvel = getDistanceBetweenPoints3D(0, 0, 0, ax, ay, az )
	if angvel > 0.1 then
		ax = ax / 2
		ay = ay / 2
		az = az / 2
		setElementAngularVelocity( self.vehicle, ax, ay, az )
	end
end

