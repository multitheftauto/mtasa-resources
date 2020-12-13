local carfadeSettings = {}
carfadeSettings.values = {}

function carfadeSettings.request()
	triggerServerEvent("race_carfade.clientRequestsSettings", resourceRoot)
end
carfadeSettings.request()


function carfadeSettings.receive(receivedSettings)
	carfadeSettings.values = receivedSettings
	carFade.handleSettings()
end
addEvent("race_carfade.updateSettings", true)
addEventHandler("race_carfade.updateSettings", root, carfadeSettings.receive)

function getSetting(key)
	return carfadeSettings.values[key] or nil
end
