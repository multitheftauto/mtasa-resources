local rootElement = getRootElement()

-- gets a friendly name from a category ID
local nameFromCategoryID = {
	objectID = function(ID)
		return getObjectNameFromModel ( tonumber(ID) )
	end,
	vehicleID = function(ID)
		return getVehicleNameFromModel ( tonumber(ID) )
	end,
	weaponID = function(ID)
		return getWeaponNameFromID ( tonumber(ID) )
	end,
	markerType = function(ID)
		return ID
	end,
	pickupType = function(ID)
		local IDAsNumber = tonumber(ID)
		if IDAsNumber then
			return getWeaponNameFromID(IDAsNumber)
		else
			return ID
		end
	end,
}

-- assigns a new unique ID to an element
function assignID ( theElement )
	local creatorResource = edf.edfGetCreatorResource(theElement) 
	if creatorResource == edf.res then
		creatorResource = thisResource
	end
	
	local elementType = getElementType( theElement )
	local elementDefinition = loadedEDF[creatorResource].elements[elementType]
	local elementID = getElementID( theElement )
	
	-- if it doesn't have an ID or it isn't unique,
	if not ( elementID and getElementByID( elementID ) == theElement ) then
		-- prepare the ID string. Append the element type first,
		local idString = elementType
		
		-- then all category-based properties' values' names,
		if elementDefinition then
			for dataField, dataDefinition in pairs( elementDefinition.data ) do
				local nameGetter = nameFromCategoryID[dataDefinition.datatype]
				if nameGetter then
					local dataValue = edf.edfGetElementProperty(theElement, dataField)
					local valueName = nameGetter(dataValue)
					if valueName then
						idString = idString .. " ("..tostring(valueName)..")"
					end
				end
			end
		end
	
		-- and lastly, find an unused index, and set the ID
		local i = 1
		while true do
			local newID = idString .. " ("..i..")"
			if getElementByID ( newID ) == false then
				setElementID( theElement, newID )
				setElementData( theElement, "me:ID", newID )
				setElementData( theElement, "me:autoID", true )
				break
			else
				i = i + 1
			end
		end
	end
end
