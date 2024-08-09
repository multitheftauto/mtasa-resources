local _spectating = false
local _currentTarget
local _validTargets = {}

--
--  startSpectating([target]): starts spectating the targted player, or a random one if target == nil
--
function startSpectating(target)
    -- fade camera out, hide radar hud and score screen
    fadeCamera(false, 0)
    setPlayerHudComponentVisible("radar", false)
    _hud.scoreDisplay:setVisible(false)
    
    -- hide wasted screen and destroy wasted timer
    _hud.wastedScreen:setVisible(false)
    if isElement(_wastedTimer) then
        destroyElement(_wastedTimer)
    end

    -- if target is nil, pick a random player
    if not target then
        target = _validTargets[math.random(1, #_validTargets)]
    end

    -- if there still isn't a target, error out
    if not target then
        -- TODO: handle this more gracefully
        error("no valid spectate target", 2)
    end
    
    -- set camera target and disable controls
    iprint(target)
    setCameraTarget(target)
    toggleAllControls(false, true, false)

    -- show spectate screen
    _hud.spectateScreen:setVisible(true)

    -- bind left and right arrow keys to cycle spectate target
    bindKey("left", "down", cycleSpectateTarget, true)
    bindKey("right", "down", cycleSpectateTarget)

    -- fade camera in next frame
    setTimer(fadeCamera, 50, 1, true, 1)

    _spectating = true
    _currentTarget = nil
end

--
-- stopSpectating([fadeOut]): exits spectate mode. if fadeOut == true camera will not fade back in
--
function stopSpectating(fadeOut)
    -- fade camera out, restore radar hud and score screen
    fadeCamera(false, 0)
    setPlayerHudComponentVisible("radar", true)
    _hud.scoreDisplay:setVisible(true)

    -- reset camera target and controls
    setCameraTarget(localPlayer)
    toggleAllControls(true, true, false)

    -- hide spectate screen
    _hud.spectateScreen:setVisible(false)

    -- bind left and right arrow keys to cycle spectate target
    unbindKey("left", "down", cycleSpectateTarget)
    unbindKey("right", "down", cycleSpectateTarget)

    -- fade camera in next frame
    if not fadeOut then
        setTimer(fadeCamera, 50, 1, true, 1)
    end

    _spectating = false
    _currentTarget = nil
end

--
-- isSpectating(): returns true if local player is spectating, false otherwise
--
function isSpectating()
    return _spectating
end

--
--  setSpectateTarget(target): updates spectate target
--
function setSpectateTarget(target)
    if not _spectating then
        error("local player is not spectating", 2)
    end
 
    if target == _currentTarget then
        return
    end

    _currentTarget = target
    setCameraTarget(target)
end

--
--  cycleSpectateTarget(): cycles to next or previous target while in spectate mode
--
function cycleSpectateTarget(previous)
    if not _spectating then
        error("local player is not spectating", 2)
    end

    local index = 1
    for i, validTarget in ipairs(_validTargets) do
        if validTarget == _currentTarget then
         index = i
            break
        end
    end

    if previous then
        index = index - 1
        if index < 1 then
            index = #_validTargets
        end
    else
        index = index + 1
        if index > #_validTargets then
            index = 1
        end
    end

    setSpectateTarget(_validTargets[index])
end

--
--  functions to update target list on player spawn, death, and resource start
--
local function addValidTarget(playerTeam)
    if source == localPlayer then
        return
    end

    table.insert(_validTargets, source)
end
addEventHandler("onClientPlayerSpawn", root, addValidTarget)

local function removeValidTarget()
    if source == localPlayer then
        return
    end

    for i, target in ipairs(_validTargets) do
        table.remove(_validTargets, i)
    end
end
addEventHandler("onClientPlayerWasted", root, removeValidTarget)

local function refreshValidTargets()
    local players = getElementsByType("player", root)

    -- remove local player and dead players from list
    for i, player in ipairs(players) do
        if player == localPlayer or isPedDead(player) then
            table.remove(players, i)
        end
    end

    _validTargets = players
end
addEventHandler("onClientResourceStart", resourceRoot, refreshValidTargets)