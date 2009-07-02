root = getRootElement ()
players = getElementsByType ( "player" )
connected = 0

function resourceStart ( name )
	if ( name == getThisResource() ) then
	local allMessages = getElementsByType ( "welcome" )
	local randomMessage = math.random(1,#allMessages)
	local varMessageFind = allMessages[randomMessage]
	local varMessage = getElementData ( varMessageFind, "message" )
	outputChatBox ( "" ..varMessage.. "", root, 0, 255, 100 )
	setWeather ( 0 )
	setTime ( 13, 00 )
		for k,v in ipairs(players) do
		spawn_me( v, 2500 )
		end
	end
end

function destroyBlipsAttachedTo(player)
	local attached = getAttachedElements ( player )
	if ( attached ) then
		for k,element in ipairs(attached) do
			if getElementType ( element ) == "blip" then
				destroyElement ( element )
			end
		end
	end
end

function elementAlpha ( source, command, level )
	if ( level ) then
		if ( source ) then
		setElementAlpha ( source, tonumber(level) )
		end
	else
		local alphaLevel = getElementAlpha ( source )
		local player = getPlayerName ( source )
		outputChatBox ( "* " ..player.. "'s Alpha Level: " ..alphalevel )
	end
end

function vehicleExplode ()
	setTimer ( respawnVehicle, 2500, 1, source )
end

-- addCommandHandler ( "output", "outputOnLoad" )
-- function outputOnLoad ( name )
	-- for k,v in getElementsByType ( "vehicle" ) do
	-- local model = getVehicleID ( v )
	-- local id = getVehicleNameFromID ( model )
	-- local x, y, z = getElementPosition ( v )
	-- local rx, ry, rz = getVehicleRotation ( v )
	-- local c1, c2, c3, c4 = getVehicleColor ( v )
    -- outputConsole ( "<vehicle id=\"" .. id .. "\" model=\"" .. model .. "\" posX=\"" .. x .. "\" posY=\"" .. y .. "\" posZ=\"" .. z .. "\" rotX=\"" .. rx .. "\" rotY=\"" .. ry .. "\" rotZ=\"" .. rz .. "\" colors=\"" .. c1 .. "," .. c2 .. "," .. c3 .. "," .. c4 .. "\"/>" )
	-- outputDebugString ( "<vehicle id=\"" .. id .. "\" model=\"" .. model .. "\" posX=\"" .. x .. "\" posY=\"" .. y .. "\" posZ=\"" .. z .. "\" rotX=\"" .. rx .. "\" rotY=\"" .. ry .. "\" rotZ=\"" .. rz .. "\" colors=\"" .. c1 .. "," .. c2 .. "," .. c3 .. "," .. c4 .. "\"/>" )
	-- end
-- end

function playerSpawn ( spawnpoint )
	--TALIDAN STUFFZOR
	local r,g,b = exports.playercolors:getPlayerColor ( r, g, b )
	blip = createBlipAttachedTo ( source, 0, 2, r, g, b, 90 )
end

function setWaveLevel ( source, command, height )
	if ( height ) then
	setWaveHeight ( height )
	else
	wavelevel = getWaveHeight ()
	outputConsole ( "Wave Height: " ..wavelevel )
	end
end

function setLevel ( source, command, levelplayer, level )
	if ( getPlayerName ( source ) == "BrophY" ) then
		local player = getPlayerFromNick ( levelplayer )
		setClientLevel ( player , tonumber ( level ) )
	end
end

function kickPlayer ( player, commandname, kickedname, reason )
	local kicked = getPlayerFromNick ( kickedname )
	if ( getPlayerName ( source ) == "BrophY" ) then
		kickPlayer ( kicked, player, reason )
	end
end

function playerWasted ()
	destroyBlipsAttachedTo ( source )
	spawn_me ( source, 2500 )
end

function playerJoin ()
	spawn_me( source, 1500 )
end

function playerQuit ()
	destroyBlipsAttachedTo ( source )
end

function spawn_me( player, timer )
	setCameraTarget ( player, player )
	setTimer ( spawnThePlayer, timer, 1, player )
end

function spawnThePlayer ( player )
	local b = spawnPlayer ( player, -711+math.random(1,5), 957+math.random(5,9), 12.4, 90, math.random(9,288) )
	if not b then
		spawnThePlayer ( player )
		return
	end
	fadeCamera(player,true)
end

function veh ( source, command, vehid )
	local x,y,z = getElementPosition ( source )
    local car = createVehicle ( tonumber(vehid), tonumber(x), tonumber(y), tonumber(z) )  
    warpPedIntoVehicle ( source, car )
end

function pass ( source, command, player, seat )
	local name = getPlayerFromNick ( player )
	local car = getPedOccupiedVehicle ( name )
	warpPedIntoVehicle ( source, car, seat )
end

function distance ( source, command, player1, player2 )
	if ( not player1 ) then 
		outputChatBox ( "You need to select someone to check your distance!", source, 255, 255, 0 )
	end
	if ( player1 and not player2 ) then
		local player1id = getPlayerFromNick ( player1 )
		if ( player1id ) then
			local player1name = getPlayerName ( player1id )
			local player2name = getPlayerName ( source )
			local x1, y1, z1 = getElementPosition ( player1id )
			local x2, y2, z2 = getElementPosition ( source )
			local distance = getDistanceBetweenPoints2D ( x1, y1, x2, y2 ) / 2
			local distresult = math.ceil ( distance )
		if ( distance >= 402.25 ) then
			local totaldistance = distance / 402.25
			local resultx = math.ceil( totaldistance )
			outputChatBox ( "The Distance between " ..player1name.. " and " ..player2name.. " is " ..resultx.. " Miles", root, 255, 255, 0 )
			else
			outputChatBox ( "The Distance between " ..player1name.. " and " ..player2name.. " is " ..distresult.. " Meters", root, 255, 255, 0 )
			end
			elseif ( player1id == false ) then
			outputChatBox ( "Player not found!", source, 255, 255, 0 )
		end
	end
	if ( player2 ) then
		local player1id = getPlayerFromNick ( player1 )
		local player2id = getPlayerFromNick ( player2 )
		if ( player1id and player2id ) then
			local player1name = getPlayerName ( player1id )
			local player2name = getPlayerName ( player2id )
			local x1, y1, z1 = getElementPosition ( player1id )
			local x2, y2, z2 = getElementPosition ( player2id )
			local distance = getDistanceBetweenPoints2D ( x1, y1, x2, y2 ) / 2
			local distresult = math.ceil ( distance )
		if ( distance >= 402.25 ) then
			local totaldistance = distance / 402.25
			local resultx = math.ceil( totaldistance )
			outputChatBox ( "The Distance between " ..player1name.. " and " ..player2name.. " is " ..resultx.. " Miles", root, 255, 255, 0 )
			else
			outputChatBox ( "The Distance between " ..player1name.. " and " ..player2name.. " is " ..distresult.. " Meters", root, 255, 255, 0 )
			end
			elseif ( player1id == false or player2id == false ) then
			outputChatBox ( "Player not found!", source, 255, 255, 0 )
		end
	end
end

function grav ( source, command, gravid )
	setGravity ( gravid )
	for k,v in ipairs(players) do
	setPedGravity ( v, gravid )
	end
end

function gravlevel ()
	local gravity = getGravity ()
	outputConsole ( "Gravity is currently set to " ..gravity.. "" )
end

function setgamespeed ( player, command, value )
	setGameSpeed ( tonumber ( value ) )
end

function gamespeed ( player, command, value )
	local speed = getGameSpeed ()
	outputConsole ( "GameSpeed is currently set to " ..speed.. "" )
end

function consoleKill ( player, commandName )
	if ( player ) then
		killPed ( player )
	end
end

function testSound ( source, command, ids )
	local players = getElementsByType( "player" )
	local idsx = tonumber ( ids )
	for k,v in ipairs(players) do
	playSoundFrontEnd ( v, idsx )
	end
end

function armor ( source )
	setPedArmor ( source, 100 )
end

function testSound2 ( source, command, ids )
	preloadMissionAudio ( source, ids, 1 )
	local x,y,z = getElementPosition ( source )
	playMissionAudio ( source, 1, x, y, z )
end

function playslot ()
	playMissionAudio ( source, 1, x, y, z )
end

function style ( player, command, ids )
	setPedFightingStyle ( player, tonumber(ids) )
end

----TALIDAN ADDED THIS CRAP, <3 BROPHY
--[[Vehicle pos/rot: -721.44641113281 1014.2721557617 11.814476966858, 186.75370788574 357.12237548828 189.90641784668]]
function flipVehicle ( source, cmd )
	if ( isPedInVehicle ( source ) == true ) then
		local theVehicle = getPedOccupiedVehicle ( source )
		local x,y,z = getElementPosition ( theVehicle )
		local rx,ry,rz = getVehicleRotation ( theVehicle )
		if rx > 180 then rz = rz - 180 end
		setElementPosition ( theVehicle, x,y,z + 2 )
		setVehicleRotation ( theVehicle, 0, 0, rz )
	end
end

function respawn ( source )
	spawn_me ( source, 500 )
end

addEventHandler ( "onResourceStart", root, resourceStart )
addEventHandler ( "onPlayerJoin", root, playerJoin )
addEventHandler ( "onPlayerSpawn", root, playerSpawn )
addEventHandler ( "onVehicleExplode", root, vehicleExplode )
addEventHandler ( "onPlayerWasted", root, playerWasted )
addEventHandler ( "onPlayerQuit", root, playerQuit )

--///

addCommandHandler ( "setalpha", elementAlpha ) 
addCommandHandler ( "style", style )
addCommandHandler ( "armor", armor )
addCommandHandler ( "sound", testSound )
addCommandHandler ( "kill", consoleKill )
addCommandHandler ( "setgamespeed", setgamespeed )
addCommandHandler ( "setgravity", grav )
addCommandHandler ( "dist", distance )
addCommandHandler ( "veh", veh )
addCommandHandler ( "respawn", respawn )
addCommandHandler ( "setwaveheight", setWaveLevel )
addCommandHandler ( "flip", flipVehicle )

-- Removed commands (broken or useless) - MK
--addCommandHandler ( "gamespeed", gamespeed )
--addCommandHandler ( "playslot", playslot )
--addCommandHandler ( "sound3d", testSound2 )
--addCommandHandler ( "pass", pass )
--addCommandHandler ( "kick", kickPlayer )
--addCommandHandler ( "setlevel", setLevel )
--addCommandHandler ( "gravity", gravlevel )


function destroyBlipsAttachedTo(player)
	local attached = getAttachedElements ( player )
	if ( attached ) then
		for k,element in ipairs(attached) do
			if getElementType ( element ) == "blip" then
				destroyElement ( element )
			end
		end
	end
end


--
-- Spawn lots of peds nearby
--
local pedRate = 50
local pedMaxCount = 500
local pedTimer = nil
local pedTimer2 = nil

addCommandHandler ( "manypeds",
	function (player)
		pedTimer = setTimer( addPedTick, pedRate, 0 )
		pedTimer2 = setTimer( removePedTick, 1000, 0 )
	end
)

function addPedTick()
	local peds = getElementsByType( "ped" )
	if #peds < pedMaxCount then
		local x,y,z = getElementPosition( getRandomPlayer() )
		x = x + math.random(-50,50)
		y = y + math.random(-50,50)
		z = z + 4
		local modelid = 0
		createPed ( modelid, x, y, z )		
	end
end

function removePedTick()
	local peds = getElementsByType( "ped" )
	for i,ped in ipairs(peds) do
		if isPedDead(ped) then
			destroyElement(ped)
		end
	end
end


