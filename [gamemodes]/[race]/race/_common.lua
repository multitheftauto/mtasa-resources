--
-- common.lua
--   Common setting for server and client
--

--_DEBUG_LOG = {'UNDEF','MISC','OPTIMIZATION','TOPTIMES','STATE','JOINER','TIMER','RANDMAP','CHECKPOINT','CP','SPECTATE'}   -- More logging
--_DEBUG_TIMING = true        -- Introduce delays
--_DEBUG_CHECKS = true        -- Extra checks
_TESTING = false             -- Any user can issue test commands

---------------------------------------------------------------------------
-- Script location
---------------------------------------------------------------------------
function isServer()				return triggerClientEvent ~= nil	end
function isClient()				return triggerServerEvent ~= nil	end
function getScriptLocation()	return isServer() and "Server" or "Client"	end

---------------------------------------------------------------------------
-- Math extentions
---------------------------------------------------------------------------
function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end

function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.wrap(low,value,high)
    while value > high do
        value = value - (high-low)
    end
    while value < low do
        value = value + (high-low)
    end
    return value
end

function math.wrapdifference(low,value,other,high)
    return math.wrap(low,value-other,high)+other
end

-- curve is { {x1, y1}, {x2, y2}, {x3, y3} ... }
function math.evalCurve( curve, input )
	-- First value
	if input<curve[1][1] then
		return curve[1][2]
	end
	-- Interp value
	for idx=2,#curve do
		if input<curve[idx][1] then
			local x1 = curve[idx-1][1]
			local y1 = curve[idx-1][2]
			local x2 = curve[idx][1]
			local y2 = curve[idx][2]
			-- Find pos between input points
			local alpha = (input - x1)/(x2 - x1);
			-- Map to output points
			return math.lerp(y1,y2,alpha)
		end
	end
	-- Last value
	return curve[#curve][2]
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Misc functions
---------------------------------------------------------------------------
function getSecondCount()
 	return getTickCount() * 0.001
end

-- remove color coding from string
function removeColorCoding ( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

-- getPlayerName with color coding removed
_getPlayerName = getPlayerName
function getPlayerName ( player )
	return removeColorCoding ( _getPlayerName ( player ) )
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Camera functions
---------------------------------------------------------------------------
function getCameraRot()
	local px, py, pz, lx, ly, lz = getCameraMatrix()
	local rotz = math.atan2 ( ( lx - px ), ( ly - py ) )
 	local rotx = math.atan2 ( lz - pz, getDistanceBetweenPoints2D ( lx, ly, px, py ) )
 	return math.deg(rotx), 180, -math.deg(rotz)
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- TimerManager
---------------------------------------------------------------------------
TimerManager = {}
TimerManager.list = {}

-- Create a timer with tags
function TimerManager.createTimerFor( ... )
	-- Make a dictionary of tags for easy lookup
	local tagMap = {}
	for _,arg in ipairs({ ... }) do
		tagMap[tostring(arg)] = 1
	end
	local timer = Timer:create(true)
	table.insert( TimerManager.list, { timer=timer, tagMap=tagMap } )
	outputDebug( "TIMERS", getScriptLocation() .. " create - number of timers:" .. tostring(#TimerManager.list) )
	return timer
end

-- Timer must have all the tags specified
function TimerManager.hasTimerFor( ... )
	local timers = TimerManager.getTimersByTags(...)
	return #timers > 0
end

-- Timers must have all the tags specified
function TimerManager.destroyTimersFor( ... )
	local timers = TimerManager.getTimersByTags(...)
	for _,timer in ipairs(timers) do
		timer:destroy()
	end
end

-- Remove specific timer from the list
function TimerManager.removeTimer( timer )
	for _,item in ipairs(TimerManager.list) do
		if item.timer == timer then
			table.removevalue(TimerManager.list, item)
			outputDebug( "TIMERS", getScriptLocation() .. " remove - number of timers:" .. tostring(#TimerManager.list) )
		end
	end
end

-- Get all timers which contains all matching tags
function TimerManager.getTimersByTags( ... )
	-- Get list of tags to find
	local findtags = {}
	for _,arg in ipairs({ ... }) do
		table.insert( findtags, tostring(arg) )
	end
	-- Check each timer
	local timers = {}
	for i,item in ipairs(TimerManager.list) do
		local bFound = true
		for _,tag in ipairs(findtags) do
			if item.tagMap[tag] ~= 1 then
				bFound = false
				break
			end
		end
		if bFound then
			table.insert( timers, item.timer )
		end
	end
	return timers
end


if isServer() then
	addEventHandler ( "onElementDestroy", root,
		function()
			TimerManager.destroyTimersFor( source )
		end
	)
end

if isClient() then
	addEventHandler ( "onClientElementDestroy", root,
		function()
			TimerManager.destroyTimersFor( source )
		end
	)
end


---------------------------------------------------------------------------
-- Timer - Wraps a standard timer
---------------------------------------------------------------------------
Timer = {}
Timer.__index = Timer
Timer.instances = {}

-- Create a Timer instance
function Timer:create(autodestroy)
    local id = #Timer.instances + 1
    Timer.instances[id] = setmetatable(
        {
            id = id,
            timer = nil,      -- Actual timer
            autodestroy = autodestroy,
        },
        self
    )
    return Timer.instances[id]
end

-- Destroy a Timer instance
function Timer:destroy()
    self:killTimer()
    TimerManager.removeTimer(self)
    Timer.instances[self.id] = nil
    self.id = 0
end

-- Check if timer is valid
function Timer:isActive()
    return self.timer ~= nil
end

-- killTimer
function Timer:killTimer()
    if self.timer then
        killTimer( self.timer )
        self.timer = nil
    end
end

-- setTimer
function Timer:setTimer( theFunction, timeInterval, timesToExecute, ... )
    self:killTimer()
    self.fn = theFunction
    self.count = timesToExecute
    self.dodestroy = false
    self.args = { ... }
	if timeInterval < 50 then
		timeInterval = 50
	end
    self.timer = setTimer( function() self:handleFunctionCall() end, timeInterval, timesToExecute )
end

function Timer:handleFunctionCall()
    -- Delete reference to timer if there are no more repeats
    if self.count > 0 then
        self.count = self.count - 1
        if self.count == 0 then
            self.timer = nil
            self.dodestroy = self.autodestroy
        end
    end
    self.fn(unpack(self.args))
    if self.dodestroy then
        self:destroy()
    end
end

---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Version checks
---------------------------------------------------------------------------
function isVersion10()
	return getVersion().number == 256
end
function isVersion101Compatible()
	return getVersion().number >= 257
end
function isVersion102Compatible()
	return getVersion().number >= 258
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Others
---------------------------------------------------------------------------
-- Element description for debugging
function getElementDesc(element)
	local bHasPlayerName = false
	local status = "[" .. tostring( getElementType(element) ) .. ":"

	if getElementType(element)=="player" then
		status = status .. getPlayerName(element)
		bHasPlayerName = true
	end
	if getElementType(element)=="vehicle" then
		local player = getVehicleController(element)
		if player then
			status = status .. "controller-" .. getPlayerName(player)
			bHasPlayerName = true
		end
	end
	if not bHasPlayerName then
		status = status .. string.gsub(tostring(element),".* 0*","0")
	end
	return status .. "]"
end

-- Modulo with more useful sign handling
function rem( a, b )
	local result = a - b * math.floor( a / b )
	if result >= b then
		result = result - b
	end
	return result
end

-- Rotations from an element matrix
function matrixToRotations( matrix )

	local Right = Vector3D:new( matrix[1][1], matrix[1][2], matrix[1][3] )
	local Fwd	= Vector3D:new( matrix[2][1], matrix[2][2], matrix[2][3] )
	local Up	= Vector3D:new( matrix[3][1], matrix[3][2], matrix[3][3] )

	local rz = math.atan2( Fwd.y, Fwd.x )
	local rx = math.asin( Fwd.z )
	local ry = -math.atan2( Right.z, Up.z)

	-- Convert to degrees and ensure 0-360
	rx = rem( rx * (360/6.28) - 90, 360 )
	ry = rem( ry * (360/6.28), 360 )
	rz = rem( rz * (360/6.28), 360 )

	return rx, ry, rz
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Vector3D
---------------------------------------------------------------------------
Vector3D = {
	new = function(self, _x, _y, _z)
		local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
		return setmetatable(newVector, { __index = Vector3D })
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Length()
		self.x = self.x / mod
		self.y = self.y / mod
		self.z = self.z / mod
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Length = function(self)
		return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	end,

	AddV = function(self, V)
		return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	CrossV = function(self, V)
		return Vector3D:new(self.y * V.z - self.z * V.y,
							self.z * V.x - self.x * V.z,
							self.x * V.y - self.y * V.z)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,
}
---------------------------------------------------------------------------
