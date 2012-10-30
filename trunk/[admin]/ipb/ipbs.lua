local updateFrequency = 2000
local listeners = {}

function accessCheck(object)
	if (hasObjectPermissionTo(object, "general.http", false)) then
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
	local stat1, stat2 = getPerformanceStats(listeners[player][1], listeners[player][2], listeners[player][3])
	triggerClientEvent(player, "ipb.recStats", player, 1, stat1, stat2)
end
addCommandHandler("perfbrowse", startListening)
addCommandHandler("ipb", startListening)

function changeCategory(newCategory)
	if (not accessCheck(client)) then return end
	listeners[client][1] = newCategory
	local stat1, stat2 = getPerformanceStats(newCategory)
	triggerClientEvent(client, "ipb.recStats", client, 2, stat1, stat2)
end
addEvent("ipb.changeCat", true)
addEventHandler("ipb.changeCat", root, changeCategory)

function changeOptionsAndFilter(options, filter)
	if (not accessCheck(client)) then return end
	listeners[client][2] = options
	listeners[client][3] = filter
	local stat1, stat2 = getPerformanceStats(listeners[client][1], listeners[client][2], listeners[client][3])
	triggerClientEvent(client, "ipb.recStats", client, 2, stat1, stat2)
end
addEvent("ipb.changeOptionsAndFilter", true)
addEventHandler("ipb.changeOptionsAndFilter", root, changeOptionsAndFilter)

function updateListeners()
	for player, data in pairs(listeners) do
		if (isElement(player)) then
			local stat1, stat2 = getPerformanceStats(data[1], data[2], data[3])
			triggerClientEvent(player, "ipb.recStats", player, 3, stat1, stat2)
		else
			listeners[player] = nil
		end
	end
end
setTimer(updateListeners, updateFrequency, 0)