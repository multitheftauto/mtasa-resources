local broadcasts = {}

function setPlayerBroadcast(thePlayer, players)
    broadcasts[thePlayer] = {}

    for player, _ in pairs(players) do
        table.insert(broadcasts[thePlayer], player)
    end

    setPlayerVoiceBroadcastTo(thePlayer, broadcasts[thePlayer])
end
addEvent("voice:setPlayerBroadcast", true)
addEventHandler("voice:setPlayerBroadcast", resourceRoot, setPlayerBroadcast)

function addToPlayerBroadcast(thePlayer, player)
    if not broadcasts[thePlayer] then
        broadcasts[thePlayer] = {}
    end

    table.insert(broadcasts[thePlayer], player)
    setPlayerVoiceBroadcastTo(thePlayer, broadcasts[thePlayer])
end
addEvent("voice:addToPlayerBroadcast", true)
addEventHandler("voice:addToPlayerBroadcast", resourceRoot, addToPlayerBroadcast)

function removePlayerBroadcasts(thePlayer, players)
    if not broadcasts[thePlayer] then
        return
    end

    for _, player in ipairs(players) do
        for i, broadcast in ipairs(broadcasts[thePlayer]) do
            if player == broadcast then
                table.remove(broadcasts[thePlayer], i)
            end
        end
    end

    setPlayerVoiceBroadcastTo(thePlayer, broadcasts[thePlayer])
end
addEvent("voice:removePlayerBroadcasts", true)
addEventHandler("voice:removePlayerBroadcasts", resourceRoot, removePlayerBroadcasts)

function removePlayerBroadcast(thePlayer, player)
    if not broadcasts[thePlayer] then
        return
    end

    for i, broadcast in ipairs(broadcasts[thePlayer]) do
        if player == broadcast then
            table.remove(broadcasts[thePlayer], i)
        end
    end

    setPlayerVoiceBroadcastTo(thePlayer, broadcasts[thePlayer])
end
addEvent("voice:removePlayerBroadcast", true)
addEventHandler("voice:removePlayerBroadcast", resourceRoot, removePlayerBroadcast)

function playerVoiceStart()
    for _, listener in ipairs(broadcasts[source]) do
        triggerClientEvent(listener, "voice_cl:onClientPlayerVoiceStart", resourceRoot, source)
    end
end
addEventHandler("onPlayerVoiceStart", root, playerVoiceStart)

function playerVoiceStop()
    for _, listener in ipairs(broadcasts[source]) do
        triggerClientEvent(listener, "voice_cl:onClientPlayerVoiceStop", resourceRoot, source)
    end
end
addEventHandler("onPlayerVoiceStop", root, playerVoiceStop)