--
-- common.lua
--   Common setting for server and client
--

--_DEBUG_LOG = {'UNDEF','MISC','OPTIMIZATION','TOPTIMES','STATE','JOINER'}   -- More logging
--_DEBUG_TIMING = true        -- Introduce delays
--_DEBUG_CHECKS = true        -- Extra checks
_TESTING = true             -- Any user can issue test commands



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

-- setTimer
function Timer:setTimer( ... )
    self:killTimer()
    self.timer = setTimer( ... )
end

-- killTimer
function Timer:killTimer()
    if self.timer then
        killTimer( self.timer )
        self.timer = nil
    end
end

---------------------------------------------------------------------------
