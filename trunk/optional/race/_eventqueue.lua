-- This file hooks addEventHandler (and removeEventHandler) and doesn't allow the specified events to trigger
-- until all clients have downloaded the client scripts.
-- Add a triggerServerEvent('onLoadedAtClient', getLocalPlayer()) to the onClientResourceStart
-- event for this to work.

g_EventHandlers = {
	onResourceStart = {},		-- { i = { elem = elem, fn = fn, getpropagated = bool } }
	onGamemodeMapStart = {},
	onPlayerJoin = {}
}

g_Root = getRootElement()
g_EventQueue = {}		-- { i = { name = eventName, source = source, args = {...} } }
g_LoadedPlayers = {}
g_SlowPlayers = {}

function createQueueText()
	if g_QueueDisplay then
		destroyQueueText()
	end
	g_QueueDisplay = textCreateDisplay()
	g_QueueTextItem = textCreateTextItem('Loading...', 0.5, 0.8, 'medium', 255, 255, 255, 255, 1.5, 'center', 'center')
	textDisplayAddText(g_QueueDisplay, g_QueueTextItem)
	for i,player in ipairs(getElementsByType('player')) do
		textDisplayAddObserver(g_QueueDisplay, player)
	end
end

function updateQueueText()
	if g_QueueDisplay then
		local left = getPlayerCount() - #g_LoadedPlayers
		textItemSetText(g_QueueTextItem, left .. ' more player' .. (left ~= 1 and 's' or '') .. ' downloading...')
	end
end

function destroyQueueText()
	if g_QueueDisplay then
		textDestroyDisplay(g_QueueDisplay)
		g_QueueDisplay = nil
		textDestroyTextItem(g_QueueTextItem)
		g_QueueTextItem = nil
	end
end

addEvent('onLoadedAtClient', true)
addEventHandler('onLoadedAtClient', g_Root,
	function()
		table.insert(g_LoadedPlayers, source)
		if #g_LoadedPlayers == getPlayerCount() then
			if g_QueueTimeoutTimer then
				killTimer(g_QueueTimeoutTimer)
			end
			flushQueue()
		else
			updateQueueText()
			if not g_QueueTimeoutTimer then
				g_QueueTimeoutTimer = setTimer(flushQueue, 30000, 1)
			end
		end
	end
)

addEventHandler('onPlayerJoin', g_Root, updateQueueText)

addEventHandler('onPlayerQuit', g_Root,
	function()
		table.removevalue(g_LoadedPlayers, source)
		table.removevalue(g_SlowPlayers, source)
		local numReadyPlayers = #g_LoadedPlayers
		for i,slowplayer in ipairs(g_SlowPlayers) do
			if not table.find(g_LoadedPlayers, slowplayer) then
				numReadyPlayers = numReadyPlayers + 1
			end
		end
		if numReadyPlayers == getPlayerCount() then
			if g_QueueTimeoutTimer then
				killTimer(g_QueueTimeoutTimer)
			end
			flushQueue()
		else
			updateQueueText()
		end
	end
)

function queueTimeout()
	for i,player in ipairs(getElementsByType('player')) do
		if not table.find(g_LoadedPlayers, player) then
			if not table.find(g_SlowPlayers, player) then
				table.insert(g_SlowPlayers, player)
			end
		else
			table.removevalue(g_SlowPlayers, player)
		end
	end
	flushQueue()
end

function flushQueue()
	g_QueueTimeoutTimer = nil
	destroyQueueText()
	
	for _,event in ipairs(g_EventQueue) do
		source = event.source
		local triggeredElem
		for _,handler in ipairs(g_EventHandlers[event.name]) do
			triggeredElem = event.source
			if not triggeredElem then
				triggeredElem = g_Root
			end
			if isElement(triggeredElem) then
				while true do
					if triggeredElem == handler.elem then
						handler.fn(unpack(event.args))
						break
					end
					if not handler.getpropagated or triggeredElem == g_Root then
						break
					end
					triggeredElem = getElementParent(triggeredElem)
				end
			end
		end
	end
	g_EventQueue = {}
end

for eventName,_ in pairs(g_EventHandlers) do
	addEventHandler(eventName, g_Root, function(...) hookedEventTriggered(eventName, ...) end)
end

function hookedEventTriggered(eventName, ...)
	table.insert(g_EventQueue, { name = eventName, source = source, args = {...} })
	local numReadyPlayers = #g_LoadedPlayers
	for i,slowplayer in ipairs(g_SlowPlayers) do
		if not table.find(g_LoadedPlayers, slowplayer) then
			numReadyPlayers = numReadyPlayers + 1
		end
	end
	if numReadyPlayers == getPlayerCount() then
		if g_QueueTimeoutTimer then
			killTimer(g_QueueTimeoutTimer)
		end
		flushQueue()
	elseif not g_QueueTimeoutTimer and eventName ~= 'onPlayerJoin' then
		createQueueText()
		g_QueueTimeoutTimer = setTimer(queueTimeout, 30000, 1)
	end
end

_addEventHandler = addEventHandler
function addEventHandler(event, elem, fn, getPropagated)
	if getPropagated == nil then
		getPropagated = true
	end
	if g_EventHandlers[event] then
		table.insert(g_EventHandlers[event], { elem = elem, fn = fn, getpropagated = getPropagated })
	else
		_addEventHandler(event, elem, fn, getPropagated)
	end
end

_removeEventHandler = removeEventHandler
function removeEventHandler(event, elem, fn)
	if g_EventHandlers[event] then
		local handler
		for i=#g_EventHandlers[event],1,-1 do
			handler = g_EventHandlers[event][i]
			if handler.elem == elem and handler.fn == fn then
				table.remove(g_EventHandlers[event], i)
			end
		end
	else
		_removeEventHandler(event, elem, fn)
	end
end