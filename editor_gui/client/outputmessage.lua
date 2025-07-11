local g_screenX,g_screenY = guiGetScreenSize()
local message = { timers = {}, animations = {} }
local TEXT_SCALE = 1
local TEXT_FONT = "default-bold"
local FADE_TIME = 350
local MOVE_DELAY,MOVE_SPEED = 1700,0.05--pixels/ms
--
addEvent ( "doOutputMessage", true )

local function setAlpha ( _, alpha ) message.a = alpha end
local function setTextAlpha ( _,alpha ) message.texta = alpha end
local function setX ( _, x ) message.x = x end
local function doAnimation (...) table.insert(message.animations,Animation.createAndPlay(...)) end

local function cleanup ()
	for k,t in ipairs(message.timers) do
		if isTimer(t) then
			killTimer ( t )
		end
	end
	message.timers = {}
	for k,animation in ipairs(message.animations) do
		animation:remove()
	end
	message.animations = {}
end

local function removeHandler()
	message.outputting = nil
	removeEventHandler ( "onClientRender", root, renderMessage )
end

function outputMessage ( text, r, g, b, time )
	cleanup()
	if type(text) ~= "string" then
		return false
	end
	message.r = r or 255
	message.g = g or 0
	message.b = b or 0
	message.a = a or 1
	time = time or 5000
	message.text = text
	--
	message.height = dxGetFontHeight ( TEXT_SCALE, TEXT_FONT ) + 4
	message.width = dxGetTextWidth ( text, TEXT_SCALE, TEXT_FONT )
	--
	message.y = g_screenY - message.height
	if message.width > g_screenX then
		message.x = 5
		local movedistance = message.width - screenX*0.75
		local movetime = movedistance/MOVE_SPEED
		time = math.max(time,movetime)
		--Create our animations
		table.insert(message.timers, setTimer ( function()
			doAnimation(setX,{{ from = 5, to = 5 - movedistance, time = time, fn = setX }}) end, MOVE_DELAY, 1 ))
		doAnimation(setAlpha,
			{{ from = 1, to = 140, time = FADE_TIME, fn = setAlpha }})
		table.insert(message.timers, setTimer ( function() doAnimation(setAlpha,
			{{ from = 140, to = 0, time = FADE_TIME, fn = setAlpha }}) end, MOVE_DELAY + time - FADE_TIME, 1 ))
		--
		doAnimation(setTextAlpha,
			{{ from = 1, to = 200, time = FADE_TIME, fn = setTextAlpha }})
		table.insert(message.timers, setTimer ( function() doAnimation(setTextAlpha,
			{{ from = 200, to = 0, time = FADE_TIME, fn = setTextAlpha }}) end, MOVE_DELAY + time - FADE_TIME, 1 ))
		--
		table.insert(message.timers, setTimer ( removeHandler, MOVE_DELAY + time, 1 ))

	else
		message.x = screenX/2 - message.width/2
		doAnimation (setAlpha,
			{{ from = 1, to = 140, time = FADE_TIME, fn = setAlpha }})
		table.insert(message.timers, setTimer ( function()  doAnimation (setAlpha,
			{{ from = 140, to = 0, time = FADE_TIME, fn = setAlpha },}) end, time, 1 ) )
		--
		doAnimation (setTextAlpha,
			{{ from = 1, to = 200, time = FADE_TIME, fn = setTextAlpha }})
		table.insert(message.timers, setTimer ( function()  doAnimation (setTextAlpha,
			{{ from = 200, to = 0, time = FADE_TIME, fn = setTextAlpha },}) end, time, 1 ) )
		--
		table.insert(message.timers, setTimer ( removeHandler, time + FADE_TIME, 1 ))
	end
	if not message.outputting then
		message.outputting = true
		addEventHandler ( "onClientRender", root, renderMessage )
	end
end
addEventHandler ( "doOutputMessage", root, outputMessage )

function renderMessage()
	dxDrawRectangle ( 0, message.y, g_screenX, g_screenY, tocolor(message.r,message.g,message.b,message.a), true )
	dxDrawText ( message.text, message.x, message.y, g_screenX, g_screenY, tocolor(0,0,0,message.texta), TEXT_SCALE, TEXT_FONT, "left", "center", false, false, true )
end


