g_ModelForPickupType = { nitro = 2221, repair = 2222, vehiclechange = 2223 }
models = {}

startTick = getTickCount()

function onStart() --Callback triggered by edf
	for name,id in pairs(g_ModelForPickupType) do
		models[name] = {}
		models[name].txd = engineLoadTXD(':race/model/' .. name .. '.txd')
		engineImportTXD(models[name].txd, id)

		models[name].dff = engineLoadDFF(':race/model/' .. name .. '.dff', id)
		engineReplaceModel(models[name].dff, id)
	end
	for i,racepickup in pairs(getElementsByType"racepickup") do
		checkElementType(racepickup)
	end
end

function onStop()
	for name,id in pairs(g_ModelForPickupType) do
		destroyElement ( models[name].txd )
		destroyElement ( models[name].dff )
	end
end

addEventHandler ( "onClientElementPropertyChanged", root,
	function ( propertyName )
		if getElementType(source) == "racepickup" then
			if propertyName == "type" then
				local pickupType = exports.edf:edfGetElementProperty ( source, "type" )
				local object = getRepresentation(source,"object")
				if object then
					setElementModel ( object[1], g_ModelForPickupType[pickupType] or 1346 )
				end
			end
		elseif getElementType(source) == "checkpoint" then
			if propertyName == "nextid" or propertyName == "type" then
				local nextID = exports.edf:edfGetElementProperty ( source, "nextid" )
				local marker = getRepresentation(source,"marker")
				if nextID then
					if getMarkerType(marker) == "checkpoint" then
						setMarkerIcon ( marker, "arrow" )
					end
					setMarkerTarget ( marker, exports.edf:edfGetElementPosition(nextID) )
				else
					if getMarkerType(marker) == "checkpoint" then
						setMarkerIcon ( marker, "finish" )
					end
				end
			end
		end
	end
)

function checkElementType(element)
	element = element or source
	if getElementType(element) == "racepickup" then
		local pickupType = exports.edf:edfGetElementProperty ( element, "type" )
		local object = getRepresentation(element,"object")
		if object then
			setElementModel ( object[1], g_ModelForPickupType[pickupType] or 1346 )
			setElementAlpha ( object[2], 0 )
		end
	end
end
addEventHandler("onClientElementCreate", root, checkElementType)

--Pickup processing code
function updatePickups()
	local angle = math.fmod((getTickCount() - startTick) * 360 / 2000, 360)
	for i,racepickup in pairs(getElementsByType"racepickup") do
		setElementRotation(racepickup, 0, 0, angle)
	end
end
addEventHandler('onClientRender', root, updatePickups)

function getRepresentation(element,type)
	local elemTable = {}
	for i,elem in ipairs(getElementsByType(type,element)) do
		if elem ~= exports.edf:edfGetHandle ( elem ) then
			table.insert(elemTable, elem)
		end
	end
	if #elemTable == 0 then
		return false
	elseif #elemTable == 1 then
		return elemTable[1]
	else
		return elemTable
	end
end
