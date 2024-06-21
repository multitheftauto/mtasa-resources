-- MTA:SA Map Fixes

local mapFixComponents = {
    ["crack_palace_interior"] = {
        spawnBuildings = {
            -- Fill the hole of Big Smoke's Crack Palace with vanilla open-world interior
            {17933, 2532.992188, -1289.789062, 39.281250, 0, 0, 0},
            {17946, 2533.820312, -1290.554688, 36.945312, 0, 0, 0},
        },
    },
}

-- Check resource settings
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
