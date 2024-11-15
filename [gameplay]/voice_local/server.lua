-- Remote events:
addEvent("voice:setPlayerBroadcast", true)
addEvent("voice:addToPlayerBroadcast", true)
addEvent("voice:removePlayerBroadcast", true)

local broadcasts = {}

for settingName, settingData in pairs(settings) do
    if settingData then
        settings[settingName].value = get("*"..settingData.key)
    end
end

addEventHandler("onPlayerResourceStart", root, function(res)
    if res == resource then
        triggerClientEvent(source, "voice_local:updateSettings", resourceRoot, settings)
    end
end)

-- Don't let the player talk to anyone as soon as they join
addEventHandler("onPlayerJoin", root, function()
    print("not letting", getPlayerName(source), "talk to anyone")
    setPlayerVoiceBroadcastTo(source, {})
end)

addEventHandler("onPlayerQuit", root, function()
    broadcasts[source] = nil
end)

-- Anti-cheat
-- Prevents clients from wanting to broadcast their voice to players that are really too far away
local function canPlayerBeWithinOtherPlayerStreamDistance(player, otherPlayer)
    local maxDist = getServerConfigSetting("ped_syncer_distance") or 100
    if not isElement(player) or not isElement(otherPlayer) then
        return false
    end
    if getElementType(player) ~= "player" or getElementType(otherPlayer) ~= "player" then
        return false
    end
    if getElementInterior(player) ~= getElementInterior(otherPlayer) or getElementDimension(player) ~= getElementDimension(otherPlayer) then
        return false
    end
    return getDistanceBetweenPoints3D(getElementPosition(player), getElementPosition(otherPlayer)) <= maxDist
end

addEventHandler("voice:setPlayerBroadcast", resourceRoot, function(players)
    if not client then return end
    if type(players) ~= "table" then return end
    broadcasts[client] = {client}

    for player, _ in pairs(players) do
        if player ~= client and canPlayerBeWithinOtherPlayerStreamDistance(client, player) then
            table.insert(broadcasts[client], player)
        end
    end
    setPlayerVoiceBroadcastTo(client, broadcasts[client])
end, false)

addEventHandler("voice:addToPlayerBroadcast", resourceRoot, function(player)
    if not client then return end
    if not isElement(player) or getElementType(player) ~= "player" then return end

    if not broadcasts[client] then
        broadcasts[client] = {client}
    end

    if not canPlayerBeWithinOtherPlayerStreamDistance(client, player) then
        return
    end

    -- Prevent duplicates
    for _, broadcast in pairs(broadcasts[client]) do
        if player == broadcast then
            return
        end
    end

    table.insert(broadcasts[client], player)
    setPlayerVoiceBroadcastTo(client, broadcasts[client])
end, false)

addEventHandler("voice:removePlayerBroadcast", resourceRoot, function(player)
    if not client then return end
    if not isElement(player) or getElementType(player) ~= "player" then return end

    if not broadcasts[client] then
        return
    end

    for i, broadcast in pairs(broadcasts[client]) do
        if player~=client and player == broadcast then
            table.remove(broadcasts[client], i)
            break
        end
    end

    setPlayerVoiceBroadcastTo(client, broadcasts[client])
end, false)

addEventHandler("onPlayerVoiceStart", root, function()
    if not broadcasts[source] then
        -- Somehow if the system still hasn't loaded the player, prevent them from talking
        cancelEvent()
        return
    end
    triggerClientEvent(broadcasts[source], "voice_cl:onClientPlayerVoiceStart", resourceRoot, source)
end)

addEventHandler("onPlayerVoiceStop", root, function()
    if not broadcasts[source] then
        return
    end
    triggerClientEvent(broadcasts[source], "voice_cl:onClientPlayerVoiceStop", resourceRoot, source)
end)

-- Cancel resource start if voice is not enabled on the server
addEventHandler("onResourceStart", resourceRoot, function()
    if not isVoiceEnabled() then
        cancelEvent(true, "<voice> setting is not enabled on this server")
    end
end, false)
