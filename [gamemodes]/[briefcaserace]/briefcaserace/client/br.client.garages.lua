local GARAGE_USE_PENALTY = 30000 -- number of milliseconds to wait until using the garage again

local garageElements = {}
local lastUseTime = 0
local randomMessages = {	"Hope you like the new paint.",
							"Have a nice day.",
							"Try not to break it next time.",
							"This one's on the house.",
							"Good as new.",
							"Repaired. Painted. And ready for briefcase stealing."
						}
local textLabel
local clearTimer

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
function (resource)
	-- set up garages and stuff
	for i=0,49 do
		setGarageOpen(i, true)
		--local westX, eastX, southY, northY = getGarageBoundingBox(i)
		local posX, posY, posZ = getGaragePosition(i)
		local size1, size2, size3 = getGarageSize(i)
		--outputConsole("Garage " .. i .. ": bounding box = " .. westX .. " " .. eastX .. " " .. southY .. " " .. northY .. ", position = " .. posX .. " " .. posY .. " " .. posZ .. ", size = " .. size1 .. " " .. size2 .. " " .. size3)
		--outputConsole("Garage " .. i .. ": size = " .. size1 .. " " .. size2 .. " " .. size3)
		size1, size2, size3 = 10, 10, 5 -- getGarageSize() returns numbers that are way too big.. so let's make it 10
		-- fixes for problem garages:
		if (i == 18 or i == 19) then -- wang's fender and wang's spray
			posY = posY - 10
		end
		if (i == 21) then -- wang's fender and wang's spray
			size1 = 22
		end
		if (i == 22) then
			size1 = 20
			size2 = 32
		end
		garageElements[i] = {}
		garageElements[i].col = createColCuboid(posX, posY, posZ, size1, size2, size3)
		garageElements[i].blip = createBlip(posX, posY, posZ, 63, 2, 255, 0, 0, 255, 0, 200)
		addEventHandler("onClientColShapeHit", garageElements[i].col, onGarageHit)
		--createMarker(posX, posY, posZ, "checkpoint", 1, 255, 0, 0)
		--createMarker(posX+size1, posY+size2, posZ+size3, "checkpoint", 1, 0, 255, 0)
	end
	-- create text
	textLabel = guiCreateLabel(0.25, 0.25, 0.5, 0.1, "", true)
	guiLabelSetHorizontalAlign(textLabel, "center")
	guiLabelSetColor(textLabel, 255, 255, 0)
	--guiSetFont(textLabel, "clear-normal")
end
)

function onGarageHit(theElement, matchingDimension)
	--outputChatBox("A garage was entered!")
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle and theElement == vehicle) then
		if (getTickCount() - lastUseTime <= GARAGE_USE_PENALTY) then
			-- show text
			local secs = math.ceil((GARAGE_USE_PENALTY-(getTickCount() - lastUseTime))/1000)
			local text
			if (secs > 1) then
				text = "Wait " .. secs .. " seconds."
			else
				text = "Wait 1 second."
			end
			outputConsole(text)
			guiSetText(textLabel, text)
			if (clearTimer) then
				killTimer(clearTimer)
			end
			clearTimer = setTimer(clearLabel, 5000, 1)
		else
			playSoundFrontEnd(46)
			triggerServerEvent("onPlayerGarageEnter", localPlayer, vehicle)
			lastUseTime = getTickCount()
			-- show text
			local text = randomMessages[math.random(1,#randomMessages)]
			outputConsole(text)
			guiSetText(textLabel, text)
			if (clearTimer) then
				killTimer(clearTimer)
			end
			clearTimer = setTimer(clearLabel, 5000, 1)
		end
	end
end

function clearLabel()
	guiSetText(textLabel, "")
	clearTimer = nil
end
