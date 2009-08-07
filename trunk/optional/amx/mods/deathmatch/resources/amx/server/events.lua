-------------------------------
-- Players

function gameModeInit(player)
	local playerID = getElemID(player)
	local playerData = g_Players[playerID]
	for k,v in pairs(playerData) do
		if k ~= 'elem' and k ~= 'keys' and k ~= 'blip' then
			playerData[k] = nil
		end
	end
	setPlayerMoney(player, 0)
	takeAllWeapons(player)
	setElementInterior(player, 0)
	setElementDimension(player, 0)
	local r, g, b = math.random(50, 255), math.random(50, 255), math.random(50, 255)
	ShowPlayerMarker(false, player, g_ShowPlayerMarkers)
	showPlayerHudComponent(player, 'area_name', g_ShowZoneNames)
	SetPlayerColor(false, player, r, g, b)
	setElementData(player, 'Score', 0)
	toggleAllControls(player, false, true, false)
	clientCall(player, 'showIntroScene')
	clientCall(player, 'TogglePlayerClock', false, false)
	if g_PlayerClasses[0] then
		g_Players[playerID].viewingintro = true
		g_Players[playerID].doingclasssel = true
		fadeCamera(player, true)
		setTimer(
			function()
				if not isElement(player) or getElementType(player) ~= 'player' then
					return
				end
				killPed(player)
				if procCallOnAll('OnPlayerRequestClass', playerID, 0) then
					putPlayerInClassSelection(player)
				else
					outputDebugString('Not allowed to select a class', 1)
				end
			end,
			5000,
			1
		)
	else
		setTimer(
			function()
				if not isElement(player) or getElementType(player) ~= 'player' then
					return
				end
				repeat until spawnPlayer(player, math.random(-20, 20), math.random(-20, 20), 3, math.random(0, 359), math.random(9, 288))
			end,
			5000,
			1
		)
	end
end

function joinHandler(player)
	local playerJoined = not player
	if playerJoined then
		player = source
	end
	
	local playerID = addElem(g_Players, player)
	clientCall(player, 'setAMXVersion', amxVersionString())
	clientCall(player, 'setPlayerID', playerID)
	
	-- Keybinds
	bindKey(player, 'F4', 'down', "changeclass")
	bindKey(player, 'enter_exit', 'down', removePedJetPack)
	g_Players[playerID].keys = {}
	local function bindControls(player, t)
		for samp,mta in pairs(t) do
			bindKey(player, mta, 'down', keyStateChange)
			bindKey(player, mta, 'up', keyStateChange)
		end
	end
	bindControls(player, g_KeyMapping)
	bindControls(player, g_LeftRightMapping)
	bindControls(player, g_UpDownMapping)
	
	if playerJoined then
		if getRunningGameMode() then
			gameModeInit(player)
		end
		if isWeaponSyncingNeeded() then
			clientCall(player, 'enableWeaponSyncing', true)
		end
		table.each(
			g_LoadedAMXs,
			function(amx)
				-- add amx clientside
				clientCall(player, 'addAMX', amx.name, amx.publics.OnGameModeInit and true)
				-- send textdraws
				for id,textdraw in pairs(amx.textdraws) do
					clientCall(player, 'TextDrawCreate', amx.name, id, table.deshadowize(textdraw, true))
				end
				-- send menus
				for i,menu in pairs(amx.menus) do
					clientCall(player, 'CreateMenu', amx.name, i, menu)
				end
				
				procCallInternal(amx, 'OnPlayerConnect', playerID)
			end
		)
	end
end
addEventHandler('onPlayerJoin', root, joinHandler)

function classSelKey(player)
	clientCall(player, 'displayFadingMessage', 'Returning to class selection after next death', 0, 200, 200)
	outputChatBox('* Returning to class selection after next death', player, 0, 220, 220)
	g_Players[getElemID(player)].returntoclasssel = true
end
addCommandHandler ( "changeclass", classSelKey )

function keyStateChange(player, key, state)
	local id = getElemID(player)
	g_Players[id].keys[key] = (state == 'down')
	if g_KeyMapping[key] then
		local oldState = g_Players[id].keys.old or 0
		local newState = buildKeyState(player, g_KeyMapping)
		g_Players[id].keys.old = newState
		procCallOnAll('OnPlayerKeyStateChange', id, newState, oldState)
	end
end

function buildKeyState(player, t)
	local keys = g_Players[getElemID(player)].keys
	local result = 0
	for samp,mta in pairs(t) do
		if type(mta) == 'table' then
			for i,key in ipairs(mta) do
				if keys[key] then
					result = result + samp
					break
				end
			end
		elseif keys[mta] then
			result = result + samp
		end
	end
	return result
end

function syncPlayerWeapons(player, weapons)
	g_Players[getElemID(player)].weapons = weapons
end

function putPlayerInClassSelection(player)
	if not isElement(player) then
		return
	end
	toggleAllControls(player, false, true, false)
	killPed(player)
	local playerID = getElemID(player)
	g_Players[playerID].viewingintro = nil
	g_Players[playerID].doingclasssel = true
	g_Players[playerID].selectedclass = g_Players[playerID].selectedclass or 0
	if g_Players[playerID].blip then
		setElementVisibleTo(g_Players[playerID].blip, root, false)
	end
	clientCall(player, 'startClassSelection', g_PlayerClasses)
	bindKey(player, 'arrow_l', 'down', requestClass, -1)
	bindKey(player, 'arrow_r', 'down', requestClass, 1)
	bindKey(player, 'lshift', 'down', requestSpawn)
	bindKey(player, 'rshift', 'down', requestSpawn)
	requestClass(player, false, false, 0)
end

function requestClass(player, btn, state, dir)
	local playerID = getElemID(player)
	local data = g_Players[playerID]
	data.selectedclass = data.selectedclass + dir
	if data.selectedclass > #g_PlayerClasses then
		data.selectedclass = 0
	elseif data.selectedclass < 0 then
		data.selectedclass = #g_PlayerClasses
	end
	local x, y, z = getElementPosition(player)
	if isPedDead(player) then
		spawnPlayer(player, x, y, z, getPedRotation(player), g_PlayerClasses[data.selectedclass][5], getElementInterior(player), playerID)
	else
		setElementModel(player, g_PlayerClasses[data.selectedclass][5])
	end
	clientCall(player, 'selectClass', data.selectedclass)
	procCallOnAll('OnPlayerRequestClass', playerID, data.selectedclass)
end

function requestSpawn(player, btn, state)
	local playerID = getElemID(player)
	if procCallOnAll('OnPlayerRequestSpawn', playerID) then
		unbindKey(player, 'arrow_l', 'down', requestClass)
		unbindKey(player, 'arrow_r', 'down', requestClass)
		unbindKey(player, 'lshift', 'down', requestSpawn)
		unbindKey(player, 'rshift', 'down', requestSpawn)
		spawnPlayerBySelectedClass(player)
	end
end

function spawnPlayerBySelectedClass(player, x, y, z, r)
	local playerID = getElemID(player)
	local playerdata = g_Players[playerID]
	playerdata.viewingintro = nil
	playerdata.doingclasssel = nil
	local spawninfo = playerdata.spawninfo or (g_PlayerClasses and g_PlayerClasses[playerdata.selectedclass])
	if not spawninfo then
		return
	end
	if x then
		spawninfo = table.shallowcopy(spawninfo)
		spawninfo[1], spawninfo[2], spawninfo[3], spawninfo[4] = x, y, z, r or spawninfo[4]
	end
	spawnPlayer(player, unpack(spawninfo))
	for i,weapon in ipairs(spawninfo.weapons) do
		giveWeapon(player, weapon[1], weapon[2], true)
	end
	clientCall(player, 'destroyClassSelGUI')
	if playerdata.blip then
		setElementVisibleTo(playerdata.blip, root, true)
	end
end

addEventHandler('onPlayerSpawn', root,
	function()
		local playerID = getElemID(source)
		local playerdata = g_Players[playerID]
		if playerdata.doingclasssel or playerdata.beingremovedfromvehicle then
			return
		end
		toggleAllControls(source, true)
		procCallOnAll('OnPlayerSpawn', playerID)
		setPlayerState(source, PLAYER_STATE_ONFOOT)
		playerdata.vehicle = nil
		playerdata.specialaction = SPECIAL_ACTION_NONE
	end
)

addEventHandler('onPlayerChat', root,
	function(msg, type)
		if type ~= 0 then
			return
		end
		cancelEvent()
		msg = tostring(msg)
		if not procCallOnAll('OnPlayerText', getElemID(source), msg) then
			return
		end
		
		local r, g, b = getPlayerNametagColor(source)
		
		if g_GlobalChatRadius then
			local x, y, z = getElementPosition(source)
			for i,data in pairs(g_Players) do
				if getDistanceBetweenPoints3D(x, y, z, getElementPosition(data.elem)) <= g_GlobalChatRadius then
					outputChatBox(getPlayerName(source) .. ':#FFFFFF ' .. msg:gsub('#%x%x%x%x%x%x', ''), data.elem, r, g, b, true)
				end
			end
		else
			outputChatBox(getPlayerName(source) .. ':#FFFFFF ' .. msg:gsub('#%x%x%x%x%x%x', ''), root, r, g, b, true)
		end
	end
)

addEventHandler('onPlayerDamage', root,
	function(attacker, weapon, body, loss)
		if not attacker or not isElement(attacker) or getElementType(attacker) ~= 'player' then
			return
		end
		if g_ServerVars.instagib then
			killPed(source)
		end
	end
)

addEventHandler('onPlayerWasted', root,
	function(ammo, killer, weapon, bodypart)
		local playerID = getElemID(source)
		if g_Players[playerID].doingclasssel then
			return
		end
		local killerID = killer and killer ~= source and getElemID(killer) or 255
		setPlayerState(source, PLAYER_STATE_WASTED)
		procCallOnAll('OnPlayerDeath', playerID, killerID, weapon)
		if g_Players[playerID].returntoclasssel then
			g_Players[playerID].returntoclasssel = nil
			setTimer(putPlayerInClassSelection, 3000, 1, source)
		else
			setTimer(spawnPlayerBySelectedClass, 3000, 1, source, false)
		end
		g_Players[playerID].vehicle = nil
		g_Players[playerID].specialaction = SPECIAL_ACTION_NONE
	end
)

addCommandHandler('kill',
	function(player)
		killPed(player)
	end
)

local quitReasons = {
	['Timed out'] = 0,
	Quit = 1,
	Kicked = 2
}
addEventHandler('onPlayerQuit', root,
	function(reason)
		local vehicle = getPedOccupiedVehicle(source)
		if vehicle then
			triggerEvent('onVehicleExit', vehicle, source)
		end
		for name,amx in pairs(g_LoadedAMXs) do
			amx.playerobjects[source] = nil
		end
		local playerID = getElemID(source)
		procCallOnAll('OnPlayerDisconnect', playerID, quitReasons[reason])
		if g_Players[playerID].blip then
			destroyElement(g_Players[playerID].blip)
		end
		g_Players[playerID] = nil
	end
)


-------------------------------
-- Vehicles

function respawnStaticVehicle(vehicle)
	if not isElement(vehicle) then
		return
	end
	local amx, vehID = getElemAMX(vehicle), getElemID(vehicle)
	if not amx or not amx.vehicles[vehID] then
		return
	end
	if isTimer(amx.vehicles[vehID].respawntimer) then
		killTimer(amx.vehicles[vehID].respawntimer)
	end
	amx.vehicles[vehID].respawntimer = nil
	local spawninfo = amx.vehicles[vehID].spawninfo
	spawnVehicle(vehicle, spawninfo.x, spawninfo.y, spawninfo.z, 0, 0, spawninfo.angle)
	procCallInternal(amx, 'OnVehicleSpawn', vehID)
end

addEventHandler('onVehicleEnter', root,
	function(player, seat, jacked)
		local vehID = getElemID(source)
		local amx = getElemAMX(source)
		if not amx then
			return
		end
		
		local playerID = getElemID(player)
		g_Players[playerID].vehicle = source
		setPlayerState(player, seat == 0 and PLAYER_STATE_DRIVER or PLAYER_STATE_PASSENGER)
		procCallInternal(amx, 'OnPlayerEnterVehicle', playerID, vehID, seat ~= 0 and 1 or 0)
		
		if amx.vehicles[vehID] and amx.vehicles[vehID].respawntimer then
			killTimer(amx.vehicles[vehID].respawntimer)
			amx.vehicles[vehID].respawntimer = nil
		end
	end
)

addEventHandler('onVehicleExit', root,
	function(player, seat, jacker)
		local amx = getElemAMX(source)
		local vehID = getElemID(source)
		if not amx then
			return
		end
		
		local playerID = getElemID(player)
		g_Players[playerID].vehicle = nil
		procCallInternal(amx, 'OnPlayerExitVehicle', playerID, vehID)
		setPlayerState(player, PLAYER_STATE_ONFOOT)
		
		for i=0,getVehicleMaxPassengers(source) do
			if getVehicleOccupant(source, i) then
				return
			end
		end
		if amx.vehicles[vehID] and amx.vehicles[vehID].respawntimer then
			killTimer(amx.vehicles[vehID].respawntimer)
			amx.vehicles[vehID].respawntimer = nil
		end
		amx.vehicles[vehID].respawntimer = setTimer(respawnStaticVehicle, amx.vehicles[vehID].respawndelay, 1, source)
	end
)

addEventHandler('onVehicleStartExit', root,
	function()
		if g_RCVehicles[getElementModel(source)] then
			cancelEvent()
		end
	end
)

addEventHandler('onVehicleExplode', root,
	function()
		local amx = getElemAMX(source)
		local vehID = getElemID(source)
		if not amx then
			return
		end
		
		procCallOnAll('OnVehicleDeath', vehID, 0)		-- NOES, MY VEHICLE DIED
		
		if amx.vehicles[vehID].respawntimer then
			killTimer(amx.vehicles[vehID].respawntimer)
			amx.vehicles[vehID].respawntimer = nil
		end
		amx.vehicles[vehID].respawntimer = setTimer(respawnStaticVehicle, amx.vehicles[vehID].respawndelay, 1, source)
	end
)

function getPedOccupiedVehicle(player)
	local data = g_Players[getElemID(player)]
	return data and data.vehicle
end

local _warpPlayerIntoVehicle = warpPedIntoVehicle
function warpPedIntoVehicle(player, vehicle, seat)
	g_Players[getElemID(player)].vehicle = vehicle
	_warpPlayerIntoVehicle(player, vehicle, seat)
end

function removePedFromVehicle(player)
	local playerdata = g_Players[getElemID(player)]
	if not playerdata.vehicle then
		return false
	end
	-- Built-in removePlayerFromVehicle is simply too unreliable
	local health, armor = getElementHealth(player), getPedArmor(player)
	local weapons, currentslot = playerdata.weapons, getPedWeaponSlot(player)
	playerdata.beingremovedfromvehicle = true
	local x, y, z = getElementPosition(playerdata.vehicle)
	local rx, ry, rz = getVehicleRotation(playerdata.vehicle)
	spawnPlayerBySelectedClass(player, x + 4*math.cos(math.rad(rz+180)), y + 4*math.sin(math.rad(rz+180)), z + 1, rz)
	playerdata.beingremovedfromvehicle = nil
	playerdata.vehicle = nil
	setElementHealth(player, health)
	setPedArmor(player, armor)
	if weapons then
		giveWeapons(player, weapons, currentslot)
	end
	return true
end

-------------------------------
-- Misc

addEventHandler('onPlayerPickupHit', root,
	function(pickup)
		if getElementType(source) ~= 'player' or not getElemID(pickup) then
			return
		end
		procCallOnAll('OnPlayerPickUpPickup', getElemID(source), getElemID(pickup))
		if getElementModel(pickup) == 370 then
			-- Jetpack pickup
			givePedJetPack(source)
		end
	end
)

addEventHandler('onConsole', root,
	function(cmd)
		cmd = '/' .. cmd:gsub('^([^%s]*)', g_CommandMapping)
		procCallOnAll('OnPlayerCommandText', getElemID(source), cmd)
	end
)
