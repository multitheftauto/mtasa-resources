--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_ip2c.lua
*
*	Original File by lil_Toady
*
**************************************]]
local ip2cRunning = false

function getPlayerCountry(...)
    return ip2cRunning and exports.ip2c:getPlayerCountry(...) or false
end

function getPlayerCountryName(...)
    return ip2cRunning and exports.ip2c:getPlayerCountryName(...) or false
end

addEventHandler("onResourceStart", resourceRoot, function()
    local ip2c = getResourceFromName("ip2c")
    if ip2c then
        local state = getResourceState(ip2c)
        if (state == "running") or (state == "loaded" and startResource(ip2c)) then
            ip2cRunning = true

            addEventHandler("onResourceStop", getResourceRootElement(ip2c), function()
                ip2cRunning = false
            end)
        end
    end
end)