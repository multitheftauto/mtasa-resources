setTimer ( setTime, 60000, 1, 12, 00 )

function cancelSharkDamage  ( attacker, weapon, bodypart )
	if weapon == 53 and attacker == getLocalPlayer() and getElementModel(getLocalPlayer()) == 124 then
		cancelEvent()
	end
end
addEventHandler ( "onClientPlayerDamage", getLocalPlayer(), cancelSharkDamage )

function setupSpawn  ()
	--outputChatBox ( "called for "..getPlayerName ( source ) )
	if ( getElementModel(getLocalPlayer()) == 124 ) then
		for k,v in pairs(getTimers()) do
			if eatTimer == v then
				killTimer ( v )
			end
		end
		setPlayerHudComponentVisible ( "breath", false )
		setTimer ( toggleControl, 1000, 1, "jump", false )
		setElementAlpha( getLocalPlayer(), 0 )
		--lol = toggleControl ( "jump", false )
		--outputChatBox ( "Jump disabled? "..tostring(lol) )
		setGameSpeed ( 1.5 )
	else
		for k,v in pairs(getTimers()) do
			if eatTimer == v then
				killTimer ( v )
			end
		end
		eatTimer = setTimer ( isBeingEaten, 200, 0 )
		setPlayerHudComponentVisible ( "breath", true )
		setElementAlpha( getLocalPlayer(), 255 )
		toggleControl ( "jump", true )
		setGameSpeed ( 1 )
	end
end
addEventHandler ( "onClientPlayerSpawn", getLocalPlayer(), setupSpawn )

function getSharkMouthPosition(player)
	local rot = math.rad ( getPedRotation(player) )
	local x,y,z = getElementPosition ( player )
	sharkOffset = 5
	local tx = x + -sharkOffset * math.sin(rot)
	local ty = y + sharkOffset * math.cos(rot)
	return tx,ty,z
end

function isBeingEaten()
	local x,y,z = getElementPosition ( getLocalPlayer() )
	for k,player in pairs(getElementsByType("player")) do
		if getElementModel ( player ) == 124 then
			local sx,sy,sz = getSharkMouthPosition(player)
			if getDistanceBetweenPoints3D ( x,y,z,sx,sy,sz ) <= 2 then
				local health = getElementHealth ( getLocalPlayer() )
				outputDebugString("Health "..tostring(health))
				if health <= 34 then
					setElementHealth ( getLocalPlayer(),0 )
				else
					setElementHealth ( getLocalPlayer(),health - 34 )
				end
			end
		end
	end
end
---------
---------


function getDistanceBetweenPoints3D ( Ax,Ay,Az,Bx,By,Bz )
	if ( not tonumber(Ax) ) or ( not tonumber(Ay) ) or ( not tonumber(Az) ) or ( not tonumber(Bx) ) or ( not tonumber(By) ) or ( not tonumber(Bz) ) then
		return false
	end
	local dx = Ax-Bx
	local dy = Ay-By
	local dz = Az-Bz
	local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
	return distance
end
