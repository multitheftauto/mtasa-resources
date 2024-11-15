-- Remote events:
addEvent("voice_cl:onClientPlayerVoiceStart", true)
addEvent("voice_cl:onClientPlayerVoiceStop", true)
addEvent("voice_local:updateSettings", true)

local MAX_VOICE_DISTANCE = 25

local streamedPlayers = {}

local sx, sy = guiGetScreenSize()

local nx, ny = sx / 1920, sy / 1080
local width = 108 * nx
local height = 180 * ny
local halfWidth = width / 2
local halfHeight = height / 2
local icon = dxCreateTexture("icon.png", "dxt5", true, "clamp")

local localPlayerTalking = false

local function preRender()
    local cx, cy, cz = getCameraMatrix()
    for player, talking in pairs(streamedPlayers) do
        local px, py, pz = getElementPosition(player)
        local distanceToPlayer = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz)

        local playerVolume
        if (distanceToPlayer <= 0) then
            playerVolume = 1.0
        elseif (distanceToPlayer >= MAX_VOICE_DISTANCE) then
            playerVolume = 0.0
        else
            playerVolume = (1.0 - (distanceToPlayer / MAX_VOICE_DISTANCE)^2)
        end
        setSoundVolume(player, playerVolume)

        if talking and settings.playersTalkingIcon.value and isLineOfSightClear(cx, cy, cz, px, py, pz, false, false, false, false, true, true, true, localPlayer) then
            local boneX, boneY, boneZ = getPedBonePosition(player, 8)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.5)
            if screenX and screenY and fDistance < MAX_VOICE_DISTANCE then
                fDistance = 1 / fDistance
                dxDrawImage(screenX - halfWidth * fDistance, screenY - halfHeight * fDistance, width * fDistance, height * fDistance, icon, 0, 0, 0, -1, false)
            end
        end
    end
    if settings.ownTalkingTextEnabled.value then
        if localPlayerTalking then
            dxDrawText("Voice: ON", 5, sy - 20, sx, sy, 0xff00ff00, 1, "default-bold", "left", "center")
        else
            dxDrawText("Voice: OFF", 5, sy - 20, sx, sy, 0x44ffffff, 1, "default-bold", "left", "center")
        end
    end
end
addEventHandler("onClientPreRender", root, preRender)

local function onStart()
    local x, y, z = getElementPosition(localPlayer)
    for _, player in ipairs(getElementsWithinRange(x, y, z, 250, "player")) do
        if player ~= localPlayer and streamedPlayers[player] == nil then
            setSoundVolume(source, 0)
            streamedPlayers[player] = false
        end
    end
    triggerServerEvent("voice:setPlayerBroadcast", resourceRoot, streamedPlayers)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart, false)

-- Handle remote/other player join
local function playerJoin()
    if getElementType(source) == "player" then
        if streamedPlayers[source] == nil then
            setSoundVolume(source, 0)
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, source)
        end
    end
end
addEventHandler("onClientPlayerJoin", root, playerJoin)

-- Handle remote/other player quit
local function playerQuit()
    if streamedPlayers[source] ~= nil then
        streamedPlayers[source] = nil
        triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, source)
    end
end
addEventHandler("onClientPlayerQuit", root, playerQuit)

-- Code considers this event's problem @ "Note" box: https://wiki.multitheftauto.com/wiki/OnClientElementStreamIn
-- It should be modified if said behavior ever changes
-- Stream in event
local function streamIn()
    if (isElement(source) and getElementType(source) == "player" and isPedDead(source) == false) then
        if streamedPlayers[source] == nil then
            setSoundVolume(source, 0)
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, source)
            print("streaming in", getPlayerName(source))
        end
    end
end
addEventHandler("onClientElementStreamIn", root, streamIn)

-- Stream out event
local function streamOut()
    if (source ~= localPlayer and isElement(source) and getElementType(source) == "player") then
        if streamedPlayers[source] ~= nil then
            setSoundVolume(source, 0)
            streamedPlayers[source] = nil
            triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, source)
            print("streaming out", getPlayerName(source))
        end
    end
end
addEventHandler("onClientElementStreamOut", root, streamOut)

local function voiceStart(source)
    if (isElement(source) and getElementType(source) == "player") then
        if source == localPlayer then
            localPlayerTalking = true
        elseif streamedPlayers[source] ~= nil then
            streamedPlayers[source] = true
        end
    end
end
addEventHandler("voice_cl:onClientPlayerVoiceStart", resourceRoot, voiceStart)

local function voiceStop(source)
    if (isElement(source) and getElementType(source) == "player") then
        if source == localPlayer then
            localPlayerTalking = false
        elseif streamedPlayers[source] ~= nil then
            streamedPlayers[source] = false
        end
    end
end
addEventHandler("voice_cl:onClientPlayerVoiceStop", resourceRoot, voiceStop)

addEventHandler("voice_local:updateSettings", resourceRoot, function(settingsFromServer)
    settings = settingsFromServer
end, false)
