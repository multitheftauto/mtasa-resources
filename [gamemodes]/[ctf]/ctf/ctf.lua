--[[
<team name="" colorR="" colorG="" colorB="">
	<flag name="" posX="" posY="" posZ="" />
	<spawnpoint posX="" posY="" posZ="" rot="" model="" />
</team>
]]

local CTF_root = getRootElement()

function CTF_onResourceStart( resourcename )
	if ( resourcename == getThisResource () ) then
		local players = getElementsByType ( "player" )
		for k,v in ipairs(players) do
			setElementData( v, "score", 0 )
		end
		setTimer( call, 1000, 1, getResourceFromName("scoreboard"), "addScoreboardColumn", "score" )
	end
end

function CTF_gamemodeMapStop( startedMap )
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		textDisplayRemoveObserver( CTF_annDisp, v )
		textDisplayRemoveObserver( CTF_scoDisp, v )
		textDisplayRemoveObserver( CTF_spawnHeaderDisp, v )
		textDisplayRemoveObserver( CTF_spawnWarningDisp, v )
		textDisplayRemoveObserver( CTF_spawnChangeDisp, v )
		local playerCol = getElementData( v, "col" )
		if ( playerCol ~= nil ) then
			local playerColObject = getElementData( playerCol, "object" )
			local playerColMarker = getElementData( playerCol, "marker" )
			detachElements ( playerColObject, v )
			detachElements ( playerColMarker, v )
			setElementData( playerCol, "object", nil )
			setElementData( playerCol, "marker", nil )
		end
		setElementData( v, "col", nil )
	end
	local blips = getElementsByType ( "blip" )
	for k,v in ipairs(blips) do
		destroyElement( v )
	end
	local cols = getElementsByType ( "colshape" )
	for k,v in ipairs(cols) do
		local colFlag = getElementData( v, "flag" )
		if ( colFlag ) then
			destroyElement( getElementData( v, "object" ) )
			destroyElement( getElementData( v, "marker" ) )
			destroyElement( v )
			setElementData( v, "flag", nil )
		end
	end
	local timers = getTimers()
	for k,v in ipairs(timers) do
		killTimer( v )
	end
end

function CTF_gamemodeMapStart ( startedMap )
	local mapName = getResourceName(startedMap)
	CTF_mapRoot = source
	local settings = getElementsByType( "settings" , CTF_mapRoot)
	if settings[1] then
		CTF_respawnTime = tonumber(getElementData( settings[1], "respawnTime" ))
		CTF_roundTime = tonumber(getElementData( settings[1], "roundTime" ))
		CTF_spawnscreen = getElementData( settings[1], "spawnScreen" )
		CTF_blips = getElementData( settings[1], "blips" )
	end
	CTF_respawnTime = CTF_respawnTime or get(mapName..".respawnTime")
	CTF_roundTime = CTF_roundTime or get(mapName..".roundTime")
	CTF_spawnscreen = CTF_spawnscreen or get(mapName..".spawnScreen")
	CTF_blips = CTF_blips or get(mapName..".blips")

	if ( not CTF_respawnTime ) then
		outputDebugString( "* CTF Warning: Respawn time not set. Defaulting to 4.5 seconds.", 2 )
		CTF_respawnTime = 4500
	end

	if ( not CTF_roundTime ) then
		outputDebugString( "* CTF Warning: Round time not set. Defaulting to 10 minutes.", 2 )
		CTF_roundTime = 600000
	end

	if ( CTF_spawnscreen == "on" ) then
		CTF_spawnscreen = true
	end
	if ( ( CTF_blips ~= "team" ) and ( CTF_blips ~= "all" ) ) then
		outputDebugString( "* CTF Warning: Blips are OFF.", 2 )
		CTF_blips = false
	end
	local weapons = getElementsByType( "weapon", CTF_mapRoot )
	CTF_weapons = {}
	for k,v in ipairs(weapons) do
		CTF_weapons[k] = {}
		CTF_weapons[k].model = getElementData( v, "model" )
		CTF_weapons[k].ammo = getElementData( v, "ammo" )
	end
	outputDebugString( "* CTF Info: Respawn time: " ..tostring(CTF_respawnTime) .. ", round time: " .. tostring(CTF_roundTime) .. ", spawnscreen: " .. tostring(CTF_spawnscreen) .. ", blips: " .. tostring(CTF_blips) .. ". " )
	local teams = getElementsByType ( "team", CTF_mapRoot )
	CTF_annDisp = textCreateDisplay ()
	CTF_annText = textCreateTextItem ( "", 0.5, 0.25, 0, 0, 0, 0, 255, 2, "center" )
	textDisplayAddText ( CTF_annDisp, CTF_annText )
	CTF_scoDisp = textCreateDisplay ()
	CTF_scoText = textCreateTextItem ( "", 0.8, 0.22, 0, 255, 255, 255, 255, 1.25 )
	textDisplayAddText ( CTF_scoDisp, CTF_scoText )
	CTF_spawnHeaderDisp = textCreateDisplay ()
	CTF_spawnHeaderText = textCreateTextItem ( "Select a team", 0.5, 0.5, 0, 255, 255, 255, 255, 2, "center" )
	textDisplayAddText ( CTF_spawnHeaderDisp, CTF_spawnHeaderText )
	CTF_spawnWarningDisp = textCreateDisplay ()
	CTF_spawnWarningText = textCreateTextItem ( "There are too many players in this team.\nChoose another team or wait for when there are less players in it.", 0.5, 0.75, 0, 255, 255, 255, 255, 1, "center" )
	textDisplayAddText ( CTF_spawnWarningDisp, CTF_spawnWarningText )
	CTF_spawnChangeDisp = textCreateDisplay ()
	CTF_spawnChangeText = textCreateTextItem ( "Press F3 to change a team for next round.", 0.5, 0.75, 0, 255, 255, 255, 255, 1, "center" )
	textDisplayAddText ( CTF_spawnChangeDisp, CTF_spawnChangeText )
	CTF_spawnDisp = {}
	CTF_spawnText = {}
	if (table.getn( teams ) < 1) then
		outputDebugString("* CTF Error: Not enough teams. Minimum is 2.", 1 )
		return
	else
		local flags, spawnpoints
		for teamKey,teamValue in ipairs(teams) do
			flags = getChildren ( teamValue, "flag" )
			spawnpoints = getChildren ( teamValue, "spawnpoint" )
			for spawnpointKey,spawnpointValue in ipairs(spawnpoints) do
				setElementData( spawnpointValue, "team", getTeamName( teamValue ) )
			end
			local r,g,b = getTeamColor( teamValue )
			if ( #flags < 1 ) then
				outputDebugString("* CTF Error: Not enough flags for team '" .. getTeamName( teamValue ) .. "'. Minimum is 1.", 1 )
				return
			elseif ( #spawnpoints < 1) then
				outputDebugString("* CTF Error: Not enough spawnpoints for team '" .. getTeamName( teamValue ) .. "'. Minimum is 1.", 1 )
				return
			else
				local x,y,z,object,marker,col
				for flagKey,flagValue in ipairs(flags) do
					local x,y,z = tonumber( getElementData ( flagValue, "posX" ) ), tonumber( getElementData ( flagValue, "posY" ) ), tonumber( getElementData ( flagValue, "posZ" ) )
					local object = createObject( 2993, x, y, z )
					local marker = createMarker( x, y, z, "arrow", 2, r, g, b, 255 )
					local col = createColSphere( x, y, z, 1 )
					local sblip = createBlip ( x, y, z, 0, 3, r, g, b, 25 )
					if ( CTF_blips ) then
						local blip = createBlipAttachedTo ( object, 56, 1 )
						local blipTwo = createBlipAttachedTo ( object, 0, 1, r, g, b, 255 )
						setElementData( col, "blip", blip )
						setElementData( col, "blipTwo", blipTwo )
						if ( CTF_blips == "team" ) then
							setElementVisibleTo ( blip, CTF_root, false )
							setElementVisibleTo ( blipTwo, CTF_root, false )
						end
					end
					setElementData( col, "object", object )
					setElementData( col, "flag", flagValue )
					setElementData( col, "marker", marker )
					setElementData( col, "sblip", sblip )
					setElementData( col, "team", teamValue )
				end
			end
			CTF_spawnDisp[teamKey] = textCreateDisplay ()
			CTF_spawnText[teamKey] = textCreateTextItem ( getTeamName( teamValue ), 0.5, 0.6, 0, r, g, b, 255, 2, "center" )
			textDisplayAddText ( CTF_spawnDisp[teamKey], CTF_spawnText[teamKey] )
			setElementData( teamValue, "score", 0 )
			local camera = getElementsByType( "camera", CTF_mapRoot )
			if camera[1] then
				CTF_camPosX, CTF_camPosY, CTF_camPosZ, CTF_camLookX, CTF_camLookY, CTF_camLookZ = tonumber(getElementData( camera[1], "posX" )), tonumber(getElementData( camera[1], "posY" )), tonumber(getElementData( camera[1], "posZ" )), tonumber(getElementData( camera[1], "lookX" )), tonumber(getElementData( camera[1], "lookY" )), tonumber(getElementData( camera[1], "lookZ" ))
			end
			if ( not CTF_camPosX ) or ( not CTF_camPosY ) or ( not CTF_camPosZ ) or ( not CTF_camLookX ) or ( not CTF_camLookY ) or ( not CTF_camLookZ ) then
				local camTable = get(mapName..".camera")
				if camTable then
					CTF_camPosX, CTF_camPosY, CTF_camPosZ = unpack(camTable[1])
					CTF_camLookX, CTF_camLookY, CTF_camLookZ = unpack(camTable[2])
				end
			end
			if ( not CTF_camPosX ) or ( not CTF_camPosY ) or ( not CTF_camPosZ ) or ( not CTF_camLookX ) or ( not CTF_camLookY ) or ( not CTF_camLookZ ) then
				local flagss = getElementsByType( "flag", CTF_mapRoot )
				local xi, yi, zi = 0, 0, 0
				for p,f in ipairs(flagss) do
					xi = xi + getElementData( f, "posX" )
					yi = yi + getElementData( f, "posY" )
					zi = zi + getElementData( f, "posZ" )
				end
				xi, yi, zi = xi/#flagss, yi/#flagss, zi/#flagss
				CTF_camPosX, CTF_camPosY, CTF_camPosZ, CTF_camLookX, CTF_camLookY, CTF_camLookZ = xi, yi, zi, xi, yi, zi
				outputDebugString( "* CTF Warning: Cameras are set wrong. Defaulting to " .. xi .. ", " .. yi .. ", " .. zi .. ".", 2 )
			end
		end
		updateScores()
		setTimer( call, 1000, 1, getResourceFromName("scoreboard"), "addScoreboardColumn", "score" )
		CTF_roundOn = true
		local players = getElementsByType ( "player" )
		for playerKey,playerValue in ipairs(players) do
			setElementData( playerValue, "col", nil )
			textDisplayAddObserver ( CTF_scoDisp, playerValue )
			setElementData( playerValue, "CTF_switched", false )
			--setCameraMode ( playerValue, "fixed" )
			--setTimer( setCameraPosition, 3000, 1, playerValue, CTF_camPosX, CTF_camPosY, CTF_camPosZ )
			--setTimer( setCameraLookAt, 3250, 1, playerValue, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
			setCameraMatrix( playerValue, CTF_camPosX, CTF_camPosY, CTF_camPosZ, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
			setTimer( CTF_spawnMenu, 5000, 1, playerValue )
			fadeCamera ( playerValue, true )
		end
		if ( CTF_roundTime >= 60000 ) then
			setTimer( CTF_announce, CTF_roundTime-10000, 1, 255, 255, 255, "Ten seconds remaining!", 4000 )
		end
		if ( CTF_roundTime >= 120000 ) then
			setTimer( CTF_announce, CTF_roundTime-60000, 1, 255, 255, 255, "One minute remaining!", 4000 )
		end
		CTF_missionTimer = exports.missiontimer:createMissionTimer (CTF_roundTime,true,true,0.5,20,true,"default-bold",1)
		addEventHandler ( "onMissionTimerElapsed", CTF_missionTimer, CTF_endRound )
	end
end

function CTF_endRound()
	CTF_roundOn = false
	local teams = getElementsByType ( "team", CTF_mapRoot )
	local maxScore = 0
	local winningTeam = 0
	local tieFlag = false
	for k,v in ipairs(teams) do
		local teamScore = getElementData( v, "score" )
		if ( teamScore >= maxScore ) then
			maxScore = teamScore
			winningTeam = v
		end
	end
	for k,v in ipairs(teams) do
		local teamScore = getElementData( v, "score" )
		if ( ( maxScore == teamScore ) and ( winningTeam ~= v ) ) then
			tieFlag = true
		end
	end
	if ( tieFlag ) then
		CTF_announce ( 255, 255, 255, "It's a tie!", 10000 )
	else
		local r, g, b = getTeamColor( winningTeam )
		CTF_announce ( r, g, b, "The " .. tostring(getTeamName( winningTeam )) .. " team won this round!", 10000 )
	end
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		--setCameraMode ( v, "fixed" )
		--setTimer( setCameraPosition, 1000, 1, v, CTF_camPosX, CTF_camPosY, CTF_camPosZ )
		--setTimer( setCameraLookAt, 1050, 1, v, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
		setCameraMatrix(v, CTF_camPosX, CTF_camPosY, CTF_camPosZ, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
		--setCameraPosition ( v, CTF_camPosX, CTF_camPosY, CTF_camPosZ )
		--setCameraLookAt ( v, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
		fadeCamera ( v, false, 15, 000, 000, 000 )
		toggleAllControls ( v, false, true, false )
		local playerCol = getElementData( v, "col" )
		if ( playerCol ~= nil ) then
			local playerColObject = getElementData( playerCol, "object" )
			local playerColMarker = getElementData( playerCol, "marker" )
			detachElements ( playerColObject, v )
			detachElements ( playerColMarker, v )
			setElementData( playerColObject, "object", nil )
			setElementData( playerColMarker, "marker", nil )
		end
		setElementData( v, "col", nil )
		textDisplayAddObserver ( CTF_spawnChangeDisp, v )
		bindKey ( v, "F3", "down", setPlayerTeam, v, nil )
		setTimer( unbindKey, 10000, 1, v, "F3", "down", setPlayerTeam )
		setTimer( textDisplayRemoveObserver, 10000, 1, CTF_spawnChangeDisp, v )
	end
	setTimer ( destroyElement, 9000, 1, CTF_missionTimer)
	setTimer( CTF_newRound, 10000, 1 )
end


function CTF_newRound()
	triggerEvent( "onRoundFinished", getResourceRootElement(getThisResource()) )
	local blips = getElementsByType ( "blip" )
	for k,v in ipairs(blips) do
		if ( getElementData( v, "playerBlip" ) ) then
			destroyElement( v )
		end
	end
	local cols = getElementsByType ( "colshape" )
	for k,v in ipairs(cols) do
		local colFlag = getElementData( v, "flag" )
		if ( colFlag ) then
			local colObject = getElementData( v, "object" )
			local colMarker = getElementData( v, "marker" )
			local colTeam = getElementData( v, "team" )
			local x,y,z = tonumber( getElementData ( colFlag, "posX" ) ), tonumber( getElementData ( colFlag, "posY" ) ), tonumber( getElementData ( colFlag, "posZ" ) )
			detachElements ( colObject, player )
			detachElements ( colMarker, player )
			setElementPosition( v, x, y, z )
			setElementPosition( colObject, x, y, z )
			setElementPosition( colMarker, x, y, z )
			if ( CTF_blips == "team" ) then
				setElementVisibleTo ( getElementData( v, "blip" ), CTF_root, false )
				setElementVisibleTo ( getElementData( v, "blipTwo" ), CTF_root, false )
			end
		end
	end
	local teams = getElementsByType ( "team", CTF_mapRoot )
	for teamKey,teamValue in ipairs(teams) do
		local nextTeam = teamKey + 1
		if ( nextTeam > #teams ) then
			nextTeam = 1
		end
		local teamPlayers = getPlayersInTeam ( teamValue )
		for playerKey, playerValue in ipairs(teamPlayers) do
			if ( getElementData( playerValue, "CTF_switched" ) == false ) then
				setPlayerTeam ( playerValue, teams[nextTeam] )
				setElementData( playerValue, "CTF_switched", true )
			end
		end
		setElementData( teamValue, "score", 0 )
	end
	updateScores()
	CTF_roundOn = true
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		fadeCamera ( v, true )
		setElementData( v, "CTF_switched", false )
		if ( getPlayerTeam( v ) ~= false ) then
			CTF_spawnPlayer( v )
		else
			CTF_spawnMenu( v )
		end
	end
	if ( CTF_roundTime >= 60000 ) then
		setTimer( CTF_announce, CTF_roundTime-10000, 1, 255, 255, 255, "Ten seconds remaining!", 4000 )
	end
	if ( CTF_roundTime >= 120000 ) then
		setTimer( CTF_announce, CTF_roundTime-60000, 1, 255, 255, 255, "One minute remaining!", 4000 )
	end
	CTF_missionTimer = exports.missiontimer:createMissionTimer (CTF_roundTime,true,true,0.5,20,true,"default-bold",1)
	addEventHandler ( "onMissionTimerElapsed", CTF_missionTimer, CTF_endRound )
end


function CTF_onPlayerJoin ( )
	setElementData( source, "col", nil )
	textDisplayAddObserver ( CTF_scoDisp, source )
	--setCameraMode ( source, "fixed" )
	--setTimer( setCameraPosition, 3000, 1, source, CTF_camPosX, CTF_camPosY, CTF_camPosZ )
	--setTimer( setCameraLookAt, 3250, 1, source, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
	setCameraMatrix( source, CTF_camPosX, CTF_camPosY, CTF_camPosZ, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
	fadeCamera ( source, true )
	setElementData( source, "score", 0 )
	if ( CTF_roundOn ) then
		setTimer( CTF_spawnMenu, 5000, 1, source )
	end
end

function CTF_onPlayerWasted ( totalammo, killer, killerweapon, bodypart )
	-- Increment score of killer
	if ( killer and getElementType( killer ) == "player" ) then
		if ( getPlayerTeam( killer ) ~= getPlayerTeam( source ) ) then
			setElementData( killer, "score", getElementData( killer, "score" ) + 1 )
		else
			setElementData( killer, "score", getElementData( killer, "score" ) - 1 )
		end
	end
	-- Flag stuff
	local player = source --It's important. Trust me.
	CTF_flag_check ()
	-- Handle respawn
	if ( CTF_roundOn ) then
		fadeCamera ( player, false, CTF_respawnTime/500, 000, 000, 000 )
		setTimer( fadeCamera, CTF_respawnTime, 1, player, true )
		setTimer( CTF_spawnPlayer, CTF_respawnTime, 1, player )
	end
end

function CTF_onPlayerQuit ( )
	CTF_flag_check ()
end

function CTF_flag_check ( )
	local playerCol = getElementData( source, "col" )
	local player = source --It's important. Trust me.
	if ( playerCol ~= nil ) then
		local playerColObject = getElementData( playerCol, "object" )
		local playerColMarker = getElementData( playerCol, "marker" )
		local playerColTeam = getElementData( playerCol, "team" )
		local playerColFlag = getElementData( playerCol, "flag" )
		local r,g,b = getTeamColor ( getPlayerTeam( source ) )
	    	local x,y,z = getElementPosition( source )
		detachElements ( playerColObject, source )
		detachElements ( playerColMarker, source )
		setElementPosition( playerCol, x, y, z )
	        setElementPosition( playerColObject, x, y, z )
	        setElementPosition( playerColMarker, x, y, z )
		CTF_announce ( r, g, b, getPlayerName( player ) .. " dropped the " .. getTeamName( playerColTeam ) .. " teams' " .. getElementData( playerColFlag, "name" ) .. " flag!", 4000 )
		setElementData( player, "col", nil )
	end
	toggleControl ( player, "sprint", true )
	destroyBlipsAttachedTo ( player )
	local xi, yi, zi = getElementPosition( player )
	local deathBlip = createBlip ( xi, yi, zi, 0, 2, 200, 200, 200 )
	setTimer( destroyElement, CTF_respawnTime, 1, deathBlip )
end

function CTF_onColShapeHit ( player )
	if ( ( getPlayerName( player ) ~= false ) and ( isPedDead ( player ) == false ) ) then
	local playerTeam = getPlayerTeam( player )
	local playerCol = getElementData( player, "col" )
	local colObject = getElementData( source, "object" )
	local colFlag = getElementData( source, "flag" )
	local colMarker = getElementData( source, "marker" )
	local colTeam = getElementData( source, "team" )
	local r,g,b = getTeamColor ( playerTeam )
	if ( playerTeam == colTeam ) then
		local x,y,z = tonumber( getElementData ( colFlag, "posX" ) ), tonumber( getElementData ( colFlag, "posY" ) ), tonumber( getElementData ( colFlag, "posZ" ) )
		local x2,y2,z2 = getElementPosition( colObject )
		x1,y1,z1 = math.ceil(x),math.ceil(y),math.ceil(z)
		x2,y2,z2 = math.ceil(x2),math.ceil(y2),math.ceil(z2)
		if (( x1 ~= x2) or ( y1 ~= y2 ) or ( z1 ~= z2 )) then
			detachElements ( colObject, player )
			detachElements ( colMarker, player )
			setElementPosition( source, x, y, z )
			setElementPosition( colObject, x, y, z )
			setElementPosition( colMarker, x, y, z )
			CTF_announce ( r, g, b, getPlayerName( player ) .. " returned the " .. getTeamName( colTeam ) .. " teams' " .. getElementData( colFlag, "name" ) .. " flag!", 4000 )
		elseif (playerCol ~= nil) then
	        	setElementData( player, "col", nil )
			local playerColObject = getElementData( playerCol, "object" )
			local playerColFlag = getElementData( playerCol, "flag" )
			local playerColMarker = getElementData ( playerCol, "marker" )
			local playerColTeam = getElementData( playerCol, "team" )
			x,y,z = tonumber( getElementData ( playerColFlag, "posX" ) ), tonumber( getElementData ( playerColFlag, "posY" ) ), tonumber( getElementData ( playerColFlag, "posZ" ) )
			detachElements ( playerColObject, player )
			detachElements ( playerColMarker, player )
			setElementPosition( playerCol, x, y, z )
			setElementPosition( playerColMarker, x, y, z )
			setElementPosition( playerColObject, x, y, z )
			toggleControl ( player, "sprint", true )
			setElementData( playerTeam, "score", getElementData( playerTeam, "score" ) + 1 )
			setElementData( player, "score", getElementData( player, "score" ) + 5 )
			updateScores()
			CTF_announce ( r, g, b, getPlayerName( player ) .. " scores the " .. getTeamName( playerColTeam ) .. " teams' " .. getElementData( playerColFlag, "name" ) .. " flag!", 4000 )
		end
	elseif (playerCol == nil) then
		setElementPosition( source, 0, 0, 0 )
        	setElementData( player, "col", source )
		attachElements ( colObject, player, 0, 0, 0, 0, 0, -90 )
		attachElements ( colMarker, player, 0, 0, 0, 0, 0, 0 )
		toggleControl ( player, "sprint", false )
		CTF_announce ( r, g, b, getPlayerName( player ) .. " took the " .. getTeamName( colTeam ) .. " teams' " .. getElementData( colFlag, "name" ) .. " flag!", 4000 )
	end
	end
end

function CTF_announce ( red, green, blue, text, time )
	textItemSetColor ( CTF_annText, red, green, blue, 255 )
	textItemSetText ( CTF_annText, text )
	if ( CTF_annTimer ) then
		killTimer ( CTF_annTimer )
	else
		local players = getElementsByType( "player" )
		for k,v in ipairs(players) do
			textDisplayAddObserver ( CTF_annDisp, v )
		end
	end
	CTF_annTimer = setTimer( CTF_annRem, time, 1 )
end

function updateScores()
	local teams = getElementsByType( "team", CTF_mapRoot )
	local str=""
	for k,v in ipairs(teams) do
		str = str .. getTeamName( v ) .. ": " .. getElementData( v, "score" ) .. "\n"
	end
	textItemSetText ( CTF_scoText, str )
end

function CTF_annRem()
	CTF_annTimer = nil
	local players = getElementsByType( "player" )
	for k,v in ipairs(players) do
		textDisplayRemoveObserver( CTF_annDisp, v )
	end
end

function CTF_spawnMenu ( player )
	--setCameraMode ( player, "fixed" )
	--setTimer( setCameraPosition, 1000, 1, player, CTF_camPosX, CTF_camPosY, CTF_camPosZ )
	--setTimer( setCameraLookAt, 1050, 1, player, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
	--setCameraPosition ( player, CTF_camPosX, CTF_camPosY, CTF_camPosZ )
	--setCameraLookAt ( player, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
	setCameraMatrix( player, CTF_camPosX, CTF_camPosY, CTF_camPosZ, CTF_camLookX, CTF_camLookY, CTF_camLookZ )
	toggleAllControls ( player, false, true, false )
	if ( CTF_spawnscreen == true ) then
		local last = getElementData( player, "CTF_lastSpawn" )
		if ( last == false ) then
			setElementData( player, "CTF_lastSpawn", 1 )
			last = 1
		end
		textDisplayAddObserver ( CTF_spawnHeaderDisp, player )
		textDisplayAddObserver ( CTF_spawnDisp[last], player )
		bindKey ( player, "enter", "down", CTF_confirmSpawn,  player )
		bindKey ( player, "arrow_l", "down", CTF_changeSpawn, player )
		bindKey ( player, "arrow_r", "down", CTF_changeSpawn, player )
	else
		local teams = getElementsByType( "team", CTF_mapRoot )
		local team = teams[1]
		for teamKey,teamValue in ipairs(teams) do
			if ( table.getn( getPlayersInTeam ( teamValue ) ) < table.getn( getPlayersInTeam ( team ) ) ) then
				team = teamValue
			end
		end
		setPlayerTeam( player, team )
		local r,g,b = getTeamColor ( team )
		CTF_announce ( r, g, b, getPlayerName(player) .. " joined the " .. getTeamName(team) .. " team!", 4000 )
		if ( CTF_roundOn ) then
			setTimer( CTF_spawnPlayer, CTF_respawnTime, 1, player )
		end
	end
end

function CTF_changeSpawn( player, key )
	local last = getElementData( player, "CTF_lastSpawn" )
	textDisplayRemoveObserver ( CTF_spawnDisp[last], player )
	local teams = getElementsByType( "team", CTF_mapRoot )
	if ( key == "arrow_l" ) then last = last - 1 else last = last + 1 end
	if ( last < 1 ) then last = table.getn( teams ) end
	if ( last > table.getn( teams ) ) then last = 1 end
	textDisplayAddObserver ( CTF_spawnDisp[last], player )
	setElementData( player, "CTF_lastSpawn", last )
end

function CTF_confirmSpawn( player )
	local confTeam = getElementData( player, "CTF_lastSpawn" )
	local teams = getElementsByType( "team", CTF_mapRoot )
	local smallest = 1337
	for teamKey,teamValue in ipairs(teams) do
		if ( table.getn( getPlayersInTeam ( teamValue ) ) < smallest ) then
			smallest = table.getn( getPlayersInTeam ( teamValue ) )
		end
	end
	if ( table.getn( getPlayersInTeam ( teams[confTeam] ) ) == smallest ) then
		unbindKey ( player, "enter", "down", CTF_confirmSpawn )
		unbindKey ( player, "arrow_l", "down", CTF_changeSpawn )
		unbindKey ( player, "arrow_r", "down", CTF_changeSpawn )
		textDisplayRemoveObserver ( CTF_spawnHeaderDisp, player )
		textDisplayRemoveObserver ( CTF_spawnDisp[confTeam], player )
		textDisplayRemoveObserver ( CTF_spawnWarningDisp, player )
		setPlayerTeam( player, teams[confTeam] )
		local r,g,b = getTeamColor( teams[confTeam] )
		CTF_announce ( r, g, b, getPlayerName(player) .. " joined the " .. getTeamName(teams[confTeam]) .. " team!", 4000 )
		if ( CTF_roundOn ) then
			CTF_spawnPlayer( player )
		end
	else
		textDisplayAddObserver ( CTF_spawnWarningDisp, player )
		setTimer( textDisplayRemoveObserver, 5000, 1, CTF_spawnWarningDisp, player )
	end
end

function CTF_spawnPlayer( player )
	if ( player ) then
		local team = getPlayerTeam( player )
		if ( team ) then
			local spawnpoints = getChildren ( team, "spawnpoint" )
			call(getResourceFromName("spawnmanager"), "spawnPlayerAtSpawnpoint", player, spawnpoints[ math.random( 1, #spawnpoints ) ] )
			--spawnPlayerAtSpawnpoint ( player, spawnpoints[ math.random( 1, #spawnpoints ) ] )
			local r,g,b = getTeamColor( team )
			setPlayerNametagColor ( player, r, g, b )
			if ( CTF_blips ) then
				local playerBlip = createBlipAttachedTo ( player, 0, 2, r, g, b, 255 )
				setElementData( playerBlip, "playerBlip", true )
				if ( CTF_blips == "team" ) then
					setElementVisibleTo ( playerBlip, CTF_root, false )
					for k,v in ipairs(getPlayersInTeam(team)) do
						setElementVisibleTo ( playerBlip, v, true )
					end
					local cols = getElementsByType ( "colshape" )
					for k,v in ipairs(cols) do
						local colFlag = getElementData( v, "flag" )
						if ( colFlag ) then
							local colTeam = getElementData( v, "team" )
							if ( colTeam == team ) then
								local colObject = getElementData( v, "object" )
								setElementVisibleTo ( getElementData( v, "blip" ), player, true )
								setElementVisibleTo ( getElementData( v, "blipTwo" ), player, true )
							end
						end
					end
				end
			end
			--setCameraMode ( player, "player" )
			setCameraTarget( player, player )
			toggleAllControls ( player, true, true, false )
			for k,v in ipairs(CTF_weapons) do
				giveWeapon ( player, CTF_weapons[k].model, CTF_weapons[k].ammo )
			end
		end
	end
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

addEventHandler( "onResourceStart", CTF_root, CTF_onResourceStart )
addEventHandler( "onPlayerJoin", CTF_root, CTF_onPlayerJoin )
addEventHandler( "onPlayerQuit", CTF_root, CTF_onPlayerQuit )
addEventHandler( "onPlayerWasted", CTF_root, CTF_onPlayerWasted )
addEventHandler( "onColShapeHit", CTF_root, CTF_onColShapeHit )
addEventHandler( "onGamemodeMapStart", CTF_root, CTF_gamemodeMapStart )
addEventHandler( "onGamemodeMapStop", CTF_root, CTF_gamemodeMapStop )
