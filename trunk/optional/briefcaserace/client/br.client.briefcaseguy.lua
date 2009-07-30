ALTERED_GRAVITY_MAGNITUDE = 0.6
ALTERED_GRAVITY_MAGNITUDE_2 = 0.475
MAX_CARRIER_SPEED = 0.6
local root = getRootElement()
local localPlayer = getLocalPlayer()

function addVehicleEffects()
	addEventHandler("onClientPlayerVehicleEnter", localPlayer, onEnter)
	addEventHandler("onClientPlayerVehicleExit", localPlayer, onExit)
	-- add effects if in vehicle
	if (isPedInVehicle(localPlayer)) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		showVolatilityMeter()
		addEventHandler("onClientRender", root, onFrameLimitVehicleSpeed)
		if (getVehicleType(vehicle) == "Bike") then -- make it harder for bikes, cause they have big advantages in other areas
			setVehicleGravity(vehicle, 0, 0, -1*ALTERED_GRAVITY_MAGNITUDE_2)
		else
			setVehicleGravity(vehicle, 0, 0, -1*ALTERED_GRAVITY_MAGNITUDE)
		end
	end
end

function removeVehicleEffects()
	removeEventHandler("onClientPlayerVehicleEnter", localPlayer, onEnter)
	removeEventHandler("onClientPlayerVehicleExit", localPlayer, onExit)
	-- remove effects if in vehicle
	if (isPedInVehicle(localPlayer)) then
		hideVolatilityMeter()
		removeEventHandler("onClientRender", root, onFrameLimitVehicleSpeed)
		setVehicleGravity(getPedOccupiedVehicle(localPlayer), 0, 0, -1)
	end
end

function onEnter(vehicle, seat)
	showVolatilityMeter()
	addEventHandler("onClientRender", root, onFrameLimitVehicleSpeed)
	if (getVehicleType(vehicle) == "Bike") then -- make it harder for bikes, cause they have big advantages in other areas
		setVehicleGravity(vehicle, 0, 0, -1*ALTERED_GRAVITY_MAGNITUDE_2)
	else
		setVehicleGravity(vehicle, 0, 0, -1*ALTERED_GRAVITY_MAGNITUDE)
	end
end

function onExit(vehicle, seat)
	hideVolatilityMeter()
	removeEventHandler("onClientRender", root, onFrameLimitVehicleSpeed)
	setVehicleGravity(vehicle, 0, 0, -1)
end

function onFrameLimitVehicleSpeed ()
	local inVehicle = isPedInVehicle ( localPlayer )
	if ( inVehicle ) then
		local curVehicle = getPedOccupiedVehicle(localPlayer)
		-- player is in vehicle, limit his speed if needed
		local origVX, origVY, origVZ = getElementVelocity ( curVehicle )
	    -- slow vehicle down if it's going over MAX_CARRIER_SPEED m/s
		if ( math.sqrt ( origVX^2 + origVY^2 ) > MAX_CARRIER_SPEED ) then
		
			-- get original angle
			local angle
			if ( origVX > 0 ) then -- I or IV
				angle = math.atan ( origVY / origVX )
			elseif ( origVX < 0 ) then -- II or III
				angle = math.pi + math.atan ( origVY / origVX )
			end

			-- get new X and Y velocity
			local newVX = MAX_CARRIER_SPEED * math.cos ( angle )
			local newVY = MAX_CARRIER_SPEED * math.sin ( angle )
			
			-- set new velocity
			setElementVelocity ( curVehicle, newVX, newVY, origVZ )
			
		end
	end
end
