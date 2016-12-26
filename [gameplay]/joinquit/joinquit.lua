-- Colour settings
-- Defaults: r = 255; g = 100; b = 100;
local r = 255
local g = 100
local b = 100

addEventHandler('onClientPlayerJoin', root,
	function()
		outputChatBox('* ' .. getPlayerName(source) .. ' has joined the game', r, g, b)
	end
)

addEventHandler('onClientPlayerChangeNick', root,
	function(oldNick, newNick)
		outputChatBox('* ' .. oldNick .. ' is now known as ' .. newNick, r, g, b)
	end
)

addEventHandler('onClientPlayerQuit', root,
	function(reason)
		outputChatBox('* ' .. getPlayerName(source) .. ' has left the game [' .. reason .. ']', r, g, b)
	end
)
