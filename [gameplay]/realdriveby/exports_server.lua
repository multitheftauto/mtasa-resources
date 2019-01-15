function isDrivebyEnabled(player)
	assert(isElement(player) and getElementType(player) == "player", "Bad argument @ 'isDrivebyEnabled' [Expected player at argument 1, got " .. type(player) .. "]")

	if syncedPlayerStates[player] ~= nil then
		return syncedPlayerStates[player]
	end

	return settings.enabled
end

function setDrivebyEnabled(player, state)
	assert(isElement(player) and getElementType(player) == "player", "Bad argument @ 'setDrivebyEnabled' [Expected player at argument 1, got " .. type(player) .. "]")

	local stateType = type(state)
	assert(stateType == "boolean", "Bad argument @ 'setDrivebyEnabled' [Expected boolean at argument 2, got " .. stateType .. "]")

	syncedPlayerStates[player] = state

	triggerClientEvent(player, "driveby_setDrivebyEnabled", player, state, false)
end
