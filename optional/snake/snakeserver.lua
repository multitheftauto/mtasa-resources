function startSnake (player)
	if getElementType(player) == "player" then
		triggerClientEvent(player, "startSnakeC", player)
	end
end

function stopSnake (player)
	if getElementType(player) == "player" then
		triggerClientEvent(player, "stopSnakeC", player)
	end
end
