-- Remote events:
addEvent("voice_cl:onClientPlayerVoiceStart", true)
addEvent("voice_cl:onClientPlayerVoiceStop", true)
addEvent("voice_local:updateSettings", true)

local streamedPlayers = {}

local sx, sy = guiGetScreenSize()

local nx, ny = sx / 1920, sy / 1080
local width = 108 * nx
local height = 180 * ny
local halfWidth = width / 2
local halfHeight = height / 2
local icon = dxCreateTexture("icon.png", "dxt5", true, "clamp")

local localPlayerTalking = false

addEventHandler("onClientPreRender", root, function()
    local cx, cy, cz = getCameraMatrix()
    for player, talking in pairs(streamedPlayers) do
        local px, py, pz = getElementPosition(player)
        local distanceToPlayer = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz)
        local maxDistance = settings.maxVoiceDistance.value
        local playerVolume
        if (distanceToPlayer <= 0) then
            playerVolume = 1.0
        elseif (distanceToPlayer >= maxDistance) then
            playerVolume = 0.0
        else
            playerVolume = (1.0 - (distanceToPlayer / maxDistance)^2)
        end
        setSoundVolume(player, playerVolume)

        if talking and settings.playersTalkingIcon.value and isLineOfSightClear(cx, cy, cz, px, py, pz, false, false, false, false, true, true, true, localPlayer) then
            local boneX, boneY, boneZ = getPedBonePosition(player, 8)
            local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.5)
            if screenX and screenY and fDistance < maxDistance then
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

    if source == localPlayer then
        localPlayerTalking = false
    elseif streamedPlayers[source] ~= nil then
        streamedPlayers[source] = false
    end
end)

addEventHandler("voice_local:updateSettings", resourceRoot, function(settingsFromServer)
    settings = settingsFromServer
end, false)
