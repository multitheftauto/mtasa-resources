-- Remote events:
addEvent("voice_cl:onClientPlayerVoiceStart", true)
addEvent("voice_cl:onClientPlayerVoiceStop", true)
addEvent("voice_local:updateSettings", true)

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

addEventHandler("onClientPreRender", root, function()
    local maxDistance = settings.maxVoiceDistance.value
    local cx, cy, cz = getCameraMatrix()
    for player, talking in pairs(streamedPlayers) do
        local px, py, pz = getElementPosition(player)
        local camDistToPlayer = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz)
        local playerVolume
        if (camDistToPlayer >= maxDistance) then
            playerVolume = 0.0
        else
            playerVolume = (1.0 - (camDistToPlayer / maxDistance)^2)
        end
        setSoundVolume(player, playerVolume)

        if talking and (settings.showTalkingIcon.value == true)
        and camDistToPlayer < maxDistance
        and isLineOfSightClear(cx, cy, cz, px, py, pz, false, false, false, false, true, true, true, localPlayer) then
            drawTalkingIcon(player, camDistToPlayer)
        end
    end
    if localPlayerTalking and (settings.showTalkingIcon.value == true) then
        drawTalkingIcon(localPlayer, getDistanceBetweenPoints3D(cx, cy, cz, getElementPosition(localPlayer)))
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, player in pairs(getElementsByType("player", root, true)) do
        if player ~= localPlayer and streamedPlayers[player] == nil then
            setSoundVolume(source, 0)
            streamedPlayers[player] = false
        end
    end
    triggerServerEvent("voice:setPlayerBroadcast", resourceRoot, streamedPlayers)
end, false)

-- Handle remote/other player join
addEventHandler("onClientPlayerJoin", root, function()
    if streamedPlayers[source] == nil then
        setSoundVolume(source, 0)
        streamedPlayers[source] = false
        triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, source)
    end
end)

-- Handle remote/other player quit
addEventHandler("onClientPlayerQuit", root, function()
    if streamedPlayers[source] ~= nil then
        streamedPlayers[source] = nil
        triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, source)
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
        triggerServerEvent("voice:addToPlayerBroadcast", resourceRoot, source)
    end
end)
addEventHandler("onClientElementStreamOut", root, function()
    if source == localPlayer then return end
    if not (isElement(source) and getElementType(source) == "player") then return end

    if streamedPlayers[source] ~= nil then
        setSoundVolume(source, 0)
        streamedPlayers[source] = nil
        triggerServerEvent("voice:removePlayerBroadcast", resourceRoot, source)
    end
end)

-- Update player talking status (for displaying)
addEventHandler("voice_cl:onClientPlayerVoiceStart", resourceRoot, function(player)
    if not (isElement(player) and getElementType(player) == "player") then return end

    if player == localPlayer then
        localPlayerTalking = true
    elseif streamedPlayers[player] ~= nil then
        streamedPlayers[player] = true
    end
end)
addEventHandler("voice_cl:onClientPlayerVoiceStop", resourceRoot, function(player)
    if not (isElement(player) and getElementType(player) == "player") then return end

    if player == localPlayer then
        localPlayerTalking = false
    elseif streamedPlayers[player] ~= nil then
        streamedPlayers[player] = false
    end
end)

addEventHandler("voice_local:updateSettings", resourceRoot, function(settingsFromServer)
    settings = settingsFromServer
end, false)
