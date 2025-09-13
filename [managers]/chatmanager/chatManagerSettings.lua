local chatManagerSettingsTemplate = {
	["*mainChatDelay"] = {
		"CHAT_MANAGER_CHAT_DELAY",

		function(chatManagerSettingValue)
			local chatManagerSettingNumber = tonumber(chatManagerSettingValue)

			return chatManagerSettingNumber
		end,
	},

	["*omitChatDelayRights"] = {
		"CHAT_MANAGER_OMIT_CHAT_DELAY_RIGHTS",

		function(chatManagerSettingValue)
			local chatManagerOmitRights = split(chatManagerSettingValue, ",")

			if (chatManagerOmitRights) then
				return chatManagerOmitRights
			end

			local chatManagerOmitRight = { chatManagerSettingValue }

			return chatManagerOmitRight
		end,
	},

	["*blockRepeatMessages"] = {
		"CHAT_MANAGER_BLOCK_REPEATED_MESSAGES",

		function(chatManagerSettingValue)
			local chatManagerSettingBool = (chatManagerSettingValue == "true")

			return chatManagerSettingBool
		end,
	},

	["*playerDefaultColor"] = {
		"CHAT_MANAGER_PLAYER_DEFAULT_COLOR",

		function(chatManagerSettingValue)
			local chatManagerDefaultPlayerColor = {255, 255, 255}
			local chatManagerCustomPlayerColor = split(chatManagerSettingValue, ",")

			if (chatManagerCustomPlayerColor) then
				return chatManagerCustomPlayerColor
			end

			return chatManagerDefaultPlayerColor
		end,
	},

	["*removeHex"] = {
		"CHAT_MANAGER_REMOVE_HEX",

		function(chatManagerSettingValue)
			local chatManagerSettingBool = (chatManagerSettingValue == "true")

			return chatManagerSettingBool
		end,
	},

	["*nameColorMode"] = {
		"CHAT_MANAGER_NAME_COLOR_MODE",
	},
}

local function updateChatManagerSetting(chatManagerSettingKey)
	local chatManagerSetting = chatManagerSettingsTemplate[chatManagerSettingKey]

	if (not chatManagerSetting) then
		return false
	end

	local chatManagerValue = get(chatManagerSettingKey)

	if (not chatManagerValue) then
		local chatManagerLog = "[chatManager]: Failed to retrieve setting key '"..chatManagerSettingKey.."'."
		local chatManagerLogLevel = 4
		local chatManagerLogR, chatManagerLogG, chatManagerLogB = 255, 127, 0

		outputDebugString(chatManagerLog, chatManagerLogLevel, chatManagerLogR, chatManagerLogG, chatManagerLogB)

		return false
	end

	local chatManagerVariable = chatManagerSetting[1]
	local chatManagerFunction = chatManagerSetting[2]

	if (chatManagerFunction) then
		local chatManagerFunctionResult = chatManagerFunction(chatManagerValue)

		chatManagerValue = chatManagerFunctionResult
	end

	_G[chatManagerVariable] = chatManagerValue

	return true
end

do
	for chatManagerSettingKey, _ in pairs(chatManagerSettingsTemplate) do -- initialize all settings into variables
		updateChatManagerSetting(chatManagerSettingKey)
	end
end

local function handleChatManagerSettingUpdate(settingKey)
	local chatManagerReplaceFrom = "*"..resourceName.."."
	local chatManagerReplaceTo = "*"
	local chatManagerSettingKey = string.gsub(settingKey, chatManagerReplaceFrom, chatManagerReplaceTo)

	updateChatManagerSetting(chatManagerSettingKey)
end
addEventHandler("onSettingChange", root, handleChatManagerSettingUpdate)