
assaultTimers = {}

--[[
This one is called when a map is loaded. It reads the mapfile, creates the text displays and
lets player choose their teams, starting the first round afterwards
]]
function startAssaultMap(startedMap)
	local mapRoot = getResourceRootElement(startedMap)
	outputDebugString("Starting assault map..")
	if (readOptions(startedMap) == false) then
		outputChatBox("Error loading map")
		return
	end

	setWeather(options.weather)

	-- simulate the end of a round
	attacker = team2

	-- Create Objectives Text items
	removeTextItems()
	objectiveTextItem = {}
	objectiveTextItemShadow = {}
	local pos = 0.3
	for k,v in ipairs(options.objective) do
		--outputChatBox("created textdisplay for "..v.name)
		-- Objectives on the right
		--objectiveTextItem[k] = textCreateTextItem(v.name, 0.92, pos, "low", 255,255,255,255,1.4,"right")
		--objectiveTextItemShadow[k] = textCreateTextItem(v.name, 0.921, pos + 0.001, "low", 0, 0, 0, 255, 1.4,"right")

		-- Objectives on the left
		objectiveTextItem[k] = textCreateTextItem(v.name, 0.04, pos, "low", 255,255,255,255,1.4,"left")
		objectiveTextItemShadow[k] = textCreateTextItem(v.name, 0.041, pos + 0.001, "low", 0, 0, 0, 255, 1.4,"left")

		textDisplayAddText( statusDisplay, objectiveTextItemShadow[k] )
		textDisplayAddText( statusDisplay, objectiveTextItem[k] )
		pos = pos + 0.03
	end

	-- Remove player from noMapLoadedDisplay, fadeCamera and show team select display
	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		fadeCamera(v,true)
		setNoMapLoaded( v, false )
		selectTeam( v )
		--outputConsole(getClientName(v))
		triggerClientEvent2( v, "assaultCreateGui", options )
	end

	noMapLoaded = false

	startRound()
end
--[[
Removes all required map-based settings when a map is stopped (but only if the resource wasnt stopped too)
]]
function stopAssaultMap()
	--outputDebugString(getResourceState(getResourceFromName("assault")))
	--outputDebugString(tostring(isElement(noMapLoadedDisplay)))
	outputDebugString("Stopping assault map..")


	noMapLoaded = true

	clearAllObjectives()
	removeTextItems()

	for k,v in pairs(assaultTimers) do
		if (isTimer(v)) then killTimer(v) end
	end

	-- Stop round timer
	--if (isTimer(assaultTimers.updateTimeLeft)) then
	--	killTimer(assaultTimers.updateTimeLeft)
	--end
	-- Add all players to noMapLoadedDisplay/toggleAllControls
	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		setNoMapLoaded( v, true )
		textDisplayRemoveObserver( waitingDisplay, v )
		textDisplayRemoveObserver( waitingDisplay2, v )

		--toggleAllControls( v, false )
	end
end

function stopAssault()
	outputDebugString("Stopping assault..")
	removeEventHandler( "onGamemodeMapStop", getRootElement(), stopAssaultMap )
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "score")
end

function removeTextItems()
-- Destroy map specific textitems
	if (objectiveTextItem == nil) then return end
	for k,v in ipairs(objectiveTextItem) do
		--textDisplayRemoveText(statusDisplay,v)
		--textDisplayRemoveText(objectiveTextItemShadow[k],statusDisplay)
		textDestroyTextItem(objectiveTextItemShadow[k])
		textDestroyTextItem(v)
		--outputChatBox("removing textitem")
	end
end

function setNoMapLoaded( player, bool )
	if (isElement(noMapLoadedDisplay) == false) then return end

	if (bool == true) then
		textDisplayAddObserver( noMapLoadedDisplay, player )

	else
		setTimer(textDisplayRemoveObserver,1000,1,noMapLoadedDisplay, player )

	end
end

--[[
This one prepares Assault when it is started. It creates the required teams, does some basic settings
and shows a text display as long as no map is loaded
]]
function startAssault(resource)

	noMapLoaded = true

	--outputChatBox("Now playing assault..")

	team1 = createTeam("Red",255,0,0)
	team2 = createTeam("Blue",0,0,255)
	team1Name = "Red"
	team2Name = "Blue"

	setTeamFriendlyFire( team1, false )
	setTeamFriendlyFire( team2, false )


	statusDisplay = textCreateDisplay()
	timeLeftTextItem = textCreateTextItem( "", 0.5, 0.02, "low", 255,255,255,255,1.8, "center" )
	textDisplayAddText( statusDisplay, timeLeftTextItem )

	waitingCreateDisplay()
	selectTeamCreateDisplay()

	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		textDisplayAddObserver( statusDisplay, v )
		setNoMapLoaded( v, true )
		setElementDataLocal(v,"assaultToggleLogo",false)
		setElementDataLocal(v,"assaultCreateGui",false)
		setElementDataLocal(v,"assaultClientScriptLoaded",false)
		setPlayerHudComponentVisible( v, "money", false )
	end

	attackerDisplay = textCreateDisplay()
	defenderDisplay = textCreateDisplay()

	team1Display = textCreateDisplay()
	team2Display = textCreateDisplay()


	--nextObjectiveText = textCreateTextItem("Next Objective: ", 0.5, 0.94, "low", 255,255,255,255, 1.2, "center")
	--textDisplayAddText( attackerDisplay, nextObjectiveText )


	--defenderText = textCreateTextItem("Prevent the attackers from reaching their objectives",0.5,0.94,"low",255,255,255,255,1.2,"center")
	--textDisplayAddText( defenderDisplay, defenderText )

	team1Text = textCreateTextItem("You are on: Red", 0.04, 0.24, "low", 255,0,0,255, 1.2, "left")
	team2Text = textCreateTextItem("You are on: Blue", 0.04, 0.24, "low", 0,0,255,255, 1.2, "left")
	textDisplayAddText( team1Display, team1Text )
	textDisplayAddText( team2Display, team2Text )

	roundText = textCreateTextItem( "Round 1/2", 0.5, 0.048, "low", 255,255,255,255,1.2, "center" )
	textDisplayAddText( statusDisplay, roundText )

	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "score")

	--startAssaultMap(resource)
end

-- function updateTimeLeft()
	-- timeLeft = timeLeft - 1
	-- textItemSetText(timeLeftTextItem,calcTime(timeLeft))
	-- if (timeLeft <= 0) then
		-- killTimer(assaultTimers.updateTimeLeft)
		-- endRound()
	-- end
-- end

--[[
Prepares the round to be started
]]
function startRound()
	for k,v in ipairs(objectives) do
		textItemSetColor(objectiveTextItem[k],255,255,255,255)
	end
	clearAllObjectives()
	respawnAllVehicles()
	progress = 1
	waiting = true

	if (attacker == team1) then
		attacker = team2
		timeLimit = timeReachedBefore
		textItemSetText(roundText,"Round 2/2")
	elseif (attacker == team2) then
		attacker = team1
		timeLimit = options.timelimit
		textItemSetText(roundText,"Round 1/2")
	end

	createObjectives()

	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		triggerClientEvent2(v,"assaultNextRound",attacker)
		if (getPlayerTeam(v)) then
			waitForStart(v)
			textDisplayRemoveObserver( waitingDisplay2, v )
		end
	end
	assaultTimers.startRoundNow = setTimer( startRoundNow, 4000, 1 )
end
--[[
Actually starts the round and spawns the players
]]
function startRoundNow()
	triggerEvent("onAssaultStartRound",getRootElement(),attacker)
	if (options.time ~= false) then setTime(gettok(options.time,1,58),gettok(options.time,2,58)) end
	waiting = false
	timeLeft = timeLimit
	-- if (isTimer(assaultTimers.updateTimeLeft)) then killTimer(assaultTimers.updateTimeLeft) end
	-- assaultTimers.updateTimeLeft = setTimer(updateTimeLeft,1000,timeLimit)
	g_missionTimer = exports.missiontimer:createMissionTimer (timeLimit*1000,true,false,0.5,20,true,"default-bold",1)
	addEventHandler ( "onMissionTimerElapsed", g_missionTimer, function() endRound(false) end )
	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		if (getPlayerTeam(v)) then
			spawnPlayerTeam( v )
		end
		toggleAllControls( v, true )
		setElementData(v,"score",0)
	end
end

function waitForStart( player )
	if (isPedInVehicle( player )) then
		removePedFromVehicle( player ) end

	textDisplayAddObserver( waitingDisplay, player )
	--setCameraMode( player, "fixed" )
	--setCameraPosition( player, 0, 0, 20 )
	--setCameraLookAt( player, -33.486911773682, 35.214984893799, 4 )
	--setTimer(setCameraPosition,1000,1,player,options.camera["spawn"].posX,options.camera["spawn"].posY,options.camera["spawn"].posZ)
	--setTimer(setCameraLookAt,1000,1,player, options.camera["spawn"].targetX, options.camera["spawn"].targetY, options.camera["spawn"].targetZ )
	--triggerClientEvent(player,"customSetCamera", player, 0, 0, 20,  -33.486911773682, 35.214984893799, 4 )
	--toggleAllControls( player, false )
	setCameraMatrix(player,options.camera["spawn"].posX,options.camera["spawn"].posY,options.camera["spawn"].posZ,options.camera["spawn"].targetX, options.camera["spawn"].targetY, options.camera["spawn"].targetZ)
end

function waitEndRound( player )
	if (isPedInVehicle( player )) then
		removePedFromVehicle( player ) end

	textDisplayAddObserver( waitingDisplay2, player )
	--setCameraMode( player, "fixed" )
	--setTimer(setCameraPosition,1000,1,player,options.camera["finish"].posX,options.camera["finish"].posY,options.camera["finish"].posZ)
	--setTimer(setCameraLookAt,1000,1,player, options.camera["finish"].targetX, options.camera["finish"].targetY, options.camera["finish"].targetZ )
	setCameraMatrix(player,options.camera["finish"].posX,options.camera["finish"].posY,options.camera["finish"].posZ, options.camera["finish"].targetX, options.camera["finish"].targetY, options.camera["finish"].targetZ)
end
--[[
This one is called when the round ended and checks if already both rounds were played, if so which team won and so on.
It also starts the new round after some delay..
]]
function endRound(conquered)

	waiting = true

	-- killTimer(assaultTimers.updateTimeLeft)
	setTimer ( destroyElement, 9000, 1, g_missionTimer )
	local text = ""
	local timeLeft = math.max(exports.missiontimer:getMissionTimerTime ( g_missionTimer )/1000, 0)
	if (attacker == team1) then
		timeReachedBefore = timeLimit - timeLeft
		if not conquered then
			-- team 1 failed to attack in round 1
			text = team2Name.." "..options.defendedMessage..""
			team1Succeded = false
		else
			-- team 1 successfully attacked in round 1
			text = team1Name.." "..options.conqueredMessage.." in "..calcTime(timeReachedBefore)
			team1Succeded = true
		end
	elseif (attacker == team2) then
		setTimer(triggerEvent, 10000, 1, "onRoundFinished", getResourceRootElement(getThisResource()))
		if not conquered then
			-- team 1 successfully defended in round 2 and...
			if team1Succeded then
				-- ...successfully attacked in round 1
				text = team1Name.." "..options.defendedMessage.."! "..team1Name.." wins!"
			else
				-- ...failed the attack in round 1
				text = team1Name.." "..options.defendedMessage.."! Tie!"
			end
		else
			-- team 1 failed to defend in round 2 and...
			if team1Succeded then
				-- ...successfully attacked in round 1
				text = team2Name.." "..options.conqueredMessage.." in "..calcTime(timeLimit - timeLeft).."! Tie!"
			else
				-- ...failed to attack in round 1
				text = team2Name.." "..options.conqueredMessage.." in "..calcTime(timeLimit - timeLeft).."! "..team2Name.." wins!"
			end
		end
	end
	triggerEvent("onAssaultEndRound",getRootElement(),conquered)
	textItemSetText(waitingText2,text)
	textItemSetText(waitingText2_2,text)
	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		if (getPlayerTeam(v)) then
			waitEndRound( v )
		end
	end
	assaultTimers.startRound = setTimer(startRound, 10000, 1)


end

--[[
####

Objectives

####
]]

-- As soon as an objective (marker) is hit, this one is called and acts based on the objective settings
function onObjectiveHit( player )
	if (getElementType(player) == "player") then
		local team = getPlayerTeam(player)
		if (team ~= attacker) then return end
		objectiveId = getObjectiveIdFromElement( source )
		if (objectiveId ~= false) then
			local thisObjective = options.objective[status[objectiveId].key]

			if (thisObjective.captureType == "foot") then
				if (isPedInVehicle(player) == true) then
					outputChatBox("You need to be on foot to activate this objective!",player,255,0,0)
					return
				end
			elseif (thisObjective.captureType == "vehicle") then
				if (isPedInVehicle(player) == false) then
					outputChatBox("You need to be in a vehicle to activate this objective!",player,255,0,0)
					return
				end
			end

			if (thisObjective.stay > 0) then
				--outputChatBox("meh")
				if (objectiveTimer[objectiveId] == nil) then
					objectiveTimer[objectiveId] = setTimer(objectiveCount,1000,0,objectiveId)
					--outputChatBox("start timer")
					local stay = options.objective[status[objectiveId].key].stay
					local progress = status[objectiveId].count
					showProgress( player, objectiveId, true, progress, stay )
				end
			else
				local playerTable = {player}
				objectiveReached( objectiveId, playerTable )
			end
		end
	end
end
-- This one is triggered when a player leaves the objective and stops the objective countdown if necessary
function onObjectiveLeave( player )
	if (getElementType(player) == "player") then
		objectiveId = getObjectiveIdFromElement( source )
		showProgress(player, objectiveId, false)
	end
end
-- Counts the time players are in an objective, if it has a timelimit
function objectiveCount(objectiveId)
	if (waiting) then
		stopObjectiveTimer(objectiveId)
		hideProgressForAll(objectiveId)
		return
	end

	if (isElement(status[objectiveId].colShape) == false) then
		stopObjectiveTimer(objectiveId)
		return
	end
	local allPlayers = getElementsWithinColShape( status[objectiveId].colShape, "player" )
	-- colShape is empty or does not exist - stop timer
	if (#allPlayers == 0 or allPlayers == false) then
		stopObjectiveTimer(objectiveId)
		return
	end

	local countPlayers = 0
	local playerTable = {}

	local captureTypeBool = nil
	local thisObjective = options.objective[status[objectiveId].key]
	if (thisObjective.captureType == "foot") then captureTypeBool = true
	elseif (thisObjective.captureType == "vehicle") then captureTypeBool = false end

	for k,v in ipairs(allPlayers) do
		local team = getPlayerTeam(v)
		if (isPedDead(v) == false and team == attacker and isPedInVehicle(v) ~= captureTypeBool) then
			countPlayers = countPlayers + 1
			playerTable[#playerTable+1] = v
		end
	end

	local addPerPlayer = 1
	if (countPlayers > 1) then addPerPlayer = 1/countPlayers + 0.25 end
	status[objectiveId].count = status[objectiveId].count + countPlayers * addPerPlayer

	if (countPlayers == 0) then
		stopObjectiveTimer(objectiveId)
		return
	end

	local stay = options.objective[status[objectiveId].key].stay
	local progress = status[objectiveId].count
	if (progress > stay) then progress = stay end
	for k,v in ipairs(playerTable) do
		showProgress(v, objectiveId, true, progress, stay)
	end
	if (status[objectiveId].count >= stay) then
		objectiveReached(objectiveId, playerTable)
	end
end
-- Shows a gui with a progressbar based on the percentage this objective is already done
function showProgress(player, objectiveId, bool, progress, total )
	local thisObjective = options.objective[status[objectiveId].key]
	if (thisObjective.stay == 0) then return false end
	local stayText = options.objective[status[objectiveId].key].stayText
	triggerClientEvent( player, "assaultShowProgress", player, objectiveId, bool, progress, total, stayText )
end
-- Hides the progressbar for all players
function hideProgressForAll(objectiveId)
	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		showProgress(v,objectiveId,false)
	end
end
-- Hides the progress for a single player
function hideProgressForPlayer(player)
	for k,v in ipairs(status) do
		showProgress(player,k,false)
	end
end
-- Stops the objectives timer
function stopObjectiveTimer(objectiveId)
	--outputChatBox("stop timer")
	if (isTimer(objectiveTimer[objectiveId])) then killTimer(objectiveTimer[objectiveId]) end
	objectiveTimer[objectiveId] = nil
end
-- Returns the objective id from a colshape
function getObjectiveIdFromElement( element )
	local objectiveId = false
	for k,v in pairs(status) do
		if (v.colShape == source) then
			objectiveId = k
		end
	end
	return objectiveId
end
-- This function can be used by external scripts to trigger an objective. It is still checked if it is even possible to do so though.
function triggerObjective( objectiveId, playerTable )
	local req = options.objective[status[objectiveId].key].req
	if (status[objectiveId].reached == false and checkRequired(req) == true) then
		objectiveReached( objectiveId, playerTable )
		return true
	end
	return false
end
-- When an objective is reached (hit for one without timelimit, or the timelimit passed) this one is called and shows messages
-- activates the next objectives and so on.
function objectiveReached( objectiveId, playerTable )
	if (waiting) then
		clearObjective(objectiveId)
		return
	end
	if (playerTable == nil) then playerTable = {} end

	for k,v in ipairs(playerTable) do
		addPoints(v,10)
	end

	clearObjective(objectiveId)

	status[objectiveId].reached = true
	local key = status[objectiveId].key

	textItemSetColor(objectiveTextItem[key],255,0,0,255)

	local objectiveReached = options.objective[key]
	triggerEvent("onAssaultObjectiveReached",getRootElement(),objectiveReached, playerTable)

	progress = progress + 1

	-- Finished map?
	if (options.finishType == "all") then
		if (allObjectivesReached() == true) then
			endRound(true)
		end
	elseif (options.finishType == "objective") then
		if (objectiveId == options.finishObjective) then
			endRound(true)
		end
	end

	createObjectives()

	local defender
	if (attacker == team1) then defender = team2 else defender = team1 end
	local teamName = nil
	if (attacker == team1) then teamName = team1Name else teamName = team2Name end


	local messageForAttacker = "Objective '"..objectiveReached.name.."' reached"
	local messageForDefender = "Objective '"..objectiveReached.name.."' reached"

	if (objectiveReached.name == "") then
		messageForAttacker = ""
		messageForDefender = ""
	end

	if (objectiveReached.successText ~= "") then
		messageForAttacker = string.gsub(objectiveReached.successText,"~team~",teamName)
		messageForDefender = string.gsub(objectiveReached.successText,"~team~",teamName)
	end
	if (objectiveReached.successTextForDefender ~= "") then
		messageForDefender = string.gsub(objectiveReached.successTextForDefender,"~team~",teamName)
	end


	if (messageForAttacker ~= "") then
		showTextForTeam(attacker,2000,255,255,255,1.4,0.6,messageForAttacker)
	end
	if (messageForDefender ~= "") then
		showTextForTeam(defender,2000,255,255,255,1.4,0.6,messageForDefender)
	end
end
-- Removes all elements of an objective (e.g. when its reached)
function clearObjective( objectiveId )
	hideProgressForAll(objectiveId)
	stopObjectiveTimer(objectiveId)
	local colShape = status[objectiveId].colShape
	local marker = status[objectiveId].marker
	local blip = status[objectiveId].blip
	if (colShape ~= nil) then removeEventHandler ( "onColShapeHit", colShape, onObjectiveHit ) end
	if (isElement(marker)) then destroyElement(marker) end
	if (isElement(colShape)) then destroyElement(colShape) end
	if (isElement(blip)) then destroyElement(blip) end
	status[objectiveId].colShape = nil
	status[objectiveId].marker = nil
	status[objectiveId].blip = nil
end
-- Removes all objectives (e.g. when the round ends due to timelimit)
function clearAllObjectives()
	for k,v in pairs(status) do
		if (v.colShape ~= nil) then
			clearObjective( k )
		end
		status[k].reached = false
		status[k].created = false
		status[k].count = 0
	end
	objectiveTimer = {}
end
-- Creates all objectives that have not already be done and that meet the requirements to be created
function createObjectives()
	local nextObjectives = getNextObjectives()
	createNextObjectiveText()
	local i = 0
	for k,v in pairs(nextObjectives) do
		local objective = options.objective[k]
		--if (i == 0) then
		--	i = 1
		--	--textItemSetText(nextObjectiveText,"Next Objective: '"..objective.name.."' "..objective.description)
		--end
		textItemSetColor(objectiveTextItem[k],0,255,0,255)
		if (objective.forcedRespawn == "both") then
			forcedRespawn()
		end
		--outputChatBox(objective.name)
		if (objective.type == "checkpoint") then
			createObjectiveMarker( objective )
			triggerEvent("onAssaultCreateObjective",getRootElement(),objective)
		elseif (objective.type == "custom") then
			triggerEvent("onAssaultCreateObjective",getRootElement(),objective)
		end
		status[objective.id].created = true
	end
end
-- Creates the marker and colshape for a single objective
function createObjectiveMarker( objective )
	local x = 	objective.posX
	local y = 	objective.posY
	local z = 	objective.posZ
	objectiveMarker = createMarker(x, y, z, objective.markerType,2,255,128,64)
	if objective.interior then
		setElementInterior(objectiveMarker, objective.interior)
	end
	status[objective.id].marker = objectiveMarker
	--objectiveMarkerColShape = getElementColShape(objectiveMarker)
	objectiveMarkerColShape = createColTube(x,y,z,2,2)
	status[objective.id].colShape = objectiveMarkerColShape
	objectiveBlip = createBlip(x,y,z,0,2,255,128,64,255)
	status[objective.id].blip = objectiveBlip

	addEventHandler ( "onColShapeHit", objectiveMarkerColShape, onObjectiveHit )
	addEventHandler ( "onColShapeLeave", objectiveMarkerColShape, onObjectiveLeave )
end

--[[
Returns an array of all objectives that haven't been done yet but meet the requirements to be done next
]]
function getNextObjectives()
	local output = {}
	for k,v in ipairs(options.objective) do
		if (status[v.id].reached == false and status[v.id].colShape == nil and status[v.id].created ~= true) then
			if (checkRequired(v.req) == true) then
				output[k] = true
				--status[v.id].created = true
			end
		end
	end
	return output
end
-- Checks the requirements and returns true they are all met, false otherwise
function checkRequired( requiredString )
	local requiredTable = split(requiredString, 44)
	local ok = true
	for k,v in ipairs(requiredTable) do
		if (status[v].reached == false) then
			ok = false
		end
	end
	return ok
end
-- Simply checks if all objectives are reched
function allObjectivesReached()
	for k,v in pairs(status) do
		if (v.reached == false) then return false end
	end
	return true
end

function createNextObjectiveText(player)
	local objectivesTable = {}
	local i = 0
	for k,v in ipairs(options.objective) do
		if (status[v.id].reached == false and checkRequired(v.req) == true and v.name ~= "") then
			local objective = v
			i = i + 1
			objectivesTable[i] = {}

			objectivesTable[i].attackerText = objective.description
			objectivesTable[i].name = objective.name
			if (objective.defenderDescription == "") then
				objectivesTable[i].defenderText = options.defenderText
			else
				objectivesTable[i].defenderText = objective.defenderDescription
			end
		end
	end
	if (player == nil) then
		for k,v in ipairs(getElementsByType("player")) do
			triggerClientEvent2( v, "assaultNextObjectivesText", objectivesTable )
		end
	else
		triggerClientEvent2( player, "assaultNextObjectivesText", objectivesTable )
		triggerClientEvent2( player ,"assaultNextRound",attacker)
	end
end

assaultClientScriptQueue = {}

function triggerClientEvent2( player, eventName, parameter )
	if (getElementDataLocal( player, "assaultClientScriptLoaded") == true) then
		triggerClientEvent( player, eventName, player, parameter )
	else
		if (assaultClientScriptQueue[player] == nil) then
			assaultClientScriptQueue[player] = {}
		end
		local index = #assaultClientScriptQueue[player]+1
		assaultClientScriptQueue[player][index] = {}
		assaultClientScriptQueue[player][index].eventName = eventName
		assaultClientScriptQueue[player][index].parameter = parameter
	end
end
addEvent("assaultClientScriptLoaded",true)
addEventHandler('assaultClientScriptLoaded', getRootElement(),
	function()
		setElementDataLocal( source, "assaultClientScriptLoaded", true )
		if (assaultClientScriptQueue[source] == nil) then return end
		for k,v in ipairs(assaultClientScriptQueue[source]) do
			--outputConsole("Triggering queued event '"..v.eventName.."'",source)
			triggerClientEvent( source, v.eventName, source, v.parameter )
		end
		assaultClientScriptQueue[source] = {}
	end
)
addEventHandler("onPlayerQuit", getRootElement(),
	function()
		assaultClientScriptQueue[source] = {}
	end
)

--[[
####

Players and Teams

####
]]

-- Makes a player join team1 if there arent too many already
function joinTeam1( source )
	if (countPlayersInTeam(team1) - countPlayersInTeam(team2) > options.teamBalance - 1) then
		showTextForPlayer ( source, 2000, 255, 0, 0, 1.4, 0.62, "Can't join "..team1Name.." (too many players)" )
	else
		joinTeam(source, team1)
	end
end
-- Makes a player join team2 if there arent too many already
function joinTeam2( source )
	if (countPlayersInTeam(team2) - countPlayersInTeam(team1) > options.teamBalance - 1) then
		showTextForPlayer ( source, 2000, 255, 0, 0, 1.4, 0.62, "Can't join "..team2Name.." (too many players)" )
	else
		joinTeam(source, team2)
	end
end
-- Makes a player join the given team
function joinTeam( player, team )

	unbindKey ( player, "F1", "down", joinTeam1 )
	unbindKey ( player, "F2", "down", joinTeam2 )
	toggleSelectTeamDisplay(player, false)
	setPlayerTeam(player, team)

	textDisplayRemoveObserver( team1Display, player )
	textDisplayRemoveObserver( team2Display, player )

	if (team == team1) then textDisplayAddObserver( team1Display, player ) end
	if (team == team2) then textDisplayAddObserver( team2Display, player ) end

	if (waiting ~= true) then spawnPlayerTeam(player) else waitForStart(player) end
end
-- Spawns a player at the right spot (based on the team he is in)
function spawnPlayerTeam( player )
	if (waiting == true) then return end
	textDisplayRemoveObserver( waitingDisplay, player )
	textDisplayRemoveObserver( attackerDisplay, player )
	textDisplayRemoveObserver( defenderDisplay, player )
	local team = getPlayerTeam(player)
	local spawnpoint = nil
	if (team == attacker) then
		spawnpoint = getSpawnpoint(options.spawngroup.attacker)
		showTextForPlayer(player, 10000, 255, 0, 0, 2, 0.7, options.attackMessage)
		textDisplayAddObserver( attackerDisplay, player )
		--setElementData(player,"assaultAttacker",true)
	elseif (team) then
		spawnpoint = getSpawnpoint(options.spawngroup.defender)
		showTextForPlayer(player, 10000, 255, 0, 0, 2, 0.7, options.defendMessage)
		textDisplayAddObserver( defenderDisplay, player )
		--setElementData(player,"assaultAttacker",false)
	else
		outputDebugString("Can't spawn player '"..getPlayerName(player).."' (no team)",2)
		return
	end

	setElementDataLocal( player, "lastSpawnarea", spawnpoint)

	local x = spawnpoint.posX
	local y = spawnpoint.posY
	local z = spawnpoint.posZ

	if (x == nil or y == nil or z == nil) then
		outputChatBox("Invalid checkpoint")
	end

	--outputChatBox(x.." "..y.." "..z)

	local skins = spawnpoint.skins
	local skin = getRandomSkin(skins)

	local sizeX = tonumber(spawnpoint.sizeX)
	local sizeY = tonumber(spawnpoint.sizeY)
	if (sizeX < 1) then sizeX = 1 end
	if (sizeY < 1) then sizeY = 1 end

	local newX = x
	local newY = y
	if (spawnpoint.shape == "rectangle") then
		newX = x + math.random(1,sizeX)
		newY = y + math.random(1,sizeY)
	elseif (spawnpoint.shape == "circle") then
		local maxRadius = tonumber(spawnpoint.radius)
		local angle = math.random(0,359)
		local distance = maxRadius * math.random()
		newX = x + math.cos(math.rad(angle)) * distance
		newY = y + math.sin(math.rad(angle)) * distance
	end

	if (spawnPlayer( player, newX, newY, z + 1, 0, skin ) == false) then
		outputConsole("Failed to spawn player '"..getPlayerName(player).."'")
	end
	setElementInterior(player,tonumber(spawnpoint.interior))
	setElementDimension(player,tonumber(spawnpoint.dimension))
end

function getSpawnpoint(spawngroupsTable)
	spawngroup = nil
	for k,v in ipairs(spawngroupsTable) do
		--outputChatBox("req: "..v.req)
		if (checkRequired(v.req) == true) then
			spawngroup = v

		end
	end
	spawnarea = spawngroup.spawnarea
	--outputChatBox("test"..tostring(#spawngroup.spawnarea))
	if (#spawnarea == 0) then return false end
	local rand = math.random(1,#spawnarea)
	return spawnarea[rand]
end

function giveWeapons(player, weaponsString)
	local weaponsTable = split(weaponsString, 59)
	for k,v in ipairs(weaponsTable) do
		weaponId = gettok(v, 1, 44)
		weaponAmmo = gettok(v, 2, 44)
		if (weaponId ~= nil and weaponAmmo ~= nil) then
			giveWeapon(player, weaponId, weaponAmmo)
		end
	end
end
function getRandomSkin( skinString )
	local skinTable = split(skinString, 44)
	local skins = {}
	for k,v in ipairs(skinTable) do
		local skinTable2 = split(v, 45)
		if (skinTable2[2] == nil) then
			skins[#skins+1] = skinTable2[1]
		else
			for i=skinTable2[1],skinTable2[2] do
				skins[#skins+1] = i
			end
		end
	end
	local rand = math.random(1,#skins)
	return skins[rand]
end
-- Spawns all players, even if they are already spawned (as long as they selected a team)
function forcedRespawn()
	local players = getElementsByType("player")
	for k,v in ipairs(players) do
		if (getPlayerTeam(v) ~= false) then
			spawnPlayerTeam(v)
		end
	end
end

function onPlayerSpawn()
	--textDisplayRemoveObserver ( selectTeamDisplay, source )
	setCameraTarget( source, source )
	local team = getPlayerTeam(source)
	local spawnarea = getElementDataLocal( source, "lastSpawnarea" )
	if (team == attacker) then
		giveWeapons(source, spawnarea.weapons)
		showTextForPlayer(source,10,255,0,0,1,"You are attacking")
	else
		giveWeapons(source, spawnarea.weapons)
		showTextForPlayer(source,10,0,0,255,1,"You are defending")
	end
	if (team == team1) then
		local blip = createBlipAttachedTo(source, 0, 1, 255, 0, 0)
		setPlayerNametagColor(source, 255, 0, 0)
		--setElementVisibleTo(blip,team2,false)
	else
		local blip = createBlipAttachedTo(source, 0, 1, 0, 0, 255)
		setPlayerNametagColor(source, 0, 0, 255)
		--setElementVisibleTo(blip,team1,false)
	end
end

function onPlayerWasted( ammo, attacker, weapon, bodypart )
	destroyBlipsAttachedTo(source)

	if (noMapLoaded == false) then
		if (getElementDataLocal( source, "dontRespawn" ) == true) then
			setElementDataLocal( source, "dontRespawn", false )
			--outputDebugString("not spawning player")
		else
			if (waiting == true) then
				--outputDebugString("waiting for start")
				waitForStart( source )
			else
				--outputDebugString("spawning player")
				setTimer( spawnPlayerTeam, 2000, 1, source )
				pointsOnPlayerWasted(source, ammo, attacker)
			end
		end
	end
end

function selectTeam( player )
	if (isPedInVehicle( player )) then
		removePedFromVehicle( player ) end

	if (isPedDead(player) == false) then
		setElementDataLocal( player, "dontRespawn", true )
		killPed( player )
	end
	setPlayerTeam( player, nil )
	toggleSelectTeamDisplay( player, true )
	--setCameraMode( player, "fixed" )
	--setTimer(setCameraPosition,1000,1,player, options.camera.selectTeam.posX, options.camera.selectTeam.posY, options.camera.selectTeam.posZ )
	--setTimer(setCameraLookAt,1000,1,player, options.camera.selectTeam.targetX, options.camera.selectTeam.targetY, options.camera.selectTeam.targetZ )
	setCameraMatrix(player, options.camera.selectTeam.posX, options.camera.selectTeam.posY, options.camera.selectTeam.posZ, options.camera.selectTeam.targetX, options.camera.selectTeam.targetY, options.camera.selectTeam.targetZ)
	bindKey ( player, "F1", "down", joinTeam1 )
	bindKey ( player, "F2", "down", joinTeam2 )
	bindKey ( player, "F3", "down", selectTeamKey )
end

function selectTeamKey( source )
	selectTeam( source )
end

function createHelpText()
	helpTable = {}
	for k,v in ipairs(options.objective) do
		helpTable[k] = {}
		helpTable[k].name = v.name
		helpTable[k].description = v.description
	end
	return helpTable
end

function onPlayerChat( message, theType )
	if theType == 0 then
		cancelEvent()
		message = string.gsub(message, "#%x%x%x%x%x%x", "")
		local team = getPlayerTeam( source )
		local playerName = getPlayerName( source )
		if (team) then
			local r,g,b = getTeamColor(team)
			outputChatBox( playerName..":#FFFFFF "..message,getRootElement(),r,g,b, true )
		else
			outputChatBox( playerName..": "..message )
		end
		outputServerLog( "CHAT: " .. playerName .. ": " .. message )
	end
end


function onPlayerJoin ()
	createNextObjectiveText(source)
	triggerClientEvent2( source, "assaultCreateGui", options )
	textDisplayAddObserver( statusDisplay, source )
	setElementData(source, "score", 0)
	setPlayerHudComponentVisible( source, "money", false )
	if (noMapLoaded == true) then
		setNoMapLoaded( source, true )
	else
		selectTeam( source )
	end
end

function onPlayerQuit ()
	--playerLeft( soruce )
	unbindKey ( source, "F1", "down", joinTeam1 )
	unbindKey ( source, "F2", "down", joinTeam2 )
	--unbindKey ( source, "F3", "down", "spawnScreen" )
	destroyBlipsAttachedTo ( source )
	setPlayerTeam ( source, nil )
end

function destroyBlipsAttachedTo( source )
	local elements = getAttachedElements(source)
	for k,v in ipairs(elements) do
		if (getElementType(v) == "blip") then
			destroyElement(v)
		end
	end
end


-- Scores
function addPoints( player, add )
	local old = tonumber(getElementData(player,"score"))
	if (old == nil) then old = 0 end
	local new = old + add
	setElementData(player,"score",new)
end

function pointsOnPlayerWasted( source, ammo, killer )
	if (source == killer or killer == false) then
		addPoints(source, -1)
	elseif (getPlayerTeam(source) == getPlayerTeam(killer)) then
		addPoints(killer,-1)
	else
		addPoints(killer,1)
	end
end


--[[
####

Vehicle respawn

####
]]
function respawnAllVehicles()

	if (respawnVehicleTimers ~= nil) then
		for k,v in ipairs(respawnVehicleTimers) do
			stopVehicleRespawnTimer(v)
		end
	end
	respawnVehicleTimers = {}
	local vehicles = getElementsByType("vehicle", mapRoot)
	for k,v in ipairs(vehicles) do
		respawnVehicle(v)
	end
end

function respawnVehicle(vehicle)
	if (isElement(vehicle) == false) then return end
	if (getElementData(vehicle,"noRespawn") == true or getElementData(vehicle,"noRespawn") == "1") then return end
	posX = getElementData(vehicle,"posX")
	posY = getElementData(vehicle,"posY")
	posZ = getElementData(vehicle,"posZ")
	rotX = getElementData(vehicle,"rotX")
	rotY = getElementData(vehicle,"rotY")
	rotZ = getElementData(vehicle,"rotZ")
	spawnVehicle ( vehicle, posX, posY, posZ, rotX, rotY, rotZ )

end

function onVehicleExit()
	if (isVehicleEmpty(source) == true) then
		stopVehicleRespawnTimer(respawnVehicleTimers[source])
		respawnVehicleTimers[source] = setTimer(respawnVehicle,30000,1,source)
	end
end
function onVehicleEnter()
	if (respawnVehicleTimers[source] ~= nil) then
		if (isTimer(respawnVehicleTimers[source])) then
			killTimer(respawnVehicleTimers[source])
		end
		respawnVehicleTimers[source] = nil
	end
end
function onVehicleExplode()
	stopVehicleRespawnTimer(respawnVehicleTimers[source])
	respawnVehicleTimers[source] = setTimer(respawnVehicle,30000,1,source)
end
function stopVehicleRespawnTimer(timer)
	if (timer == nil) then return end
	if (isTimer(timer)) then
		killTimer(timer)
	end
end

function isVehicleEmpty( vehicle )
	local max = getVehicleMaxPassengers( vehicle )
	local empty = true
	local i = 0
	while (i < max) do
		if (getVehicleOccupant( vehicle, i ) ~= false) then
			empty = false
		end
		i = i + 1
	end
	return empty
end

--[[
####

Help functions

####
]]

assaultElementData = {}

function setElementDataLocal( element, item, value )
	if (assaultElementData[element] == nil) then
		assaultElementData[element] = {}
		--outputConsole("added element data. now: "..countTableElements(assaultElementData))
	end
	assaultElementData[element][item] = value
end
function getElementDataLocal( element, item )
	if (assaultElementData[element] == nil) then
		return nil
	end
	return assaultElementData[element][item]
end
function countTableElements(table)
	count = 0
	for k,v in pairs(table) do
		count = count + 1
	end
	return count
end

addEventHandler("onPlayerQuit", getRootElement(),
	function()
		if (assaultElementData[source] ~= nil) then
			assaultElementData[source] = nil
		end
		--outputConsole("removed element data. now: "..countTableElements(assaultElementData))
	end
)

-- stolen from mission_timer.lua
function calcTime ( timeLeft )
	local calcString = ""
	local timeHours = 0
	local timeMins = 0
	local timeSecs = 0

	timeLeft = tonumber(timeLeft)
	--outputDebugString ( "timeLeft = " .. timeLeft )

	timeSecs = math.mod(timeLeft, 60)
	--outputDebugString ( "timeSeconds = " .. timeSecs )

	timeMins = math.mod((timeLeft / 60), 60)
	--outputDebugString ( "timeMins = " .. timeMins )

	timeHours = (timeLeft / 3600)
	--outputDebugString ( "timeHours = " .. timeHours )

	if ( timeHours >= 1 ) then
		--outputDebugString ( "Time hours is above or equal too 1" )
		calcString = string.format("%02d:", timeHours)
	end
	calcString = calcString .. string.format("%02d:%02d", timeMins, timeSecs)

	--outputDebugString ( "calcString = " .. calcString )
	return calcString
end

function showTextForAll ( time, red, green, blue, scale, text, vertical )
	if (vertical == nil) then local vertical = 0.3 end
	local textDisplay = textCreateDisplay ()
	local stextItem = textCreateTextItem ( text, 0.501, vertical + 0.001, 2, 0, 0, 0, 255, scale, "center" )
	local textItem = textCreateTextItem ( text, 0.5, vertical, 2, red, green, blue, 255, scale, "center" )
	textDisplayAddText ( textDisplay, stextItem )
	textDisplayAddText ( textDisplay, textItem )
	local players = getElementsByType( "player" )
	for k,v in ipairs(players) do
		textDisplayAddObserver ( textDisplay, v )
	end
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end
function showTextForPlayer ( source, time, red, green, blue, scale, pos, text )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, 0.5, pos, 2, red, green, blue, 255, scale, "center" )
	textDisplayAddText ( textDisplay, textItem )
	textDisplayAddObserver ( textDisplay, source )
	if ( time < 50 ) then time = 50 end
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end
function showTextForTeam( team, time, red, green, blue, scale, pos, text )
	local textDisplay = textCreateDisplay ()
	local textItem = textCreateTextItem ( text, 0.5, pos, 2, red, green, blue, 255, scale, "center" )
	textDisplayAddText ( textDisplay, textItem )
	local players = getPlayersInTeam(team)
	for k,v in ipairs(players) do
		textDisplayAddObserver ( textDisplay, v )
	end
	setTimer(textDestroyTextItem, time, 1, textItem)
	setTimer(textDestroyDisplay, time, 1, textDisplay)
end

function isTimer(timer)
	local timers = getTimers()
	for k,v in ipairs(timers) do
		if (v == timer) then
			return true
		end
	end
	return false
end


-- Read map data from started map

function readOptions( startedMap )
	options = {}
	status = {}
	errors = {}

	mapRoot = getResourceRootElement(startedMap)
	options.name = getResourceName(startedMap)

	objectives = getElementsByType("objective",mapRoot)
	options.objective = {}
	for k,v in ipairs(objectives) do
		options.objective[k] = {}
		options.objective[k].node = v
		options.objective[k].type = getElementData2(v,"type",false,"checkpoint")
		options.objective[k].name = getElementData2(v,"name",false,"")
		options.objective[k].description = getElementData2(v,"description",false,"")
		options.objective[k].successText = getElementData2(v,"successText",false,"")
		options.objective[k].stay = tonumber(getElementData2(v,"stay",false,"0"))
		options.objective[k].stayText = getElementData2(v,"stayText",false,"")
		options.objective[k].id = getElementData2(v,"id",false,k)
		options.objective[k].req = getElementData2(v,"req",false,"")
		options.objective[k].posX = tonumber(getElementData2(v,"posX",true))
		options.objective[k].posY = tonumber(getElementData2(v,"posY",true))
		options.objective[k].posZ = tonumber(getElementData2(v,"posZ",true))
		options.objective[k].interior = tonumber(getElementData2(v,"interior",false))
		options.objective[k].blip = getElementData2(v,"blip",false,"0")
		options.objective[k].forcedRespawn = getElementData2(v,"forcedRespawn",false,"none")
		options.objective[k].markerType = getElementData2(v,"markerType",false,"cylinder")
		options.objective[k].captureType = getElementData2(v,"captureType",false,"foot")
		options.objective[k].defenderDescription = getElementData2(v,"defenderDescription",false,"")
		options.objective[k].successTextForDefender = getElementData2(v,"successTextForDefender",false,"")

		options.objective[k].reached = false
		status[options.objective[k].id] = {}
		status[options.objective[k].id].reached = false
		status[options.objective[k].id].key = k
		status[options.objective[k].id].count = 0
	end

	spawngroups = getElementsByType("spawngroup",mapRoot)

	options.spawngroup = {}
	options.spawngroup.attacker = {}
	options.spawngroup.defender = {}
	local count = {}
	count.attacker = 0
	count.defender = 0

	for k,v in ipairs(spawngroups) do
		local spawnType = getElementData2(v,"type",true)
		if (spawnType ~= "attacker" and spawnType ~= "defender") then return false end
		count[spawnType] = count[spawnType] + 1
		options.spawngroup[spawnType][count[spawnType]] = {}
		options.spawngroup[spawnType][count[spawnType]].req = getElementData2(v,"req",false,"")
		local spawnarea = {}
		local spawnareas = getElementChildren(v)
		local skinsForThisGroup = {}
		local weaponsForThisGroup = {}
		for k2,v2 in ipairs(spawnareas) do
			if (getElementType(v2) == "spawnarea") then
				local key = #spawnarea+1
				spawnarea[key] = {}
				spawnarea[key].posX = getElementData2(v2,"posX",true)
				spawnarea[key].posY = getElementData2(v2,"posY",true)
				spawnarea[key].posZ = getElementData2(v2,"posZ",true)
				spawnarea[key].sizeX = getElementData2(v2,"sizeX",false,2)
				spawnarea[key].sizeY = getElementData2(v2,"sizeY",false,2)
				spawnarea[key].skins = getElementData2(v2,"skins",false,"0")
				spawnarea[key].weapons = getElementData2(v2,"weapons",false,"")
				spawnarea[key].radius = getElementData2(v2,"radius",false,"2")
				spawnarea[key].shape = getElementData2(v2,"shape",false,"circle")
				spawnarea[key].dimension = getElementData2(v2,"dimension",false,"0")
				spawnarea[key].interior = getElementData2(v2,"interior",false,"0")
			elseif (getElementType(v2) == "skin") then
				local key = #skinsForThisGroup+1
				--skinsForThisGroup[key] = {}
				skinsForThisGroup[key] = getElementData2(v2,"model",true)
			elseif (getElementType(v2) == "weapon") then
				local key = #weaponsForThisGroup+1
				--outputDebugString(tostring(key))
				weaponsForThisGroup[key] = {}
				weaponsForThisGroup[key][1] = getElementData2(v2,"model",true)
				weaponsForThisGroup[key][2] = getElementData2(v2,"ammo",true)
			end
		end
		local skinsForThisGroupString = table.concat(skinsForThisGroup,",")
		-- default skin in case its empty
		if (skinsForThisGroupString == "" or skinsForThisGroupString == nil) then
			skinsForThisGroupString = "0"
		end
		for key,value in ipairs(weaponsForThisGroup) do
			local temp = table.concat(value,",")
			weaponsForThisGroup[key] = temp
		end
		local weaponsForThisGroupString = table.concat(weaponsForThisGroup,";")

		--outputDebugString("Weapons: "..tostring(weaponsForThisGroupString).." Skins: "..tostring(skinsForThisGroupString))

		for key,value in ipairs(spawnarea) do
			if (value.skins == "0") then
				spawnarea[key].skins = skinsForThisGroupString
				--outputDebugString("Assigned spawnarea skins of group")
			end
			if (value.weapons == "") then
				spawnarea[key].weapons = weaponsForThisGroupString
				--outputDebugString("Assigned spawnarea weapons of group")
			end
		end
		options.spawngroup[spawnType][count[spawnType]].spawnarea = spawnarea
	end

	local assaultSettingsNodeTable = getElementsByType("assaultSettings", mapRoot)
	local assaultSettingsNode = assaultSettingsNodeTable[1]

	local cameras = getElementsByType("camera", mapRoot)

	options.camera = {}
	for k,v in ipairs(cameras) do
		local cameraType = getElementData(v,"type")
		options.camera[cameraType] = {}
		options.camera[cameraType].posX = getElementData2(v,"posX",true)
		options.camera[cameraType].posY = getElementData2(v,"posY",true)
		options.camera[cameraType].posZ = getElementData2(v,"posZ",true)
		options.camera[cameraType].targetX = getElementData2(v,"targetX",true)
		options.camera[cameraType].targetY = getElementData2(v,"targetY",true)
		options.camera[cameraType].targetZ = getElementData2(v,"targetZ",true)
	end

	if (options.camera.spawn == nil) then
		errors[#errors+1] = "Required camera element of type 'spawn' not found"
	end
	if (options.camera.selectTeam == nil) then
		errors[#errors+1] = "Required camera element of type 'selectTeam' not found"
	end
	if (options.camera.finish == nil) then
		errors[#errors+1] = "Required camera element of type 'finish' not found"
	end

	local startedMapName = getResourceName(startedMap)

	-- Assault specific settings
	options.teamBalance = tonumber(getFromSettings(nil,"teamBalance","1"))
	if (options.teamBalance < 1) then
		options.teamBalance = 1
		outputDebugString("Assault: Changed teamBalance setting to '1' because of invalid value.")
	end

	-- Map specific settings
	options.time = getElementData2(assaultSettingsNode,"time", false, "12:00")
	options.time = getFromSettings(startedMapName,"time",options.time)
	options.weather = getElementData2(assaultSettingsNode,"weather",false,"0")
	options.weather = getFromSettings(startedMapName,"weather",options.weather)
	options.description = getElementData2(assaultSettingsNode, "description",false,"")
	options.description = getFromSettings(startedMapName,"description",options.description)
	options.author = getElementData2(assaultSettingsNode, "author",false,"")
	options.author = getFromSettings(startedMapName,"author",options.author)
	options.timelimit = tonumber(getElementData2(assaultSettingsNode, "timelimit",false,"300"))
	options.timelimit = tonumber(getFromSettings(startedMapName,"timelimit",options.timelimit))
	options.defaultObjectiveColorR = tonumber(getElementData2(assaultSettingsNode,"defaultObjectiveColorR",false,"255"))
	options.defaultObjectiveColorG = tonumber(getElementData2(assaultSettingsNode,"defaultObjectiveColorG",false,"128"))
	options.defaultObjectiveColorB = tonumber(getElementData2(assaultSettingsNode,"defaultObjectiveColorB",false,"64"))
	options.defenderText = getElementData2(assaultSettingsNode, "defenderText", false, "Prevent attackers from reaching their objectives!")
	options.defenderText = getFromSettings(startedMapName,"defenderText",options.defenderText)
	options.attackMessage = getElementData2(assaultSettingsNode, "attackMessage", false, "Assault the base!")
	options.attackMessage = getFromSettings(startedMapName,"attackMessage",options.attackMessage)
	options.defendMessage = getElementData2(assaultSettingsNode, "defendMessage", false, "Defend the base!")
	options.defendMessage = getFromSettings(startedMapName,"defendMessage",options.defendMessage)
	options.conqueredMessage = getElementData2(assaultSettingsNode, "conqueredMessage", false, "conquered the base")
	options.conqueredMessage = getFromSettings(startedMapName,"conqueredMessage",options.conqueredMessage)
	options.defendedMessage = getElementData2(assaultSettingsNode, "defendedMessage", false, "defended the base")
	options.defendedMessage = getFromSettings(startedMapName,"defendedMessage",options.defendedMessage)

	options.finishObjective = getElementData2(assaultSettingsNode, "finishObjective", false, "")
	options.finishObjective = getFromSettings(startedMapName,"finishObjective",options.finishObjective)

	options.finishType = getElementData2(assaultSettingsNode, "finishType", false, "")
	options.finishType = getFromSettings(startedMapName,"finishType",options.finishType)

	if (options.finishObjective == "") then
		-- finishType should be "all"
		if (options.finishType == "objective") then
			errors[#errors+1] = "Finish type is set to objective, yet no finish objective is defined"
		else
			options.finishType = "all"
		end
	elseif (options.finishType ~= "all") then
		-- if finishType is not "all" and finishObjective is not "", then it has to be "objective"
		options.finishType = "objective"
	end

	--outputConsole(options.finishType.." "..options.finishObjective)

	local noError = true
	for k,v in ipairs(errors) do
		noError = false
		outputDebugString(v,1)
	end
	return noError
end

function getElementData2( element, item, required, default )
	if (isElement(element) == false) then
		errors[#errors+1] = "Element to read item "..item.." does not exist."
		return false
	end
	local data = getElementData(element,item)
	--outputChatBox(item..": "..tostring(data))
	if (data == false or data == nil or data == "") then
		--outputChatBox(item..": "..tostring(data))
		if (required == true) then
			errors[#errors+1] = "Value missing in '"..getElementType(element).."': '"..item.."'"
			return false
		else
			return default
		end
	end

	return data
end

function getFromSettings( mapName, setting, default )
	if (mapName == nil) then
		local value = get(setting)
		if (value ~= false) then
			return value
		end
	elseif (get(mapName.."."..setting) ~= false) then
		return get(mapName.."."..setting)
	end
	return default
end

function selfkill( source )
	killPed(source)
end

-- GUI/Textdisplay stuff

function toggleSelectTeamDisplay( player, bool )
	toggleLogo(player,bool)
	--[[
	if (bool == true) then
		textDisplayAddObserver ( selectTeamDisplay, player )
	else
		textDisplayRemoveObserver ( selectTeamDisplay, player )
	]]
end

function toggleLogo( player, bool )
	if (getElementDataLocal(player,"assaultToggleLogo") == true) then
		triggerClientEvent( player, "assaultToggleLogo", player, bool )
	else
		setElementDataLocal(player,"assaultToggleLogo", true)
	end
end

function selectTeamCreateDisplay()
	selectTeamDisplay = textCreateDisplay()
	local stext = textCreateTextItem ( "Select your spawn", 0.502, 0.302, "low", 0, 0, 0, 255, 2, "center" )
	local stext2 = textCreateTextItem ( "Press F1 to spawn " ..team1Name.. "", 0.501, 0.501, "low", 0, 0, 0, 255, 1.4, "center" )
	local stext3 = textCreateTextItem ( "Press F2 to spawn " ..team2Name.. "", 0.501, 0.551, "low", 0, 0, 0, 255, 1.4, "center" )
	local stext4 = textCreateTextItem ( "Press F3 to return to the spawn screen", 0.501, 0.601, "low", 0, 0, 0, 255, 1.4, "center" )
	local stext5 = textCreateTextItem ( "Press F9 for help", 0.501, 0.651, "low", 0, 0, 0, 255, 1.4, "center" )
	local text = textCreateTextItem ( "Select your spawn", 0.5, 0.3, "low", 255, 255, 255, 255, 2, "center" )
	local text2 = textCreateTextItem ( "Press F1 to spawn " ..team1Name.. "", 0.5, 0.5, "low", 255, 255, 255, 255, 1.4, "center" )
	local text3 = textCreateTextItem ( "Press F2 to spawn " ..team2Name.. "", 0.5, 0.55, "low", 255, 255, 255, 255, 1.4, "center" )
	local text4 = textCreateTextItem ( "Press F3 to return to the spawn screen", 0.5, 0.6, "low", 255, 255, 255, 255, 1.4, "center" )
	local text5 = textCreateTextItem ( "Press F9 for help", 0.5, 0.65, "low", 255, 255, 255, 255, 1.4, "center" )
	textDisplayAddText ( selectTeamDisplay, stext )
	textDisplayAddText ( selectTeamDisplay, stext2 )
	textDisplayAddText ( selectTeamDisplay, stext3 )
	textDisplayAddText ( selectTeamDisplay, stext4 )
	textDisplayAddText ( selectTeamDisplay, stext5 )
	textDisplayAddText ( selectTeamDisplay, text )
	textDisplayAddText ( selectTeamDisplay, text2 )
	textDisplayAddText ( selectTeamDisplay, text3 )
	textDisplayAddText ( selectTeamDisplay, text4 )
	textDisplayAddText ( selectTeamDisplay, text5 )
end

function waitingCreateDisplay()
	waitingDisplay = textCreateDisplay()
	local stext = textCreateTextItem("Waiting for the round to begin..",0.501,0.701,"low",0,0,0,255,1.4, "center")
	local text = textCreateTextItem("Waiting for the round to begin..",0.5,0.7,"low",255,255,255,255,1.4, "center")

	textDisplayAddText(waitingDisplay,stext)
	textDisplayAddText(waitingDisplay,text)

	waitingDisplay2 = textCreateDisplay()
	waitingText2 = textCreateTextItem("text",0.5,0.5,"low",255,255,255,255,2, "center")
	waitingText2_2 = textCreateTextItem("text",0.501,0.501,"low",0,0,0,255,2, "center")
	textDisplayAddText(waitingDisplay2, waitingText2_2)
	textDisplayAddText(waitingDisplay2, waitingText2)

	noMapLoadedDisplay = textCreateDisplay()
	local stext = textCreateTextItem("Assault: No map loaded..",0.501,0.701,"low",0,0,0,255,1.4, "center")
	local text = textCreateTextItem("Assault: No map loaded..",0.5,0.7,"low",255,255,255,255,1.4, "center")
	textDisplayAddText(noMapLoadedDisplay,stext)
	textDisplayAddText(noMapLoadedDisplay,text)
end

-- General Gamemode Events
addEventHandler( "onResourceStart", getResourceRootElement(getThisResource()), startAssault )
addEventHandler( "onGamemodeMapStart", getRootElement(), startAssaultMap )
addEventHandler( "onGamemodeMapStop", getRootElement(), stopAssaultMap )
addEventHandler( "onResourceStop", getResourceRootElement(getThisResource()), stopAssault )

-- Custom gamemode Events
addEvent("onAssaultObjectiveReached")
addEvent("onAssaultStartRound")
addEvent("onAssaultCreateObjective")
addEvent("onAssaultEndRound")

-- Player Events
--addCommandHandler("team1",joinTeam1)
--addCommandHandler("team2",joinTeam2)
addCommandHandler("kill",selfkill)
addEventHandler( "onPlayerSpawn", getRootElement(), onPlayerSpawn )
addEventHandler( "onPlayerWasted", getRootElement(), onPlayerWasted )
addEventHandler( "onPlayerJoin", getRootElement(), onPlayerJoin )
addEventHandler( "onPlayerQuit", getRootElement(), onPlayerQuit )
addEventHandler( "onPlayerChat", getRootElement(), onPlayerChat )

-- Vehicle Events
addEventHandler ( "onVehicleEnter", getRootElement(), onVehicleEnter )
addEventHandler ( "onVehicleExit", getRootElement(), onVehicleExit )
addEventHandler ( "onVehicleExplode", getRootElement(), onVehicleExplode )

