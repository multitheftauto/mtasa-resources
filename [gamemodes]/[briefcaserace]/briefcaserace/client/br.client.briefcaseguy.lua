local root = getRootElement()
local inVehicle = false -- safer to use a flag instead of checking isPedInVehicle(), cause sometimes the effects might not get removed when removeVehicle is called (client reports that isPedInVehicle() is false, but for some reason the effects have not yet been removed)

function addVehicleEffects()
	addEventHandler("onClientPlayerVehicleEnter", localPlayer, onEnter)
	addEventHandler("onClientPlayerVehicleExit", localPlayer, onExit)
	-- add effects if in vehicle
	if (isPedInVehicle(localPlayer)) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		--showVolatilityMeter()
		enableVehicleSlowing(vehicle)
		addVehicleWeaponDamageEvent(vehicle)
		inVehicle = true
	end
end

function removeVehicleEffects()
	removeEventHandler("onClientPlayerVehicleEnter", localPlayer, onEnter)
	removeEventHandler("onClientPlayerVehicleExit", localPlayer, onExit)
	-- remove effects if in vehicle
	if (inVehicle) then
		--hideVolatilityMeter()
		disableVehicleSlowing()
		removeVehicleWeaponDamageEvent()
		inVehicle = false
	end
end

function onEnter(vehicle, seat)
	--showVolatilityMeter()
	enableVehicleSlowing(vehicle)
	addVehicleWeaponDamageEvent(vehicle)
	inVehicle = true
end

function onExit(vehicle, seat)
	--hideVolatilityMeter()
	disableVehicleSlowing()
	removeVehicleWeaponDamageEvent()
	inVehicle = false
end
