local commands = {}
local customSpawnTable = false
local allowedStyles =
{
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[15] = true,
	[16] = true,
}
local internallyBannedWeapons = -- Fix for some debug warnings
{
	[19] = true,
	[20] = true,
	[21] = true,
}
local server = setmetatable(
		{},
		{
			__index = function(t, k)
				t[k] = function(...) triggerServerEvent('onServerCall', resourceRoot, k, ...) end
				return t[k]
			end
		}
	)
guiSetInputMode("no_binds_when_editing")
setCameraClip(true, false)

local antiCommandSpam = {} -- Place to store the ticks for anti spam:
local playerGravity = getGravity() -- Player's current gravity set by gravity window --
local knifeRestrictionsOn = false

-- Local settings received from server
local g_settings = {}
local _addCommandHandler = addCommandHandler
local _setElementPosition = setElementPosition

if not (g_PlayerData) then
    g_PlayerData = {}
end

-- Variables for time freeze
local freezeTimeHour = false
local freezeTimeMinute = false
local freezeTimeWeather = false

-- Settings are stored in meta.xml
function freeroamSettings(settings)
	if settings then
		g_settings = settings
		for _,gui in ipairs(disableBySetting) do
			guiSetEnabled(getControl(gui.parent,gui.id),g_settings["gui/"..gui.id])
		end
	end
end

-- Store the tries for forced global cooldown
local global_cooldown = 0
function isFunctionOnCD(func, exception)
	local tick = getTickCount()
	-- check if a global cd is active
	if g_settings.command_spam_protection and global_cooldown ~= 0 then
		if tick - global_cooldown <= g_settings.command_spam_ban_duration then
			local duration = math.ceil((g_settings.command_spam_ban_duration-tick+global_cooldown)/1000)
			errMsg("You are banned from using commands for " .. duration .." seconds due to continuous spam")
			return true
		end
	end

	if not g_settings.command_spam_protection then
		return false
	end

	if not antiCommandSpam[func] then
		antiCommandSpam[func] = {time = tick, tries = 1}
		return false
	end

	local oldTime = antiCommandSpam[func].time
	if (tick-oldTime) > 2000 then
		antiCommandSpam[func].time = tick
		antiCommandSpam[func].tries = 1
		return false
	end

	antiCommandSpam[func].tries = antiCommandSpam[func].tries + 1

	if exception and (antiCommandSpam[func].tries < g_settings.g_settings.tries_required_to_trigger_low_priority) then
		return false
	end

	if (exception == nil) and (antiCommandSpam[func].tries < g_settings.tries_required_to_trigger) then
		return false
	end

	-- activate a global command cooldown
	global_cooldown = tick
	antiCommandSpam[func].tries = 0
	errMsg("Failed, do not spam the commands!")
	return true
end

local function executeCommand(cmd,...)

	local func = commands[cmd]
	cmd = string.lower(cmd)
	if not commands[cmd] then return end
	if table.find(g_settings["command_exception_commands"],cmd) then
		func(cmd,...)
		return
	end
	if isFunctionOnCD(func) then return end
	func(cmd,...)

end

local function addCommandHandler(cmd,func)

	commands[cmd] = func
	_addCommandHandler(cmd,executeCommand,false,false)

end

local function cancelKnifeEvent(target)

	if knifingDisabled then
		cancelEvent()
		errMsg("Knife restrictions are in place")
	end

	if g_PlayerData[localPlayer].knifing or g_PlayerData[target].knifing then
		cancelEvent()
	end
end
addEventHandler("onClientPlayerStealthKill",localPlayer,cancelKnifeEvent)

local function resetKnifing()

	knifeRestrictionsOn = false

end

local function setElementPosition(element,x,y,z)

	if g_settings["weapons/kniferestrictions"] and not knifeRestrictionsOn then
		knifeRestrictionsOn = true
		setTimer(resetKnifing,5000,1)
	end

	_setElementPosition(element,x,y,z)

end

---------------------------
-- Set skin window
---------------------------
function skinInit()
	setControlNumber(wndSkin, 'skinid', getElementModel(localPlayer))
end

function showSkinID(leaf)
	if leaf.id then
		setControlNumber(wndSkin, 'skinid', leaf.id)
	end
end

function applySkin()
	local skinID = getControlNumber(wndSkin, 'skinid')
	if skinID then
		server.setMySkin(skinID)
		fadeCamera(true)
	end
end

wndSkin = {
	'wnd',
	text = 'Set skin',
	width = 250,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='skinlist',
			width=230,
			height=290,
			columns={
				{text='Skin', attr='name'}
			},
			rows={xml='data/skins.xml', attrs={'id', 'name'}},
			onitemclick=showSkinID,
			onitemdoubleclick=applySkin,
			DoubleClickSpamProtected=true,
		},
		{'txt', id='skinid', text='', width=50},
		{'btn', id='set', onclick=applySkin, ClickSpamProtected = true},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = skinInit
}

function setSkinCommand(cmd, skin)

	if isPlayerMoving(localPlayer) then
		errMsg("You can't use /ss while running! Stop moving first!")
		return
	end

	skin = skin and tonumber(skin)
	if skin then
		server.setMySkin(skin)
		fadeCamera(true)
		closeWindow(wndSpawnMap)
		closeWindow(wndSetPos)
	else
		errMsg("Invalid skin ID! Usage: /ss [id]")
	end
end
addCommandHandler('setskin', setSkinCommand)
addCommandHandler('ss', setSkinCommand)

---------------------------
--- Set animation window
---------------------------

function applyAnimation(leaf)
	if isPlayerAiming(localPlayer) then
		errMsg("You cannot perform animations while actively aiming a weapon!")
		return
	end

	if isPedReloadingWeapon(localPlayer) then
		errMsg("You cannot perform animations while reloading a weapon!")
		return
	end

	if type(leaf) ~= "table" then
		leaf = getSelectedGridListLeaf(wndAnim, "animlist")
		if not leaf or not leaf.parent.name or not leaf.name or string.len(leaf.name) > 25 or string.len(leaf.parent.name) > 25
		 then errMsg("Invalid animation request")
			return
		end
	end
	server.setPedAnimation(localPlayer, leaf.parent.name, leaf.name, true, true)
end

function stopAnimation()
	if getPedAnimation(localPlayer) then
		server.setPedAnimation(localPlayer, false)
	end
end
addCommandHandler('stopanim', stopAnimation)
bindKey("lshift", "down", stopAnimation)

wndAnim = {
	'wnd',
	text = 'Set animation',
	width = 250,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='animlist',
			width=230,
			height=290,
			columns={
				{text='Animation', attr='name'}
			},
			rows={xml='data/animations.xml', attrs={'name'}},
			expandlastlevel=false,
			onitemdoubleclick=applyAnimation,
			DoubleClickSpamProtected=true,
		},
		{'btn', id='set', onclick=applyAnimation, ClickSpamProtected=true},
		{'btn', id='stop', onclick=stopAnimation},
		{'btn', id='close', closeswindow=true}
	}
}

addCommandHandler('anim',
	function(command, lib, name)

		if not lib or not name then
			return errMsg("Invalid animation! Rule of thumb: Provide both library and anim name!")
		end

		if not tostring(lib) or not tostring(name) then
			return errMsg("Invalid animation!")
		end

		if string.len(lib) > 40 or string.len(name) > 40 then
			return errMsg("Invalid animation!")
		end

		if isPlayerAiming(localPlayer) then errMsg ("You cannot perform animations while actively aiming a weapon!") return end
		if isPedReloadingWeapon(localPlayer) then errMsg ("You cannot perform animations while reloading a weapon!") return end

		if lib and name and (
			(lib:lower() == "finale" and name:lower() == "fin_jump_on") or
			(lib:lower() == "finale2" and name:lower() == "fin_cop1_climbout")
		) then
			errMsg('This animation may not be set by command.')
			return
		end
		server.setPedAnimation(localPlayer, lib, name, true, true)
	end
)

---------------------------
-- Weapon window
---------------------------

function addWeapon(leaf, amount)
	if type(leaf) ~= 'table' then
		leaf = getSelectedGridListLeaf(wndWeapon, 'weaplist')
		amount = getControlNumber(wndWeapon, 'amount')
		if not amount or not leaf or not leaf.id then
			return
		end
	end
	if amount < 1 or amount > 999999999 then
		errMsg("Invalid amount!")
		return
	end
	if isPedReloadingWeapon(localPlayer) then
		errMsg ("You can't get weapons while reloading a weapon!")
		return
	end
	if isPlayerAiming(localPlayer) then
		errMsg ("You can't get weapons while aiming a weapon!")
		return
	end
	server.giveMeWeapon(leaf.id, amount)
end

function isPlayerAiming(p)
	if isElement(p) then
		if getPedTask(p, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(p) then
			return true
		end
	end
	return false
end

wndWeapon = {
	'wnd',
	text = 'Give weapon',
	width = 250,
	controls = {
		{
			'lst',
			id='weaplist',
			width=230,
			height=280,
			columns={
				{text='Weapon', attr='name'}
			},
			rows={xml='data/weapons.xml', attrs={'id', 'name'}},
			onitemdoubleclick=function(leaf) addWeapon(leaf, 1500) end,
			DoubleClickSpamProtected=true
		},
		{'br'},
		{'txt', id='amount', text='1500', width=60},
		{'btn', id='add', onclick=addWeapon, ClickSpamProtected=true},
		{'btn', id='close', closeswindow=true}
	}
}

function giveWeaponCommand(cmd, weapon, amount)

	if weapon and string.len(weapon) > 25 then errMsg("Invalid weapon name/ID!") return end
	if amount and string.len(amount) > 9 then errMsg("Invalid amount!") return end

	weapon = tonumber(weapon) and math.floor(tonumber(weapon)) or weapon and getWeaponIDFromName(weapon) or 0
	amount = tonumber(amount) and math.floor(tonumber(amount)) or 2500

	if not weapon then errMsg("Invalid weapon! Syntax: /wp [weapon id/name]") return end
	if not amount or amount < 1 or amount > 999999999 or weapon < 1 or weapon > 46 then return end
	if internallyBannedWeapons[weapon] then return end
	if isPlayerAiming(localPlayer) then errMsg ("You can't get weapons while aiming a weapon or driveby'ing!") return end
	if isPedReloadingWeapon(localPlayer) then errMsg ("You can't use this command while reloading a weapon!") return end
	if weapon == 39 or weapon == 40 then errMsg ("You can't get Satchels with /wp command! Use F1 > weapons instead!") return end
	server.giveMeWeapon(weapon, amount)
end
addCommandHandler('give', giveWeaponCommand)
addCommandHandler('wp', giveWeaponCommand)

---------------------------
-- Fighting style
---------------------------

addCommandHandler("setstyle",
	function(cmd, style)
		style = style and tonumber(style) or 5

		if getPedFightingStyle(localPlayer) == style then
			return
		end

		if allowedStyles[style] then
			server.setPedFightingStyle(localPlayer, style)
		else
			errMsg("Invalid style ID!")
			return
		end
	end
)

---------------------------
-- Clothes window
---------------------------
function clothesInit()
	if getElementModel(localPlayer) ~= 0 then
		errMsg('You must have the CJ skin set in order to apply clothes.')
		closeWindow(wndClothes)
		return
	end
	if not g_Clothes then
		triggerServerEvent('onClothesInit', resourceRoot)
	end
end

addEvent('onClientClothesInit', true)
addEventHandler('onClientClothesInit', resourceRoot,
	function(clothes)
		g_Clothes = clothes.allClothes
		for i,typeGroup in ipairs(g_Clothes) do
			for j,cloth in ipairs(typeGroup.children) do
				if not cloth.name then
					cloth.name = cloth.model .. ' - ' .. cloth.texture
				end
				cloth.wearing =
					clothes.playerClothes[typeGroup.type] and
					clothes.playerClothes[typeGroup.type].texture == cloth.texture and
					clothes.playerClothes[typeGroup.type].model == cloth.model
					or false
			end
			table.sort(typeGroup.children, function(a, b) return a.name < b.name end)
		end
		bindGridListToTable(wndClothes, 'clothes', g_Clothes, false)
	end
)

function clothListClick(cloth)
	setControlText(wndClothes, 'addremove', cloth.wearing and 'remove' or 'add')
end

function applyClothes(cloth)
	if not cloth then
		cloth = getSelectedGridListLeaf(wndClothes, 'clothes')
		if not cloth then
			return
		end
	end
	if cloth.wearing then
		cloth.wearing = false
		setControlText(wndClothes, 'addremove', 'add')
		server.removePedClothes(localPlayer, cloth.parent.type)
	else
		local prevClothIndex = table.find(cloth.siblings, 'wearing', true)
		if prevClothIndex then
			cloth.siblings[prevClothIndex].wearing = false
		end
		cloth.wearing = true
		setControlText(wndClothes, 'addremove', 'remove')
		server.addPedClothes(localPlayer, cloth.texture, cloth.model, cloth.parent.type)
	end
end

wndClothes = {
	'wnd',
	text = 'Clothes',
	x = -20,
	y = 0.3,
	width = 350,
	controls = {
		{
			'lst',
			id='clothes',
			width=330,
			height=390,
			columns={
				{text='Clothes', attr='name', width=0.6},
				{text='Wearing', attr='wearing', enablemodify=true, width=0.3}
			},
			rows={
				{name='Retrieving clothes list...'}
			},
			onitemclick=clothListClick,
			onitemdoubleclick=applyClothes,
			DoubleClickSpamProtected=true,
		},
		{'br'},
		{'btn', text='add', id='addremove', width=60, onclick=applyClothes, ClickSpamProtected=true},
		{'btn', id='outfits', onclick=function() createWindow(wndOutfits) end},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = clothesInit
}

function addClothesCommand(cmd, type, model, texture)
	type = type and tonumber(type)

	if string.len(type) > 30 or string.len(model) > 30 or string.len(texture) > 30 then
		errMsg("Invalid clothes input!")
		return
	end

	if type and model and texture then
		server.addPedClothes(localPlayer, texture, model, type)
	end
end
addCommandHandler('addclothes', addClothesCommand)
addCommandHandler('ac', addClothesCommand)

function removeClothesCommand(cmd, type)
	type = type and tonumber(type)
	if type and string.len(type) < 30 then
		server.removePedClothes(localPlayer, type)
	end
end
addCommandHandler('removeclothes', removeClothesCommand)
addCommandHandler('rc', removeClothesCommand)

---------------------------
-- Outfits window
---------------------------

local outfitList
local outfits

function initOutfits()
	outfitList = wndOutfits.controls[1].element
	if outfits then return end
	loadOutfits()
	addEventHandler('onClientGUIDoubleClick', outfitList, loadClothes)
end

function loadOutfits()
	outfits = {}

	local xml = xmlLoadFile('outfits.xml')
	if not xml then
		xml = xmlCreateFile('outfits.xml', 'catalog')
	end
	guiGridListClear(outfitList)
	for i,child in ipairs (xmlNodeGetChildren(xml) or {}) do
		local row = guiGridListAddRow(outfitList)
		guiGridListSetItemText(outfitList, row, 1, tostring(xmlNodeGetAttribute(child, 'name')), false, false)
		outfits[row+1] = {}
		for j=0,17 do
			table.insert(outfits[row+1], j, xmlNodeGetAttribute(child, 'c'..j))
		end
	end
end

function saveOutfits()
	if fileExists('outfits.xml') then
		fileDelete('outfits.xml')
	end
	local xml = xmlCreateFile('outfits.xml', 'catalog')
	for row=0,(guiGridListGetRowCount(outfitList)-1) do
		local child = xmlCreateChild(xml, 'outfit')
		xmlNodeSetAttribute(child, 'name', guiGridListGetItemText(outfitList, row, 1))
		for k,v in pairs (outfits[row+1]) do
			xmlNodeSetAttribute(child, 'c'..k,v)
		end
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function saveOutfit()
	local name = getControlText(wndOutfits,'outfitname')
	if name ~= "" then
		local row = guiGridListAddRow(outfitList)
		outfits[row+1] = {}
		for i=0,17 do
			local texture,model = getPedClothes (localPlayer, i)
			if texture and model then
				table.insert(outfits[row+1], i, texture ..', '.. model)
			else
				table.insert(outfits[row+1], i, 'none')
			end
		end
		guiGridListSetItemText(outfitList, row, 1, name, false, false)
		setControlText(wndOutfits, 'outfitname', '')
		saveOutfits()
	else
		outputChatBox('Please enter a name for the outfit')
	end
end

function deleteOutfit()
	local row = guiGridListGetSelectedItem(outfitList)
	if row and row ~= -1 then
		table.remove(outfits, row+1)
		guiGridListRemoveRow(outfitList, row)
		saveOutfits()
	end
end

function loadClothes()
	local row = guiGridListGetSelectedItem(outfitList)
	if row and row ~= -1 then
		for k,v in pairs (outfits[row+1]) do
			if v ~= 'none' then
				local clothes = split(v, ', ')
				server.addPedClothes(localPlayer, clothes[1], clothes[2], k)
			else
				server.removePedClothes(localPlayer, k)
			end
		end
	end
end

wndOutfits = {
	'wnd',
	text = 'Outfits',
	width = 170,
	x = -400,
	y = 0.3,
	controls = {
		{
			'lst',
			id='outfits',
			width=150,
			height=250,
			columns={
				{text='Name', attr='name', width=0.85},
			}
		},
		{'txt', id='outfitname', text='', width=100},
		{'btn', id='save', onclick=saveOutfit, width=45},
		{'btn', id='delete selected', onclick=deleteOutfit, width=100},
		{'btn', id='close', closeswindow=true, width=45}
	},
	oncreate = initOutfits
}
---------------------------
-- Player gravity window
---------------------------
function playerGravInit()
	triggerServerEvent('onPlayerGravInit',localPlayer)
end

addEvent('onClientPlayerGravInit', true)
addEventHandler('onClientPlayerGravInit', resourceRoot,
	function(curgravity)
		setControlText(wndGravity, 'gravval', string.sub(tostring(curgravity), 1, 6))
	end
)

function selectPlayerGrav(leaf)
	setControlNumber(wndGravity, 'gravval', leaf.value)
end

function applyPlayerGrav()
	local grav = getControlNumber(wndGravity, 'gravval')
	if grav then
		playerGravity = grav
		server.setPedGravity(localPlayer, grav)
	end
	closeWindow(wndGravity)
end

function setGravityCommand(cmd, grav)
	local grav = grav and tonumber(grav)
	if grav then
		playerGravity = grav
		server.setPedGravity(localPlayer, tonumber(grav))
	end
end
addCommandHandler('setgravity', setGravityCommand)
addCommandHandler('grav', setGravityCommand)

wndGravity = {
	'wnd',
	text = 'Set gravity',
	width = 300,
	controls = {
		{
			'lst',
			id='gravlist',
			width=280,
			height=200,
			columns={
				{text='Gravity', attr='name'}
			},
			rows={
				{name='Space', value=0},
				{name='Moon', value=0.001},
				{name='Normal', value=0.008},
				{name='Strong', value=0.015}
			},
			onitemclick=selectPlayerGrav,
			onitemdoubleclick=applyPlayerGrav,
			DoubleClickSpamProtected=true,
		},
		{'lbl', text='Exact value: '},
		{'txt', id='gravval', text='', width=80},
		{'br'},
		{'btn', id='ok', onclick=applyPlayerGrav,ClickSpamProtected=true},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = playerGravInit
}

---------------------------
-- Warp to player window
---------------------------

local function warpMe(targetPlayer)

	if not g_settings["warp"] then
		errMsg("Warping is disallowed!")
		return
	end

	if targetPlayer == localPlayer then
		errMsg("You can't warp to yourself!")
		return
	end

	if g_PlayerData[targetPlayer].warping then
		errMsg("This player has disabled warping to them!")
		return
	end

	local vehicle = getPedOccupiedVehicle(targetPlayer)
	local interior = getElementInterior(targetPlayer)
	if not vehicle then
		-- target player is not in a vehicle - just warp next to him
		local vec = targetPlayer.position + targetPlayer.matrix.right*2
		local x, y, z = vec.x,vec.y,vec.z
		if localPlayer.interior ~= interior then
			fadeCamera(false,1)
			setTimer(setPlayerInterior,1000,1,x,y,z,interior)
		else
			setPlayerPosition(x,y,z)
		end
	else
		-- target player is in a vehicle - warp into it if there's space left
		server.warpMeIntoVehicle(vehicle)
	end

end

function warpInit()
	setControlText(wndWarp, 'search', '')
	warpUpdate()
end

function warpTo(leaf)
	if not leaf then
		leaf = getSelectedGridListLeaf(wndWarp, 'playerlist')
		if not leaf then
			return
		end
	end
	if isElement(leaf.player) then
		warpMe(leaf.player)
	end
	closeWindow(wndWarp)
end

function warpUpdate()
	local function getPlayersByPartName(text)
		if not text or text == '' then
			return getElementsByType("player")
		else
			local players = {}
			for _, player in ipairs(getElementsByType("player")) do
				if string.find(getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):upper(), text:upper(), 1, true) then
					table.insert(players, player)
				end
			end
			return players
		end
	end

	local text = getControlText(wndWarp, 'search')
	local players = table.map(getPlayersByPartName(text),
		function(p)
			local pName = getPlayerName(p)
			if g_settings["hidecolortext"] then
				pName = pName:gsub("#%x%x%x%x%x%x", "")
			end
			return { player = p, name = pName }
		end)
	table.sort(players, function(a, b) return a.name < b.name end)
	bindGridListToTable(wndWarp, 'playerlist', players, true)
end

wndWarp = {
	'wnd',
	text = 'Warp to player',
	width = 300,
	controls = {
		{'txt', id='search', text='', width = 280, onchanged=warpUpdate},
		{
			'lst',
			id='playerlist',
			width=280,
			height=330,
			columns={
				{text='Player', attr='name'}
			},
			onitemdoubleclick=warpTo,
			DoubleClickSpamProtected=true,
		},
		{'btn', id='warp', onclick=warpTo, ClickSpamProtected=true},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = warpInit
}

function warpToCommand(cmd, player)
	if player then
		player = getPlayerFromName(player)
		if player then
			warpMe(player)
		end
	else
		createWindow(wndWarp)
		showCursor(true)
	end
end

addCommandHandler('warpto', warpToCommand)
addCommandHandler('wt', warpToCommand)

---------------------------
-- Stats window
---------------------------

function initStats()
	applyToLeaves(getGridListCache(wndStats, 'statslist'), function(leaf) leaf.value = getPedStat(localPlayer, leaf.id) end)
end

function selectStat(leaf)
	setControlNumber(wndStats, 'statval', leaf.value)
end

function maxStat(leaf)
	setControlNumber(wndStats, 'statval', 1000)
	applyStat()
end

function applyStat()
	local leaf = getSelectedGridListLeaf(wndStats, 'statslist')
	if not leaf then
		return
	end
	local value = getControlNumber(wndStats, 'statval')
	if not value then
		return
	end
	leaf.value = value
	server.setPedStat(localPlayer, leaf.id, value)
end

wndStats = {
	'wnd',
	text = 'Stats',
	width = 300,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='statslist',
			width=280,
			columns={
				{text='Stat', attr='name', width=0.6},
				{text='Value', attr='value', width=0.3, enablemodify=true}
			},
			rows={xml='data/stats.xml', attrs={'name', 'id'}},
			onitemclick=selectStat,
			onitemdoubleclick=maxStat,
			DoubleClickSpamProtected=true
		},
		{'txt', id='statval', text='', width=60},
		{'btn', id='set', onclick=applyStat, ClickSpamProtected=true},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = initStats
}

---------------------------
-- Bookmarks window
---------------------------

local bookmarkList
local bookmarks

function initBookmarks ()
	bookmarkList = wndBookmarks.controls[1].element
	if bookmarks then return end
	loadBookmarks ()
	addEventHandler("onClientGUIDoubleClick",bookmarkList,gotoBookmark)
end

function loadBookmarks ()
	bookmarks = {}
	local xml = xmlLoadFile("bookmarks.xml")
	if not xml then
		xml = xmlCreateFile("bookmarks.xml","catalog")
	end
	guiGridListClear(bookmarkList)
	for i,child in ipairs (xmlNodeGetChildren(xml) or {}) do
		local row = guiGridListAddRow(bookmarkList)
		guiGridListSetItemText(bookmarkList,row,1,tostring(xmlNodeGetAttribute(child,"name")),false,false)
		guiGridListSetItemText(bookmarkList,row,2,tostring(xmlNodeGetAttribute(child,"zone")),false,false)
		bookmarks[row+1] = {tonumber(xmlNodeGetAttribute(child,"x")),tonumber(xmlNodeGetAttribute(child,"y")),tonumber(xmlNodeGetAttribute(child,"z"))}
	end
	xmlUnloadFile(xml)
end

function saveBookmarks ()
	if fileExists("bookmarks.xml") then
		fileDelete("bookmarks.xml")
	end
	local xml = xmlCreateFile("bookmarks.xml","catalog")
	for row=0,(guiGridListGetRowCount(bookmarkList)-1) do
		local child = xmlCreateChild(xml,"bookmark")
		xmlNodeSetAttribute(child,"name",guiGridListGetItemText(bookmarkList,row,1))
		xmlNodeSetAttribute(child,"zone",guiGridListGetItemText(bookmarkList,row,2))
		xmlNodeSetAttribute(child,"x",tostring(bookmarks[row+1][1]))
		xmlNodeSetAttribute(child,"y",tostring(bookmarks[row+1][2]))
		xmlNodeSetAttribute(child,"z",tostring(bookmarks[row+1][3]))
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function saveLocation ()
	local name = getControlText(wndBookmarks,"bookmarkname")
	if name ~= "" then
		local x,y,z = getElementPosition(localPlayer)
		local zone = getZoneName(x,y,z,false)
		if x and y and z then
			local row = guiGridListAddRow(bookmarkList)
			guiGridListSetItemText(bookmarkList,row,1,name,false,false)
			guiGridListSetItemText(bookmarkList,row,2,zone,false,false)
			bookmarks[row+1] = {x,y,z}
			setControlText(wndBookmarks,"bookmarkname","")
			saveBookmarks()
		end
	else
		errMsg("Please enter a name for the bookmark")
	end
end

function deleteLocation ()
	local row,column = guiGridListGetSelectedItem(bookmarkList)
	if row and row ~= -1 then
		table.remove(bookmarks,row+1)
		guiGridListRemoveRow(bookmarkList,row)
		saveBookmarks()
	end
end

function gotoBookmark ()
	local row = guiGridListGetSelectedItem(bookmarkList)
	if row and row ~= -1 then
		setPlayerPosition(unpack(bookmarks[row+1]))
	end
end

wndBookmarks = {
	'wnd',
	text = 'Bookmarks',
	width = 400,
	x = -300,
	y = 0.2,
	controls = {
		{
			'lst',
			id='bookmarklist',
			width=400,
			columns={
				{text='Name', attr='name', width=0.3},
				{text='Zone', attr='zone', width=0.6}
			}
		},
		{'txt', id='bookmarkname', text='', width=225},
		{'btn', id='save current location', onclick=saveLocation, width=150},
		{'btn', id='delete selected location', onclick=deleteLocation, width=225},
		{'btn', id='close', closeswindow=true, width=150}
	},
	oncreate = initBookmarks
}

---------------------------
-- Jetpack toggle
---------------------------
function toggleJetPack()
	if not doesPedHaveJetPack(localPlayer) then
		server.givePedJetPack(localPlayer)
		guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), true)
	else
		server.removePedJetPack(localPlayer)
		guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), false)
	end
end

bindKey('j', 'down', toggleJetPack)

addCommandHandler('jetpack', toggleJetPack)
addCommandHandler('jp', toggleJetPack)


---------------------------
-- Fall off bike toggle
---------------------------
function toggleFallOffBike()
	setPedCanBeKnockedOffBike(localPlayer, guiCheckBoxGetSelected(getControl(wndMain, 'falloff')))
end

---------------------------
-- Set position window
---------------------------
do
	local screenWidth, screenHeight = guiGetScreenSize()
	g_MapSide = (screenHeight * 0.85)
end

function setPosInit()
	local x, y, z = getElementPosition(localPlayer)
	setControlNumbers(wndSetPos, { x = x, y = y, z = z })

	addEventHandler('onClientRender', root, updatePlayerBlips)
end

function fillInPosition(relX, relY, btn)
	if (btn == 'right') then
		closeWindow (wndSetPos)
		return
	end

	local x = relX*6000 - 3000
	local y = 3000 - relY*6000
	local hit, hitX, hitY, hitZ
	hit, hitX, hitY, hitZ = processLineOfSight(x, y, 3000, x, y, -3000)
	setControlNumbers(wndSetPos, { x = x, y = y, z = hitZ or 0 })
end

function setPosClick()
	if setPlayerPosition(getControlNumbers(wndSetPos, {'x', 'y', 'z'})) ~= false then
		if getElementInterior(localPlayer) ~= 0 then
			local vehicle = localPlayer.vehicle
			if vehicle and vehicle.interior ~= 0 then
				server.setElementInterior(getPedOccupiedVehicle(localPlayer), 0)
				local occupants = vehicle.occupants
				for seat,occupant in pairs(occupants) do
					if occupant.interior ~= 0 then
						server.setElementInterior(occupant,0)
					end
				end
			end
			if localPlayer.interior ~= 0 then
				server.setElementInterior(localPlayer,0)
			end
		end
		closeWindow(wndSetPos)
	end
end

local function forceFade()

	fadeCamera(false,0)

end

local function calmVehicle(veh)

	if not isElement(veh) then return end
	local z = veh.rotation.z
	veh.velocity = Vector3(0,0,0)
	veh.turnVelocity = Vector3(0,0,0)
	veh.rotation = Vector3(0,0,z)
	if not (localPlayer.inVehicle and localPlayer.vehicle) then
		server.warpMeIntoVehicle(veh)
	end

end

local function retryTeleport(elem,x,y,z,isVehicle,distanceToGround)

	local hit, groundX, groundY, groundZ = processLineOfSight(x, y, 3000, x, y, -3000)
	if hit then
		local waterZ = getWaterLevel(x, y, 100)
		z = (waterZ and math.max(groundZ, waterZ) or groundZ) + distanceToGround
		setElementPosition(elem,x, y, z + distanceToGround)
		setCameraPlayerMode()
		setGravity(grav)
		if isVehicle then
			server.fadeVehiclePassengersCamera(true)
			setTimer(calmVehicle,100,1,elem)
		else
			fadeCamera(true)
		end
		killTimer(g_TeleportTimer)
		g_TeleportTimer = nil
		grav = nil
	end

end

function setPlayerPosition(x, y, z, skipDeadCheck)
	local elem = getPedOccupiedVehicle(localPlayer)
	local isVehicle
	if elem and getPedOccupiedVehicle(localPlayer) then
		local controller = getVehicleController(elem)
		if controller and controller ~= localPlayer then
			errMsg('Only the driver of the vehicle can set its position.')
			return false
		end
		isVehicle = true
	else
		elem = localPlayer
		isVehicle = false
	end
	if isPedDead(localPlayer) and not skipDeadCheck then

		dim = getElementDimension(localPlayer)
		int = getElementInterior(localPlayer)

		customSpawnTable = {x,y,z,dim,int}
		fadeCamera(false,0)
		addEventHandler("onClientPreRender",root,forceFade)
		outputChatBox("You will be respawned to your specified location",0,255,0)
		return
	end
	local distanceToGround = getElementDistanceFromCentreOfMassToBaseOfModel(elem)
	local hit, hitX, hitY, hitZ = processLineOfSight(x, y, 3000, x, y, -3000)
	if not hit then
		if isVehicle then
			server.fadeVehiclePassengersCamera(false)
		else
			fadeCamera(false)
		end
		if isTimer(g_TeleportMatrixTimer) then killTimer(g_TeleportMatrixTimer) end
		g_TeleportMatrixTimer = setTimer(setCameraMatrix, 1000, 1, x, y, z)
		if not grav then
			grav = playerGravity
			setGravity(0.001)
		end
		if isTimer(g_TeleportTimer) then killTimer(g_TeleportTimer) end
		g_TeleportTimer = setTimer(retryTeleport,50,0,elem,x,y,z,isVehicle,distanceToGround)
	else
		setElementPosition(elem,x, y, z + distanceToGround)
		if isVehicle then
			setTimer(calmVehicle,100,1,elem)
		end
	end
end

local blipPlayers = {}

local function destroyBlip()

	blipPlayers[source] = nil

end

local function warpToBlip()

	local wnd = isWindowOpen(wndSpawnMap) and wndSpawnMap or wndSetPos
	local elem = blipPlayers[source]

	if isElement(elem) then
		warpMe(elem)
		closeWindow(wnd)
	end

end

function updatePlayerBlips()
	if not g_PlayerData then
		return
	end
	local wnd = isWindowOpen(wndSpawnMap) and wndSpawnMap or wndSetPos
	local mapControl = getControl(wnd, 'map')
	for elem,player in pairs(g_PlayerData) do
		if not player.gui.mapBlip then
			local playerName = player.name
			if g_settings["hidecolortext"] then
				playerName = playerName:gsub("#%x%x%x%x%x%x", "")
			end
			player.gui.mapBlip = guiCreateStaticImage(0, 0, 9, 9, elem == localPlayer and 'img/localplayerblip.png' or 'img/playerblip.png', false, mapControl)
			player.gui.mapLabelShadow = guiCreateLabel(0, 0, 100, 14, playerName, false, mapControl)
			local labelWidth = guiLabelGetTextExtent(player.gui.mapLabelShadow)
			guiSetSize(player.gui.mapLabelShadow, labelWidth, 14, false)
			guiSetFont(player.gui.mapLabelShadow, 'default-bold-small')
			guiLabelSetColor(player.gui.mapLabelShadow, 255, 255, 255)
			player.gui.mapLabel = guiCreateLabel(0, 0, labelWidth, 14, playerName, false, mapControl)
			guiSetFont(player.gui.mapLabel, 'default-bold-small')
			guiLabelSetColor(player.gui.mapLabel, 0, 0, 0)
			for i,name in ipairs({'mapBlip', 'mapLabelShadow'}) do
				blipPlayers[player.gui[name]] = elem
				addEventHandler('onClientGUIDoubleClick', player.gui[name],warpToBlip,false)
				addEventHandler("onClientElementDestroy", player.gui[name],destroyBlip)
			end
		end
		local x, y = getElementPosition(elem)
		local visible = (localPlayer.interior == elem.interior and localPlayer.dimension == elem.dimension)
		x = math.floor((x + 3000) * g_MapSide / 6000) - 4
		y = math.floor((3000 - y) * g_MapSide / 6000) - 4
		guiSetPosition(player.gui.mapBlip, x, y, false)
		guiSetPosition(player.gui.mapLabelShadow, x + 14, y - 4, false)
		guiSetPosition(player.gui.mapLabel, x + 13, y - 5, false)
		guiSetVisible(player.gui.mapBlip,visible)
		guiSetVisible(player.gui.mapLabelShadow,visible)
		guiSetVisible(player.gui.mapLabel,visible)
	end
end

function updateName(oldNick, newNick)
	if (not g_PlayerData) then return end
	local source = getElementType(source) == "player" and source or oldNick
	local player = g_PlayerData[source]
	player.name = newNick
	if player.gui.mapLabel then
		guiSetText(player.gui.mapLabelShadow, newNick)
		guiSetText(player.gui.mapLabel, newNick)
		local labelWidth = guiLabelGetTextExtent(player.gui.mapLabelShadow)
		guiSetSize(player.gui.mapLabelShadow, labelWidth, 14, false)
		guiSetSize(player.gui.mapLabel, labelWidth, 14, false)
	end
end
addEventHandler('onClientPlayerChangeNick', root,updateName)

function closePositionWindow()
	removeEventHandler('onClientRender', root, updatePlayerBlips)
end

wndSetPos = {
	'wnd',
	text = 'Set position',
	width = g_MapSide + 20,
	controls = {
		{'img', id='map', src='img/map.png', width=g_MapSide, height=g_MapSide, onclick=fillInPosition, ondoubleclick=setPosClick, DoubleClickSpamProtected=true},
		{'txt', id='x', text='', width=60},
		{'txt', id='y', text='', width=60},
		{'txt', id='z', text='', width=60},
		{'btn', id='ok', onclick=setPosClick, ClickSpamProtected=true},
		{'btn', id='cancel', closeswindow=true},
		{'lbl', text='Right click on map to close'}
	},
	oncreate = setPosInit,
	onclose = closePositionWindow
}

function getPosCommand(cmd, playerName)
	local player, sentenceStart

	if playerName then
		player = getPlayerFromName(playerName)

		if not player then
			errMsg('There is no player named "' .. playerName .. '".')
			return
		end

		if g_PlayerData[player].warping then
			errMsg("You cannot get coordinates of a player that has disabled warping!")
			return
		end

		playerName = getPlayerName(player)		-- make sure case is correct
		sentenceStart = playerName .. ' is '
	else
		player = localPlayer
		sentenceStart = 'You are '
	end

	local px, py, pz = getElementPosition(player)
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		outputChatBox(sentenceStart .. 'in a ' .. getVehicleName(vehicle), 0, 255, 0)
	else
		outputChatBox(sentenceStart .. 'on foot', 0, 255, 0)
	end
	outputChatBox(sentenceStart .. 'at {' .. string.format("%.5f", px) .. ', ' .. string.format("%.5f", py) .. ', ' .. string.format("%.5f", pz) .. '}', 0, 255, 0)
end
addCommandHandler('getpos', getPosCommand)
addCommandHandler('gp', getPosCommand)

function setPosCommand(cmd, x, y, z, r)
	if isPlayerAiming(localPlayer) then return errMsg ("You can't use /sp while aiming a weapon!") end
	if isPedReloadingWeapon(localPlayer) then return errMsg ("You can't use /sp while reloading a weapon!") end

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		local vehModel = getElementModel(vehicle)

		if table.find(g_settings["vehicles/disallowed_warp"], vehModel) and not isPedDead(localPlayer) then
			errMsg("You cannot use /sp while in this vehicle!")
			return
		end
	end

	-- Handle setpos if used like: x, y, z, r or x,y,z,r
	local x, y, z, r = string.gsub(x or "", ",", " "), string.gsub(y or "", ",", " "), string.gsub(z or "", ",", " "), string.gsub(r or "", ",", " ")
	-- Extra handling for x,y,z,r
	if (x and y == "" and not tonumber(x)) then
		x, y, z, r = unpack(split(x, " "))
	end

	local px, py, pz = getElementPosition(localPlayer)
	local pr = getPedRotation(localPlayer)

	-- If somebody doesn't provide all XYZ explain that we will use their current X Y or Z.
	local message = ""
	message = message .. (tonumber(x) and "" or "X ")
	message = message .. (tonumber(y) and "" or "Y ")
	message = message .. (tonumber(z) and "" or "Z ")
	if (message ~= "") then
		outputChatBox(message.."arguments were not provided. Using your current "..message.."values instead.", 255, 255, 0)
	end

	setPlayerPosition(tonumber(x) or px, tonumber(y) or py, tonumber(z) or pz)
	if (isPedInVehicle(localPlayer)) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if (vehicle and isElement(vehicle) and getVehicleController(vehicle) == localPlayer) then
			setElementRotation(vehicle, 0, 0, tonumber(r) or pr)
		end
	else
		setPedRotation(localPlayer, tonumber(r) or pr)
	end
end

addCommandHandler('setpos', setPosCommand)
addCommandHandler('sp', setPosCommand)

---------------------------
-- Spawn map window
---------------------------
function warpMapInit()
	addEventHandler('onClientRender', root, updatePlayerBlips)
end

function spawnMapDoubleClick(relX, relY)
	setPlayerPosition(relX*6000 - 3000, 3000 - relY*6000, 0)
	closeWindow(wndSpawnMap)
end

function closeSpawnMap()
	showCursor(false)
	removeEventHandler('onClientRender', root, updatePlayerBlips)
	for elem,data in pairs(g_PlayerData) do
		for i,name in ipairs({'mapBlip', 'mapLabelShadow', 'mapLabel'}) do
			if data.gui[name] then
				destroyElement(data.gui[name])
				data.gui[name] = nil
			end
		end
	end
end

wndSpawnMap = {
	'wnd',
	text = 'Select spawn position',
	width = g_MapSide + 20,
	controls = {
		{'img', id='map', src='img/map.png', width=g_MapSide, height=g_MapSide, ondoubleclick=spawnMapDoubleClick},
		{'lbl', text='Welcome to freeroam. Double click a location on the map to spawn.', width=g_MapSide-60, align='center'},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = warpMapInit,
	onclose = closeSpawnMap
}

---------------------------
-- Interior window
---------------------------

local function setPositionAfterInterior(x,y,z)
	setPlayerPosition(x,y,z)
	setCameraTarget(localPlayer)
	fadeCamera(true)
end

function setPlayerInterior(x,y,z,i)
	setCameraMatrix(x,y,z)
	setCameraInterior(i)
	server.setElementInterior(localPlayer, i)
	setTimer(setPositionAfterInterior,1000,1,x,y,z)
end

function setInterior(leaf)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and getVehicleController (vehicle) ~= localPlayer then
		errMsg("* Only the driver may set interior/dimension")
		return
	end
	if vehicle then
		server.setElementInterior(vehicle, leaf.world)
		for i=0,getVehicleMaxPassengers(vehicle) do
			local player = getVehicleOccupant(vehicle, i)
			if player and player ~= localPlayer then
				server.setElementInterior(player, leaf.world)
				server.setCameraInterior(player, leaf.world)
			end
		end
	end
	fadeCamera(false)
	setTimer(setPlayerInterior,1000,1,leaf.posX, leaf.posY, leaf.posZ, leaf.world)
	closeWindow(wndSetInterior)
end

wndSetInterior = {
	'wnd',
	text = 'Set interior',
	width = 250,
	controls = {
		{
			'lst',
			id='interiors',
			width=230,
			height=300,
			columns={
				{text='Interior', attr='name'}
			},
			rows={xml='data/interiors.xml', attrs={'name', 'posX', 'posY', 'posZ', 'world'}},
			onitemdoubleclick=setInterior,
			DoubleClickSpamProtected=true,
		},
		{'btn', id='close', closeswindow=true}
	}
}

---------------------------
-- Create vehicle window
---------------------------
function createSelectedVehicle(leaf)
	if not leaf then
		leaf = getSelectedGridListLeaf(wndCreateVehicle, 'vehicles')
		if not leaf then
			return
		end
	end
	server.giveMeVehicles(leaf.id)
end

wndCreateVehicle = {
	'wnd',
	text = 'Create vehicle',
	width = 300,
	controls = {
		{
			'lst',
			id='vehicles',
			width=280,
			height=340,
			columns={
				{text='Vehicle', attr='name'}
			},
			rows={xml='data/vehicles.xml', attrs={'id', 'name'}},
			onitemdoubleclick=createSelectedVehicle,
			DoubleClickSpamProtected=true,
		},
		{'btn', id='create', onclick=createSelectedVehicle, ClickSpamProtected=true},
		{'btn', id='close', closeswindow=true}
	}
}

function createVehicleCommand(cmd, ...)

	local args = {...}

	if not ... then
		return errMsg("Enter vehicle model please! Syntax: /cv [vehicle ID/name]")
	end

	vehID = getVehicleModelFromName(table.concat(args, " ")) or tonumber(args[1]) and math.floor(tonumber(args[1])) or false

	if not vehID or not tostring(vehID) or not tonumber(vehID) then
		return errMsg("Invalid vehicle model!")
	end

	if string.len(table.concat(args, " ")) > 25 or tonumber(vehID) and string.len(vehID) > 3 then
		return errMsg("Invalid vehicle model!")
	end

	if vehID and vehID >= 400 and vehID <= 611 then
		server.giveMeVehicles(vehID)
	else
		errMsg("Invalid vehicle model!")
	end
end
addCommandHandler('createvehicle', createVehicleCommand)
addCommandHandler('cv', createVehicleCommand)

---------------------------
-- Repair vehicle
---------------------------
function repairVehicle()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		server.fixVehicle(vehicle)
	end
end

addCommandHandler('repair', repairVehicle)
addCommandHandler('rp', repairVehicle)

---------------------------
-- Flip vehicle
---------------------------
function flipVehicle()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		local rX, rY, rZ = getElementRotation(vehicle)
		setElementRotation(vehicle, 0, 0, (rX > 90 and rX < 270) and (rZ + 180) or rZ)
	end
end

addCommandHandler('flip', flipVehicle)
addCommandHandler('f', flipVehicle)

---------------------------
-- Vehicle upgrades
---------------------------
function upgradesInit()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		errMsg('Please enter a vehicle to change the upgrades of.')
		closeWindow(wndUpgrades)
		return
	end
	local installedUpgrades = getVehicleUpgrades(vehicle)
	local compatibleUpgrades = {}
	local slotName, group
	for i,upgrade in ipairs(getVehicleCompatibleUpgrades(vehicle)) do
		slotName = getVehicleUpgradeSlotName(upgrade)
		group = table.find(compatibleUpgrades, 'name', slotName)
		if not group then
			group = { 'group', name = slotName, children = {} }
			table.insert(compatibleUpgrades, group)
		else
			group = compatibleUpgrades[group]
		end
		table.insert(group.children, { id = upgrade, installed = table.find(installedUpgrades, upgrade) ~= false })
	end
	table.sort(compatibleUpgrades, function(a, b) return a.name < b.name end)
	bindGridListToTable(wndUpgrades, 'upgradelist', compatibleUpgrades, true)
end

function selectUpgrade(leaf)
	setControlText(wndUpgrades, 'addremove', leaf.installed and 'remove' or 'add')
end

function addRemoveUpgrade(selUpgrade)
	-- Add or remove selected upgrade
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		return
	end

	if not selUpgrade then
		selUpgrade = getSelectedGridListLeaf(wndUpgrades, 'upgradelist')
		if not selUpgrade then
			return
		end
	end

	if selUpgrade.installed then
		-- remove upgrade
		selUpgrade.installed = false
		setControlText(wndUpgrades, 'addremove', 'add')
		server.removeVehicleUpgrade(vehicle, selUpgrade.id)
	else
		-- add upgrade
		local prevUpgradeIndex = table.find(selUpgrade.siblings, 'installed', true)
		if prevUpgradeIndex then
			selUpgrade.siblings[prevUpgradeIndex].installed = false
		end
		selUpgrade.installed = true
		setControlText(wndUpgrades, 'addremove', 'remove')
		server.addVehicleUpgrade(vehicle, selUpgrade.id)
	end
end

wndUpgrades = {
	'wnd',
	text = 'Vehicle upgrades',
	width = 300,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='upgradelist',
			width=280,
			height=340,
			columns={
				{text='Upgrade', attr='id', width=0.6},
				{text='Installed', attr='installed', width=0.3, enablemodify=true}
			},
			onitemclick=selectUpgrade,
			onitemdoubleclick=addRemoveUpgrade,
			DoubleClickSpamProtected=true
		},
		{'btn', id='addremove', text='add', width=60, onclick=addRemoveUpgrade,ClickSpamProtected=true},
		{'btn', id='ok', closeswindow=true}
	},
	oncreate = upgradesInit
}

function addUpgradeCommand(cmd, upgrade)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and upgrade then
		server.addVehicleUpgrade(vehicle, tonumber(upgrade) or 0)
	end
end
addCommandHandler('addupgrade', addUpgradeCommand)
addCommandHandler('au', addUpgradeCommand)

function removeUpgradeCommand(cmd, upgrade)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and upgrade then
		server.removeVehicleUpgrade(vehicle, tonumber(upgrade) or 0)
	end
end
addCommandHandler('removeupgrade', removeUpgradeCommand)
addCommandHandler('ru', removeUpgradeCommand)

---------------------------
-- Toggle lights
---------------------------
function forceLightsOn()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		return
	end
	if guiCheckBoxGetSelected(getControl(wndMain, 'lightson')) then
		server.setVehicleOverrideLights(vehicle, 2)
		guiCheckBoxSetSelected(getControl(wndMain, 'lightsoff'), false)
	else
		server.setVehicleOverrideLights(vehicle, 0)
	end
end

function forceLightsOff()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		return
	end
	if guiCheckBoxGetSelected(getControl(wndMain, 'lightsoff')) then
		server.setVehicleOverrideLights(vehicle, 1)
		guiCheckBoxSetSelected(getControl(wndMain, 'lightson'), false)
	else
		server.setVehicleOverrideLights(vehicle, 0)
	end
end


---------------------------
-- Color
---------------------------

function setColorCommand(cmd, ...)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		return
	end
	local colors = {getVehicleColor(vehicle)}
	local args = {...}

	if not ... then
		errMsg("Enter colors please!")
		return
	end

	for i = 1, 12 do
		colors[i] = args[i] and tonumber(args[i]) or colors[i]
	end
	server.setVehicleColor(vehicle, unpack(colors))
end
addCommandHandler('color', setColorCommand)
addCommandHandler('cl', setColorCommand)

function openColorPicker()
	editingVehicle = getPedOccupiedVehicle(localPlayer)
	if (editingVehicle) then
		local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = getVehicleColor(editingVehicle, true)
		local r, g, b = 255, 255, 255
		if (guiCheckBoxGetSelected(checkColor1)) then
			r, g, b = r1, g1, b1
		end
		if (guiCheckBoxGetSelected(checkColor2)) then
			r, g, b = r2, g2, b2
		end
		if (guiCheckBoxGetSelected(checkColor3)) then
			r, g, b = r3, g3, b3
		end
		if (guiCheckBoxGetSelected(checkColor4)) then
			r, g, b = r4, g4, b4
		end
		if (guiCheckBoxGetSelected(checkColor5)) then
			r, g, b = getVehicleHeadLightColor(editingVehicle)
		end
		colorPicker.setValue({r, g, b})
		colorPicker.openSelect(colors)
	end
end

function closedColorPicker()
	if not editingVehicle then return end
	local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = getVehicleColor(editingVehicle, true)
	server.setVehicleColor(editingVehicle, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4)
	local r, g, b = getVehicleHeadLightColor(editingVehicle)
	server.setVehicleHeadLightColor(editingVehicle, r, g, b)
	editingVehicle = nil
end

function updateColor()
	if (not colorPicker.isSelectOpen) then return end
	local r, g, b = colorPicker.updateTempColors()
	if (editingVehicle and isElement(editingVehicle)) then
		local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4  = getVehicleColor(editingVehicle, true)
		if (guiCheckBoxGetSelected(checkColor1)) then
			r1, g1, b1 = r, g, b
		end
		if (guiCheckBoxGetSelected(checkColor2)) then
			r2, g2, b2 = r, g, b
		end
		if (guiCheckBoxGetSelected(checkColor3)) then
			r3, g3, b3 = r, g, b
		end
		if (guiCheckBoxGetSelected(checkColor4)) then
			r4, g4, b4 = r, g, b
		end
		if (guiCheckBoxGetSelected(checkColor5)) then
			setVehicleHeadLightColor(editingVehicle, r, g, b)
		end
		setVehicleColor(editingVehicle, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4)
	end
end
addEventHandler("onClientRender", root, updateColor)

---------------------------
-- Paintjob
---------------------------

function paintjobInit()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		errMsg('You need to be in a car to change its paintjob.')
		closeWindow(wndPaintjob)
		return
	end
	local paint = getVehiclePaintjob(vehicle)
	if paint then
		guiGridListSetSelectedItem(getControl(wndPaintjob, 'paintjoblist'), paint+1, 1)
	end
end

function applyPaintjob(paint)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and tonumber(paint.id) and string.len(paint.id) == 1 then
		server.setVehiclePaintjob(vehicle, paint.id)
	end
end

wndPaintjob = {
	'wnd',
	text = 'Car paintjob',
	width = 220,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='paintjoblist',
			width=200,
			height=130,
			columns={
				{text='Paintjob ID', attr='id'}
			},
			rows={
				{id=0},
				{id=1},
				{id=2},
				{id=3}
			},
			onitemclick=applyPaintjob,
			ClickSpamProtected=true,
			ondoubleclick=function() closeWindow(wndPaintjob) end
		},
		{'btn', id='close', closeswindow=true},
	},
	oncreate = paintjobInit
}

function setPaintjobCommand(cmd, paint)

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then return end

	paint = paint and tonumber(paint)

	if not paint then errMsg("Enter paintjob ID please!") return end
	if paint > 3 or string.len(paint) > 1 then
		errMsg("Invalid paintjob ID!")
		return
	end

	server.setVehiclePaintjob(vehicle, paint)
end
addCommandHandler('paintjob', setPaintjobCommand)
addCommandHandler('pj', setPaintjobCommand)

---------------------------
-- Time
---------------------------
function timeInit()
	local hours, minutes = getTime()
	setControlNumbers(wndTime, { hours = hours, minutes = minutes })
end

function selectTime(leaf)
	setControlNumbers(wndTime, { hours = leaf.h, minutes = leaf.m })
end

function applyTime()
	local hours, minutes = getControlNumbers(wndTime, { 'hours', 'minutes' })
	setTime(hours, minutes)
	closeWindow(wndTime)
	freezeTimeHour, freezeTimeMinute = hours, minutes
end

wndTime = {
	'wnd',
	text = 'Set time',
	width = 220,
	controls = {
		{
			'lst',
			id='timelist',
			width=200,
			height=150,
			columns={
				{text='Time', attr='name'}
			},
			rows={
				{name='Midnight',  h=0, m=0},
				{name='Dawn',      h=5, m=0},
				{name='Morning',   h=9, m=0},
				{name='Noon',      h=12, m=0},
				{name='Afternoon', h=15, m=0},
				{name='Evening',   h=20, m=0},
				{name='Night',     h=22, m=0}
			},
			onitemclick=selectTime,
			ondoubleclick=applyTime
		},
		{'txt', id='hours', text='', width=40},
		{'lbl', text=':'},
		{'txt', id='minutes', text='', width=40},
		{'btn', id='ok', onclick=applyTime},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = timeInit
}

function setTimeCommand(cmd, hours, minutes)
	if not hours then
		return
	end
	local curHours, curMinutes = getTime()
	hours = tonumber(hours) or curHours
	minutes = minutes and tonumber(minutes) or curMinutes
	setTime(hours, minutes)
end
addCommandHandler('settime', setTimeCommand)
addCommandHandler('st', setTimeCommand)

function toggleFreezeTime()
	local state = guiCheckBoxGetSelected(getControl(wndMain, 'freezetime'))
	guiCheckBoxSetSelected(getControl(wndMain, 'freezetime'), not state)
	freezeTimeHour, freezeTimeMinute = getTime()
	freezeTimeWeather = getWeather()
	setTimeFrozen(state)
end

function setTimeFrozen(state)
	guiCheckBoxSetSelected(getControl(wndMain, 'freezetime'), state)
	if state then
		if not g_TimeFreezeTimer then
			g_TimeFreezeTimer = setTimer(function() setTime(freezeTimeHour, freezeTimeMinute) setWeather(freezeTimeWeather) end, 5000, 0)
			setMinuteDuration(9001)
		end
	else
		if g_TimeFreezeTimer then
			killTimer(g_TimeFreezeTimer)
			g_TimeFreezeTimer = nil
		end
		setMinuteDuration(1000)
	end
end

---------------------------
-- Weather
---------------------------
function applyWeather(leaf)
	if not leaf then
		leaf = getSelectedGridListLeaf(wndWeather, 'weatherlist')
		if not leaf then
			return
		end
	end
	setWeather(leaf.id)
	closeWindow(wndWeather)
	freezeTimeWeather = leaf.id
end

wndWeather = {
	'wnd',
	text = 'Set weather',
	width = 250,
	controls = {
		{
			'lst',
			id='weatherlist',
			width=230,
			height=290,
			columns = {
				{text='Weather type', attr='name'}
			},
			rows={xml='data/weather.xml', attrs={'id', 'name'}},
			onitemdoubleclick=applyWeather
		},
		{'btn', id='ok', onclick=applyWeather},
		{'btn', id='cancel', closeswindow=true}
	}
}

function setWeatherCommand(cmd, weather)
	weather = weather and tonumber(weather)
	if not weather or weather > 255 or string.len(weather) > 3 then
		errMsg("Invalid weather ID!")
		return
	end
	if weather then
		setWeather(weather)
	end
end
addCommandHandler('setweather', setWeatherCommand)
addCommandHandler('sw', setWeatherCommand)

---------------------------
-- Game speed
---------------------------

function setMyGameSpeed(speed)

	speed = speed and tonumber(speed) or 1

	if g_settings["gamespeed/enabled"] then
		if speed > g_settings["gamespeed/max"] then
			errMsg(('Maximum allowed gamespeed is %.5f'):format(g_settings['gamespeed/max']))
		elseif speed < g_settings["gamespeed/min"] then
			errMsg(('Minimum allowed gamespeed is %.5f'):format(g_settings['gamespeed/min']))
		else
			setGameSpeed(speed)
		end
	else
		errMsg("Setting game speed is disallowed!")
	end

end

function gameSpeedInit()
	setControlNumber(wndGameSpeed, 'speed', getGameSpeed())
end

function selectGameSpeed(leaf)
	setControlNumber(wndGameSpeed, 'speed', leaf.id)
end

function applyGameSpeed()
	speed = getControlNumber(wndGameSpeed, 'speed')
	if speed and tonumber(speed) then
		setMyGameSpeed(speed)
	end
	closeWindow(wndGameSpeed)
end

wndGameSpeed = {
	'wnd',
	text = 'Set game speed',
	width = 220,
	controls = {
		{
			'lst',
			id='speedlist',
			width=200,
			height=150,
			columns={
				{text='Speed', attr='name'}
			},
			rows={
				{id=3, name='3x'},
				{id=2, name='2x'},
				{id=1, name='1x'},
				{id=0.5, name='0.5x'}
			},
			onitemclick=selectGameSpeed,
			ondoubleclick=applyGameSpeed
		},
		{'txt', id='speed', text='', width=40},
		{'btn', id='ok', onclick=applyGameSpeed},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = gameSpeedInit
}

function setGameSpeedCommand(cmd, speed)
	speed = speed and tonumber(speed)
	if speed then
		setMyGameSpeed(speed)
	end
end

addCommandHandler('setgamespeed', setGameSpeedCommand)
addCommandHandler('speed', setGameSpeedCommand)

---------------------------
-- Main window
---------------------------

function toggleWarping()

	local state = guiCheckBoxGetSelected( getControl(wndMain, 'disablewarp') )
	triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"warping",state)
	outputChatBox("You "..(state and "disabled" or "enabled").." others warping to you",255,255,0)

end

function toggleKnifing()

	local state = guiCheckBoxGetSelected( getControl(wndMain, 'disableknife') )
	triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"knifing",state)
	outputChatBox("You "..(state and "disabled" or "enabled").." knifekills",255,255,0)

end

function toggleGhostmode()

	local state = guiCheckBoxGetSelected( getControl(wndMain, 'antiram') )
	triggerServerEvent("onFreeroamLocalSettingChange",localPlayer,"ghostmode",state)
	outputChatBox("You "..(state and "disabled" or "enabled").." other players ramming your vehicle",255,255,0)


end

function updateGUI()
	-- update position
	local x, y, z = getElementPosition(localPlayer)
	setControlNumbers(wndMain, {xpos=math.ceil(x), ypos=math.ceil(y), zpos=math.ceil(z)})

	-- update jetpack toggle
	guiCheckBoxSetSelected( getControl(wndMain, 'jetpack'), doesPedHaveJetPack(localPlayer) )

	-- update current vehicle
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and isElement(vehicle) then
		setControlText(wndMain, "curvehicle", getVehicleName(vehicle))
	else
		setControlText(wndMain, "curvehicle", "On foot")
	end
end

function mainWndShow()
	if not getPedOccupiedVehicle(localPlayer) then
		hideControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
	end
	updateTimer = updateTimer or setTimer(updateGUI, 2000, 0)
	updateGUI(true)
end

function mainWndClose()
	killTimer(updateTimer)
	updateTimer = nil
	colorPicker.closeSelect()
end

function hasDriverGhost(vehicle)

	if not g_PlayerData then return end
	if not isElement(vehicle) then return end
	if getElementType(vehicle) ~= "vehicle" then return end

	local driver = getVehicleController(vehicle)
	if g_PlayerData[driver] and g_PlayerData[driver].ghostmode then return true end
	return false

end

function onEnterVehicle(vehicle,seat)
	if source == localPlayer then
		setControlText(wndMain, 'curvehicle', getVehicleName(vehicle))
		showControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
		guiCheckBoxSetSelected(getControl(wndMain, 'lightson'), getVehicleOverrideLights(vehicle) == 2)
		guiCheckBoxSetSelected(getControl(wndMain, 'lightsoff'), getVehicleOverrideLights(vehicle) == 1)
	end
	if seat == 0 and g_PlayerData[source] then
		setVehicleGhost(vehicle,hasDriverGhost(vehicle))
	end
end
addEventHandler('onClientPlayerVehicleEnter', root, onEnterVehicle)

function onExitVehicle(vehicle,seat)
	if (eventName == "onClientPlayerVehicleExit" and source == localPlayer) or (eventName == "onClientElementDestroy" and getElementType(source) == "vehicle" and getPedOccupiedVehicle(localPlayer) == source) then
		setControlText(wndMain, 'curvehicle', 'On foot')
		hideControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
		closeWindow(wndUpgrades)
		closeWindow(wndColor)
	elseif vehicle and seat == 0 then
		if source and g_PlayerData[source] then
			setVehicleGhost(vehicle,hasDriverGhost(vehicle))
		end
	end
end
addEventHandler('onClientPlayerVehicleExit', root, onExitVehicle)
addEventHandler("onClientElementDestroy", root, onExitVehicle)

function killLocalPlayer()
	if g_settings["kill"] then
		setElementHealth(localPlayer,0)
	else
		errMsg("Killing yourself is disallowed!")
	end
end

function alphaCommand(command, alpha)
	alpha = alpha and tonumber(alpha) or 255
	if alpha >= 0 and alpha <= 255 then
		server.setElementAlpha(localPlayer, alpha)
	else
		errMsg("Invalid alpha value! (range: 0 - 255)")
	end
end
addCommandHandler('alpha', alphaCommand)
addCommandHandler('ap', alphaCommand)

addCommandHandler('kill', killLocalPlayer)

wndMain = {
	'wnd',
	text = 'FR GUI',
	x = 10,
	y = 150,
	width = 280,
	controls = {
		{'lbl', text='Local player'},
		{'br'},
		{'btn', id='kill', onclick=killLocalPlayer},
		{'btn', id='skin', window=wndSkin},
		{'btn', id='anim', window=wndAnim},
		{'btn', id='weapon', window=wndWeapon},
		{'btn', id='clothes', window=wndClothes},
		{'btn', id='playergrav', text='grav', window=wndGravity},
		{'btn', id='warp', window=wndWarp},
		{'btn', id='stats', window=wndStats},
		{'btn', id='bookmarks', window=wndBookmarks},
		{'br'},

		{'chk', id='jetpack', onclick=toggleJetPack},
		{'chk', id='falloff', text='fall off bike', onclick=toggleFallOffBike},
		{'br'},

		{'chk', id='disablewarp', text='disable warp', onclick=toggleWarping},
		{'chk', id='disableknife', text='disable knifing', onclick=toggleKnifing},
		{'chk', id='antiram', text='anti-ramming (vehicle ghostmode)', onclick=toggleGhostmode},
		{'br'},

		{'lbl', text='Pos:'},
		{'lbl', id='xpos', text='x', width=45},
		{'lbl', id='ypos', text='y', width=45},
		{'lbl', id='zpos', text='z', width=45},
		{'btn', id='setpos', text='map', window=wndSetPos},
		{'btn', id='setinterior', text='int', window=wndSetInterior},
		{'br'},
		{'br'},

		{'lbl', text='Vehicles'},
		{'br'},
		{'lbl', text='Current:'},
		{'lbl', id='curvehicle'},
		{'br'},
		{'btn', id='createvehicle', window=wndCreateVehicle, text='create'},
		{'btn', id='repair', onclick=repairVehicle},
		{'btn', id='flip', onclick=flipVehicle},
		{'btn', id='upgrades', window=wndUpgrades},
		{'btn', id='color', onclick=openColorPicker},
		{'btn', id='paintjob', window=wndPaintjob},
		{'br'},
		{'chk', id='lightson', text='Lights on', onclick=forceLightsOn},
		{'chk', id='lightsoff', text='Lights off', onclick=forceLightsOff},
		{'br'},
		{'br'},

		{'lbl', text='Environment'},
		{'br'},
		{'btn', id='time', window=wndTime},
		{'chk', id='freezetime', text='freeze', onclick=toggleFreezeTime},
		{'btn', id='weather', window=wndWeather},
		{'btn', id='speed', window=wndGameSpeed}
	},
	oncreate = mainWndShow,
	onclose = mainWndClose
}

disableBySetting =
{
	{parent=wndMain, id="antiram"},
	{parent=wndMain, id="disablewarp"},
	{parent=wndMain, id="disableknife"},
}

function errMsg(msg)
	outputChatBox(msg,255,0,0)
end

addEventHandler('onClientResourceStart', resourceRoot,
	function()
		fadeCamera(true)
		getPlayers()
		setJetpackMaxHeight(9001)
		setAircraftMaxHeight(1600)
		triggerServerEvent('onLoadedAtClient', resourceRoot)
		createWindow(wndMain)
		hideAllWindows()
		bindKey('f1', 'down', toggleFRWindow)
		guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), doesPedHaveJetPack(localPlayer))
		guiCheckBoxSetSelected(getControl(wndMain, 'falloff'), canPedBeKnockedOffBike(localPlayer))
	end
)

function showWelcomeMap()
	createWindow(wndSpawnMap)
	showCursor(true)
end

function showMap()
	createWindow(wndSetPos)
	showCursor(true)
end

function toggleFRWindow()
	if isWindowOpen(wndMain) then
		showCursor(false)
		hideAllWindows()
		colorPicker.closeSelect()
	else
		if guiGetInputMode() ~= "no_binds_when_editing" then
			guiSetInputMode("no_binds_when_editing")
		end
		showCursor(true)
		showAllWindows()
	end
end

addCommandHandler('fr', toggleFRWindow)

function getPlayers()
	g_PlayerData = {}
	table.each(getElementsByType('player'), joinHandler)
end

function joinHandler(player)
	if (not g_PlayerData) then return end
	g_PlayerData[player or source] = { name = getPlayerName(player or source), gui = {} }
end
addEventHandler('onClientPlayerJoin', root, joinHandler)

function quitHandler()
	if (not g_PlayerData) then return end
	local veh = getPedOccupiedVehicle(source)
	local seat = (veh and getVehicleController(veh) == localPlayer) and 0 or 1
	if seat == 0 then
		onExitVehicle(veh,0)
	end
	table.each(g_PlayerData[source].gui, destroyElement)
	g_PlayerData[source] = nil
end
addEventHandler('onClientPlayerQuit', root, quitHandler)

function wastedHandler()
	if source == localPlayer then
		onExitVehicle()
		if g_settings["spawnmapondeath"] then
			setTimer(showMap,2000,1)
		end
	else
		local veh = getPedOccupiedVehicle(source)
		local seat = (veh and getVehicleController(veh) == localPlayer) and 0 or 1
		if seat == 0 then
			onExitVehicle(veh,0)
		end
	end
end
addEventHandler('onClientPlayerWasted', root, wastedHandler)

local function removeForcedFade()
	removeEventHandler("onClientPreRender",root,forceFade)
	fadeCamera(true)
end

local function checkCustomSpawn()

	if type(customSpawnTable) == "table" then
		local x,y,z,dim,int = unpack(customSpawnTable)
		setPlayerPosition(x,y,z,true)
		setElementDimension(localPlayer, dim)
		setElementInterior(localPlayer, int)
		customSpawnTable = false
		setTimer(removeForcedFade,100,1)
	end

end
addEventHandler("onClientPlayerSpawn", localPlayer, checkCustomSpawn)

function getPlayerName(player)
	return g_settings["removeHex"] and player.name:gsub("#%x%x%x%x%x%x","") or player.name
end

addEventHandler('onClientResourceStop', resourceRoot,
	function()
		showCursor(false)
		setPedAnimation(localPlayer, false)
	end
)

function setVehicleGhost(sourceVehicle,value)

	  local vehicles = getElementsByType("vehicle")
	  for _,vehicle in ipairs(vehicles) do
		local vehicleGhost = hasDriverGhost(vehicle)
		if isElement(sourceVehicle) and isElement(vehicle) then
		   setElementCollidableWith(sourceVehicle,vehicle,not value)
		   setElementCollidableWith(vehicle,sourceVehicle,not value)
		end
		if value == false and vehicleGhost == true and isElement(sourceVehicle) and isElement(vehicle) then
			setElementCollidableWith(sourceVehicle,vehicle,not vehicleGhost)
			setElementCollidableWith(vehicle,sourceVehicle,not vehicleGhost)
		end
	end

end

local function onStreamIn()
	if source.type ~= "vehicle" then return end
	setVehicleGhost(source,hasDriverGhost(source))
end
addEventHandler("onClientElementStreamIn",root,onStreamIn)

local function onLocalSettingChange(key,value)

	g_PlayerData[source][key] = value

	if key == "ghostmode" then
		local sourceVehicle = getPedOccupiedVehicle(source)
		if sourceVehicle then
			setVehicleGhost(sourceVehicle,hasDriverGhost(sourceVehicle))
		end
	end
end
addEvent("onClientFreeroamLocalSettingChange",true)
addEventHandler("onClientFreeroamLocalSettingChange",root,onLocalSettingChange)

local function renderKnifingTag()
	if not g_PlayerData then return end
	for _,p in ipairs (getElementsByType ("player", root, true)) do
		if g_PlayerData[p] and g_PlayerData[p].knifing then
			local px,py,pz = getPedBonePosition(p, 6)
			local x,y,d = getScreenFromWorldPosition (px, py, pz+0.5)
			if x and y and d < 20 then
				dxDrawText ("Disabled Knifing", x+1, y+1, x, y, tocolor (0, 0, 0), 0.5, "bankgothic", "center")
				dxDrawText ("Disabled Knifing", x, y, x, y, tocolor (220, 220, 0), 0.5, "bankgothic", "center")
			end
		end
    end
end
addEventHandler ("onClientRender", root, renderKnifingTag)
