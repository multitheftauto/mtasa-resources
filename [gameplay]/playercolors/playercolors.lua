local lowerBound, upperBound = unpack(get("color_range"))

local freeroamRunning = false

local function randomizePlayerColor(player)
	player = player or source
	local r, g, b = math.random(lowerBound, upperBound), math.random(lowerBound, upperBound), math.random(lowerBound, upperBound)
	setPlayerNametagColor(player, r, g, b)
end
addEventHandler("onPlayerJoin", root, randomizePlayerColor)

local function setAllPlayerColors()
	for _, player in ipairs(getElementsByType("player")) do
		if eventName == "onResourceStop" then
			setPlayerNametagColor(player, false)
		else
			randomizePlayerColor(player)
		end
	end
end
-- mapmanager resets player colors to white when the map ends
addEventHandler("onGamemodeMapStart", root, setAllPlayerColors)

local function handleResourceStartStop(res)
	if res == resource then
		local freeroamResource = getResourceFromName("freeroam")
		if freeroamResource then
			freeroamRunning = getResourceState(freeroamResource) == "running"
		end
		setAllPlayerColors()
	elseif getResourceName(res) == "freeroam" then
		freeroamRunning = eventName == "onResourceStart"
	end
end
addEventHandler("onResourceStart", root, handleResourceStartStop)
addEventHandler("onResourceStop", root, handleResourceStartStop)

addEventHandler('onPlayerChat', root,
	function(msg, type)
		if type == 0 then
			if freeroamRunning then
				return -- Let freeroam handle chat
			end
			cancelEvent()
			local r, g, b = getPlayerColor(source)
			local name = getPlayerName(source)
			msg = msg:gsub('#%x%x%x%x%x%x', '')
			outputChatBox( name.. ': #FFFFFF' .. msg, root, r, g, b, true)
			outputServerLog( "CHAT: " .. name .. ": " .. msg )
		end
	end
)

getPlayerColor = getPlayerNametagColor
getPlayerColour = getPlayerNametagColor
