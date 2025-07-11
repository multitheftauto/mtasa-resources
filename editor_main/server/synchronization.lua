local function syncElementPosition(element, value)
	local x, y, z = unpack(value)
	edf.edfSetElementPosition(element, x, y, z)
end

local function syncElementRotation(element, value)
	local rx, ry, rz
	if type(value) == "number" then --Z rotation
		rx, ry, rz = 0, 0, value
	else --XYZ rotation
		rx, ry, rz = unpack(value)
	end
	edf.edfSetElementRotation(element, rx, ry, rz, "ZYX")
end

local function syncElementScale(element, scale)
	edf.edfSetElementScale(element, scale)
end

local function syncElementDimension(element, dim)
	setElementData(element, "me:dimension", dim)
end

local function syncElementInterior(element, int)
	edf.edfSetElementInterior(element, int)
end

local function syncElementAlpha(element, alpha)
	edf.edfSetElementAlpha(element, alpha)
end

local function syncParent(element, parent)
	setElementData(element, "me:parent", parent)
end

local function syncID(element, id)
	if id == "" then
		--force a reassign. blank the ID first to avoid ID number changing
		setElementID(element, "")
		assignID(element)
	else
		setElementID(element, id)
		setElementData(element, "me:ID", id)
		setElementData(element, "id", id)
		removeElementData(element, "me:autoID")
	end
end

local specialSyncers = {
	position = syncElementPosition,
	rotation = syncElementRotation,
	scale = syncElementScale,
	dimension = syncElementDimension,
	interior = syncElementInterior,
	alpha = syncElementAlpha,
	parent = syncParent,
	id = syncID,
}

local function commonSyncer(element, property, value)
	if loadedEDF[edf.edfGetCreatorResource(element)] then
		local datatype = loadedEDF[edf.edfGetCreatorResource(element)].elements[getElementType(element)].data[property].datatype
		if datatype == "element" then
			local references = getElementData ( value, "me:references" ) or {}
			references[element] = property
			setElementData ( value, "me:references", references )
		end
	end
	edf.edfSetElementProperty(element, property, value)

	if getElementData(element, "me:autoID") then
		--force a reassign. blank the ID first to avoid ID number changing
		setElementID(element, "")
		assignID(element)
	end
end

function syncProperty(property, value, element)
	local locked = element or getLockedElement(client)
	if element or (locked and (source == locked or edf.edfGetParent(source) == locked)) then
		if specialSyncers[property] then
			specialSyncers[property](locked, value)
		else
			commonSyncer(locked, property, value)
		end
	end
end
addEventHandler("syncProperty", root, syncProperty)

function syncProperties(oldProperties, newProperties, element, undoredo)
	local locked = element or getLockedElement(client)

	if (client and not isPlayerAllowedToDoEditorAction(client,"editElementProperties")) or (client and client ~= edf.edfGetCreatorClient(element) and not isPlayerAllowedToDoEditorAction(client,"editOtherElementProperties")) then
		editor_gui.outputMessage ("You don't have permissions to edit element properties!", client,255,0,0)

		for dataField, value in pairs(oldProperties) do
			if newProperties[dataField] ~= value then
				if specialSyncers[dataField] then
					specialSyncers[dataField](locked, value)
				else
					commonSyncer(locked, dataField, value)
				end
			end
		end

		return
	end

	if element or (locked and (source == locked or edf.edfGetParent(source) == locked)) then
		for dataField, value in pairs(newProperties) do
			if specialSyncers[dataField] then
				specialSyncers[dataField](locked, value)
			else
				commonSyncer(locked, dataField, value)
			end
		end

		for dataField, value in pairs(oldProperties) do
			if ( not newProperties[dataField] ) then
				if specialSyncers[dataField] then
					specialSyncers[dataField](locked, nil)
				else
					local datatype = loadedEDF[edf.edfGetCreatorResource(locked)].elements[getElementType(locked)].data[dataField].datatype
					if ( datatype ~= "boolean" ) then
						commonSyncer(locked, dataField, nil)
					end
				end
			end
		end
		if not undoredo then
			triggerEvent("onElementPropertiesChange_undoredo", locked, oldProperties, newProperties)
		end
	end
end
addEventHandler("syncProperties", root, syncProperties)
