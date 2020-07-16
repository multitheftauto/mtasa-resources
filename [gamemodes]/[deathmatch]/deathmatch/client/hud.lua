-- TODO:    long term - implement new UI resembling original game design
--          more code cleanup?
local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()

--
--  client HUD definitions
--
_hud = {}
-- loading screen
_hud.loadingScreen = {}
_hud.loadingScreen.mapInfoText = dxText:create("", 0, 0, false, "bankgothic", 1)
_hud.loadingScreen.mapInfoText:boundingBox(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, false)
_hud.loadingScreen.mapInfoText:align("center", "center")
_hud.loadingScreen.mapInfoText:type("stroke", 1)
_hud.loadingScreen.setVisible = function(_, visible)
    _hud.loadingScreen.mapInfoText:visible(visible)
end
_hud.loadingScreen.update = function()
    _hud.loadingScreen.mapInfoText:text("Now playing:\n".._mapTitle..(_mapAuthor and (" by ".._mapAuthor) or ""))
end
-- score display
_hud.scoreDisplay = {}
-- frag limit text (Frag Limit: x)
_hud.scoreDisplay.fragLimitText = dxText:create("", 0, 0, false, "default-bold", 1)
_hud.scoreDisplay.fragLimitText:boundingBox(0, 35, SCREEN_WIDTH, SCREEN_HEIGHT, false)
_hud.scoreDisplay.fragLimitText:align("center", "top")
_hud.scoreDisplay.fragLimitText:type("stroke", 1)
-- magic numbers
local fragWidth = 146
local fragHeight = 68
--scoreDisplay.textScale = 2
local textScale = 1.5
local fragStartX = SCREEN_WIDTH - 20 - fragWidth
local fragStartY = SCREEN_HEIGHT - 20 - fragHeight
-- frag image (background for frag count)
_hud.scoreDisplay.fragImage = guiCreateStaticImage(fragStartX, fragStartY, fragWidth, fragHeight, "images/frag.png", false)
-- frag count
_hud.scoreDisplay.fragCount = dxText:create("0", 0, 0, true, "pricedown", 2)
_hud.scoreDisplay.fragCount:type("stroke", 2)
_hud.scoreDisplay.fragCount:postGUI(true)
_hud.scoreDisplay.fragCount:boundingBox(fragStartX + 65, fragStartY + 15, fragStartX + 131, fragStartY + fragHeight - 10, false)
-- spread text (Spread: x)
_hud.scoreDisplay.spreadText = dxText:create("Spread: 0", 0, 0, true, "Arial", textScale)
_hud.scoreDisplay.spreadText:align("right", "bottom")
_hud.scoreDisplay.spreadText:type("shadow", 2, 2)
_hud.scoreDisplay.spreadText:boundingBox(0, 0, fragStartX + fragWidth - 20, fragStartY - 2, false)
-- rank text (Rank: x/x)
_hud.scoreDisplay.rankText = dxText:create("Rank:  -/-", 0, 0, true, "Arial", textScale)
_hud.scoreDisplay.rankText:align("right", "bottom")
_hud.scoreDisplay.rankText:type("shadow", 2, 2)
_hud.scoreDisplay.rankText:boundingBox(0, 0, fragStartX + fragWidth - 20, fragStartY - 2 - dxGetFontHeight(textScale, "Arial"), false)
_hud.scoreDisplay.setVisible = function(_, visible)
    guiSetVisible(_hud.scoreDisplay.fragImage, visible)
    _hud.scoreDisplay.fragCount:visible(visible)
    _hud.scoreDisplay.spreadText:visible(visible)
    _hud.scoreDisplay.rankText:visible(visible)
    _hud.scoreDisplay.fragLimitText:visible(visible)
end
_hud.scoreDisplay.update = function()
    -- don't do anything if a round isn't in progress
    if getElementData(resourceRoot, "gameState") ~= GAME_IN_PROGRESS then
        return
    end
    -- update score count
    local score = getElementData(localPlayer, "Score")
    _hud.scoreDisplay.fragCount:text(tostring(score))
    if (score < 0) then
        _hud.scoreDisplay.fragCount:color(255,0,0,255)
    else
        _hud.scoreDisplay.fragCount:color(255,255,255,255)
    end
    -- shrink the score count font is it's greater than 3 digits
    local length = #tostring(score)
    if length >= 3 then
        _hud.scoreDisplay.fragCount:scale(textScale - ((length - textScale)^0.7)*0.5)
    else
        _hud.scoreDisplay.fragCount:scale(_hud.textScale)
    end
    -- update frag limit text
    if _fragLimit == 0 then return end
    _hud.scoreDisplay.fragLimitText:text("Frag Limit: ".._fragLimit)
    -- update rank
    local players = getElementsByType("player")
    local rank = getElementData(localPlayer, "Rank")
	_hud.scoreDisplay.rankText:text ( "Rank "..getElementData(localPlayer, "Rank").."/"..#players )
	-- update spread
	local spreadTargetScore = (rank == 1) and
				getElementData ( players[2] or players[1], "Score" )
				or getElementData ( players[1], "Score" ) or 0
	local spread = score - spreadTargetScore
	_hud.scoreDisplay.spreadText:text("Spread: "..spread)
end
-- respawn screen
_hud.respawnScreen = {}
-- respawn counter (You will respawn in x seconds)
_hud.respawnScreen.respawnCounter = dxText:create("", 0.5, 0.5, true, "pricedown", 2)
_hud.respawnScreen.respawnCounter:type("stroke", 1.2)
_hud.respawnScreen.respawnCounter:color(255, 0, 0, 0)
_hud.respawnScreen.respawnCounter:visible(false)
_hud.respawnScreen.setVisible = function(_, visible)
    _hud.respawnScreen.respawnCounter:visible(visible)
end
_hud.respawnScreen.startCountdown = function()
    if _respawnTime > 0 then
        startCountdown(_respawnTime)
    end
end
-- end screen
_hud.endScreen = {}
-- announcement text (x has won the round!)
_hud.endScreen.announcementText = dxText:create("", 0, 0, false, "bankgothic", 1)
_hud.endScreen.announcementText:boundingBox(0, 0.1, 1, 1, true)
_hud.endScreen.announcementText:align("center", "top")
_hud.endScreen.announcementText:type("stroke", 1)
_hud.endScreen.setVisible = function(_, visible)
    _hud.endScreen.announcementText:visible(visible)
end
_hud.endScreen.update = function(_, winner, draw)
    if winner then
        _hud.endScreen.announcementText:text(getPlayerName(winner).." has won the round!")
        _hud.endScreen.announcementText:color(getPlayerNametagColor(winner))
    else
        if draw then
            _hud.endScreen.announcementText:text("The round was a draw!")
        else
            _hud.endScreen.announcementText:text("Round ended.")
        end
        _hud.endScreen.announcementText:color(255, 255, 255, 255)
    end
end
-- hide all HUD elements by default
_hud.loadingScreen:setVisible(false)
_hud.scoreDisplay:setVisible(false)
_hud.respawnScreen:setVisible(false)
_hud.endScreen:setVisible(false)

-- TODO: clean this junk up
local function dxSetAlpha ( dx, a )
	local r,g,b = dx:color()
	dx:color(r,g,b,a)
end

local countdownCR
local function countdown(time)
	for i=time,0,-1 do
		_hud.respawnScreen.respawnCounter:text("You will respawn in "..i.." seconds")
		setTimer ( countdownCR, 1000, 1 )
		coroutine.yield()
	end
end

local function hideCountdown()
	setTimer (
		function()
			_hud.respawnScreen:setVisible(false)
		end,
		600, 1
	)
	Animation.createAndPlay(
	  _hud.respawnScreen.respawnCounter,
	  {{ from = 255, to = 0, time = 400, fn = dxSetAlpha }}
	)
	removeEventHandler ( "onClientPlayerSpawn", localPlayer, hideCountdown )
end

function startCountdown(time)
    Animation.createAndPlay(
        _hud.respawnScreen.respawnCounter,
        {{ from = 0, to = 255, time = 600, fn = dxSetAlpha }}
    )
    addEventHandler ( "onClientPlayerSpawn", localPlayer, hideCountdown )
    _hud.respawnScreen:setVisible(true)
    time = math.floor(time/1000)
    countdownCR = coroutine.wrap(countdown)
    countdownCR(time)
end
