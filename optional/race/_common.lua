--
-- common.lua
--   Common setting for server and client
--

--_DEBUG_LOG = {'UNDEF','MISC','OPTIMIZATION','TOPTIMES','STATE','JOINER','TIMER'}   -- More logging
--_DEBUG_TIMING = true        -- Introduce delays
--_DEBUG_CHECKS = true        -- Extra checks
_TESTING = false             -- Any user can issue test commands


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
-- Timer - Wraps a standard timer
---------------------------------------------------------------------------
Timer = {}
Timer.__index = Timer
Timer.instances = {}

-- Create a Timer instance
function Timer:create()
    local id = #Timer.instances + 1
    Timer.instances[id] = setmetatable(
        {
            id = id,
            timer = nil,      -- Actual timer
        },
        self
    )
    return Timer.instances[id]
end

-- Destroy a Timer instance
function Timer:destroy()
    self:killTimer()
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
    self.args = { ... }
    self.timer = setTimer( function() self:handleFunctionCall() end, timeInterval, timesToExecute )
end

function Timer:handleFunctionCall()
    self.fn(unpack(self.args))
    -- Delete reference to timer if there are no more repeats
    if self.count > 0 then
        self.count = self.count - 1
        if self.count == 0 then
            self.timer = nil
        end
    end
end

---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Others
---------------------------------------------------------------------------
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
---------------------------------------------------------------------------
