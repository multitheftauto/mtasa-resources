--
-- common.lua
--   Common setting for server and client
--

--_DEBUG_LOG = {'UNDEF','MISC','OPTIMIZATION','TOPTIMES','STATE','JOINER','TIMER'}   -- More logging
--_DEBUG_TIMING = true        -- Introduce delays
--_DEBUG_CHECKS = true        -- Extra checks
_TESTING = true             -- Any user can issue test commands
VERSION = 'r144 23Apr09'


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
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- Misc functions
---------------------------------------------------------------------------
function getSecondCount()
 	return getTickCount() * 0.001
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
