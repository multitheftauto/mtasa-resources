-- Remote events:
addEvent("voice_local:onClientPlayerVoiceStart", true)
addEvent("voice_local:onClientPlayerVoiceStop", true)
addEvent("voice_local:updateSettings", true)

-- Only starts handling player voices after receiving the settings from the server
local initialWaiting = true

local streamedPlayers = {}
local localPlayerTalking = false

local sx, sy = guiGetScreenSize()

local devSX, devSY = sx / 1920, sy / 1080
local iconWidth = 108 * devSX
local iconHalfWidth = iconWidth / 2
local iconHeight = 180 * devSY
local iconHalfHeight = iconHeight / 2
local iconTexture = dxCreateTexture("icon.png", "dxt5", true, "clamp")

local function drawTalkingIcon(player, camDistToPlayer)
    local boneX, boneY, boneZ = getPedBonePosition(player, 8)
    local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.4)
    if screenX and screenY then
        local factor = 1 / camDistToPlayer
        dxDrawImage(
            screenX - iconHalfWidth * factor,
            screenY - iconHalfHeight * factor,
            iconWidth * factor,
            iconHeight * factor,
            iconTexture, 0, 0, 0, -1, false
        )
    end
end

local function handlePreRender()
    local debugY = 50
    local maxDistance = settings.maxVoiceDistance.value
    local cameraX, cameraY, cameraZ = getCameraMatrix()
    local localPlayerX, localPlayerY, localPlayerZ = getElementPosition(localPlayer)
    for player, talking in pairs(streamedPlayers) do
        local otherPlayerX, otherPlayerY, otherPlayerZ = getElementPosition(player)
        local realDistanceToPlayer = getDistanceBetweenPoints3D(localPlayerX, localPlayerY, localPlayerZ, otherPlayerX, otherPlayerY, otherPlayerZ)
        local playerVolume
        if (realDistanceToPlayer >= maxDistance) then
            playerVolume = 0.0
        else
            playerVolume = (1.0 - (realDistanceToPlayer / maxDistance)^2)
        end

        -- Voice voume is usually unfortunately very low, resulting in players
        -- barely hearing others if we set the player voice volume to 1.0
        -- So we need to increase it to like 6.0 to make it audible
        playerVolume = playerVolume * settings.voiceSoundBoost.value

        setSoundVolume(player, playerVolume)

        if DEBUG_MODE then
            dxDrawRectangle(20, debugY - 5, 300, 25, tocolor(0, 0, 0, 200))
            dxDrawText(("%s | Distance: %.2f | Voice Volume: %.2f"):format(getPlayerName(player), realDistanceToPlayer, playerVolume), 30, debugY)
            debugY = debugY + 15
        end

        if talking and (settings.showTalkingIcon.value == true)
        and realDistanceToPlayer < maxDistance
        and isLineOfSightClear(cameraX, cameraY, cameraZ, otherPlayerX, otherPlayerY, otherPlayerZ, false, false, false, false, true, true, true, localPlayer) then
            drawTalkingIcon(player, getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, otherPlayerX, otherPlayerY, otherPlayerZ))
        end
    end
    if localPlayerTalking and (settings.showTalkingIcon.value == true) then
        drawTalkingIcon(localPlayer, getDistanceBetweenPoints3D(cameraX, cameraY, cameraZ, localPlayerX, localPlayerY, localPlayerZ))
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, player in pairs(getElementsByType("player", root, true)) do
        if player ~= localPlayer and streamedPlayers[player] == nil then
            setSoundVolume(player, 0)
            streamedPlayers[player] = false
        end
    end
    triggerServerEvent("voice_local:setPlayerBroadcast", localPlayer, streamedPlayers)
end, false)

-- Handle remote/other player quit
addEventHandler("onClientPlayerQuit", root, function()
    if streamedPlayers[source] ~= nil then
        streamedPlayers[source] = nil
        triggerServerEvent("voice_local:removeFromPlayerBroadcast", localPlayer, source)
    end
end)

-- Code considers this event's problem @ "Note" box: https://wiki.multitheftauto.com/wiki/OnClientElementStreamIn
-- It should be modified if said behavior ever changes
addEventHandler("onClientElementStreamIn", root, function()
    if source == localPlayer then return end
    if not (isElement(source) and getElementType(source) == "player") then return end

    if isPedDead(source) then return end

    if streamedPlayers[source] == nil then
        setSoundVolume(source, 0)
        streamedPlayers[source] = false
        triggerServerEvent("voice_local:addToPlayerBroadcast", localPlayer, source)
    end
end)
addEventHandler("onClientElementStreamOut", root, function()
    if source == localPlayer then return end
    if not (isElement(source) and getElementType(source) == "player") then return end

    if streamedPlayers[source] ~= nil then
        setSoundVolume(source, 0)
        streamedPlayers[source] = nil
        triggerServerEvent("voice_local:removeFromPlayerBroadcast", localPlayer, source)
    end
end)

-- Update player talking status (for displaying)
addEventHandler("voice_local:onClientPlayerVoiceStart", root, function(player)
    if not (isElement(player) and getElementType(player) == "player") then return end

    if player == localPlayer then
        localPlayerTalking = true
    elseif streamedPlayers[player] ~= nil then
        streamedPlayers[player] = true
    end
end)
addEventHandler("voice_local:onClientPlayerVoiceStop", root, function(player)
    if not (isElement(player) and getElementType(player) == "player") then return end

    if player == localPlayer then
        localPlayerTalking = false
    elseif streamedPlayers[player] ~= nil then
        streamedPlayers[player] = false
    end
end)

-- Load the settings received from the server
addEventHandler("voice_local:updateSettings", localPlayer, function(settingsFromServer)
    settings = settingsFromServer

    if initialWaiting then
        addEventHandler("onClientPreRender", root, handlePreRender, false)
        initialWaiting = false
    end
end, false)
