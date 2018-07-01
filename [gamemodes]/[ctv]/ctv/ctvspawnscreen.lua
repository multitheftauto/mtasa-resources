-- Capture the Vehicle by BrophY, if you wish to modify, keep copyright notice and credits in the file
-- Credits to Talidan, Dragon and Ransom for help and testing

bases = {}

-- Right, lets get down to the main spawnscreen code

function onCTVSpawnMapStart (startedMap)
	local mapRoot = getResourceRootElement(startedMap)
	setMapName ( "Capture the Vehicle" )
	---get all the base elements ready
	for k,v in ipairs(getElementsByType ( "base", mapRoot )) do
		if getElementData ( v, "team" ) == "team1" then
			baseTeam1 = v
		elseif getElementData ( v, "team" ) == "team2" then
			baseTeam2 = v
		elseif getElementData ( v, "team" ) == "team3" then
			baseTeam3 = v
		elseif getElementData ( v, "team" ) == "team4" then
			baseTeam4 = v
		end
	end
	team1name = getElementData ( baseTeam1, "teamName" )
	team2name = getElementData ( baseTeam2, "teamName" )
	team3name = getElementData ( baseTeam3, "teamName" )
	team4name = getElementData ( baseTeam4, "teamName" )
	setRuleValue ( "Team 1", "" ..team1name.. "" )
	setRuleValue ( "Team 2", "" ..team2name.. "" )
	setRuleValue ( "Team 3", "" ..team3name.. "" )
	setRuleValue ( "Team 4", "" ..team4name.. "" )
	team1color = getElementData ( baseTeam1, "teamColor" )
	team1col1 = gettok ( team1color, 1, 44 )
	team1col2 = gettok ( team1color, 2, 44 )
	team1col3 = gettok ( team1color, 3, 44 )
	team2color = getElementData ( baseTeam2, "teamColor" )
	team2col1 = gettok ( team2color, 1, 44 )
	team2col2 = gettok ( team2color, 2, 44 )
	team2col3 = gettok ( team2color, 3, 44 )
	team3color = getElementData ( baseTeam3, "teamColor" )
	team3col1 = gettok ( team3color, 1, 44 )
	team3col2 = gettok ( team3color, 2, 44 )
	team3col3 = gettok ( team3color, 3, 44 )
	team4color = getElementData ( baseTeam4, "teamColor" )
	team4col1 = gettok ( team4color, 1, 44 )
	team4col2 = gettok ( team4color, 2, 44 )
	team4col3 = gettok ( team4color, 3, 44 )
	varTeam1 = createTeam ( tostring(team1name), team1col1, team1col2, team1col3 )
	varTeam2 = createTeam ( tostring(team2name), team2col1, team2col2, team2col3 )
	varTeam3 = createTeam ( tostring(team3name), team3col1, team3col2, team3col3 )
	varTeam4 = createTeam ( tostring(team4name), team4col1, team4col2, team4col3 )
	bases[varTeam1] = baseTeam1
	bases[varTeam2] = baseTeam2
	bases[varTeam3] = baseTeam3
	bases[varTeam4] = baseTeam4

	spawnText ()
end

function onCTVSpawnMapStop (startedMap)
	for k,v in ipairs(getElementsByType ( "player" )) do
		textDisplayRemoveObserver ( spawnDisplay, v )
		--setCameraMode ( v, "player" )
		setCameraTarget( v, v )
		unbindKey ( v, "F1", "down", spawnTeam1 )
		unbindKey ( v, "F2", "down", spawnTeam2 )
		unbindKey ( v, "F3", "down", spawnTeam3 )
		unbindKey ( v, "F4", "down", spawnTeam4 )
		hudDisplay ( v, true )
	end
	setMapName ( "None" )
	removeRuleValue ( "Team 1" )
	removeRuleValue ( "Team 2" )
	removeRuleValue ( "Team 3" )
	removeRuleValue ( "Team 4" )
end

function spawnScreen ( source )
	textDisplayAddObserver ( spawnDisplay, source )
	--setCameraMode ( source, "fixed" )
	--setTimer ( setCameraPosition, 1000, 1, source, 160.15, -1951.68, 50 )
	--setTimer ( setCameraLookAt, 1000, 1, source, 165, -1951.68, 50 )
	setCameraMatrix( source, 329.94, -1985.88, 30.0, 377.36, -2043.06, 7.83 )
	bindKey ( source, "F1", "down", spawnTeam, varTeam1 )
	bindKey ( source, "F2", "down", spawnTeam, varTeam2 )
	bindKey ( source, "F3", "down", spawnTeam, varTeam3 )
	bindKey ( source, "F4", "down", spawnTeam, varTeam4 )
	hudDisplay ( source, false )
end

function spawnTeam ( source, key, keyState, team )
	local teamBase = bases[team]
	local x = getElementData ( teamBase, "posX" )
	local y = getElementData ( teamBase, "posY" )
	local z = getElementData ( teamBase, "posZ" )
	local rot = getElementData ( teamBase, "rot" )
	local skins = getElementData ( teamBase, "skins" )
	local startSkin =  gettok ( skins, 1, 44  )
	local endSkin =  gettok ( skins, 2, 44  )

	local r, g, b = getTeamColor ( team )
	setPlayerNametagColor ( source, r, g, b )

	spawnPlayer ( source, x + math.random(1,5), y + math.random(1,5), z, rot, math.random(startSkin, endSkin) )
	showTextForPlayer ( source, 3000, 0.5, 0.5, 200, 100, 100, 200, 2, "Capture the vehicle!" )
	--setCameraMode ( source, "player" )
	setCameraTarget( source, source )
	playSoundFrontEnd ( source, 6 )
	setPlayerTeam ( source, team )
	createBlipAttachedTo ( source, 0, 2, r, g, b, 140 )

	local weapon1 = getElementData ( teamBase, "weapon1" )
	local weapon1id = tonumber ( gettok ( weapon1, 1, 44 ) )
	local weapon1ammo = tonumber ( gettok ( weapon1, 2, 44 ) )
	local weapon2 = getElementData ( teamBase, "weapon2" )
	local weapon2id = tonumber ( gettok ( weapon2, 1, 44 ) )
	local weapon2ammo = tonumber ( gettok ( weapon2, 2, 44 ) )
	local weapon3 = getElementData ( teamBase, "weapon3" )
	local weapon3id = tonumber ( gettok ( weapon3, 1, 44 ) )
	local weapon3ammo = tonumber ( gettok ( weapon3, 2, 44 ) )
	local weapon4 = getElementData ( teamBase, "weapon4" )
	local weapon4id = tonumber ( gettok ( weapon4, 1, 44 ) )
	local weapon4ammo = tonumber ( gettok ( weapon4, 2, 44 ) )
	local weapon5 = getElementData ( teamBase, "weapon5" )
	local weapon5id = tonumber ( gettok ( weapon5, 1, 44 ) )
	local weapon5ammo = tonumber ( gettok ( weapon5, 2, 44 ) )
	local weapon6 = getElementData ( teamBase, "weapon6" )
	local weapon6id = tonumber ( gettok ( weapon6, 1, 44 ) )
	local weapon6ammo = tonumber ( gettok ( weapon6, 2, 44 ) )
	giveWeapon ( source, weapon1id, weapon1ammo )
	giveWeapon ( source, weapon2id, weapon2ammo )
	giveWeapon ( source, weapon3id, weapon3ammo )
	giveWeapon ( source, weapon4id, weapon4ammo )
	giveWeapon ( source, weapon5id, weapon5ammo )
	giveWeapon ( source, weapon6id, weapon6ammo )
end

function playerJoin ()
	fadeCamera ( source, false, 1.0, 0, 0, 0 )
	setTimer ( fadeCamera, 1000, 1, source, true, 1 )
	setTimer ( spawnScreen, 1000, 1, source )
	showTextForPlayer ( source, 5000, 0.5, 0.1, 0, 0, 180, 255, 1.5, "Capture the Vehicle is running!" )
end

function playerQuit ()
	destroyBlipsAttachedTo ( source )
	setPlayerTeam ( source, nil )
end

function playerSpawn ( spawnpoint, team )
	textDisplayRemoveObserver ( spawnDisplay, source )
	unbindKey ( source, "F1", "down", spawnTeam )
	unbindKey ( source, "F2", "down", spawnTeam )
	unbindKey ( source, "F3", "down", spawnTeam )
	unbindKey ( source, "F4", "down", spawnTeam )
	hudDisplay ( source, true )
end

function playerWasted ( ammo, attacker, weapon, bodypart )
	fadeCamera ( source, false, 1.0, 0, 0, 0 )
	setTimer ( fadeCamera, 1000, 1, source, true, 1 )
	setTimer ( spawnScreen, 1000, 1, source )
	setPlayerTeam ( source, nil )
	destroyBlipsAttachedTo ( source )
end

function spawnText ()
		spawnDisplay = textCreateDisplay ()
		local stext = textCreateTextItem ( "Select your spawn", 0.502, 0.302, "low", 0, 0, 0, 255, 2, "center" )
		local stext2 = textCreateTextItem ( "Press F1 to spawn " ..team1name.. "", 0.502, 0.502, "low", 0, 0, 0, 255, 1.8, "center" )
		local stext3 = textCreateTextItem ( "Press F2 to spawn " ..team2name.. "", 0.502, 0.552, "low", 0, 0, 0, 255, 1.8, "center" )
		local stext4 = textCreateTextItem ( "Press F3 to spawn " ..team3name.. "", 0.502, 0.602, "low", 0, 0, 0, 255, 1.8, "center" )
		local stext5 = textCreateTextItem ( "Press F4 to spawn " ..team4name.. "", 0.502, 0.652, "low", 0, 0, 0, 255, 1.8, "center" )
		local text = textCreateTextItem ( "Select your spawn", 0.5, 0.3, "low", 255, 255, 255, 255, 2, "center" )
		local text2 = textCreateTextItem ( "Press F1 to spawn " ..team1name.. "", 0.5, 0.5, "low", 255, 255, 255, 255, 1.8, "center" )
		local text3 = textCreateTextItem ( "Press F2 to spawn " ..team2name.. "", 0.5, 0.55, "low", 255, 255, 255, 255, 1.8, "center" )
		local text4 = textCreateTextItem ( "Press F3 to spawn " ..team3name.. "", 0.5, 0.6, "low", 255, 255, 255, 255, 1.8, "center" )
		local text5 = textCreateTextItem ( "Press F4 to spawn " ..team4name.. "", 0.5, 0.65, "low", 255, 255, 255, 255, 1.8, "center" )
		textDisplayAddText ( spawnDisplay, stext )
		textDisplayAddText ( spawnDisplay, stext2 )
		textDisplayAddText ( spawnDisplay, stext3 )
		textDisplayAddText ( spawnDisplay, stext4 )
		textDisplayAddText ( spawnDisplay, stext5 )
		textDisplayAddText ( spawnDisplay, text )
		textDisplayAddText ( spawnDisplay, text2 )
		textDisplayAddText ( spawnDisplay, text3 )
		textDisplayAddText ( spawnDisplay, text4 )
		textDisplayAddText ( spawnDisplay, text5 )
end

function hudDisplay ( player, bool )
	setPlayerHudComponentVisible ( player, "ammo", bool )
	setPlayerHudComponentVisible ( player, "area_name", bool )
	setPlayerHudComponentVisible ( player, "armour", bool )
	setPlayerHudComponentVisible ( player, "breath", bool )
	setPlayerHudComponentVisible ( player, "health", bool )
	setPlayerHudComponentVisible ( player, "money", bool )
	setPlayerHudComponentVisible ( player, "radar", bool )
	setPlayerHudComponentVisible ( player, "vehicle_name", bool )
	setPlayerHudComponentVisible ( player, "weapon", bool )
end

addEventHandler( "onGamemodeMapStart", getRootElement (), onCTVSpawnMapStart )
addEventHandler( "onGamemodeMapStop", getRootElement (), onCTVSpawnMapStop )
addEventHandler ( "onPlayerQuit", root, playerQuit )
addEventHandler ( "onPlayerSpawn", root, playerSpawn )
addEventHandler ( "onPlayerWasted", root, playerWasted )
addEventHandler ( "onPlayerJoin", root, playerJoin )
