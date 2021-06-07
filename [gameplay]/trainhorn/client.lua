local spam = 0

function initBind(theVehicle)
	if (getVehicleType(theVehicle) == "Train") then
		bindKey("horn", "down", soundHorn)
	end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, initBind)

function soundHorn()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	-- Make it so they can't play multiple train horns at the same time (causes lag and distortion)
	if (vehicle and getVehicleType(vehicle) == "Train" and getVehicleController(vehicle) == localPlayer and getTickCount() - spam >= 5000) then
		spam = getTickCount()
		triggerServerEvent("onSyncHorn", localPlayer)
		local x, y, z = getElementPosition(vehicle)
		local sound = playSound3D("horn.aac", x, y, z, false)
		attachElements(sound, vehicle)
		setSoundMaxDistance(sound, 250)
	end
end

function syncedHorn(train, x, y, z)
	if (isElement(train) and getVehicleType(train) == "Train" and source ~= localPlayer) then
		local sound = playSound3D("horn.aac", x, y, z, false)
		attachElements(sound, train)
		setSoundMaxDistance(sound, 250)
	end
end
addEvent("onPlaySyncedHorn", true)
addEventHandler("onPlaySyncedHorn", root, syncedHorn)

function cleanUp(theVehicle)
	if (getVehicleType(theVehicle) == "Train") then
		unbindKey("horn", "down", soundHorn)
	end
end
addEventHandler("onClientPlayerVehicleExit", localPlayer, cleanUp)

-- Dying in train, so not triggering onClientPlayerVehicleExit
function integrityCheck()
	local vehicle = getPedOccupiedVehicle(localPlayer)

	if (vehicle and getVehicleType(vehicle) == "Train") then
		unbindKey("horn", "down", soundHorn)
	end
end
addEventHandler("onClientPlayerWasted", localPlayer, integrityCheck)
