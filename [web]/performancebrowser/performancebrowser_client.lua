--
--
-- performancebrowser_client.lua
--
--

me = localPlayer
local bSupportsStats = getPerformanceStats ~= nil
g_HighUsageResources = {}

addEventHandler("onClientResourceStart", resourceRoot,
	function (resource)
		local a,b = nil,nil
		if bSupportsStats then
			a,b = getPerformanceStats( "" )
		end
		triggerServerEvent( "onNotifyTargetEnabled", resourceRoot, bSupportsStats, a, b )
    end
)

--[[
addEvent('onClientRequestCategories', true)
addEventHandler('onClientRequestCategories', me,
	function( username )
		local a,b = getPerformanceStats( "" )
		triggerServerEvent( "onNotifyCategories", resourceRoot, username, a, b )
	end
)
--]]

addEvent('onClientRequestStats', true)
addEventHandler('onClientRequestStats', me,
	function( username, queryCategoryName, queryOptionsText, queryFilterText )

		if queryCategoryName == "Lua time recordings" then
			
			local columns, rows = getPerformanceStats( queryCategoryName, queryOptionsText, queryFilterText )
			local a = {"Resource", "CPU Usage", "Recorded Time"}
			local b = g_HighUsageResources

			return triggerServerEvent( "onNotifyStats", resourceRoot, a, b, username, queryCategoryName, queryOptionsText, queryFilterText )
		end
		
		local a,b = getPerformanceStats( queryCategoryName, queryOptionsText, queryFilterText )
		triggerServerEvent( "onNotifyStats", resourceRoot, a, b, username, queryCategoryName, queryOptionsText, queryFilterText )
	end
)

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