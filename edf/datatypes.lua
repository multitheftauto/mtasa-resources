convert = {}
local c = convert

--basic datatypes--
c.string = tostring

c.number = tonumber

c.integer = function(var)
	local nVar = c.number(var)
	if nVar then
		local int, frac = math.modf(nVar)
		if frac == 0 then
			return int
		else
			return nil
		end
	else
		return nil
	end
end

c.natural = function(var)
	local nVar = c.integer(var)
	if nVar then
		if nVar >= 0 then
			return nVar
		else
			return nil
		end
	else
		return nil
	end
end

c.boolean = function(var)
	if type(var) == "boolean" then
		return var
	elseif var == "true" then
		return true
	elseif var == "false" then
		return false
	else
		return nil
	end
end

c.colour = function(var)
	var = string.upper(c.string(var))
	if getColorFromString(var) then
		return var
	else
		var = '#'..var
		if getColorFromString(var) then return var
		else
			return nil
		end
	end
end

c.color = c.colour

c.element = function(ID, elementType)
	if isElement(ID) then
		return ID
	end
	if type(ID) ~= "string" then
		return nil
	end
	if type(elementType) == "table" then
		elementType = elementType[1]
	end
	local theElement = getElementByID(ID)
	if theElement then
		if elementType then
			if getElementType(theElement) == elementType then
				return theElement
			end
		else
			return theElement
		end
	else
		return nil
	end
end

c.plate = function(var)
	if var ~= nil then
		var = c.string(var)
	else
		return nil
	end
	if #var <= 8 then
		return string.upper(string.gsub( var, "[^%d%a]", "" ))
	else
		return nil
	end
end

c.objectID = function(var)
	var = c.number(var)
	if var and ((var >= 615 and var <= 18630) or (var >= 321 and var <= 373)) then
		return var
	else
		return nil
	end
end

c.vehicleID = function(var)
	var = c.number(var)
	if var and getVehicleNameFromModel(var) then
		return var
	else
		return nil
	end
end

local skinIDs = {}
for _, v in ipairs(getValidPedModels()) do
	skinIDs[v] = true
end

c.skinID = function(var)
	var = c.number(var)
	if skinIDs[var] then
		return var
	else
		return nil
	end
end

c.blipID = function(var)
	var = c.number(var)
	if var ~= nil and var >= 0 and var <= 63 then
		return var
	else
		return nil
	end
end

c.weaponID = function(var)
	var = c.number(var)
	if var and getWeaponNameFromID(var) then
		return var
	else
		return nil
	end
end

c.pickupType = function(var)
	if var == "health" or var == "armor" then
		return var
	else
		return c.weaponID(var)
	end
end

local markerTypes = {
	arrow = true,
	checkpoint = true,
	corona = true,
	cylinder = true,
	ring = true,
}

c.markerType = function(var)
	if markerTypes[var] then
		return var
	else
		return nil
	end
end

local colshapeTypes = {
	colcircle = true,
	colcube = true,
	colrectangle = true,
	colsphere = true,
	coltube = true,
}

c.colshapeType = function(var)
	if colshapeTypes[var] then
		return var
	else
		return nil
	end
end

c.coord3d = function(var)
	local vType = type(var)
	if vType == "string" then
		local substrings = split(var, string.byte(','))
		local coord = {}
		for i = 1, 3 do
			coord[i] = c.number(substrings[i])
			if not coord[i] then
				return nil
			end
		end
		return coord
	elseif vType == "table" then
		local coord = {}
		for i = 1, 3 do
			coord[i] = c.number(var[i])
			if not coord[i] then
				return nil
			end
		end
		return coord
	else
		return nil
	end
end

c.camera = function(var)
	local vType = type(var)
	if vType == "string" then
		local substrings = split(var, string.byte(','))
		if #substrings >= 6 then
			return {{substrings[1],substrings[2],substrings[3]},{substrings[4],substrings[5],substrings[6]} }
		end
		-- local coord1 = c.coord3d {substrings[1], substrings[2], substrings[3]}
		-- local coord2 = c.coord3d {substrings[4], substrings[5], substrings[6]}

		-- if coord1 and coord2 then
			-- return {coord1, coord2}
		-- else
			-- return nil
		-- end
	elseif vType == "table" then
		local coord1 = c.coord3d(var[1])
		local coord2 = c.coord3d(var[2])

		if coord1 and coord2 then
			return var
		else
			return nil
		end
	else
		return nil
	end
end

c.selection = function(var,validTypes)
	if not validTypes then
		return var
	end
	local vType = type(var)
	if vType ~= "string" then
		return false
	end
	local found
	for selectionKey,selectionValue in ipairs(validTypes) do
		if selectionValue == var then
			found = true
			break
		end
	end
	if ( found ) then
		return var
	else
		return validTypes[1]
	end
end

c.radius = function(var)
	var = c.number(var)
	if var then
		return var
	else
		return nil
	end
end

--c.vehicleupgrades
