-- TODO: long term - implement new UI resembling original game design
-- TODO: ui element fade out
local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()

_hudElements = {}

_hudElements.loadingText = dxText:create("", 0, 0, false, "bankgothic", 1)
_hudElements.loadingText:boundingBox(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, false)
_hudElements.loadingText:align("center", "center")
--_hudElements.loadingText:type("stroke", 1) TODO: is this needed for fading out well?
_hudElements.loadingText:visible(false)

_hudElements.fragLimit = dxText:create("", 0, 0, false, "default-bold", 1)
_hudElements.fragLimit:boundingBox(0, 35, SCREEN_WIDTH, SCREEN_HEIGHT, false)
_hudElements.fragLimit:align("center", "top")
_hudElements.fragLimit:type("stroke", 1)
_hudElements.fragLimit:visible(false)

_hudElements.announcementText = dxText:create("", 0, 0, false, "bankgothic", 1)
_hudElements.announcementText:boundingBox(0, 0.1, 1, 1, true)
_hudElements.announcementText:align("center", "top")
_hudElements.announcementText:type("stroke", 1)
_hudElements.fragLimit:visible(false)

--CONFIG
local fragWidth = 146
local fragHeight = 68
local fragTextScale = 2
local textScale = 1.5
local fragStartX = SCREEN_WIDTH - 20 - fragWidth
local fragStartY = SCREEN_HEIGHT - 20 - fragHeight
g_FragColor = tocolor(255,255,255,255)

_hudElements.respawnText = dxText:create("", 0.5, 0.5, true, "pricedown", 2)
_hudElements.respawnText:type("stroke", 1.2)
_hudElements.respawnText:color(255, 0, 0, 0)
_hudElements.respawnText:visible(false)

_hudElements.fragImage = guiCreateStaticImage(fragStartX, fragStartY, fragWidth, fragHeight, "images/frag.png", false)
--_hudElements.fragImage:visible(false) -- TODO: does this work?

_hudElements.fragText = dxText:create("0", 0, 0, true, "pricedown", 2)
_hudElements.fragText:type("stroke", 2)
_hudElements.fragText:postGUI(true)
_hudElements.fragText:boundingBox(fragStartX + 65, fragStartY + 15, fragStartX + 131, fragStartY + fragHeight - 10, false)
_hudElements.fragText:visible(false)

_hudElements.spreadText = dxText:create("Spread: 0", 0, 0, true, "Arial", textScale)
_hudElements.spreadText:align("right", "bottom")
_hudElements.spreadText:type("shadow", 2, 2)
_hudElements.spreadText:boundingBox(0, 0, fragStartX + fragWidth - 20, fragStartY - 2, false)
_hudElements.spreadText:visible(false)

_hudElements.rankText = dxText:create("Rank:  -/-", 0, 0, true, "Arial", textScale)
_hudElements.rankText:align("right", "bottom")
_hudElements.rankText:type("shadow", 2, 2)
_hudElements.rankText:boundingBox(0, 0, fragStartX + fragWidth - 20, fragStartY - 2 - dxGetFontHeight(textScale, "Arial"), false)
_hudElements.rankText:visible(false)