-- Remote events:
addEvent("voice_local:setPlayerBroadcast", true)
addEvent("voice_local:addToPlayerBroadcast", true)
addEvent("voice_local:removeFromPlayerBroadcast", true)

local broadcasts = {}

for settingName, settingData in pairs(settings) do
    if settingData then
        settings[settingName].value = get("*"..settingData.key)
    end
end

addEventHandler("onPlayerResourceStart", root, function(res)
    if res == resource then
        triggerClientEvent(source, "voice_local:updateSettings", source, settings)
    end
end)

-- Don't let the player talk to anyone as soon as they join
addEventHandler("onPlayerJoin", root, function()
    setPlayerVoiceBroadcastTo(source, {})
end)

addEventHandler("onPlayerQuit", root, function()
    broadcasts[source] = nil
end)

-- Anti-cheat
-- Prevents clients from wanting to broadcast their voice to players that are really too far away
local function canPlayerBeWithinOtherPlayerStreamDistance(player, otherPlayer)
    local maxDist = tonumber(getServerConfigSetting("ped_syncer_distance")) or 100
    if (not isElement(player)) or (not isElement(otherPlayer)) then
        return false
    end
    if getElementType(player) ~= "player" or getElementType(otherPlayer) ~= "player" then
        return false
    end
    if getElementInterior(player) ~= getElementInterior(otherPlayer)
    or getElementDimension(player) ~= getElementDimension(otherPlayer) then
        return false
    end
    local px, py, pz = getElementPosition(player)
    local opx, opy, opz = getElementPosition(otherPlayer)
    return getDistanceBetweenPoints3D(px, py, pz, opx, opy, opz) <= maxDist
end

addEventHandler("voice_local:setPlayerBroadcast", root, function(players)
    if not client then return end
    if type(players) ~= "table" then return end
    broadcasts[client] = {client}

    for player, _ in pairs(players) do
        if player ~= client then
            if canPlayerBeWithinOtherPlayerStreamDistance(client, player) then
                table.insert(broadcasts[client], player)
            else
                iprint(eventName, "ignoring", getPlayerName(player))
            end
        end
    end
    setPlayerVoiceBroadcastTo(client, broadcasts[client])
end)

addEventHandler("voice_local:addToPlayerBroadcast", root, function(player)
    if not client then return end
    if not (isElement(player) and getElementType(player) == "player") then return end

    if not broadcasts[client] then
        broadcasts[client] = {client}
    end

    if not canPlayerBeWithinOtherPlayerStreamDistance(client, player) then
        iprint(eventName, "ignoring", getPlayerName(player))
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
end)

addEventHandler("voice_local:removeFromPlayerBroadcast", root, function(player)
    if not client then return end
    if not (isElement(player) and getElementType(player) == "player") then return end

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
end)

addEventHandler("onPlayerVoiceStart", root, function()
    if not broadcasts[source] then
        -- Somehow if the system still hasn't loaded the player, prevent them from talking
        cancelEvent()
        return
    end
    triggerClientEvent(broadcasts[source], "voice_local:onClientPlayerVoiceStart", source, source)
end)

addEventHandler("onPlayerVoiceStop", root, function()
    if not broadcasts[source] then
        return
    end
    triggerClientEvent(broadcasts[source], "voice_local:onClientPlayerVoiceStop", source, source)
end)

-- Cancel resource start if voice is not enabled on the server
addEventHandler("onResourceStart", resourceRoot, function()
    if not isVoiceEnabled() then
        cancelEvent(true, "<voice> setting is not enabled on this server")
    end
end, false)
