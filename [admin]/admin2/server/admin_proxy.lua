--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_proxy.lua
*
*	Original File by lil_Toady
*
**************************************]]
local blurLevel = 36

function setBlurLevel(blevel)
    local level = tonumber(blevel)
    if (level and level >= 0 and level <= 255) then
        blurLevel = level
        for _, player in ipairs(getElementsByType("player")) do
            setPlayerBlurLevel(player, blurLevel)
        end
        return true
    end
    return false
end

addEventHandler(
    EVENT_SESSION,
    root,
    function(type)
        if (type == SESSION_START) then
            setPlayerBlurLevel(client, blurLevel)
        end
    end
)
