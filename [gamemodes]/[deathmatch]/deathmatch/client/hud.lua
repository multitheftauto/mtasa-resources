local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()

--
--  client HUD definitions
--
_hud = {}
-- loading screen
_hud.loadingScreen = {}
_hud.loadingScreen.deathmatchText = dxText:create("Deathmatch", 0, 0, false, "bankgothic", 2)
_hud.loadingScreen.deathmatchText:color(230, 200, 110)
_hud.loadingScreen.deathmatchText:boundingBox(0, 0, 1, 0.2, true)
_hud.loadingScreen.deathmatchText:align("bottom", "center")
_hud.loadingScreen.deathmatchText:type("stroke", 1)
_hud.loadingScreen.mapInfoText = dxText:create("", 0, 0, false, "pricedown", 2)
_hud.loadingScreen.mapInfoText:color(125, 85, 13)
_hud.loadingScreen.mapInfoText:boundingBox(0, 0.65, 0.95, 1, true)
_hud.loadingScreen.mapInfoText:align("right", "top")
_hud.loadingScreen.mapInfoText:type("stroke", 1)
_hud.loadingScreen.setVisible = function(_, visible)
    _hud.loadingScreen.deathmatchText:visible(visible)
    _hud.loadingScreen.mapInfoText:visible(visible)
end
_hud.loadingScreen.update = function()
    _hud.loadingScreen.mapInfoText:text(_mapTitle..(_mapAuthor and ("\n by ".._mapAuthor) or ""))
end

-- score display
_hud.scoreDisplay = {}
_hud.scoreDisplay.roundInfoText = dxText:create("", 0, 0, false, "bankgothic", 1)
_hud.scoreDisplay.roundInfoText:color(175, 200, 240)
_hud.scoreDisplay.roundInfoText:boundingBox(0, 0, 0.95, 0.95, true)
_hud.scoreDisplay.roundInfoText:align("right", "bottom")
_hud.scoreDisplay.roundInfoText:type("stroke", 1)
_hud.scoreDisplay.setVisible = function(_, visible)
    _hud.scoreDisplay.roundInfoText:visible(visible)
end
_hud.scoreDisplay.update = function()
    -- don't do anything if a round isn't in progress
    if getElementData(resourceRoot, "gameState") ~= GAME_IN_PROGRESS then
        return
    end
    -- update score and rank text
    local score = getElementData(localPlayer, "Score")
    local rank = getElementData(localPlayer, "Rank")
    _hud.scoreDisplay.roundInfoText:text(
        "Score: "..score..(_fragLimit > 0 and "/".._fragLimit or "")
        .."\nRank: "..getElementData(localPlayer, "Rank").."/"..#getElementsByType("player")
    )
end

-- wasted screen
_hud.wastedScreen = {}
_hud.wastedScreen.text = dxText:create("Wasted", 0.5, 0.5, true, "beckett", 4)
_hud.wastedScreen.text:type("border", 2)
_hud.wastedScreen.text:color(255, 0, 0)
_hud.wastedScreen.setVisible = function(_, visible)
    _hud.wastedScreen.text:visible(visible)
end

-- end screen
_hud.endScreen = {}
-- announcement text (x has won the round!)
_hud.endScreen.announcementText = dxText:create("", 0, 0, false, "pricedown", 2)
_hud.endScreen.announcementText:color(225, 225, 225, 225)
_hud.endScreen.announcementText:boundingBox(0, 0, 1, 0.2, true)
_hud.endScreen.announcementText:align("bottom", "center")
_hud.endScreen.announcementText:type("border", 1)
_hud.endScreen.setVisible = function(_, visible)
    _hud.endScreen.announcementText:visible(visible)
end
_hud.endScreen.update = function(_, winner, draw, aborted)
    if winner then
        _hud.endScreen.announcementText:text(getPlayerName(winner).." has won the round!")
        _hud.endScreen.announcementText:color(getPlayerNametagColor(winner))
    else
        if draw then
            _hud.endScreen.announcementText:text("The round was a draw!")
        else
            _hud.endScreen.announcementText:text("Round ended.")
        end
        _hud.endScreen.announcementText:color(225, 225, 225, 225)
    end
    if not aborted then
        playSound("client/audio/mission_accomplished.mp3")
    end
end

-- spectate screen
_hud.spectateScreen = {}
-- spectating info label
_hud.spectateScreen.infoLabel = dxText:create("You are currently spectating.\nUse left and right arrow to switch players.", 0, 0, false, "default-bold", 2)
_hud.spectateScreen.infoLabel:color(225, 225, 225, 225)
_hud.spectateScreen.infoLabel:boundingBox(0, 0.8, 1, 1, true)
_hud.spectateScreen.infoLabel:align("bottom", "center")
_hud.spectateScreen.infoLabel:type("border", 2)
_hud.spectateScreen.setVisible = function(_, visible)
    _hud.spectateScreen.infoLabel:visible(visible)
end

-- hide all HUD elements by default
_hud.loadingScreen:setVisible(false)
_hud.scoreDisplay:setVisible(false)
_hud.wastedScreen:setVisible(false)
_hud.endScreen:setVisible(false)
_hud.spectateScreen:setVisible(false)