-- #######################################
-- ## Project: Superman					##
-- ## Authors: MTA contributors			##
-- ## Version: 3.0						##
-- #######################################

function supermanCancelAirKill()
	local supermanFlying = getSupermanData(source, SUPERMAN_FLY_DATA_KEY)
	local supermanTakingOff = getSupermanData(source, SUPERMAN_TAKE_OFF_DATA_KEY)

	if (not supermanFlying and not supermanTakingOff) then
		return false
	end

	cancelEvent()
end
addEventHandler("onPlayerStealthKill", root, supermanCancelAirKill)

-- Fix for players glitching other players' vehicles by warping into them while superman is active, causing them to flinch into air and get stuck.

function supermanEnterVehicle()
	local supermanFlying = getSupermanData(source, SUPERMAN_FLY_DATA_KEY)
	local supermanTakingOff = getSupermanData(source, SUPERMAN_TAKE_OFF_DATA_KEY)

	if (not supermanFlying and not supermanTakingOff) then
		return false
	end

	removePedFromVehicle(source)

	local playerX, playerY, playerZ = getElementPosition(source)

	setElementPosition(source, playerX, playerY, playerZ)
end
addEventHandler("onPlayerVehicleEnter", root, supermanEnterVehicle)