if isVoiceEnabled() then
	addEventHandler ( "onPlayerJoin", root,
		function()
			setPlayerInternalChannel ( source, root )
		end
	)

	addEventHandler ( "onResourceStart", getResourceRootElement(),
		function()
			refreshPlayers()
		end
	)

	function refreshPlayers()
		for i,player in ipairs(getElementsByType"player") do
			if not tonumber(getPlayerChannel ( player )) then --If he's not in a scripted channel
				setPlayerDefaultChannel ( player )
			end
		end
	end

	setTimer ( refreshPlayers, TEAM_REFRESH, 0 )

	function setPlayerDefaultChannel ( player )
		local team = getPlayerTeam(player)
		if team and settings.autoassign_to_teams then --He has a team, so let's put him in that team's voice channel
			return setPlayerInternalChannel ( player, team )
		else --If he doesn't have a team, stick him in the root
			return setPlayerInternalChannel ( player, root )
		end
	end


	function setPlayerInternalChannel ( player, element )
		if playerChannels[player] == element then
			return false
		end
		playerChannels[player] = element
		channels[element] = player
		setPlayerVoiceBroadcastTo ( player, element )
		return true
	end
end
