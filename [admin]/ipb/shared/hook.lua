
local _getPerformanceStats = getPerformanceStats
function getPerformanceStats(category, options, filter)
    local columns, rows

    if category == "Lua time recordings" then
        columns = {[1] = "Resource", [2] = "CPU %", [3] = "Weekday, Date, Time"}
        rows = g_HighUsageResources
    else
        columns, rows = _getPerformanceStats(category, options, filter)
    end

    return columns, rows
end
