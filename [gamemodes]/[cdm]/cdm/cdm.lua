--[[
<team name="" red="" green="" blue="">
	<camera lookX="" lookY="" lookZ="" posX="" posY="" posZ=""/>
	<weapon model="" ammo=""/>
	<skin model=""/>
	<spawnpoint posX="" posY="" posZ="" rot=""/>
</team>
]]

cdm_root = getRootElement()

function cdm_initialize()
	outputDebugString( "Initializing Classic Deathmatch..." )
	local teams = getElementsByType( "team" )
	if ( #teams < 2 ) then
		outputDebugString( "* CDM Error: There are not enough teams. Minimum is 2", 1 )
		cdm_error = true
		return
	end
	teamRoot = {}
	for k,v in ipairs(teams) do
		teamRoot[k] = {}
		teamRoot[k].name = getElementData( v, "name" )
		if ( teamRoot[k].name == false ) then
			outputDebugString( "* CDM Error: Team #" .. k .. " doesn't have a name.", 1 )
			cdm_error = true
			return
		end
		local weapons = getChildren ( v, "weapon" )
		teamRoot[k].weapons = {}
		local str = ""
		for i,j in ipairs(weapons) do
			teamRoot[k].weapons[i] = {}
			teamRoot[k].weapons[i].id, teamRoot[k].weapons[i].ammo = tonumber(getElementData( j, "model" )), tonumber(getElementData( j, "ammo" ))
			if ( teamRoot[k].weapons[i].id == false ) then
				outputDebugString( "* CDM Error: All weapon IDs should be numeric.", 1 )
				cdm_error = true
				return
			elseif ( teamRoot[k].weapons[i].ammo == false ) then
				outputDebugString( "* CDM Error: All ammo values should be numeric.", 1 )
				cdm_error = true
				return
			end
			str = str .. teamRoot[k].weapons[i].ammo .. "x " .. getWeaponNameFromID ( teamRoot[k].weapons[i].id ) .. "\n"
		end
		local skins = getChildren ( v, "skin" )
		teamRoot[k].skins = {}
		if ( #skins == 0 ) then 
			teamRoot[k].skins[1] = 0
			outputDebugString( "* CDM Warning: No skins were found in team #" .. k .. ". Defaulting to 0.", 2 )
		end
		for i,j in ipairs(skins) do
			teamRoot[k].skins[i] = tonumber(getElementData( j, "model" ))
			if ( teamRoot[k].skins[i] == false ) then
				outputDebugString( "* CDM Error: All skin IDs should be numeric.", 1 )
				cdm_error = true
				return
			end
		end
		local spawnpoints = getChildren ( v, "spawnpoint" )
		if ( #spawnpoints == 0 ) then
			outputDebugString( "* CDM Error: Team #" .. k .. " doesn't have enough spawnpoints. Minimum is 1.", 1 )
			cdm_error = true
			return
		end
		teamRoot[k].spawnpoints = {}
		for i,j in ipairs(spawnpoints) do
			teamRoot[k].spawnpoints[i] = {}
			teamRoot[k].spawnpoints[i].posX, teamRoot[k].spawnpoints[i].posY, teamRoot[k].spawnpoints[i].posZ, teamRoot[k].spawnpoints[i].rot = tonumber(getElementData( j, "posX" )), tonumber(getElementData( j, "posY" )), tonumber(getElementData( j, "posZ" )), tonumber(getElementData( j, "rot" ))
			if ( ( teamRoot[k].spawnpoints[i].posX == false ) or ( teamRoot[k].spawnpoints[i].posY == false ) or ( teamRoot[k].spawnpoints[i].posZ == false ) or ( teamRoot[k].spawnpoints[i].rot == false ) ) then
				outputDebugString( "* CDM Error: All spawnpoint values should be numeric.", 1 )
				cdm_error = true
				return
			end
		end
		local camera = getChildren ( v, "camera" )
		teamRoot[k].camera = {}
		teamRoot[k].camera.posX, teamRoot[k].camera.posY, teamRoot[k].camera.posZ, teamRoot[k].camera.lookX, teamRoot[k].camera.lookY, teamRoot[k].camera.lookZ = tonumber(getElementData( camera[1], "posX" )), tonumber(getElementData( camera[1], "posY" )), tonumber(getElementData( camera[1], "posZ" )), tonumber(getElementData( camera[1], "lookX" )), tonumber(getElementData( camera[1], "lookY" )), tonumber(getElementData( camera[1], "lookZ" ))
		if ( ( teamRoot[k].camera.posX == false ) or ( teamRoot[k].camera.posY == false ) or ( teamRoot[k].camera.posZ == false ) or ( teamRoot[k].camera.lookX == false ) or ( teamRoot[k].camera.lookY == false ) or ( teamRoot[k].camera.lookZ == false )) then
			teamRoot[k].camera.posX, teamRoot[k].camera.posY, teamRoot[k].camera.posZ, teamRoot[k].camera.lookX, teamRoot[k].camera.lookY, teamRoot[k].camera.lookZ = 0, 0, 0, 0, 0, 0
			outputDebugString( "* CDM Warning: Something went wrong with the camera in team #" .. k .. " and it's your fault. Defaulting to 0, 0, 0.", 2 )
		end
		teamRoot[k].red, teamRoot[k].green, teamRoot[k].blue = tonumber(getElementData( v, "red" )), tonumber(getElementData( v, "green" )), tonumber(getElementData( v, "blue" ))
		if (( teamRoot[k].red == false ) or ( teamRoot[k].green == false ) or ( teamRoot[k].blue == false )) then
			teamRoot[k].red, teamRoot[k].green, teamRoot[k].blue = 255, 255, 255
			outputDebugString( "* CDM Warning: Something went wrong with the colors in team #" .. k .. " and it's your fault. Defaulting to 255, 255, 255.", 2 )
		end
		teamRoot[k].display = textCreateDisplay ()
		teamRoot[k].text1 = textCreateTextItem ( getElementData( v, "name" ), 0.5, 0.23, "high", teamRoot[k].red, teamRoot[k].green, teamRoot[k].blue, 255, 2.5 )
		teamRoot[k].text2 = textCreateTextItem ( str, 0.5, 0.35, "high", 240, 240, 240, 255, 1.75 )
		textDisplayAddText ( teamRoot[k].display, teamRoot[k].text1 )
		textDisplayAddText ( teamRoot[k].display, teamRoot[k].text2 )
		teamRoot[k].team = createTeam( tostring(teamRoot[k].name), tonumber(teamRoot[k].red), tonumber(teamRoot[k].green), tonumber(teamRoot[k].blue) )
	end
	cdm_error = false
	outputDebugString( "Done." )
end

function cdm_showScreen( player )
	local last = getElementData( player, "lastSpawn" )
	if ( last == false ) then
		setElementData( player, "lastSpawn", 1 )
		last = 1
	end
	spawnPlayer( player, 10000, 10000, 10000, 0, 0 )
	setElementPosition( player, teamRoot[last].camera.posX, teamRoot[last].camera.posY, teamRoot[last].camera.posZ - 100 )
	setPedGravity ( player, 0 )
	textDisplayAddObserver ( teamRoot[last].display, player )
	setCameraMatrix ( player, teamRoot[last].camera.posX, teamRoot[last].camera.posY, teamRoot[last].camera.posZ, teamRoot[last].camera.lookX, teamRoot[last].camera.lookY, teamRoot[last].camera.lookZ )
	bindKey ( player, "enter", "down", "Spawn" )
	bindKey ( player, "arrow_l", "down", "Next_team", "arrow_l" )
	bindKey ( player, "arrow_r", "down", "Previous_team", "arrow_r" )
end

function cdm_changeSpawn( player, commandName, key )
	local last = getElementData( player, "lastSpawn" )
	textDisplayRemoveObserver ( teamRoot[last].display, player )
	if ( key == "arrow_l" ) then last = last - 1 else last = last + 1 end
	if ( last < 1 ) then last = #teamRoot end
	if ( last > #teamRoot ) then last = 1 end
	textDisplayAddObserver ( teamRoot[last].display, player )
	setElementPosition( player, teamRoot[last].camera.posX, teamRoot[last].camera.posY, teamRoot[last].camera.posZ - 100 )
	setCameraMatrix( player, teamRoot[last].camera.posX, teamRoot[last].camera.posY, teamRoot[last].camera.posZ, teamRoot[last].camera.lookX, teamRoot[last].camera.lookY, teamRoot[last].camera.lookZ )
	setElementData( player, "lastSpawn", last )
end

function cdm_spawn( player )
	teamNum = getElementData( player, "lastSpawn" )
	textDisplayRemoveObserver ( teamRoot[teamNum].display, player )
	unbindKey ( player, "enter", "down", "Spawn" )
	unbindKey ( player, "arrow_l", "down", "Next_team" )
	unbindKey ( player, "arrow_r", "down", "Previous_team" )
	local randSpawn = math.random(1, #teamRoot[teamNum].spawnpoints)
	local randSkin = math.random(1, #teamRoot[teamNum].skins)
	local team = getTeamFromName(teamRoot[teamNum].name)
	setPlayerNametagColor ( player, teamRoot[teamNum].red, teamRoot[teamNum].green, teamRoot[teamNum].blue )
	setPedGravity ( player, 0.008 )
	spawnPlayer ( player, 0, 0, 1000, 0, 1 )
	setTimer( cdm_spawnTwo, 550, 1, player, teamNum, randSpawn, randSkin, team )
end

function cdm_spawnTwo( player, teamNum, randSpawn, randSkin, team )
	setCameraTarget( player, player )
	setPlayerTeam ( player, team )
	spawnPlayer ( player, teamRoot[teamNum].spawnpoints[randSpawn].posX, teamRoot[teamNum].spawnpoints[randSpawn].posY, teamRoot[teamNum].spawnpoints[randSpawn].posZ, teamRoot[teamNum].spawnpoints[randSpawn].rot, teamRoot[teamNum].skins[randSkin], 0, 0, team )
	createBlipAttachedTo ( player, 0, 2, teamRoot[teamNum].red, teamRoot[teamNum].green, teamRoot[teamNum].blue )
	for k,v in ipairs(teamRoot[teamNum].weapons) do
		giveWeapon ( player, teamRoot[teamNum].weapons[k].id, teamRoot[teamNum].weapons[k].ammo )
	end
end

function cdm_killAll()
	local players = getElementsByType( "player" )
	for k,v in ipairs(players) do
		if ( isPedDead( v ) == false ) then
			killPed( v )
		end
	end
end	

function cdm_gamemodeMapStart( startedMap )
	cdm_initialize()
	if ( cdm_error == false ) then
		local sTime = getElementsByType( "respawn" )
		if ( sTime ) then respawnTime = tonumber(getElementData( sTime[1], "time" )) else respawnTime = 4500 end
		local players = getElementsByType( "player" )
		for k,v in ipairs(players) do
			setElementData( v, "score", 0 )
			spawnPlayer( v, 10000, 10000, 10000, 0, 0 )
			cdm_showScreen( v )
			fadeCamera ( v, true )
		end
		setTimer( call, 1000, 1, getResourceFromName("scoreboard"), "addScoreboardColumn", "score" )
	end
end

function cdm_playerJoin()
	setElementData( source, "score", 0 )
	cdm_showScreen( source )
	fadeCamera ( source, true )
end

function cdm_playerQuit()
	destroyBlipsAttachedTo ( source )
end

function cdm_playerWasted( totalAmmo, killer )
	setPlayerTeam ( source, nil )
	if ( killer ) then
		if ( killer ~= source ) then
			setElementData( killer, "score", getElementData( source, "score" ) + 1 )
		else
			setElementData( killer, "score", getElementData( source, "score" ) - 1 )
		end
	end
	destroyBlipsAttachedTo ( source )
	local x, y, z = getElementPosition( source )
	local deathBlip = createBlip ( x, y, z, 0, 2, 200, 200, 200 )
	if ( getPedOccupiedVehicle ( source ) ) then
		if ( respawnTime > 200 ) then
			setTimer( removePedFromVehicle, respawnTime-200, 1, source )
		else
			removePedFromVehicle( source )
		end
	end
	setTimer( destroyElement, respawnTime, 1, deathBlip )
	setTimer( cdm_showScreen, respawnTime, 1, source )
end

function destroyBlipsAttachedTo( source )
	local elements = getAttachedElements ( source )
	for k,v in ipairs( elements ) do
		if ( getElementType( v ) == "blip" ) then destroyElement( v ) end
	end
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

addCommandHandler("Spawn", cdm_spawn)
addCommandHandler("Next_team", cdm_changeSpawn)
addCommandHandler("Previous_team", cdm_changeSpawn)

addEventHandler ( "onPlayerJoin", cdm_root, cdm_playerJoin )
addEventHandler ( "onPlayerQuit", cdm_root, cdm_playerQuit )
addEventHandler ( "onPlayerWasted", cdm_root, cdm_playerWasted )
addEventHandler ( "onGamemodeMapStart", cdm_root, cdm_gamemodeMapStart )
