local carfadeSettings = {}
carfadeSettings.values = {}

function carfadeSettings.refreshSettings()
	carfadeSettings.values.maxdistance = mathClamp(getNumber("race_carfade.maxdistance", 15), 1, 100)
	carfadeSettings.values.mindistance = mathClamp(getNumber("race_carfade.mindistance", 5), 1, 100)
	carfadeSettings.values.minalpha = mathClamp(getNumber("race_carfade.minalpha", 0), 0, 255)
	carfadeSettings.values.keybind = getBindKeyValue("race_carfade.keybind", "c")
	carfadeSettings.values.canbetoggled = getBool("race_carfade.canbetoggled", true)
	carfadeSettings.values.enabledbydefault = getBool("race_carfade.enabledbydefault", true)
	carfadeSettings.values.broadcastatmapstart = getBool("race_carfade.broadcastatmapstart", true)
	carfadeSettings.values.throttleamount = mathClamp(getNumber("race_carfade.throttleamount", 100), 0, 1000)
end
carfadeSettings.refreshSettings()

function carfadeSettings.settingsChanged(changedSetting)
	if string.find(changedSetting, getResourceName( getThisResource() ) ) ~= 2 then
		return
	end

	carfadeSettings.refreshSettings()
	triggerClientEvent( root, "race_carfade.updateSettings", resourceRoot, carfadeSettings.values )
end
addEventHandler("onSettingChange", resourceRoot, carfadeSettings.settingsChanged)

function carfadeSettings.sendSettingsToClient()
	if not client then
		return
	end
	triggerClientEvent( client, "race_carfade.updateSettings", client, carfadeSettings.values )
end
addEvent("race_carfade.clientRequestsSettings", true)
addEventHandler("race_carfade.clientRequestsSettings", resourceRoot, carfadeSettings.sendSettingsToClient)
