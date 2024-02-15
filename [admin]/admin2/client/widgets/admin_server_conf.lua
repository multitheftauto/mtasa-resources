--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_server_conf.lua
*
**************************************]]
aServerConfig = {
	Intervals = {
		player_sync_interval = "Player Sync",
		lightweight_sync_interval = "Lightweight Sync",
		camera_sync_interval = "Camera Sync",
		ped_sync_interval = "Ped Sync",
		unoccupied_vehicle_sync_interval = "Unoccupied Vehicle Sync",
		keysync_mouse_sync_interval = "Mouse Key Sync",
		keysync_analog_sync_interval = "Analog Key Sync",
		player_triggered_event_interval = "Player Triggered Event"
	}
}

function aServerConfig.Open()
	if (not isElement(aServerConfig.Form)) then
		local x,y = guiGetScreenSize()

		aServerConfig.Form = guiCreateWindow(x/2 - 240, y/2 - 215, 480, 430, "Server Configuration", false)

		guiCreateHeader(0.05, 0.052, 0.3, 0.04, "Connection:", true, aServerConfig.Form)
		
		aServerConfig.minVersion = guiCreateLabel(0.1, 0.089, 0.5, 0.04, "Minimum Client Version:", true, aServerConfig.Form)
		aServerConfig.minVersionField = guiCreateEdit(0.725, 0.089, 0.25, 0.04, "", true, aServerConfig.Form)

		aServerConfig.recVersion = guiCreateLabel(0.1, 0.141, 0.5, 0.04, "Recommended Client Version:", true, aServerConfig.Form)
		aServerConfig.recVersionField = guiCreateEdit(0.725, 0.141, 0.25, 0.04, "", true, aServerConfig.Form)

		guiCreateHeader(0.05, 0.193, 0.3, 0.04, "Performance:", true, aServerConfig.Form)

		aServerConfig.bandwidth = guiCreateLabel(0.1, 0.23, 0.5, 0.04, "Bandwidth Reduction:", true, aServerConfig.Form)

		aServerConfig.bandwidthCombo = guiCreateComboBox(0.725, 0.23, 0.2, 0.2, "", true, aServerConfig.Form)
		guiComboBoxAddItem(aServerConfig.bandwidthCombo, "None")
		guiComboBoxAddItem(aServerConfig.bandwidthCombo, "Medium")
		guiComboBoxAddItem(aServerConfig.bandwidthCombo, "Maximum")

		aServerConfig.bulletSync = guiCreateLabel(0.1, 0.292, 0.5, 0.04, "Bullet Sync:", true, aServerConfig.Form)
		aServerConfig.bulletSyncCombo = guiCreateComboBox(0.725, 0.292, 0.2, 0.2, "", true, aServerConfig.Form)
		guiComboBoxAddItem(aServerConfig.bulletSyncCombo, "False")
		guiComboBoxAddItem(aServerConfig.bulletSyncCombo, "True")

		aServerConfig.maxTriggers = guiCreateLabel(0.1, 0.354, 0.55, 0.04, "Max player triggered events per interval:", true, aServerConfig.Form)
		aServerConfig.maxTriggersField = guiCreateEdit(0.725, 0.354, 0.2, 0.04, "", true, aServerConfig.Form)
		guiEditSetMaxLength(aServerConfig.maxTriggersField, 4)

		guiCreateHeader(0.05, 0.406, 0.3, 0.04, "Intervals:", true, aServerConfig.Form);

		local i = 1
		local py = 0
		for k,v in pairs(aServerConfig.Intervals) do
			py = 0.443 + 0.052 * (i - 1)
			guiCreateLabel(0.1, py, 0.5, 0.04, v..":", true, aServerConfig.Form)

			aServerConfig[k] = guiCreateEdit(0.725, py, 0.2, 0.04, "", true, aServerConfig.Form)
			guiEditSetMaxLength(aServerConfig[k], 4)
			i = i + 1
		end

		aServerConfig.infoLabel = guiCreateLabel(0, py + 0.052, 1, 0.2, "WARNING\nIf you don't know what you're doing, close this window.", true, aServerConfig.Form)
		guiLabelSetHorizontalAlign(aServerConfig.infoLabel, "center", true)
		guiLabelSetColor(aServerConfig.infoLabel, 255,0,0)
		guiSetFont(aServerConfig.infoLabel, "default-bold-small")

		aServerConfig.saveButton = guiCreateButton(0.25, 0.93, 0.2, 0.1, "Save", true, aServerConfig.Form)
		aServerConfig.closeButton = guiCreateButton(0.55, 0.93, 0.2, 0.1, "Close", true, aServerConfig.Form)

		guiSetVisible(aServerConfig.Form, false)

		aRegister("ServerConfig", aServerConfig.Form, aServerConfig.Open, aServerConfig.Close)
	else
		guiSetVisible(aServerConfig.Form, true)
		guiBringToFront(aServerConfig.Form)
	end

	addEventHandler("onClientGUIClick", aServerConfig.Form, aServerConfig.onClientClick)
	addEventHandler('onClientGUIChanged', aServerConfig.Form, aServerConfig.onClientChanged)
	addEventHandler("onAdminRefresh", aServerConfig.Form, aServerConfig.Refresh)
	
	aServerConfig.Refresh()
end

function aServerConfig.Close(destroy)
	if (destroy) then
		destroyElement(aServerConfig.Form)
	else
		removeEventHandler('onClientGUIClick', aServerConfig.Form, aServerConfig.onClientClick)
		removeEventHandler('onClientGUIChanged', aServerConfig.Form, aServerConfig.onClientChanged)
		removeEventHandler('onAdminRefresh', aServerConfig.Form, aServerConfig.Refresh)

		guiSetVisible(aServerConfig.Form, false)
	end
end

function aServerConfig.onClientChanged()
    local actualText = guiGetText(source)
    local character = actualText:sub(#actualText, #actualText)
    if (not tonumber(character) and character ~= '.' and character ~= '-') then
        guiSetText(source, actualText:sub(0, #actualText - 1))
    end
end

function aServerConfig.onClientClick(button)
	if (button == "left") then
		if (source == aServerConfig.closeButton) then
			aServerConfig.Close()
		elseif (source == aServerConfig.saveButton) then
			local triggersPerInterval = guiGetText(aServerConfig.maxTriggersField)
			local cameraSyncInterval = guiGetText(aServerConfig.camera_sync_interval)
			local playerSyncInterval = guiGetText(aServerConfig.player_sync_interval)
			local playerTriggeredEventInterval = guiGetText(aServerConfig.player_triggered_event_interval)
			local keySyncAnalogInterval = guiGetText(aServerConfig.keysync_analog_sync_interval)
			local keySyncMouseInterval = guiGetText(aServerConfig.keysync_mouse_sync_interval)
			local pedSyncInterval = guiGetText(aServerConfig.ped_sync_interval)
			local unoccupiedVehicleSyncInterval = guiGetText(aServerConfig.unoccupied_vehicle_sync_interval)
			local lightWeightSyncInterval = guiGetText(aServerConfig.lightweight_sync_interval)

			if (#triggersPerInterval <= 0 or tonumber(triggersPerInterval) < 1 or tonumber(triggersPerInterval) > 1000) then
				messageBox("The range for 'Max player triggered events per interval' is: 1-1000", MB_ERROR, MB_OK)
				return
			end

			if (#cameraSyncInterval <= 0 or tonumber(cameraSyncInterval) < 50 or tonumber(cameraSyncInterval) > 4000) then
				messageBox("The range for 'Camera sync interval' is: 50-4000", MB_ERROR, MB_OK)
				return
			end

			if (#playerSyncInterval <= 0 or tonumber(playerSyncInterval) < 50 or tonumber(playerSyncInterval) > 4000) then
				messageBox("The range for 'Player sync interval' is: 50-4000", MB_ERROR, MB_OK)
				return
			end

			if (#playerTriggeredEventInterval <= 0 or tonumber(playerTriggeredEventInterval) < 50 or tonumber(playerTriggeredEventInterval) > 5000) then
				messageBox("The range for 'Player triggered event interval' is: 50-5000", MB_ERROR, MB_OK)
				return
			end

			if (#keySyncAnalogInterval <= 0 or tonumber(keySyncAnalogInterval) < 50 or tonumber(keySyncAnalogInterval) > 4000) then
				messageBox("The range for 'Analog key sync interval' is: 50-4000", MB_ERROR, MB_OK)
				return
			end

			if (#keySyncMouseInterval <= 0 or tonumber(keySyncMouseInterval) < 50 or tonumber(keySyncMouseInterval) > 4000) then
				messageBox("The range for 'Mouse key sync interval' is: 50-4000", MB_ERROR, MB_OK)
				return
			end

			if (#pedSyncInterval <= 0 or tonumber(pedSyncInterval) < 50 or tonumber(pedSyncInterval) > 4000) then
				messageBox("The range for 'Ped sync interval' is: 50-4000", MB_ERROR, MB_OK)
				return
			end

			if (#unoccupiedVehicleSyncInterval <= 0 or tonumber(unoccupiedVehicleSyncInterval) < 50 or tonumber(unoccupiedVehicleSyncInterval) > 4000) then
				messageBox("The range for 'Unoccupied vehicle sync interval' is: 50-4000", MB_ERROR, MB_OK)
				return
			end

			if (#lightWeightSyncInterval <= 0 or tonumber(lightWeightSyncInterval) < 200 or tonumber(lightWeightSyncInterval) > 4000) then
				messageBox("The range for 'Lightweight sync interval' is: 200-4000", MB_ERROR, MB_OK)
				return
			end

			if (messageBox("Are you sure you want to save the server configuration changes?", MB_QUESTION, MB_YESNO)) then
				triggerServerEvent("aServer", localPlayer, "setconfig", {
					minclientversion = guiGetText(aServerConfig.minVersionField),
					recommendedclientversion = guiGetText(aServerConfig.recVersionField),
					bandwidth_reduction = guiComboBoxGetItemText(aServerConfig.bandwidthCombo, guiComboBoxGetSelected(aServerConfig.bandwidthCombo)):lower() or "medium",
					bullet_sync = tostring(guiComboBoxGetSelected(aServerConfig.bulletSyncCombo)),
					max_player_triggered_events_per_interval = triggersPerInterval,
					camera_sync_interval = cameraSyncInterval,
					player_sync_interval = playerSyncInterval,
					player_triggered_event_interval = playerTriggeredEventInterval,
					keysync_analog_sync_interval = keySyncAnalogInterval,
					keysync_mouse_sync_interval = keySyncMouseInterval,
					ped_sync_interval = pedSyncInterval,
					unoccupied_vehicle_sync_interval = unoccupiedVehicleSyncInterval,
					lightweight_sync_interval = lightWeightSyncInterval
				})

				aServerConfig.Close()
			end
		end
	end
end

function aServerConfig.Refresh()
	triggerServerEvent("aServerConfigRefresh", localPlayer)
end

addEvent("aClientConfigRefresh", true)
addEventHandler("aClientConfigRefresh", localPlayer, function(minclientversion, recommendedclientversion, bandwidthreduction, bulletsync, maxplayertriggers, camerasync_interval, playersync_interval, playertriggers_interval, keysync_analog_interval, keysync_mousse_interval, pedsync_interval, unoccupiedvehicle_interval, lightweight_interval)
	guiSetText(aServerConfig.minVersionField, minclientversion)
	guiSetText(aServerConfig.recVersionField, recommendedclientversion)

	guiComboBoxSetSelected(aServerConfig.bandwidthCombo, (bandwidthreduction == "none" and 0 or (bandwidthreduction == "medium" and 1 or 2)) or 0)
	guiComboBoxSetSelected(aServerConfig.bulletSyncCombo, tonumber(bulletsync))

	guiSetText(aServerConfig.maxTriggersField, maxplayertriggers)
	guiSetText(aServerConfig.camera_sync_interval, camerasync_interval)
	guiSetText(aServerConfig.player_sync_interval, playersync_interval)
	guiSetText(aServerConfig.player_triggered_event_interval, playertriggers_interval)
	guiSetText(aServerConfig.keysync_analog_sync_interval, keysync_analog_interval)
	guiSetText(aServerConfig.keysync_mouse_sync_interval, keysync_mousse_interval)
	guiSetText(aServerConfig.ped_sync_interval, pedsync_interval)
	guiSetText(aServerConfig.unoccupied_vehicle_sync_interval, unoccupiedvehicle_interval)
	guiSetText(aServerConfig.lightweight_sync_interval, lightweight_interval)
end)