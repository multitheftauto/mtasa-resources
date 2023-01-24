local fMinDistance = 0
local fMaxDistance = 25
local mathexp = math.exp
local streamedPlayers = {}
local fDistDiff = fMinDistance - fMaxDistance

local sx, sy = guiGetScreenSize()
local nx, ny = sx / 1920, sy / 1080

local width = 108 * nx
local height = 180 * ny
local xOffset = 75 * nx
local yOffset = 50 * ny
local halfWidth = width / 2
local halfHeight = height / 2

local icon = dxCreateTexture("icon.png", "dxt5", true, "clamp")

function preRender()
    local x, y, z, lx, ly, lz = getCameraMatrix()

    for player, talking in pairs(streamedPlayers) do
        if player and isElement(player) and getElementType(player) == "player" then
            local x1, y1, z1 = getElementPosition(player)
            local fDistance = getDistanceBetweenPoints3D(x, y, z, x1, y1, z1)

            local fVolume
            if (fDistance <= fMinDistance) then
                fVolume = 100
            elseif (fDistance >= fMaxDistance) then
                fVolume = 0.0
            else
                fVolume = mathexp(-(fDistance - fMinDistance) * (5.0 / fDistDiff)) * 100
            end

            if isLineOfSightClear(x, y, z, x1, y1, z1, false, false, false, false, true, true, true, localPlayer) then
                setSoundVolume(player, fVolume)
                setSoundEffectEnabled(player, "compressor", false)
            else
                setSoundVolume(player, fVolume * 2)
                setSoundEffectEnabled(player, "compressor", true)
            end

            if talking and isLineOfSightClear(x, y, z, x1, y1, z1, false, false, false, false, true, true, true, localPlayer) then
                local boneX, boneY, boneZ = getPedBonePosition(player, 8)
                local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.5)
                if screenX and screenY and fDistance < fMaxDistance then
                    fDistance = 1 / fDistance
                    dxDrawImage(screenX - halfWidth * fDistance, screenY - halfHeight * fDistance, width * fDistance, height * fDistance, icon, 0, 0, 0, -1, false)
                end
            end
        end
    end
end
addEventHandler("onClientPreRender", root, preRender)

function onStart()
    local x, y, z = getElementPosition(localPlayer)
    for _, player in ipairs(getElementsWithinRange(x, y, z, 250, "player")) do
        if streamedPlayers[player] == nil then
            streamedPlayers[player] = false
        end
    end
    triggerServerEvent("voice:setPlayerBroadcast", resourceRoot, localPlayer, streamedPlayers)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart, false)

function playerJoin()
    if getElementType(source) == "player" then
        if streamedPlayers[source] == nil then
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, localPlayer, source)
        end
    end
end
addEventHandler("onClientPlayerJoin", root, playerJoin)

function playerQuit()
    if streamedPlayers[source] ~= nil then
        streamedPlayers[source] = nil
        setSoundVolume(source, 0)
        triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, localPlayer, source)
    end
end
addEventHandler("onClientPlayerQuit", root, playerQuit)

-- Code considers this event's problem @ "Note" box: https://wiki.multitheftauto.com/wiki/OnClientElementStreamIn
-- It should be modified if said behavior ever changes
function streamIn()
    if (isElement(source) and getElementType(source) == "player" and isPedDead(source) == false) then
        if streamedPlayers[source] == nil then
            streamedPlayers[source] = false
            triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, localPlayer, source)
        end
    end
end
addEventHandler("onClientElementStreamIn", root, streamIn)

-- To ensure table integrity, stream out & local player death into 2 separate, safer events
-- See the "Note" box at https://wiki.multitheftauto.com/wiki/OnClientElementStreamIn for reason why
-- Stream out event
function streamOut()
    if (source ~= localPlayer and isElement(source) and getElementType(source) == "player") then
        if streamedPlayers[source] ~= nil then
            streamedPlayers[source] = nil
            setSoundVolume(source, 0)
            triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, localPlayer, source)
        end
    end
end
addEventHandler("onClientElementStreamOut", root, streamOut)

-- Local player death event
function onWasted()
    if streamedPlayers[localPlayer] ~= nil then
        streamedPlayers[localPlayer] = nil
        setSoundVolume(localPlayer, 0)
        triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, localPlayer, localPlayer)
    end
end
addEventHandler("onClientPlayerWasted", localPlayer, onWasted)

function resourceStop()
    triggerServerEvent("voice:removePlayerBroadcasts", resourceRoot, localPlayer, streamedPlayers)
    streamedPlayers = {}
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStop, false)

function voiceStart(source)
    if (isElement(source) and getElementType(source) == "player") then
        if streamedPlayers[source] ~= nil then
            streamedPlayers[source] = true
        end
    end
end
addEvent("voice_cl:onClientPlayerVoiceStart", true)
addEventHandler("voice_cl:onClientPlayerVoiceStart", resourceRoot, voiceStart)

function voiceStop(source)
    if (isElement(source) and getElementType(source) == "player") then
        if streamedPlayers[source] ~= nil then
            streamedPlayers[source] = false
        end
    end
end
addEvent("voice_cl:onClientPlayerVoiceStop", true)
addEventHandler("voice_cl:onClientPlayerVoiceStop", resourceRoot, voiceStop)

function table.empty(a)
    if type(a) ~= "table" then
        return false
    end

    return next(a) == nil
end