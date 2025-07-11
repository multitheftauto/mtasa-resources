local attachPlayersEnabled = false


function getCameraRotation ()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local rotz = 6.2831853071796 - math.atan2 ( ( lx - px ), ( ly - py ) ) % 6.2831853071796
	local rotx = math.atan2 ( lz - pz, getDistanceBetweenPoints2D ( lx, ly, px, py ) )
	--Convert to degrees
	rotx = math.deg(rotx)
	rotz = math.deg(rotz)

	return rotx, 180, rotz
end

local function attachRender()
	--Attach the local player
	local camX,camY,camZ = getCameraMatrix()
	setElementPosition ( localPlayer, camX,camY,camZ )
	if #getElementsByType"player" > 1 then
		velocityX,velocityY,velocityZ = freecam.getFreecamVelocity()
		if velocityX and velocityY and velocityZ then
			setElementVelocity ( localPlayer, velocityX,velocityY,velocityZ )
		end
	else
		setElementVelocity(localPlayer, 0,0,0)
	end
	local x,y,z = getCameraRotation()
	setPedRotation ( localPlayer, (-z)%360 )
	setElementRotation ( localPlayer, (-x),0,(-z)%360 )
	setElementCollisionsEnabled(localPlayer,true)
	setElementCollisionsEnabled(localPlayer,false)
end

function attachPlayers(enabled)
	if attachPlayersEnabled == enabled then return false end
	attachPlayersEnabled = enabled
	if enabled then
		for i,player in ipairs(getElementsByType"player") do
			-- if player ~= localPlayer then
				-- setPlayerFlying(player,true)
			-- end
			setElementCollisionsEnabled(player,false)
		end
		setElementAlpha(localPlayer,0)
		return addEventHandler ( "onClientRender", root, attachRender )
	else
		for i,player in ipairs(getElementsByType"player") do
			-- if player ~= localPlayer then
				-- setPlayerFlying(player,false)
			-- end
			setElementCollisionsEnabled(player,true)
		end
		setElementAlpha(localPlayer,255)
		return removeEventHandler ( "onClientRender", root, attachRender )
	end
end

addEventHandler ( "onClientPlayerSpawn", root,
	function()
		if attachPlayersEnabled then
			setElementCollisionsEnabled(source,false)
			-- if source ~= localPlayer then
				-- setPlayerFlying(source,true)
			-- end
		end
	end
)

