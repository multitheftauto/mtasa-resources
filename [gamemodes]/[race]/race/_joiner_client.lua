--
-- joiner_client.lua
--
-- see joiner.lua for details
--

g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())

addEvent('onClientPlayerJoining')	-- Pre join
addEvent('onClientPlayerJoined')	-- Post join

g_JoinedPlayers = {}                -- List of joined players maintained at the client


---------------------------------
--
-- Hook events
--
---------------------------------
g_EventHandlers = {
	onClientPlayerJoin = {},        -- { i = { elem = elem, fn = fn, getpropagated = bool } }
	onClientResourceStart = {}
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
        return filterTable(_getElementsByType( type, startat ))
    end
end


----------------------------------------------------------------------------
--
-- Others functions
--
----------------------------------------------------------------------------

-- Remove players not joined from a table
function filterTable(playerList)
    local result = {}
    for i,player in ipairs(playerList) do
        if table.find(g_JoinedPlayers,player) then
            table.insert(result,player)
        end
    end
    return result
end


----------------------------------------------------------------------------
--
-- Event handlers
--
----------------------------------------------------------------------------

-- Real onClientPlayerJoin event was fired
--      Do nothing
addEventHandler('_onClientPlayerJoin', g_Root,
    function ()
        triggerEvent( 'onClientPlayerJoining', source );
    end
)

-- Real onClientResourceStart event was fired
--      Call the deferred onClientResourceStart event handlers, then tell the server we are loaded.
addEventHandler('_onClientResourceStart', g_ResRoot,
	function()
        callSavedEventHandlers( 'onClientResourceStart', source )
        if _DEBUG_TIMING then
    		setTimer(
                function()
                    triggerServerEvent('onLoadedAtClient', resourceRoot, g_Me )
                end,
                math.random(1000,15000), 1 )
        else
    		triggerServerEvent('onLoadedAtClient', resourceRoot, g_Me )
	    end
	end
)

-- onMyJoinCompleteAtServer
--   This player is now fully joined at the server.
addEvent('onMyJoinCompleteAtServer', true)
addEventHandler('onMyJoinCompleteAtServer', resourceRoot,
	function(allJoinedPlayersAtServer)
        for i,player in ipairs(allJoinedPlayersAtServer) do
            table.insertUnique(g_JoinedPlayers,player)
        end
	end
)


-- onOtherJoinCompleteAtServer
--   A player is fully joined at the server. Call the deferred onClientPlayerJoin event handlers.
addEvent('onOtherJoinCompleteAtServer', true)
addEventHandler('onOtherJoinCompleteAtServer', resourceRoot,
	function( player )
        table.insertUnique(g_JoinedPlayers,player)

        -- Call deferred onClientPlayerJoin event handlers
        callSavedEventHandlers( 'onClientPlayerJoin', player )

        -- Custom event for joiner aware event handlers
        triggerEvent( 'onClientPlayerJoined', player )
	end
)

-- onClientPlayerQuit
--   Remove player from JoinedPlayers list
addEventHandler('onClientPlayerQuit', g_Root,
    function ()
        table.removevalue(g_JoinedPlayers, source)
    end
)

