local screenW, screenH = guiGetScreenSize()

local rustler = false
local reloading = false
local lastShotTick = 0
local rounds = 10
local shotsFired = 0
local delayBetweenShots = 625
local delayBetweenReloads = 5000

function drawHud()
	if reloading then
		dxDrawText("Reloading...", screenW - 250, screenH - 100, _, _, tocolor(0, 255, 0), 2)
	else
		dxDrawText("Bombs: " .. tostring(rounds - shotsFired) .. "/" .. tostring(rounds), screenW - 250, screenH - 100, _, _, tocolor(0, 255, 0), 2)
	end
end

function dropGliderBomb()
	if not isElement(rustler) then
		return
	end
	local nowTick = getTickCount()

	if nowTick - lastShotTick < delayBetweenShots then
		return
	end

	local matrix = getElementMatrix(rustler)
	local _, forward, up, position = unpack(matrix)
	local x, y, z = unpack(position)

	if getVehicleLandingGearDown(rustler) then
		return
	end

	local uX, uY, uZ = unpack(up)
	local fX, fY, fZ = unpack(forward)
	local vX, vY, vZ = getElementVelocity(rustler)

	if reloading then
		playSoundFrontEnd(41)
		return
	end

	local projectile = createProjectile(rustler, 21, x - uX * 2, y - uY * 2, z - uZ * 2, 1, nil, 0, 0, 0, vX + fX * 0.01, vY + fY * 0.01, vZ + fZ * 0.01 - uZ * 0.1)

	if not projectile then
		return
	end

	setProjectileMatrix(projectile, Vector3(vX, vY, vZ))

	setElementCollisionsEnabled(projectile, false)
	playSoundFrontEnd(30)

	shotsFired = shotsFired + 1

	if shotsFired >= 10 then
		setTimer(function()
				reloading = false
				shotsFired = 0
			end, delayBetweenReloads, 1)
		reloading = true
	end

	lastShotTick = nowTick
end

function gliderBomb()
	dropGliderBomb()
end

function exitMode()
	unbindKey("vehicle_fire", "down", gliderBomb)
	removeEventHandler("onClientPlayerWasted", localPlayer, exitMode)

	if isElement(rustler) then
		removeEventHandler("onClientVehicleExit", rustler, exitMode)
		removeEventHandler("onClientElementModelChange", rustler, exitMode)
		removeEventHandler("onClientElementDestroy", rustler, exitMode)
		removeEventHandler("onClientVehicleExplode", rustler, exitMode)
	end

	removeEventHandler("onClientRender", root, drawHud)

	rustler = false
	reloading = false
	lastShotTick = 0
	rounds = 10
	shotsFired = 0
	delayBetweenShots = 625
	delayBetweenReloads = 5000
end
addEventHandler("onClientResourceStop", resourceRoot, exitMode)

function enterMode(vehicle)
	if not isElement(vehicle) or getElementModel(vehicle) ~= 476 then
		return
	end

	rustler = vehicle

	bindKey("vehicle_fire", "down", gliderBomb)
	addEventHandler("onClientPlayerWasted", localPlayer, exitMode)
	addEventHandler("onClientVehicleExit", vehicle, exitMode)
	addEventHandler("onClientElementModelChange", vehicle, exitMode)
	addEventHandler("onClientElementDestroy", vehicle, exitMode)
	addEventHandler("onClientVehicleExplode", vehicle, exitMode)
	addEventHandler("onClientRender", root, drawHud)
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, enterMode)

function checkStart()
	local vehicle = getPedOccupiedVehicle(localPlayer)

	if vehicle and getElementModel(vehicle) == 476 then
		enterMode(vehicle)
	end
end
addEventHandler("onClientResourceStart", resourceRoot, checkStart)

function setProjectileMatrix(p, forward)
    forward = -forward:getNormalized()
    forward = Vector3(-forward:getX(), -forward:getY(), forward:getZ())
    local up = Vector3(0, 0, 1)
    local left = forward:cross(up)

    local ux, uy, uz = left:getX(), left:getY(), left:getZ()
    local vx, vy, vz = forward:getX(), forward:getY(), forward:getZ()
    local wx, wy, wz = up:getX(), up:getY(), up:getZ()
    local x, y, z = getElementPosition(p)

    setElementMatrix(p, {{ux, uy, uz, 0}, {vx, vy, vz, 0}, {wx, wy, wz, 0}, {x, y, z, 1}})
    return true
end