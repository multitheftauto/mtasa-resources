resourceRoot = getResourceRootElement(getThisResource())
g_Me = getLocalPlayer()

local dxDrawText = dxDrawText
local tocolor = tocolor
local SPEED_EPSILON = 0.005
local VEHICLE_DROP_TRY_INTERVAL = 100
local VEHICLE_DROP_MAX_TRIES = 50

local MENU_ITEM_HEIGHT = 25
local MENU_TOP_PADDING = MENU_ITEM_HEIGHT*2
local MENU_BOTTOM_PADDING = 10
local MENU_SIDE_PADDING = 20

local BOATS = {
	[472] = true,
	[473] = true,
	[493] = true,
	[595] = true,
	[484] = true,
	[430] = true,
	[453] = true,
	[452] = true,
	[446] = true,
	[454] = true
}

g_AMXs = {}

local screenWidth, screenHeight = guiGetScreenSize()

addEventHandler('onClientResourceStart', resourceRoot,
	function()
		triggerServerEvent('onLoadedAtClient', resourceRoot, g_Me)
		InitDialogs()
		setTimer(checkTextLabels, 500, 0)
	end,
	false
)

addEventHandler('onClientResourceStop', resourceRoot,
	function()
		TogglePlayerClock(false, true)
	end,
	false
)

function setAMXVersion(ver)
	g_AMXVersion = ver
end

function addAMX(name, type)
	g_AMXs[name] = { name = name, type = type, vehicles = {}, playerobjects = {}, textdraws = {}, textlabels = {}, menus = {}, blips = {} }
	-- textdraws = { id = { text = text, color = color, align = 1|2|3, x = x, y = y, boxsize = {width, height}, parts={{x=x,y=y,color=color,text=text},...} }, ... }
	setmetatable(
		g_AMXs[name].vehicles,
		{
			__index = function(t, k)
				local vehInfo = {}
				t[k] = vehInfo
				return t[k]
			end
		}
	)
	if type == 'gamemode' then
		setTime(12, 0)
	end
end

function removeAMX(amxName)
	local amx = g_AMXs[amxName]
	if amx.type == 'gamemode' then
		if g_ClassSelectionInfo then
			if g_ClassSelectionInfo.gui then
				table.each(g_ClassSelectionInfo.gui, destroyElement)
			end
			g_ClassSelectionInfo = nil
		end
		DisablePlayerCheckpoint()
		DisablePlayerRaceCheckpoint()
		destroyGameText()
		destroyClassSelGUI()
		if g_WorldBounds and g_WorldBounds.handled then
			removeEventHandler('onClientRender', root, checkWorldBounds)
			g_WorldBounds = nil
		end
	end
	table.each(amx.playerobjects, destroyElement)
	for id,textdraw in pairs(amx.textdraws) do
		destroyTextDraw(textdraw)
	end
	for id, textlabel in pairs(amx.textlabels) do
		destroyTextLabel(textlabel)
	end
	for id,menu in pairs(amx.menus) do
		DestroyMenu(amxName, id)
	end
	table.each(amx.blips, destroyElement)
	setElementAlpha(g_Me, 255)
	g_AMXs[amxName] = nil
end

function setPlayerID(id)
	g_PlayerID = id
end
-----------------------------
-- MTA Key Handling
function HandleMTAKey( key, keyState )
	outputServerLog("handlemtakey: " .. key)
end
-----------------------------
-- Class selection screen

function startClassSelection(classInfo)
	g_ClassSelectionInfo = classInfo
	
	-- environment
	if g_StartTime then
		setTime(unpack(g_StartTime))
		g_StartTime = nil
	end
	if g_StartWeather then
		setWeather(g_StartWeather)
		g_StartWeather = nil
	end
	setGravity(0)
	setElementCollisionsEnabled(g_Me, false)
	
	-- interaction
	showPlayerHudComponent('radar', false)
	if not g_ClassSelectionInfo.selectedclass then
		g_ClassSelectionInfo.selectedclass = 0
	end
	g_ClassSelectionInfo.gui = {
		img = guiCreateStaticImage(35, screenHeight - 410, 205, 236, 'client/logo_small.png', false),
		btnLeft = guiCreateButton(screenWidth/2-145-70,screenHeight-100,140,20,"<<<",false),
		btnRight = guiCreateButton(screenWidth/2-70,screenHeight-100,140,20,">>>",false),
		btnSpawn = guiCreateButton(screenWidth/2+145-70,screenHeight-100,140,20,"Spawn",false)
	}
	addEventHandler ( "onClientGUIClick", g_ClassSelectionInfo.gui.btnLeft, ClassSelLeft )
	addEventHandler ( "onClientGUIClick", g_ClassSelectionInfo.gui.btnRight, ClassSelRight )
	addEventHandler ( "onClientGUIClick", g_ClassSelectionInfo.gui.btnSpawn, ClassSelSpawn )
	showCursor(true)
	addEventHandler('onClientRender', root, renderClassSelText)
end

function ClassSelLeft ()
	server.requestClass(getLocalPlayer(), false, false, -1)
end

function ClassSelRight ()
	server.requestClass(getLocalPlayer(), false, false, 1)
end

function ClassSelSpawn ()
	server.requestSpawn(getLocalPlayer(), false, false)
end

function renderClassSelText()
	drawShadowText(g_AMXVersion, 20, screenHeight - 170, tocolor(39, 171, 250), 1, 'default-bold', 1, 230)
	drawShadowText('Use left and right arrow keys to select class.', 20, screenHeight - 150, tocolor(240, 240, 240))
	drawShadowText('Press SHIFT when ready to spawn.', 20, screenHeight - 136, tocolor(240, 240, 240))
	
	if not g_ClassSelectionInfo or not g_ClassSelectionInfo.selectedclass then
		return
	end
	drawShadowText('Class ' .. g_ClassSelectionInfo.selectedclass .. ' weapons:', 20, screenHeight - 110, tocolor(240, 240, 240))
	local weapon, ammo, linenum, line
	linenum = 0
	for i,weapondata in ipairs(g_ClassSelectionInfo[g_ClassSelectionInfo.selectedclass].weapons) do
		weapon, ammo = weapondata[1], weapondata[2]
		if weapon ~= 0 and weapon ~= -1 and ammo ~= -1 then
			linenum = linenum + 1
			if ammo ~= 0 then
				line = ammo .. 'x '
			else
				line = ''
			end
			line = line .. (getWeaponNameFromID(weapon) or weapon)
			drawShadowText(line, 25, screenHeight - 110 + 14*linenum, tocolor(240, 240, 240))
		end
	end
end

function selectClass(classid)
	fadeCamera(true)
	g_ClassSelectionInfo.selectedclass = classid
end

function destroyClassSelGUI()
	if g_ClassSelectionInfo and g_ClassSelectionInfo.gui then
		for i,elem in pairs(g_ClassSelectionInfo.gui) do
			destroyElement(elem)
		end
		g_ClassSelectionInfo.gui = nil
		removeEventHandler('onClientRender', root, renderClassSelText)
	end
	showPlayerHudComponent('radar', true)
	setCameraTarget(g_Me)
	setGravity(0.008)
	setElementCollisionsEnabled(g_Me, true)
	showCursor(false)
	if g_ClassSelectionInfo then
		removeEventHandler ( "onClientGUIClick", g_ClassSelectionInfo.gui.btnLeft, ClassSelLeft )
		removeEventHandler ( "onClientGUIClick", g_ClassSelectionInfo.gui.btnRight, ClassSelRight )
		removeEventHandler ( "onClientGUIClick", g_ClassSelectionInfo.gui.btnSpawn, ClassSelSpawn )
	end
end

addEventHandler('onClientResourceStop', resourceRoot,
	function()
		destroyClassSelGUI()
		removeEventHandler('onClientRender', root, renderTextDraws)
		removeEventHandler('onClientRender', root, renderMenu)
	end
)

function requestSpawn()
	triggerServerEvent('onRequestSpawn', g_Me, g_ClassSelectionInfo.selectedclass)
end

addEventHandler('onClientPlayerWeaponFire', resourceRoot,
	function(weapon, ammo, ammoInClip, hitX, hitY, hitZ)
		--if getLocalPlayer() ~= source then return end
		serverAMXEvent('OnPlayerShoot', getElemID(source), weapon, ammo, ammoInClip, hitX, hitY, hitZ)
	end,
	false
)

-----------------------------
-- Camera

g_IntroScenes = {
	{ pos = {1480.6602783203, -895.64221191406, 59.47342300415},   lookat = {1425.9151611328, -811.95843505859, 80.428070068359}, hour = 22 },
	{ pos = {340.99697875977, -2056.0290527344, 12.975963592529},  lookat = {414.72384643555, -1988.4691162109, 18.528661727905}  },
	{ pos = {587.87091064453, -1603.4930419922, 56.795890808105},  lookat = {503.70782470703, -1549.4876708984, 12.30154800415}   },
	{ pos = {2087.1223144531, 1326.7012939453, 12.497343063354},   lookat = {2177.5185546875, 1283.9398193359, 25.791206359863}   },
	{ pos = {-2350.7131347656, 2616.9641113281, 59.754123687744},  lookat = {-2389.2639160156, 2524.6936035156, 51.430431365967}  },
	{ pos = {-2134.8439941406, 648.99450683594, 58.182228088379},  lookat = {-2190.6123046875, 565.98913574219, 48.198886871338}  },
	{ pos = {-1920.4506835938, 671.93243408203, 46.611064910889},  lookat = {-2010.3052978516, 628.04443359375, 97.929328918457}  },
	{ pos = {-2826.470703125, -321.03930664063, 15.318729400635},  lookat = {-2726.5969238281, -316.01550292969, 35.185661315918} },
	{ pos = {1962.1159667969, -1243.6359863281, 21.70813369751},   lookat = {1936.1663818359, -1147.0615234375, 22.263687133789}  },
	{ pos = {709.04748535156, -768.44177246094, 93.960334777832},  lookat = {721.93560791016, -867.60778808594, 62.820266723633}  },
	{ pos = {-273.57577514648, -1792.1629638672, 44.541469573975}, lookat = {-318.5471496582, -1881.4802246094, 51.203201293945}, hour = 0 },
	{ pos = {-1617.8410644531, 483.92135620117, 76.319374084473},  lookat = {-1615.3560791016, 583.89050292969, 70.766677856445}, hour = 0 }
}

local introSceneShown = false
function showIntroScene()
	if introSceneShown then
		return
	end
	showPlayerHudComponent('area_name', false)
	showPlayerHudComponent('radar', false)
	fadeCamera(true)
	
	local scene = table.random(g_IntroScenes)
	setCameraMatrix(scene.pos[1], scene.pos[2], scene.pos[3], scene.lookat[1], scene.lookat[2], scene.lookat[3])
	g_StartTime = { getTime() }
	g_StartWeather = getWeather()
	setTime(scene.hour or 12, 0)
	setWeather(0)
	
	introSceneShown = true
end

-----------------------------
-- Player objects

function AttachPlayerObjectToPlayer(amxName, objID, attachPlayer, offsetX, offsetY, offsetZ, rX, rY, rZ)
	local obj = g_AMXs[amxName] and g_AMXs[amxName].playerobjects[objID]
	if not obj then
		return
	end
	attachElements(obj, attachPlayer, offsetX, offsetY, offsetZ, rX, rY, rZ)
end

function CreatePlayerObject(amxName, objID, model, x, y, z, rX, rY, rZ)
	g_AMXs[amxName].playerobjects[objID] = createObject(model, x, y, z, rX, rY, rZ)
end

function DestroyPlayerObject(amxName, objID)
	local obj = g_AMXs[amxName].playerobjects[objID]
	if not obj then
		return
	end
	destroyElement(obj)
	g_AMXs[amxName].playerobjects[objID] = nil
end

function MovePlayerObject(amxName, objID, x, y, z, speed)
	local obj = g_AMXs[amxName].playerobjects[objID]
	local rX, rY, rZ = getElementRotation(obj)
	local distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(obj))
	local time = distance/speed*1000
	moveObject(obj, time, x, y, z)
	setElementRotation(obj, rX, rY, rZ)
end

function SetPlayerObjectPos(amxName, objID, x, y, z)
	local obj = g_AMXs[amxName] and g_AMXs[amxName].playerobjects[objID]
	if not obj then
		return
	end
	setElementPosition(obj, x, y, z)
end

function SetPlayerObjectRot(amxName, objID, rX, rY, rZ)
	local obj = g_AMXs[amxName] and g_AMXs[amxName].playerobjects[objID]
	if not obj then
		return
	end
	setElementRotation(obj, rX, rY, rZ)
end

function StopPlayerObject(amxName, objID)
	local obj = g_AMXs[amxName] and g_AMXs[amxName].playerobjects[objID]
	if not obj then
		return
	end
	stopObject(obj)
end


-----------------------------
-- Checkpoints

function OnPlayerEnterCheckpoint(elem)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if (vehicle and elem == vehicle) or (not vehicle and elem == g_Me) then
		serverAMXEvent('OnPlayerEnterCheckpoint', g_PlayerID)
	end
end

function OnPlayerLeaveCheckpoint(elem)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if (vehicle and elem == vehicle) or (not vehicle and elem == g_Me) then
		serverAMXEvent('OnPlayerLeaveCheckpoint', g_PlayerID)
	end
end

function DisablePlayerCheckpoint()
	if not g_PlayerCheckpoint then
		return
	end
	removeEventHandler('onClientColShapeHit', g_PlayerCheckpoint.colshape, OnPlayerEnterCheckpoint)
	removeEventHandler('onClientColShapeLeave', g_PlayerCheckpoint.colshape, OnPlayerLeaveCheckpoint)
	for k,elem in pairs(g_PlayerCheckpoint) do
		destroyElement(elem)
	end
	g_PlayerCheckpoint = nil
end

function SetPlayerCheckpoint(x, y, z, size)
	if g_PlayerCheckpoint then
		DisablePlayerCheckpoint()
	end
	g_PlayerCheckpoint = {
		marker = createMarker(x, y, z, 'cylinder', size, 255, 0, 0, 150),
		colshape = createColCircle(x, y, size),
		blip = createBlip(x, y, z)
	}
	setBlipOrdering(g_PlayerCheckpoint.blip, 2)
	setElementAlpha(g_PlayerCheckpoint.marker, 128)
	addEventHandler('onClientColShapeHit', g_PlayerCheckpoint.colshape, OnPlayerEnterCheckpoint)
	addEventHandler('onClientColShapeLeave', g_PlayerCheckpoint.colshape, OnPlayerLeaveCheckpoint)
end

function OnPlayerEnterRaceCheckpoint(elem)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if (vehicle and elem == vehicle) or (not vehicle and elem == g_Me) then
		serverAMXEvent('OnPlayerEnterRaceCheckpoint', g_PlayerID)
	end
end

function OnPlayerLeaveRaceCheckpoint(elem)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if (vehicle and elem == vehicle) or (not vehicle and elem == g_Me) then
		serverAMXEvent('OnPlayerLeaveRaceCheckpoint', g_PlayerID)
	end
end

function DisablePlayerRaceCheckpoint()
	if not g_PlayerRaceCheckpoint then
		return
	end
	removeEventHandler('onClientColShapeHit', g_PlayerRaceCheckpoint.colshape, OnPlayerEnterRaceCheckpoint)
	removeEventHandler('onClientColShapeLeave', g_PlayerRaceCheckpoint.colshape, OnPlayerLeaveRaceCheckpoint)
	for k,elem in pairs(g_PlayerRaceCheckpoint) do
		destroyElement(elem)
	end
	g_PlayerRaceCheckpoint = nil
end

function SetPlayerRaceCheckpoint(type, x, y, z, nextX, nextY, nextZ, size)
	if g_PlayerRaceCheckpoint then
		DisablePlayerRaceCheckpoint()
	end
	g_PlayerRaceCheckpoint = {
		marker = createMarker(x, y, z, type < 2 and 'checkpoint' or 'ring', size, 255, 0, 0),
		colshape = type < 2 and createColCircle(x, y, size) or createColSphere(x, y, z, size*1.5),
		blip = createBlip(x, y, z, 0, 2, 255, 0, 0),
		nextblip = createBlip(nextX, nextY, nextZ, 0, 1, 255, 0, 0)
	}
	setBlipOrdering(g_PlayerRaceCheckpoint.blip, 2)
	setBlipOrdering(g_PlayerRaceCheckpoint.nextblip, 2)
	if type == 1 or type == 4 then
		setMarkerIcon(g_PlayerRaceCheckpoint.marker, 'finish')
	end
	setElementAlpha(g_PlayerRaceCheckpoint.marker, 128)
	setMarkerTarget(g_PlayerRaceCheckpoint.marker, nextX, nextY, nextZ)
	addEventHandler('onClientColShapeHit', g_PlayerRaceCheckpoint.colshape, OnPlayerEnterRaceCheckpoint)
	addEventHandler('onClientColShapeLeave', g_PlayerRaceCheckpoint.colshape, OnPlayerLeaveRaceCheckpoint)
end


-----------------------------
-- Vehicles

function SetPlayerPosFindZ(amxName, x, y, z)
	setElementPosition(g_Me, x, y, getGroundPosition(x, y, z) + 1)
end

function SetVehicleParamsForPlayer(vehicle, isObjective, doorsLocked)
	local amx, vehID = getElemAMX(vehicle), getElemID(vehicle)
	if not amx or not vehID then
		return
	end
	local vehInfo = amx.vehicles[vehID]
	if isObjective then
		if vehInfo.blip then
			destroyElement(vehInfo.blip)
			vehInfo.blip = nil
		end
		vehInfo.blip = createBlipAttachedTo(vehicle, 0, 2, 222, 188, 97)
		setBlipOrdering(vehInfo.blip, 1)
		vehInfo.blippersistent = true
		setElementParent(vehInfo.blip, vehicle)
		
		if not vehInfo.marker then
			local x, y, z = getElementPosition(vehicle)
			vehInfo.marker = createMarker(x, y, z, 'arrow', 2, 255, 255, 100)
			attachElements(vehInfo.marker, vehicle, 0, 0, 6)
			setElementParent(vehInfo.marker, vehicle)
		end
	end
	setVehicleLocked(vehicle, doorsLocked)
end


local vehicleDrops = {}		-- { [vehicle] = { timer = timer, tries = tries } }

function dropVehicle(vehicle)
	local dropdata = vehicleDrops[vehicle]
	if not dropdata then
		return
	end
	dropdata.tries = dropdata.tries + 1
	if dropdata.tries >= VEHICLE_DROP_MAX_TRIES then
		vehicleDrops[vehicle] = nil
	end
	if not isElement(vehicle) or not isVehicleEmpty(vehicle) then
		if dropdata.tries < VEHICLE_DROP_MAX_TRIES then
			killTimer(dropdata.timer)
		end
		vehicleDrops[vehicle] = nil
		return
	end
	
	local left, back, bottom, right, front, top = getElementBoundingBox(vehicle)
	if not bottom then
		top = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
		if not top then
			return
		end
		bottom = -top
	end
	local x, y, z = getElementPosition(vehicle)
	local rx, ry, rz = getElementRotation(vehicle)
	
	local hit, hitX, hitY, hitZ = processLineOfSight(x, y, z + top, x, y, z - 10, true, false)
	if hitZ then
		setElementCollisionsEnabled(vehicle, true)
		if z < hitZ - bottom - 0.5 or top > 2 then
			setElementPosition(vehicle, x, y, hitZ + 2*math.abs(bottom))
			setElementRotation(vehicle, 0, ry, rz)
			setElementVelocity(vehicle, 0, 0, -0.05)
		end
		if dropdata.tries < VEHICLE_DROP_MAX_TRIES then
			killTimer(dropdata.timer)
		end
		vehicleDrops[vehicle] = nil
	elseif dropdata.tries >= VEHICLE_DROP_MAX_TRIES then
		setElementCollisionsEnabled(vehicle, true)
	end
end

addEventHandler('onClientElementStreamIn', root,
	function()
		if getElementType(source) == 'vehicle' then
			-- drop floating/underground vehicles
			if not vehicleDrops[source] and isVehicleEmpty(source) and not BOATS[getElementModel(source)] then
				setElementCollisionsEnabled(source, false)
				local timer = setTimer(dropVehicle, VEHICLE_DROP_TRY_INTERVAL, VEHICLE_DROP_MAX_TRIES, source)
				vehicleDrops[source] = { timer = timer, tries = 0 }
			end
			
			local amx, vehID = getElemAMX(source), getElemID(source)
			local vehInfo = amx and vehID and amx.vehicles[vehID]
			if vehInfo and not vehInfo.blip then
				vehInfo.blip = createBlipAttachedTo(source, 0, 1, 136, 136, 136, 150, 0, 500)
				setElementParent(vehInfo.blip, source)
			end
			serverAMXEvent('OnVehicleStreamIn', getElemID(source), getElemID(getLocalPlayer()))
		elseif getElementType(source) == 'player' then
			serverAMXEvent('OnPlayerStreamIn', getElemID(source), getElemID(getLocalPlayer()))
		end
	end
)

addEventHandler('onClientElementStreamOut', root,
	function()
		if getElementType(source) ~= 'vehicle' then
			local amx, vehID = getElemAMX(source), getElemID(source)
			local vehInfo = amx and vehID and amx.vehicles[vehID]
			if vehInfo and vehInfo.blip and not vehInfo.blippersistent then
				if isElement(vehInfo.blip) then
					destroyElement(vehInfo.blip)
				end
				vehInfo.blip = nil
			end 
			serverAMXEvent('OnVehicleStreamOut', getElemID(source), getElemID(getLocalPlayer()))
		elseif getElementType(source) == 'player' then
			serverAMXEvent('OnPlayerStreamOut', getElemID(source), getElemID(getLocalPlayer()))
		end
	end
)

function DestroyVehicle(amxName, vehID)
	g_AMXs[amxName].vehicles[vehID] = nil
end

-----------------------------
-- Text

local controlNames = {
	VEHICLE_TURRETLEFT = 'special_control_left',
	VEHICLE_TURRETRIGHT = 'special_control_right',
	VEHICLE_TURRETUP = 'special_control_up',
	VEHICLE_TURRETDOWN = 'special_control_down',
	VEHICLE_HORN = 'horn',
	VEHICLE_LOOKLEFT = 'vehicle_look_left',
	VEHICLE_LOOKRIGHT = 'vehicle_look_right',
	VEHICLE_ENTER_EXIT = 'enter_exit',
	VEHICLE_ACCELERATE = 'accelerate',
	VEHICLE_BRAKE = 'brake_reverse',
	VEHICLE_HANDBRAKE = 'handbrake',
	VEHICLE_STEERDOWN = 'steer_forward',
	VEHICLE_STEERUP = 'steer_backward',
	VEHICLE_STEERLEFT = 'vehicle_left',
	VEHICLE_STEERRIGHT = 'vehicle_right',
	VEHICLE_FIREWEAPON_ALT = 'vehicle_secondary_fire',
	VEHICLE_RADIO_STATION_UP = 'radio_next',
	VEHICLE_RADIO_STATION_DOWN = 'radio_previous',

	PED_SPRINT = 'sprint',
	PED_FIREWEAPON = 'fire',
	PED_ANSWER_PHONE = 'action',
	PED_LOCK_TARGET = 'aim_weapon',
	PED_LOOKBEHIND = 'look_behind',
	PED_SNIPER_ZOOM_IN = 'zoom_in',
	PED_SNIPER_ZOOM_OUT = 'zoom_out',
	PED_CYCLE_WEAPON_LEFT = 'previous_weapon',
	PED_CYCLE_WEAPON_RIGHT = 'next_weapon',
	PED_DUCK = 'crouch',
	PED_JUMPING = 'jump',

	GO_LEFT = 'left',
	GO_RIGHT = 'right',
	GO_BACK = 'backwards',
	GO_FORWARD = 'forwards',

	CONVERSATION_NO = 'conversation_no',
	CONVERSATION_YES = 'conversation_yes',

	GROUP_CONTROL_BWD = 'group_control_back',
	GROUP_CONTROL_FWD = 'group_control_forwards'
}

local function getSAMPBoundKey(control)
	control = controlNames[control] or control
	local keys = getBoundKeys(control)
	if keys and #keys > 0 then
		return keys[1]
	else
		return control
	end
end

local textDrawColorMapping = {
	r = {180, 25, 29},
	g = {53, 101, 43},
	b = {50, 60, 127},
	o = {239, 141, 27},
	w = {255, 255, 255},
	y = {222, 188, 97},
	p = {180, 25, 180},
	l = {10, 10, 10}
}

local textDrawFonts = {
	[0] = { font = 'beckett', lsizemul = 3 },			-- TextDraw letter size -> dxDrawText scale multiplier
	[1] = { font = 'default-bold', lsizemul = 3 },
	[2] = { font = 'bankgothic',   lsizemul = 2 },
	[3] = { font = 'default-bold', lsizemul = 3 }
}

function initTextDraw(textdraw)
	local amx = textdraw.amx
	textdraw.id = textdraw.id or (#amx.textdraws + 1)
	amx.textdraws[textdraw.id] = textdraw
	
	local lineHeight = 60*(textdraw.lsize or 0.5)
	
	local text = textdraw.text:gsub('~k~~(.-)~', getSAMPBoundKey)
	local lines = {}
	local pos, stop, c
	stop = 0
	while true do
		pos, stop, c = text:find('~(%a)~', stop + 1)
		if c == 'n' then
			lines[#lines + 1] = text:sub(1, pos - 1)
			text = text:sub(stop + 1)
			stop = 0
		elseif not pos then
			lines[#lines + 1] = text
			break
		end
	end
	while #lines > 0 and lines[#lines]:match('^%s*$') do
		lines[#lines] = nil
	end
	
	textdraw.parts = {}
	textdraw.width = 0
	local font = textDrawFonts[textdraw.font and textdraw.font >= 0 and textdraw.font <= #textDrawFonts and textdraw.font or 0]
	local scale = (textdraw.lsize or 0.5) * font.lsizemul
	font = font.font
	
	local curX
	local curY = textdraw.y or screenHeight/2 - #lines*lineHeight/2
	
	for i,line in ipairs(lines) do
		local colorpos = 1
		local color
		
		while true do
			local start = line:find('~%a~', colorpos)
			if not start then
				break
			end
			local extrabright = 0
			colorpos = start
			while true do
				c = line:match('^~(%a)~', colorpos)
				if not c then
					break
				end
				colorpos = colorpos + 3
				if textDrawColorMapping[c] then
					color = textDrawColorMapping[c]
				elseif c == 'h' then
					extrabright = extrabright + 1
				else
					break
				end
			end
			if color or extrabright > 0 then
				if extrabright > 0 then
					color = color and table.shallowcopy(color) or { 255, 255, 255 }
					for i=1,3 do
						color[i] = math.min(color[i] + extrabright*40, 255)
					end
				end
				line = line:sub(1, start-1) .. ('#%02X%02X%02X'):format(unpack(color)) .. line:sub(colorpos)
			end
		end
		
		local textWidth = dxGetTextWidth(line:gsub('#%x%x%x%x%x%x', ''), scale, font)
		textdraw.width = math.max(textdraw.width, textWidth)
		if textdraw.align == 1 then
			-- left
			curX = textdraw.x
		elseif textdraw.align == 2 or not textdraw.align then
			-- center
			curX = screenWidth/2 - textWidth/2
		elseif textdraw.align == 3 then
			-- right
			curX = textdraw.x - textWidth
		end
		
		color = textdraw.color or tocolor(255, 255, 255)
		colorpos = 1
		local nextcolorpos
		while colorpos < line:len()+1 do
			local r, g, b = line:sub(colorpos, colorpos+6):match('#(%x%x)(%x%x)(%x%x)')
			if r then
				color = tocolor(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
				colorpos = colorpos + 7
			end
			nextcolorpos = line:find('#%x%x%x%x%x%x', colorpos) or line:len() + 1
			local part = { text = line:sub(colorpos, nextcolorpos - 1), x = curX, y = curY, color = color }
			table.insert(textdraw.parts, part)
			curX = curX + dxGetTextWidth(part.text, scale, font)
			colorpos = nextcolorpos
		end
		curY = curY + lineHeight
	end
	textdraw.absheight = lineHeight*#lines
end

function visibleTextDrawsExist()
	for name,amx in pairs(g_AMXs) do
		if table.find(amx.textdraws, 'visible', true) then
			return true
		end
	end
	return false
end

function showTextDraw(textdraw)
	if not visibleTextDrawsExist() then
		addEventHandler('onClientRender', root, renderTextDraws)
	end
	textdraw.visible = true
end

function hideTextDraw(textdraw)
	textdraw.visible = false
	if not visibleTextDrawsExist() then
		removeEventHandler('onClientRender', root, renderTextDraws)
	end
end

function renderTextDraws()
	for name,amx in pairs(g_AMXs) do
		for id,textdraw in pairs(amx.textdraws) do
			if textdraw.visible and textdraw.parts and not (textdraw.text:match('^%s*$') and not textdraw.usebox) then
				local font = textDrawFonts[textdraw.font and textdraw.font >= 0 and textdraw.font <= #textDrawFonts and textdraw.font or 0]
				local scale = (textdraw.lsize or 0.5) * font.lsizemul
				font = font.font
				if textdraw.usebox then
					local boxcolor = textdraw.boxcolor or tocolor(0, 0, 0, 120*(textdraw.alpha or 1))
					local x, y, w, h
					if textdraw.align == 1 then
						x = textdraw.x
						if textdraw.boxsize then
							w = textdraw.boxsize[1] - x
						else
							w = textdraw.width
						end
					elseif textdraw.align == 2 then
						if textdraw.boxsize then
							x = screenWidth/2 - textdraw.boxsize[1]/2
							w = textdraw.boxsize[1]
						else
							x = textdraw.x
							w = textdraw.width
						end
					elseif textdraw.align == 3 then
						if textdraw.boxsize then
							w = textdraw.x - textdraw.boxsize[1]
						else
							w = textdraw.width
						end
						x = textdraw.x - w
					end
					y = textdraw.y
					if textdraw.boxsize and textdraw.text:match('^%s*$') then
						h = textdraw.boxsize[2]
					else
						h = textdraw.absheight
					end
					dxDrawRectangle(x - 3, y - 3, w + 6, h + 6, boxcolor)
				end
				for i,part in pairs(textdraw.parts) do
					if textdraw.shade and textdraw.shade > 0 then
						dxDrawText(part.text, part.x + 5, part.y + 5, part.x + 5, part.y + 5, tocolor(0, 0, 0, 100*(textdraw.alpha or 1)), scale, font)
					end
					drawBorderText(
						part.text, part.x, part.y,
						textdraw.alpha and setcoloralpha(part.color, math.floor(textdraw.alpha*255)) or part.color,
						scale, font, math.ceil((textdraw.outlinesize or (font == 'bankgothic' and 2 or 1))*scale),
						textdraw.outlinecolor
					)
				end
			end
		end
	end
end

function destroyTextDraw(textdraw)
	if not textdraw then
		return
	end
	hideTextDraw(textdraw)
	table.removevalue(textdraw.amx.textdraws, textdraw)
end

local gameText = false

function GameTextForPlayer(amxName, text, time, style)
	if gameText then
		destroyGameText()
	end
	local amx = g_AMXs[amxName]
	gameText = { amx = amx, text = text, font = 2 }
	if style == 2 then
		gameText.x = 0.9*screenWidth
		gameText.y = 0.7*screenHeight
		gameText.align = 3
	elseif style == 6 then
		gameText.y = 0.2*screenHeight
	end
	initTextDraw(gameText)
	showTextDraw(gameText)
	gameText.timer = setTimer(destroyGameText, time, 1)
end

function destroyGameText()
	if not gameText then
		return
	end
	destroyTextDraw(gameText)
	if gameText.timer then
		killTimer(gameText.timer)
		gameText.timer = nil
	end
	gameText = false
end

function renderTextLabels()
	for name,amx in pairs(g_AMXs) do
		for id,textlabel in pairs(amx.textlabels) do
			if textlabel.enabled then
				if textlabel.attached then
					local oX, oY, oZ = getElementPosition(textlabel.attachedTo)
					oX = oX + textlabel.offX
					oY = oY + textlabel.offY
					oZ = oZ + textlabel.offZ
					textlabel.X = oX
					textlabel.Y = oY
					textlabel.Z = oZ
				end
				
				local screenX, screenY = getScreenFromWorldPosition(textlabel.X, textlabel.Y, textlabel.Z, textlabel.dist, false)
				local pX, pY, pZ = getElementPosition(g_Me)
				local dist = getDistanceBetweenPoints3D(pX, pY, pZ, textlabel.X, textlabel.Y, textlabel.Z)
				local vw = getElementDimension(g_Me)
				--[[if textlabel.attached then
					local LOS = isLineOfSightClear(pX, pY, pZ, textlabel.X, textlabel.Y, textlabel.Z, true, true, true, true, true, false, false, textlabel.attachedTo)
				else]] --неработает, похоже функция isLineOfSightClear не работает с аргументом ignoredElement.
					local LOS = isLineOfSightClear(pX, pY, pZ, textlabel.X, textlabel.Y, textlabel.Z, true, false, false)--пока так, потом разберутся с функцией сделаем как нужно :)
				--end
				local len = string.len(textlabel.text)
				if screenX and dist <= textlabel.dist and vw == textlabel.vw then
					if not textlabel.los then
						--dxDrawText(textlabel.text, screenX, screenY, screenWidth, screenHeight, tocolor ( 0, 0, 0, 255 ), 1, "default")--, "center", "center")--, true, false)
						dxDrawText(textlabel.text, screenX, screenY, screenWidth, screenHeight, tocolor(textlabel.color.r, textlabel.color.g, textlabel.color.b, textlabel.color.a), 1, "default-bold")--, "center", "center", true, false)
					elseif LOS then
						--dxDrawText(textlabel.text, screenX, screenY, screenWidth, screenHeight, tocolor ( 0, 0, 0, 255 ), 1, "default")--, "center", "center")--, true, false)
						dxDrawText(textlabel.text, screenX - (len), screenY, screenWidth, screenHeight, tocolor(textlabel.color.r, textlabel.color.g, textlabel.color.b, textlabel.color.a), 1, "default-bold")--, "center", "center", true, false)
					end
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, renderTextLabels)

function checkTextLabels()
	for name,amx in pairs(g_AMXs) do
		for id,textlabel in pairs(amx.textlabels) do
		
			local pX, pY, pZ = getElementPosition(g_Me)
			local dist = getDistanceBetweenPoints3D(pX, pY, pZ, textlabel.X, textlabel.Y, textlabel.Z)
			
			if dist <= textlabel.dist then
				textlabel.enabled = true
			else
				textlabel.enabled = false
			end
		
		end
	end
end


function Create3DTextLabel(amxName, id, textlabel)
	local amx = g_AMXs[amxName]
	textlabel.amx = amx
	textlabel.id = id
	textlabel.enabled = false
	amx.textlabels[id] = textlabel
end

function Delete3DTextLabel(amxName, id)
	local amx = g_AMXs[amxName]
	textlabel = amx.textlabels[id]
	table.removevalue(amx.textlabels, textlabel)
end

function Attach3DTextLabel(amxName, textlabel)
	local amx = g_AMXs[amxName]
	local id = textlabel.id
	amx.textlabels[id] = textlabel
end

function TextDrawCreate(amxName, id, textdraw)
	local amx = g_AMXs[amxName]
	textdraw.amx = amx
	textdraw.id = id
	amx.textdraws[id] = textdraw
	if textdraw.x then
		textdraw.x = textdraw.x*screenWidth
		textdraw.y = textdraw.y*screenHeight
	end
	for prop,val in pairs(textdraw) do
		TextDrawPropertyChanged(amxName, id, prop, val, true)
	end
	initTextDraw(textdraw)
end

function TextDrawDestroy(amxName, id)
	destroyTextDraw(g_AMXs[amxName].textdraws[id])
end

function TextDrawHideForPlayer(amxName, id)
	hideTextDraw(g_AMXs[amxName].textdraws[id])
end

function TextDrawPropertyChanged(amxName, id, prop, newval, skipInit)
	local textdraw = g_AMXs[amxName].textdraws[id]
	textdraw[prop] = newval
	if prop == 'boxsize' then
		textdraw.boxsize[1] = textdraw.boxsize[1]*screenWidth
		textdraw.boxsize[2] = textdraw.boxsize[2]*screenHeight
	elseif prop:match('color') then
		textdraw[prop] = tocolor(unpack(newval))
	end
	if not skipInit then
		initTextDraw(textdraw)
	end
end

function TextDrawShowForPlayer(amxName, id)
	showTextDraw(g_AMXs[amxName].textdraws[id])
end

function displayFadingMessage(text, r, g, b, fadeInTime, stayTime, fadeOutTime)
	local lineHeight = 40
	local label = guiCreateLabel(screenWidth, screenHeight, 500, lineHeight, text, false)
	local width = guiLabelGetTextExtent(label)
	guiSetPosition(label, screenWidth/2 - width/2, 3*screenHeight/4, false)
	guiSetSize(label, width, lineHeight, false)
	guiSetAlpha(label, 0)
	if r and g and b then
		guiLabelSetColor(label, r, g, b)
	end
	local anim = Animation.createNamed('fadingLabels')
	anim:addPhase(
		{ elem = label,
			Animation.presets.guiFadeIn(fadeInTime or 1000),
			{ time = stayTime or 3000 },
			Animation.presets.guiFadeOut(fadeOutTime or 1000),
			destroyElement
		}
	)
	anim:play()
end

-----------------------------
-- Menus

local function updateMenuSize(menu)
	menu.width = (#menu.items[1] > 0 and (menu.leftColumnWidth + menu.rightColumnWidth) or (menu.leftColumnWidth)) + 2*MENU_SIDE_PADDING
	menu.height = MENU_ITEM_HEIGHT*math.max(#menu.items[0], #menu.items[1]) + MENU_TOP_PADDING + MENU_BOTTOM_PADDING
end

function AddMenuItem(amxName, id, column, caption)
	local menu = g_AMXs[amxName].menus[id]
	table.insert(menu.items[column], caption)
	updateMenuSize(menu)
end

function CreateMenu(amxName, id, menu)
	local amx = g_AMXs[amxName]
	menu.amx = amx
	menu.x = math.floor(menu.x * screenWidth / 640)
	menu.y = math.floor(menu.y * screenHeight / 480)
	menu.leftColumnWidth = math.floor(menu.leftColumnWidth * screenWidth / 640)
	menu.rightColumnWidth = math.floor(menu.rightColumnWidth * screenWidth / 480)
	local id = 1
	while amx.textdraws['m' .. id] do
		id = id + 1
	end
	menu.titletextdraw = { amx = amx, text = menu.title, id = 'm' .. id, x = menu.x + MENU_SIDE_PADDING, y = menu.y - 0.5*MENU_ITEM_HEIGHT, align = 1, font = 2 }
	initTextDraw(menu.titletextdraw)
	hideTextDraw(menu.titletextdraw)
	updateMenuSize(menu)
	amx.menus[id] = menu
end

function DisableMenuRow(amxName, menuID, rowID)
	local menu = g_AMXs[amxName].menus[menuID]
	menu.disabledrows = menu.disabledrows or {}
	table.insert(menu.disabledrows, rowID)
end

function SetMenuColumnHeader(amxName, menuID, column, text)
	g_AMXs[amxName].menus[menuID].items[column][13] = text
end

function ShowMenuForPlayer(amxName, menuID)
	local amx = g_AMXs[amxName]
	if g_CurrentMenu and g_CurrentMenu.anim then
		g_CurrentMenu.anim:remove()
		g_CurrentMenu.anim = nil
	end
	
	local prevMenu = g_CurrentMenu
	g_CurrentMenu = amx.menus[menuID]
	local closebtnSide = screenWidth*(30/1024)
	if not prevMenu then
		g_CurrentMenu.alpha = 0
		g_CurrentMenu.titletextdraw.alpha = 0
		
		g_CurrentMenu.closebtn = guiCreateStaticImage(g_CurrentMenu.x + g_CurrentMenu.width - closebtnSide, g_CurrentMenu.y, closebtnSide, closebtnSide, 'client/closebtn.png', false, nil)
		guiSetAlpha(g_CurrentMenu.closebtn, 0)
		addEventHandler('onClientMouseEnter', g_CurrentMenu.closebtn,
			function()
				guiSetVisible(g_CurrentMenu.closebtn, false)
				guiSetVisible(g_CurrentMenu.closebtnhover, true)
			end,
			false
		)
		
		g_CurrentMenu.closebtnhover = guiCreateStaticImage(g_CurrentMenu.x + g_CurrentMenu.width - closebtnSide, g_CurrentMenu.y, closebtnSide, closebtnSide, 'client/closebtn_hover.png', false, nil)
		guiSetVisible(g_CurrentMenu.closebtnhover, false)
		guiSetAlpha(g_CurrentMenu.closebtnhover, .75)
		addEventHandler('onClientMouseLeave', g_CurrentMenu.closebtnhover,
			function()
				guiSetVisible(g_CurrentMenu.closebtnhover, false)
				guiSetVisible(g_CurrentMenu.closebtn, true)
			end,
			false
		)
		
		addEventHandler('onClientGUIClick', g_CurrentMenu.closebtnhover,
			function()
				if not g_CurrentMenu.anim then
					HideMenuForPlayer(amxName)
				end
			end,
			false
		)
		
		g_CurrentMenu.anim = Animation.createAndPlay(
			g_CurrentMenu,
			{ time = 500, from = 0, to = 1, fn = setMenuAlpha },
			function()
				setMenuAlpha(g_CurrentMenu, 1)
				g_CurrentMenu.titletextdraw.alpha = nil
				g_CurrentMenu.anim = nil
			end
		)
		
		addEventHandler('onClientRender', root, renderMenu)
		addEventHandler('onClientClick', root, menuClickHandler)
		showCursor(true)
	else
		hideTextDraw(prevMenu.titletextdraw)
		g_CurrentMenu.closebtn = prevMenu.closebtn
		prevMenu.closebtn = nil
		guiSetPosition(g_CurrentMenu.closebtn, g_CurrentMenu.x + g_CurrentMenu.width - closebtnSide, g_CurrentMenu.y, false)
		g_CurrentMenu.closebtnhover = prevMenu.closebtnhover
		prevMenu.closebtnhover = nil
		guiSetPosition(g_CurrentMenu.closebtnhover, g_CurrentMenu.x + g_CurrentMenu.width - closebtnSide, g_CurrentMenu.y, false)
		g_CurrentMenu.alpha = 1
	end
	showTextDraw(g_CurrentMenu.titletextdraw)
	bindKey('enter', 'down', OnKeyPress)
end

function HideMenuForPlayer(amxName, menuID)
	if g_CurrentMenu and (not menuID or g_CurrentMenu.id == menuID) then
		if g_CurrentMenu.anim then
			g_CurrentMenu.anim:remove()
			g_CurrentMenu.anim = nil
		end
		g_CurrentMenu.anim = Animation.createAndPlay(g_CurrentMenu, { time = 500, from = 1, to = 0, fn = setMenuAlpha }, exitMenu)
	end
end

function DestroyMenu(amxName, menuID)
	local amx = g_AMXs[amxName]
	destroyTextDraw(amx.menus[menuID].titletextdraw)
	if g_CurrentMenu and menuID == g_CurrentMenu.id then
		exitMenu()
	end
	amx.menus[menuID] = nil
end

function setMenuAlpha(menu, alpha)
	menu.alpha = alpha
	menu.titletextdraw.alpha = alpha
	guiSetAlpha(menu.closebtn, .75*alpha)
	guiSetAlpha(menu.closebtnhover, .75*alpha)
end

function closeMenu()
	removeEventHandler('onClientRender', root, renderMenu)
	hideTextDraw(g_CurrentMenu.titletextdraw)
	g_CurrentMenu.titletextdraw.alpha = nil
	removeEventHandler('onClientClick', root, menuClickHandler)
	g_CurrentMenu.anim = nil
	destroyElement(g_CurrentMenu.closebtn)
	g_CurrentMenu.closebtn = nil
	destroyElement(g_CurrentMenu.closebtnhover)
	g_CurrentMenu.closebtnhover = nil
	g_CurrentMenu = nil
	showCursor(false)
	unbindKey('enter', 'down', OnKeyPress)
end

function exitMenu()
	closeMenu()
	serverAMXEvent('OnPlayerExitedMenu', g_PlayerID)
end

function renderMenu()
	local menu = g_CurrentMenu
	if not menu then
		return
	end
	
	-- background
	dxDrawRectangle(menu.x, menu.y, menu.width, menu.height, tocolor(0, 0, 0, 128*menu.alpha))
	
	local cursorX, cursorY = getCursorPosition()
	cursorY = screenHeight*cursorY
	-- selected row
	local selectedRow
	if cursorY >= menu.y + MENU_TOP_PADDING and cursorY < menu.y + menu.height - MENU_BOTTOM_PADDING then
		selectedRow = math.floor((cursorY - menu.y - MENU_TOP_PADDING) / MENU_ITEM_HEIGHT)
		dxDrawRectangle(menu.x, menu.y + MENU_TOP_PADDING + selectedRow*MENU_ITEM_HEIGHT, menu.width, MENU_ITEM_HEIGHT, tocolor(98, 152, 219, 192*menu.alpha))
	end
	
	-- menu items
	for column=0,1 do
		for i,text in pairs(menu.items[column]) do
			local x = menu.x + MENU_SIDE_PADDING + column*menu.leftColumnWidth
			local y
			local color, scale
			if i < 13 then
				-- regular item
				y = menu.y + MENU_TOP_PADDING + (i-1)*MENU_ITEM_HEIGHT
				if menu.disabledrows and table.find(menu.disabledrows, i-1) then
					color = tocolor(100, 100, 100, 255*menu.alpha)
				else
					color = (i-1) == selectedRow and tocolor(255, 255, 255, 255*menu.alpha) or tocolor(180, 180, 180, 255*menu.alpha)
				end
				scale = 0.7
			else
				-- column header
				y = menu.y + MENU_TOP_PADDING - MENU_ITEM_HEIGHT
				color = tocolor(228, 190, 57, 255*menu.alpha)
				scale = 0.8
			end
			drawShadowText(text, x, y + 5, color, scale, 'pricedown')
		end
	end
end

function menuClickHandler(button, state, clickX, clickY)
	if state ~= 'up' then
		return
	end
	if not g_CurrentMenu then
		return
	end
	local cursorX, cursorY = getCursorPosition()
	cursorY = screenHeight*cursorY
	if cursorY < g_CurrentMenu.y + MENU_TOP_PADDING or cursorY > g_CurrentMenu.y + MENU_TOP_PADDING + math.max(#g_CurrentMenu.items[0], #g_CurrentMenu.items[1])*MENU_ITEM_HEIGHT then
		return
	end
	local selectedRow = math.floor((clickY - g_CurrentMenu.y - MENU_TOP_PADDING) / MENU_ITEM_HEIGHT)
	if not (g_CurrentMenu.disabledrows and table.find(g_CurrentMenu.disabledrows, selectedRow)) then
		serverAMXEvent('OnPlayerSelectedMenuRow', g_PlayerID, selectedRow)
		exitMenu()
	end
end

function OnKeyPress(key, keyState)
	if ( keyState == "down" ) then
		exitMenu()
	end
end

-----------------------------
-- Others

function enableWeaponSyncing(enable)
	if enable and not g_WeaponSyncTimer then
		g_WeaponSyncTimer = setTimer(sendWeapons, 5000, 0)
	elseif not enable and g_WeaponSyncTimer then
		killTimer(g_WeaponSyncTimer)
		g_WeaponSyncTimer = nil
	end
end

local prevWeapons
function sendWeapons()
	local weapons = {}
	local needResync = false
	for slot=0,12 do
		weapons[slot] = { id = getPedWeapon(g_Me, slot), ammo = getPedTotalAmmo(g_Me, slot) }
		if not needResync and (not prevWeapons or prevWeapons[slot].ammo ~= weapons[slot].ammo or prevWeapons[slot].id ~= weapons[slot].id) then
			needResync = true
		end
	end
	if needResync then
		server.syncPlayerWeapons(g_Me, weapons)
		prevWeapons = weapons
	end
end

function RemovePlayerMapIcon(amxName, blipID)
	local amx = g_AMXs[amxName]
	if amx.blips[blipID] then
		destroyElement(amx.blips[blipID])
		amx.blips[blipID] = nil
	end
end

function SetPlayerMapIcon(amxName, blipID, x, y, z, type, r, g, b, a)
	for name,amx in pairs(g_AMXs) do
		if amx.blips[blipID] then
			destroyElement(amx.blips[blipID])
			amx.blips[blipID] = nil
		end
	end
	g_AMXs[amxName].blips[blipID] = createBlip(x, y, z, type, 2, r, g, b, a)
end

function SetPlayerWorldBounds(amxName, xMax, xMin, yMax, yMin)
	g_WorldBounds = g_WorldBounds or {}
	g_WorldBounds.xmin, g_WorldBounds.ymin, g_WorldBounds.xmax, g_WorldBounds.ymax = xMin, yMin, xMax, yMax
	if not g_WorldBounds.handled then
		addEventHandler('onClientRender', root, checkWorldBounds)
		g_WorldBounds.handled = true
	end
end

function checkWorldBounds()
	if g_ClassSelectionInfo and g_ClassSelectionInfo.gui then
		return
	end
	
	local x, y, z, vx, vy, vz
	local elem = getPedOccupiedVehicle(g_Me)
	local isVehicle
	
	if elem then
		if getVehicleController(elem) == g_Me then
			isVehicle = true
			vx, vy, vz = getElementVelocity(elem)
		else
			return
		end
	else
		elem = g_Me
		isVehicle = false
	end
	local bounds = g_WorldBounds
	x, y, z = getElementPosition(elem)
	
	local changed = false
	if x < bounds.xmin then
		x = bounds.xmin
		if isVehicle and vx < 0 then
			vx = -vx
		end
		changed = true
	elseif x > bounds.xmax then
		x = bounds.xmax
		if isVehicle and vx > 0 then
			vx = -vx
		end
		changed = true
	end
	if y < bounds.ymin then
		y = bounds.ymin
		if isVehicle and vy < 0 then
			vy = -vy
		end
		changed = true
	elseif y > bounds.ymax then
		y = bounds.ymax
		if isVehicle and vy > 0 then
			vy = -vy
		end
		changed = true
	end
	if changed then
		if isVehicle then
			setElementVelocity(elem, vx, vy, vz)
		else
			setElementPosition(elem, x, y, z)
		end
		if not gameText then
			local name, amx = next(g_AMXs)
			GameTextForPlayer(name, 'Don\'t leave the ~r~world boundaries!', 2000)
		end
	end
end

function SetPlayerMarkerForPlayer(amxName, blippedPlayer, r, g, b, a)
	if a == 0 then
		destroyBlipsAttachedTo(blippedPlayer)
	else
		createBlipAttachedTo(blippedPlayer, 0, 2, r, g, b, a)
	end
end

function TogglePlayerClock(amxName, toggle)
	setMinuteDuration(toggle and 1000 or 2147483647)
	showPlayerHudComponent('clock', toggle)
end

function createListDialog()
		listDialog = nil
		listWindow = guiCreateWindow(screenWidth/2 - 541/2,screenHeight/2 - 352/2,541,352,"",false)
		guiWindowSetMovable(listWindow,false)
		guiWindowSetSizable(listWindow,false)
		listGrid = guiCreateGridList(9,19,523,300,false,listWindow)
		guiGridListSetSelectionMode(listGrid,2)
		guiGridListSetScrollBars(listGrid, true, true)
		listColumn = guiGridListAddColumn(listGrid, "List", 0.85)
		listButton1 = guiCreateButton(10,323,256,20,"",false,listWindow)
		listButton2 = guiCreateButton(281,323,256,20,"",false,listWindow)
		guiSetVisible(listWindow, false)
		addEventHandler("onClientGUIClick", listButton1, OnListDialogButton1Click, false)
		addEventHandler("onClientGUIClick", listButton2, OnListDialogButton2Click, false)
end

function createInputDialog()	
		inputDialog = nil
		inputWindow = guiCreateWindow(screenWidth/2 - 541/2,screenHeight/2 - 352/2,541,352,"",false)
		guiWindowSetMovable(listWindow,false)
		guiWindowSetSizable(listWindow,false)
		inputLabel = guiCreateLabel(9, 19, 523, 270, "", false, inputWindow)
		inputEdit = guiCreateEdit(9,290,523,30,"",false,inputWindow)
		inputButton1 = guiCreateButton(10,323,256,20,"",false,inputWindow)
		inputButton2 = guiCreateButton(281,323,256,20,"",false,inputWindow)
		guiSetVisible(inputWindow, false)
		addEventHandler("onClientGUIClick", inputButton1, OnInputDialogButton1Click, false)
		addEventHandler("onClientGUIClick", inputButton2, OnInputDialogButton2Click, false)
end

function createMessageDialog()
		msgDialog = nil
		msgWindow = guiCreateWindow(screenWidth/2 - 541/2,screenHeight/2 - 352/2,541,352,"",false)
		guiWindowSetMovable(msgWindow,false)
		guiWindowSetSizable(msgWindow,false)
		msgLabel = guiCreateLabel(9, 19, 523, 300, "", false, msgWindow)
		msgButton1 = guiCreateButton(10,323,256,20,"",false,msgWindow)
		msgButton2 = guiCreateButton(281,323,256,20,"",false,msgWindow)
		guiSetVisible(msgWindow, false)
		addEventHandler("onClientGUIClick", msgButton1, OnMessageDialogButton1Click, false)
		addEventHandler("onClientGUIClick", msgButton2, OnMessageDialogButton2Click, false)
end

function InitDialogs()
	createListDialog()
	createInputDialog()
	createMessageDialog()
end

function OnListDialogButton1Click( button, state )
	if button == "left" then
		local row, column = guiGridListGetSelectedItem(listGrid)
		local text = guiGridListGetItemText(listGrid, row, column)
		serverAMXEvent("OnDialogResponse", getElemID(getLocalPlayer()), listDialog, 1, row, text);
		guiSetVisible(listWindow, false)
		guiGridListClear(listGrid)
		showCursor(false)
		listDialog = nil
	end
end

function OnListDialogButton2Click( button, state )
	if button == "left" then
		local row, column = guiGridListGetSelectedItem(listGrid)
		local text = guiGridListGetItemText(listGrid, row, column)
		serverAMXEvent("OnDialogResponse", getElemID(getLocalPlayer()), listDialog, 0, row, text);
		guiSetVisible(listWindow, false)
		guiGridListClear(listGrid)
		showCursor(false)
		listDialog = nil
	end
end

function OnInputDialogButton1Click( button, state )
	if button == "left" then
		serverAMXEvent("OnDialogResponse", getElemID(getLocalPlayer()), inputDialog, 1, 0, guiGetText(inputEdit));
		guiSetVisible(inputWindow, false)
		showCursor(false)
		inputDialog = nil
	end
end

function OnInputDialogButton2Click( button, state )
	if button == "left" then
		serverAMXEvent("OnDialogResponse", getElemID(getLocalPlayer()), inputDialog, 0, 0, guiGetText(inputEdit));
		guiSetVisible(inputWindow, false)
		showCursor(false)
		inputDialog = nil
	end
end

function OnMessageDialogButton1Click( button, state )
	if button == "left" then
		serverAMXEvent("OnDialogResponse", getElemID(getLocalPlayer()), msgDialog, 1, 0, "");
		guiSetVisible(msgWindow, false)
		showCursor(false)
		msgDialog = nil
	end
end

function OnMessageDialogButton2Click( button, state )
	if button == "left" then
		serverAMXEvent("OnDialogResponse", getElemID(getLocalPlayer()), msgDialog, 0, 0, "");
		guiSetVisible(msgWindow, false)
		msgDialog = nil
		showCursor(false)
	end
end


function ShowPlayerDialog(amxName, dialogid, dialogtype, caption, info, button1, button2)
	if dialogtype == 0 then
		guiSetText(msgButton1, button1)
		guiSetText(msgButton2, button2)
		guiSetText(msgWindow, caption)
		guiSetText(msgLabel, info)
		guiSetVisible(msgWindow, true)
		msgDialog = dialogid
		showCursor(true)
	elseif dialogtype == 1 then
		guiSetText(inputButton1, button1)
		guiSetText(inputButton2, button2)
		guiSetText(inputWindow, caption)
		guiSetText(inputEdit, "")
		guiSetText(inputLabel, info)
		guiSetVisible(inputWindow, true)
		inputDialog = dialogid
		showCursor(true)
	elseif dialogtype == 2 then
		guiSetText(listButton1, button1)
		guiSetText(listButton2, button2)
		guiSetText(listWindow, caption)
		guiSetVisible(listWindow, true)
		listDialog = dialogid
		showCursor(true)
		local items = string.gsub(info, "\t", "        ")
		items = string.split(items, "\n")
		for k,v in ipairs(items) do
			local row = guiGridListAddRow ( listGrid )
			guiGridListSetItemText ( listGrid, row, listColumn, v, false, true)
		end
	end
end

addEvent ( "onPlayerClickPlayer" )
function OnPlayerClickPlayer ( element )
	serverAMXEvent('OnPlayerClickPlayer', getElemID(getLocalPlayer()), getElemID(element), 0)
end
addEventHandler ( "onPlayerClickPlayer", getRootElement(), OnPlayerClickPlayer )


