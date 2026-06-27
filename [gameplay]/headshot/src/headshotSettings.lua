local headshotSettings = {}
local headshotSettingsAvailable = {
    {"decap", "boolean"}
}

local function headshotSettingsNumberize(headshotValue)
    if not headshotValue then
        return
    end

    if type(headshotValue) == "number" then
        return headshotValue
    end

    if type(headshotValue) == "string" then
        return tonumber(headshotValue)
    end

    return 0
end

local function headshotSettingsBooleanize(headshotValue)
    if type(headshotValue) == "boolean" then
        return headshotValue
    end

    if type(headshotValue) == "string" then
        return headshotValue == "[true]"
    end

    return false
end

function headshotSettingsGet(headshotSetting)
    if not headshotSetting or type(headshotSetting) ~= "string" then
        return
    end

    return headshotSettings[headshotSetting]
end

function headshotSettingsSet(headshotSetting, headshotValue)
    if not headshotSetting or type(headshotSetting) ~= "string" then
        return
    end

    local headshotDot = string.find(headshotSetting, "%.")

    if headshotDot and type(headshotDot) == "number" then
        headshotSetting = string.sub(headshotSetting, headshotDot + 1)
    end

    local headshotFound

    for _, headshotEntry in ipairs(headshotSettingsAvailable) do
        if headshotEntry[1] == headshotSetting then
            headshotFound = headshotEntry
            break
        end
    end

    if not headshotFound then
        return
    end

    local headshotType = headshotFound[2]

    if headshotType == "string" and type(headshotValue) == "string" then
        headshotSettings[headshotSetting] = headshotValue
        return
    end

    if headshotType == "number" and type(headshotValue) == "string" then
        headshotSettings[headshotSetting] = headshotSettingsNumberize(headshotValue)
        return
    end

    if headshotType == "boolean" then
        headshotSettings[headshotSetting] = headshotSettingsBooleanize(headshotValue)
    end
end

addEventHandler("onResourceStart", resourceRoot,
    function()
        for _, headshotEntry in ipairs(headshotSettingsAvailable) do
            local headshotSetting = headshotEntry[1]
            local headshotValue = get(headshotSetting)

            headshotSettingsSet(headshotSetting, headshotValue)
        end
    end
)

addEventHandler("onSettingChange", root,
    function(headshotSetting, _, headshotValue)
        headshotSettingsSet(headshotSetting, headshotValue)
    end
)