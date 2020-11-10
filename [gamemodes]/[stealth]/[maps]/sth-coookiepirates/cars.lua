firstime = 1


function locks()
	local vehicles = getElementsByType("vehicle")
	for i,v in ipairs(vehicles) do
		setVehicleLocked( v, true )
		if (getElementModel(v) == 427 or getElementModel(v) == 427 or getElementModel(v) == 597) then
			setVehicleSirensOn ( v, true )
		end
	end
end

function fix()
	local vehicles = getElementsByType("vehicle")
	if (firstime == 1) then
		firstime = 0
		for i,v in ipairs(vehicles) do
			local x,y,z = getElementPosition(v)
			setElementData(v, "CarX", x)
			setElementData(v, "CarY", y)
			setElementData(v, "CarZ", z)
		end
	end
	for i,v in ipairs(vehicles) do
		fixVehicle(v)
	end
end
function reposvehicle()
	local vehicles = getElementsByType("vehicle")
	for i,v in ipairs(vehicles) do
		local x,y,z = getElementPosition(v)
		setElementData(v, "CarZ", z)
		setElementPosition(v, tonumber(getElementData(v, "CarX")), tonumber(getElementData(v, "CarY")), z)
	end
end
setTimer( reposvehicle, 5000, 0 )
setTimer( locks, 500, 1 )
setTimer( fix, 50, 0 )
