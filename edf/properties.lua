local function getStringFromColor( R, G, B, A )
	if R and G and B then
		A = A or 255
		return "#"..string.format("%02x",R)..string.format("%02x",G)..string.format("%02x",B)..string.format("%02x",A)
	else
		return false
	end
end

propertyGetters = {
	object = {
		model = getElementModel,
		doublesided = function(element)
			if isElementDoubleSided then
				return isElementDoubleSided(element) and "true" or "false"
			else
				return getElementData(element,"doublesided")=="true" and "true" or "false"
			end
		end,
		scale = getObjectScale,
		breakable = function(element)
			if isObjectBreakable then
				return isObjectBreakable(element) and "true" or "false"
			else
				local breakable = getElementData(element, "breakable")
				if breakable == "true" or breakable == false then
					return "true"
				else
					return "false"
				end
			end
		end,
		collisions = function(element)
			local collisions = getElementData(element, "collisions")
			if collisions == "true" or collisions == false then
				return "true"
			else
				return "false"
			end
		end
	},
	ped = {
		model = getElementModel,
		rotZ = getPedRotation,
		health = getElementHealth,
		armor = getPedArmor,
		collisions = function(element)
			local collisions = getElementData(element, "collisions")
			if collisions == "true" or collisions == false then
				return "true"
			else
				return "false"
			end
		end
	},
	vehicle = {
		model = getElementModel,
		color1 = function(element)
			local vehCol = {getVehicleColor(element, true)}
			return {vehCol[1], vehCol[2], vehCol[3]}
		end,
		color2 = function(element)
			local vehCol = {getVehicleColor(element, true)}
			return {vehCol[4], vehCol[5], vehCol[6]}
		end,
		color3 = function(element)
			local vehCol = {getVehicleColor(element, true)}
			return {vehCol[7], vehCol[8], vehCol[9]}
		end,
		color4 = function(element)
			local vehCol = {getVehicleColor(element, true)}
			return {vehCol[10], vehCol[11], vehCol[12]}
		end,
		upgrades = getVehicleUpgrades,
		plate = getVehiclePlateText,
		sirens = function(vehicle)
			return getVehicleSirensOn(vehicle) and "true" or "false"
		end,
		health = getElementHealth,
		paintjob = function(vehicle) return tostring(getVehiclePaintjob(vehicle)) end,
		landingGearDown = function(element) return tostring(getVehicleLandingGearDown(element)) end,
		collisions = function(element)
			local collisions = getElementData(element, "collisions")
			if collisions == "true" or collisions == false then
				return "true"
			else
				return "false"
			end
		end
	},
	marker = {
		type = getMarkerType,
		size = getMarkerSize,
		color = function(element)
			local r, g, b, a = getMarkerColor(element)
			return getStringFromColor(r,g,b,a)
		end,
	},
	pickup = {
		type = function(element)
			local pType = getPickupType(element)
			if pType == 0 then
				return "health"
			elseif pType == 1 then
				return "armor"
			elseif pType == 2 then
				return getPickupWeapon(element)
			elseif pType == 3 then
				return "Custom"
			end
		end,
	},
	radararea = {
		sizeX = function(element)
			local sizeX = getRadarAreaSize(element)
			return sizeX
		end,
		sizeY = function(element)
			local _,sizeY = getRadarAreaSize(element)
			return sizeY
		end,
		posX = function(element)
			local posX = getElementPosition(element)
			return posX
		end,
		posY = function(element)
			local _,posY = getElementPosition(element)
			return posY
		end,
		color = function(element)
			local r,g,b,a = getRadarAreaColor(element)
			return getStringFromColor(r,g,b,a)
		end,
	},
	blip = {
		color = function(element)
			local r,g,b,a = getBlipColor(element)
			return getStringFromColor(r,g,b,a)
		end,
		size = getBlipSize,
		icon = getBlipIcon,
	},
	water = {
		sizeX = function(element)
			local x1 = getWaterVertexPosition ( element, 1 )
			local x2 = getWaterVertexPosition ( element, 2 )
			return x2 - x1
		end,
		sizeY = function(element)
			local _,y1 = getWaterVertexPosition ( element, 2 )
			local _,y2 = getWaterVertexPosition ( element, 3 )
			return y2 - y1
		end,
	}
}

propertySetters = {
	object = {
		model = setElementModel,
		doublesided = function(element,bon)
			if setElementDoubleSided then
				return setElementDoubleSided(element,bon=="true")
			else
				return setElementData(element,"doublesided",bon=="true" and "true" or "false")
			end
		end,
		scale = function(element, scale)
			if ( scale ) then
				return setObjectScale(element, scale)
			end
			return false
		end,
		breakable = function(element, breakable)
			if setObjectBreakable then
				return setObjectBreakable(element, breakable == "true")
			else
				return setElementData(element, "breakable", breakable == "true" and "true" or "false")
			end
		end,
		collisions = function(element, state)
			return setElementData(element, "collisions", state == "false" and "false" or "true")
		end
	},
	ped = {
		model = setElementModel,
		rotZ = setPedRotation,
		frozen = function(element, state)
			return setElementFrozen(element, state == "true")
		end,
		collisions = function(element, state)
			return setElementData(element, "collisions", state == "false" and "false" or "true")
		end,
		health = setElementHealth,
		armor = setPedArmor
	},
	vehicle = {
		model = setElementModel,
		color1 = function(element, colorsTable)
			if colorsTable then
				colorsTable = {getColorFromString(colorsTable)}
				local otherColors = {getVehicleColor(element, true)}
				return setVehicleColor(element, colorsTable[1], colorsTable[2], colorsTable[3], otherColors[4], otherColors[5], otherColors[6], otherColors[7], otherColors[8], otherColors[9], otherColors[10], otherColors[11], otherColors[12])
			else
				return false
			end
		end,
		color2 = function(element, colorsTable)
			if colorsTable then
				colorsTable = {getColorFromString(colorsTable)}
				local otherColors = {getVehicleColor(element, true)}
				return setVehicleColor(element, otherColors[1], otherColors[2], otherColors[3], colorsTable[1], colorsTable[2], colorsTable[3], otherColors[7], otherColors[8], otherColors[9], otherColors[10], otherColors[11], otherColors[12])
			else
				return false
			end
		end,
		color3 = function(element, colorsTable)
			if colorsTable then
				colorsTable = {getColorFromString(colorsTable)}
				local otherColors = {getVehicleColor(element, true)}
				return setVehicleColor(element, colorsTable[1], colorsTable[2], colorsTable[3], otherColors[4], otherColors[5], otherColors[6], colorsTable[1], colorsTable[2], colorsTable[3], otherColors[10], otherColors[11], otherColors[12])
			else
				return false
			end
		end,
		color4 = function(element, colorsTable)
			if colorsTable then
				colorsTable = {getColorFromString(colorsTable)}
				local otherColors = {getVehicleColor(element, true)}
				return setVehicleColor(element, colorsTable[1], colorsTable[2], colorsTable[3], otherColors[4], otherColors[5], otherColors[6], otherColors[7], otherColors[8], otherColors[9], colorsTable[1], colorsTable[2], colorsTable[3])
			else
				return false
			end
		end,
		upgrades = function(element, upgradesTable)
			for slot = 0, 16 do
				local upgrade = getVehicleUpgradeOnSlot ( element, slot )
				if upgrade then
					removeVehicleUpgrade( element, upgrade )
				end
			end
			for i, upgrade in ipairs(upgradesTable) do
				addVehicleUpgrade(element, upgrade)
			end
			return true
		end,
		paintjob = setVehiclePaintjob,
		plate = setVehiclePlateText,
		sirens = function(vehicle, bon)
			return setVehicleSirensOn(vehicle, bon == "true" and true or false)
		end,
		health = setElementHealth,
		frozen = function(element, state)
			return setElementFrozen(element, state == "true")
		end,
		collisions = function(element, state)
			return setElementData(element, "collisions", state == "false" and "false" or "true")
		end,
		locked = function(element, state)
			return setVehicleLocked(element, state == "true")
		end,
		landingGearDown = function(element, state)
			return setVehicleLandingGearDown(element, state == "true")
		end
	},
	marker = {
		type = setMarkerType,
		size = setMarkerSize,
		color = function(element, color)
			return setMarkerColor(element, getColorFromString(color))
		end,
	},
	pickup = {
		type = function(element, pType)
			local nType
			local amount = getPickupAmount(element)
			if pType == "health" then
				return setPickupType(element, 0, amount)
			elseif pType == "armor" then
				return setPickupType(element, 1, amount)
			elseif pType == "custom" then
				return setPickupType(element, 3)
			else
				return setPickupType(element, 2, pType, amount)
			end
		end,
	},
	radararea = {
		sizeX = function(element, sizeX)
			local _, currentY = getRadarAreaSize(element)
			return setRadarAreaSize(element, sizeX, currentY)
		end,
		sizeY = function(element, sizeY)
			local currentX = getRadarAreaSize(element)
			return setRadarAreaSize(element, currentX, sizeY)
		end,
		posX = function(element, posX)
			local _, currentY = getElementPosition(element)
			return setElementPosition(element, posX, currentY, 0)
		end,
		posY = function(element, posY)
			local currentX = getElementPosition(element)
			return setElementPosition(element, currentX, posY, 0)
		end,
		color = function(element, colorstr)
			local r, g, b, a = getColorFromString(colorstr)
			return setRadarAreaColor(element, r, g, b, a)
		end,
	},
	blip = {
		color = function(element, colorstr)
			local r, g, b, a = getColorFromString(colorstr)
			return setBlipColor(element, r, g, b, a)
		end,
		size = setBlipSize,
		icon = setBlipIcon,
	},
}

