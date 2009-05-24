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
	},
	ped = {
		model = getElementModel,
		rotZ = getPedRotation,
	},
	vehicle = {
		model = getElementModel,
		color = function(element)
			return {getVehicleColor(element)}
		end,
		upgrades = getVehicleUpgrades,
		plate = getVehiclePlateText,
		paintjob = function(vehicle) return tostring(getVehiclePaintjob(vehicle)) end,
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
		amount = function(element)
			return getElementData(element, "edf:p:amount")
		end,
		respawn = function(element)
			return getElementData(element, "edf:p:respawn")
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
	},
	ped = {
		model = setElementModel,
		rotZ = setPedRotation,
	},
	vehicle = {
		model = setElementModel,
		color = function(element, colorsTable)
			return setVehicleColor(element, unpack(colorsTable))
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
		paintjob = setVehiclePaintjob
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
		amount = function(element, amount)
			return setElementData(element, "edf:p:amount", amount)
		end,
		respawn = function(element, respawn)
			return setElementData(element, "edf:p:respawn", respawn)
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

