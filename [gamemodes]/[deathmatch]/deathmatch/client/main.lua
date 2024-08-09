local _wastedTimer, _respawnTimer

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
    -- disable zone name HUD element
    setPlayerHudComponentVisible("area_name", false)
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
    -- re-enable zone name HUD element
    setPlayerHudComponentVisible("area_name", true)
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
    -- attach player spawn and wasted handler
    addEventHandler("onClientPlayerSpawn", localPlayer, localPlayerSpawn)
    addEventHandler("onClientPlayerWasted", localPlayer, localPlayerWasted)
    -- attach element data change handler
    addEventHandler("onClientElementDataChange", root, elementDataChange)
    -- stop spectating
    if isSpectating() then
        stopSpectating(true)
    end
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
    -- remove player spawn & wasted handler and hide respawn screen if active
    removeEventHandler("onClientPlayerWasted", localPlayer, localPlayerWasted)
    removeEventHandler("onClientPlayerSpawn", localPlayer, localPlayerSpawn)
    -- remove element data change handler
    removeEventHandler("onClientElementDataChange", root, elementDataChange)
    -- hide score display
    _hud.scoreDisplay:setVisible(false)
    -- hide wasted screen and cancel the wasted and respawn timers
    _hud.wastedScreen:setVisible(false)
    if isTimer(_wastedTimer) then
        killTimer(_wastedTimer)
    end
    if isElement(_respawnTimer) then
        destroyElement(_respawnTimer)
    end
    -- spectate the winner
    if winner and player ~= winner then
        startSpectating(winner)
    end
    -- exit spectate mode and go to black if round was aborted
    if aborted then
        if isSpectating() then
            stopSpectating(true)
        end
        fadeCamera(false, 0)
    else
        -- begin fading out the screen
        fadeCamera(false, ROUND_START_DELAY/1000)
        -- show end screen and scoreboard
        _hud.endScreen:update(winner, draw, aborted)
        _hud.endScreen:setVisible(true)
        exports.scoreboard:setScoreboardForced(true)
    end
end
addEvent("onClientGamemodeRoundEnd", true)
addEventHandler("onClientGamemodeRoundEnd", resourceRoot, stopGamemodeRound)

--
--  localPlayerWasted: triggered when local player is killed
--
function localPlayerWasted()
    -- show the wasted screen
    _hud.wastedScreen:setVisible(true)

    -- set timer to show the spectate screen
    _wastedTimer = setTimer(startSpectating, WASTED_CAMERA_DURATION, 1)

    -- create a respawn timer is repawn is enabled
    if _respawnTime > 0 then
        _respawnTimer = exports.missionTimer:createMissionTimer(WASTED_CAMERA_DURATION + _respawnTime, true, "You will respawn in %s seconds", 0.5, 50, true, "default-bold", 1)
    end
end

--
--  localPlayerSpawn: triggered when local player is spawned
--
function localPlayerSpawn()
    -- if we're spectating, stop spectating
    if isSpectating() then
        stopSpectating()
    end
    -- kill the respawn timer if it exists
    if isElement(_respawnTimer) then
        destroyElement(_respawnTimer)
    end
end

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
