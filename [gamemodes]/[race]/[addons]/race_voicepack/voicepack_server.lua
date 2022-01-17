local mapMode = ""

function playAudio(player, filename)
	-- outputDebugString("play sound "..filename.." for "..getPlayerName(player))
	triggerClientEvent(player, "playClientAudio", root, filename)
end

addEvent("onMapStarting")
addEventHandler('onMapStarting', root,
	function(mapInfo)
		mapMode = mapInfo.modename
	end
)

addEventHandler('onPlayerQuit', root,
    function()
        if mapMode == "Destruction derby" and getElementData(source,"state") == "alive" then
			local alivePlayers = getAlivePlayers()
            for i,player in ipairs(alivePlayers) do
                if player == source then
                    table.remove(alivePlayers, i)
                end
            end
            if #alivePlayers == 1 then
                playAudio(alivePlayers[1], "jobcomplete.mp3")
            end
		end
    end
)

addEventHandler('onPlayerWasted', root,
	function()
		if mapMode == "Destruction derby" then
			local alivePlayers = getAlivePlayers()
			if #alivePlayers >= 1 then
				playAudio(source, "jobfail.mp3")
				if #alivePlayers == 1 then
					playAudio(alivePlayers[1], "jobcomplete.mp3")
				end
			end
		else
			if p_Killed then
				p_Killed = false
			else
				playAudio(source, "wasted.mp3")
			end
		end
	end
)

addEvent('onRequestKillPlayer', true)
addEventHandler('onRequestKillPlayer', root,
    function()
		p_Killed = true
    end
)

addEvent("onPlayerToptimeImprovement")
addEventHandler("onPlayerToptimeImprovement", root,
	function(newPos, newTime, oldPos, oldTime, displayTopCount, validEntryCount)
		if newPos <= displayTopCount and newPos <= validEntryCount then
			playAudio(source, "nicework.mp3")
		end
	end
)

local _getAlivePlayers = getAlivePlayers
function getAlivePlayers(player)
	local result = {}
	for _,plr in ipairs(_getAlivePlayers()) do
		if getElementData(plr, "state") == "alive" then
			table.insert(result, plr)
		end
	end
	return result
end
