--Fallout By Ransom
--Special Thanks arc_, lil_toady, eAi, IJs, jbeta, Talidan

outputChatBox("Fallout V" .. (getResourceInfo ( resource, "version" ) or "?")  .. " by Ransom loaded", root, 255, 127, 0)

function resourceStart()
	local scoreboardResource = getResourceFromName("scoreboard")
	call(scoreboardResource, "addScoreboardColumn", "Wins", root, 2, .08)
	call(scoreboardResource, "addScoreboardColumn", "Losses", root, 3, .08)
	call(scoreboardResource, "addScoreboardColumn", "W/L Ratio", root, 4, .08)
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)


local teamAlive = createTeam("Alive Players", 255, 255, 255)
local newTournament = true --Setup scoreboard and podium scores
local gameOver = false -- Boolean used to manage the gameOver state
local winTie = false -- Boolean used when the game round ended with a tie
local countdown = 0 -- Countdown used for the round start 3,2,1...
local checkPlayersHeightTimer -- Timer used to check the height of the player


for k, player in pairs(getElementsByType("player")) do
	textDisplayAddObserver(textDisplays.podiumDisplay, player)
end


---------------------------------------------------------------------------------------------
--                                     START FALLING BOARD SCRIPT                          --
---------------------------------------------------------------------------------------------


function triggerPieceFall(fallingPiece)
	if gameOver then return end --Stop timer setting when winner is declared, avoid board recretaion problems
	if not isElement(fallingPiece) then return end
	triggerClientEvent(getLoadedPlayers(), "onClientShakePieces", fallingPiece )
	local x, y = getElementPosition(fallingPiece)
	local rx, ry, rz = math.random(0, 360), math.random(0, 360), math.random(0, 360)

	if rx < 245 then
		rx = -(rx + 245)
	end --Make the falling pieces with big random spins

	if ry < 245 then
		ry = -(ry + 245)
	end

	if rz < 245 then
		rz = -(rz + 245)
	end

	setTimer(moveFallingPiece, 2500, 1,  fallingPiece, 10000, x, y, 404, rx, ry, rz )
	setTimer(destroyFallingPiece, 8000, 1, fallingPiece)
end

function moveFallingPiece (fallingPiece, ...)
	if not isElement(fallingPiece) then return end
	moveObject(fallingPiece, ...)
end

function destroyFallingPiece (fallingPiece)
	if not isElement(fallingPiece) then return end
	destroyElement(fallingPiece)
end

function breakAwayPieces()
	local activeBoardCount = getActiveBoardElementCount()

	if activeBoardCount ~= config.winningBoards then
		local chosenBoard = getRandomActiveBoard()
		triggerPieceFall(chosenBoard) --becomes fallingPiece parameter
		-- Adjust the fall speed based on the remaining board pieces
		local callSpeed = 1
		if activeBoardCount >= 30 then
			callSpeed = config.callSpeedA
		elseif (activeBoardCount <= 29) and (activeBoardCount >= 15) then
			callSpeed = config.callSpeedB
		elseif activeBoardCount < 15 then
			callSpeed = config.callSpeedC
		end
		disableBoard(chosenBoard)
		setTimer(breakAwayPieces, callSpeed, 1)
	end

	if (activeBoardCount == config.winningBoards) and (gameOver == false) then
		startDeclareWinnersTimer()
	end
end

---------------------------------------------------------------------------------------------
--                                      /END FALLING BOARD SCRIPT                          --
---------------------------------------------------------------------------------------------

--- Get the 3 leaders (if any)
function getLeaders ()
	local leaders = {} -- { {player=p, ratio=r}, ... }
	local players = getElementsByType("player")
	for k, player in ipairs(players) do
		if (getElementData(player, "Losses")) == 0 then --Special cases to make W/L report correctly
			if (getElementData(player, "Wins")) >= 1 then
				setElementData(player, "W/L Ratio", 1)
			end
		else
			local playerRatio = math.ceil((getElementData(player, "Wins") / getElementData(player, "Losses")) * 1000) / 1000
			setElementData(player, "W/L Ratio", tostring(playerRatio)) --Update ratio every game. tostringed due to decimal places bug
		end
		local checkRatio = tonumber(getElementData(player, "Wins")) --changed leader board to display wins not ratio
		if checkRatio > 0 then
			local wasAdded = false
			for i = 1, #leaders do
				if checkRatio > leaders[i].ratio then
					table.insert(leaders, i, {player = player, ratio = checkRatio})
					if #leaders > 3 then
						table.remove(leaders)
					end
					wasAdded = true
					break
				end
			end
			if not wasAdded and #leaders < 3 then
				table.insert(leaders, {player = player, ratio = checkRatio})
			end
		end
	end
	return leaders
end

function updateTournamentLeaders()
	local leaders = getLeaders ()
	if (leaders[1]) then
		textItemSetText(textItems.firstText, "1st: " .. getPlayerName(leaders[1].player) .. " " .. leaders[1].ratio)
	else
		textItemSetText(textItems.firstText, "1st:")
	end
	if (leaders[2]) then
		textItemSetText(textItems.secondText, "2nd: " .. getPlayerName(leaders[2].player) .. " " .. leaders[2].ratio)
	else
		textItemSetText(textItems.secondText, "2nd:")
	end
	if (leaders[3]) then
		textItemSetText(textItems.thirdText, "3rd: " .. getPlayerName(leaders[3].player) .. " " .. leaders[3].ratio)
	else
		textItemSetText(textItems.thirdText, "3rd:")
	end
end

local declareWinnersTimer
--- Start the declare winners timer. If called again, it will delay declaring the winner
function startDeclareWinnersTimer ()
	if isTimer(declareWinnersTimer) then
		killTimer(declareWinnersTimer)
	end
	declareWinnersTimer = setTimer(declareWinners, 4000, 1)
end

function declareWinners()
	if gameOver then return end

	declareWinnersTimer = nil
	if checkPlayersHeightTimer then
		if isTimer(checkPlayersHeightTimer) then
			killTimer(checkPlayersHeightTimer)
		end
		checkPlayersHeightTimer = nil
	end

	gameOver = true

	local winners = getPlayersInTeam(teamAlive)
	local winnersList = ""
	for k, v in ipairs(winners) do
		if k == 1 then
			winnersList = getPlayerName(v)
		else
			winnersList = winnersList .. "\n" .. getPlayerName(v)
		end
		setElementData(v, "Wins", (getElementData(v, "Wins")) + 1)
	end

	if #winners > 0 then
		textItemSetText(textItems.winnersText, "Winners:\n" .. winnersList)
	else
		textItemSetText(textItems.winnersText, "No Winners")
	end

	local players = getElementsByType("player")
	for k, v in pairs(players) do
		textDisplayAddObserver(textDisplays.winnersDisplay, v)
		if (getElementData(v, "Losses")) == 0 then --Update W/L Ratio (checks for special case of divide by 0)
			local playerRatio = (getElementData(v, "Wins"))
			setElementData(v, "W/L Ratio", tostring(playerRatio))
		else
			local playerRatio = math.ceil((getElementData(v, "Wins") / getElementData(v, "Losses")) * 1000) / 1000
			setElementData(v, "W/L Ratio", tostring(playerRatio)) --Update ratio every game. tostringed due to decimal places bug
		end
	end
	updateTournamentLeaders()

	--Rest is check for tournament winner stuff
	local winnerCount = 0
	for k, v in pairs(winners) do
		local playerwins = (getElementData(v, "Wins"))
		if tonumber(playerwins) >= config.scoreLimit then
			winnerCount = winnerCount + 1
		end
	end

	if winnerCount == 1 then
		textItemSetText(textItems.winnersText, "" .. getPlayerName(winners[1]) .. " won fallout! Starting a new tournament in 15 seconds.")
		newTournament = true
		setTimer(newGame, 15000, 1)
	elseif winnerCount > 1 then
		winTie = true
		setTimer(newGame, 3000, 1)
	else
		setTimer(newGame, 3000, 1)
	end
end

function quickKill(player, key, keyState)
	unbindKey(player, "space")
	killPed(player)
end

function activateSpectate(player) --Don't setTimer loop serverside, will cause bug when 2 players come in
	setCameraMatrix(player, 1558.367, -1346.678, 630, 1558.367, -1301.059, 603.105469)
	exports.freecam:setPlayerFreecamEnabled(player)
end

addEventHandler("onPlayerWasted", root,
function ()
	setPlayerTeam(source, nil)
	textDisplayRemoveObserver(textDisplays.suicideDisplay, source)
	activateSpectate(source)
end)

function reportPlayerLoss (player)

	playSoundFrontEnd(player, 4)
	textDisplayAddObserver(textDisplays.suicideDisplay, player)
	bindKey(player, "space", "down", quickKill)
	setElementData(player, "Losses", (getElementData(player, "Losses")) + 1)

	if gameOver == true then return end

	local remainingPlayers = countPlayersInTeam(teamAlive)
	if (remainingPlayers == 1) then --Detect early victories
		startDeclareWinnersTimer()
	elseif (remainingPlayers == 0) then
		startDeclareWinnersTimer()
	end
end

addEventHandler("onPlayerJoin", root,
function ()
	setElementData(source, "Wins", 0)
	setElementData(source, "Losses", 0)
	setElementData(source, "W/L Ratio", 0)
	textDisplayAddObserver(textDisplays.podiumDisplay, source)
	setCameraMatrix(source, 1558.367, -1346.678, 630, 1558.367, -1301.059, 603.105469)
end)

function spawnPlayers()
	if getActiveBoardElementCount() == 0 then return end
	local leaders = getLeaders()
	local players = getElementsByType("player")
	for k, player in pairs(players) do
		exports.freecam:setPlayerFreecamDisabled(player)
		setPlayerTeam(player, teamAlive)
		textDisplayAddObserver(textDisplays.countDownDisplay, player)
		local spawningBoard = getRandomActiveBoard()
		local x, y, z = getElementPosition(spawningBoard)
		local changeX = math.random(0, 1)
		local changeY = math.random(0, 1)

		if changeX == 0 then --Choose random position across spawn board surface
			x = x - math.random(0, 200) / 100
		elseif changeX == 1 then
			x = x + math.random(0, 200) / 100
		end

		if changeY == 0 then
			y = y - math.random(0, 200) / 100
		elseif changeY == 1 then
			y = y + math.random(0, 200) / 100
		end

		local spawnAngle = 360 - math.deg(math.atan2((1557.987182 - x), (-1290.754272 - y)))

		local skinID = 209 -- Noodle vender
		if leaders[1] and leaders[1].player == player then
			skinID = 167 -- Chicken
		elseif leaders[2] and leaders[2].player == player then
			skinID = 205 -- Burger girl
		elseif leaders[3] and leaders[3].player == player then
			skinID = 155 -- Pizza guy
		end

		spawnPlayer(player, x, y, 607.105469, spawnAngle, skinID)
		if config.peacefulMode then
			toggleControl ( player, "fire", false )
		end
	end
end

addEventHandler("onPlayerSpawn", root, function ()
	setCameraTarget(source) -- Disabling freecam does not set the camera back to the player, this line fixes that.
end)

function newGameCountdown()
	if countdown > 0 then
		if winTie == false then
			textItemSetText(textItems.countDownText, "Tournament length: " .. config.scoreLimit .. " wins" .. "\n" .. "Get ready!" .. "\n" .. countdown)
		else --set special tie game text
			textItemSetText(textItems.countDownText, "Tournament length: " .. config.scoreLimit .. " wins - Tiebreaker game!!!" .. "\n" .. "Get ready!" .. "\n" .. countdown)
		end

		setTimer(newGameCountdown, 1000, 1)
		countdown = countdown - 1
		playSoundFrontEnd(root, 44) -- Race countdown nr. 44
	else
		local players = getElementsByType("player")
		for k, player in pairs(players) do
			textDisplayRemoveObserver(textDisplays.countDownDisplay, player)
		end

		if not checkPlayersHeightTimer and not isTimer(checkPlayersHeightTimer) then
			checkPlayersHeightTimer = setTimer(checkPlayersHeight, 300, 0)
		end

		playSoundFrontEnd(root, 45) -- Race countdown nr. 45
		--Erase countdown for displaying 'get ready' next game prior to countdown
		if winTie == false then --needed for display consistency
			textItemSetText(textItems.countDownText, "Tournament length: " .. config.scoreLimit .. " wins" .. "\n" .. "Get ready!" .. "\n" .. "")
		else
			textItemSetText(textItems.countDownText, "Tournament length: " .. config.scoreLimit .. " wins - Tiebreaker game!!!" .. "\n" .. "Get ready!" .. "\n" .. "")
		end
		gameOver = false
		breakAwayPieces() --Game starts, boards fall
	end
end

-- Check player height and report a loss if the player has fall off
function checkPlayersHeight ()
	local alivePlayers = getPlayersInTeam(teamAlive)
	for i=1, #alivePlayers do
		local player = alivePlayers[i]
		local x, y, z = getElementPosition(player)
		if z < 595 then
			setPlayerTeam(player, nil)
			reportPlayerLoss(player)
		end
	end
end

function cleanupOldGame()
	resetActiveBoards()
	destroyBoards()

	for timerKey, timer in ipairs(getTimers()) do
		killTimer(timer)
	end

	local players = getElementsByType("player")
	for k, player in pairs(players) do
		unbindKey(player, "space")
		textDisplayRemoveObserver(textDisplays.winnersDisplay, player)
		textDisplayRemoveObserver(textDisplays.suicideDisplay, player)
		textDisplayRemoveObserver(textDisplays.spectatorCamDisplay, player)
		setCameraTarget(player)
	end
end

function emptyPodium()
	textItemSetText(textItems.firstText, "1st:") --Avoid double entries on podium
	textItemSetText(textItems.secondText, "2nd:")
	textItemSetText(textItems.thirdText, "3rd:")
end

function newGame()
	cleanupOldGame()

	if newTournament == true then
		local players = getElementsByType("player")
		for k, player in pairs(players) do
			setElementData(player, "Wins", 0)
			setElementData(player, "Losses", 0) --|
			setElementData(player, "W/L Ratio", 0)
		end

		emptyPodium()
		newTournament = false
		winTie = false
	end

	createBoards()
	spawnPlayers() --Add players to countdown text display and teamAlive
	setWeather(math.random(0, 19))
	setTime(math.random(0, 23), 00)
	countdown = 3 --Set here for first game only
	setTimer(newGameCountdown, 3000, 1)
	setSkyGradient( 200, 170, 70, 176, 170, 200 )
	setCloudsEnabled (false) -- Disable clouds to improve FPS
end
addEventHandler("onResourceStart", resourceRoot, newGame) --Initiate first game

addEventHandler("onResourceStop", root,
function () --Prevent invisible bug, reset cam on unload
	local players = getElementsByType("player")
	for k, player in pairs(players) do
		setCameraTarget(player)
		toggleControl ( player, "fire", true )
	end
	local scoreboardResource = getResourceFromName("scoreboard")
	call(scoreboardResource, "removeScoreboardColumn", "Wins")
	call(scoreboardResource, "removeScoreboardColumn", "Losses")
	call(scoreboardResource, "removeScoreboardColumn", "W/L Ratio")
	gameOver = false
end)


