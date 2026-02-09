local screenW, screenH = guiGetScreenSize()
local base_color = tocolor(255, 255, 255, 235)

local function dxDrawRelativeImage(startX, startY, width, height, image, rot, rotX, rotY, color, postGUI)
    dxDrawImage(screenW*startX, screenH*startY, width, height, image, rot or 0, rotX or 0, rotY or 0, color or base_color, postGUI or false)
end

function drawSpeedo()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local velx, vely, velz = getElementVelocity(veh)
    local speed = (velx ^ 2 + vely ^ 2 + velz ^ 2) ^ (0.5)

    dxDrawRelativeImage(0.82, 0.65, 300, 300, "images/disc.png")
    dxDrawRelativeImage(0.82, 0.65, 300, 300, "images/needle.png", -145-(1.5-(speed/1.5) * 305))
end

local isSpeedoShown = false
function toggleRender(bool)
    if bool then
        isSpeedoShown = true
        addEventHandler("onClientRender", root, drawSpeedo)
    else
        isSpeedoShown = false
        removeEventHandler("onClientRender", root, drawSpeedo)
    end
end

function toggleSpeedo()
    toggleRender(not isSpeedoShown)
end
addCommandHandler("speedo", toggleSpeedo)

local function enterHandler(theVehicle)
    local vehType = getVehicleType(theVehicle)
    if (vehType == "Plane") or (vehType == "Helicopter") then return end

    if not isSpeedoShown then
        toggleRender(true)
    end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, enterHandler)

local function exitHandler(theVehicle)
    local vehType = getVehicleType(theVehicle)
    if (vehType == "Plane") or (vehType == "Helicopter") then return end

    if isSpeedoShown then
        toggleRender(false)
    end
end
addEventHandler("onClientPlayerVehicleExit", localPlayer, exitHandler)

local function destroyHandler()
    if isSpeedoShown and (getElementType(source) == "vehicle") and (getPedOccupiedVehicle(localPlayer) == source) then
        toggleRender(false)
    end
end
addEventHandler("onClientVehicleExplode", root, destroyHandler)
addEventHandler("onClientElementDestroy", root, destroyHandler)

-- If player vehicle changes in abnormal way (e.g drives into a vehicle pick-up)
local function onVehicleTypeChange(oldModel, newModel)
    if (getPedOccupiedVehicle(localPlayer) ~= source) then return end

    local newType = getVehicleType(newModel)

    if isSpeedoShown and (newType == "Plane") or (newType == "Helicopter") then
        toggleRender(false)
    elseif not isSpeedoShown and (newType ~= "Plane") and (newType ~= "Helicopter") then
        toggleRender(true)
    end
end
addEventHandler("onClientElementModelChange", root, onVehicleTypeChange)

-- Dying in vehicle, so not triggering onClientPlayerVehicleExit
function integrityCheck()
    if getPedOccupiedVehicle(localPlayer) and isSpeedoShown then
        toggleRender(false)
    end
end
addEventHandler("onClientPlayerWasted", localPlayer, integrityCheck)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if isPedInVehicle(localPlayer) then
            enterHandler(getPedOccupiedVehicle(localPlayer))
        end
    end
)