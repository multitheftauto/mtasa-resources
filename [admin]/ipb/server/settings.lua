
local resourceName = (Resource.getThis()):getName()
local settingPrefix = ("*%s."):format(resourceName)
local prefixLength = settingPrefix:len()

g_Settings = {
    ["SaveHighCPUResources"] = get("SaveHighCPUResources") or "true",
    ["SaveHighCPUResourcesAmount"] = get("SaveHighCPUResourcesAmount") or "10",
    ["NotifyIPBUsersOfHighUsage"] = get("NotifyIPBUsersOfHighUsage") or "50",
    ["AccessRightName"] = get("AccessRightName") or "general.http"
}

local function onResourceSettingChange(name, old, new)
    g_Settings[name] = new

    if Element.getByIndex("player", 0) then
        triggerClientEvent("ipb.updateSetting", resourceRoot, name, new)
    end
end

addEventHandler("onSettingChange", root,
    function (settingName, old, new)
        if not settingName:find(settingPrefix, 1, true) then
            return
        end

        local shortSettingName = settingName:sub(prefixLength + 1)

        if g_Settings[shortSettingName] ~= new then
            onResourceSettingChange(shortSettingName, old and fromJSON(old) or old, new and fromJSON(new) or new)
        end
    end
)

addEvent("onClientResourceStart", true)
addEventHandler("onClientResourceStart", root,
    function ()
        client:triggerEvent("ipb.syncSettings", client, g_Settings)
    end
)
