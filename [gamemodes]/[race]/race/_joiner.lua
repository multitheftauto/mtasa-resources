--
-- joiner.lua
--
-- 1. Delay onPlayerJoin until client loaded
-- 2. Patch the following calls to only use the joined players:
--      getElementsByType('player')
--      getDeadPlayers
--      getPlayerCount
--      getRandomPlayer
-- 3. In any call that uses getRootElement() or g_Root to specify all players, use
--          g_RootPlayers instead. Or use the function onlyJoined(element) to handle the choice.
--

g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())

addEvent('onPlayerJoining')		-- Pre join
addEvent('onPlayerJoined')		-- Post join

---------------------------------
--
-- Hook events
--
---------------------------------
g_EventHandlers = {
	onPlayerJoin = {}       -- { i = { elem = elem, fn = fn, getpropagated = bool } }
}

-- Divert 'onEventName' to '_onEventName'
for eventName,_ in pairs(g_EventHandlers) do
	addEvent('_'..eventName)
	addEventHandler(eventName, g_Root, function(...) triggerEvent( '_'..eventName, source, ... ) end)
end

-- Catch addEventHandler calls here and save the ones listed in g_EventHandlers
_addEventHandler = addEventHandler
function addEventHandler(event, elem, fn, getPropagated)
	getPropagated = getPropagated==nil and true or getPropagated
	if g_EventHandlers[event] then
		table.insert(g_EventHandlers[event], { elem = elem, fn = fn, getpropagated = getPropagated })
	else
		_addEventHandler(event, elem, fn, getPropagated)
	end
end

-- Catch removeEventHandler calls here and remove saved ones listed in g_EventHandlers
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

-- call the saved handlers for 'onEventName'
function callSavedEventHandlers(eventName, eventSource, ...)
	for _,handler in ipairs(g_EventHandlers[eventName]) do
		local triggeredElem = eventSource or g_Root
		if isElement(triggeredElem) then
			while true do
				if triggeredElem == handler.elem then
	                source = eventSource
					handler.fn(...)
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


----------------------------------------------------------------------------
--
-- Function patches
--      Modify functions to act only on joined players
--
----------------------------------------------------------------------------

-- getElementsByType patch
_getElementsByType = getElementsByType
function getElementsByType( type, startat )
    startat = startat or getRootElement()
    if type ~= 'player' then
        return _getElementsByType( type, startat )
    else
        return _getElementsByType( type, onlyJoined(startat) )
    end
end

-- getDeadPlayers patch
_getDeadPlayers = getDeadPlayers
function getDeadPlayers()
    local deadPlayers = _getDeadPlayers()
    for i,player in ipairs(getElementChildren(g_RootJoining)) do
        table.removevalue(deadPlayers,player)
    end
    return deadPlayers
end

-- getPlayerCount patch
_getPlayerCount = getPlayerCount
function getPlayerCount()
    return g_RootPlayers and getElementChildrenCount(g_RootPlayers) or 0
end

-- getRandomPlayer patch
function getRandomPlayer()
    if getPlayerCount() < 1 then
        return nil
    end
    return getElementChildren(g_RootPlayers)[ math.random(1,getPlayerCount()) ]
end


----------------------------------------------------------------------------
--
-- Others functions
--
----------------------------------------------------------------------------

-- If g_Root, change to g_RootPlayers
function onlyJoined(player)
    if player == g_Root then
        if not g_RootPlayers then
            return getResourceRootElement(getThisResource())    -- return an element which will have no players
        end
        return g_RootPlayers
    end
    return player
end

-- Number of players, both pending and joined
function getTotalPlayerCount(player)
	return _getPlayerCount()
end

----------------------------------------------------------------------------
--
-- Event handlers
--
----------------------------------------------------------------------------

-- onResourceStart
--      Setup joining/joined containers and put all current players into g_RootJoining
addEventHandler('onResourceStart', g_ResRoot,
	function()
        -- Create a joining player node and a joined player node
        table.each(getElementsByType('plrcontainer'), destroyElement)
        g_RootJoining = createElement( 'plrcontainer', 'plrs joining' )
        g_RootPlayers = createElement( 'plrcontainer', 'plrs joined' )
        -- Put all current players into 'joining' group
        for i,player in ipairs(_getElementsByType('player')) do
            setElementParent( player, g_RootJoining )

        end
	end
)

-- onResourceStop
--      Clean up
addEventHandler('onResourceStop', g_ResRoot,
	function()
        table.each(getElementsByType('plrcontainer'), destroyElement)
		g_RootJoining = nil
		g_RootPlayers = nil
	end
)

-- Real onPlayerJoin event was fired
--      Move player element to g_RootJoining
addEventHandler('_onPlayerJoin', g_Root,
    function ()
        setElementParent( source, g_RootJoining )
        triggerEvent( 'onPlayerJoining', source );
    end
)

-- onPlayerQuit
--      Clean up
addEventHandler('onPlayerQuit', g_Root,
	function()
	end
)

-- onLoadedAtClient
--      Client says he is good to go. Move player element to g_RootPlayers and call deferred onPlayerJoin event handlers.
addEvent('onLoadedAtClient', true)
addEventHandler('onLoadedAtClient', resourceRoot,
	function( player )
		if checkClient( false, player, 'onLoadedAtClient' ) then return end
        -- Tell other clients; join completed for this player
        triggerClientEvent( g_RootPlayers, 'onOtherJoinCompleteAtServer', resourceRoot, player )

        setElementParent( player, g_RootPlayers )

        -- Tell client; join completed; and send a list of all joined players
        triggerClientEvent( player, 'onMyJoinCompleteAtServer', resourceRoot, getElementChildren(g_RootPlayers) )

        -- Call deferred onPlayerJoin event handlers
        callSavedEventHandlers( 'onPlayerJoin', player )

        -- Custom event for joiner aware event handlers
        triggerEvent( 'onPlayerJoined', player )
	end
)

