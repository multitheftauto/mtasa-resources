local root = getRootElement()

MAX_SPEED = 0.65

local element = false

local intervalLength = 200 -- milliseconds
local pauseTime = 120

local intervalTickStart = 0

local pausing = false
local lastFrameTick -- we need to know the time elapsed since the last frame to calculate the change in velocity due to gravity
--local lastFrameSpeed = 0 -- used to comapre the current speed to last speed to check big drops, and thus detect collisions

local lastVelX, lastVelY, lastVelZ = 0, 0, 0

function onFrameSlowVehicle()
	if (element and isElement(element)) then

		local velX, velY, velZ = getElementVelocity(element)

		local intervalTimeElapsed = getTickCount() - intervalTickStart

		if (intervalTimeElapsed >= intervalLength) then
			-- reset and start pausing
			intervalTimeElapsed = 0
			intervalTickStart = getTickCount()
			lastFrameTick = intervalTickStart
			lastVelX, lastVelY, lastVelZ = velX, velY, velZ
			pausing = true
		end

		--[[local curSpeed = math.sqrt(velX^2 + velY^2 + velZ^2)
--outputChatBox(curSpeed)
		if (curSpeed > 0.1 and curSpeed*1.2 <= lastFrameSpeed) then
			outputChatBox("car slowed down by at least 1.2x since last frame!")
			pausing = false
		end
		lastFrameSpeed = curSpeed]]

		if (pausing) then
			if (intervalTimeElapsed >= pauseTime) then
				-- turn pausing off
				pausing = false
			else
				local curTick = getTickCount()
				-- pause code...
				if (not isVehicleOnGround(element)) then
					local gx, gy, gz = getVehicleGravity(element)
					lastVelZ = lastVelZ + gz * 9.8 * (1/30) * ((curTick-lastFrameTick)/1000)
				end
				setElementVelocity(element, lastVelX, lastVelY, lastVelZ)
				lastFrameTick = curTick
			end
		else
			-- limit speed if too fast

			if ( (velX^2 + velY^2) > MAX_SPEED^2 ) then

				-- get original angle
				local angle
				if ( velX > 0 ) then -- I or IV
					angle = math.atan ( velY / velX )
				elseif ( velX < 0 ) then -- II or III
					angle = math.pi + math.atan ( velY / velX )
				end

				-- get new X and Y velocity
				local newVX = MAX_SPEED * math.cos ( angle )
				local newVY = MAX_SPEED * math.sin ( angle )

				-- set new velocity
				setElementVelocity ( element, newVX, newVY, velZ )

			end

		end

	end
end


function enableVehicleSlowing(vehicle)
	assert(not element)
	element = vehicle
	addEventHandler("onClientRender", root, onFrameSlowVehicle)
end


function disableVehicleSlowing()
	removeEventHandler("onClientRender", root, onFrameSlowVehicle)
	element = false
end
