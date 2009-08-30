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
					setElementModel ( object, g_ModelForPickupType[pickupType] or 1337 )
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

--Pickup processing code
function updatePickups()
	local angle = math.fmod((getTickCount() - startTick) * 360 / 2000, 360)
	for i,racepickup in pairs(getElementsByType"racepickup") do
		local object = getRepresentation(racepickup,"object")
		if object then
			setElementRotation(object, 0, 0, angle)
		end
	end
end
addEventHandler('onClientRender', root, updatePickups)

function getRepresentation(element,type)
	for i,elem in ipairs(getElementsByType(type,element)) do
		if elem ~= exports.edf:edfGetHandle ( elem ) then
			return elem
		end
	end
	return false
end
