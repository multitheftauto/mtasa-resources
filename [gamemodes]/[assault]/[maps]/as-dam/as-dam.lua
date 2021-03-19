local bombs = {}

function startRound( attack )
	attacker = attack
end

-- This is called by assault (through an event) and creates the custom objectives (leave quarry and reach dam)
function create(objective)
	if (objective.id == "leave") then
		local col = createColCircle(objective.posX,objective.posY,217)
		addEventHandler("onColShapeLeave",col,quarryLeft)
	elseif (objective.id == "dam") then
		local col = createColCircle(objective.posX,objective.posY,351)
		damBlip = createBlip(objective.posX,objective.posY,objective.posZ,0,2,255,128,64)
		addEventHandler("onColShapeHit",col,damHit)
	end
end

-- When the quarry was left..
function quarryLeft( player )
	if (getElementType(player) ~= "player") then return end
	local team  = getPlayerTeam( player )
	if (team == attacker) then
		call(getResourceFromName("assault"),"triggerObjective","leave")
		destroyElement(source)
	end
end

-- When the dam was reached..
function damHit( player )
	if (getElementType(player) ~= "player") then return end
	local team  = getPlayerTeam( player )
	if (team == attacker) then
		call(getResourceFromName("assault"),"triggerObjective","dam")
		destroyElement(damBlip)
		destroyElement(source)
	end
end

-- Destroy bombs and start explosions, if the attackers were successful
function endRound( conquered )
	for i, v in pairs ( bombs ) do
		destroyBomb ( i )
	end

	if (conquered == false) then return end
	setTimer(explosions,1000,1)


end

function explosions()
	setTimer(createExplosion,300,1,-607.230408,1924.516479,6.000000,10)
	setTimer(createExplosion,300,1,-607.230408,1924.516479,6.000000,1)

	setTimer(createExplosion,600,1,-613.370,1905.743,7,10)
	setTimer(createExplosion,600,1,-613.370,1905.743,7,1)

	setTimer(createExplosion,900,1,-619.370,1881.743,7,10)
	setTimer(createExplosion,900,1,-619.370,1881.743,7,1)

	setTimer(createExplosion,1200,1,-626.370,1860.743,7,7)
	setTimer(createExplosion,1200,1,-626.370,1860.743,7,1)

	setTimer(createExplosion,1300,1,-629.370,1842.743,7,7)
	setTimer(createExplosion,1300,1,-629.370,1842.743,7,1)

	setTimer(createExplosion,100,1,-830.455383,1973.126587,6.000008,10)
	setTimer(createExplosion,100,1,-830.455383,1973.126587,6.000008,1)

	setTimer(createExplosion,300,1,-783.043030,2147.322998,59.382813,10)
	setTimer(createExplosion,300,1,-783.043030,2147.322998,59.382813,1)
end

-- Plant bombs
function objectiveReached(obj, players)
	if (obj.id == "bomb1" or obj.id == "bomb2" or obj.id == "bomb3") then
		placeBomb(obj,players)
	end
end

function placeBomb ( obj, players )
	local bomb = getElementByID ( obj.id )
	local ID = obj.id
	local x, y, z = getElementData ( bomb, "bombPosX" ), getElementData ( bomb, "bombPosY" ), getElementData ( bomb, "bombPosZ" )
	local rx, ry, rz = getElementData ( bomb, "bombRotX" ), getElementData ( bomb, "bombRotY" ), getElementData ( bomb, "bombRotZ" )
	local bombglow = createMarker ( x, y, z, "corona", 1, 255, 255, 200, 80 )
	bombs[ID] = createObject ( 1654, x, y, z, rx, ry, rz )

	setElementData ( bombs[ID], "bombglow", bombglow )
	if ( players ) then
		for i, v in ipairs ( players ) do
			setTimer ( playSoundFrontEnd, 200, 1, v, 5 )
			setTimer ( playSoundFrontEnd, 360, 1, v, 5 )
		end
	end
end
-- Destroy bomb
function destroyBomb ( ID )
	--local ID = obj.id
	--outputChatBox("destroying......: "..ID)
	if (bombs[ID] == nil) then return end
	local bombglow = getElementData ( bombs[ID], "bombglow" )
	if (isElement(bombglow)) then destroyElement ( bombglow ) end
	if (isElement(bombs[ID])) then destroyElement ( bombs[ID] ) end
	bombs[ID] = nil
end

addEventHandler("onAssaultCreateObjective",getRootElement(),create)
addEventHandler("onAssaultObjectiveReached",getRootElement(),objectiveReached)
addEventHandler("onAssaultStartRound",getRootElement(),startRound)
addEventHandler("onAssaultEndRound",getRootElement(),endRound)

