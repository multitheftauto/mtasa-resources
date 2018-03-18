--Modified by Ransom
players = getElementsByType ( "player" )
scoreboardRes = getResourceFromName("scoreboard")

addEventHandler("onResourceStop",getResourceRootElement(getThisResource()),
function()
	call(scoreboardRes,"removeScoreboardColumn","Current level")
	call(scoreboardRes,"removeScoreboardColumn","Max level")
	call(scoreboardRes,"removeScoreboardColumn","Health")
end )

function spawnFunct ( passedPlayer )
	if (not isElement(passedPlayer)) then return false end
	r = 20
	angle = math.random(133, 308) --random angle between 0 and 359.99
	centerX = -12
	centerY = -10
	spawnX = r*math.cos(angle) + centerX --circle trig math
	spawnY = r*math.sin(angle) + centerY --circle trig math
	spawnAngle = 360 - math.deg( math.atan2 ( (centerX - spawnX), (centerY - spawnY) ) )
	spawnPlayer ( passedPlayer, spawnX, spawnY, 3.3, spawnAngle )
end

for k,v in ipairs(players) do --Game start spawn
	spawnFunct ( v )
end

function playerJoin ( )
	fadeCamera ( source, true )
	spawnFunct ( source )
end
addEventHandler ( "onPlayerJoin", root, playerJoin )


function playerWasted ( )
	setTimer ( spawnFunct, 3000, 1, source )
end
addEventHandler ( "onPlayerWasted", root, playerWasted )

-- To do:
-- * Dynamic circle spawn
-- Options:
local options = {
	x = 4,
	y = 4,
	--z = 49, -- +1
	z = get("levels") - 1, -- +1
	--b = 245,
	b = get("blocks"),
	r = 4
}
-- Don't touch below!
local matrix = {}
local objects = {}
local moving = {}
local xy_speed
local z_speed
local barrier_x
local barrier_y
local barrier_r

function move ()
	--outputDebugString("move entered")
	local rand
	repeat
		rand = math.random( 1, options.b )
	until (moving[rand] ~= 1)
	local object = objects[ rand ]
	local move = math.random( 0, 5 )
	--outputDebugString("move: " .. move)
	local x,y,z
	local x2,y2,z2 = getElementPosition ( object )
	--Purge old player positions
	for x = 1,options.x do
		for y = 1,options.y do
			for z = 1,options.z do
				if (matrix[x][y][z] == 2) then
					matrix[x][y][z] = 0
				end
			end
		end
	end
	--Fill in new player positions
	local players = getElementsByType( "player" )
	for k,v in ipairs(players) do
		x,y,z = getElementPosition( v )
		x = math.floor(x / -4 + 0.5)
		y = math.floor(y / -4 + 0.5)
		z = math.floor(z / 3 + 0.5)
		if (x >= 1) and (x <= options.x) and (y >= 1) and (y <= options.y) and (z >= 1) and (z <= options.z) and (matrix[x][y][z] == 0) then
			matrix[x][y][z] = 2
		end
	end
	x = x2 / -4
	y = y2 / -4
	z = z2 / 3
	if (move == 0)  and (x ~= 1) and (matrix[x-1][y][z] == 0) then
		moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (done, s, 1, rand, x, y, z)
		x = x - 1
		matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2 + 4, y2, z2, 0, 0, 0 )
	elseif (move == 1) and (x ~= options.x) and (matrix[x+1][y][z] == 0) then
		moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (done, s, 1, rand, x, y, z)
		x = x + 1
		matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2 - 4, y2, z2, 0, 0, 0 )
	elseif (move == 2) and (y ~= 1) and (matrix[x][y-1][z] == 0) then
		moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (done, s, 1, rand, x, y, z)
		y = y - 1
		matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2 + 4, z2, 0, 0, 0 )
	elseif (move == 3) and (y ~= options.y) and (matrix[x][y+1][z] == 0) then
		moving[rand] = 1
		local s = 4000 - xy_speed * z
		setTimer (done, s, 1, rand, x, y, z)
		y = y + 1
		matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2 - 4, z2, 0, 0, 0 )
	elseif (move == 4) and (z ~= 1) and (matrix[x][y][z-1] == 0) then
		moving[rand] = 1
		local s = 3000 - z_speed * z
		setTimer (done, s, 1, rand, x, y, z)
		z = z - 1
		matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2, z2 - 3, 0, 0, 0 )
	elseif (move == 5) and (z ~= options.z) and ((matrix[x][y][z+1] == 0) or ((z ~= options.z-1) and (matrix[x][y][z+1] == 2) and (matrix[x][y][z+2] ~= 1))) then
		moving[rand] = 1
		local s = 3000 - z_speed * z
		setTimer (done, s, 1, rand, x, y, z)
		z = z + 1
		matrix[x][y][z] = 1
		--outputDebugString("moving obj")
		moveObject ( object, s, x2, y2, z2 + 3, 0, 0, 0 )
	end
	--	setTimer ("move", 100 )
end

function onThisResourceStart ( )
	call(scoreboardRes,"addScoreboardColumn","Current level")
	call(scoreboardRes,"addScoreboardColumn","Max level")
	call(scoreboardRes,"addScoreboardColumn","Health")
	--outputChatBox("* Haystack-em-up v1.44 by Aeron", root, 255, 100, 100)  --PFF meta is good enough :P
	--Calculate speed velocity
	xy_speed = 2000 / (options.z + 1)
	z_speed = 1500 / (options.z + 1)

	--Clean matrix
	for x = 1,options.x do
		matrix[x] = {}
		for y = 1,options.y do
			matrix[x][y] = {}
			for z = 1,options.z do
				matrix[x][y][z] = 0
			end
		end
	end

    --Place number of haybails in matrix
	local x,y,z
	for count = 1,options.b do
		repeat
			x = math.random ( 1, options.x )
			y = math.random ( 1, options.y )
			z = math.random ( 1, options.z )
		until (matrix[x][y][z] == 0)
		matrix[x][y][z] = 1
		objects[count] = createObject ( 3374, x * -4, y * -4, z * 3 ) --, math.random ( 0, 3 ) * 90, math.random ( 0, 1 ) * 180 , math.random ( 0, 1 ) * 180 )
	end

	--Place number of rocks in matrix
	for count = 1,options.r do
		repeat
			x = math.random ( 1, options.x )
			y = math.random ( 1, options.y )
			z = math.random ( 1, options.z )
		until (matrix[x][y][z] == 0)
		matrix[x][y][z] = 1
		createObject ( 1305, x * -4, y * -4, z * 3, math.random ( 0, 359 ), math.random ( 0, 359 ), math.random ( 0, 359 ) )
	end

	--Calculate tower center and barrier radius
	barrier_x = (options.x + 1) * -2
	barrier_y = (options.y + 1) * -2
	if (options.x > options.y) then
		barrier_r = options.x / 2 + 20
	else
		barrier_r = options.y / 2 + 20
	end

	--Place top-haybail + minigun
	createObject ( 3374, barrier_x, barrier_y, options.z * 3 + 3 )
	thePickup = createPickup ( barrier_x, barrier_y, options.z * 3 + 6, 3, 2880, 1 )
	setTimer ( move, 100, 0 )
	setTimer ( barrier, 1000, 1)
	fadeCamera ( getRootElement(), true )
end

function barrier ()
	local barrier = createColCircle ( barrier_x, barrier_y, barrier_r )
	addEventHandler ( "onColShapeLeave", barrier, function ( p )
		if ( getElementType ( p ) == "player" ) then
			killPed ( p )
			outputChatBox( "* Killed: Don't walk away.", p, 255, 100, 100 )
			end
		end )
end

function onPickupHit ( player )
	if source == thePickup then
		outputChatBox( "* " .. getPlayerName ( player ) .. " made it to the top!", root, 255, 100, 100, false )
		toggleControl ( player, "fire", true )
		destroyElement( source )
	end
end

function done ( id, x, y, z )
	moving[id] = 0
	matrix[x][y][z] = 0
end

--addEventHandler( "onResourceStart", root, function() onMapLoad() end)
--addEventHandler( "onPickupHit", root, function() onPickupHit() end)
--addEventHandler( "onPlayerJoin", root, function() onPlayerJoin() end)

addEventHandler( "onResourceStart", getResourceRootElement(getThisResource()), onThisResourceStart)
addEventHandler( "onPickupHit", root, onPickupHit)
