
--TRIGGERS THE CLOAKING CLIENT FUNCTIONS
addEvent ("cloaktheplayer", true )

function cloakstart(thisplayer)
	setElementData ( thisplayer, "stealthmode", "on" )
	playSoundFrontEnd ( thisplayer, 34 )
	setElementAlpha ( thisplayer, 10 )
end

addEventHandler("cloaktheplayer",root,cloakstart)

--TRIGGERS THE UNCLOAKING CLIENT FUNCTIONS
addEvent ("uncloaktheplayer", true )

function cloakstop(thisplayer)
	if (cloakoff) then
		killTimer (cloakoff)
		cloakoff= nil
	end
	setElementData ( thisplayer, "stealthmode", "off" )
	playSoundFrontEnd ( thisplayer, 35 )
	setElementAlpha ( thisplayer, 255 )
end
addEventHandler("uncloaktheplayer",root,cloakstop)


--GOGGLES

addEvent ("goggleswap", true )

function changegoggles(player)
	local currentgoggles = getPedWeapon ( player, 11 )
	if currentgoggles == 44 then
		giveWeapon ( player, 45, 1 )
		outputChatBox("Infrared.",player, 255, 69, 0)
	elseif currentgoggles == 45 then
		giveWeapon ( player, 44, 1 )
		outputChatBox("Nightvision.",player, 255, 69, 0)
	end
end

addEventHandler("goggleswap",root,changegoggles)


--PROXY MINES

--LAYS THE MINE AND SETS THE COL

addEvent ("poopoutthemine", true )

function laymine(player)
	local posx, posy, posz = getElementPosition ( player )
	local landmine = createObject ( 1510, posx, posy, posz - .999, 0, 0, 3.18 )
	local landminecol = createColSphere ( posx, posy, posz, 3 )
	setElementData ( landminecol, "type", "alandmine" )
	setElementData ( landminecol, "owner", player )
	setElementData ( landmine, "type", "proximity" )
	setElementParent ( landmine, landminecol )
end

addEventHandler("poopoutthemine",root,laymine)

--DETECTS THE HIT
function landminehit ( player, matchingDimension )
	if ( getElementData ( source, "type" ) == "alandmine" ) then
		if ( getElementData ( player, "stealthmode" ) ~= "on" ) then
			local mineowner = getElementData ( source, "owner" )
			local ownersteam = getPlayerTeam ( mineowner )
			local victimteam = getPlayerTeam ( player )
			if ownersteam ~= victimteam then --IS THIS PLAYER ON THE SAME TEAM AS THE GUY WHO PUT IT THERE?
				local posx, posy, posz = getElementPosition ( source )
				createExplosion (posx, posy, posz, 8, mineowner )
				setElementData ( source, "type", nil )
				destroyElement ( source )
			end
		end
	end
end

addEventHandler ( "onColShapeHit", root, landminehit )


--KILLS THE MINE WHEN SHOT

addEvent ("destroylandmine", true )

function destroymine(hitElement)
	if (hitElement) then
		local damagedmine = getElementParent ( hitElement )
		destroyElement ( damagedmine )
	end
end

addEventHandler("destroylandmine",root,destroymine)


--SPYCAMERA

addEvent ("placethecam", true )

function dropcamera(player)
	local playerrot = getPedRotation ( player )
	local rot = playerrot-180
	triggerClientEvent(player,"findcamerapos",root,rot )
end

addEventHandler("placethecam",root,dropcamera)


addEvent ("cameraobject", true )

function placecamball(x, y, z, player)
	local camball = createObject ( 3106, x, y, z )
	local camcol = createColSphere ( x, y, z, 1 )
	setElementData ( camcol, "camowner", player )
	setElementData ( camcol, "type", "acamera" )
	setElementParent ( camball, camcol )
end

addEventHandler("cameraobject",root,placecamball)

addEvent ("killcameraobject", true )

function removecamball(player)
	coltable = getElementsByType ( "colshape" )
	for theKey,thecol in ipairs(coltable) do
		if getElementData ( thecol, "camowner" ) == player then
			setElementData ( thecol, "type", nil )
			destroyElement ( thecol )
		end
	end
end

addEventHandler("killcameraobject",root,removecamball)


--SHIELD

addEvent ("shieldup", true )

function maketheshield (player)
	local x, y, z = getElementPosition( player )
	shield = createObject ( 1631, x, y, z, 0, 0, 0 )
	setElementData ( shield, "type", "ashield" )
	if isPedDucked ( player ) then
		attachElements( shield, player, .2, .5, -.6, 0, 90, 0 )
	else
		giveWeapon ( player, 0, 0, true )
		attachElements( shield, player, .2, .5, .2 )
	end
end

addEventHandler("shieldup", root , maketheshield)


addEvent ("shielddown", true )

function killtheshield (player, currentweapon )
	stuckstuff = getAttachedElements ( player )
	for ElementKey, ElementValue in ipairs(stuckstuff) do
		if ( getElementData ( ElementValue, "type" ) == "ashield" ) then
			theshield = ElementValue
		end
	end
	destroyElement ( theshield )
	giveWeapon ( player, currentweapon, 0, true )
end

addEventHandler("shielddown", root , killtheshield)
