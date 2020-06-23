--
--  startDeathmatchClient(): initializes the deathmatch client
--
local function startDeathmatchClient()
    -- add scoreboard columns
    exports.scoreboard:scoreboardAddColumn("Score")
    exports.scoreboard:scoreboardAddColumn("Rank")
    exports.scoreboard:scoreboardSetColumnPriority("Rank", 1)
    -- fade out camera
    fadeCamera(false, 0)
    -- if a game is in progress, apply the loading camera matrix
    if getElementData(resourceRoot, "gameState") == GAME_IN_PROGRESS then
        setCameraMatrix(unpack(calculateLoadingCameraMatrix()))
    end
    -- inform server we are ready to play
    triggerServerEvent("onDeathmatchPlayerReady", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, startDeathmatchClient)

--
--  stopDeathmatchClient(): cleans up the deathmatch client
--
local function stopDeathmatchClient()
    -- remove scoreboard columns
    exports.scoreboard:scoreboardRemoveColumn("Score")
    exports.scoreboard:scoreboardRemoveColumn("Rank")
    -- hide scoreboard
    exports.scoreboard:setScoreboardForced(false)
end
addEventHandler("onClientResourceStop", resourceRoot, stopDeathmatchClient)

--
--  startDeathmatchMap: triggered when a deathmatch map starts
--
local function startDeathmatchMap(mapTitle, mapAuthor, fragLimit, respawnTime)
    -- apply the loading camera matrix - used to stream-in map elements
    setCameraMatrix(unpack(calculateLoadingCameraMatrix()))

    -- hide announcement text and scoreboard
    _hudElements.announcementText:visible(false)
    exports.scoreboard:setScoreboardForced(false)

    -- store map data
    _fragLimit = fragLimit
    _respawnTime = respawnTime

    -- show loading text
    _hudElements.loadingText:text("Now playing:\n"..mapTitle..(mapAuthor and (" by "..mapAuthor) or ""))
    _hudElements.loadingText:visible(true)
end
addEvent("onClientDeathmatchMapStart", true)
addEventHandler("onClientDeathmatchMapStart", resourceRoot, startDeathmatchMap)

--
-- stopDeathmatchMap: triggered when a deathmatch map stops
--
local function stopDeathmatchMap()
    -- clear stored map data
    _fragLimit = nil
    _respawnTime = nil

    -- hide loading text
    _hudElements.loadingText:visible(false)
end
addEvent("onClientDeathmatchMapStop", true)
addEventHandler("onClientDeathmatchMapStop", resourceRoot, stopDeathmatchMap)

local function startDeathmatchRound()
    -- TODO: fade this out rather than dissappearing suddenly?
    _hudElements.loadingText:visible(false)
    _hudElements.announcementText:visible(false)
    exports.scoreboard:setScoreboardForced(false)

    _hudElements.fragLimit:text("Frag Limit: ".._fragLimit)
    _hudElements.fragLimit:visible(true)

    updateScores()
    --_hudElements.fragImage:visible(true)
    _hudElements.fragText:visible(true)
    _hudElements.spreadText:visible(true)
    _hudElements.rankText:visible(true)
end
addEvent("onClientDeathmatchRoundStart", true)
addEventHandler("onClientDeathmatchRoundStart", resourceRoot, startDeathmatchRound)

local function stopDeathmatchRound(winner, draw)
    _hudElements.fragLimit:visible(false)

    -- TODO: what happens if the winner leaves after the round ends but before this code is executed?
    if winner then
        _hudElements.announcementText:text(getPlayerName(winner).." has won the round!")
        _hudElements.announcementText:color(getPlayerNametagColor(winner))
    else
        if draw then
            _hudElements.announcementText:text("The round was a draw!")
        else
            -- TODO: if the round ends for no reason, should anything be displayed?
            _hudElements.announcementText:text("Round ended.")
        end
        _hudElements.announcementText:color(255, 255, 255, 255)
    end

    --_hudElements.fragImage:visible(false)
    _hudElements.fragText:visible(false)
    _hudElements.spreadText:visible(false)
    _hudElements.rankText:visible(false)

    _hudElements.announcementText:visible(true)
    exports.scoreboard:setScoreboardForced(true)
    iprint("onClientDeathmatchRoundEnded", winner, draw)
end
addEvent("onClientDeathmatchRoundEnded", true)
addEventHandler("onClientDeathmatchRoundEnded", resourceRoot, stopDeathmatchRound) -- TODO: use present-tense verb in event name

local function playerWasted()
    if source == localPlayer and getElementData(resourceRoot, "gameState") == GAME_IN_PROGRESS then
        startCountdown(_respawnTime)
    end
end
addEventHandler("onClientPlayerWasted", root, playerWasted)

local function updateDeathmatchScores()
    -- TODO
    outputDebugString("updateDeathmatchScores")
    updateScores() -- TODO: refactor
end
addEvent("onDeathmatchScoreUpdate", true)
addEventHandler("onDeathmatchScoreUpdate", resourceRoot, updateDeathmatchScores)

--
--	calculateCameraMatrix(): calculates the map loading camera matrix
--
function calculateLoadingCameraMatrix()
	local spawnpoints = getElementsByType("spawnpoint")
	if #spawnpoints == 0 then
		return {0,0,0,0,0,0}
	end
	-- calculate our camera position by calculating an average spawnpoint position
	local camX, camY, camZ = 0, 0, 0
	for _, spawnpoint in ipairs(spawnpoints) do
		local x, y, z = getElementPosition(spawnpoint)
		camX = camX + x
		camY = camY + y
		camZ = camZ + z
	end
	camX, camY, camZ = camX/#spawnpoints, camY/#spawnpoints, camZ/#spawnpoints + 30
	-- use a random spawnpoint as the look-at position
	local lookAt = spawnpoints[math.random(1, #spawnpoints)]
	lookX, lookY, lookZ = getElementPosition(lookAt)
	return {camX, camY, camZ, lookX, lookY, lookZ}
end

local function sortingFunction (a,b)
	return (getElementData(a,"Score") or 0) > (getElementData(b,"Score") or 0)
end

function updateScores()
	--if true then return end -- lol
	local currentScore = getElementData(localPlayer,"Score")
	if source == localPlayer then
		_hudElements.fragText:text(tostring(currentScore))
		if (currentScore < 0) then
			_hudElements.fragText:color(255,0,0,255)
		else
			_hudElements.fragText:color(255,255,255,255)
		end
		--Make the score smaller if the frag limit is 3 digits
		local length = #tostring(currentScore)
		if length >= 3 then
			_hudElements.fragText:scale(_hudElements.fragTextScale - ((length - _hudElements.fragTextScale)^0.7)*0.5)
		else
			_hudElements.fragText:scale(_hudElements.fragTextScale)
		end
		Animation.createAndPlay(
		  true,
		  {{ from = 510, to = 0, time = 400, fn = dxSetYellowFrag }}
		)
	end
	--Lets calculate local position
	local rank
	local players = getElementsByType"player"
	table.sort ( players, sortingFunction )
	for i,player in ipairs(players) do
		if player == localPlayer then
			rank = i
			break
		end
	end
	--Quickly account for drawing positions
	for i=rank,1,-1 do
		if currentScore == getElementData ( players[i], "Score" ) then
			rank = i
		else
			break
		end
	end
	--Calculate spread
	local spreadTargetScore = (rank == 1) and
				getElementData ( players[2] or players[1], "Score" )
				or getElementData ( players[1], "Score" ) or 0
	local spread = currentScore - spreadTargetScore
	_hudElements.spreadText:text("Spread: "..spread)
	if rank ~= currentRank then
		currentRank = rank
		_hudElements.rankText:text ( "Rank "..rank.."/"..#players )
		Animation.createAndPlay(
			_hudElements.rankText,
			{{ from = 0, to = 500, time = 600, fn = dxSetYellow }}
		)
	end
end
addEventHandler ( "onClientPlayerQuit", root, updateScores )
addEventHandler ( "onClientPlayerJoin", root, updateScores )