--
--
-- admin_serverjoiner.lua
--
-- Delays triggerClientEvent until the client is ready.
-- Based on _triggequeue.lua from amx.
-- Should be high up in meta.xml.
--

---------------------------------------------------------------------------
--
-- Variables
--
---------------------------------------------------------------------------
local _triggerClientEvent = triggerClientEvent
local playerData = {}			-- { player = { loaded = bool, pending = {...} } }


---------------------------------------------------------------------------
--
-- Events
--
---------------------------------------------------------------------------
addEventHandler('onResourceStart', resourceRoot,
	function()
		for i,player in ipairs(getElementsByType('player')) do
			playerData[player] = { loaded = false, pending = {} }
		end
	end
)

addEventHandler('onPlayerJoin', root,
	function()
		playerData[source] = { loaded = false, pending = {} }
	end
)

addEventHandler('onPlayerQuit', root,
	function()
		playerData[source] = nil
	end
)

-- New player loaded
addEvent('onResourceLoadedAtClient_internal', true)
addEventHandler('onResourceLoadedAtClient_internal', resourceRoot,
	function(player)
		if checkClient( false, player, 'onResourceLoadedAtClient_internal' ) then return end
		if playerData[player] then
			playerData[player].loaded = true
			-- Do queued events
			for i,event in ipairs(playerData[player].pending) do
				_triggerClientEvent(player, event.name, event.source, unpack(event.args))
			end
			playerData[player].pending = nil
		end
	end
)


---------------------------------------------------------------------------
--
-- Functions
--
---------------------------------------------------------------------------
local function addToQueue(player, name, source, args)
	for i,a in pairs(args) do
		if type(a) == 'table' then
			args[i] = table.deepcopy(a)
		end
	end
	table.insert(playerData[player].pending, { name = name, source = source, args = args })
end


function triggerClientEvent( triggerFor, name, theElement, ... )
	local args = { ... }
	if type(triggerFor) == 'string' then
		table.insert(args, 1, theElement)
		theElement = name
		name = triggerFor
		triggerFor = nil
	end

	triggerFor = triggerFor or root
	if triggerFor == root then
		-- trigger for everyone
		for player,data in pairs(playerData) do
			if data.loaded then
				_triggerClientEvent(player, name, theElement, unpack(args))
			else
				addToQueue(player, name, theElement, args)
			end
		end
	elseif playerData[triggerFor] then
		-- trigger for single player
		if playerData[triggerFor].loaded then
			_triggerClientEvent(triggerFor, name, theElement, unpack(args))
		else
			addToQueue(triggerFor, name, theElement, args)
		end
	end
end


---------------------------------------------------------------------------
--
-- Util
--
---------------------------------------------------------------------------
function table.deepcopy(t)
	local known = {}
	local function _deepcopy(t)
		local result = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				if not known[v] then
					known[v] = _deepcopy(v)
				end
				result[k] = known[v]
			else
				result[k] = v
			end
		end
		return result
	end
	return _deepcopy(t)
end

