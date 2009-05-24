local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement(getThisResource())
local g_Me = getLocalPlayer()

local p_Killed = false
local mapMode = ""

function playAudio(filename)
	outputDebugString("play sound "..filename)
	playSound("audio/"..filename)
end
addEvent("playClientAudio", true)
addEventHandler("playClientAudio", g_Root, playAudio)

addEvent("onClientMapStarting")
addEventHandler('onClientMapStarting', g_Root,
	function(mapInfo)
		mapMode = mapInfo.modename
	end
)

addEventHandler('onClientResourceStart', g_ResRoot,
	function()
		playAudio("raceon.mp3")
	end
)

addEventHandler('onClientPlayerWasted', g_Root,
	function()
		if source == g_Me then
			if not p_Killed then
				if mapMode ~= "Destruction derby" then
					playAudio("wasted.mp3")
				end
			else
				p_Killed = false
			end
		end
	end
)

addEvent("onClientPlayerOutOfTime", true)
addEventHandler('onClientPlayerOutOfTime', g_Root,
	function()
		playAudio("timesup.mp3")
	end
)

addCommandHandler('kill',
    function()
		p_Killed = true
    end
)

bindKey('enter_exit', 'down',
    function()
		p_Killed = true
    end
)
