
g_HighUsageResources = {}

function saveHighCPUResources()
    if g_Settings["SaveHighCPUResources"] ~= "true" then
        return
    end

    local columns, rows = getPerformanceStats("Lua timing")
    local saveHighCPUResourcesAmount = tonumber(g_Settings["SaveHighCPUResourcesAmount"]) or 10

    for index, row in pairs(rows) do
        local usageText = row[2]:gsub("[^0-9%.]", "")
        local usage = math.floor(tonumber(usageText) or 0)

        if (usage > saveHighCPUResourcesAmount) then
            -- Notify IPB users if necessary
            if usage > (tonumber(g_Settings["NotifyIPBUsersOfHighUsage"]) or 50) then
                if g_Listener then
                    for player in pairs(g_Listener) do
                        if isElement(player) then
                            player:outputChat(("[IPB WARNING] Resource %q is using %s CPU"):format(row[1], row[2]), 255, 100, 100, true)
                        else
                            g_Listener[player] = nil
                        end
                    end
                end
            end

            -- Record this high usage to table
            table.insert(g_HighUsageResources, 1, {row[1], row[2], getDateTimeString()})

            -- Make sure it won't get too big
            table.remove(g_HighUsageResources, 1000)
        end
    end
end
Timer(saveHighCPUResources, 5000, 0)

function getDateTimeString()
    local time = getRealTime()
    local weekday = ({"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"})[time.weekday + 1]
    -- Weekday, DD.MM.YYYY, hh:mm:ss
    return ("%s, %02d.%02d.%d, %02d:%02d:%02d"):format(weekday, time.monthday, time.month + 1, time.year + 1900, time.hour, time.minute, time.second)
end
