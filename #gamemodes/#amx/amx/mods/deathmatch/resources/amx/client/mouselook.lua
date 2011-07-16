-- implements a mouse look for spectating e.g. vehicles, as MTA's setCameraTarget only supports players

local screenWidth, screenHeight = guiGetScreenSize()

local phi, theta = false, false
local target
local distance = false

local sin = math.sin
local cos = math.cos
local pi = math.pi

local _setCameraMatrix = setCameraMatrix

local function scale(factor, baseX, baseY, baseZ, x, y, z)
	return baseX + factor*(x-baseX), baseY + factor*(y-baseY), baseZ + factor*(z-baseZ)
end

local function onRender()
	if not phi or not theta then
		return
	end
	local x, y, z = getElementPosition(target)
	local camX = x + 3*distance*cos(phi)*cos(theta)
	local camY = y + 3*distance*sin(phi)*cos(theta)
	local camZ = z + 0.4*distance + 2*distance*sin(theta)
	local camLookZ = z + 0.5*distance
	local hit, hitX, hitY, hitZ = processLineOfSight(x, y, camLookZ, camX, camY, camZ, true, false, false)
	if hit then
		camX, camY, camZ = scale(0.9, x, y, camLookZ, hitX, hitY, hitZ)
	end
	_setCameraMatrix(camX, camY, camZ, x, y, camLookZ)
end

local function onMouseMove(relX, relY, absX, absY)
	if isMTAWindowActive() then
		return
	end
	absX = absX - screenWidth/2
	absY = absY - screenHeight/2
	phi = (phi - 0.005*absX) % (2*pi)
	theta = theta + 0.005*absY
	if theta > 0.4*pi then
		theta = 0.4*pi
	elseif theta < -0.4*pi then
		theta = -0.4*pi
	end
end

local function registerHandlers()
	addEventHandler('onClientCursorMove', root, onMouseMove)
	addEventHandler('onClientRender', root, onRender)
end

local function unregisterHandlers()
	removeEventHandler('onClientCursorMove', root, onMouseMove)
	removeEventHandler('onClientRender', root, onRender)
end

local _setCameraTarget = setCameraTarget
function setCameraTarget(_target)
	unregisterHandlers()
	if getElementType(_target) == 'player' then
		_setCameraTarget(_target)
	elseif getElementType(_target) == 'vehicle' and getVehicleController(_target) then
		_setCameraTarget(getVehicleController(_target))
	elseif isElement(_target) then
		phi = 0
		theta = 0
		target = _target
		distance = getElementRadius(_target) or 3.5
		registerHandlers()
	end
end


