local spam = {}

function initBind(thePlayer)
	if (thePlayer == localPlayer and getVehicleType(source) == "Train") then
		bindKey("H", "down", soundHorn)
	end
end
addEventHandler("onClientVehicleEnter", getRootElement(), initBind)

function soundHorn()
	local vehicle = getPedOccupiedVehicle(localPlayer)

	if getVehicleType(vehicle) ~= "Train" then return end

	-- Make it so they can't play multiple train horns at the same time (causes lag and distortion)
    if spam[localPlayer] and getTickCount() - spam[localPlayer] < 5000 then
        return
    end

	if (vehicle and getVehicleController(vehicle) == localPlayer) then
		spam[localPlayer] = getTickCount()
		x, y, z = getElementPosition(vehicle)
		triggerServerEvent("onSyncHorn", getRootElement(), localPlayer, vehicle)
		sound = playSound3D("horn.aac", x, y, z, false)
		setSoundVolume(sound, 1.0)
		attachElements(sound, vehicle)
		setSoundMaxDistance(sound, 250)
	end
end

function syncedHorn(train, x, y, z)
	if (isElement(train) and getVehicleType(train) == "Train") then
		sound = playSound3D("horn.aac", x, y, z, false)
		setSoundVolume(sound, 1.0)
		attachElements(sound, train)
		setSoundMaxDistance(sound, 250)
	end
end
addEvent("onPlaySyncedHorn", true)
addEventHandler("onPlaySyncedHorn", localPlayer, syncedHorn)

function cleanUp(thePlayer)
	if (thePlayer == localPlayer and getVehicleType(source) == "Train") then
		unbindKey("H", "down", soundHorn)
	end
end
addEventHandler("onClientVehicleExit", getRootElement(), cleanUp)

-- Dying in train, so not triggering onClientVehicleExit
function integrityCheck()
	local vehicle = getPedOccupiedVehicle(localPlayer)

	if (vehicle and getVehicleType(vehicle) == "Train") then
		unbindKey("H", "down", soundHorn)
	end
end
addEventHandler("onClientPlayerWasted", localPlayer, integrityCheck)