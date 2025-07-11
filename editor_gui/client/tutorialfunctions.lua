local screenX,screenY = guiGetScreenSize()
local BOX_COLOR,BOX_HEIGHT = -1358954496, 19
local FADE_TIME = 300
local TEXT_FONT,TEXT_COLOR = "default",{255,255,255}
local MOVE_DELAY,MOVE_SPEED = 1700,0.05--pixels/ms
local fontSize
local g_inTutorial = false
local nextTutorialID = 1

function setTutorialPosition ( id )
	if not g_inTutorial then return false end
	if not fontSize then
		if screenY <= 768 then --Use the small font for small resolutions
			fontSize = 1
		else
			fontSize = 1
		end
	end
	nextTutorialID = id + 1
	if not tutorial[id] then return end
	local message = tutorial[id].message
	popup(message)
	tutorial[id].initiate()
end

function tutorialNext()
	if not g_inTutorial then return false end
	setTutorialPosition(nextTutorialID)
end

local textShown,popupMove,popupFade,popupMoveStart,popupFadeStart,startX
local popupText = ""
function popup(text)
	popupFadeStart = getTickCount()
	if textShown then --we need to hide that text first
		popupFade = "out"
		textShown = true
		setTimer ( popup, FADE_TIME + 200, 1, text )
		return
	end
	popupMove,popupFade,startX = nil,nil,5
	popupText = text
	local width = dxGetTextWidth ( text, fontSize, TEXT_FONT )
	if (width + 5) > screenX then --We'll need to perform the scroll anim
		setTimer (
		function()
			popupMove = true
			popupMoveStart = getTickCount()
		end,
		MOVE_DELAY,
		1
		)
	end
	popupFade = "in"
	textShown = true
end

function drawRectangle()
	dxDrawRectangle ( 0, screenY - BOX_HEIGHT, screenX, BOX_HEIGHT, BOX_COLOR, true )
end

function drawText()
	local changeStartX,alpha = nil
	local fontHeight = dxGetFontHeight ( fontSize, TEXT_FONT )
	local fontWidth = dxGetTextWidth ( popupText, fontSize, TEXT_FONT )
	local posX = startX
	local currentTick = getTickCount()
	if ( popupFade ) then
		alpha = 255
		local tickDifference = currentTick - popupFadeStart
		local ratio = (tickDifference/FADE_TIME)
		if popupFade == "out" then
			alpha = 0
			ratio = 1 - ratio
		end
		if tickDifference < FADE_TIME then
			alpha = math.ceil(ratio * 255)
		end
		if alpha == 0 then
			textShown = false
		end
	end
	if ( popupMove ) then
		local tickDifference = currentTick - popupMoveStart
		local moveX = tickDifference*MOVE_SPEED
		if startX ~= screenX then
			if moveX >= fontWidth then
				changeStartX = true
				popupMoveStart = getTickCount()
			end
		else
			if moveX  >= fontWidth + screenX then
				popupMoveStart = getTickCount()
			end
		end
		posX = startX - moveX
	end
	dxDrawText ( popupText, posX, screenY - fontHeight, screenX, screenY, tocolor(255,255,255,alpha), fontSize, TEXT_FONT, "left", "center", false, false, true )
	if changeStartX then
		startX = screenX
	end
end

function startTutorial()
	g_inTutorial = true
	tutorialNext()
end

function stopTutorial()
	g_inTutorial = nil
end

function isInTutorial()
	return g_inTutorial
end

local glow = { color = tocolor(255,0,0,112) }
function glowButton ( currentButton )
	if not isElement(currentButton) and type(currentButton) ~= "table" then
		glow.show = nil
		glow.animation:remove()
		return
	end
	glow.animation = Animation.createAndPlay(
		dxPulse,
	  {
		{ from = 120, to = 0, time = 500, fn = dxPulse },
		{ from = 0, to = 120, time = 500, fn = dxPulse },
		repeats = 0,
	  }
	)
	glow.show = true
	glow.element = currentButton
end

function drawGlow()
	if not glow.show then return end
	if type(glow.element) == "table" then
		for k,element in ipairs(glow.element) do
			if guiGetVisible ( element ) then
				local x,y = guiGetPosition ( element, false )
				local width,height = guiGetSize ( element, false )
				dxDrawRectangle ( x + 1, y + 1, width - 1, height - 1, glow.color, true )
			end
		end
	else
		if not guiGetVisible ( glow.element ) then return end
		local x,y = guiGetPosition ( glow.element, false )
		local width,height = guiGetSize ( glow.element, false )
		dxDrawRectangle ( x + 1, y + 1, width - 1, height - 1, glow.color, true )
	end
end

function dxPulse(f,alpha)
	glow.color = tocolor(255,0,0,alpha)
end
