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
