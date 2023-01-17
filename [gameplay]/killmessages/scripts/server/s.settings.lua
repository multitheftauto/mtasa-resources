local settings = {}

addEventHandler('onResourceStart', resourceRoot, function()
    local allSettings = {'displayLines', 'drawMarginRight', 'drawMarginBottom', 'fadeTime', 'duration', 'outputConsole'}
    for k, v in ipairs(allSettings) do
        settings[v] = get(v)
    end
end)

addEvent('requestKillMessagesSettings', true)
addEventHandler('requestKillMessagesSettings', root, function()
    triggerClientEvent(client, 'receiveKillMessagesSettings', client, settings)
end)

addEventHandler('onSettingChange', root, function(name, _, value)
    name = name:gsub('[%*%#%@](.*)', '%1')-- Remove leading '*','#' or '@'
    name = name:gsub(getResourceName(resource) .. '%.(.*)', '%1')-- Remove leading 'resName.'

    if (not settings[name]) then return end

    value = fromJSON(value)
    settings[name] = value

    -- send only the changed setting
    triggerClientEvent(root, 'receiveKillMessagesSettings', root, {
        [name] = value
    })
end)
