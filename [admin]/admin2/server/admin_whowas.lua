local info = getElementData(root, "WhoWas", info) or {}
removeElementData(root, "WhoWas")

addEventHandler("onPlayerJoin", root, function()
	local name = getPlayerName(source)
	local serial = getPlayerSerial(source)
	for i, data in pairs(info) do
		if (data[1] == name and data[2] == serial) then
			return true
		end
	end
	info[#info + 1] = {name, serial, accName, getPlayerIP(source)}
end)

addEventHandler("onPlayerLogin", root, function(old, new)
	local name = getPlayerName(source)
	local serial = getPlayerSerial(source)
	local accName = getAccountName(new)
	for i, data in pairs(info) do
		if (data[1] == name and data[2] == serial and data[3] == accName) then
			return true
		end
	end
	info[#info + 1] = {name, serial, accName, getPlayerIP(source)}
end)

addEventHandler("onPlayerChangeNick", root, function(old, name)
	local serial = getPlayerSerial(source)
	for i, data in pairs(info) do
		if data[1] == name and data[2] == serial then
			return true
		end
	end
	local acc = getPlayerAccount(source)
	if isGuestAccount(acc) then
		acc = nil
	else
		acc = getAccountName(acc)
	end
	info[#info + 1] = {name, serial, acc, getPlayerIP(source)}
end)

function cmdWhoWas(plr, cmd, name)
	if not hasObjectPermissionTo(plr, "command.whowas", false) and not hasObjectPermissionTo(plr, "command.listbans", false) then
		outputChatBox("You don't have access to 'command.whowas' or 'command.listbans'", plr, 255, 0, 0)
		return false
	end
	local found = 0
	outputChatBox("Players who had "..name.." in their name/serial/account/IP:", plr, 0, 255, 0)
	for i, data in pairs(info) do
		if string.find(data[1], name, 1, true) or string.find(data[2], name, 1, true) or string.find(data[3], name, 1, true) or string.find(data[4], name, 1, true) then
			outputChatBox(data[1].." #F7FF00"..data[2].." #FDC11C"..(data[3] or "guest").." #FD581C"..data[4], plr, 0, 255, 0, true)
			found = found + 1
			if (found > 100) then
				outputChatBox("Reached limit of 100 returns, refine your search.", plr, 0, 255, 0, true)
				return true
			end
		end
	end
end
addCommandHandler("whowas", cmdWhoWas)

-- Add players when script starts
for i, plr in pairs(getElementsByType("player")) do
	local alreadyIn = false
	for i2, data in pairs(info) do
		if data[1] == getPlayerName(plr) and data[2] == getPlayerSerial(plr) then
			alreadyIn = true
			break
		end
	end
	if not alreadyIn then
		local acc = getPlayerAccount(plr)
		if isGuestAccount(acc) then
			acc = nil
		else
			acc = getAccountName(acc)
		end
		info[#info + 1] = {getPlayerName(plr), getPlayerSerial(plr), acc, getPlayerIP(plr)}
	end
end

addEventHandler("onResourceStop", resourceRoot, function()
	setElementData(root, "WhoWas", info, false) -- This preserves whowas data from resource restarts.
end)