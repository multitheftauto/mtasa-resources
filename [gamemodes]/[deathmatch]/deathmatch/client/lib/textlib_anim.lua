--This script extends client_anim by providing a set of presets for textlib classes, mimicing the gui presets.
local screenX,screenY = guiGetScreenSize()

local function setDXAlpha(dx,alpha)
	local r,g,b = dx:color()
	dx:color(r,g,b,alpha)
end

function Animation.presets.dxTextPulse(time, value, phase)
	-- dxTextPulse(time)
	-- Pulses text (scale down/up). time = ms for a complete pulsation cycle
	if type(time) ~= 'table' then
		return { from = 0, to = 2*math.pi, transform = math.sin, time = time, repeats = 0, fn = Animation.presets.dxTextPulse }
	else
		local elem = time
		if not phase.scale then
			phase.scale = elem:scale()
		end
		local pct = 1 - (value+1)*0.1
		local scale = pct*phase.scale
		elem:scale(scale)
	end
end

function Animation.presets.dxTextFadeIn(time)
	return { from = 0, to = 255, time = time or 1000, fn = setDXAlpha }
end

function Animation.presets.dxTextFadeOut(time)
	return { from = 255, to = 0, time = time or 1000, fn = setDXAlpha }
end

function Animation.presets.dxTextMove(endX, endY, time, loop, startX, startY, speedUpSlowDown)
	--NB: ABSOLUTE POSITION
	-- dxTextMove(endX, endY, [ time = 1000, loop = false, startX = current X, startY = current Y, speedUpSlowDown = false ])
	if type(endX) ~= 'table' then
		return { from = speedUpSlowDown and -math.pi/2 or 0, to = speedUpSlowDown and math.pi/2 or 1,
		         time = time or 1000, repeats = loop and 0 or 1, fn = Animation.presets.dxTextMove,
		         startX = startX, startY = startY, endX = endX, endY = endY, speedUpSlowDown = speedUpSlowDown }
	else
		local elem, value, phase = endX, endY, time
		if phase.speedUpSlowDown then
			value = (value + 1)/2
		end
		if not phase.startX then
			phase.startX, phase.startY = elem:position()
			if elem.bRelativePosition then
				phase.startX, phase.startY = phase.startX*screenX, phase.startY*screenY
			end
		end
		local x = (phase.startX + (phase.endX - phase.startX)*value)/screenX
		local y = (phase.startY + (phase.endY - phase.startY)*value)/screenY
		elem:position(x,y)
	end
end

function Animation.presets.dxTextMoveResize(endX, endY, endScale, time, loop, startX, startY, startScale, speedUpSlowDown)
	--NB: ABSOLUTE POSITION/SIZE
	-- dxTextMoveResize(endX, endY, endScale, [ time = 1000, loop = false, startX = current X, startY = current Y,
	--   startScale = currentScale, speedUpSlowDown = false ])
	if type(endX) ~= 'table' then
		return { from = speedUpSlowDown and -math.pi/2 or 0, to = speedUpSlowDown and math.pi/2 or 1,
		         time = time or 1000, repeats = loop and 0 or 1, transform = math.sin, fn = Animation.presets.dxTextMoveResize,
		         startX = startX, startY = startY, startScale = startScale,
		         endX = endX, endY = endY, endScale = endScale, speedUpSlowDown = speedUpSlowDown }
	else
		local elem, value, phase = endX, endY, endScale
		if phase.speedUpSlowDown then
			value = (value + 1)/2
		end
		if not phase.startX then
			phase.startX, phase.startY = elem:position()
			if elem.bRelativePosition then
				phase.startX, phase.startY = phase.startX*screenX, phase.startY*screenY
			end
			phase.startScale = elem:scale()
		end
		local x = (phase.startX + value*(phase.endX - phase.startX))/screenX
		local y = (phase.startY + value*(phase.endY - phase.startY))/screenY
		elem:position(x,y)
		local scale = (phase.startScale + value*(phase.endScale - phase.startScale))
		elem:scale(scale)
	end
end
