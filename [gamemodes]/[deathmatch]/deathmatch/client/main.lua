--
--  startDeathmatchClient: initializes the deathmatch client
--
local function startDeathmatchClient()
    -- add scoreboard columns
    exports.scoreboard:scoreboardAddColumn("Score")
    exports.scoreboard:scoreboardAddColumn("Rank")
    exports.scoreboard:scoreboardSetColumnPriority("Rank", 1)
    exports.scoreboard:scoreboardSetSortBy("Rank")
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
--  stopDeathmatchClient: cleans up the deathmatch client
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
    -- hide end screen and scoreboard
    _hud.endScreen:setVisible(false)
    exports.scoreboard:setScoreboardForced(false)
    -- update map data
    _mapTitle = mapTitle
    _mapAuthor = mapAuthor
    _fragLimit = fragLimit
    _respawnTime = respawnTime
    -- show loading screen
    _hud.loadingScreen:update()
    _hud.loadingScreen:setVisible(true)
end
addEvent("onClientDeathmatchMapStart", true)
addEventHandler("onClientDeathmatchMapStart", resourceRoot, startDeathmatchMap)

--
-- stopDeathmatchMap: triggered when a deathmatch map stops
--
local function stopDeathmatchMap()
    -- clear stored map data
    _mapTitle = nil
    _mapAuthor = nil
    _fragLimit = nil
    _respawnTime = nil
    -- hide loading text
    _hud.loadingScreen:setVisible(false)
end
addEvent("onClientDeathmatchMapStop", true)
addEventHandler("onClientDeathmatchMapStop", resourceRoot, stopDeathmatchMap)

--
--  startDeathmatchRound: triggered when a round begins
--
local function startDeathmatchRound()
    -- attach player wasted handler
    addEventHandler("onClientPlayerWasted", localPlayer, _hud.respawnScreen.startCountdown)
    -- attach element data change handler
    addEventHandler("onClientElementDataChange", root, elementDataChange)
    -- hide end/loading screens and scoreboard
    _hud.loadingScreen:setVisible(false)
    _hud.endScreen:setVisible(false)
    exports.scoreboard:setScoreboardForced(false)
    -- show score display
    _hud.scoreDisplay:update()
    _hud.scoreDisplay:setVisible(true)
end
addEvent("onClientDeathmatchRoundStart", true)
addEventHandler("onClientDeathmatchRoundStart", resourceRoot, startDeathmatchRound)

--
--  stopDeathmatchRound: triggered when a round ends
--
local function stopDeathmatchRound(winner, draw, aborted)
    -- remove player wasted handler and hide respawn screen if active
    removeEventHandler("onClientPlayerWasted", localPlayer, _hud.respawnScreen.startCountdown)
    _hud.respawnScreen.setVisible(false)
    -- remove element data change handler
    removeEventHandler("onClientElementDataChange", root, elementDataChange)
    -- hide score display
    _hud.scoreDisplay:setVisible(false)
    -- spectate the winner
    if winner and player ~= winner then
        if winner then
            setCameraTarget(winner)
        end
        toggleAllControls(true, true, false)
    end
    -- begin fading out the screen
    fadeCamera(false, CAMERA_LOAD_DELAY/1000)
    -- show end screen and scoreboard
    _hud.endScreen:update(winner, draw, aborted)
    _hud.endScreen:setVisible(true)
    exports.scoreboard:setScoreboardForced(true)
end
addEvent("onClientDeathmatchRoundEnd", true)
addEventHandler("onClientDeathmatchRoundEnd", resourceRoot, stopDeathmatchRound)

--
--  elementDataChange: triggered when element data changes - used to track score changes
--
function elementDataChange(key, oldValue, newValue)
    -- ignore changes if there isn't a round in progress
    if getElementData(resourceRoot, "gameState") ~= GAME_IN_PROGRESS then
        return
    end
    -- only respond to score-related data changes
    if key == "Score" or key == "Rank" then
        _hud.scoreDisplay.update()
        -- if its the local player's score being increased, play "subobjective complete ding"
        if key == "Score" and source == localPlayer and newValue > oldValue then
            playSoundFrontEnd(12)
        end
    end
end

--
--	calculateCameraMatrix: calculates the map loading camera matrix
--
function calculateLoadingCameraMatrix()
	local spawnpoints = getElementsByType("spawnpoint")
	if #spawnpoints == 0 then
		return {0,0,0,0,0,0}
	end
	-- calculate our camera position by calculating an average spawnpoint position
	local camX, camY, camZ = 0, 0, 0
	for i = 1, #spawnpoints do
		local x, y, z = getElementPosition(spawnpoints[i])
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
