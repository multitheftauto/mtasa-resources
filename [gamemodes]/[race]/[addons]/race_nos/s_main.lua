
g_Root = getRootElement()
g_ResRoot = getResourceRootElement()

--
-- SETTINGS
--

g_SettingKeys = { 
	["nos_duration"] = {
		clientSetting = "NosDuration",
		dataType = tonumber,
		defaultValue = 20
	},
	["nos_recharge_delay"] = {
		clientSetting = "NosRechargeDelay",
		dataType = tonumber,
		defaultValue = 40
	},
	["nos_recharge_duration"] = {
		clientSetting = "NosRechargeDuration",
		dataType = tonumber,
		defaultValue = 0
	},
	["nos_state_on_vehicle_spawn"] = {
		clientSetting = "KeepNosOnPlayerWasted",
		dataType = toboolean,
		defaultValue = false
	},
	["nos_state_on_vehicle_change"] = {
		clientSetting = "KeepNosOnVehicleChange",
		dataType = toboolean,
		defaultValue = false
	}
}

g_Settings = {}

function refreshClientSettings(player)
	player = player or g_Root
	triggerClientEvent(player, "onClientUpdateNosSettings", player, g_Settings)
end

function cacheResourceSettings()
	g_Settings = {}
	for key,setting in pairs(g_SettingKeys) do
		local clientSetting = setting.clientSetting or key
		local value = get(key) or setting.defaultValue
		g_Settings[clientSetting] = (setting.dataType or tostring)(value) or setting.defaultValue
	end
end

addEvent("onRequestNosSettings", true)
addEventHandler("onRequestNosSettings", g_Root, 
	function()
		cacheResourceSettings()
		refreshClientSettings(source)
	end
)


-- Called from the admin panel when a setting is changed there
addEvent ("onSettingChange")
addEventHandler("onSettingChange", g_ResRoot,
	function(name, oldvalue, value, player)
		cacheResourceSettings()
		refreshClientSettings()
	end
)


--
-- ADMIN COMMANDS
--

-- admin command to set NOS duration
function consoleSetNosDuration(playerSource, commandName, durationInSeconds)
	if not durationInSeconds then
		outputChatBox("Syntax: /nosduration <duration in seconds>", playerSource)
	end
	local duration = tonumber(durationInSeconds)
	if duration <= 15 then 
		outputChatBox("A value greater that 15 seconds must be supplied.", playerSource)
		return 
	end
	set("*nos_duration", duration)
	cacheResourceSettings()
	refreshClientSettings()
	outputChatBox("The duration of a NOS charge has been set to " .. duration .. " seconds.")
end
addCommandHandler("nosduration", consoleSetNosDuration, true)


-- admin command to set NOS recharge period
function consoleSetNosRechargePeriod(playerSource, commandName, durationInSeconds)
	if not durationInSeconds then
		outputChatBox("Syntax: /nosrecharge <period in seconds>", playerSource)
	end
	local duration = tonumber(durationInSeconds)
	set("*nos_recharge_delay", duration)
	cacheResourceSettings()
	refreshClientSettings()
	outputChatBox("The NOS recharge period has been set to " .. duration .. " seconds.")
end
addCommandHandler("nosrechargedelay", consoleSetNosRechargePeriod, true)


-- admin command to set NOS recharge period
function consoleSetNosRechargeDuration(playerSource, commandName, durationInSeconds)
	if not durationInSeconds then
		outputChatBox("Syntax: /nosrechargeduration <duration in seconds>", playerSource)
	end
	local duration = tonumber(durationInSeconds)
	set("*nos_recharge_duration", duration)
	cacheResourceSettings()
	refreshClientSettings()
	outputChatBox("The duration of a NOS recharge has been set to " .. duration .. " seconds.")
end
addCommandHandler("nosrecharge", consoleSetNosRechargePeriod, true)


-- admin command to set NOS state on vehicle spawn
function consoleSetNosStateOnVehicleSpawn(playerSource, commandName, state)
	if state ~= "on" and state ~= "off" then
		outputChatBox("Syntax: /nosonrespawn [on|off]", playerSource)
		return
	end
	state = state == "on"
	set("*nos_state_on_vehicle_spawn", state)
	cacheResourceSettings()
	refreshClientSettings()
end
addCommandHandler("nosonrespawn", consoleSetNosStateOnVehicleSpawn)


-- admin command to set NOS state on vehicle spawn
function consoleSetNosStateOnVehicleChange(playerSource, commandName, state)
	if state ~= "on" and state ~= "off" then
		outputChatBox("Syntax: /nosonchange [on|off]", playerSource)
		return
	end
	state = state == "on"
	set("*nos_state_on_vehicle_change", state)
	cacheResourceSettings()
	refreshClientSettings()
end
addCommandHandler("nosonchange", consoleSetNosStateOnVehicleSpawn)






--
-- RACE NOS
--

addEventHandler("onNotifyPlayerReady", g_Root,
	function()
		-- does the spawnpoint already have a nitro upgrade installed?
		local vehicle = getPedOccupiedVehicle(source)
		
		if not vehicle then	return end
		local nitro = getVehicleUpgradeOnSlot(vehicle, 8)
		if type(nitro) == "number" and nitro ~= 0 then
			playSoundFrontEnd(source, 46)
			triggerClientEvent(source, "onClientPickupNos", source, 100)
		end	
	end
)


addEvent("onPlayerPickUpRacePickup")
addEventHandler("onPlayerPickUpRacePickup", g_Root, 
	function(_, type, vehicleId)
		if type == "nitro" then
			triggerClientEvent(source, "onClientPickupNos", source, 100)
		elseif type == "vehiclechange" then
			triggerClientEvent(source, "onClientVehicleChange", source, vehicleId)
		end
	end
)


addEvent("onPlayerReachCheckpoint")
addEventHandler("onPlayerReachCheckpoint", g_Root, 
	function(checkpointNum, time)
		triggerClientEvent(source, "onClientCheckpointReached", source, checkpointNum)
	end
)


addEvent("onMapStarting")
addEventHandler("onMapStarting", g_Root,
	function(mapInfo, mapOptions, gameOptions)
		cacheResourceSettings()
		-- allow map to override settings
		for key,setting in pairs(g_SettingKeys) do
			local clientSetting = setting.clientSetting or key
			local value = get(string.format("#%s.%s", mapInfo.resname, key))
			if value then
				g_Settings[clientSetting] = (setting.dataType or tostring)(value) or setting.defaultValue
			end
		end
		refreshClientSettings()
	end
)

--
-- OTHER NOS
--

addEvent("onVehicleEnter")
addEventHandler("onVehicleEnter", g_Root,
	function(player, seat, jacked)
		if seat == 0 then
			local vehicle = source
			local savedAmount = getElementData(vehicle, "nos", false) or -1
			if savedAmount == -1 then
				-- may have upgrades
				local nitro = getVehicleUpgradeOnSlot(vehicle, 8)
				if type(nitro) == "number" and nitro ~= 0 then
					savedAmount = 100
				end
			end
			
			if savedAmount > 0 then
				playSoundFrontEnd(source, 46)
				triggerClientEvent(player, "onClientPickupNos", player, savedAmount)
			end	

		end
	end
)




