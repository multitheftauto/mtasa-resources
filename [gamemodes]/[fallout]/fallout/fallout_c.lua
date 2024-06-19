fadeCamera(true)
local shakeState = false
local shakingPieces = {}

function shakeOnRender()
	local currentTick = getTickCount()
	for object, originalTick in pairs(shakingPieces) do
		local tickDifference = currentTick - originalTick
		if tickDifference > 2400 or not isElement(object) then
			shakingPieces[object] = nil
		else
			--since newx/newy increases by 1 every 125ms, we can use this ratio to calculate a more accurate time
			local newx = tickDifference / 125 * 1
			local newy = tickDifference / 125 * 1
			setElementRotation(object, math.deg(0.555), 3 * math.cos(newy + 1), 3 * math.sin(newx + 1))
		end
	end
	if not next(shakingPieces) and shakeState then
		removeEventHandler("onClientRender", root, shakeOnRender)
		shakeState = false
	end
end


addEvent("onClientShakePieces", true)
addEventHandler("onClientShakePieces", resourceRoot,
function ()
	-- we store the time when the piece was told to shake under a table, so multiple objects can be stored
	shakingPieces[source] = getTickCount()
	if not shakeState then
		addEventHandler("onClientRender", root, shakeOnRender)
		shakeState = true
	end
end, true)