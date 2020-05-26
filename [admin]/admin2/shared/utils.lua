--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_coroutines.lua
*
*	Original File by lil_Toady
*
**************************************]]

function stripColorCodes(str)
    local oldLen
    repeat
        oldLen = str:len()
        str = str:gsub('#%x%x%x%x%x%x', '')
    until str:len() == oldLen
    return str
end

function RGBToHex(red, green, blue, alpha)
    -- Make sure RGB values passed to this function are correct
    if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
        return nil
    end

    -- Alpha check
    if alpha then
        return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
    else
        return string.format("#%.2X%.2X%.2X", red, green, blue)
    end
end

function isAnonAdmin(player)
    local player = (player or localPlayer)

    if (not isElement(player)) then
        return false
    end

    return (getElementData(player, "AnonAdmin") == true)
end
