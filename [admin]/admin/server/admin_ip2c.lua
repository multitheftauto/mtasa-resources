--[[
    ip2c script has been moved to its own separate resource.
    This exported function remains for backwards compatibility, in case any custom resources rely on it.
]]
function getPlayerCountry(player)
    outputDebugString("exports.admin:getPlayerCountry(player) is deprecated. Get & use the new ip2c resource.", 2)
    outputDebugString("  https://mirror-cdn.multitheftauto.com/mtasa/resources/mtasa-resources-latest.zip", 2)
    return false
end