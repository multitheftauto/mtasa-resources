
function openSilo(objective)
	if (objective.id == "silo") then
		local objects = getElementsByType("object")
		local roof = nil
		for k,v in ipairs(objects) do
			if (getElementData(v,"name") == "roof") then
				roof = v
			end
		end
		moveObject(roof,10000, 293.268707, 1876.698120, 14.849337, 0, 0, 0 )
	end
end

function closeSilo()
	local objects = getElementsByType("object")
		local roof = nil
		for k,v in ipairs(objects) do
			if (getElementData(v,"name") == "roof") then
				roof = v
			end
		end
		local posX = getElementData(roof,"posX")
		local posY = getElementData(roof,"posY")
		local posZ = getElementData(roof,"posZ")
		local rotX = getElementData(roof,"rotX")
		local rotY = getElementData(roof,"rotY")
		local rotZ = getElementData(roof,"rotZ")
		setTimer(moveObject,100,1,roof,1000, posX, posY, posZ, 0, 0, 0 )
end

addEventHandler("onAssaultObjectiveReached",getRootElement(),openSilo)
addEventHandler("onAssaultStartRound",getRootElement(),closeSilo)
