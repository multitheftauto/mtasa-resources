local settings = {}

function getSetting(name)
    return settings[name] or false
end

addEvent('receiveKillMessagesSettings', true)
addEventHandler('receiveKillMessagesSettings', localPlayer, function(received)
    for k, v in pairs(received) do -- replace only received settings.
        settings[k] = tonumber(v)
    end
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    triggerServerEvent('requestKillMessagesSettings', localPlayer)
end)
