local g_Root = getRootElement()

local mapMode = ""

function playAudio(player, filename)
	outputDebugString("play sound "..filename.." for "..getPlayerName(player))
	triggerClientEvent(player, "playClientAudio", getRootElement(), filename)
end

addEvent("onMapStarting")
addEventHandler('onMapStarting', g_Root,
	function(mapInfo)
		mapMode = mapInfo.modename
	end
)

addEventHandler('onPlayerWasted', g_Root,
	function()
		if mapMode == "Destruction derby" then
			local alivePlayers = getAlivePlayers()
			if #alivePlayers >= 1 then
				playAudio(source, "jobfail.mp3")
				if #alivePlayers == 1 then
					playAudio(alivePlayers[1], "jobcomplete.mp3")
				end
			end
		end
	end
)

addEvent("onPlayerToptimeImprovement")
addEventHandler("onPlayerToptimeImprovement", g_Root,
	function( player, newPos, newTime, oldPos, oldTime, displayTopCount, validEntryCount )
		playAudio(source, "nicework.mp3")
	end
)
