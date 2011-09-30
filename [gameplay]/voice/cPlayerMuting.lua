addEventHandler ( "onClientPlayerVoiceStart", root,
	function()
		if globalMuted[source] then
			return
		end
	end
)

--Mute a remote player for the local player only.  It informs the server as an optimization, so speech is never sent.
function setPlayerVoiceMuted ( player, muted )
	if not checkValidPlayer ( player ) then return false end
	if muted and not globalMuted[player] then
		globalMuted[player] = true
		return triggerServerEvent ( "voice_mutePlayerForPlayer", player )
	elseif not muted and globalMuted[player] then
		globalMuted[player] = nil
		return triggerServerEvent ( "voice_unmutePlayerForPlayer", player )
	end
	return false
end

function isPlayerVoiceMuted ( player )
	if not checkValidPlayer ( player ) then return false end
	return not not globalMuted[player]
end


-- Functions for backward compatibility only
-- DO NOT USE THESE AS THEY WILL BE REMOVED IN A LITTLE WHILE --
function isPlayerMuted ( player )			return isPlayerVoiceMuted ( player ) end
function setPlayerMuted ( player, muted )	return setPlayerVoiceMuted ( player, muted ) end
-- DO NOT USE THESE AS THEY WILL BE REMOVED IN A LITTLE WHILE --
