local showColorCodes = true; 		-- Shows player's names colorcoded if set to true, and if set to false it doesn't
local defaultHexCode = "#4E5768"; 	-- Hex code for what color to output messages in (only used if showColorCodes is true)


-- This function converts RGB colors to colorcodes like #ffffff
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


addEventHandler('onClientPlayerJoin', root,
	function()

		if showColorCodes then
			outputChatBox(defaultHexCode .. '* ' .. RGBToHex(getPlayerNametagColor(source)) .. getPlayerName(source) .. defaultHexCode .. ' has joined the game', 255, 100, 100, true)
		else
			outputChatBox('* ' .. getPlayerName(source) .. ' has joined the game', 255, 100, 100)
		end

	end
)


addEventHandler('onClientPlayerChangeNick', root,
	function(oldNick, newNick)

		if showColorCodes then
			outputChatBox(defaultHexCode .. '* ' .. RGBToHex(getPlayerNametagColor(source)) .. oldNick .. defaultHexCode .. ' is now known as ' .. RGBToHex(getPlayerNametagColor(source)) .. newNick, 255, 100, 100, true)
		else
			outputChatBox('* ' .. oldNick .. ' is now known as ' .. newNick, 255, 100, 100)
		end

	end
)


addEventHandler('onClientPlayerQuit', root,
	function(reason)

		if showColorCodes then
			outputChatBox(defaultHexCode .. '* ' .. RGBToHex(getPlayerNametagColor(source)) .. getPlayerName(source) .. defaultHexCode .. ' has left the game [' .. reason .. ']', 255, 100, 100, true)
		else
			outputChatBox('* ' .. getPlayerName(source) .. ' has left the game [' .. reason .. ']', 255, 100, 100)
		end

	end
)
