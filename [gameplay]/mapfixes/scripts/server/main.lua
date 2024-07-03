local mapFixComponentStatuses = {}

-- Fetch the settings on script load
for settingName, _ in pairs(mapFixComponents) do
    local value = get(settingName)
    mapFixComponentStatuses[settingName] = (value == true)
end

local function handlePlayerResourceStart(res)
    if res ~= resource then return end

    triggerClientEvent(source, "mapfixes:client:loadAllComponents", source, mapFixComponentStatuses)
end
addEventHandler("onPlayerResourceStart", root, handlePlayerResourceStart)

local function handleSettingChange(settingName)
    settingName = settingName:gsub(getResourceName(resource) .. ("."), "")
    local modifier = settingName:sub(1, 1)
    if modifier == "*" or modifier == "#" or modifier == "@" then
        settingName = settingName:sub(2)
    end
    if not mapFixComponents[settingName] then return end

    -- Fetch the new setting value
    local newValue = get(settingName)
    local isEnabled = (newValue == true)
    mapFixComponentStatuses[settingName] = isEnabled

    -- Trigger for all players
    triggerClientEvent("mapfixes:client:togOneComponent", resourceRoot, settingName, isEnabled)
end
addEventHandler("onSettingChange", root, handleSettingChange, false)
