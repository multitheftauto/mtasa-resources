-- MTA:SA Map Fixes

for name, data in pairs(mapFixComponents) do
    data.enabled = get(name) == "true"
end

local function handlePlayerResourceStart(res)
    if res ~= resource then return end

    triggerClientEvent(source, "mapfixes:client:loadAllComponents", source, mapFixComponents)
end
addEventHandler("onPlayerResourceStart", root, handlePlayerResourceStart)

local function handleSettingChange(settingName)
    settingName = settingName:gsub(getResourceName(resource)..("."), "")
    local modifier = settingName:sub(1, 1)
    if modifier == "*" or modifier == "#" or modifier == "@" then
        settingName = settingName:sub(2)
    end
    local data = mapFixComponents[settingName]
    if not data then return end
    
    local newValue = get(settingName)
    data.enabled = newValue == "true"
    
    for _, player in pairs(getElementsByType("player")) do
        triggerClientEvent(player, "mapfixes:client:togOneComponent", player, settingName, data.enabled)
    end
end
addEventHandler("onSettingChange", root, handleSettingChange, false)
