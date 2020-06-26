carFade = {
	isEnabled = false,
	boundKey = false,
	hasReceivedSettingsOnce = false
}

function carFade.render()
	local targetVehicle = getCameraTarget()
	if not targetVehicle or getElementType(targetVehicle) ~= "vehicle" then
		return
	end

	local targetPlayer = getVehicleOccupant(targetVehicle, 0)
	if not targetPlayer or getElementType(targetPlayer) ~= "player" then
		return
	end

	local targetMaxAlpha = getPlayerMaxAlpha(targetPlayer)
	setElementAlpha(targetVehicle, targetMaxAlpha)
	setElementAlpha(targetPlayer, targetMaxAlpha)

	local players = getElementsByType("player", root, true)
	local x, y, z = getElementPosition(targetVehicle)

	for i = 1, #players do
		local player = players[i]
		local playerVehicle = getPedOccupiedVehicle(player)
		if playerVehicle and player ~= targetPlayer then
			local maxAlpha = getPlayerMaxAlpha(player)
			local collidable = isElementCollidableWith(targetVehicle, playerVehicle)
			local distance = not collidable and getDistanceBetweenPoints3D(x, y, z, getElementPosition(playerVehicle)) or nil
			local distanceAlpha = not collidable and mathClamp((distance - getSetting("mindistance")) / getSetting("maxdistance") * 255, getSetting("minalpha"), maxAlpha) or maxAlpha

			setElementAlpha(player, distanceAlpha)
			setElementAlpha(playerVehicle, distanceAlpha)
		end
	end
end

function carFade.resetAlphas()
	local players = getElementsByType("player", root, true)
	for i = 1, #players do
		local player = players[i]
		local playerVehicle = getPedOccupiedVehicle(player)
		local maxAlpha = getPlayerMaxAlpha(player)

		setElementAlpha(player, maxAlpha)
		if playerVehicle then
			setElementAlpha(playerVehicle, maxAlpha)
		end
	end
end
addEventHandler("onClientResourceStop", resourceRoot, carFade.resetAlphas)

function carFade.toggle(forceState)
	local doEnable
	if type(forceState) == "boolean" then
		doEnable = forceState
	else
		doEnable = not carFade.isEnabled
	end

	if doEnable then
		if not carFade.isEnabled then
			if not carFade.isEnabled then
				addEventHandler("onClientPreRender", root, carFade.render)
				carFade.isEnabled = true
			end
		end
	else
		removeEventHandler("onClientPreRender", root, carFade.render)
		carFade.isEnabled = false
		carFade.resetAlphas()
	end

	outputChatBox("Notice: Carfade is " .. (carFade.isEnabled and "enabled" or "disabled") .. "." )
end

function carFade.toggleFromPlayer()
	if getSetting("canbetoggled") then
		carFade.toggle()
	end
end
addCommandHandler("carfade", carFade.toggleFromPlayer)


function carFade.handleSettings()
	if not carFade.hasReceivedSettingsOnce and getSetting("enabledbydefault") then
		carFade.toggle(true)
	end
	carFade.hasReceivedSettingsOnce = true

	if not getSetting("canbetoggled") then
		if carFade.boundKey then
			unbindKey(carFade.boundKey, "down", carFade.toggleFromPlayer)
			carFade.boundKey = false
		end
		carFade.toggle(getSetting("enabledbydefault"))
	elseif carFade.boundKey ~= getSetting("keybind") then
		if carFade.boundKey then
			unbindKey(carFade.boundKey, "down", carFade.toggleFromPlayer)
			carFade.boundKey = false
		end

		bindKey(getSetting("keybind"), "down", carFade.toggleFromPlayer)
		carFade.boundKey = getSetting("keybind")
		outputChatBox("Notice: Toggle carfade on/off with '" .. carFade.boundKey .. "'.")
	end
end

function carFade.broadcastMessage()
	if getSetting("broadcastatmapstart") then
		outputChatBox("Notice: Carfade is " .. (carFade.isEnabled and "enabled" or "disabled") .. ". " .. ( getSetting("canbetoggled") and "Toggle on/off with '" .. carFade.boundKey .. "'." or "") )
	end
end
addEvent("onClientMapStarting")
addEventHandler("onClientMapStarting", root, carFade.broadcastMessage)
