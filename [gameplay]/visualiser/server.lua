addCommandHandler("startmusic", function ( plr, commandName, url )
	setTimer(triggerClientEvent, 1000, 1, "playmus", root, url)
end)
