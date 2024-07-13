-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

local savedRadioSettings = {}

local function verifyRadioSettings(radioSettings)
	local settingsType = type(radioSettings)
	local settingsTable = (settingsType == "table")

	if (not settingsTable) then
		return false
	end

	local settingsToLoad = {}

	for settingKey, settingValue in pairs(radioSettings) do
		local settingKeyType = type(settingKey)
		local settingKeyString = (settingKeyType == "string")

		if (settingKeyString) then
			settingsToLoad[settingKey] = settingValue
		end
	end

	for settingKey, settingValue in pairs(settingsToLoad) do
		local settingData = RADIO_SETTINGS_TEMPLATE[settingKey]
		local settingExists = (settingData ~= nil)

		if (settingExists) then
			local settingValueType = type(settingValue)
			local settingAllowedType = settingData.dataType
			local settingMatchingDataType = settingAllowedType[settingValueType]

			if (not settingMatchingDataType) then
				local settingDefault = settingData.defaultsTo

				settingsToLoad[settingKey] = settingDefault
			end
		else
			settingsToLoad[settingKey] = nil
		end
	end

	savedRadioSettings = settingsToLoad

	return true
end

local function loadDefaultRadioSettings()
	for settingKey, settingData in pairs(RADIO_SETTINGS_TEMPLATE) do
		local settingValue = settingData.defaultsTo

		savedRadioSettings[settingKey] = settingValue
	end
end

function setRadioSetting(pKey, pValue)
	savedRadioSettings[pKey] = pValue

	return true
end

function getRadioSetting(pKey)
	local radioSetting = savedRadioSettings[pKey]

	return radioSetting
end

function onClientResourceStartLoadSettings()
	local settingsFileExists = fileExists(RADIO_SETTINGS_PATH)

	loadDefaultRadioSettings()

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
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStartLoadSettings, false, "high")

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
	local jsonData = toJSON(savedRadioSettings, jsonCompact, jsonPrettyType)

	fileWrite(newSettingsFile, jsonData)
	fileClose(newSettingsFile)
end
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStopSaveSettings, false, "high")