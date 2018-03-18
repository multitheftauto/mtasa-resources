--Fallout By Ransom
--Special Thanks arc_, lil_toady, eAi, IJs, jbeta, Talidan

--------------
---OPTIONS----
--------------
rows = 10         --Default:10  Number of rows to put on the board
columns = 8       --Default:8   Number of columns to put on the board
winningBoards = 3 --Default:3   Number of boards that will not fall. Must be higher than board count!
scoreLimit = 10   --Default:10  wins required to win the fallout tournament default is 10
callSpeedA = 250  --Default:250 Call speed when 30 or more boards exist
callSpeedB = 500  --Default:500 Call speed when 29 to 15 boards exist
callSpeedC = 750  --Default:750 Call speed when 15 or less boards exist
--------------
---/OPTIONS---
--------------
outputChatBox ( "Fallout V4 by Ransom loaded", root, 255, 127, 0 ) --DEBUG
--outputChatBox ( "Fallout Server Loaded", root, 255, 127, 0 ) --DEBUG

function resourceStart()
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Rank", getRootElement(), 2, .08 )-----|Add scoreboard columns
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Wins", getRootElement(), 3, .08 )-----|
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Losses", getRootElement(), 4, .08 )---|
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "W/L Ratio", getRootElement(), 5, .1)--|
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

-----------
---DISPLAYS
-----------
countDownDisplay = textCreateDisplay ()
countDownText = textCreateTextItem ( "", 0.5, 0.3, "high", 255, 127, 0, 255, 2, "center" )
textDisplayAddText ( countDownDisplay, countDownText )

suicideDisplay = textCreateDisplay ()
suicideText = textCreateTextItem ( "You lose! Press space for a quick death.", 0.5, 0.5, "low", 255, 127, 0, 255, 2, "center" )
textDisplayAddText ( suicideDisplay, suicideText )

winnersDisplay = textCreateDisplay ()
winnersText = textCreateTextItem ( "Winners:", 0.5, 0.35, "low", 255, 127, 0, 255, 2, "center", "center" )
textDisplayAddText ( winnersDisplay, winnersText )

spectatorCamDisplay = textCreateDisplay ()
specCamText = textCreateTextItem ( "Use your player movement keys to move the spectator camera.\nUse your sprint key to speed the camera up.", 0.5, 0.22, "low", 255, 127, 0, 255, 1.3, "center" )
textDisplayAddText ( spectatorCamDisplay, specCamText )

podiumDisplay = textCreateDisplay ()
tournamentText = textCreateTextItem ( "Tournament Leaders", 0.45, 0.04, "high", 255, 127, 0, 255, 1.5 )
firstText = textCreateTextItem ( "1st:", 0.45, 0.08, "high", 255, 127, 0, 255, 1.5 )
secondText = textCreateTextItem ( "2nd:", 0.45, 0.12, "high", 255, 127, 0, 255, 1.5 )
thirdText = textCreateTextItem ( "3rd:", 0.45, 0.16, "high", 255, 127, 0, 255, 1.5 )
textDisplayAddText ( podiumDisplay, tournamentText )
textDisplayAddText ( podiumDisplay, firstText )
textDisplayAddText ( podiumDisplay, secondText )
textDisplayAddText ( podiumDisplay, thirdText )
-----------
--/DISPLAYS
-----------

board = {}
teamAlive = createTeam ( "Alive Players", 255, 255, 255 )
tableSize = rows * columns
newTournament = true --Setup scoreboard and podium scores
players = getElementsByType ( "player" )
gameOver = false
for k,v in pairs(players) do
	textDisplayAddObserver ( podiumDisplay, v )
end

---------------------------------------------------------------------------------------------
--                                     START FALLING BOARD SCRIPT                          --
---------------------------------------------------------------------------------------------

function createBoard () --MOVE BOARD CREATION TO CLIENTSIDE
	--Create boards. Platform #1 is at SW Corner
	for i = 1,rows do --Nested to create rows and columns
		for j = 1, columns do
			board[count] = createObject ( 1697, 1540.122926 + 4.466064 * j, -1317.568237 + 5.362793 * i, 603.105469, math.deg( 0.555 ), 0, 0 )
			count = count + 1
		end
	end
end

function triggerClientFall ( fallingPiece )
    if gameOver == false then --Stop timer setting when winner is declared, avoid board recretaion problems
		triggerClientEvent ( "clientShakePieces", getRootElement(), fallingPiece )
		local x, y = getElementPosition ( fallingPiece )
	    local rx, ry, rz = math.random( 0, 360 ), math.random( 0, 360 ), math.random( 0, 360 )
		if rx < 245 then rx = -(rx + 245) end --Make the falling pieces with big random spins
		if ry < 245 then ry = -(ry + 245) end
		if rz < 245 then rz = -(rz + 245) end
		setTimer ( moveObject, 2500, 1, fallingPiece, 10000, x, y, 404, rx, ry, rz )
	    setTimer ( destroyElement, 8000, 1, fallingPiece )
	end
end

function breakAwayPieces ()
	tableSize = table.maxn (board)
	if tableSize ~= winningBoards then
		chosenBoard = math.random ( 1, tableSize )
		triggerClientFall ( board[chosenBoard] ) --becomes fallingPiece parameter
		if tableSize >= 40 then
			callSpeed = callSpeedA
		elseif ( tableSize <= 29 ) and ( tableSize > 15 ) then
			callSpeed = callSpeedB
		elseif tableSize < 15 then
			callSpeed = callSpeedC
		end
		table.remove ( board, chosenBoard ) --Adjust table to get rid of used board
		setTimer ( breakAwayPieces, callSpeed, 1 )
	end
	remainingPlayers = countPlayersInTeam ( teamAlive )
	if ( tableSize == winningBoards ) and ( gameOver == false ) then
		setTimer ( declareWinners, 4000, 1 )
	end
end
---------------------------------------------------------------------------------------------
--                                      /END FALLING BOARD SCRIPT                           --
---------------------------------------------------------------------------------------------

function updateTournamentLeaders ()
	local top3 = {}		-- { {player=p, ratio=r}, ... }
	for k,v in ipairs(players) do
		if (getElementData (v, "Losses")) == 0 then --Special cases to make W/L report correctly
		    if (getElementData (v, "Wins")) >= 1 then
				setElementData ( v, "W/L Ratio", 1 )
			end
		else
			playerRatio = math.ceil ( (getElementData (v, "Wins") / getElementData (v, "Losses")) * 1000 ) / 1000
			setElementData ( v, "W/L Ratio", tostring(playerRatio) ) --Update ratio every game. tostringed due to decimal places bug
		end
		checkRatio = tonumber(getElementData (v, "Wins")) --changed leader board to display wins not ratio
		if checkRatio > 0 then
			wasAdded = false
			for i=1,#top3 do
				if checkRatio > top3[i].ratio then
					table.insert(top3, i, {player=v, ratio=checkRatio})
					if #top3 > 3 then
						table.remove(top3)
					end
					wasAdded = true
					break
				end
			end
			if not wasAdded and #top3 < 3 then
				table.insert(top3, {player=v, ratio=checkRatio})
			end
		end
	end
    if ( top3[1] ) then
    	textItemSetText ( firstText, "1st: " .. getPlayerName(top3[1].player) .. " " .. top3[1].ratio )
	else
	    textItemSetText ( firstText, "1st:" )
	end
	if ( top3[2] ) then
    	textItemSetText ( secondText, "2nd: " .. getPlayerName(top3[2].player) .. " " .. top3[2].ratio )
	else
	    textItemSetText ( secondText, "2nd:" )
	end
	if ( top3[3] ) then
    	textItemSetText ( thirdText, "3rd: "..getPlayerName (top3[3].player).." ".. top3[3].ratio )
	else
	    textItemSetText ( thirdText, "3rd:" )
	end
end

function declareWinners ()
	triggerClientEvent ( "lossDetectionOff", getRootElement() ) --Also stop board shaking
	gameOver = true
	winners = getPlayersInTeam ( teamAlive )
	firstEntry = true --This is necessary to save names on seperate lines in a varible for the winners display
	for k,v in pairs(winners) do
		if firstEntry == true then
			winnersList = getPlayerName ( v )
			firstEntry = false
		else
			winnersList = winnersList.."\n"..getPlayerName ( v )
		end
		--outputChatBox ( "adding 1 win to: "..getClientName ( v ) ) --DEBUG--DEBUG--DEBUG--DEBUG --DEBUG
		setElementData ( v, "Wins", ( getElementData ( v, "Wins" ) ) + 1 )
	end
	if ( winnersList ) then --If no players during game... winnersList must exist here
		textItemSetText( winnersText, "Winners:\n"..winnersList )
	else
		textItemSetText( winnersText, "No Winners" )
	end
	players = getElementsByType ( "player" )
	for k,v in pairs(players) do
		textDisplayAddObserver ( winnersDisplay, v )
		if (getElementData (v, "Losses")) == 0 then --Update W/L Ratio (checks for special case of divide by 0)
			playerRatio = (getElementData (v, "Wins"))
			setElementData ( v, "W/L Ratio", tostring(playerRatio) )
		else
			playerRatio = math.ceil ( (getElementData (v, "Wins") / getElementData (v, "Losses")) * 1000 ) / 1000
			setElementData ( v, "W/L Ratio", tostring(playerRatio) ) --Update ratio every game. tostringed due to decimal places bug
		end
	end
	updateTournamentLeaders ()
	--Rest is check for tournament winner stuff
    for k,v in pairs(winners) do
		playerwins = (getElementData (v, "Wins"))
		if tonumber(playerwins) >= scoreLimit then
			winnerCount = winnerCount + 1
			winnerName = getPlayerName ( v )
		end
	end
	if winnerCount == 1 then
		textItemSetText( winnersText, ""..winnerName.." won fallout! Starting a new tournament in 15 seconds." )
		newTournament = true
		setTimer ( newGame, 15000, 1 )
	elseif winnerCount > 1 then
		winTie = true
		setTimer ( newGame, 3000, 1 )
	else
		setTimer ( newGame, 3000, 1 )
	end
end

function quickKill ( player, key, keyState )
	unbindKey ( player, "space" )
    killPed ( player )
end

function activateSpectate ( player ) --Don't setTimer loop serverside, will cause bug when 2 players come in
	setCameraMatrix( player, 1558.367, -1346.678, 630, 1558.367, -1301.059, 603.105469)
	exports.freecam:setPlayerFreecamEnabled( player )
end

function playerWasted ( )
    setPlayerTeam ( source, nil )
    textDisplayRemoveObserver ( suicideDisplay, source )
	--setCameraMode (source, "player" )--   DEBUG---   DEBUG---   --   DEBUG---   DEBUG---   --   DEBUG---   DEBUG---
	--setCameraMode (source, "fixed" )--   DEBUG---   DEBUG---   --   DEBUG---   DEBUG---   --   DEBUG---   DEBUG---
	activateSpectate ( source )
end
addEventHandler ( "onPlayerWasted", root, playerWasted )

function playerLoss ( )
	setPlayerTeam ( source, nil )
	textDisplayAddObserver ( suicideDisplay, source ) --suicide display
	bindKey ( source, "space", "down", quickKill )
	setElementData ( source, "Losses", ( getElementData ( source, "Losses" ) ) + 1 )
	remainingPlayers = countPlayersInTeam ( teamAlive )
	if ( remainingPlayers == 1 ) and ( gameOver == false ) then --Detect early victories
		setTimer ( declareWinners, 4000, 1 )
    elseif ( remainingPlayers == 0 ) and ( gameOver == false ) then
		setTimer ( declareWinners, 4000, 1 )
	end
end
addEvent("serverReportLoss", true) --For triggering from server
addEventHandler("serverReportLoss", getRootElement (), playerLoss)

function KillCheater ( )
	outputChatBox ( "weapon cheat detected. "..getPlayerName(source).." killed for cheating." )
	killPed ( source )
end
addEvent("serverKillCheater", true) --For triggering from server
addEventHandler("serverKillCheater", getRootElement (), KillCheater)

function PlayerJoin ( )
	setElementData ( source, "Wins", 0 )
	setElementData ( source, "Losses", 0 )
	setElementData ( source, "W/L Ratio", 0 )
	textDisplayAddObserver ( podiumDisplay, source )
	--setCameraMode (source, "player" )
	--setTimer ( setCameraMode, 500, 1, source, "fixed" ) --camera stuff not working
    --setTimer ( setCameraPosition, 1000, 1, source, 1558.367, -1346.678, 630 )
  	--setTimer ( setCameraLookAt, 2000, 1, source, 1558.367, -1301.059, 603.105469 )
	setCameraMatrix( source, 1558.367, -1346.678, 630, 1558.367, -1301.059, 603.105469)
end
addEventHandler ( "onPlayerJoin", getRootElement(), PlayerJoin )

function PlayerQuit ( )
	players = getElementsByType ( "player" )
	-- Remove the player that is disconnecting
	for k, player in pairs(players) do
		if (player == source) then
			players[k] = nil
			break
		end
	end
end
addEventHandler ( "onPlayerQuit", root, PlayerQuit )

--function clientStoredBoardInformation ()

--end

function spawnPlayers ()
	for k,v in pairs(players) do
		exports.freecam:setPlayerFreecamDisabled( v )
		setPlayerTeam ( v, teamAlive )
		textDisplayAddObserver ( countDownDisplay, v )
		spawningBoard = math.random ( 1, tableSize ) --Choose random spawn board
		local x, y, z = getElementPosition ( board[spawningBoard] )
		changex = math.random (0,1)
		changey = math.random (0,1)
		if changex == 0 then --Choose random position across spawn board surface
			x = x - math.random (0,200)/100
		elseif changex == 1 then
			x = x + math.random (0,200)/100
		end
		if changey == 0 then
			y = y - math.random (0,200)/100
		elseif changey == 1 then
			y = y + math.random (0,200)/100
		end
		spawnAngle = 360 - math.deg( math.atan2 ( (1557.987182 - x), (-1290.754272 - y) ) )
		spawnPlayer ( v, x, y, 607.105469, spawnAngle )
	end
end

function newGameCountdown ()
	if countdown > 0 then
	    if winTie == false then
			textItemSetText ( countDownText, "Tournament length: "..scoreLimit.. " wins".."\n".."Get ready!".."\n"..countdown )
		else --set special tie game text
		    textItemSetText ( countDownText, "Tournament length: "..scoreLimit.. " wins - Tiebreaker game!!!".."\n".."Get ready!".."\n"..countdown )
		end
		setTimer ( newGameCountdown, 1000, 1 )
		countdown = countdown - 1
		playSoundFrontEnd(root, 44)
	else
		for k,v in pairs(players) do
			textDisplayRemoveObserver ( countDownDisplay, v )
			triggerClientEvent ( "clientCheckStatus", getRootElement() ) --Start loser checks on client
		end
		playSoundFrontEnd(root, 45)
		--Erase countdown for displaying 'get ready' next game prior to countdown
		if winTie == false then --needed for display consistency
        	textItemSetText ( countDownText, "Tournament length: "..scoreLimit.. " wins".."\n".."Get ready!".."\n".."" )
		else
		    textItemSetText ( countDownText, "Tournament length: "..scoreLimit.. " wins - Tiebreaker game!!!".."\n".."Get ready!".."\n".."" )
		end
		gameOver = false
		breakAwayPieces () --Game starts, boards fall
	end
end

function cleanupOldGame ()
	existingBoards = getElementsByType ( "object" )
	for k,v in ipairs(existingBoards) do
		destroyElement ( v )
	end
    gameTimers = getTimers ()
    for timerKey, timerNameData in ipairs(gameTimers) do
    	killTimer ( timerNameData )
    end
	for k,v in pairs(players) do
		unbindKey ( v, "space" )
		textDisplayRemoveObserver ( winnersDisplay, v )
		textDisplayRemoveObserver( suicideDisplay, v )
		textDisplayRemoveObserver ( spectatorCamDisplay, v )
		--setCameraMode (source, "player" )  ------------DEBUG-DEBUG      -DEBUG      -DEBUG      -DEBUG
		setCameraTarget( v, v )
	end
	winnersList = nil
end

function emptyPodium ()
	textItemSetText ( firstText, "1st:" ) --Avoid double entries on podium
	textItemSetText ( secondText, "2nd:" )
	textItemSetText ( thirdText, "3rd:" )
	firstScore = -1
	secondScore = -1
	thirdScore = -1
end

function newGame ()
	cleanupOldGame ()
	if newTournament == true then
		players = getElementsByType ( "player" )
		for k,v in pairs(players) do
			setElementData ( v, "Wins", 0 )---------------|Set scoreboard column data
			setElementData ( v, "Losses", 0 )           --|
			setElementData ( v, "W/L Ratio", 0 )----------|
		end
		emptyPodium ()
		newTournament = false
		winTie = false
	end
	winnerCount = 0 --Reset tournament winners each newGame if no tourney winner
	count = 1 --Reset count for storing new board creation identities
    createBoard ()
	players = getElementsByType ( "player" ) --Update players table
	spawnPlayers () --Add players to countdown text display and teamAlive
	setWeather ( math.random (0, 19) )
	setTime ( math.random (0, 23), 00 )
	countdown = 3 --Set here for first game only
	setTimer ( newGameCountdown, 3000, 1 )
end
addEventHandler("onResourceStart", resourceRoot, newGame) --Initiate first game
-- I had to put this in the event handler else got debug about freecam not running

function ResourceStop ( ) --Prevent invisible bug, reset cam on unload
	players = getElementsByType ( "player" )
	for k,v in pairs(players) do
		--setCameraMode ( v, "player" ) --DISABLED DEBUG--DISABLED DEBUG      --DISABLED DEBUG      --DISABLED DEBUG
		setCameraTarget( v, v )
	end
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "Wins" )
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "Losses" )
	call(getResourceFromName("scoreboard"), "removeScoreboardColumn", "W/L Ratio" )
end
addEventHandler ( "onResourceStop", root, ResourceStop )

function clientLoad() -- Indicate to the gamemode than the client is loaded
	if not getPlayerTeam(client) then --Check if its not playing
		exports.freecam:setPlayerFreecamEnabled( client ) -- Start spectating
	end
end
addEvent ( "serverClientLoad", true )
addEventHandler ( "serverClientLoad", root, clientLoad )
