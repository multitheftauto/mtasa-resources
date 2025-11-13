--
--
-- performancebrowser.lua
--
--

-- Lua time recordings config
g_LuaTimingRecordings = {
	Enabled = true,
	Frequency = 2000, -- in milliseconds
	HistoryLength = 300, -- number of records to keep
	HighCPUResourcesAmount = 10, -- percentage threshold
}

-- Global variable to store high usage resources similar to IPB
g_HighUsageResources = {}

-- Browser update
function setQuery ( counter, user, target, category, options, filter, showClients )
	local viewer = getViewer(user)
	return viewer:setQuery ( counter, target, category, options, filter, showClients )
end

-- Date/time formatting function
local function getDateTimeString()
    local time = getRealTime()
    local weekday = ({"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"})[time.weekday + 1]
    -- Weekday, DD.MM.YYYY, hh:mm:ss
    return ("%s, %02d.%02d.%d, %02d:%02d:%02d"):format(weekday, time.monthday, time.month + 1, time.year + 1900, time.hour, time.minute, time.second)
end

-- Save high CPU resources function (based on IPB alarm.lua)
function saveHighCPUResources()
    local columns, rows = getPerformanceStats("Lua timing")
	
    if not rows then
        return
    end

    for index, row in pairs(rows) do
        local usageText = row[2]:gsub("[^0-9%.]", "")
        local usage = math.floor(tonumber(usageText) or 0)

        if (usage > g_LuaTimingRecordings.HighCPUResourcesAmount) then
            -- Record this high usage to table
            table.insert(g_HighUsageResources, 1, {row[1], row[2], getDateTimeString()})

            -- Make sure it won't get too big
            if #g_HighUsageResources > g_LuaTimingRecordings.HistoryLength then
                table.remove(g_HighUsageResources, g_LuaTimingRecordings.HistoryLength)
            end
        end
    end
end

-- Start monitoring timer
if (g_LuaTimingRecordings.Enabled) then
	setTimer(saveHighCPUResources, g_LuaTimingRecordings.Frequency, 0)
end