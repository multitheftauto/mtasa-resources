--
--  startGamemodeClient: initializes the gamemode client
--
local function startGamemodeClient()
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
end
addEventHandler("onClientResourceStart", resourceRoot, startGamemodeClient)

--
--  stopGamemodeClient: cleans up the gamemode client
--
local function stopGamemodeClient()
    -- remove scoreboard columns
    exports.scoreboard:scoreboardRemoveColumn("Score")
    exports.scoreboard:scoreboardRemoveColumn("Rank")
    -- hide scoreboard
    exports.scoreboard:setScoreboardForced(false)
end
addEventHandler("onClientResourceStop", resourceRoot, stopGamemodeClient)

--
--  startGamemodeMap: triggered when a gamemode map starts
--
local function startGamemodeMap(mapTitle, mapAuthor, fragLimit, respawnTime)
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
addEvent("onClientGamemodeMapStart", true)
addEventHandler("onClientGamemodeMapStart", resourceRoot, startGamemodeMap)

--
-- stopGamemodeMap: triggered when a gamemode map stops
--
local function stopGamemodeMap()
    -- clear stored map data
    _mapTitle = nil
    _mapAuthor = nil
    _fragLimit = nil
    _respawnTime = nil
    -- hide loading text
    _hud.loadingScreen:setVisible(false)
end
addEvent("onClientGamemodeMapStop", true)
addEventHandler("onClientGamemodeMapStop", resourceRoot, stopGamemodeMap)

--
--  startGamemodeRound: triggered when a round begins
--
local function startGamemodeRound()
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
addEvent("onClientGamemodeRoundStart", true)
addEventHandler("onClientGamemodeRoundStart", resourceRoot, startGamemodeRound)

--
--  stopGamemodeRound: triggered when a round ends
--
local function stopGamemodeRound(winner, draw, aborted)
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
addEvent("onClientGamemodeRoundEnd", true)
addEventHandler("onClientGamemodeRoundEnd", resourceRoot, stopGamemodeRound)

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
