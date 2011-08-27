addEventHandler('onClientPlayerJoin', root,
	function()
		outputChatBox('* ' .. getPlayerName(source) .. ' has joined the game', 255, 100, 100)
	end
)

addEventHandler('onClientPlayerChangeNick', root,
	function(oldNick, newNick)
		outputChatBox('* ' .. oldNick .. ' is now known as ' .. newNick, 255, 100, 100)
	end
)

addEventHandler('onClientPlayerQuit', root,
	function(reason)
		outputChatBox('* ' .. getPlayerName(source) .. ' has left the game [' .. reason .. ']', 255, 100, 100)
	end
)