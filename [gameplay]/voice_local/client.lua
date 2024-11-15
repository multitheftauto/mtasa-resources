-- Remote events:
addEvent("voice_cl:onClientPlayerVoiceStart", true)
addEvent("voice_cl:onClientPlayerVoiceStop", true)
addEvent("voice_local:updateSettings", true)

local MAX_VOICE_DISTANCE = 25

local streamedPlayers = {}

local mathexp = math.exp
local sx, sy = guiGetScreenSize()

local nx, ny = sx / 1920, sy / 1080
local width = 108 * nx
local height = 180 * ny
local halfWidth = width / 2
local halfHeight = height / 2
local icon = dxCreateTexture("icon.png", "dxt5", true, "clamp")

local function preRender()
    local x, y, z = getCameraMatrix()
    for player, talking in pairs(streamedPlayers) do
        if player and isElement(player) and getElementType(player) == "player" then
            local x1, y1, z1 = getElementPosition(player)
            local fDistance = getDistanceBetweenPoints3D(x, y, z, x1, y1, z1)

            local fVolume
            if (fDistance <= 0) then
                fVolume = 100
            elseif (fDistance >= MAX_VOICE_DISTANCE) then
                fVolume = 0.0
            else
                fVolume = (mathexp((fDistance) * (3.0 / fDistance)) * 100) * 3
            end
            setSoundVolume(player, fVolume / 100)

            local lineOfSightClear = isLineOfSightClear(x, y, z, x1, y1, z1, false, false, false, false, true, true, true, localPlayer)
            if lineOfSightClear then
                setSoundEffectEnabled(player, "compressor", false)

                if talking and settings.playersTalkingIcon.value then
                    local boneX, boneY, boneZ = getPedBonePosition(player, 8)
                    local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.5)
                    if screenX and screenY and fDistance < MAX_VOICE_DISTANCE then
                        fDistance = 1 / fDistance
                        dxDrawImage(screenX - halfWidth * fDistance, screenY - halfHeight * fDistance, width * fDistance, height * fDistance, icon, 0, 0, 0, -1, false)
                    end
                end
            else
                setSoundEffectEnabled(player, "compressor", true)
            end
        end
    end
    if settings.ownTalkingTextEnabled.value then
        if streamedPlayers[localPlayer] == true then
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
        if streamedPlayers[player] == nil then
            streamedPlayers[player] = false
        end
    end
    triggerServerEvent("voice:setPlayerBroadcast", resourceRoot, streamedPlayers)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart, false)

local function playerJoin()
    if getElementType(source) == "player" then
        if streamedPlayers[source] == nil then
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, source)
        end
    end
end
addEventHandler("onClientPlayerJoin", root, playerJoin)

local function playerQuit()
    if streamedPlayers[source] ~= nil then
        streamedPlayers[source] = nil
        setSoundVolume(source, 0)
        triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, source)
    end
end
addEventHandler("onClientPlayerQuit", root, playerQuit)

-- Code considers this event's problem @ "Note" box: https://wiki.multitheftauto.com/wiki/OnClientElementStreamIn
-- It should be modified if said behavior ever changes
local function streamIn()
    if (isElement(source) and getElementType(source) == "player" and isPedDead(source) == false) then
        if streamedPlayers[source] == nil then
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, source)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, streamIn)

-- To ensure table integrity, stream out & local player death into 2 separate, safer events
-- See the "Note" box at https://wiki.multitheftauto.com/wiki/OnClientElementStreamIn for reason why
-- Stream out event
local function streamOut()
    if (source ~= localPlayer and isElement(source) and getElementType(source) == "player") then
        if streamedPlayers[source] ~= nil then
            streamedPlayers[source] = nil
            setSoundVolume(source, 0)
            triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, source)
        end
    end
end
addEventHandler("onClientElementStreamOut", root, streamOut)

-- Local player death event
local function onWasted()
    if streamedPlayers[localPlayer] ~= nil then
        streamedPlayers[localPlayer] = nil
        setSoundVolume(localPlayer, 0)
        triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, localPlayer)
    end
end
addEventHandler("onClientPlayerWasted", localPlayer, onWasted)

local function voiceStart(source)
    if (isElement(source) and getElementType(source) == "player") then
        if streamedPlayers[source] ~= nil then
            streamedPlayers[source] = true
        end
    end
end
addEventHandler("voice_cl:onClientPlayerVoiceStart", resourceRoot, voiceStart)

local function voiceStop(source)
    if (isElement(source) and getElementType(source) == "player") then
        if streamedPlayers[source] ~= nil then
            streamedPlayers[source] = false
        end
    end
end
addEventHandler("voice_cl:onClientPlayerVoiceStop", resourceRoot, voiceStop)

addEventHandler("voice_local:updateSettings", resourceRoot, function(settingsFromServer)
    settings = settingsFromServer
end, false)
