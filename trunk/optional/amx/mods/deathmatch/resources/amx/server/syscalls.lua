function argsToMTA(amx, prototype, ...)
	if type(amx) == 'userdata' then
		local amxName = table.find(g_LoadedAMXs, 'cptr', amx)
		if not amxName then
			print('argsToMTA: No amx found for provided cptr')
			return 0
		end
		amx = g_LoadedAMXs[amxName]
	end
	
	local args = { ... }
	local val
	local argMissing = false
	local colorArgs
	for i,val in ipairs(args) do
		vartype = prototype[i]
		if vartype == 'b' then			-- boolean
			val = val ~= 0
		elseif vartype == 'c' then		-- color
			if not colorArgs then
				colorArgs = {}
			end
			colorArgs[i] = { binshr(val, 24), binshr(val, 16) % 0x100, binshr(val, 8) % 0x100 }		-- r, g, b
			val = val % 0x100			-- a
		elseif vartype == 'p' then		-- player
			val = g_Players[val] and g_Players[val].elem
		elseif vartype == 't' then		-- team
			val = val ~= 0 and g_Teams[val]
		elseif vartype == 'v' then		-- vehicle
			val = g_Vehicles[val] and g_Vehicles[val].elem
		elseif vartype == 'o' then		-- object
			val = g_Objects[val] and g_Objects[val].elem
		elseif vartype == 'u' then		-- pickup
			val = g_Pickups[val] and g_Pickups[val].elem
		elseif vartype == 'h' then		-- file handle
			val = amx.files[val]
		elseif vartype == 'x' then		-- textdraw
			val = amx.textdraws[val]
		elseif vartype == 'm' then		-- menu
			val = amx.menus[val]
		elseif vartype == 'g' then		-- gang zone
			val = amx.gangzones[val] and amx.gangzones[val].elem
		elseif vartype == 'd' then		-- database result
			val = amx.dbresults[val]
		end
		if val == nil then
			val = false
			argMissing = true
		end
		args[i] = val
	end
	if colorArgs then
		local indexOffset = 0
		for i,colorArg in pairs(colorArgs) do
			for j,color in ipairs(colorArg) do
				table.insert(args, i+j-1 + indexOffset, color)
			end
			indexOffset = indexOffset + 3
		end
	end
	
	return args, argMissing
end
local argsToMTA = argsToMTA

function argsToSAMP(amx, prototype, ...)
	if type(amx) == 'userdata' then
		local amxName = table.find(g_LoadedAMXs, 'cptr', amx)
		if not amxName then
			print('argsToSAMP: No amx found for provided cptr')
			return 0
		end
		amx = g_LoadedAMXs[amxName]
	end
	
	local args = { ... }
	for i,v in ipairs(args) do
		if type(v) == 'nil' then
			args[i] = 0
		elseif type(v) == 'boolean' then
			args[i] = v and 1 or 0
		elseif type(v) == 'string' then
			-- keep unmodified
		elseif type(v) == 'number' then
			if prototype[i] == 'f' then
				args[i] = float2cell(v)
			end
		elseif type(v) == 'userdata' then
			args[i] = isElement(v) and getElemID(v)
		else
			args[i] = 0
		end
	end
	return args
end

function syscall(amx, svc, prototype, ...)		-- svc = service number (= index in native functions table) or name of native function
	if type(amx) == 'userdata' then
		local amxName = table.find(g_LoadedAMXs, 'cptr', amx)
		if not amxName then
			return 0
		end
		amx = g_LoadedAMXs[amxName]
	end
	local fnName = type(svc) == 'number' and amx.natives[svc] or svc
	local fn = prototype.fn or _G[fnName]
	if not fn and not prototype.client then
		outputDebugString('syscall: function ' .. tostring(fn) .. 'doesn\'t exist', 1)
		return
	end

	local args, argMissing = argsToMTA(amx, prototype, ...)
	
	if argMissing then
		return 0
	end
	--[[
	local logstr = fnName .. '('
	for i,argval in ipairs(args) do
		if i > 1 then
			logstr = logstr .. ', '
		end
		logstr = logstr .. tostring(argval)
	end
	logstr = logstr .. ')'
	print(logstr)
	outputConsole(logstr)
	--]]

	local result
	if prototype.client then
		local player = table.remove(args, 1)
		clientCall(player, fnName, amx.name, unpack(args))
	else
		result = fn(amx, unpack(args))
		if type(result) == 'boolean' then
			result = result and 1 or 0
		end
	end
	--print('syscall returned ' .. tostring(result or 0))
	return result or 0
end

----------------------------------------------
--  Start of SA-MP API implementation

local skinReplace = {
	-- invalid skins
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[8] = 0,
	[42] = 0,
	[65] = 0,
	[74] = 0,
	[86] = 0,
	[119] = 0,
	[149] = 0,
	[208] = 0,
	[273] = 0,
	
	-- story skins
	[1] = 261,		-- The Truth
	[2] = 37,		-- Mack
	[265] = 284,	-- Police
	[266] = 281,	--  "
	[267] = 280,	--  "
	[268] = 72,		-- Paul
	[269] = 105,	-- Big Smoke
	[270] = 107,	-- Sweet
	[271] = 106,	-- Ryder
	[272] = 112,	-- Black jacket, white pants
	[290] = 57,		-- Rosenberg
	[291] = 111,	-- Jeans jacket, black pants
	[292] = 109,	-- Ese
	[293] = 83,		-- O.G. LOC
	[294] = 120,	-- Wuzi
	[295] = 165,	-- Toreno
	[296] = 249,	-- Pimp
	[297] = 24,		-- Madd Dog
	[298] = 192,	-- Cathalena
	[299] = 124		-- Claude
}

function AddMenuItem(amx, menu, column, caption)
	table.insert(menu.items[column], caption)
	clientCall(root, 'AddMenuItem', amx.name, menu.id, column, caption)
end

function AddPlayerClass(amx, skin, x, y, z, angle, weap1, weap1_ammo, weap2, weap2_ammo, weap3, weap3_ammo)
	return AddPlayerClassEx(amx, false, skin, x, y, z, angle, weap1, weap1_ammo, weap2, weap2_ammo, weap3, weap3_ammo)
end

function AddPlayerClassEx(amx, team, skin, x, y, z, angle, weap1, weap1_ammo, weap2, weap2_ammo, weap3, weap3_ammo)
	local id = table.insert0(
		g_PlayerClasses,
		{
			x, y, z, angle, skinReplace[skin] or skin, 0, 0, team,
			weapons={
				{weap1, weap1_ammo},
				{weap2, weap2_ammo},
				{weap3, weap3_ammo}
			}
		}
	)
	return id
end

function AddPlayerClothes(amx, player, type, index)
	local texture, model = getClothesByTypeIndex(type, index)
	addPedClothes(player, texture, model, type)
end

local function cancelPickup()
	cancelEvent()
end
function AddStaticPickup(amx, model, type, x, y, z)
	local mtaPickupType, mtaPickupAmount
	if model == 1240 then		-- health
		mtaPickupType = 0
		mtaPickupAmount = 100
	elseif model == 1242 then	-- armor
		mtaPickupType = 1
		mtaPickupAmount = 100
	else						-- weapon
		mtaPickupType = 2
		mtaPickupAmount = g_WeaponIDMapping[model]
		if not mtaPickupAmount then
			mtaPickupType = 3
			mtaPickupAmount = model
		end
	end
	local pickup = createPickup(x, y, z, mtaPickupType, mtaPickupAmount)
	if not pickup then
		outputDebugString('Failed to create pickup of model ' .. model, 2)
		return 0
	end
	if model == 1272 or model == 1273 then
		-- house pickups don't disappear on pickup
		addEventHandler('onPickupHit', pickup, cancelPickup, false)
	end
	return addElem(amx, 'pickups', pickup)
end

function AddStaticVehicle(amx, model, x, y, z, angle, color1, color2)
	return AddStaticVehicleEx(amx, model, x, y, z, angle, color1, color2, 120)
end

function AddStaticVehicleEx(amx, model, x, y, z, angle, color1, color2, respawnDelay)
	local vehicle = createVehicle(model, x, y, z, 0, 0, angle)
	if not g_PoliceVehicles[model] then
		setVehicleColor(vehicle, color1 >= 0 and color1 or math.random(0, 126), color2 >= 0 and color2 or math.random(0, 126), 0, 0)
	end
	local vehID = addElem(amx, 'vehicles', vehicle)
	if respawnDelay < 0 then
		respawnDelay = 120
	end
	amx.vehicles[vehID].respawndelay = respawnDelay*1000
	amx.vehicles[vehID].spawninfo = { x = x, y = y, z = z, angle = angle }
	return vehID
end

function AddVehicleComponent(amx, vehicle, upgradeID)
	addVehicleUpgrade(vehicle, upgradeID)
end

function AllowAdminTeleport(amx, allow)

end

function AllowInteriorWeapons(amx, allow)

end

function AllowPlayerTeleport(amx, player, allow)

end

function ApplyAnimation(amx, player, animLib, animName, fS, opt1, opt2, opt3, opt4, op5)
	setPedAnimation(player, animLib, animName, -1, opt1, opt2 or opt3)
end

function AttachObjectToPlayer(amx, object, player, offsetX, offsetY, offsetZ, rX, rY, rZ)
	attachElements(object, player, offsetX, offsetY, offsetZ, rX, rY, rZ)
end

function AttachTrailerToVehicle(amx, trailer, vehicle)
	attachTrailerToVehicle(vehicle, trailer)
end

function Ban(amx, player)
	banPlayer(player)
end

function BanEx(amx, player, reason)
	banPlayer(player, nil, reason)
end

function CallLocalFunction(amx, fnName, fmt, ...)
	local args = { ... }
	for i=1,math.min(#fmt, #args) do
		if fmt:sub(i, i) == 's' then
			args[i] = readMemString(amx, args[i])
		else
			args[i] = amx.memDAT[args[i]]
		end
	end
	return procCallInternal(amx, fnName, unpack(args))
end

function CallRemoteFunction(amx, fnName, fmt, ...)
	local args = { ... }
	for i=1,math.min(#fmt, #args) do
		if fmt:sub(i, i) == 's' then
			args[i] = readMemString(amx, args[i])
		else
			args[i] = amx.memDAT[args[i]]
		end
	end
	return procCallOnAll(fnName, unpack(args))
end

function ChangeVehicleColor(amx, vehicle, color1, color2)
	setVehicleColor(vehicle, color1, color2, 0, 0)
end

function ChangeVehiclePaintjob(amx, vehicle, paintjob)
	setVehiclePaintjob(vehicle, paintjob)
end

function ClearAnimations(amx, player)
	setPedAnimation(player, false)
	g_Players[getElemID(player)].specialaction = SPECIAL_ACTION_NONE
end

function CreateExplosion(amx, x, y, z, type, radius)
	createExplosion(x, y, z, type)
end

function CreateMenu(amx, title, columns, x, y, leftColumnWidth, rightColumnWidth)
	local menu = { title = title, x = x, y = y, leftColumnWidth = leftColumnWidth, rightColumnWidth = rightColumnWidth, items = { [0] = {}, [1] = {} } }
	local id = table.insert(amx.menus, menu)
	menu.id = id
	clientCall(root, 'CreateMenu', amx.name, id, menu)
	return id
end

function CreateObject(amx, model, x, y, z, rX, rY, rZ)
	outputConsole('CreateObject(' .. model .. ')')
	return addElem(amx, 'objects', createObject(model, x, y, z, rX, rY, rZ))
end

CreatePickup = AddStaticPickup

function CreatePlayerObject(amx, player, model, x, y, z, rX, rY, rZ)
	outputConsole('CreatePlayerObject(' .. model .. ')')
	if not amx.playerobjects[player] then
		amx.playerobjects[player] = {}
	end
	local objID = table.insert(amx.playerobjects[player], { x = x, y = y, z = z, rx = rX, ry = rY, rz = rZ })
	clientCall(player, 'CreatePlayerObject', amx.name, objID, model, x, y, z, rX, rY, rZ)
	return objID
end

CreateVehicle = AddStaticVehicleEx

function DestroyMenu(amx, menu)
	for i,playerdata in pairs(g_Players) do
		if playerdata.menu == menu then
			playerdata.menu = nil
		end
	end
	clientCall(root, 'DestroyMenu', amx.name, menu.id)
	amx.menus[menu.id] = nil
end

function DestroyObject(amx, object)
	removeElem(amx, 'objects', object)
	destroyElement(object)
end

function DestroyPickup(amx, pickup)
	removeElem(amx, 'pickups', pickup)
	destroyElement(pickup)
end

function DestroyPlayerObject(amx, player, objID)
	amx.playerobjects[player][objID] = nil
	clientCall(player, 'DestroyPlayerObject', amx.name, objID)
end

function DestroyVehicle(amx, vehicle)
	clientCall(root, 'DestroyVehicle', amx.name, getElemID(vehicle))
	removeElem(amx, 'vehicles', vehicle)
	destroyElement(vehicle)
end

function DetachTrailerFromVehicle(amx, puller)
	detachTrailerFromVehicle(puller)
end

function DisableInteriorEnterExits(amx)

end

function DisableMenu(amx, menuID)
	local menu = amx.menus[menuID]
	if not menu then
		return
	end
	menu.disabled = true
	for id,player in pairs(g_Players) do
		if GetPlayerMenu(amx, player.elem) == menuID then
			clientCall(player.elem, 'HideMenuForPlayer', amx.name, menuID)
		end
	end
end

function DisableMenuRow(amx, menuID, rowID)
	local menu = amx.menus[menuID]
	if not menu then
		return
	end
	clientCall(root, 'DisableMenuRow', amx.name, menuID, rowID)
end

function DisablePlayerCheckpoint(amx, player)
	g_Players[getElemID(player)].checkpoint = nil
	clientCall(player, 'DisablePlayerCheckpoint')
end

function DisablePlayerRaceCheckpoint(amx, player)
	g_Players[getElemID(player)].racecheckpoint = nil
	clientCall(player, 'DisablePlayerRaceCheckpoint')
end

function EnableStuntBonusForAll(amx, enable)

end

function EnableStuntBonusForPlayer(amx, player, enable)

end

function EnableTirePopping(amx, enable)

end

function EnableZoneNames(amx, enable)
	g_ShowZoneNames = enable
	for i,data in pairs(g_Players) do
		showPlayerHudComponent(data.elem, 'area_name', enable)
	end
end

function ForceClassSelection(amx, playerID)
	if not g_Players[playerID] then
		return
	end
	g_Players[playerID].returntoclasssel = true
end

function GameModeExit(amx)
	if getResourceState(getResourceFromName('mapcycler')) == 'running' then
		triggerEvent('onRoundFinished', getResourceRootElement(getThisResource()))
	else
		exports.votemanager:voteMap(getThisResource())
	end
end

function GameTextForAll(amx, str, time, style)
	str = str:lower()
	for mta,samp in pairs(g_CommandMapping) do
		str = str:gsub('/' .. samp, '/' .. mta)
	end
	for i,player in pairs(g_Players) do
		GameTextForPlayer(amx, player.elem, str, time, style)
	end
end

function GameTextForPlayer(amx, player, str, time, style)
	str = str:lower()
	for mta,samp in pairs(g_CommandMapping) do
		str = str:gsub('/' .. samp, '/' .. mta)
	end
	clientCall(player, 'GameTextForPlayer', amx.name, str, time, style)
end

function GangZoneCreate(amx, minX, minY, maxX, maxY)
	local zone = createRadarArea(minX + (maxX - minX)/2, minY + (maxY - minY)/2, maxX - minX, maxY - minY)
	local id = addElem(amx, 'gangzones', zone)
	setElementVisibleTo(zone, root, false)
	return id
end

function GangZoneDestroy(amx, zone)
	removeElem(amx, 'gangzones', zone)
	destroyElement(zone)
end

function GangZoneShowForPlayer(amx, player, zone, r, g, b, a)
	setRadarAreaColor(zone, r, g, b, a)
	setElementVisibleTo(zone, player, true)
end

function GangZoneShowForAll(amx, zone, r, g, b, a)
	setRadarAreaColor(zone, r, g, b, a)
	setElementVisibleTo(zone, root, true)
end

function GangZoneHideForPlayer(amx, player, zone)
	setElementVisibleTo(zone, player, false)
end

function GangZoneHideForAll(amx, zone)
	setElementVisibleTo(zone, root, false)
end

function GangZoneFlashForPlayer(amx, player, zone, r, g, b, a)
	clientCall(player, 'setRadarAreaFlashing', zone, true)
end

function GangZoneFlashForAll(amx, zone, r, g, b, a)
	setRadarAreaFlashing(zone, true)
end

function GangZoneStopFlashForPlayer(amx, player, zone)
	clientCall(player, 'setRadarAreaFlashing', zone, false)
end

function GangZoneStopFlashForAll(amx, zone)
	setRadarAreaFlashing(zone, false)
end

function GetMaxPlayers(amx)
	return getMaxPlayers()
end

function GetObjectPos(amx, object, refX, refY, refZ)
	local x, y, z = getElementPosition(object)
	writeMemFloat(amx, refX, x)
	writeMemFloat(amx, refY, y)
	writeMemFloat(amx, refZ, z)
end

function GetObjectRot(amx, object, refX, refY, refZ)
	local rX, rX, rZ = getObjectRotation(object)
	writeMemFloat(amx, refX, rX)
	writeMemFloat(amx, refY, rY)
	writeMemFloat(amx, refZ, rZ)
end

function GetPlayerAmmo(amx, player)
	return getPlayerTotalAmmo(player)
end

function GetPlayerArmour(amx, player, refArmor)
	writeMemFloat(amx, refArmor, getPedArmor(player))
end

function GetPlayerColor(amx, player)
	local r, g, b = getPlayerNametagColor(player)
	return color2cell(r, g, b)
end

function GetPlayerClothes(amx, player, type)
	local texture, model = getPedClothes(player, type)
	if not texture then
		return
	end
	local type, index = getTypeIndexFromClothes(texture, model)
	return index
end

function GetPlayerFacingAngle(amx, player, refRot)
	writeMemFloat(amx, refRot, getPedRotation(player))
end

function GetPlayerHealth(amx, player, refHealth)
	writeMemFloat(amx, refHealth, getElementHealth(player))
end

function GetPlayerInterior(amx, player)
	return getElementInterior(player)
end

function GetPlayerIp(amx, player, refName, len)
	local ip = getClientIP(player)
	if #ip < len then
		writeMemString(amx, refName, ip)
	end
end

function GetPlayerKeys(amx, player, refKeys, refUpDown, refLeftRight)
	amx.memDAT[refKeys] = buildKeyState(player, g_KeyMapping)
	amx.memDAT[refUpDown] = buildKeyState(player, g_UpDownMapping)
	amx.memDAT[refLeftRight] = buildKeyState(player, g_LeftRightMapping)
end

function GetPlayerMenu(amx, player)
	local playerdata = g_Players[getElemID(player)]
	return playerdata.menu and playerdata.menu.id or 0
end

function GetPlayerMoney(amx, player)
	return getPlayerMoney(player)
end

function GetPlayerName(amx, player, nameBuf, bufSize)
	local name = getClientName(player)
	if #name <= bufSize then
		writeMemString(amx, nameBuf, name)
	end
end

local function getPlayerObjectPos(amx, player, objID)
	local obj = amx.playerobjects[player] and amx.playerobjects[player][objID]
	if not obj then
		return false
	end
	
	if obj.moving then
		local curtick = getTickCount()
		if curtick >= obj.moving.starttick + obj.moving.duration then
			obj.x, obj.y, obj.z = obj.moving.x, obj.moving.y, obj.moving.z
			obj.moving = nil
			x, y, z = obj.x, obj.y, obj.z
		else
			local factor = (curtick - obj.moving.starttick)/obj.moving.duration
			x = obj.x + (obj.moving.x - obj.x)*factor
			y = obj.y + (obj.moving.y - obj.y)*factor
			z = obj.z + (obj.moving.z - obj.z)*factor
		end
	else
		x, y, z = obj.x, obj.y, obj.z
	end
	return x, y, z
end

function GetPlayerObjectPos(amx, player, objID, refX, refY, refZ)
	local x, y, z = getPlayerObjectPos(amx, player, objID)
	if not x then
		return
	end
	writeMemFloat(amx, refX, x)
	writeMemFloat(amx, refY, y)
	writeMemFloat(amx, refZ, z)
end

function GetPlayerObjectRot(amx, player, objID, refX, refY, refZ)
	local obj = amx.playerobjects[player] and amx.playerobjects[player][objID]
	if not obj then
		return
	end
	writeMemFloat(amx, refX, obj.rx)
	writeMemFloat(amx, refY, obj.ry)
	writeMemFloat(amx, refZ, obj.rz)
end

function GetPlayerPing(amx, player)
	return getPlayerPing(player)
end

GetPlayerPos = GetObjectPos

function GetPlayerScore(amx, player)
	return getElementData(player, 'Score')
end

function GetPlayerSkin(amx, player)
	return getPlayerSkin(player)
end

function GetPlayerSpecialAction(amx, player)
	if doesPlayerHaveJetPack(player) then
		return SPECIAL_ACTION_USEJETPACK
	else
		return g_Players[getElemID(player)].specialaction or SPECIAL_ACTION_NONE
	end
end

function GetPlayerState(amx, player)
	return getPlayerState(player)
end

function GetPlayerTeam(amx, player)
	return table.find(g_Teams, getPlayerTeam(player))
end

function GetPlayerTime(amx, player, refHour, refMinute)
	amx.memDAT[refHour], amx.memDAT[refMinute] = getTime()
end

function GetPlayerVehicleID(amx, player)
	local vehicle = getPedOccupiedVehicle(player)
	if not vehicle then
		return 0
	end
	return getElemID(vehicle)
end

function GetPlayerVirtualWorld(amx, player)
	return getElementDimension(player)
end

function GetPlayerWantedLevel(amx, player)
	return getPlayerWantedLevel(player)
end

function GetPlayerWeapon(amx, player)
	return getPlayerWeapon(player)
end

function GetPlayerWeaponData(amx, player, slot, refWeapon, refAmmo)
	local playerdata = g_Players[getElemID(player)]
	local weapon = playerdata.weapons and playerdata.weapons[slot]
	if weapon then
		amx.memDAT[refWeapon], amx.memDAT[refAmmo] = weapon.id, weapon.ammo
	end
end

function GetServerVarAsBool(amx, varname)
	return get('amx.' .. varname) and true
end

function GetServerVarAsInt(amx, varname)
	local val = get('amx.' .. varname)
	return val and tonumber(val)
end

function GetServerVarAsString(amx, varname, buf, buflen)
	local val = get('amx.' .. varname)
	writeMemString(amx, buf, val and #val < buflen and val or '')
end

local serverStartTick = getTickCount()
function GetTickCount(amx)
	return getTickCount() - serverStartTick
end

function GetVehicleHealth(amx, vehicle, refHealth)
	writeMemFloat(amx, refHealth, getElementHealth(vehicle))
end

function GetVehicleModel(amx, vehicle)
	return getElementModel(vehicle)
end

GetVehiclePos = GetObjectPos

function GetVehicleTrailer(amx, vehicle)
	local trailer = getVehicleTowedByVehicle(vehicle)
	if not trailer then
		return 0
	end
	return getElemID(trailer)
end

function GetVehicleVelocity(amx, vehicle, refVX, refVY, refVZ)
	local vx, vy, vz = getElementVelocity(vehicle)
	writeMemFloat(amx, refVX, vx)
	writeMemFloat(amx, refVY, vy)
	writeMemFloat(amx, refVZ, vz)
end

function GetVehicleVirtualWorld(amx, vehicle)
	return getElementDimension(vehicle)
end

function GetVehicleZAngle(amx, vehicle, refZ)
	local rX, rY, rZ = getVehicleRotation(vehicle)
	writeMemFloat(amx, refZ, rZ)
end

function GetWeaponName(amx, weaponID, buf, len)
	local name = getWeaponNameFromID(weaponID)
	if #name < len then
		writeMemString(amx, buf, name)
	end
end

function GivePlayerMoney(amx, player, amount)
	givePlayerMoney(player, amount)
end

function GivePlayerWeapon(amx, player, weaponID, ammo)
	giveWeapon(player, weaponID, ammo, true)
end

function HideMenuForPlayer(amx, menu, player)
	clientCall(player, 'HideMenuForPlayer', amx.name, menu.id)
	g_Players[getElemID(player)].menu = nil
end

function IsPlayerAdmin(amx, player)
	return isPlayerInACLGroup(player, 'Admin') or isPlayerInACLGroup(player, 'Console')
end

function IsPlayerConnected(amx, playerID)
	return g_Players[playerID] ~= nil
end

function IsPlayerInAnyVehicle(amx, player)
	return getPedOccupiedVehicle(player) and true
end

function IsPlayerInCheckpoint(amx, player)
	local playerdata = g_Players[getElemID(player)]
	if not playerdata.checkpoint then
		return false
	end
	local x, y = getElementPosition(player)
	return math.sqrt((playerdata.checkpoint.x - x)^2 + (playerdata.checkpoint.y - y)^2) <= playerdata.checkpoint.radius
end

function IsPlayerInRaceCheckpoint(amx, player)
	local playerdata = g_Players[getElemID(player)]
	if not playerdata.racecheckpoint then
		return false
	end
	local x, y = getElementPosition(player)
	return math.sqrt((playerdata.racecheckpoint.x - x)^2 + (playerdata.racecheckpoint.y - y)^2) <= playerdata.racecheckpoint.radius
end

function IsPlayerInVehicle(amx, player, vehicle)
	return getPedOccupiedVehicle(player) == vehicle
end

function IsPluginLoaded(amx, pluginName)
	return amxIsPluginLoaded(pluginName)
end

function IsTrailerAttachedToVehicle(amx, vehicle)
	return getVehicleTowedByVehicle(vehicle) ~= false
end

function IsValidMenu(amx, menuID)
	return amx.menus[menuID] ~= nil
end

function IsValidObject(amx, objID)
	return g_Objects[objID] ~= nil
end

function IsValidPlayerObject(amx, player, objID)
	return amx.playerobjects[player] and amx.playerobjects[player][objID] and true
end

function Kick(amx, player)
	kickPlayer(player)
end

function KillTimer(amx, timerID)
	if not amx.timers[timerID] then
		return
	end
	killTimer(amx.timers[timerID])
	amx.timers[timerID] = nil
end

function LimitGlobalChatRadius(amx, radius)
	if radius > 0 then
		g_GlobalChatRadius = radius
	end
end

function LinkVehicleToInterior(amx, vehicle, interior)
	setElementInterior(vehicle, interior)
end

function MoveObject(amx, object, x, y, z, speed)
	local distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(object))
	local time = distance/speed*1000
	moveObject(object, time, x, y, z, 0, 0, 0)
	setTimer(procCallOnAll, time, 1, 'OnObjectMoved', getElemID(object))
end

function MovePlayerObject(amx, player, objID, x, y, z, speed)
	local obj = amx.playerobjects[player] and amx.playerobjects[player][objID]
	if not obj then
		return
	end
	local distance = getDistanceBetweenPoints3D(x, y, z, getPlayerObjectPos(amx, player, objID))
	local duration = distance/speed*1000
	if obj.moving and isTimer(obj.moving.timer) then
		killTimer(obj.moving.timer)
	end
	local timer = setTimer(procCallInternal, duration, 1, amx.name, 'OnPlayerObjectMoved', getElemID(player), objID)
	obj.moving = { x = x, y = y, z = z, starttick = getTickCount(), duration = duration, timer = timer }
	clientCall(player, 'MovePlayerObject', amx.name, objID, x, y, z, speed)
end

function PlayerPlaySound(amx, player, soundID, x, y, z)
	
end

function PlayerSpectatePlayer(amx, player, playerToSpectate, mode)
	setCameraTarget(player, playerToSpectate)
end

function PlayerSpectateVehicle(amx, player, vehicleToSpectate, mode)
	if getVehicleController(vehicleToSpectate) then
		setCameraTarget(player, getVehicleController(vehicleToSpectate))
	else
		clientCall(player, 'setCameraTarget', vehicleToSpectate)
	end
end

function PutPlayerInVehicle(amx, player, vehicle, seat)
	warpPlayerIntoVehicle(player, vehicle, seat)
	if g_RCVehicles[getElementModel(vehicle)] then
		setElementAlpha(player, 0)
	end
	setPlayerState(player, seat == 0 and PLAYER_STATE_DRIVER or PLAYER_STATE_PASSENGER)
end

function RemovePlayerClothes(amx, player, type)
	removePedClothes(player, type)
end

function RemovePlayerFromVehicle(amx, player)
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		removePlayerFromVehicle(player)
		if g_RCVehicles[getElementModel(vehicle)] then
			clientCall(root, 'setElementAlpha', player, 255)
		end
	end
	setPlayerState(player, PLAYER_STATE_ONFOOT)
end

function RemoveVehicleComponent(amx, vehicle, upgradeID)
	removeVehicleUpgrade(vehicle, upgrade)
end

function ResetPlayerMoney(amx, player)
	setPlayerMoney(player, 0)
end

function ResetPlayerWeapons(amx, player)
	takeAllWeapons(player)
end

function SendClientMessage(amx, player, r, g, b, a, message)
	if message:len() > 75 and message:match('^%-+$') then
		message = ('-'):rep(75)
	elseif message:len() > 43 and message:match('^_+$') then
		message = ('_'):rep(43)
	elseif message:len() > 44 and message:match('^%*+$') then
		message = ('*'):rep(44)
	else
		for mta,samp in pairs(g_CommandMapping) do
			message = message:gsub('/' .. samp, '/' .. mta)
		end
	end
	outputChatBox(message, player, r, g, b)
end

function SendClientMessageToAll(amx, r, g, b, a, message)
	if (amx.proc == 'OnPlayerConnect' and message:match('joined')) or (amx.proc == 'OnPlayerDisconnect' and message:match('left')) then
		return
	end
	for i,data in pairs(g_Players) do
		SendClientMessage(amx, data.elem, r, g, b, a, message)
	end
end

function SendDeathMessage(amx, killer, victim, reason)
	-- no implementation needed, killmessages resource shows kills already
end

function SendPlayerMessageToAll(amx, sender, message)
	outputChatBox(getClientName(sender) .. ' ' .. message, root, 255, 255, 255)
end

function SendPlayerMessageToPlayer(amx, playerTo, playerFrom, message)
	outputChatBox(getClientName(playerFrom) .. ' ' .. message, playerTo, 255, 255, 255)
end

function SendRconCommand(amx, command)
	print(doRCON(command))
end

function SetCameraBehindPlayer(amx, player)
	setCameraTarget(player, player)
end

function SetDeathDropAmount(amx, amount)
	
end

function SetDisabledWeapons(amx, ...)

end

function SetEchoDestination(amx)
	
end

function SetGameModeText(amx, gamemodeName)
	setMapName(gamemodeName)
end

function SetGravity(amx, gravity)
	setGravity(gravity)
	table.each(g_Players, 'elem', setPedGravity, gravity)
end

function SetMenuColumnHeader(amx, menu, column, text)
	menu.items[column][13] = text
	clientCall(root, 'SetMenuColumnHeader', amx.name, menu.id, column, text)
end

function SetNameTagDrawDistance(amx, distance)
	
end

function SetObjectPos(amx, object, x, y, z)
	setElementPosition(object, x, y, z)
end

function SetObjectRot(amx, object, rX, rY, rY)
	setObjectRotation(object, rX, rY, rZ)
end

function SetPlayerAmmo(amx, player, slot, ammo)
	setWeaponAmmo(player, slot, ammo)
end

function SetPlayerArmour(amx, player, armor)
	setPlayerArmor(player, armor)
end

function SetPlayerCameraLookAt(amx, player, lx, ly, lz)
	fadeCamera(player, true)
	local x, y, z = getCameraMatrix(player)
	setCameraMatrix(player, x, y, z, lx, ly, lz)
end

function SetPlayerCameraPos(amx, player, x, y, z)
	fadeCamera(player, true)
	setCameraMatrix(player, x, y, z)
end

function SetPlayerCheckpoint(amx, player, x, y, z, size)
	g_Players[getElemID(player)].checkpoint = { x = x, y = y, z = z, radius = size }
	clientCall(player, 'SetPlayerCheckpoint', x, y, z, size)
end

function SetPlayerColor(amx, player, r, g, b)
	setPlayerNametagColor(player, r, g, b)
	if g_ShowPlayerMarkers then
		setBlipColor(g_Players[getElemID(player)].blip, r, g, b, 255)
	end
end

function SetPlayerDisabledWeapons(amx, player, ...)
	
end

function SetPlayerFacingAngle(amx, player, angle)
	setPedRotation(player, angle)
end

function SetPlayerGravity(amx, player, gravity)
	setPlayerGravity(player, gravity)
end

function SetPlayerHealth(amx, player, health)
	setElementHealth(player, health)
end

function SetPlayerInterior(amx, player, interior)
	if g_Players[getElemID(player)].viewingintro then
		return
	end
	setElementInterior(player, interior)
end

function SetPlayerObjectPos(amx, player, objID, x, y, z)
	local obj = amx.playerobjects[player] and amx.playerobjects[player][objID]
	if not obj then
		return
	end
	if obj.moving then
		if isTimer(obj.moving.timer) then
			killTimer(obj.moving.timer)
		end
		obj.moving = nil
	end
	obj.x, obj.y, obj.z = x, y, z
	clientCall(player, 'SetPlayerObjectPos', amx.name, objID, x, y, z)
end

function SetPlayerObjectRot(amx, player, objID, rX, rY, rZ)
	local obj = amx.playerobjects[player] and amx.playerobjects[player][objID]
	if not obj then
		return
	end
	obj.rx, obj.ry, obj.rz = rX, rY, rZ
	clientCall(player, 'SetPlayerObjectRot', amx.name, objID, rX, rY, rZ)
end

function SetPlayerName(amx, player, name)
	setClientName(player, name)
end

function SetPlayerPos(amx, player, x, y, z)
	setElementPosition(player, x, y, z)
end

function SetPlayerRaceCheckpoint(amx, player, type, x, y, z, nextX, nextY, nextZ, size)
	g_Players[getElemID(player)].racecheckpoint = { type = type, x = x, y = y, z = z, radius = size }
	clientCall(player, 'SetPlayerRaceCheckpoint', type, x, y, z, nextX, nextY, nextZ, size)
end

function SetPlayerScore(amx, player, score)
	setElementData(player, 'Score', score)
end

function SetPlayerSkin(amx, player, skin)
	setPlayerSkin(player, skinReplace[skin] or skin)
end

function SetPlayerSpecialAction(amx, player, actionID)
	if actionID == SPECIAL_ACTION_NONE then
		removePlayerJetPack(player)
		setPedAnimation(player, false)
	elseif actionID == SPECIAL_ACTION_USEJETPACK then
		givePlayerJetPack(player)
	elseif g_SpecialActions[actionID] then
		setPedAnimation(player, unpack(g_SpecialActions[actionID]))
	end
	g_Players[getElemID(player)].specialaction = actionID
end

function SetPlayerTeam(amx, player, team)
	setPlayerTeam(player, team)
end

function SetPlayerTime(amx, player, hours, minutes)
	clientCall(player, 'setTime', hours, minutes)
end

function SetPlayerVirtualWorld(amx, player, dimension)
	setElementDimension(player, dimension)
end

function SetPlayerWantedLevel(amx, player, level)
	setPlayerWantedLevel(player, level)
end

function SetPlayerWeather(amx, player, weatherID)
	clientCall(player, 'setWeather', weatherID % 256)
end

function SetSpawnInfo(amx, player, team, skin, x, y, z, angle, weap1, weap1_ammo, weap2, weap2_ammo, weap3, weap3_ammo)
	g_Players[getElemID(player)].spawninfo = {
		x, y, z, angle, skinReplace[skin] or skin, 0, 0, team,
		weapons={ {weap1, weap1_ammo}, {weap2, weap2_ammo}, {weap3, weap3_ammo} }
	}
end

function SetTeamCount(amx, count)

end

function SetTimerEx(amx, fnName, interval, repeating, fmt, ...)
	local vals = { ... }
	for i,val in ipairs(vals) do
		if fmt:sub(i, i) == 's' then
			vals[i] = readMemString(amx, val)
		else
			vals[i] = amx.memDAT[val]
		end
	end
	
	if repeating then
		local timer = setTimer(procCallInternal, interval, 0, amx.name, fnName, unpack(vals))
		return table.insert(amx.timers, timer)
	else
		local id = table.insert(amx.timers, false)
		local timer = setTimer(
			function(id, ...)
				amx.timers[id] = nil
				procCallInternal(amx, fnName, ...)
			end,
			interval, 1, id, unpack(vals)
		)
		amx.timers[id] = timer
		return id
	end
end

SetTimer = SetTimerEx

function SetVehicleHealth(amx, vehicle, health)
	setElementHealth(vehicle, health)
end

function SetVehicleModel(amx, vehicle, model)
	setElementModel(vehicle, model)
end

function SetVehicleNumberPlate(amx, vehicle, plate)
	
end

function SetVehicleParamsForPlayer(amx, vehicle, player, isObjective, doorsLocked)
	clientCall(player, 'SetVehicleParamsForPlayer', vehicle, isObjective, doorsLocked)
end

SetVehiclePos = SetObjectPos

function SetVehicleToRespawn(amx, vehicle)
	for seat=0,getVehicleMaxPassengers(vehicle) do
		local player = getVehicleOccupant(vehicle, seat)
		if player then
			removePlayerFromVehicle(player)
		end
	end
	local spawninfo = g_Vehicles[getElemID(vehicle)].spawninfo
	spawnVehicle(vehicle, spawninfo.x, spawninfo.y, spawninfo.z, 0, 0, spawninfo.angle)
end

function SetVehicleVelocity(amx, vehicle, vx, vy, vz)
	setElementVelocity(vehicle, vx, vy, vz)
end

function SetVehicleVirtualWorld(amx, vehicle, dimension)
	setElementDimension(vehicle, dimension)
end

function SetVehicleZAngle(amx, vehicle, rZ)
	local rX, rY = getVehicleRotation(vehicle)
	setVehicleRotation(vehicle, rX, rY, rZ)
end

function SetWeather(amx, weatherID)
	setWeather(weatherID % 256)
end

function SetWorldTime(amx, hours)
	setTime(hours, 0)
end

function ShowMenuForPlayer(amx, menu, player)
	clientCall(player, 'ShowMenuForPlayer', amx.name, menu.id)
	g_Players[getElemID(player)].menu = menu
end

function ShowNameTags(amx, show)
	table.each(g_Players, 'elem', setPlayerNametagShowing, show)
end

function ShowPlayerMarker(amx, player, show)
	local data = g_Players[getElemID(player)]
	if not show and data.blip then
		destroyElement(data.blip)
		data.blip = nil
	elseif show and not data.blip then
		local r, g, b = getPlayerNametagColor(player)
		data.blip = createBlipAttachedTo(player, 0, 2, r, g, b)
	end
end

function ShowPlayerMarkers(amx, show)
	g_ShowPlayerMarkers = show
	for i,data in pairs(g_Players) do
		ShowPlayerMarker(amx, data.elem, show)
	end
end

function ShowPlayerNameTagForPlayer(amx, player, playerToShow, show)
	clientCall(player, 'setPlayerNametagShowing', playerToShow, show)
end

function SpawnPlayer(amx, player)
	spawnPlayerBySelectedClass(player)
end

function StopObject(amx, object)
	stopObject(object)
end

function StopPlayerObject(amx, player, objID)
	local obj = amx.playerobjects[player] and amx.playerobjects[player][objID]
	if not obj then
		return
	end
	if obj.moving then
		obj.x, obj.y, obj.z = getPlayerObjectPos(amx, player, objID)
		if isTimer(obj.moving.timer) then
			killTimer(obj.moving.timer)
		end
		obj.moving = nil
	end
	clientCall(player, 'StopPlayerObject', amx.name, objID)
end

function TextDrawAlignment(amx, textdraw, align)
	textdraw.align = (align == 0 and 1 or align)
end

function TextDrawBackgroundColor(amx, textdraw, r, g, b, a)
	textdraw.outlinecolor = { r, g, b, a }
end

function TextDrawBoxColor(amx, textdraw, r, g, b, a)
	textdraw.boxcolor = { r, g, b, a }
end

function TextDrawColor(amx, textdraw, r, g, b, a)
	textdraw.color = { r, g, b }
end

function TextDrawCreate(amx, x, y, text)
	local textdraw = { x = x/640, y = y/480, shadow = {align=1, text=text, font=1, lsize=0.5} }
	local id = table.insert(amx.textdraws, textdraw)
	setmetatable(
		textdraw,
		{
			__index = textdraw.shadow,
			__newindex = function(t, k, v)
				local different
				if not t.shadow[k] then
					different = true
				else
					if type(v) == 'table' then
						different = not table.cmp(v, t.shadow[k])
					else
						different = v ~= t.shadow[k]
					end
				end
				if different then
					clientCall(root, 'TextDrawPropertyChanged', amx.name, id, k, v)
					t.shadow[k] = v
				end
			end
		}
	)
	clientCall(root, 'TextDrawCreate', amx.name, id, table.deshadowize(textdraw, true))
	return id
end

function TextDrawDestroy(amx, textdrawID)
	if not amx.textdraws[textdrawID] then
		return
	end
	clientCall(root, 'TextDrawDestroy', amx.name, textdrawID)
	amx.textdraws[textdrawID] = nil
end

function TextDrawFont(amx, textdraw, font)
	textdraw.font = font
end

function TextDrawHideForAll(amx, textdrawID)
	for id,player in pairs(g_Players) do
		TextDrawHideForPlayer(amx, player.elem, textdrawID)
	end
end

function TextDrawHideForPlayer(amx, player, textdrawID)
	local textdraw = amx.textdraws[textdrawID]
	local playerdata = g_Players[getElemID(player)]
	playerdata.visibletextdraws = playerdata.visibletextdraws or {}
	if not textdraw or not playerdata.visibletextdraws[textdraw] then
		return
	end
	clientCall(player, 'TextDrawHideForPlayer', amx.name, textdrawID)
	playerdata.visibletextdraws[textdraw] = nil
end

function TextDrawLetterSize(amx, textdraw, width, height)
	textdraw.lsize = width
end

function TextDrawSetOutline(amx, textdraw, size)
	textdraw.outlinesize = size
end

function TextDrawSetProportional(amx, textdraw, proportional)

end

function TextDrawSetShadow(amx, textdraw, size)
	textdraw.shade = size
end

function TextDrawSetString(amx, textdraw, str)
	textdraw.text = str
end

function TextDrawShowForAll(amx, textdrawID)
	for id,player in pairs(g_Players) do
		TextDrawShowForPlayer(amx, player.elem, textdrawID)
	end
end

function TextDrawShowForPlayer(amx, player, textdrawID)
	local textdraw = amx.textdraws[textdrawID]
	local playerdata = g_Players[getElemID(player)]
	playerdata.visibletextdraws = playerdata.visibletextdraws or {}
	if not textdraw or playerdata.visibletextdraws[textdraw] then
		return
	end
	clientCall(player, 'TextDrawShowForPlayer', amx.name, textdrawID)
	playerdata.visibletextdraws[textdraw] = true
end

function TextDrawTextSize(amx, textdraw, x, y)
	textdraw.boxsize = { x/640, y/480 }
end

function TextDrawUseBox(amx, textdraw, usebox)
	textdraw.usebox = usebox
end

function TogglePlayerControllable(amx, player, enable)
	toggleAllControls(player, enable, true, false)
end

function TogglePlayerSpectating(amx, player, enable)
	if enable then
		fadeCamera(player, true)
		setCameraMatrix(player, 75.461357116699, 64.600051879883, 51.685581207275, 149.75857543945, 131.53228759766, 40.597320556641)
		showPlayerHudComponent(player, 'radar', false)
	else
		if isPlayerDead(player) then
			spawnPlayerBySelectedClass(player)
		end
		setCameraTarget(player, player)
		showPlayerHudComponent(player, 'radar', true)
	end
end

function UsePlayerPedAnims(amx)

end



function acos(amx, f)
	return float2cell(math.acos(f))
end

function asin(amx, f)
	return float2cell(math.asin(f))
end

function atan(amx, f)
	return float2cell(math.atan(f))
end

function atan2(amx, x, y)
	return float2cell(math.atan2(y, x))
end

function db_close(amx, db)
	sqlite3CloseDB(amx.cptr, db)
end

function db_free_result(amx, dbResultID)
	amx.dbresults[dbResultID] = nil
end

function db_field_name(amx, dbresult, fieldIndex, outbuf, maxlength)
	local colname = dbresult.columns[fieldIndex+1]
	if #colname < maxlength then
		writeMemString(amx, outbuf, colname)
		return true
	end
	return false
end

function db_get_field(amx, dbresult, fieldIndex, outbuf, maxlength)
	if dbresult[dbresult.row] then
		local data = dbresult[dbresult.row][fieldIndex+1]
		if #data < maxlength then
			writeMemString(amx, outbuf, data)
			return true
		end
	end
	return false
end

function db_get_field_assoc(amx, dbresult, fieldName, outbuf, maxlength)
	local fieldIndex = table.find(dbresult.columns, fieldName)
	return fieldIndex and db_get_field(amx, dbresult, fieldIndex-1, outbuf, maxlength)
end

function db_next_row(amx, dbresult)
	dbresult.row = dbresult.row + 1
end

function db_num_fields(amx, dbresult)
	return #dbresult.columns
end

function db_num_rows(amx, dbresult)
	return #dbresult
end

function db_open(amx, dbName)
	return sqlite3OpenDB(amx.cptr, dbName)
end

function db_query(amx, db, query)
	local dbresult = sqlite3Query(amx.cptr, db, query)
	if type(dbresult) == 'table' then
		dbresult.row = 1
		return table.insert(amx.dbresults, dbresult)
	end
	return 0
end

function floatstr(amx, str)
	return float2cell(tonumber(str) or 0)
end

function format(amx, outBuf, outBufSize, fmt, ...)
	local args = { ... }
	local i = 0
	
	fmt = fmt:gsub('[^%%]%%$', '%%%%'):gsub('%%i', '%%d')
	for c in fmt:gmatch('%%[%-%d%.]*(%*?%a)') do
		i = i + 1
		if c:match('^%*') then
			c = c:sub(2)
			table.remove(args, i)
		end
		if c == 'd' then
			args[i] = amx.memDAT[args[i]]
		elseif c == 'f' then
			args[i] = cell2float(amx.memDAT[args[i]])
		elseif c == 's' then
			args[i] = readMemString(amx, args[i])
		else
			i = i - 1
		end
	end
	fmt = fmt:gsub('(%%[%-%d%.]*)%*(%a)', '%1%2')
	local result = fmt:format(unpack(args))
	if #result+1 <= outBufSize then
		writeMemString(amx, outBuf, result)
	end
end

-----------------------------------------------------
-- List of the functions and their argument types

g_SAMPSyscallPrototypes = {
	AddMenuItem = {'m', 'i', 's'},
	AddPlayerClass = {'i', 'f', 'f', 'f', 'f', 'i', 'i', 'i', 'i', 'i', 'i'},
	AddPlayerClassEx = {'t', 'i', 'f', 'f', 'f', 'f', 'i', 'i', 'i', 'i', 'i', 'i'},
	AddPlayerClothes = {'p', 'i', 'i'},
	AddStaticPickup = {'i', 'i', 'f', 'f', 'f'},
	AddStaticVehicle = {'i', 'f', 'f', 'f', 'f', 'i', 'i'},
	AddStaticVehicleEx = {'i', 'f', 'f', 'f', 'f', 'i', 'i', 'i'},
	AddVehicleComponent = {'v', 'i'},
	AllowAdminTeleport = {'b'},
	AllowInteriorWeapons = {'b'},
	AllowPlayerTeleport = {'p', 'b'},
	ApplyAnimation = {'p', 's', 's', 'f', 'b', 'b', 'b', 'b', 'i'},
	AttachObjectToPlayer = {'o', 'p', 'f', 'f', 'f', 'f', 'f', 'f'},
	AttachPlayerObjectToPlayer = {'p', 'i', 'p', 'f', 'f', 'f', 'f', 'f', 'f', client=true},
	AttachTrailerToVehicle = {'v', 'v'},

	Ban = {'p'},
	BanEx = {'p', 's'},

	CallLocalFunction = {'s', 's'},
	CallRemoteFunction = {'s', 's'},
	ChangeVehicleColor = {'v', 'i', 'i'},
	ChangeVehiclePaintjob = {'v', 'i'},
	ClearAnimations = {'p'},
	CreateExplosion = {'f', 'f', 'f', 'i', 'f'},
	CreateMenu = {'s', 'i', 'f', 'f', 'f', 'f'},
	CreateObject = {'i', 'f', 'f', 'f', 'f', 'f', 'f'},
	CreatePickup = {'i', 'i', 'f', 'f', 'f'},
	CreatePlayerObject = {'p', 'i', 'f', 'f', 'f', 'f', 'f', 'f'},
	CreateVehicle = {'i', 'f', 'f', 'f', 'f', 'i', 'i', 'i'},
	
	DestroyMenu = {'m'},
	DestroyObject = {'o'},
	DestroyPickup = {'u'},
	DestroyPlayerObject = {'p', 'i'},
	DestroyVehicle = {'v'},
	DetachTrailerFromVehicle = {'v'},
	DisableInteriorEnterExits = {},
	DisableMenu = {'i'},
	DisableMenuRow = {'i', 'i'},
	DisablePlayerCheckpoint = {'p'},
	DisablePlayerRaceCheckpoint = {'p'},

	EnableStuntBonusForAll = {'b'},
	EnableStuntBonusForPlayer = {'p', 'b'},
	EnableTirePopping = {'b'},
	EnableZoneNames = {'b'},

	ForceClassSelection = {'i'},

	GameModeExit = {},
	GameTextForAll = {'s', 'i', 'i'},
	GameTextForPlayer = {'p', 's', 'i', 'i'},
	GangZoneCreate = {'f', 'f', 'f', 'f'},
	GangZoneDestroy = {'g'},
	GangZoneShowForPlayer = {'p', 'g', 'c'},
	GangZoneShowForAll = {'g', 'c'},
	GangZoneHideForPlayer = {'p', 'g'},
	GangZoneHideForAll = {'g'},
	GangZoneFlashForPlayer = {'p', 'g', 'c'},
	GangZoneFlashForAll = {'g', 'c'},
	GangZoneStopFlashForPlayer = {'p', 'g'},
	GangZoneStopFlashForAll = {'g'},
	GetMaxPlayers = {},
	GetObjectPos = {'o', 'r', 'r', 'r'},
	GetObjectRot = {'o', 'r', 'r', 'r'},
	GetPlayerAmmo = {'p'},
	GetPlayerArmour = {'p', 'r'},
	GetPlayerColor = {'p'},
	GetPlayerClothes = {'p', 'i'},
	GetPlayerFacingAngle = {'p', 'r'},
	GetPlayerHealth = {'p', 'r'},
	GetPlayerInterior = {'p'},
	GetPlayerIp = {'p', 'r', 'i'},
	GetPlayerKeys = {'p', 'r', 'r', 'r'},
	GetPlayerMenu = {'p'},
	GetPlayerMoney = {'p'},
	GetPlayerName = {'p', 'r', 'i'},
	GetPlayerObjectPos = {'p', 'i', 'r', 'r', 'r'},
	GetPlayerObjectRot = {'p', 'i', 'r', 'r', 'r'},
	GetPlayerPing = {'p'},
	GetPlayerPos = {'p', 'r', 'r', 'r'},
	GetPlayerScore = {'p'},
	GetPlayerSkin = {'p'},
	GetPlayerSpecialAction = {'p'},
	GetPlayerState = {'p'},
	GetPlayerTeam = {'p'},
	GetPlayerTime = {'p', 'r', 'r'},
	GetPlayerVehicleID = {'p'},
	GetPlayerVirtualWorld = {'p'},
	GetPlayerWantedLevel = {'p'},
	GetPlayerWeapon = {'p'},
	GetPlayerWeaponData = {'p', 'i', 'r', 'r'},
	GetServerVarAsBool = {'s'},
	GetServerVarAsInt = {'s'},
	GetServerVarAsString = {'s', 'r', 'i'},
	GetTickCount = {},
	GetVehicleHealth = {'v', 'r'},
	GetVehicleModel = {'v'},
	GetVehiclePos = {'v', 'r', 'r', 'r'},
	GetVehicleTrailer = {'v'},
	GetVehicleVelocity = {'v', 'r', 'r', 'r' },
	GetVehicleVirtualWorld = {'v'},
	GetVehicleZAngle = {'v', 'r'},
	GetWeaponName = {'i', 'r', 'i'},
	GivePlayerMoney = {'p', 'i'},
	GivePlayerWeapon = {'p', 'i', 'i'},
	
	HideMenuForPlayer = {'m', 'p'},

	IsPlayerAdmin = {'p'},
	IsPlayerConnected = {'i'},
	IsPlayerInAnyVehicle = {'p'},
	IsPlayerInCheckpoint = {'p'},
	IsPlayerInRaceCheckpoint = {'p'},
	IsPlayerInVehicle = {'p', 'v'},
	IsPluginLoaded = {'s'},
	IsTrailerAttachedToVehicle = {'v'},
	IsValidMenu = {'i'},
	IsValidObject = {'i'},
	IsValidPlayerObject = {'p', 'i'},

	Kick = {'p'},
	KillTimer = {'i'},

	LimitGlobalChatRadius = {'f'},
	LinkVehicleToInterior = {'v', 'i'},

	MoveObject = {'o', 'f', 'f', 'f', 'f'},
	MovePlayerObject = {'p', 'i', 'f', 'f', 'f', 'f'},

	PlayerPlaySound = {'p', 'i', 'f', 'f', 'f'},
	PlayerSpectatePlayer = {'p', 'p', 'i'},
	PlayerSpectateVehicle = {'p', 'v', 'i'},
	PutPlayerInVehicle = {'p', 'v', 'i'},

	RemovePlayerClothes = {'p', 'i'},
	RemovePlayerFromVehicle = {'p'},
	RemovePlayerMapIcon = {'p', 'i', client=true},
	RemoveVehicleComponent = {'v', 'i'},
	ResetPlayerMoney = {'p'},
	ResetPlayerWeapons = {'p'},

	SendClientMessage = {'p', 'c', 's'},
	SendClientMessageToAll = {'c', 's'},
	SendDeathMessage = {'p', 'p', 'i'},
	SetEchoDestination = {},
	SendPlayerMessageToAll = {'p', 's'},
	SendPlayerMessageToPlayer = {'p', 'p', 's'},
	SendRconCommand = {'s'},
	SetCameraBehindPlayer = {'p'},
	SetDeathDropAmount = {'i'},
	SetDisabledWeapons = {},
	SetGameModeText = {'s'},
	SetGravity = {'f'},
	SetMenuColumnHeader = {'m', 'i', 's'},
	SetNameTagDrawDistance = {'f'},
	SetObjectPos = {'o', 'f', 'f', 'f'},
	SetObjectRot = {'o', 'f', 'f', 'f'},
	SetPlayerAmmo = {'p', 'i', 'i'},
	SetPlayerArmour = {'p', 'f'},
	SetPlayerCameraLookAt = {'p', 'f', 'f', 'f'},
	SetPlayerCameraPos = {'p', 'f', 'f', 'f'},
	SetPlayerCheckpoint = {'p', 'f', 'f', 'f', 'f'},
	SetPlayerColor = {'p', 'c'},
	SetPlayerDisabledWeapons = {'p'},
	SetPlayerFacingAngle = {'p', 'f'},
	SetPlayerGravity = {'p', 'f'},
	SetPlayerHealth = {'p', 'f'},
	SetPlayerInterior = {'p', 'i'},
	SetPlayerMapIcon = {'p', 'i', 'f', 'f', 'f', 'i', 'c', client=true},
	SetPlayerMarkerForPlayer = {'p', 'p', 'c', client=true},
	SetPlayerName = {'p', 's'},
	SetPlayerObjectPos = {'p', 'i', 'f', 'f', 'f'},
	SetPlayerObjectRot = {'p', 'i', 'f', 'f', 'f'},
	SetPlayerPos = {'p', 'f', 'f', 'f'},
	SetPlayerPosFindZ = {'p', 'f', 'f', 'f', client=true},
	SetPlayerRaceCheckpoint = {'p', 'i', 'f', 'f', 'f', 'f', 'f', 'f', 'f'},
	SetPlayerScore = {'p', 'i'},
	SetPlayerSkin = {'p', 'i'},
	SetPlayerSpecialAction = {'p', 'i'},
	SetPlayerTeam = {'p', 't'},
	SetPlayerTime = {'p', 'i', 'i'},
	SetPlayerVirtualWorld = {'p', 'i'},
	SetPlayerWantedLevel = {'p', 'i'},
	SetPlayerWeather = {'p', 'i'},
	SetPlayerWorldBounds = {'p', 'f', 'f', 'f', 'f', client=true},
	SetSpawnInfo = {'p', 't', 'i', 'f', 'f', 'f', 'f', 'i', 'i', 'i', 'i', 'i', 'i'},
	SetTeamCount = {'i'},
	SetTimer = {'s', 'i', 'b'},
	SetTimerEx = {'s', 'i', 'b', 's'},
	SetVehicleHealth = {'v', 'f'},
	SetVehicleModel = {'v', 'i'},
	SetVehicleNumberPlate = {'v', 's'},
	SetVehicleParamsForPlayer = {'v', 'p', 'b', 'b'},
	SetVehiclePos = {'v', 'f', 'f', 'f'},
	SetVehicleToRespawn = {'v'},
	SetVehicleVelocity = {'v', 'f', 'f', 'f'},
	SetVehicleVirtualWorld = {'v', 'i'},
	SetVehicleZAngle = {'v', 'f'},
	SetWeather = {'i'},
	SetWorldTime = {'i'},
	ShowMenuForPlayer = {'m', 'p'},
	ShowNameTags = {'b'},
	ShowPlayerMarker = {'p', 'b'},
	ShowPlayerMarkers = {'b'},
	ShowPlayerNameTagForPlayer = {'p', 'p', 'b'},
	SpawnPlayer = {'p'},
	StopObject = {'o'},
	StopPlayerObject = {'p', 'i'},

	TextDrawAlignment = {'x', 'i'},
	TextDrawBackgroundColor = {'x', 'c'},
	TextDrawBoxColor = {'x', 'c'},
	TextDrawColor = {'x', 'c'},
	TextDrawCreate = {'f', 'f', 's'},
	TextDrawDestroy = {'i'},
	TextDrawFont = {'x', 'i'},
	TextDrawHideForAll = {'i'},
	TextDrawHideForPlayer = {'p', 'i'},
	TextDrawLetterSize = {'x', 'f', 'f'},
	TextDrawSetOutline = {'x', 'i'},
	TextDrawSetProportional = {'x', 'b'},
	TextDrawSetShadow = {'x', 'i'},
	TextDrawSetString = {'x', 's'},
	TextDrawShowForAll = {'i'},
	TextDrawShowForPlayer = {'p', 'i'},
	TextDrawTextSize = {'x', 'f', 'f'},
	TextDrawUseBox = {'x', 'b'},
	TogglePlayerClock = {'p', 'b', client=true},
	TogglePlayerControllable = {'p', 'b'},
	TogglePlayerSpectating = {'p', 'b'},

	UsePlayerPedAnims = {},
	
	acos = {'f'},
	asin = {'f'},
	atan = {'f'},
	atan2 = {'f', 'f'},

	db_close = {'i'},
	db_free_result = {'i'},
	db_field_name = {'d', 'i', 'r', 'i'},
	db_get_field = {'d', 'i', 'r', 'i'},
	db_get_field_assoc = {'d', 's', 'r', 'i'},
	db_next_row = {'d'},
	db_num_fields = {'d'},
	db_num_rows = {'d'},
	db_open = {'s'},
	db_query = {'i', 's'},
	
	floatstr = {'s'},
	format = {'r', 'i', 's'},

	memcpy = {'r', 'r', 'i', 'i', 'i'},
}