g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_Me = getLocalPlayer()

addEvent('onClientCall_race', true)
addEventHandler('onClientCall_race', resourceRoot,
	function(fnName, ...)
		local fn = _G
		local path = fnName:split('.')
		for i,pathpart in ipairs(path) do
			fn = fn[pathpart]
		end
        if not fn then
            outputDebugString( 'onClientCall_race fn is nil for ' .. tostring(fnName) )
        else
    		fn(...)
        end
	end
)

function createServerCallInterface()
	return setmetatable(
		{},
		{
			__index = function(t, k)
				t[k] = function(...) triggerServerEvent('onServerCall_race', resourceRoot, k, ...) end
				return t[k]
			end
		}
	)
end

server = createServerCallInterface()

----------------------------
-- GUI

function showHUD(show)
	for i,name in ipairs({ 'ammo', 'area_name', 'armour', 'breath', 'clock', 'health', 'money', 'vehicle_name', 'weapon' }) do
		setPlayerHudComponentVisible(name, show)
	end
end

function showGUIComponents(...)
	for i,name in ipairs({...}) do
		if g_dxGUI[name] then
			g_dxGUI[name]:visible(true)
		elseif type(g_GUI[name]) == 'table' then
			g_GUI[name]:show()
		else
			guiSetVisible(g_GUI[name], true)
		end
	end
end

function hideGUIComponents(...)
	for i,name in ipairs({...}) do
		if g_dxGUI[name] then
			g_dxGUI[name]:visible(false)
		elseif type(g_GUI[name]) == 'table' then
			g_GUI[name]:hide()
		else
			guiSetVisible(g_GUI[name], false)
		end
	end
end

function setGUIComponentsVisible(settings)
	for name,visible in pairs(settings) do
		if type(g_GUI[name]) == 'table' then
			g_GUI[name][visible and 'show' or 'hide'](g_GUI[name])
		else
			guiSetVisible(g_GUI[name], visible)
		end
	end
end

function createShadowedLabel(x, y, width, height, text, align)
	local shadow = guiCreateLabel(x + 1, y + 1, width, height, text, false)
	guiLabelSetColor(shadow, 0, 0, 0)
	local label = guiCreateLabel(x, y, width, height, text, false)
	guiLabelSetColor(label, 255, 255, 255)
	if align then
		guiLabelSetHorizontalAlign(shadow, align)
		guiLabelSetHorizontalAlign(label, align)
	end
	return label, shadow
end

function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end

function getTickTimeStr()
    return msToTimeStr(getTickCount())
end

function resAdjust(num)
	if not g_ScreenWidth then
		g_ScreenWidth, g_ScreenHeight = guiGetScreenSize()
	end
	if g_ScreenWidth < 1280 then
		return math.floor(num*g_ScreenWidth/1280)
	else
		return num
	end
end

----------------------------
-- Vehicles

function setCameraBehindVehicle(vehicle)
	if vehicle then
		local x, y, z = getElementPosition(vehicle)
		local rx, ry, rz = getElementRotation(vehicle)
		setCameraMatrix(x - 4*math.cos(math.rad(rz + 90)), y - 4*math.sin(math.rad(rz + 90)), z + 1, x, y, z + 1)
	end
	setTimer(setCameraTarget, 150, 1, getLocalPlayer())
end

function alignVehicleToGround(vehicle)
	if not g_AlignToGroundTimer then
		g_AlignToGroundTimer = setTimer(alignVehicleToGround, 200, 0, vehicle)
		g_AlignToGroundTriesLeft = 50
	else
		local x, y, z = getElementPosition(vehicle)
		local hit, hitX, hitY, groundZ = processLineOfSight(x, y, z + 5, x, y, z - 20, true, false)
		g_AlignToGroundTriesLeft = g_AlignToGroundTriesLeft - 1
		if not hit and g_AlignToGroundTriesLeft > 0 then
			return
		end
		killTimer(g_AlignToGroundTimer)
		g_AlignToGroundTimer = nil
		g_AlignToGroundTriesLeft = nil
		if hit then
			local waterZ = getWaterLevel(x, y, z + 5)
			if not waterZ or groundZ > waterZ then
				server.setElementPosition(vehicle, x, y, groundZ + getElementDistanceFromCentreOfMassToBaseOfModel(vehicle))
			end
		end
	end
end

function checkVehicleIsHelicopter()
	local vehID = getElementModel(g_Vehicle)
	if vehID == 417 or vehID == 425 or vehID == 447 or vehID == 465 or vehID == 469 or vehID == 487 or vehID == 488 or vehID == 497 or vehID == 501 or vehID == 548 or vehID == 563 then
		setHelicopterRotorSpeed (g_Vehicle, 0.2)
	end
end

function checkModelIsAirplane(g_VehicleModel)
	if g_VehicleModel == 592 or g_VehicleModel == 577 or g_VehicleModel == 511 or g_VehicleModel == 512 or g_VehicleModel == 593 or g_VehicleModel == 520 or g_VehicleModel == 553 or g_VehicleModel == 476 or g_VehicleModel == 519 or g_VehicleModel == 460 or g_VehicleModel == 513 or g_VehicleModel == 539 then
		return true
	end
end

-----------------------------
-- Table extensions

function table.find(tableToSearch, index, value)
	if not value then
		value = index
		index = false
	elseif value == '[nil]' then
		value = nil
	end
	for k,v in pairs(tableToSearch) do
		if index then
			if v[index] == value then
				return k
			end
		elseif v == value then
			return k
		end
	end
	return false
end

function table.removevalue(t, val)
	for i,v in ipairs(t) do
		if v == val then
			table.remove(t, i)
			return i
		end
	end
	return false
end

function table.each(t, index, callback, ...)
	local args = { ... }
	if type(index) == 'function' then
		table.insert(args, 1, callback)
		callback = index
		index = false
	end
	for k,v in pairs(t) do
		callback(index and v[index] or v, unpack(args))
	end
	return t
end

function table.deepcopy(t)
	local known = {}
	local function _deepcopy(t)
		local result = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				if not known[v] then
					known[v] = _deepcopy(v)
				end
				result[k] = known[v]
			else
				result[k] = v
			end
		end
		return result
	end
	return _deepcopy(t)
end


function table.create(keys, vals)
	local result = {}
	if type(vals) == 'table' then
		for i,k in ipairs(keys) do
			result[k] = vals[i]
		end
	else
		for i,k in ipairs(keys) do
			result[k] = vals
		end
	end
	return result
end

function table.insertUnique(t,val)
    if not table.find(t, val) then
        table.insert(t,val)
    end
end

function table.popLast(t,val)
    if #t==0 then
        return false
    end
    local last = t[#t]
    table.remove(t)
    return last
end


-----------------------------
-- String extensions

function string:split(sep)
	if #self == 0 then
		return {}
	end
	sep = sep or ' '
	local result = {}
	local from = 1
	local to
	repeat
		to = self:find(sep, from, true) or (#self + 1)
		result[#result+1] = self:sub(from, to - 1)
		from = to + 1
	until from == #self + 2
	return result
end


function clamp( lo, value, hi )
    return math.max( lo, math.min( value, hi ) )
end


function outputDebug( chan, msg )
    if _DEBUG_LOG then
        if not msg then
            msg = chan
            chan = 'UNDEF'
        end
        if table.find(_DEBUG_LOG,chan) then
            outputConsole( getTickTimeStr() .. ' cDEBUG: ' .. msg )
            outputDebugString( getTickTimeStr() .. ' cDEBUG: ' .. msg )
        end
    end
    if g_bPipeDebug then
        outputConsole( getTickTimeStr() .. ' cDEBUG: ' .. (msg or chan) )
    end
end

function outputWarning( msg )
    outputConsole( getTickTimeStr() .. ' cWARNING: ' .. msg )
    outputDebugString( getTickTimeStr() .. ' cWARNING: ' .. msg )
end


-------------------------------------------------------
-- Trigger an event when the screen fades in/out
-------------------------------------------------------
local fadeInFinTimer = Timer:create()

_fadeCamera = fadeCamera
function fadeCamera(fadeIn,timeToFade,...)
    _fadeCamera (fadeIn,timeToFade,...)
    local ticksToFade = (not timeToFade or timeToFade < 1) and 0 or timeToFade * 1000
    if not fadeIn then
        fadeInFinTimer:killTimer()
		triggerEvent( 'onClientScreenFadedOut', g_Root )
    else
        fadeInFinTimer:setTimer( onfadeInFin, math.max(50,ticksToFade/8), 1 )
    end
end

function onfadeInFin()
	triggerEvent( 'onClientScreenFadedIn', g_Root )
end

-------------------------------------------------------

-- Calculate the gap between element bounding spheres
function getGapBetweenElements( elemA, elemB )
	if not isElement( elemA ) or not isElement( elemB ) then
		return false
	end
	local x,y,z = getElementPosition( elemA )
	local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( elemB ) )
	distance = distance - ( getElementRadius( elemA ) or 0 )
	distance = distance - ( getElementRadius( elemB ) or 0 )
	return math.max( 0, distance )
end
