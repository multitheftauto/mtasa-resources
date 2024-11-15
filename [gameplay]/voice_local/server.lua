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

addEventHandler("voice:setPlayerBroadcast", resourceRoot, function(players)
    if not client then return end
    if type(players) ~= "table" then return end
    broadcasts[client] = {client}

    for player, _ in pairs(players) do
        if player ~= client and isElement(player) and getElementType(player) == "player" then
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

    -- Prevent duplicates
    for _, broadcast in ipairs(broadcasts[client]) do
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

    for i, broadcast in ipairs(broadcasts[client]) do
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
