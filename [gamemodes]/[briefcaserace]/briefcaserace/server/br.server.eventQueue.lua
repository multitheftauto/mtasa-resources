local root = getRootElement()
addEvent("onClientResourceLoad", true)

local clientStatuses = {}
local eventQueues = {}

--addEventHandler("onPlayerJoin", root,
--function ()
--	clientStatuses[source] = false
--	eventQueues[source] = {}
--end
--)

addEventHandler("onPlayerQuit", root,
function (quitType, reason, responsibleElement)
	clientStatuses[source] = nil
	eventQueues[source] = nil
end
)

addEventHandler("onClientResourceLoad", root,
function ()
	clientStatuses[source] = true
	if (eventQueues[source]) then
		for i=1,#eventQueues[source] do
			triggerClientEvent(source, eventQueues[source][i].event, eventQueues[source][i].elem, unpack(eventQueues[source][i].args)) -- sometimes bad arg to unpack?? expected table got nil
		end
	end
	eventQueues[source] = {}
end
)

function scheduleClientEvent(player, eventName, attachToElement, ...)
	assert(player and eventName and attachToElement)
	assert({...}, "OMGz, how can a table be false/nil???")
	if (clientStatuses[player]) then
--debugMessage("a. scheduling event: " .. eventName)
		triggerClientEvent(player, eventName, attachToElement, unpack({...}))
		return true
	elseif (eventQueues[player]) then
--debugMessage("b. scheduling event: " .. eventName)
		table.insert(eventQueues[player], {event = eventName, elem = attachToElement, args = {...}})
		return true
	else
--debugMessage("c. scheduling event: " .. eventName)
		clientStatuses[player] = false
		eventQueues[player] = {}
		table.insert(eventQueues[player], {event = eventName, elem = attachToElement, args = {...}})
		return true
	end
end

function scheduleClientEventForPlayers(players, eventName, attachToElement, ...)
	for i,v in ipairs(players) do
		scheduleClientEvent(v, eventName, attachToElement, unpack({...}))
	end
end
