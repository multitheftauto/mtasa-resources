local headshotSettings = {}
local headshotSettingsAvailable = {
    {"decap", "boolean"}
}

function headshotSettingsGet(headshotSetting)
    if not headshotSetting or type(headshotSetting) ~= "string" then
        return
    end

    return headshotSettings[headshotSetting]
end

function headshotSettingsBooleanize(headshotValue)
    if not headshotValue or type(headshotValue) ~= "string" then
        return
    end

    if string.find(headshotValue, "true") then
        return true
    end

    return false
end

addEventHandler("onResourceStart", resourceRoot,
    function()
        for _, headshotEntry in pairs(headshotSettingsAvailable) do
            local headshotSetting = headshotEntry[1]
            local headshotType = headshotEntry[2]
            local headshotValue = get(headshotSetting)

            if headshotValue and type(headshotValue) == "string" then
                if headshotType == "boolean" then
                    headshotSettings[headshotSetting] = headshotSettingsBooleanize(headshotValue)
                else
                    headshotSettings[headshotSetting] = headshotValue
                end
            end
        end
    end
)

addEventHandler("onSettingChange", root,
    function(headshotSetting, _, headshotValue)
        local headshotDot = string.find(headshotSetting, "%.")

        if headshotDot and type(headshotDot) == "number" then
            headshotSetting = string.sub(headshotSetting, headshotDot + 1)
        end

        local headshotFound

        for _, headshotEntry in pairs(headshotSettingsAvailable) do
            if headshotEntry[1] == headshotSetting then
                headshotFound = headshotEntry
                break
            end
        end

        if not headshotFound then
            return
        end

        local headshotType = headshotFound[2]

        if not headshotValue or type(headshotValue) ~= "string" then
            return
        end

        if headshotType == "boolean" then
            headshotSettings[headshotSetting] = headshotSettingsBooleanize(headshotValue)
        else
            headshotSettings[headshotSetting] = headshotValue
        end
    end
)