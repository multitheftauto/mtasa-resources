local chatTypeNormal = 0
local chatSavedMessages = {}

---@diagnostic disable: undefined-global

local function canPlayerChatWithoutDelay(playerElement)
	local defaultPermission = false

	for _, aclRight in pairs(CHAT_MANAGER_OMIT_CHAT_DELAY_RIGHTS) do
		local hasPlayerPermissionTo = hasObjectPermissionTo(playerElement, aclRight, defaultPermission)

		if (not hasPlayerPermissionTo) then
			return false
		end
	end

	return true
end

local function canPlayerChat(playerElement, playerMessage)
	local canChatWithoutDelay = canPlayerChatWithoutDelay(playerElement)

	if (not canChatWithoutDelay) then
		local chatDelayPassed = getOrSetPlayerDelay(playerElement, "chat_delay", CHAT_MANAGER_CHAT_DELAY)

		if (not chatDelayPassed) then
			outputChatBox("Stop spamming main chat!", playerElement, 255, 255, 255, false)

			return false
		end
	end

	if (CHAT_MANAGER_BLOCK_REPEATED_MESSAGES) then
		local chatLastPlayerMessage = chatSavedMessages[playerElement]
		local chatLastPlayerMessageEqual = (chatLastPlayerMessage == playerMessage)

		chatSavedMessages[playerElement] = playerMessage

		if (chatLastPlayerMessageEqual) then
			outputChatBox("Stop repeating yourself!", playerElement, 255, 255, 255, false)

			return false
		end
	end

	return true
end

local function getPlayerColor(playerElement)
	local playerNameTagColor = (CHAT_MANAGER_NAME_COLOR_MODE == "nametag")

	if (playerNameTagColor) then
		local playerR, playerG, playerB = getPlayerNametagColor(playerElement)

		return playerR, playerG, playerB
	end

	local playerTeamColor = (CHAT_MANAGER_NAME_COLOR_MODE == "team")

	if (playerTeamColor) then
		local playerTeam = getPlayerTeam(playerElement)

		if (playerTeam) then
			local playerR, playerG, playerB = getTeamColor(playerTeam)

			return playerR, playerG, playerB
		end
	end

	local playerR, playerG, playerB = CHAT_MANAGER_PLAYER_DEFAULT_COLOR[1], CHAT_MANAGER_PLAYER_DEFAULT_COLOR[2], CHAT_MANAGER_PLAYER_DEFAULT_COLOR[3]

	return playerR, playerG, playerB
end

local function handlePlayerChat(chatMessage, chatMessageType)
	local chatMessageTypeNormal = (chatMessageType == chatTypeNormal)

	if (not chatMessageTypeNormal) then
		return false
	end

	cancelEvent()

	local canPlayerSendMessage = canPlayerChat(source, chatMessage)

	if (not canPlayerSendMessage) then
		return false
	end

	local messageWithoutHEX = removeStringHEX(chatMessage)
	local messagePlayerName = getPlayerNickname(source)
	local messageText = messagePlayerName..": #ffffff"..messageWithoutHEX
	local messageLog = "CHAT: "..messagePlayerName.." : "..messageWithoutHEX
	local messageReceiver = root
	local messageR, messageG, messageB = getPlayerColor(source)
	local messageColorCoded = true

	outputServerLog(messageLog)
	outputChatBox(messageText, messageReceiver, messageR, messageG, messageB, messageColorCoded)
end
addEventHandler("onPlayerChat", root, handlePlayerChat)

local function clearPlayerChatData()
	chatSavedMessages[source] = nil
end
addEventHandler("onPlayerQuit", root, clearPlayerChatData)