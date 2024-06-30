-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local radioSettings = {}
local settingsConfig = {
	["allowRemoteSpeakers"] = {
		defaultValue = true,
		getValueFrom = nil,
	},
}

local function verifyRadioSettings(pRadioSettings)
	local settingsType = type(pRadioSettings)
	local settingsTable = (settingsType == "table")

	if (not settingsTable) then
		return false
	end

	radioSettings = pRadioSettings

	return true
end

function onClientResourceStartLoadSettings()
	local settingsFileExists = fileExists(RADIO_SETTINGS_PATH)

	if (not settingsFileExists) then
		return false
	end

	local settingsFileReadOnly = true
	local settingsFileHandler = fileOpen(RADIO_SETTINGS_PATH, settingsFileReadOnly)

	if (not settingsFileHandler) then
		return false
	end

	local settingsFileSize = fileGetSize(settingsFileHandler)
	local settingsFileData = fileRead(settingsFileHandler, settingsFileSize)
	local settingsJson = fromJSON(settingsFileData)

	fileClose(settingsFileHandler)
	verifyRadioSettings(settingsJson)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStartLoadSettings)

function onClientResourceStopSaveSettings()
	local settingsFileExists = fileExists(RADIO_SETTINGS_PATH)

	if (settingsFileExists) then
		fileDelete(RADIO_SETTINGS_PATH)
	end

	local newSettingsFile = fileCreate(RADIO_SETTINGS_PATH)

	if (not newSettingsFile) then
		return false
	end

	local jsonCompact = false
	local jsonPrettyType = "tabs"
	local jsonData = toJSON(radioSettings, jsonCompact, jsonPrettyType)

	fileWrite(newSettingsFile, jsonData)
	fileClose(newSettingsFile)
end
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStopSaveSettings)