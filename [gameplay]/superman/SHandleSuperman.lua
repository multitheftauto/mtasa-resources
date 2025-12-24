local function onPlayerStealthKillSuperman()
	local supermanFlying = getSupermanData(source, SUPERMAN_FLY_DATA_KEY)
	local supermanTakingOff = getSupermanData(source, SUPERMAN_TAKE_OFF_DATA_KEY)

	if (not supermanFlying and not supermanTakingOff) then
		return false
	end

	cancelEvent()
end
addEventHandler("onPlayerStealthKill", root, onPlayerStealthKillSuperman)

-- fix for players glitching other players' vehicles by warping into them while superman is active, causing them to flinch into air and get stuck.

local function onPlayerVehicleEnterSuperman()
	local supermanFlying = getSupermanData(source, SUPERMAN_FLY_DATA_KEY)
	local supermanTakingOff = getSupermanData(source, SUPERMAN_TAKE_OFF_DATA_KEY)

	if (not supermanFlying and not supermanTakingOff) then
		return false
	end

	removePedFromVehicle(source)

	local playerX, playerY, playerZ = getElementPosition(source)

	setElementPosition(source, playerX, playerY, playerZ)
end
addEventHandler("onPlayerVehicleEnter", root, onPlayerVehicleEnterSuperman)

-- sanity data set when player dies (prevents player being stuck if death occurs somehow)

local function onPlayerWastedResetSuperman()
	local dataKeys = {SUPERMAN_FLY_DATA_KEY, SUPERMAN_TAKE_OFF_DATA_KEY}

	for dataID = 1, #dataKeys do
		local dataKey = dataKeys[dataID]
		local dataSet = getSupermanData(source, dataKey)

		if (dataSet) then
			setSupermanData(source, dataKey, false)
		end
	end
end
addEventHandler("onPlayerWasted", root, onPlayerWastedResetSuperman)