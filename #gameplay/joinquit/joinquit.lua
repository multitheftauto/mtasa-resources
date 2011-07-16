g_Root = getRootElement()

addEventHandler('onClientPlayerJoin', g_Root,
	function()
		outputChatBox('* ' .. getPlayerName(source) .. ' has joined the game', 255, 100, 100)
	end
)

addEventHandler('onClientPlayerChangeNick', g_Root,
	function(oldNick, newNick)
		outputChatBox('* ' .. oldNick .. ' is now known as ' .. newNick, 255, 100, 100)
	end
)

addEventHandler('onClientPlayerQuit', g_Root,
	function(reason)
		outputChatBox('* ' .. getPlayerName(source) .. ' has left the game [' .. reason .. ']', 255, 100, 100)
	end
)
