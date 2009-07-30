local hand
local briefcase
local screenX, screenY
local handX, handY, bcX, bcY
local updateMeterTimer
local scale1Max = 500 -- below a damage required to drop (DTD) of 500, bc lowers alpha
local scale2Max = 200 -- below a damage required to drop (DTD) of 200, bc moves down the screen
local curDTD

function showVolatilityMeter()
outputDebugString("creating vehicle gui")
	screenX, screenY = guiGetScreenSize()
	handX, handY = math.ceil(.9*screenX), math.ceil(.25*screenY)
	bcX, bcY = handX, math.ceil(.3*screenY)
	--outputChatBox(posX .. " '' " .. posY)
	hand = guiCreateStaticImage(handX, handY, 85, 85, "hand_icon.png", false)
	briefcase = guiCreateStaticImage(bcX, bcY, 85, 85, "briefcase_icon.png", false)
	--hand = guiCreateStaticImage(0.5, 0.5, 0.2, 0.2, "hand_icon.png", true)
	--hand = guiCreateStaticImage(500, 500, 150, 150, "hand_icon.png", false)
	--maxLTD = getDropLossFromHealth(getPedOccupiedVehicle(getLocalPlayer()), 1000)
	curDTD = -1
	updateMeter()
	updateMeterTimer = setTimer(updateMeter, 500, 0)
end

function hideVolatilityMeter()
outputDebugString("destroying vehicle gui")
	destroyElement(hand)
	hand = false
	destroyElement(briefcase)
	briefcase = false
	killTimer(updateMeterTimer)
	updateMeterTimer = nil
end

function updateMeter()
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if (vehicle) then
		local damageToDrop = getDropLossFromHealth(vehicle, getElementHealth(vehicle))
		if (damageToDrop ~= curDTD) then
			outputConsole("dtd: " .. damageToDrop)
			curDTD = damageToDrop
			if (curDTD > scale2Max) then
				guiSetPosition(briefcase, bcX, bcY, false)
				local ratio = curDTD/scale1Max -- --1 - 500+, 0 - 200
				if (ratio > 1) then
					ratio  = 1
				end
				local alpha = ratio
				guiSetAlpha(briefcase, alpha)
			else
				guiSetAlpha(briefcase, scale2Max/scale1Max)
				local ratio = curDTD/scale2Max -- 1 - 200+, 0 - 0
				if (ratio > 1) then
					ratio  = 1
				end
				-- at 1000 health bc is at 0.3*screenY
				-- at 250 health, bc is at 0.9*screenY
				local addAmount = math.ceil((1-ratio)*(0.95-0.3)*screenY)
				local newY = bcY + math.ceil(addAmount)
				guiSetPosition(briefcase, bcX, newY, false)
			end
		end
	end
end
