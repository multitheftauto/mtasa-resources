SETTINGS_REFRESH = 2000 -- Interval in which team channels are refreshed, in MS.
bShowChatIcons = true

localPlayer = getLocalPlayer()
voicePlayers = {}
globalMuted = {}

---
addEventHandler ( "onClientPlayerVoiceStart", root,
	function()
		if isPlayerMuted ( source ) then
			cancelEvent()
			return
		end
		voicePlayers[source] = true
	end
)

addEventHandler ( "onClientPlayerVoiceStop", root,
	function()
		voicePlayers[source] = nil
	end
)

addEventHandler ( "onClientPlayerQuit", root,
	function()
		voicePlayers[source] = nil
	end
)
---

function checkValidPlayer ( player )
	if not isElement(player) or getElementType(player) ~= "player" then
		outputDebugString ( "is/setPlayerMuted: Bad 'player' argument", 2 )
		return false
	end
	return true
end

---

setTimer ( 
	function()
		bShowChatIcons = getElementData ( resourceRoot, "show_chat_icon", show_chat_icon )
	end,
SETTINGS_REFRESH, 0 )