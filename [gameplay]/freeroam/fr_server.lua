local g_PlayerData = {}
local g_VehicleData = {}
local chatTime = {}
local lastChatMessage = {}

g_ArmedVehicles = {
	[425] = true,
	[447] = true,
	[520] = true,
	[430] = true,
	[464] = true,
	[432] = true
}
g_Trailers = {
	[606] = true,
	[607] = true,
	[610] = true,
	[590] = true,
	[569] = true,
	[611] = true,
	[584] = true,
	[608] = true,
	[435] = true,
	[450] = true,
	[591] = true
}

g_RPCFunctions = {
	addPedClothes = { option = 'clothes', descr = 'Modifying clothes' },
	addVehicleUpgrade = { option = 'upgrades', descr = 'Adding/removing upgrades' },
	fadeVehiclePassengersCamera = true,
	fixVehicle = { option = 'repair', descr = 'Repairing vehicles' },
	giveMeVehicles = { option = 'createvehicle', descr = 'Creating vehicles' },
	giveMeWeapon = { option = 'weapons.enabled', descr = 'Getting weapons' },
	removePedClothes = { option = 'clothes', descr = 'Modifying clothes' },
	removePedFromVehicle = true,
	removeVehicleUpgrade = { option = 'upgrades', descr = 'Adding/removing upgrades' },
	setElementAlpha = { option = 'alpha', descr = 'Changing your alpha' },
	setElementInterior = true,
	setCameraInterior = true,
	setMySkin = { option = 'setskin', descr = 'Setting skin' },
	setPedAnimation = { option = 'anim', descr = 'Setting an animation' },
	setPedFightingStyle = { option = 'setstyle', descr = 'Setting fighting style' },
	setPedGravity = { option = 'gravity.enabled', descr = 'Setting gravity' },
	setPedStat = { option = 'stats', descr = 'Changing stats' },
	setPedWearingJetpack = { option = 'jetpack', descr = 'Adding/removing a jetpack' },
	setVehicleColor = true,
	setVehicleHeadLightColor = true,
	setVehicleOverrideLights = { option = 'lights', descr = 'Forcing lights' },
	setVehiclePaintjob = { option = 'paintjob', descr = 'Applying paintjobs' },
	warpMeIntoVehicle = true,
}

g_OptionDefaults = {
	alpha = true,
	anim = true,
	clothes = true,
	createvehicle = true,
	gamespeed = {
		enabled = true,
		min = 0.0,
		max = 3
	},
	gravity = {
		enabled = true,
		min = 0,
		max = 0.1
	},
	jetpack = true,
	lights = true,
	paintjob = true,
	repair = true,
	setskin = true,
	setstyle = true,
	spawnmaponstart = true,
	spawnmapondeath = true,
	stats = true,
	upgrades = true,
	warp = true,
	weapons = {
		enabled = true,
		vehiclesenabled = true,
		disallowed = {},
		kniferestrictions = true
	},
	welcometextonstart = true,
	vehicles = {
		maxidletime = 60000,
		idleexplode = true,
		maxperplayer = 2,
		disallowed = {}
	}
}

function getOption(optionName)
	local option = get(optionName:gsub('%.', '/'))
	if option then
		if option == 'true' then
			option = true
		elseif option == 'false' then
			option = false
		end
		return option
	end
	option = g_OptionDefaults
	for i,part in ipairs(optionName:split('.')) do
		option = option[part]
	end
	return option
end

addEventHandler('onResourceStart', resourceRoot,
	function()
		table.each(getElementsByType('player'), joinHandler)
	end
)

function onLocalSettingChange(setting,value)

	if client ~= source then return end
	g_PlayerData[client].settings[setting] = value
	triggerClientEvent("onClientFreeroamLocalSettingChange",client,setting,value)

end

function joinHandler(player)
	local r, g, b = math.random(50, 255), math.random(50, 255), math.random(50, 255)
	setPlayerNametagColor(player, r, g, b)
	g_PlayerData[player] = { vehicles = {}, settings={} }
	addEventHandler("onFreeroamLocalSettingChange",player,onLocalSettingChange)

	if getOption('welcometextonstart') then
		outputChatBox('Welcome to Freeroam', player, 0, 255, 0)
		outputChatBox('Press F1 to show/hide controls', player, 0, 255, 0)
	end
end

addEventHandler('onPlayerJoin', root, function() joinHandler(source) end)

local settingsToSend = {
	"command_spam_protection",
	"tries_required_to_trigger",
	"tries_required_to_trigger_low_priority",
	"command_spam_ban_duration",
	"command_exception_commands",
	"removeHex",
	"spawnmapondeath",
	"weapons/kniferestrictions",
	"kill",
	"warp",
	"hidecolortext",
	"gamespeed/enabled",
	"gamespeed/min",
	"gamespeed/max",
	"gui/antiram",
	"gui/disablewarp",
	"gui/disableknife",
	"vehicles/disallowed_warp",
}

local function updateSettings()
	local settings = {}

	for _, setting in ipairs(settingsToSend) do
		settings[setting] = getOption(setting)
	end

	return settings
end

local function sendSettings(player,settingPlayer,settings)

	if not player and isElement(player) then
		return
	end

	for setting,value in pairs(settings) do
		triggerClientEvent(player,"onClientFreeroamLocalSettingChange",settingPlayer,setting,value)
	end

end

addEvent('onLoadedAtClient', true)
addEventHandler('onLoadedAtClient', resourceRoot,
	function()
		if getOption('spawnmaponstart') and isPedDead(client) then
			clientCall(client, 'showWelcomeMap')
		end
		local settings = updateSettings()
		clientCall(client, 'freeroamSettings', settings)
		for player,data in pairs(g_PlayerData) do
			if player ~= client then
				local settings2 = data.settings
				setTimer(sendSettings,1500,1,client,player,settings2)
			end
		end
	end,
	false
)

function onSettingChange(key,_,new)
	local access = key:sub(1, 1) -- we always have modifiers
	if access ~= "*" and access ~= "#" and access ~= "@" then
		return
	end

	local resource = key:sub(2, 9)
	if key:sub(2, 9) ~= getThisResource().name then
		return
	end

	local setting = key:sub(11)
	if not table.find(settingsToSend, setting) then
		return
	end

	local settings = updateSettings()
	for index,player in ipairs(getElementsByType("player")) do
		clientCall(player, 'freeroamSettings', settings)
	end
end
addEventHandler("onSettingChange", root, onSettingChange)

function showMap(player)
	if isPedDead(player) then
		clientCall(player, "showMap")
	end
end


function handleClothesInit()

	if not client or source ~= resourceRoot then
		return
	end

	local result = {}
	local texture, model
	-- get all clothes
	result.allClothes = {}
	local typeGroup, index

	for type=0,17 do
		typeGroup = {'group', type = type, name = getClothesTypeName(type), children = {}}
		table.insert(result.allClothes, typeGroup)
		index = 0
		texture, model = getClothesByTypeIndex(type, index)
		while texture do
			table.insert(typeGroup.children, {id = index, texture = texture, model = model})
			index = index + 1
			texture, model = getClothesByTypeIndex(type, index)
		end
	end

	-- get current player clothes { type = {texture=texture, model=model} }
	result.playerClothes = {}

	for type=0,17 do
		texture, model = getPedClothes(client, type)
		if texture then
			result.playerClothes[type] = {texture = texture, model = model}
		end
	end

	if client and isElement(client) then
		triggerClientEvent(client, "onClientClothesInit", resourceRoot, result)
	end
end
addEvent('onClothesInit', true)
addEventHandler('onClothesInit', resourceRoot, handleClothesInit, false)

addEvent('onPlayerGravInit', true)
addEventHandler('onPlayerGravInit', root,
	function()
		if source ~= client then return end
		if client and isElement(client) then
			triggerClientEvent(client, "onClientPlayerGravInit", client, getPedGravity(client))
		end
	end
)

------------------------------------------
-- [START] Remote Player Call Functions --


function setMySkin(skinid)
	if not isElement(client) then return end
	if getElementModel(client) == skinid then return end
	if isPedDead(client) then
		local x, y, z = getElementPosition(client)

		if isPedTerminated(client) then
			x = 0
			y = 0
			z = 3
		end

		local r = getPedRotation(client)
		local interior = getElementInterior(client)
		spawnPlayer(client, x, y, z, r, skinid)
		setElementInterior(client, interior)
		setCameraInterior(client, interior)
	else
		setElementModel(client, skinid)
	end
	setCameraTarget(client, client)
	setCameraInterior(client, getElementInterior(client))
end

function spawnMe(x, y, z)
	if not x then
		x, y, z = getElementPosition(client)
	end

	if isPedTerminated(client) then
		repeat until spawnPlayer(client, x, y, z, 0, math.random(9, 288))
	else
		spawnPlayer(client, x, y, z, 0, getPedSkin(client))
	end

	setCameraTarget(client, client)
	setCameraInterior(client, getElementInterior(client))
end

function warpMeIntoVehicle(vehicle)
	if not isElement(vehicle) then return end

	if isPedDead(client) then
		spawnMe()
	end

	if getPedOccupiedVehicle(client) then
		outputChatBox('Get out of your vehicle first.', client, 255, 0, 0)
		return
	end
	local interior = getElementInterior(vehicle)
	local numseats = getVehicleMaxPassengers(vehicle)
	local driver = getVehicleController(vehicle)
	for i=0,numseats do
		if not getVehicleOccupant(vehicle, i) then
			if isPedDead(client) then
				local x, y, z = getElementPosition(vehicle)
				spawnMe(x + 4, y, z + 1)
			end

			setElementInterior(client, interior)
			setCameraInterior(client, interior)
			warpPedIntoVehicle(client, vehicle, i)
			return
		end
	end
	if isElement(driver) then
		outputChatBox('No free seats left in ' .. getPlayerName(driver) .. '\'s vehicle.', client, 255, 0, 0)
	end
end

local sawnoffAntiAbuse = {}

function giveMeWeapon(weapon, amount)
	local player = client
	if table.find(getOption('weapons.disallowed'), weapon) then
		errMsg((getWeaponNameFromID(weapon) or tostring(weapon)) .. 's are not allowed', player)
	else
		giveWeapon(player, weapon, amount, true)
		if weapon == 26 then
			if not sawnoffAntiAbuse[player] then
				setControlState(player, "aim_weapon", false)
				setControlState(player, "fire", false)
				toggleControl(player, "fire", false)
				reloadPedWeapon(player)
				sawnoffAntiAbuse[player] = setTimer(function(thePlayer)
					if not isElement(thePlayer) then return end
					toggleControl(thePlayer, "fire", true)
					sawnoffAntiAbuse[thePlayer] = nil
				end, 3000, 1, player)
			end
		end
	end
end


function giveMeVehicles(vehID)
	local player = client
	if not isElement(player) then return end
	local element = getPedOccupiedVehicle(player) or player
	local px,py,pz = getElementPosition(element)
	local _,_,prot = getElementRotation(element)
	local posVector = Vector3(px,py,pz+2)
	local rotVector = Vector3(0,0,prot)
	local vehMatrix = Matrix(posVector,rotVector)
	local vehicleList = g_PlayerData[player].vehicles
	if not vehID then return end
	if not table.find(getOption('vehicles.disallowed'), vehID) then
		if #vehicleList >= getOption('vehicles.maxperplayer') then unloadVehicle(vehicleList[1]) end
		local vehPos = posVector+vehMatrix.right*3
		local vehicle = Vehicle(vehID, vehPos, rotVector) or false
		if vehicle then
			vehicle.interior = player.interior
			vehicle.dimension = player.dimension
			if vehicle.vehicleType == "Bike" then vehicle.velocity = Vector3(0,0,-0.01) end
			table.insert(vehicleList, vehicle)
			g_VehicleData[vehicle] = { creator = player, timers = {} }
			if g_Trailers[vehID] then
				if getOption('vehicles.maxidletime') >= 0 then
					if getOption('vehicles.idleexplode') then
						g_VehicleData[vehicle].timers.fire = setTimer(commitArsonOnVehicle, getOption('vehicles.maxidletime'), 1, vehicle)
					end
					g_VehicleData[vehicle].timers.destroy = setTimer(unloadVehicle, getOption('vehicles.maxidletime') + (getOption('vehicles.idleexplode') and 10000 or 0), 1, vehicle)
				end
			end
		end
	else
		errMsg(getVehicleNameFromModel(vehID):gsub('y$', 'ie') .. 's are not allowed', player)
	end
end

-- [END] Remote Player Call Functions --
----------------------------------------

local _setPlayerGravity = setPedGravity
function setPedGravity(player, grav)
	if grav < getOption('gravity.min') then
		errMsg(('Minimum allowed gravity is %.5f'):format(getOption('gravity.min')), player)
	elseif grav > getOption('gravity.max') then
		errMsg(('Maximum allowed gravity is %.5f'):format(getOption('gravity.max')), player)
	else
		_setPlayerGravity(player, grav)
	end
end

function fadeVehiclePassengersCamera(toggle)
	local vehicle = getPedOccupiedVehicle(source)

	if not vehicle then
		return
	end

	local player
	for i=0,getVehicleMaxPassengers(vehicle) do
		player = getVehicleOccupant(vehicle, i)
		if player then
			fadeCamera(player, toggle)
		end
	end
end

addEventHandler('onPlayerChat', root,
	function(msg, type)
		if type == 0 then
			cancelEvent()
			if not hasObjectPermissionTo(source, "command.kick") and not hasObjectPermissionTo(source, "command.mute") then
				if chatTime[source] and chatTime[source] + tonumber(get("*chat/mainChatDelay")) > getTickCount() then
					outputChatBox("Stop spamming main chat!", source, 255, 0, 0)
					return
				else
					chatTime[source] = getTickCount()
				end
				if get("*chat/blockRepeatMessages") == "true" and lastChatMessage[source] and lastChatMessage[source] == msg then
					outputChatBox("Stop repeating yourself!", source, 255, 0, 0)
					return
				else
					lastChatMessage[source] = msg
				end
			end
			if isElement(source) then
				local r, g, b = getPlayerNametagColor(source)
				outputChatBox(getPlayerName(source) .. ': #FFFFFF' .. stripHex(msg), root, r, g, b, true)
				outputServerLog( "CHAT: " .. getPlayerName(source) .. ": " .. msg )
			end
		end
	end
)

addEventHandler('onVehicleEnter', root,
	function(player, seat)
		if not g_VehicleData[source] then
			return
		end

		if g_VehicleData[source].timers.fire then
			killTimer(g_VehicleData[source].timers.fire)
			g_VehicleData[source].timers.fire = nil
		end

		if g_VehicleData[source].timers.destroy then
			killTimer(g_VehicleData[source].timers.destroy)
			g_VehicleData[source].timers.destroy = nil
		end

		if not getOption('weapons.vehiclesenabled') and g_ArmedVehicles[getElementModel(source)] then
			toggleControl(player, 'vehicle_fire', false)
			toggleControl(player, 'vehicle_secondary_fire', false)
		end

		-- Fast Hunter/Hydra on custom gravity fix
		if getElementModel(source) == 425 or getElementModel(source) == 520 then
			if getPedGravity(player) ~= 0.008 then
				g_PlayerData[player].previousGravity = getPedGravity(player)
				setPedGravity(player, 0.008)
			end
		end
	end
)

addEventHandler('onVehicleExit', root,
	function(player, seat)
		if not g_VehicleData[source] then
			return
		end

		if not g_VehicleData[source].timers.fire then
			for i=0,getVehicleMaxPassengers(source) or 1 do
				if getVehicleOccupant(source, i) then
					return
				end
			end
			if getOption('vehicles.maxidletime') >= 0 then
				if getOption('vehicles.idleexplode') then
					g_VehicleData[source].timers.fire = setTimer(commitArsonOnVehicle, getOption('vehicles.maxidletime'), 1, source)
				end
				g_VehicleData[source].timers.destroy = setTimer(unloadVehicle, getOption('vehicles.maxidletime') + (getOption('vehicles.idleexplode') and 10000 or 0), 1, source)
			end
		end
		if g_ArmedVehicles[getElementModel(source)] then
			toggleControl(player, 'vehicle_fire', true)
			toggleControl(player, 'vehicle_secondary_fire', true)
		end

		if g_PlayerData[player].previousGravity then
			setPedGravity(player, g_PlayerData[player].previousGravity)
			g_PlayerData[player].previousGravity = nil
		end
	end
)

function commitArsonOnVehicle(vehicle)
	g_VehicleData[vehicle].timers.fire = nil
	setElementHealth(vehicle, 0)
end

addEventHandler('onVehicleExplode', root,
	function()
		if not g_VehicleData[source] then
			return
		end

		if g_VehicleData[source].timers.fire then
			killTimer(g_VehicleData[source].timers.fire)
			g_VehicleData[source].timers.fire = nil
		end

		if not g_VehicleData[source].timers.destroy then
			g_VehicleData[source].timers.destroy = setTimer(unloadVehicle, 5000, 1, source)
		end

		if getVehicleController(source) then
			if g_PlayerData[getVehicleController(source)].previousGravity then
				setPedGravity(getVehicleController(source), g_PlayerData[getVehicleController(source)].previousGravity)
				g_PlayerData[getVehicleController(source)].previousGravity = nil
			end
		end
	end
)

function unloadVehicle(vehicle)
	if not g_VehicleData[vehicle] then
		return
	end

	for name,timer in pairs(g_VehicleData[vehicle].timers) do
		if isTimer(timer) then
			killTimer(timer)
		end
		g_VehicleData[vehicle].timers[name] = nil
	end

	local creator = g_VehicleData[vehicle].creator

	if g_PlayerData[creator] then
		table.removevalue(g_PlayerData[creator].vehicles, vehicle)
	end

	g_VehicleData[vehicle] = nil
	if isElement(vehicle) then
		destroyElement(vehicle)
	end
end

function quitHandler(player)
	if sawnoffAntiAbuse[source] and isTimer (sawnoffAntiAbuse[source]) then
		killTimer (sawnoffAntiAbuse[source])
		sawnoffAntiAbuse[source] = nil
	end

	table.each(g_PlayerData[source].vehicles, unloadVehicle)
	removeEventHandler("onFreeroamLocalSettingChange",source,onLocalSettingChange)
	g_PlayerData[source] = nil
	chatTime[source] = nil
	lastChatMessage[source] = nil
end
addEventHandler('onPlayerQuit', root, quitHandler)

addEvent('onServerCall', true)
addEventHandler('onServerCall', resourceRoot,
	function(fnName, ...)
		source = client		-- Some called functions require 'source' to be set to the triggering client
		local fnInfo = g_RPCFunctions[fnName]

		-- Custom check made to intercept the jetpack on custom gravity
		if fnInfo and type(fnInfo) ~= "boolean" and tostring(fnInfo.option) == "jetpack" then
			if tonumber(("%.3f"):format(getPedGravity(client))) ~= 0.008 then
				errMsg("* You may use jetpack only if the gravity is set to 0.008", client)
				return
			end
		end

		if fnInfo and ((type(fnInfo) == 'boolean' and fnInfo) or (type(fnInfo) == 'table' and getOption(fnInfo.option))) then
			local fn = _G
			for i,pathpart in ipairs(fnName:split('.')) do
				fn = fn[pathpart]
			end
			if not g_RPCFunctionsValidation[fnName] then
				outputDebugString('Function ' ..
					tostring(fnName) ..
					' is missing from the validation list. Please add this one to g_RPCFunctionsValidation.', 1)
				return
			end
			if not g_RPCFunctionsValidation[fnName](...) then
				errMsg('Something went wrong.', client)
				-- outputDebugString(
				-- 	'Invalid parameters has been provided for function `' ..
				-- 	tostring(fnName) .. '` by user: ' .. getPlayerSerial(client) .. ' It can be a bug.', 1)
				return
			end
			fn(...)
		elseif type(fnInfo) == 'table' then
			errMsg(fnInfo.descr .. ' is not allowed', client)
		end
	end, false
)

function clientCall(player, fnName, ...)
	triggerClientEvent(player, 'onClientCall', resourceRoot, fnName, ...)
end

function getPlayerName(player)
	return getOption("removeHex") and player.name:gsub("#%x%x%x%x%x%x","") or player.name
end

addEvent("onFreeroamLocalSettingChange",true)


function handleSuicide()
	if source ~= client then return end
	if client and isElement(client) and (not isPedDead(client)) then
		killPed(client, client)
	end
end
addEvent('onFreeroamSuicide', true)
addEventHandler('onFreeroamSuicide', root, handleSuicide)