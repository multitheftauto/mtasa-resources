if isVoiceEnabled() then
	function setPlayerMuted ( player, muted )
		if not checkValidPlayer ( player ) then return false end
		muted = not not muted or nil
		globalMuted[player] = muted
		return setPlayerVoiceBroadcastTo ( player, (not muted) and root or nil )
	end

	function isPlayerMuted ( player )
		if not checkValidPlayer ( player ) then return false end
		return not not globalMuted[player]
	end

	--Returns a list of players of which have muted the specified player
	function getPlayerMutedByList ( player ) 
		if not checkValidPlayer ( player ) then return false end
		return tableToArray(mutedBy[player] or {})
	end

	function updateMutedBroadcast ( player )
		local currentChannel = getPlayerChannel(source)
		if tonumber(currentChannel) then
			setPlayerVoiceBroadcastTo ( player, getPlayersInChannel ( currentChannel ), getPlayerMutedByList ( player )  )
		else --It's an element
			setPlayerVoiceBroadcastTo ( player, currentChannel, getPlayerMutedByList ( player ) )
		end
	end


	function addPlayerMutedBy ()
		mutedBy[source] = mutedBy[source] or {}
		mutedBy[source][client] = true
		updateMutedBroadcast ( source )
	end
	addEventHandler ( "voice_mutePlayerForPlayer", root, addPlayerMutedBy )

	function removePlayerMutedBy ()
		if mutedBy[source] then
			mutedBy[source][client] = nil
			--Refresh the player
			updateMutedBroadcast ( source )
		end
	end
	addEventHandler ( "voice_unmutePlayerForPlayer", root, removePlayerMutedBy )

	addEventHandler ( "onPlayerQuit", root, 
		function()
			mutedBy[source] = nil
			globalMuted[source] = nil
		end
	)
else
	setPlayerMuted = outputVoiceNotLoaded
	isPlayerMuted = outputVoiceNotLoaded
	getPlayerMutedByList = outputVoiceNotLoaded
end
