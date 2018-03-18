-- Capture the Vehicle by BrophY©, if you wish to modify, keep copyright notice and credits in the file
-- Credits to Talidan, Dragon and Ransom for help and testing

local round = 0

addEventHandler('onResourceStart', getResourceRootElement(getThisResource()),
	function()
		exports.scoreboard:addScoreboardColumn('Score')
		table.each(getElementsByType('player'), joinHandler)
	end
)

function joinHandler(player)
	player = player or source
	setElementData(player, 'Score', 0)
	if van then
		triggerClientEvent(player, 'doSetVan', van)
	end
end
addEventHandler('onPlayerJoin', root, joinHandler)

addEventHandler('onResourceStop', getResourceRootElement(getThisResource()),
	function()
		exports.scoreboard:removeScoreboardColumn('Score')
	end
)

function onCTVMapStart (startedMap)
	local mapRoot = getResourceRootElement(startedMap)
	for k,v in ipairs(getElementsByType "player") do
		bindKey ( v, "l", "down", "Toggle vehicle lights" )
	end
	for k,v in ipairs(getElementsByType ( "base", mapRoot )) do
		if getElementData ( v, "team" ) == "team1" then
			baseTeamb1 = v
		elseif getElementData ( v, "team" ) == "team2" then
			baseTeamb2 = v
		elseif getElementData ( v, "team" ) == "team3" then
			baseTeamb3 = v
		elseif getElementData ( v, "team" ) == "team4" then
			baseTeamb4 = v
		end
	end
	--team1
	local team1markerX = getElementData ( baseTeamb1, "markerX" )
	local team1markerY = getElementData ( baseTeamb1, "markerY" )
	local team1markerZ = getElementData ( baseTeamb1, "markerZ" )
	local team1markercolor = getElementData ( baseTeamb1, "markercolor" )
	local team1markerblip = getElementData ( baseTeamb1, "blip" )
	local team1col1 = gettok ( team1markercolor, 1, 44 )
	local team1col2 = gettok ( team1markercolor, 2, 44 )
	local team1col3 = gettok ( team1markercolor, 3, 44 )
	--team2
	local team2markerX = getElementData ( baseTeamb2, "markerX" )
	local team2markerY = getElementData ( baseTeamb2, "markerY" )
	local team2markerZ = getElementData ( baseTeamb2, "markerZ" )
	local team2markercolor = getElementData ( baseTeamb2, "markercolor" )
	local team2markerblip = getElementData ( baseTeamb2, "blip" )
	local team2col1 = gettok ( team2markercolor, 1, 44 )
	local team2col2 = gettok ( team2markercolor, 2, 44 )
	local team2col3 = gettok ( team2markercolor, 3, 44 )
	--team3
	local team3markerX = getElementData ( baseTeamb3, "markerX" )
	local team3markerY = getElementData ( baseTeamb3, "markerY" )
	local team3markerZ = getElementData ( baseTeamb3, "markerZ" )
	local team3markercolor = getElementData ( baseTeamb3, "markercolor" )
	local team3markerblip = getElementData ( baseTeamb3, "blip" )
	local team3col1 = gettok ( team3markercolor, 1, 44 )
	local team3col2 = gettok ( team3markercolor, 2, 44 )
	local team3col3 = gettok ( team3markercolor, 3, 44 )
	--team4
	local team4markerX = getElementData ( baseTeamb4, "markerX" )
	local team4markerY = getElementData ( baseTeamb4, "markerY" )
	local team4markerZ = getElementData ( baseTeamb4, "markerZ" )
	local team4markercolor = getElementData ( baseTeamb4, "markercolor" )
	local team4markerblip = getElementData ( baseTeamb4, "blip" )
	local team4col1 = gettok ( team4markercolor, 1, 44 )
	local team4col2 = gettok ( team4markercolor, 2, 44 )
	local team4col3 = gettok ( team4markercolor, 3, 44 )

	capture1 = createMarker ( tonumber(team1markerX), tonumber(team1markerY), tonumber(team1markerZ), "cylinder", 4, tonumber(team1col1), tonumber(team1col2), tonumber(team1col3), 127 )
	capture2 = createMarker ( tonumber(team2markerX), tonumber(team2markerY), tonumber(team2markerZ), "cylinder", 4, tonumber(team2col1), tonumber(team2col2), tonumber(team2col3), 127 )
	capture3 = createMarker ( tonumber(team3markerX), tonumber(team3markerY), tonumber(team3markerZ), "cylinder", 4, tonumber(team3col1), tonumber(team3col2), tonumber(team3col3), 127 )
	capture4 = createMarker ( tonumber(team4markerX), tonumber(team4markerY), tonumber(team4markerZ), "cylinder", 4, tonumber(team4col1), tonumber(team4col2), tonumber(team4col3), 127 )
	createBlipAttachedTo ( capture1, tonumber(team1markerblip) )
	createBlipAttachedTo ( capture2, tonumber(team2markerblip) )
	createBlipAttachedTo ( capture3, tonumber(team3markerblip) )
	createBlipAttachedTo ( capture4, tonumber(team4markerblip) )
	setElementData(capture1, "teamName", getElementData(baseTeamb1, "teamName"))
	setElementData(capture2, "teamName", getElementData(baseTeamb2, "teamName"))
	setElementData(capture3, "teamName", getElementData(baseTeamb3, "teamName"))
	setElementData(capture4, "teamName", getElementData(baseTeamb4, "teamName"))

	setWeather ( 14 )
	setTime ( 5, 30 )
	startRound ()
end

function onCtvChat ( message, theType )
	if ( theType == 0 ) then
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

function startRound ()
	for k,v in ipairs(getElementsByType"vehicle") do --do it for all vehicles besides the target
		toggleVehicleRespawn(v,true)
		setVehicleIdleRespawnDelay ( v, 45000 )
		setVehicleRespawnDelay ( v, 2500 )
	end

	nextRound()

	for k,v in ipairs(getElementsByType "player") do
		setElementData(v, 'Score', 0)
		fadeCamera ( v, false, 1.0, 0, 0, 0 )
		setTimer ( fadeCamera, 1000, 1, v, true, 1 )
		setTimer ( spawnScreen, 1000, 1, v )
	end
end

function nextRound ()
	round = round + 1
	--get a table of all the "target" elements from the .map
	local allTargets = getElementsByType ( "target" )
	--get a random number between 1, and the total number of rows in the table
	randomVehicle = math.random(1,#allTargets)
	--call the spawn van function, with the random target element as an argument
	spawnVan ( allTargets[randomVehicle] )

	showTextForAll ( 5000, 0.5, 0.1, 100, 100, 255, 255, 2, "Capture the Vehicle: Round "..round.."" )
end

function endRound ()
	destroyBlipsAttachedTo ( van )
	destroyElement ( van )
	destroyElement ( vanMarker )
	van = nil
	setTimer( nextRound, 5000, 1 )
end

function spawnVan ( target )
	--get the location from the target element
	local x = getElementData ( target, "posX" )
	local y = getElementData ( target, "posY" )
	local z = getElementData ( target, "posZ" )
	--get the rotation from the target element
	local rx = getElementData ( target, "rotX" )
	local ry = getElementData ( target, "rotY" )
	local rz = getElementData ( target, "rotZ" )
	--get other stuff
	local model = getElementData ( target, "model" ) --id
	local platetext = getElementData ( target, "plate" ) --plate text
	local colours = getElementData ( target, "colors" ) --colours of vehicle
	local pj = getElementData ( target, "paintjob" ) --paintjob
	local upgrades = getElementData ( target, "upgrades" ) --paintjob
	---seperate the colours string and get specific colour ids
	local col1, col2, col3, col4 = colours and colours:match('^(%w+),(%w+),(%w+),(%w+)$')
	--if any of them are "ran", then make them into a random id
	if col1 == "ran" or not col1 then col1 = math.random(0,126) end
	if col2 == "ran" or not col2 then col2 = math.random(0,126) end
	if col3 == "ran" or not col3 then col3 = math.random(0,126) end
	if col4 == "ran" or not col4 then col4 = math.random(0,126) end
	--if any of the rotations are not specified, make them 0
	rx = rx or 0
	ry = ry or 0
	rz = rz or 0

	--finally, create the vehicle and define it as van
	if ( platetext ) then
		van = createVehicle ( model, x, y, z, rx, ry, rz, platetext )
	else
		van = createVehicle ( model, x, y, z, rx, ry, rz )
	end
	setElementHealth(van, 2000)
	--if a paintjob was specified, add it
	if ( pj ) then
		setVehiclePaintjob ( van, pj )
	end
	--if there were any mods
	if ( upgrades ) then
		--split the upgrades into a table
		allUpgrades = split ( upgrades, 44 )
		for k,v in ipairs(allUpgrades) do --loop through the table
			addVehicleUpgrade ( van, v ) --and add each upgrade
		end
	end

	vanMarker = createMarker ( x, y, z, "checkpoint", 1.5, 255, 255, 255, 127 )
	attachElements ( vanMarker, van )

	createBlipAttachedTo ( van, 55 )
	triggerClientEvent('doSetVan', van)
end

addEvent('onVanDrown', true)
addEventHandler('onVanDrown', root,
	function()
		if getElementHealth(van) > 250 then
			blowVehicle(van)
			triggerEvent('onVehicleExplode', van)
		end
	end
)

function vehicleExplode ()
	if source == van then
		showTextForAll ( 5000, 0.5, 0.1, 100, 100, 255, 255, 2, "The vehicle has been destroyed!" )
		endRound()
	end
end

function showTextForAll ( ... )
	for i, player in ipairs(getElementsByType("player")) do
		showTextForPlayer ( player, ... )
	end
end

local currDisplay = {}  --stores current textdisplay, per player
local currTextItem = {} --stores current textitem, per player
local currTextItemShadow = {} --stores current textitem shadow, per player
local displayTimer = {} --stores timer to remove the current display, per player

function removeTextForPlayer ( player )
	textDestroyDisplay ( currDisplay[player] )
	textDestroyTextItem ( currTextItem[player] )
	textDestroyTextItem ( currTextItemShadow[player] )

	currDisplay[player] = nil
	currTextItem[player] = nil
	if displayTimer[player] then
		killTimer(displayTimer[player])
		displayTimer[player] = nil
	end
end

function showTextForPlayer ( player, time, x, y, red, green, blue, alpha, scale, text )
	if currDisplay[player] then
		removeTextForPlayer ( player )
	end

	currDisplay[player] = textCreateDisplay ()
	currTextItemShadow[player] = textCreateTextItem ( text, x + .002, y + .002, "medium", 0, 0, 0, alpha, scale, "center" )
	currTextItem[player] = textCreateTextItem ( text, x, y, "medium", red, green, blue, alpha, scale, "center" )
	textDisplayAddText ( currDisplay[player], currTextItemShadow[player] )
	textDisplayAddText ( currDisplay[player], currTextItem[player] )
	textDisplayAddObserver ( currDisplay[player], player )

	displayTimer[player] = setTimer(removeTextForPlayer, time, 1, player)
end


function playerEnterVehicle( vehicle, seat, playerJacked )
	if ( vehicle == van ) and ( seat == 0 ) then
		local team = getPlayerTeam( source )
		local r, g, b = getTeamColor( team )
		showTextForAll ( 5000, 0.5, 0.1, r, g, b, 200, 2.5, getTeamName(team).."s have the vehicle!" )
		setMarkerColor ( vanMarker, r, g, b, 255 )
		vanPlayer = source
		triggerClientEvent('doAdaptHealthBar', root)
	end
end

function playerExitVehicle( vehicle, seat, playerJacked )
	if ( vehicle == van ) and ( seat == 0 ) then
		--outputChatBox ( "PLAYER = " .. getClientName(source) )
		local team = getPlayerTeam( source )
		if team then
			local r, g, b = getTeamColor( team )
			showTextForAll ( 5000, 0.5, 0.1, r, g, b, 200, 2.5, getTeamName(team).."s have lost the vehicle!" )
		end
		setMarkerColor ( vanMarker, 255, 255, 255, 255 )
		vanPlayer = nil
		triggerClientEvent('doAdaptHealthBar', root)
	end
end

addEventHandler('onPlayerWasted', root,
	function(ammo, killer)
		if source == vanPlayer then
			playerExitVehicle(van, 0, false)
		end
		if not killer or not isElement(killer) or getElementType(killer) ~= 'player' then
			return
		end
		if getPlayerTeam(source) ~= getPlayerTeam(killer) then
			if van and source == getVehicleController(van) then
				addPlayerScore(killer, 5)
			else
				addPlayerScore(killer, 1)
			end
		else
			addPlayerScore(killer, -1)
		end
	end
)

addEventHandler('onPlayerQuit', root,
	function()
		if source == vanPlayer then
			playerExitVehicle(van, 0, false)
		end
	end
)

function markerHit ( player )
	if not van then
		return
	end
	local vanController = getVehicleController( van )
	if player == vanController then
		if source == capture1 or source == capture2 or source == capture3 or source == capture4 then
			local team = getPlayerTeam( vanController )
			local markerTeamName = getElementData(source, "teamName")
			local teamName = getTeamName( team )
			if (markerTeamName == teamName) then
				local r, g, b = getTeamColor( team )
				showTextForAll ( 5000, 0.5, 0.1, r, g, b, 200, 2.5, teamName .. " have captured the vehicle!" )
				addPlayerScore(player, 10)
				endRound()
			end
		end
	end
end

function killplayer ( source )
	killPed ( source )
end

function toggleVehicleLights ( player, key, state )
	if ( getPedOccupiedVehicleSeat ( player ) == 0 ) then
		local veh = getPedOccupiedVehicle ( player )
		if ( getVehicleOverrideLights ( veh ) ~= 2 ) then
			setVehicleOverrideLights ( veh, 2 )
		else
			setVehicleOverrideLights ( veh, 1 )
		end
	end
end

addEventHandler( "onGamemodeMapStart", getRootElement (), onCTVMapStart )
addEventHandler ( "onVehicleExplode", root, vehicleExplode )
addEventHandler ( "onPlayerVehicleEnter", root, playerEnterVehicle )
addEventHandler ( "onPlayerVehicleExit", root, playerExitVehicle )
addEventHandler ( "onMarkerHit", root, markerHit )
addEventHandler ( "onPlayerChat", root, onCtvChat )

addCommandHandler ( "kill", killplayer )
addCommandHandler ( "Toggle vehicle lights", toggleVehicleLights )

function addPlayerScore(player, points)
	setElementData(player, 'Score', getElementData(player, 'Score') + points)
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

function table.each(t, callback, ...)
	for k,v in pairs(t) do
		callback(v, ...)
	end
	return t
end
