local updateFrequency = 2000
local listeners = {}
local highUsageResources = {}

function getPerformanceStatsIPB(category, options, filter)
	local stat1, stat2
	if (category == "Lua time recordings") then
		stat1 = {[1] = "Resource", [2] = "CPU %", [3] = "Time"}
		stat2 = highUsageResources
	else
		stat1, stat2 = getPerformanceStats(category, options, filter)
	end
	return stat1, stat2
end

function accessCheck(object)
	if (hasObjectPermissionTo(object, get("AccessRightName"), false)) then
		return true
	else
		if (getElementType(object) == "player") then
			outputChatBox("Error: access denied", object, 255, 0, 0)
		end
		return false
	end
end

function startListening(player)
	if (not accessCheck(player)) then return end
	if (not listeners[player]) then
		listeners[player] = {"Server info", "", ""}
	end
	local stat1, stat2 = getPerformanceStatsIPB(listeners[player][1], listeners[player][2], listeners[player][3])
	triggerClientEvent(player, "ipb.recStats", player, 1, stat1, stat2)
end
addCommandHandler("perfbrowse", startListening)
addCommandHandler("ipb", startListening)

function changeCategory(newCategory)
	if (not accessCheck(client)) then return end
	listeners[client][1] = newCategory
	local stat1, stat2 = getPerformanceStatsIPB(listeners[client][1], listeners[client][2], listeners[client][3])
	triggerClientEvent(client, "ipb.recStats", client, 2, stat1, stat2)
end
addEvent("ipb.changeCat", true)
addEventHandler("ipb.changeCat", root, changeCategory)

function changeOptionsAndFilter(options, filter)
	if (not accessCheck(client)) then return end
	listeners[client][2] = options
	listeners[client][3] = filter
	local stat1, stat2 = getPerformanceStatsIPB(listeners[client][1], listeners[client][2], listeners[client][3])
	triggerClientEvent(client, "ipb.recStats", client, 2, stat1, stat2)
end
addEvent("ipb.changeOptionsAndFilter", true)
addEventHandler("ipb.changeOptionsAndFilter", root, changeOptionsAndFilter)

function updateListeners()
	for player, data in pairs(listeners) do
		if (isElement(player)) then
			local stat1, stat2 = getPerformanceStatsIPB(data[1], data[2], data[3])
			triggerClientEvent(player, "ipb.recStats", player, 3, stat1, stat2)
		else
			listeners[player] = nil
		end
	end
end
setTimer(updateListeners, updateFrequency, 0)

function saveHighCPUResources()
	if (get("SaveHighCPUResources") ~= "true") then return end
	local stat1, stat2 = getPerformanceStatsIPB("Lua timing")
	-- Now find any that use too much CPU
	local saveHighCPUResourcesAmount = tonumber(get("SaveHighCPUResourcesAmount")) or 10
	for i, stat in ipairs(stat2) do
		local usage = string.gsub(stat[2], "[^0-9.]", "")
		local usage = math.floor(tonumber(usage) or 0)
		if (usage > saveHighCPUResourcesAmount) then
			-- Notify IPB users if necessary.
			if (usage > tonumber(get("NotifyIPBUsersOfHighUsage"))) then
				for player, data in pairs(listeners) do
					if (isElement(player)) then
						outputChatBox("IPB Warning: "..stat[1].." is using "..usage.."% CPU", player, 255, 0, 0)
					else
						listeners[player] = nil
					end
				end
			end
			-- Record this high usage to table
			table.insert(highUsageResources, 1, {stat[1], usage, getRealTimeForIPB()})
			-- Make sure it won't get too big
			table.remove(highUsageResources, 1000)
		end
	end
end
setTimer(saveHighCPUResources, 5000, 0)

function getRealTimeForIPB(time)
	local time = getRealTime(time)
	local str = ""
	if (time.hour < 10) then
		str = "0"..time.hour
	else
		str = time.hour
	end
	if (time.minute < 10) then
		str = str..":0"..time.minute
	else
		str = str..":"..time.minute
	end
	if (time.second < 10) then
		str = str..":0"..time.second
	else
		str = str..":"..time.second
	end
	return str
end