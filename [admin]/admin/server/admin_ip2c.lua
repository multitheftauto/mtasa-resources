--[[
    ip2c script has been moved to its own separate resource

    Placeholder function to preserve backwards compatibility
        e.g. custom external scripts that call this function
]]
function getPlayerCountry(player)
    outputServerLog("[Deprecation Warning] admin/server/admin_ip2c.lua: getPlayerCountry(player)")
    outputServerLog("  This function has been moved to the new ip2c standalone resource")
    outputServerLog("  Get it from the latest MTA:SA default resources package:")
    outputServerLog("  https://mirror-cdn.multitheftauto.com/mtasa/resources/mtasa-resources-latest.zip", 2)
    return false
end
