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

function isAnonAdmin(aplayer)
    local player = (aplayer or localPlayer)

    if (not isElement(player)) then
        return false
    end

    return (getElementData(player, "AnonAdmin") == true)
end

-- Source: https://wiki.multitheftauto.com/wiki/FormatDate
-- Credit: NeonBlack
local weekDays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
function formatDate(format, escaper, timestamp)
	--check("formatDate", "string", format, "format", {"nil","string"}, escaper, "escaper", {"nil","string"}, timestamp, "timestamp")
	
	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false

	time.year = time.year + 1900
	time.month = time.month + 1
	
	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), s = ("%02d"):format(time.second), w = weekDays[time.weekday+1]:sub(1, 2), W = weekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }
	
	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end
	
	return formattedDate
end