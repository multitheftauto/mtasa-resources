SPTick = {}
tdmaSPTimer = {}

function endOfSpawnProtection ( player, marker )
	if ( isElement(marker) ) then
		if ( isElement(player) ) then
			detachElements ( marker, player )
		end
		destroyElement ( marker )
	end
	if ( isElement(player) ) then
		--local theTimer = getElementData ( player, "tdma.SPTimer" )
		local theTimer = tdmaSPTimer[player]
		killTimer ( theTimer )
		setElementData ( player, "tdma.SPMarker", false )
		--outputChatBox ( "You are no longer spawn protected", player )
	end
end

function countdownSpawnProtection ( player, marker )
	SPTick[player] = SPTick[player] + 1
	if ( SPTick[player] == 6 ) then
		endOfSpawnProtection ( player, marker )
	end
end

function startSpawnProtection ( source )
	local player = source
	local x, y, z = getElementPosition ( player )
	local r, g, b = 0, 0, 0

	local playerTeam = getPlayerTeam(player)
	if ( playerTeam ) then
		r, g, b = getTeamColor(playerTeam)
	else
		r = 255
	end

	local theMarker = createMarker( x, y, z, "arrow", 2, r, g, b, 255 )
	setElementInterior ( theMarker, getElementInterior(source) )
	if ( theMarker ) then -- check if the marker was created successfully

		attachElements ( theMarker, player, 0, 0, 0, 0, 0, 0 )
		local myTimer = setTimer ( countdownSpawnProtection, 1000, 7, player, theMarker )

		SPTick[player] = 0
		--setElementData ( player, "tdma.SPTimer", myTimer )
		tdmaSPTimer[player] = myTimer
		setElementData ( player, "tdma.SPMarker", theMarker )
		setElementData ( player, "tdma.sp", "y" )
		setTimer( spawnProtectToggle, 6000, 1, player, false )

		--outputChatBox ( "You are currently spawn protected", player )
	end
end

function spawnProtectToggle ( player, toggle )
	if ( not isElement(player) ) then
		return
	end
	if ( toggle ) then
		setElementData ( player, "tdma.sp", "y" )
		if xDebug then outputDebugString ( "Player " .. getPlayerName(player) .. " is spawn protected" ) end
	else
		setElementData ( player, "tdma.sp", "n" )
		if xDebug then outputDebugString ( "Player " .. getPlayerName(player) .. " is no longer spawn protected" ) end
	end
end

function xonPlayerWasted ( ammo, attacker, weapon, bodypart )
	local theMarker = getElementData( source, "tdma.SPMarker" )
	if ( theMarker ) then
		destroyElement ( theMarker )
		--killTimer ( getElementData ( source, "tdma.SPTimer" ) )
		if ( isTimer(tdmaSPTimer[source]) ) then killTimer ( tdmaSPTimer[source] ) end
	end
end
addEventHandler ( "onPlayerWasted", root, xonPlayerWasted )

function onPlayerQuit ( )
	--a fix for markers not being deleted when their in SP Mode, and quit the server.
	local theMarker = getElementData( source, "tdma.SPMarker" )
	if ( theMarker ) then
		destroyElement ( theMarker )
		--killTimer ( getElementData ( source, "tdma.SPTimer" ) )
		if ( isTimer(tdmaSPTimer[source]) ) then killTimer ( tdmaSPTimer[source] ) end
	end
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit )

function spawnProtectionStart ( player )
	startSpawnProtection ( player )
end
