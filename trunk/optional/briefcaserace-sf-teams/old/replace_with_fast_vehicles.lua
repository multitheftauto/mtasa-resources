local fastCars = {429, 541, 415, 480, 562, 565, 434, --[[494,]] --[[502, 503,]] 411, 559, 561, 560, 506, 451, 558, --[[555,]] 477, 402, 603, 596, 597}
local fastBikes = {581, 522, 461, 521, 468}

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
function (resource)
	setAllVehiclesOfTypeToRandom("Automobile", fastCars, false)
	setAllVehiclesOfTypeToRandom("Monster Truck", fastCars, false)
	setAllVehiclesOfTypeToRandom("Bike", fastBikes, false)
	setAllVehiclesOfTypeToRandom("Quad", fastBikes, false)
end
)

function setAllVehiclesOfTypeToRandom(vehType, modelArray, dontReplaceIfInModelArray)
	local allVehicles = getElementsByType("vehicle")
	local arraySize = #modelArray
	for i,vehicle in ipairs(allVehicles) do
		if (getVehicleType(vehicle) == vehType) then
			local skip = false
			if (dontReplaceIfInModelArray) then
				skip = isVehicleInModelArray(vehicle, modelArray)
			end
			if (not skip) then
				local num = math.random(1, arraySize)
				setElementModel(vehicle, modelArray[num])
			end
		end
	end
end

function isVehicleInModelArray(vehicle, modelArray)
	local yes = false
	local theModel = getElementModel(vehicle)
	for j,model in ipairs(modelArray) do
		if (model == theModel) then
			yes = true
			break
		end
	end
	return yes
end
