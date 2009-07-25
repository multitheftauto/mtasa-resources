local hand
local briefcase

function showVolatilityMeter()
outputDebugString("creating vehicle gui")
	local x, y = guiGetScreenSize()
	local poxX, posY = .7*x, .3*y
	hand = guiCreateStaticImage(poxX, poxY, 150, 150, "hand_icon.png", false)
end

function hideVolatilityMeter()
outputDebugString("destroying vehicle gui")
	destroyElement(hand)
	hand = false
end
