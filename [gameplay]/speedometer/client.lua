local screenW, screenH = guiGetScreenSize()
local base_color = tocolor(255, 255, 255, 235)
local baseW, baseH = 1920, 1080

local function dxDrawRelativeImage(startX, startY, width, height, image, rot, rotX, rotY, color, postGUI)
    local scale = math.min(screenW / baseW, screenH / baseH)
    local scaledW = width * scale
    local scaledH = height * scale

    dxDrawImage(screenW * startX, screenH * startY, scaledW, scaledH, image, rot or 0, rotX or 0, rotY or 0, color or base_color, postGUI or false)
end

function dxDrawRelText(text, relX, relY, relWidth, relHeight, color, scaleXY, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY, fLineSpacing)
    local scale = math.min(screenW / baseW, screenH / baseH)
    local absX = screenW * relX
    local absY = screenH * relY
    local absRight = screenW * (relX + relWidth)
    local absBottom = screenH * (relY + relHeight)
    
    
    local scaledScale = scaleXY * scale

    dxDrawText(
        text,
        absX, absY,
        absRight, absBottom,
        color or tocolor(255, 255, 255, 255),
        scaledScale, scaledScale,  -- scaleX, scaleY
        font or "default",
        alignX or "left",
        alignY or "top",
        clip or false,
        wordBreak or false,
        postGUI or false,
        colorCoded or false,
        subPixelPositioning or false,
        fRotation or 0,
        fRotationCenterX or 0,
        fRotationCenterY or 0,
        fLineSpacing or 0
    )
end

function drawSpeedo()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local velx, vely, velz = getElementVelocity(veh)
    local speed = (velx ^ 2 + vely ^ 2 + velz ^ 2) ^ (0.5)

    dxDrawRelativeImage(0.82, 0.65, 300, 300, "images/disc.png")
    local kmh = math.floor( getElementSpeed(veh, 'km/h') ) --mph
    dxDrawRelText(kmh, 0.65, 0.71, 0.5, 0.1, tocolor(255, 255, 255), 1.5, "default-bold", "center", "center")

    if getVehicleOverrideLights( veh ) == 2 then
        dxDrawRelativeImage(0.88, 0.85, 40, 40, "images/lights_1.png", 0, 0, 0, tocolor(255, 255, 255, 255))
	elseif getVehicleOverrideLights( veh ) == 1 then
        dxDrawRelativeImage(0.88, 0.85, 40, 40, "images/lights_0.png", 0, 0, 0, tocolor(255, 255, 255, 255))
	else
		local h,m = getTime()
		if h >= 6 and h <= 21 then
            dxDrawRelativeImage(0.88, 0.85, 40, 40, "images/lights_0.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		else
            dxDrawRelativeImage(0.88, 0.85, 40, 40, "images/lights_1.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		end
	end

    dxDrawRelativeImage(0.82, 0.65, 300, 300, "images/needle.png", -145-(1.5-(speed/1.5) * 305))
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