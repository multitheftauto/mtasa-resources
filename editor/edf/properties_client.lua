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
			return {getMarkerColor(element)}
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
			return {getRadarAreaColor(element)}
		end,
	},
	blip = {
		color = function(element)
			return {getBlipColor(element)}
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
		model = function(element, model)
			if model then return setElementModel(element, model)
			else return false end
		end,
	},
	ped = {
		model = function(element, model)
			if model then return setElementModel(element, model)
			else return false end
		end,
		rotZ = function(element, rot) 
			if tonumber(rot) then return setPedRotation(element,rot)
			else return false end
		end,
	},
	vehicle = {
		model = function(element, model)
			if model then return setElementModel(element, model)
			else return false end
		end,
		color = function(element, colorsTable)
			if colorsTable then return setVehicleColor(element, unpack(colorsTable))
			else return false end
		end,
		upgrades = function(element, upgradesTable)
			if upgradesTable then
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
			else
				return false
			end
		end,
		paintjob = setVehiclePaintjob
	},
	marker = {
		type = function(element, markerType)
			if markerType then return setMarkerType(element, markerType)
			else return false end
		end,
		size = function(element, markerSize)
			if markerSize then return setMarkerSize(element, markerSize)
			else return false end
		end,
		color = function(element, color)
			if color then return setMarkerColor(element, getColorFromString(color))
			else return false end
		end,
	},
	pickup = {
		type = function(element, pType)
			if pType then
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
			else
				return false
			end
		end,
		amount = function(element, amount)
			if amount then return setElementData(element, "edf:p:amount", amount)
			else return false end
		end,
		respawn = function(element, respawn)
			if respawn then return setElementData(element, "edf:p:respawn", respawn)
			else return false end
		end,
	},
	radararea = {
		sizeX = function(element, sizeX)
			if sizeX then
				local _, currentY = getRadarAreaSize(element)
				return setRadarAreaSize(element, sizeX, currentY)
			else
				return false
			end
		end,
		sizeY = function(element, sizeY)
			if sizeY then
				local currentX = getRadarAreaSize(element)
				return setRadarAreaSize(element, currentX, sizeY)
			else
				return false
			end
		end,
		posX = function(element, posX)
			if posX then
				local _, currentY = getElementPosition(element)
				return setElementPosition(element, posX, currentY, 0)
			else
				return false
			end
		end,
		posY = function(element, posY)
			if posY then
				local currentX = getElementPosition(element)
				return setElementPosition(element, currentX, posY, 0)
			else
				return false
			end
		end,
		color = function(element, colorstr)
			if colorstr then
				local r, g, b, a = getColorFromString(colorstr)
				return setRadarAreaColor(element, r, g, b, a)
			else
				return false
			end
		end,
	},
	blip = {
		color = function(element, colorstr)
			if colorstr then
				local r, g, b, a = getColorFromString(colorstr)
				return setBlipColor(element, r, g, b, a)
			else
				return false
			end
		end,
		size = function(element, blipSize)
			if blipSize then return setBlipSize(element, blipSize)
			else return false end
		end,
		icon = function(element, blipIcon)
			if blipIcon then return setBlipIcon(element, blipIcon)
			else return false end
		end,
	},
}
