local screenW, screenH = guiGetScreenSize()
local base_color = tocolor(255, 255, 255, 235)
local baseW, baseH = 1920, 1080

function drawSpeedo()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local velx, vely, velz = getElementVelocity(veh)
    local speed = (velx ^ 2 + vely ^ 2 + velz ^ 2) ^ (0.5)

    local scale = math.min(screenW / baseW, screenH / baseH)
    local dialX, dialY = screenW * 0.82, screenH * 0.65
    local dialSize = 300 * scale

    dxDrawImage(dialX, dialY, dialSize, dialSize, "images/disc.png", 0, 0, 0, base_color)
    local kmh = math.floor(getElementSpeed(veh, "km/h"))
    dxDrawText(kmh, dialX, dialY + 65 * scale, dialX + dialSize, dialY + 173 * scale,
        tocolor(255, 255, 255), 1.5 * scale, "default-bold", "center", "center")

    local image = areVehicleLightsOn(veh) and "images/lights_1.png" or "images/lights_0.png"
    dxDrawImage(dialX + 130 * scale, dialY + 216 * scale, 40 * scale, 40 * scale, image, 0, 0, 0, base_color)

    dxDrawImage(dialX, dialY, dialSize, dialSize, "images/needle.png", -145-(1.5-(speed/1.5) * 305), 0, 0, base_color)
end

function getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
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