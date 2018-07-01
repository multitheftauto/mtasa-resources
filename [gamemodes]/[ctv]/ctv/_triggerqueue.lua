local _triggerClientEvent = triggerClientEvent
local playerData = {}			-- { player = { loaded = bool, pending = {...} } }

local function joinHandler(player)
	playerData[player or source] = { loaded = false, pending = {} }
end

addEventHandler('onResourceStart', getResourceRootElement(getThisResource()),
	function()
		for i,player in ipairs(getElementsByType('player')) do
			joinHandler(player)
		end
	end,
	false
)

addEventHandler('onPlayerJoin', getRootElement(), joinHandler)

addEvent('onLoadedAtClient', true)
addEventHandler('onLoadedAtClient', getRootElement(),
	function()
		playerData[source].loaded = true
		for i,event in ipairs(playerData[source].pending) do
			_triggerClientEvent(source, event.name, event.source, unpack(event.args))
		end
		playerData[source].pending = nil
	end
)

addEventHandler('onPlayerQuit', getRootElement(),
	function()
		playerData[source] = nil
	end
)

local function addToQueue(player, name, source, args)
	for i,a in pairs(args) do
		if type(a) == 'table' then
			args[i] = table.deepcopy(a)
		end
	end
	if playerData[player] and playerData[player].pending then
		table.insert(playerData[player].pending, { name = name, source = source, args = args })
	end
end


function triggerClientEvent(...)
	local args = { ... }
	local triggerFor, name, source
	if type(args[1]) == 'userdata' then
		triggerFor = table.remove(args, 1)
	else
		triggerFor = getRootElement()
	end
	name = table.remove(args, 1)
	source = table.remove(args, 1)

	if triggerFor == getRootElement() then
		-- trigger for everyone
		local triggerNow = true
		for player,data in pairs(playerData) do
			if not data.loaded then
				triggerNow = false
				break
			end
		end
		if triggerNow then
			_triggerClientEvent(getRootElement(), name, source, unpack(args))
		else
			for player,data in pairs(playerData) do
				addToQueue(player, name, source, args)
			end
		end
	elseif playerData[triggerFor] then
		-- trigger for single player
		if playerData[triggerFor].loaded then
			_triggerClientEvent(triggerFor, name, source, unpack(args))
		else
			addToQueue(triggerFor, name, source, args)
		end
	end
end
