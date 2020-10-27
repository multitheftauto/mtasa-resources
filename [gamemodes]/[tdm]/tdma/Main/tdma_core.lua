--+----------------------------+
--| Team Death Match Game Mode |
--|     Created By AlienX      |
--+----------------------------+
debugEnabled = true

--Game mode variables
gameInterior = 0
gameRespawnTime = 3000
gameTeams = {}
gameVehicles = {}
gameMaxKills = 40
gameFF = "off"
gameTimeHour = 0
gameTimeMin = 0
gameTimeLocked = false
versionDisplay = nil

xDebug = false
xDebug2 = false
textBoost = 0

xonPlayerWasted_Enabled = true
mapResource = nil
local tdma = nil

function onMapLoad ( name )

	--outputChatBox ( "LOADING NEW MAP... PLEASE WAIT" )

	mapResource = getResourceRootElement(name)

	if xDebug then outputDebugString ( "Starting TDMA Main Control Suite" ) end
	if xDebug then outputDebugString ( "STARTED... Proceeding to load gamemode... WAIT!" ) end

	----outputDebugString ( "Setting up Bases" )
	setupBases(name)

	setGameType ("Team Death Match Arena")

	tdma = createElement("tdmagame")

	versionDisplay = textCreateDisplay ()
	local versionText = textCreateTextItem ( "Team Death Match Arena v0.9", 0.975, 0.02, "medium", 255, 255, 255, 255, 1, "right" )
	textDisplayAddText ( versionDisplay, versionText )

	if ( tonumber(gameMaxKills) > 0 ) then
	local teamText = textCreateTextItem ( "Scores", 0.01, 0.24 + textBoost, "medium", 255,255,255, 255, 1 )
	textDisplayAddText ( versionDisplay, teamText )
	textBoost = textBoost + 0.020
		for k,v in ipairs(gameTeams) do
			if xDebug2 then outputDebugString ( "**MAKING TEAM KILL TEXTS***" ) end
			if xDebug2 then outputDebugString ( "**GOT: " .. v.name .. " R:" .. v.red .. " G:" .. v.green .. " B:" .. v.blue ) end
			local teamName = v.name
			local teamKills = v.kills
			teamText = textCreateTextItem ( teamName .. ": " .. teamKills .. "/" .. gameMaxKills .. " kills", 0.01, 0.24 + textBoost, "medium", tonumber(v.red), tonumber(v.green), tonumber(v.blue), 255, 1 )
			--setElementParent ( teamText, tdma )
			v.teamText = teamText
			textDisplayAddText ( versionDisplay, teamText )
			textBoost = textBoost + 0.015
		end
	end

	for k,v in ipairs(gameTeams) do
		if ( gameFF == "on" ) then
			setTeamFriendlyFire ( v.team, true )
			setTeamFriendlyFire ( v.team, true )
		else
			setTeamFriendlyFire ( v.team, false )
			setTeamFriendlyFire ( v.team, false )
		end
	end

	--Start the pickup system from Included\pickup_system.lua
	initPickupSystem()
	--Start the vehicle system from Included\vehicle_system.lua
	initVehicleSystem()

	----outputDebugString ( "Starting The Game" )
	if xDebug then outputDebugString ( "[[[[[/*****STARTING GAME*****\]]]]]" ) end
	startGame()

end
addEventHandler( "onGamemodeMapStart", root, onMapLoad)

function onMapUnload ( name )

	--outputChatBox ( "UNLOADING LEVEL... PLEASE WAIT" )

	for k = 1,#gameTeams do
		destroyElement ( gameTeams[k].team )
	end

	textDestroyDisplay ( versionDisplay )

	--Game mode variables
	gameInterior = 0
	gameRespawnTime = 3000
	gameTeams = {}
	gameVehicles = {}
	gameMaxKills = 40
	gameFF = "off"
	gameTimeHour = 0
	gameTimeMin = 0
	gameTimeLocked = false
	versionDisplay = nil


	textBoost = 0

	xonPlayerWasted_Enabled = true
	mapResource = nil

	destroyElement ( tdma )

	for k,v in ipairs(getElementsByType("player")) do
		setPlayerTeam ( v, nil )
		setElementData ( v, "tdma.teamid", false )
		setElementData ( v, "tdma.playerHasSpawned", false )
	end

end
addEventHandler( "onGamemodeMapStop", root, onMapUnload)


function shuffleTable(inputData)
	local newTable = {}
	local i_RndTblPos = 0
	while #inputData > 0 do
		i_RndTblPos = math.random(1,#inputData)
		table.insert ( newTable, inputData[i_RndTblPos] )
		table.remove ( inputData, i_RndTblPos )
	end
	return newTable
end

function startGame()
if xDebug then outputDebugString ( "... DONE" ) end
	local playerElementTree = getElementsByType ( "player" )
	playerElementTree = shuffleTable(playerElementTree)
	for k,v in ipairs(playerElementTree) do
	    setElementData ( v, "tdma.sp", "n" )
	    setElementData ( source, "tdma.playerHasSpawned", false )

		--setElementInterior ( v, 10 )
		--setTimer ( fadeCamera, 1000, 1, v, true, 1 )

	    setPedStat ( v, 69, 1000 )
	    setPedStat ( v, 70, 1000 )
	    setPedStat ( v, 71, 1000 )
	    setPedStat ( v, 72, 1000 )
	    setPedStat ( v, 73, 1000 )
	    setPedStat ( v, 74, 1000 )
	    setPedStat ( v, 75, 1000 )
	    setPedStat ( v, 76, 1000 )
	    setPedStat ( v, 77, 1000 )
	    setPedStat ( v, 78, 1000 )
	    setPedStat ( v, 79, 1000 )

		setPlayerHudComponentVisible ( v, "ammo", true )
		setPlayerHudComponentVisible ( v, "area_name", true )
		setPlayerHudComponentVisible ( v, "armour", true )
		setPlayerHudComponentVisible ( v, "breath", true )
		setPlayerHudComponentVisible ( v, "health", true )
		setPlayerHudComponentVisible ( v, "money", true )
		setPlayerHudComponentVisible ( v, "radar", true )
		setPlayerHudComponentVisible ( v, "vehicle_name", true )
		setPlayerHudComponentVisible ( v, "weapon", true )

	    --Setup the status bar for the player!
		statusTextDisplay = textCreateDisplay ()
		local statusTextItem = textCreateTextItem ( "", 0.5, 0.95, "high", 255, 255, 255, 255, 1.5 )
		textDisplayAddText ( statusTextDisplay, statusTextItem )
		textDisplayAddObserver ( statusTextDisplay, v )
		textDisplayAddObserver ( versionDisplay, v )
		setElementData ( v, "tdma.status", statusTextItem )

		firstSpawn ( v )
	end
end

function restartGame()
	for k,v in ipairs(getElementsByType ( "player" )) do
	    setElementData ( v, "tdma.sp", "n" )

		fadeCamera ( v, false, 1.0, 0, 0, 0 )
		--setElementInterior ( v, 10 )
		--setTimer ( fadeCamera, 1000, 1, v, true, 1 )


	    setPedStat ( v, 69, 1000 )
	    setPedStat ( v, 70, 1000 )
	    setPedStat ( v, 71, 1000 )
	    setPedStat ( v, 72, 1000 )
	    setPedStat ( v, 73, 1000 )
	    setPedStat ( v, 74, 1000 )
	    setPedStat ( v, 75, 1000 )
	    setPedStat ( v, 76, 1000 )
	    setPedStat ( v, 77, 1000 )
	    setPedStat ( v, 78, 1000 )
	    setPedStat ( v, 79, 1000 )

		setPlayerHudComponentVisible ( v, "ammo", true )
		setPlayerHudComponentVisible ( v, "area_name", true )
		setPlayerHudComponentVisible ( v, "armour", true )
		setPlayerHudComponentVisible ( v, "breath", true )
		setPlayerHudComponentVisible ( v, "health", true )
		setPlayerHudComponentVisible ( v, "money", true )
		setPlayerHudComponentVisible ( v, "radar", true )
		setPlayerHudComponentVisible ( v, "vehicle_name", true )
		setPlayerHudComponentVisible ( v, "weapon", true )

		local theTeamID = getElementData( v, "tdma.teamid" )
		local theTeam = gameTeams[theTeamID]
		if ( theTeam ) then
			respawnThePlayer ( v, theTeam )
		else
			firstSpawn ( v )
		end
	end
end

function onMapFinish ( name )
	if getThisResource() ~= name then return end
	for k,v in ipairs(getElementsByType("player")) do
		setElementInterior ( v, 0 )
		setCameraInterior( v, 0 )
		setElementData ( v, "tdma.teamMarker", nil )
		setPlayerNametagColor ( v, 255, 255, 255 )
	end
end
addEventHandler( "onResourceStop", root, onMapFinish)

--Join/Leave stuffs
function onPlayerJoin ()
	--fadeCamera ( source, false, 1.0, 0, 0, 0 )
	--setTimer ( fadeCamera, 1000, 1, source, true, 1 )
	setTimer ( firstSpawn, 1000, 1, source )
	--showTextForPlayer2 ( source, 12000, 0, 0, 180, 1.5, "Welcome To Team Death Match Arena [By AlienX]" )
    setPedStat ( source, 69, 1000 )
    setPedStat ( source, 70, 1000 )
    setPedStat ( source, 71, 1000 )
    setPedStat ( source, 72, 1000 )
    setPedStat ( source, 73, 1000 )
    setPedStat ( source, 74, 1000 )
    setPedStat ( source, 75, 1000 )
    setPedStat ( source, 76, 1000 )
    setPedStat ( source, 77, 1000 )
    setPedStat ( source, 78, 1000 )
    setPedStat ( source, 79, 1000 )

    setElementData ( source, "tdma.sp", "n" )

	statusTextDisplay = textCreateDisplay ()
	local statusTextItem = textCreateTextItem ( "", 0.5, 0.95, "high", 255, 255, 255, 255, 1.5 )
	textDisplayAddText ( statusTextDisplay, statusTextItem )
	textDisplayAddObserver ( statusTextDisplay, source )
	textDisplayAddObserver ( versionDisplay, source )
	setElementData ( source, "tdma.status", statusTextItem )
	setElementData( source, "tdma.teamMarker", nil )

	if ( debugEnabled ) then outputDebugString ( getPlayerName(source) .. "> No marker for this player, Make one and attach it." ) end

end
addEventHandler ( "onPlayerJoin", root, onPlayerJoin )

function showTextForPlayer ( player, time, red, green, blue, scale, text )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, 0.5, 0.5, 2, red, green, blue, 255, scale, "center", "center" )
	textDisplayAddText ( textDisplay, textItem )
	textDisplayAddObserver ( textDisplay, player )
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end

function showTextForPlayer2 ( player, time, red, green, blue, scale, text )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, 0.5, 0.45, 2, red, green, blue, 255, scale, "center", "center" )
	textDisplayAddText ( textDisplay, textItem )
	textDisplayAddObserver ( textDisplay, player )
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end

function showTextForAll ( time, red, green, blue, scale, text )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, 0.5, 0.1, 2, red, green, blue, 255, scale )
	textDisplayAddText ( textDisplay, textItem )
	local players = getElementsByType( "player" )
	for k,v in ipairs(players) do
		textDisplayAddObserver ( textDisplay, v )
	end
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end

function onPlayerQuit ( )
	destroyBlipsAttachedTo ( source )
	setPlayerTeam ( source, nil )
	local marker = getElementData( source, "tdma.teamMarker" )
	if ( isElement(marker) ) then
		destroyElement ( marker )
	end
	setElementData ( source, "tdma.teamMarker", nil )
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit )

function xonPlayerWasted ( ammo, attacker, weapon, bodypart )
	if ( xonPlayerWasted_Enabled ) then
		local vTeamID = getElementData ( source, "tdma.teamid" )
		local vTeam = gameTeams[vTeamID]
		if not ( vTeam ) then
			setTimer ( firstSpawn, 3000, 1, source, vTeam )
		else
			local a = setTimer ( respawnThePlayer, 3000, 1, source, vTeam )
			if not ( a ) then
				respawnThePlayer ( source, vTeam )
			end
		end

		if ( attacker ) then
			local pTeamID = getElementData ( attacker, "tdma.teamid" )
			local pTeam = gameTeams[pTeamID]
			--Was it a self kill?
			if ( source ~= attacker and vTeamID ~= pTeamID  ) then
				if ( pTeam ) then
					updateKills ( attacker, pTeam )
				end
			end
		end
	end
end
addEventHandler ( "onPlayerWasted", root, xonPlayerWasted )

function onChat ( message, theType )
	if theType == 0 then
		cancelEvent()
		message = string.gsub(message, "#%x%x%x%x%x%x", "")
		local team = getPlayerTeam ( source )
		local bastidName = getPlayerName ( source )
		if ( team ) then
			local r, g, b = getTeamColor ( team )
			outputChatBox ( bastidName..":#FFFFFF "..message, getRootElement(), r, g, b, true )
		else
			outputChatBox ( bastidName..": "..message )
		end
		outputServerLog( "CHAT: " .. bastidName .. ": " .. message )
	end
end
addEventHandler ( "onPlayerChat", root, onChat )

function updateKills( idPlayer, idTeam )
	if ( tonumber(gameMaxKills) > 0 ) then
		if xDebug then outputDebugString ( "Kills for team before are: " .. idTeam.kills  ) end
		local teamID = getElementData( idPlayer, "tdma.teamid" )
		gameTeams[teamID].kills = gameTeams[teamID].kills + 1
		if xDebug then outputDebugString ( "Kills for team " .. idTeam.name .. " updated to " .. gameTeams[teamID].kills  ) end
		textItemSetText ( idTeam.teamText, idTeam.name .. ": " .. gameTeams[teamID].kills .. "/" .. gameMaxKills .. " kills" )
		hasTeamWon ( teamID )
	end
end

function tmrRestartRound ( timerID, player )
	----outputDebugString ( "Mission timer has been triggerd, their " .. timerID .. " and " .. rndTimer .. " [timerid/rndtimer]" )
	if ( tostring(timerID) == tostring(rndTimer) ) then
		destroyMissionTimer ( timerID )
		--[[for k,v in ipairs(getElementsByType("player")) do

		end]]--
		xonPlayerWasted_Enabled = true
		for k,v in ipairs(getElementsByType("player")) do
			setPlayerTeam ( v, nil )
		end
		startGame()
		if ( tonumber(gameMaxKills) > 0 ) then
			for k,v in ipairs(gameTeams) do
				v.kills = 0
				textItemSetText ( v.teamText, v.name .. ": 0/" .. gameMaxKills .. " kills" )
				textItemSetText ( v.teamText, v.name .. ": 0/" .. gameMaxKills .. " kills" )
			end
		end
	end
end


function hasTeamWon( idTeam )
	----outputDebugString ( "Current Kills: " .. gameTeams[idTeam].kills .. " aginst " .. gameMaxKills )
	if ( tonumber(gameTeams[idTeam].kills) == tonumber(gameMaxKills) ) then
		--Yep, won it
		showTextForAll ( 5000, 0, 0, 255, 1.5, gameTeams[idTeam].name .. " team has won the match!" )
		rndTimer = createMissionTimer ( player, 10, "<", 5, 0.45, 0.25, 255, 0, 0, true )
		addEventHandler ( "missionTimerActivated", root, tmrRestartRound )
		startTimer ( rndTimer )
		xonPlayerWasted_Enabled = false
		--outputChatBox ( "Just about to go into the loop" )
		for k,v in ipairs(getElementsByType("player")) do
			--outputChatBox ( "Im inside the loop, scanning player " .. getClientName(v) )
			local pTeam = getPlayerTeam(v)
			--outputChatBox ( "He is on team " .. tostring(pTeam) .. " - does it match " .. tostring(gameTeams[idTeam].team) .. "?" )
			if pTeam ~= gameTeams[idTeam].team then
				local px, py, pz = getElementPosition(v)
				--outputChatBox ( "Got player " .. getClientName(v) .. " coords " .. px .. " " .. py .. " " .. pz .. " - boom?" )
				createExplosion ( px, py, pz, 0, nil, true, 0, false )
				killPed (v)
			end
		end
		--outputChatBox ( "out of the loop now! (did it even get into it?" )
	end
end

function updatePlayerInfoBar ( playerID, time, text )
	textItemSetText ( getElementData ( playerID, "tdma.status" ), text )
	setTimer ( textItemSetText, time, 1, getElementData ( playerID, "tdma.status" ), "" )
end

function requestedKillPlayer ( player )
	killPed ( player )
end
addCommandHandler ( "kill", requestedKillPlayer )

function setupBases( startedMap )
	local gSettings = getElementsByType ( "gamesettings" )
	gameInterior = getElementData ( gSettings[1], "interior" )
	gameRespawnTime = getElementData ( gSettings[1], "respawntime" )
	gameMaxKills = getElementData ( gSettings[1], "maxkills" )
	gameFF = getElementData( gSettings[1], "ff" )

	local tSettings = getElementsByType ( "gametime" )
	--outputDebugString ( "tSettings is " .. tostring(tSettings) )
	if tSettings and #tSettings > 0 then
		local tHour = getElementData ( tSettings[1], "h" )
		if ( tHour ) then gameTimeHour = tHour end
		local tMin = getElementData ( tSettings[1], "m" )
		if ( tMin ) then gameTimeMin = tMin end
		local tLocked = getElementData ( tSettings[1], "locked" )
		if ( tLocked ) then
			gameTimeLocked = tLocked
			setTimer ( lockTime, 1000, 0 )
			if xDebug2 then outputDebugString ( "Timer is Locked" ) end
		end
	end

	if xDebug2 then outputDebugString ( "Timer is " .. tHour .. " " .. tMin .. " locked:" .. tostring(tLocked) ) end

	if xDebug then outputDebugString ( "Searching base for data" ) end
	for k,v in ipairs(getElementsByType ( "base" )) do
		gameTeams[k] = {}
		gameTeams[k].name = getElementData ( v, "team" )
		if xDebug then outputDebugString ( "Creating team " .. gameTeams[k].name ) end
		gameTeams[k].red = getElementData ( v, "red" )
		gameTeams[k].green = getElementData ( v, "green" )
		gameTeams[k].blue = getElementData ( v, "blue" )
		gameTeams[k].kills = 0

		--Weapon Data
		gameTeams[k].weapons = {}
		for i,j in ipairs(getChildren ( v, "weapon" )) do
			gameTeams[k].weapons[i] = {}
			gameTeams[k].weapons[i].id = getElementData( j, "model" )
			gameTeams[k].weapons[i].ammo = getElementData( j, "ammo" )
		end

		--Skins
		gameTeams[k].skins = {}
		for i,j in ipairs(getChildren ( v, "skin" )) do
			gameTeams[k].skins[i] = {}
			gameTeams[k].skins[i].id = getElementData( j, "model" )
		end

		--Spawns
		gameTeams[k].spawns = {}
		for i,j in ipairs(getChildren ( v, "spawn" )) do
			gameTeams[k].spawns[i] = {}
			gameTeams[k].spawns[i].x = getElementData ( j, "posX" )
			gameTeams[k].spawns[i].y = getElementData ( j, "posY" )
			gameTeams[k].spawns[i].z = getElementData ( j, "posZ" )
			gameTeams[k].spawns[i].rot = getElementData ( j, "rot" )
			gameTeams[k].spawns[i].rx = getElementData ( j, "randx" )
			gameTeams[k].spawns[i].ry = getElementData ( j, "randy" )
			gameTeams[k].spawns[i].rz = getElementData ( j, "randz" )
		end

		gameTeams[k].team = createTeam( gameTeams[k].name, gameTeams[k].red, gameTeams[k].green, gameTeams[k].blue )
		if xDebug then outputDebugString ( "Team created [" .. gameTeams[k].name .. "]" ) end
	end

	--Spawn vehicles
	--<gamevehicle id="NRG500" model="522" posX="-2173.5368652344" posY="681.57989501953" posZ="54.47985458374" rotX="351.66986083984" rotY="69.25244140625" rotZ="168.93634033203" colors="39,106,0,0"/>

	if xDebug then outputDebugString ( "Searching base for data...DONE" ) end
end

function lockTime ()
	if xDebug2 then outputDebugString ( "Setting game time to " .. gameTimeHour .. ":" .. gameTimeMin  ) end
	setTime ( gameTimeHour, gameTimeMin )
end

function getChildren ( root, type )
	local elements = getElementsByType ( type )
	local result = {}
	for elementKey,elementValue in ipairs(elements) do
		if ( getElementParent( elementValue ) == root ) then
			result[ table.getn( result ) + 1 ] = elementValue
		end
	end
	return result
end

function playerSpawned ( )
	local player = source
--	outputChatBox ( getClientName( player ) .. " SPAWNED" )
	--Useful for a later update
	fadeCamera ( player, true, 1.0, 0, 0, 0 )
	spawnProtectionStart ( player )
	--setCameraMode ( player, "player" )
	setCameraTarget( player, player )

	local theTeamID = getElementData( player, "tdma.teamid" )
	local theTeam = gameTeams[theTeamID]
	for k,v in ipairs(theTeam.weapons) do
		--outputDebugString ( "Attempting to give weapon " .. tostring(v.id) .. " with ammo " .. tostring(v.id) .. " to player " .. getClientName(source) )
		giveWeapon ( source, v.id, v.ammo )
	end
end
addEventHandler ( "onPlayerSpawn", root, playerSpawned )

function firstSpawn ( source )
	local thePlayer = source
	if xDebug then outputDebugString ( "Spawning player " .. getPlayerName(thePlayer) .. " for the very first time" ) end
	updatePlayerInfoBar ( thePlayer, 5200, "Please wait... Spawning" )

	local randTeam = math.random(1,#gameTeams)
	local foundTeam = nil
	local foundTeamID = nil
	local allDone = false
	local scanPlayerCount = 128
	local teamPlayerCount = 0
	--outputDebugString ( "scanning teams now for auto assignment" )
	for k,v in ipairs(gameTeams) do
		teamPlayerCount = countPlayersInTeam( v.team )
		if ( teamPlayerCount < scanPlayerCount ) then
			scanPlayerCount = countPlayersInTeam ( v.team )
			foundTeam = v
			foundTeamID = k
			allDone = true
		end
	end

	if ( allDone ) then
		if xDebug then outputDebugString ( "Spawning player " .. getPlayerName(thePlayer) .. " (ALLDONE) Team: " .. foundTeam.name ) end
		spawnThePlayer ( thePlayer, foundTeam )
		setElementData ( thePlayer, "tdma.teamid", foundTeamID )
		showTextForPlayer ( thePlayer, 5000, tonumber(foundTeam.red), tonumber(foundTeam.green), tonumber(foundTeam.blue), 1.5, "You have been automatically assigned to team " .. foundTeam.name )
		--setMarkerColor ( theMarker, tonumber(gameTeams[foundTeamID].red), tonumber(gameTeams[foundTeamID].green), tonumber(gameTeams[foundTeamID].blue), 255 )
		setPlayerNametagColor ( thePlayer, gameTeams[foundTeamID].red, gameTeams[foundTeamID].green, gameTeams[foundTeamID].blue )
	else
		--Just select a random team
		if xDebug then outputDebugString ( "Spawning player " .. getPlayerName(thePlayer) .. " (NO FOUND) Team: " .. gameTeams[randTeam].name ) end
		spawnThePlayer ( thePlayer, gameTeams[1] )
		setElementData ( thePlayer, "tdma.teamid", 1 )
		--setMarkerColor ( theMarker, tonumber(gameTeams[1].red), tonumber(gameTeams[1].green), tonumber(gameTeams[1].blue), 255 )
		setPlayerNametagColor ( thePlayer, gameTeams[1].red, gameTeams[1].green, gameTeams[1].blue )
	end
end

function spawnThePlayer ( source, team )
	local randSpawn = math.random(1,#team.spawns)
	local randSkinPicker = math.random(1,#team.skins)
	local randSkin = tonumber(team.skins[randSkinPicker].id)
	local x = tonumber(team.spawns[randSpawn].x) + math.random(0,tonumber(team.spawns[randSpawn].rx))
	local y = tonumber(team.spawns[randSpawn].y) + math.random(0,tonumber(team.spawns[randSpawn].ry))
	local z = tonumber(team.spawns[randSpawn].z) + math.random(0,tonumber(team.spawns[randSpawn].rz))
	local rot = tonumber(team.spawns[randSpawn].rot)
	local rx = tonumber(team.spawns[randSpawn].rx)
	local ry = tonumber(team.spawns[randSpawn].ry)
	local rz = tonumber(team.spawns[randSpawn].rz)
	if xDebug then outputDebugString ( "Spawn Data: spawns size: " .. #team.spawns .. " skin: " .. randSkin .. " x:" .. x .. " y:" .. y .. " z:" .. z .. " rot:" .. rot .. " rx:" .. rx .. " ry:" .. ry .. " zr:" .. rz ) end

	local playerHasSpawned = getElementData(source, "tdma.playerHasSpawned")
	if ( playerHasSpawned == false ) then
		--setCameraMode ( source, "fixed" )
		--setTimer ( setCameraPosition, 1000, 1, source, x, y, z + 60 )
		--setTimer ( setCameraLookAt, 1000, 1, source, x, y, z )
		--setTimer ( setCameraRotation, 1000, source, rot, 0, 0 )
		setCameraMatrix( source, x, y, z + 60, x, y, z )
		setElementData ( source, "tdma.playerHasSpawned", true )
		setTimer ( spawnPlayer, 3000, 1, source, x, y, z, tonumber(rot), tonumber(randSkin), tonumber(gameInterior) )
		--spawnPlayer ( source, x,y,z, tonumber(rot), tonumber(randSkin), tonumber(gameInterior) )
	else
		spawnPlayer ( source, x,y,z, tonumber(rot), tonumber(randSkin), tonumber(gameInterior) )
	end
	setCameraInterior ( source, tonumber(gameInterior) )

	--setCameraMode ( source, "player" )
	setPlayerTeam ( source, team.team )
	createBlipAttachedTo ( source, 0, 2, team.red, team.green, team.blue )

	--playerSpawned ( source, team )
end

function respawnThePlayer ( source, team )
	local randSpawn = math.random(1,#team.spawns)
	local randSkinPicker = math.random(1,#team.skins)
	local randSkin = tonumber(team.skins[randSkinPicker].id)
	local x = tonumber(team.spawns[randSpawn].x) + math.random(0,tonumber(team.spawns[randSpawn].rx))
	local y = tonumber(team.spawns[randSpawn].y) + math.random(0,tonumber(team.spawns[randSpawn].ry))
	local z = tonumber(team.spawns[randSpawn].z) + math.random(0,tonumber(team.spawns[randSpawn].rz))
	local rot = tonumber(team.spawns[randSpawn].rot)
	local rx = tonumber(team.spawns[randSpawn].rx)
	local ry = tonumber(team.spawns[randSpawn].ry)
	local rz = tonumber(team.spawns[randSpawn].rz)
	--outputDebugString ( "Respawning Player " .. getClientName(source) .. " to team " .. team.name )
	local spawnComplete = spawnPlayer ( source, x, y, z, tonumber(rot), tonumber(randSkin), tonumber(gameInterior) )
	setCameraInterior ( source, tonumber(gameInterior) )
	if not ( spawnComplete ) then
		--Spawn failed, try spawning as CJ?
		--outputDebugString ( "Respawning Player FAILED - attempting to spawn player " .. getClientName(source) .. " as model CJ[0]")
		spawnComplete = spawnPlayer ( source, x, y, z, tonumber(rot), 0, tonumber(gameInterior) )
	end

	for k,v in ipairs(team.weapons) do
		giveWeapon ( source, v.id, v.ammo )
	end

	--playerSpawned ( source, team )
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

function Event_clientScriptLoaded ( player )


	if ( player ) then
		local p_Team = getPlayerTeam(player)
		if ( p_Team ) then
			p_TeamName = getTeamName ( p_Team )
			p_TeamColorR, p_TeamColorG, p_TeamColorB = getTeamColor ( p_Team )
		else
			--outputChatBox ( "PTeam is bad" )
		end
		--outputChatBox ( "OMG = " .. p_TeamName .. " r=" .. p_TeamColorR .. " g=" .. p_TeamColorG .. " b=" .. p_TeamColorB )
		triggerClientEvent ( "Event_showPlayerTheirTeam", player, player, p_TeamName, p_TeamColorR, p_TeamColorG, p_TeamColorB )
	end
end

addEvent ( "Event_clientScriptLoaded", true )
addEventHandler ( "Event_clientScriptLoaded", root, Event_clientScriptLoaded )
