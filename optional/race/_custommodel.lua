-- This is a hax file to make custom model loading work reliably
-- Usage: loadCustomModel(objID, dffFile, txdFile) in the main script body,
-- then createObject() in an event handler. Or: loadCustomModel in an event,
-- and createObject() in an event that gets triggered later.

local preloads = {}
local pendingEvents = {}

local _addEventHandler = addEventHandler
function addEventHandler(event, elem, handler, getPropagated)
	if event == 'onClientRender' then
		return _addEventHandler(event, elem, handler, getPropagated)
	end
	return _addEventHandler(
		event,
		elem,
		function(...)
			if not next(preloads) then
				handler(...)
			else
				table.insert(pendingEvents, { fn = handler, source = source, args = { ... } })
			end
		end,
		getPropagated
	)
end

local function customModelPreloaded()
	local id = table.find(preloads, 'elem', source)
	if not id then
		return
	end
	local preload = preloads[id]
	local txd = engineLoadTXD(preload.txd)
	engineImportTXD(txd, id)
	local dff = engineLoadDFF(preload.dff, id)
	engineReplaceModel(dff, id)
	removeEventHandler('onClientElementStreamIn', source, customModelPreloaded)
	destroyElement(source)
	preloads[id] = nil
	while not next(preloads) and #pendingEvents > 0 do
		local event = table.remove(pendingEvents, 1)
		source = event.source
		event.fn(unpack(event.args))
	end
end

function loadCustomModel(id, dff, txd)
	if preloads[id] then
		return
	end
	local x, y, z = getElementPosition(getLocalPlayer())
	local elem
	if id <= 609 then
		elem = createVehicle(id, x, y, z - 10)
	else
		elem = createObject(id, x, y, z - 10)
	end
	setCameraTarget(getLocalPlayer())
	preloads[id] = { dff = dff, txd = txd, elem = elem }
	_addEventHandler('onClientElementStreamIn', elem, customModelPreloaded, false)
end


-- Make sure the preloads are near the player so the onClientElementStreamIn event gets triggered
local function checkPreloads()
	for id,preload in pairs(preloads) do
		local px, py, pz = getElementPosition(getLocalPlayer())
		local ex, ey, ez = getElementPosition(preload.elem)
		local dist = getDistanceBetweenPoints3D ( px, py, pz, ex, ey, ez )
		if( dist > 50 ) then
			setElementPosition( preload.elem, px, py, pz - 10 )
		end
	end
end

setTimer(checkPreloads, 500, 10 )
