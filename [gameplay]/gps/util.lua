local CRs = {}

local _resume = coroutine.resume
function coroutine.resume(cr, ...)
	local ret = { _resume(cr, ...) }
	if coroutine.status(cr) == 'dead' then
		CRs[CRs[cr]] = nil
		CRs[cr] = nil
	end
	if not ret[1] then
		outputDebugString(ret[2], 1)
		return false
	end
	table.remove(ret, 1)
	return unpack(ret)
end

local serverMT = {}
function serverMT:__index(fnName)
	return function(...)
		triggerServerEvent('onServerCallback', getLocalPlayer(), CRs[coroutine.running()], fnName, ...)
		return coroutine.yield()
	end
end
server = setmetatable({}, serverMT)

addEvent('onServerCallbackReply', true)
addEventHandler('onServerCallbackReply', getResourceRootElement(getThisResource()),
	function(crID, ...)
		coroutine.resume(CRs[crID], ...)
	end,
	false
)

local function wrapHandler(fn)
	return function(...)
		local cr = coroutine.create(fn)
		local id = #CRs + 1
		CRs[id] = cr
		CRs[cr] = id
		coroutine.resume(cr, ...)
	end
end

local _addEventHandler = addEventHandler
function addEventHandler(event, elem, fn, getPropagated)
	return _addEventHandler(
		event,
		elem,
		(event == 'onClientRender' or event == 'onClientPreRender') and fn or wrapHandler(fn),
		getPropagated
	)
end

local _addCommandHandler = addCommandHandler
function addCommandHandler(command, fn)
	return _addCommandHandler(command, wrapHandler(fn))
end


function table.each(t, callback, ...)
	for k,v in pairs(t) do
		callback(v, ...)
	end
	return t
end

function table.merge ( ... )
	local ret = { }

	for index, tbl in ipairs ( {...} ) do
		for index, val in ipairs ( tbl ) do
			table.insert ( ret, val )
		end
	end

	return ret
end

function table.find ( tbl, val )
	for index, value in ipairs ( tbl ) do
		if value == val then
			return index
		end
	end

	return false
end
