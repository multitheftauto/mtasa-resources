if isVoiceEnabled() then
	TEAM_REFRESH = 4000 -- Interval in which team channels are refreshed, in MS.
	SETTINGS_REFRESH = 5000 -- Interval in which team channels are refreshed, in MS.
	resourceRoot = getResourceRootElement(getThisResource())

	setElementData ( resourceRoot, "voice_enabled", true ) -- REMOVE IN 1.4

	------------------
	playerChannels = {}
	channels = {}
	globalMuted = {}
	mutedBy = {}
	settings = {}

	------------------
	addEvent("voice_mutePlayerForPlayer", true)
	addEvent("voice_unmutePlayerForPlayer", true)
	addEvent("voice_muteTableForPlayer", true)

	------------------
	--Function to convert { moo=true,boo=true } into { moo,boo }
	function tableToArray (tbl)
		local newtable = {}
		for k,v in pairs(tbl) do
			table.insert ( newtable, k )
		end
		return newtable
	end

	function checkValidPlayer ( player )
		if not isElement(player) or getElementType(player) ~= "player" then
			outputDebugString ( "setPlayerVoiceMuted: Bad 'player' argument", 2 )
			return false
		end
		return true
	end

	------------------
	--Monitor our settings so they dynamically update
	setTimer (
		function()
			local show_chat_icon = get ( "show_chat_icon" )
			if show_chat_icon ~= settings.voice_show_chat_icon then
				settings.show_chat_icon = show_chat_icon
				setElementData ( resourceRoot, "show_chat_icon", show_chat_icon )
			end
			local autoassign_to_teams = get ( "autoassign_to_teams" )
			if autoassign_to_teams ~= settings.autoassign_to_teams then
				settings.autoassign_to_teams = autoassign_to_teams
				refreshPlayers()
			end

		end,
	SETTINGS_REFRESH, 0 )
end

function outputVoiceNotLoaded ()
	outputDebugString ( "Voice is not enabled on this server!", 1 )
	return false
end
