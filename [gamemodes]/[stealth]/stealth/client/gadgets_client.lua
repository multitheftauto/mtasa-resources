function choosethegadget () --GETS THE GADGET TYPE ON SPAWN
	player = localPlayer
	local x, y = guiGetScreenSize()
	x = x * 0.052
	y = y * 0.695
	if (gadgeticon) then
		destroyElement (gadgeticon)
		gadgeticon = nil
	end
	setElementData ( localPlayer, "armor", false )
	if spygadgetSelection == "prox mine" then
		chosengadget = "mines"
		gadgetuses = 6
		gadgeticon = guiCreateStaticImage (x, y, 40, 40, "mine.png", false)
		gadgetlabel = guiCreateLabel ( 0.05, .62, 40, 20, "", true, gadgeticon )
		guiLabelSetColor ( gadgetlabel, 1, 1, 1 )
	end
	if spygadgetSelection == "radar burst" then
		chosengadget = "burst"
		gadgetuses = 5
		gadgeticon = guiCreateStaticImage (x, y, 40, 40, "radar.png", false)
		gadgetlabel = guiCreateLabel ( 0.05, .62, 40, 20, "", true, gadgeticon )
		guiLabelSetColor ( gadgetlabel, 1, 1, 1 )
	end
	if spygadgetSelection == "camera" then
		chosengadget = "camera"
		gadgetuses = 3
		gadgeticon = guiCreateStaticImage (x, y, 40, 40, "camera.png", false)
		gadgetlabel = guiCreateLabel ( 0.05, .62, 40, 20, "", true, gadgeticon )
		guiLabelSetColor ( gadgetlabel, 1, 1, 1 )
	end
	if spygadgetSelection == "cloak" then
		chosengadget = "cloak"
		gadgetuses = 3
		gadgeticon = guiCreateStaticImage (x, y, 40, 40, "cloak.png", false)
		gadgetlabel = guiCreateLabel ( 0.05, .62, 40, 20, "", true, gadgeticon )
		guiLabelSetColor ( gadgetlabel, 1, 1, 1 )
	end
	if spygadgetSelection == "goggles" then
		chosengadget = "goggles"
		gadgetuses = nil
		gadgeticon = guiCreateStaticImage (x, y, 40, 40, "goggles.png", false)
		gadgetlabel = guiCreateLabel ( 0.05, .62, 40, 20, "", true, gadgeticon )
		guiLabelSetColor ( gadgetlabel, 1, 1, 1 )
	end
	if spygadgetSelection == "armor" then
		chosengadget = "armor"
		gadgetuses = nil
		gadgeticon = guiCreateStaticImage (x, y, 40, 40, "armor.png", false)
		setElementData ( localPlayer, "armor", true )
		gadgetlabel = guiCreateLabel ( 0.05, .62, 40, 20, "", true, gadgeticon )
		guiLabelSetColor ( gadgetlabel, 1, 1, 1 )
	end
	if spygadgetSelection == "shield" then
		chosengadget = "shield"
		gadgetuses = nil
		gadgeticon = guiCreateStaticImage (x, y, 40, 40, "shield.png", false)
		gadgetlabel = guiCreateLabel ( 0.05, .62, 40, 20, "", true, gadgeticon )
		guiLabelSetColor ( gadgetlabel, 1, 1, 1 )
	end
	guiSetText ( gadgetlabel, gadgetuses or "" )
	if goggleson == 1 then
		hideGogglesGUI()
		goggleson = 0
	end
	burstinprogress = 0
	cameraplaced = 0
	toggleControl ("fire", true )
	toggleControl ("aim_weapon", true )
	toggleControl ("enter_exit", true )
	toggleControl ("crouch", true )
	toggleControl ("jump", true )
	toggleControl ("right", true )
	toggleControl ("left", true )
	toggleControl ("forwards", true )
	toggleControl ("backwards", true )
	toggleControl ("enter_passenger", true )
	toggleControl ("sprint", true )
	if lookingthroughcamera == 1 then
		toggleSpyCam()
	end
	lookingthroughcamera = 0
end

addEventHandler ( "onClientPlayerSpawn", localPlayer, choosethegadget )

function playerkilled ()
	if (gadgeticon) then
		destroyElement (gadgeticon)
		gadgeticon = nil
	end
end

addEventHandler ( "onClientPlayerWasted", localPlayer, playerkilled )

addEventHandler ( "onClientPlayerDamage", root,
	function(attacker,weapon,bodypart)
		-- local slot = getSlotFromWeapon(weapon)
		if getElementData ( source, "armor" ) then
			if bodypart == 7 or bodypart == 8 or bodypart == 9 then
				local sound = playSound3D( "ricochet"..tostring(math.random(1,3))..".mp3", getElementPosition(source) )
				setSoundMinDistance ( sound, 2 )
				setSoundMaxDistance ( sound, 18 )
			end
		end
	end
)


function activategadget () --TRIGGERS WHEN GADGET BUTTON IS PRESSED, DECIDES WHICH FUNCTION TO TRIGGER
	local inacar = isPedInVehicle ( localPlayer )
	if inacar == false then
		local isDead = isPedDead(localPlayer)
		if (isDead == false) then
			if chosengadget == "mines" then
				if gadgetuses >0 then
					player = localPlayer
					if ( isPedDucked ( player) ) then
						triggerServerEvent ("poopoutthemine", localPlayer, player )
						gadgetuses = gadgetuses-1
						guiSetText ( gadgetlabel, gadgetuses )
						playSoundFrontEnd(42)
					else
						outputChatBox("You need to crouch to place a landmine.", 255, 69, 0)
					end
				else
					outputChatBox ( "You are out of Mines", 255, 69, 0)
				end
			elseif chosengadget == "burst" then
				radarblipburst()
			elseif chosengadget == "camera" then
				camerastart()
			elseif chosengadget == "cloak" then
				if gadgetuses >0 then
					local iscloaked = getElementData ( localPlayer, "stealthmode" )
					if (iscloaked ~= "on") then
						local thisplayer = localPlayer
						triggerServerEvent ("cloaktheplayer", localPlayer, thisplayer )
						cloakoff = setTimer ( makecloakstop, 20000, 1, thisplayer )
						gadgetuses = gadgetuses-1
						guiSetText ( gadgetlabel, gadgetuses )
					else
						outputChatBox ( "You are already currently cloaked.", 255, 69, 0)
					end
				else
					outputChatBox ( "You are out of Cloaks", 255, 69, 0)
				end
			elseif chosengadget == "goggles" then
				goggletoggle()
			elseif chosengadget == "shield" then
				shieldup()
			end
		end
	end
end


--CLOAK

function makecloakstop ()
	triggerServerEvent ("uncloaktheplayer", localPlayer, localPlayer )
end


--TRIGGER WHEN SOMEONE IS CLOAKED
addEvent("cloaksomeoneelse", true)

function cloakaperson (thisplayer)
	if goggleson ~= 1 then
		setElementModel ( thisplayer, 164 )
		alphachangedelay = setTimer ( setalpha, 100, 1, thisplayer )
	end
end

addEventHandler("cloaksomeoneelse", root, cloakaperson)

function setalpha(thisplayer)
	setElementAlpha ( thisplayer, 10 )
end


--TRIGGER WHEN SOMEONE IS UNCLOAKED
addEvent("uncloaksomeoneelse", true)

function uncloakaperson (thisplayer)
	local oldskin = getElementData ( thisplayer, "playerskin" )
	setElementModel ( thisplayer, oldskin )
	setElementAlpha ( thisplayer, 255 ) --- NECCESARY???
end

addEventHandler("uncloaksomeoneelse", root, uncloakaperson)


--LANDMINES

--TRIGGERS THE SERVER EVENT TO DESTROY A LAND MINE ONCE IT'S SHOT
function weaponfired (weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	if source == localPlayer then
		if (hitElement) then
			if ( getElementData ( hitElement, "type" ) == "proximity" ) then
				if minedelay ~= 1 then
					minedelay = 1
					triggerServerEvent ("destroylandmine", localPlayer, hitElement )
					endminedelay = setTimer ( minedelaystop, 400, 1, player )
				end
			end
		end
	end
end

addEventHandler ( "onClientPlayerWeaponFire", root, weaponfired )

function minedelaystop()
	minedelay = 0
end


--GOGGLES

--DETECTS IF ITS THE GOGGLES IN THE PERSONS HANDS
function triggerpulled()
	if lookingthroughcamera == 1 then
		if gadgetuses >0 then
			ejectSmokeGrenade(0)
			gadgetuses = gadgetuses-1
			guiSetText ( gadgetlabel, gadgetuses )
		else
			outputChatBox ( "You are out of Camera Smokes.", 255, 69, 0)
		end
	else
		local weapon = getPedWeapon (localPlayer)
		if weapon == 44 then
			gogglecheckdelay = setTimer ( goggletaskcheck, 200, 1 )
		end
		if weapon == 45 then
			gogglecheckdelay = setTimer ( goggletaskcheck, 200, 1 )
		end
	end
end

--CHECKS IF THE PERSON IS PUTTING ON OR TAKING OFF GOGGLES
function goggletaskcheck ()
	if ( isPedDoingTask ( localPlayer, "TASK_SIMPLE_GOGGLES_ON" ) ) then
		if goggleson == 0 then
			goggleson = 1
			local gogglestype = getPedWeapon (localPlayer)
			if gogglestype == 44 then
				showNightvisionGUI()
			end
			if gogglestype == 45 then
				showInfraredGUI()
			end
			local tableofplayers = getElementsByType("player")
			for tableKey, tableValue in pairs(tableofplayers) do
				iscloaked = getElementData ( tableValue, "stealthmode" )
				if iscloaked == "on" then
					setElementAlpha ( tableValue, 255 )
				end
			end
		end
	end
	if ( isPedDoingTask ( localPlayer, "TASK_SIMPLE_GOGGLES_OFF" ) ) then
		if goggleson == 1 then
			goggleson = 0
			hideGogglesGUI()
			local tableofplayers = getElementsByType("player")
			for tableKey, tableValue in pairs(tableofplayers) do
				iscloaked = getElementData ( tableValue, "stealthmode" )
				if iscloaked == "on" then
					local player = tableValue
					alphachangedelay = setTimer ( setalpha, 100, 1, player )
				end
			end
		end
	end
end

function goggletoggle()
	local isDead = isPedDead(localPlayer)
	if (isDead == false) then
		if goggleson == 0 then
			player = localPlayer
			triggerServerEvent ("goggleswap", localPlayer, player )
		else
			outputChatBox ( "Take off the goggles to toggle their mode.", 255, 69, 0)
		end
	end
end

--STARTUP SETUP

function clientsetup (resource)
	if resource ~= getThisResource() then return end
	notblockingTasks = { TASK_SIMPLE_GET_UP=false, TASK_SIMPLE_SWIM=false, TASK_SIMPLE_LAND=false, TASK_SIMPLE_TIRED=false, TASK_SIMPLE_IN_AIR=true, TASK_SIMPLE_JUMP=true, TASK_SIMPLE_JETPACK=true, TASK_SIMPLE_FALL=true, TASK_SIMPLE_EVASIVE_DIVE=true, TASK_SIMPLE_CLIMB=true, TASK_SIMPLE_CHOKING=true, TASK_SIMPLE_CAR_SLOW_BE_DRAGGED_OUT=true, TASK_SIMPLE_CAR_SLOW_DRAG_PED_OUT=true, TASK_SIMPLE_CAR_QUICK_BE_DRAGGED_OUT=true, TASK_SIMPLE_CAR_QUICK_DRAG_PED_OUT=true, TASK_SIMPLE_CAR_GET_IN=true, TASK_SIMPLE_CAR_GET_OUT=true, TASK_SIMPLE_CAR_JUMP_OUT=true, TASK_SIMPLE_CAR_DRIVE=true, TASK_SIMPLE_BIKE_JACKED=true }
	bindKey ("fire", "down", triggerpulled )
	bindKey ("r", "down", "Use Gadget/Spectate Next", "" )
	bindKey ("r", "up", "Use Gadget/Spectate Next", "0" )
	setElementData ( localPlayer, "stealthmode", "off" )
	goggleson = 0
	burstinprogress = 0
	cameraplaced = 0
	lookingthroughcamera = 0
	loadtheshield = setTimer ( shieldload, 3000, 1 )
end

addCommandHandler ( "Use Gadget/Spectate Next",
	function ( command, state )
		if state == "0" then
			deactivategadget()
		else
			activategadget()
		end
	end
)

addEventHandler ( "onClientResourceStart",root , clientsetup)

addEvent("Clientshieldload",true)
function shieldload ()
	txd_shield = engineLoadTXD("riot_shield.txd")
	engineImportTXD(txd_shield,1631)
	col_shield = engineLoadCOL("riot_shield.col")
	dff_shield = engineLoadDFF("riot_shield.dff", 0 )
	engineReplaceCOL(col_shield,1631)
	engineReplaceModel(dff_shield,1631)
end

addEventHandler( "Clientshieldload", root, shieldload )

--RADAR BURST

function radarblipburst()
	if gadgetuses >0 then
		gadgetuses = gadgetuses-1
		guiSetText ( gadgetlabel, gadgetuses )
		playSoundFrontEnd ( 40 )
		team1 = getTeamFromName("RED")
		team2 = getTeamFromName("BLUE")
		local allplayers = getElementsByType("player")
		for pkey, playerv in pairs(allplayers) do
			local revealedguysteam = getPlayerTeam (playerv)
			if revealedguysteam == team1 then
				local isDead = isPedDead(playerv)
				if (isDead == false) then
					local blipX, blipY, blipZ = getElementPosition ( playerv )
					local theblip = createBlip ( blipX, blipY, blipZ, 0, 2, 255, 0, 0, 75)
					stoptheburst = setTimer ( stopblipburst, 10000, 1, theblip )
				end
			end
			if revealedguysteam == team2 then
				local isDead = isPedDead(playerv)
				if (isDead == false) then
					local blipX, blipY, blipZ = getElementPosition ( playerv )
					local theblip = createBlip ( blipX, blipY, blipZ, 0, 2, 0, 0, 255, 75)
					stoptheburst = setTimer ( stopblipburst, 10000, 1, theblip )
				end
			end
		end
	else
		outputChatBox ( "You are out of Bursts.", localPlayer, 255, 69, 0)
	end
end

function stopblipburst(theblip)
	destroyElement (theblip)
end


--SPYCAMERA

function camerastart()
	if cameraplaced == 0 then
		triggerServerEvent ("placethecam", localPlayer, localPlayer )
	else
		if lookingthroughcamera == 0 then
			if isElementWithinColShape (localPlayer, cameracol) then
				removeSpyCam()
				playSoundFrontEnd(37)
				cameraplaced = 0
				camera = nil
				triggerServerEvent ("killcameraobject", localPlayer, localPlayer )
			else
				lookingthroughcamera = 1
				toggleControl ("fire", false )
				toggleControl ("aim_weapon", false )
				toggleControl ("enter_exit", false )
				toggleControl ("crouch", false )
				toggleControl ("jump", false )
				toggleControl ("right", false )
				toggleControl ("left", false )
				toggleControl ("forwards", false )
				toggleControl ("backwards", false )
				toggleControl ("enter_passenger", false )
				toggleControl ("sprint", false )
				toggleSpyCam()
				playSoundFrontEnd(38)
			end
		else
			toggleSpyCam()
			playSoundFrontEnd(38)
			lookingthroughcamera = 0
			toggleControl ("fire", true )
			toggleControl ("aim_weapon", true )
			toggleControl ("enter_exit", true )
			toggleControl ("crouch", true )
			toggleControl ("jump", true )
			toggleControl ("right", true )
			toggleControl ("left", true )
			toggleControl ("forwards", true )
			toggleControl ("backwards", true )
			toggleControl ("enter_passenger", true )
			toggleControl ("sprint", true )
		end
	end
end


addEvent("findcamerapos", true)

function findthespot (rot)
	radRot = math.rad ( rot )
	local radius = 1
	local px,py,pz = getElementPosition( localPlayer )
	local tx = px + radius * math.sin(radRot)
	local ty = py + -(radius) * math.cos(radRot)
	local tz = pz
	local touching, x, y, z, object = processLineOfSight ( px, py, pz, tx, ty, tz, true, false, false, true, false, true, false, false )
	if (touching) then
		cameraplaced = 1
		player = localPlayer
		if ( isPedDucked ( player) ) then
			z = z-0.7
		end
		triggerServerEvent ("cameraobject", x, y, z, player )
		placeSpyCam ( x, y, z, rot )
		playSoundFrontEnd(37)
		camerax = x
		cameray = y
		cameraz = z
		cameracol = createColSphere ( x, y, z, 1.4 )
	else
		outputChatBox ( "You need to place the cam on a wall", 255, 69, 0)
	end
end

addEventHandler("findcamerapos", root , findthespot)

--SHIELD

function shieldup ()
	toggleControl ("right", false )
	toggleControl ("left", false )
	toggleControl ("forwards", false )
	toggleControl ("backwards", false )
	toggleControl ("enter_exit", false )
	if (isPedDucked ( localPlayer ) == false ) then
		toggleControl ("fire", false )
		toggleControl ("aim_weapon", false )
		toggleControl ("jump", false )
		setPedControlState ( "aim_weapon", true )
		setPedControlState ( "jump", true )
	else
		toggleControl ("jump", false )
		toggleControl ("sprint", false )
	end
	blockcheck = setTimer ( shieldingyet, 300, 0, player )
end


function shieldingyet ()
	if isElementInWater(localPlayer) == false then
		if sheildon ~= 1 then
			currenttask = getPedSimplestTask ( localPlayer )
			if not notblockingTasks[currenttask] then
				killTimer ( blockcheck )
				blockcheck = nil
				shieldon = 1
				stopblockcheck = setTimer ( inturuptshield, 300, 0, player )
				local player = localPlayer
				triggerServerEvent ("shieldup", localPlayer, player )
				currentweapon = getPedWeapon (localPlayer)
			end
		end
	end
end

function inturuptshield ()
	newcurrenttask = getPedSimplestTask ( localPlayer )
	if notblockingTasks[newcurrenttask] then
		killTimer ( stopblockcheck )
		stopblockcheck = nil
		deactivategadget()
	end
	if isElementInWater(localPlayer) then
		if (stopblockcheck) then
			killTimer ( stopblockcheck )
			stopblockcheck = nil
			deactivategadget()
		end
	end
end


function deactivategadget ()
	if chosengadget == "shield" then
		if (blockcheck) then
			killTimer ( blockcheck )
			blockcheck = nil
		end
		if (stopblockcheck) then
			killTimer ( stopblockcheck )
			stopblockcheck = nil
		end
		toggleControl ("right", true )
		toggleControl ("left", true )
		toggleControl ("forwards", true )
		toggleControl ("backwards", true )
		toggleControl ("enter_exit", true )
		toggleControl ("fire", true )
		toggleControl ("aim_weapon", true )
		toggleControl ("jump", true )
		toggleControl ("sprint", true )
		setPedControlState ( "aim_weapon", false )
		setPedControlState ( "jump", false )
		if shieldon == 1 then
			local player = localPlayer
			triggerServerEvent ("shielddown", localPlayer, player, currentweapon )
			shieldon = 0
		end
	end
end


---NIGHTVISION CODE
function showNightvisionGUI()
	addEventHandler ( "onClientRender", root, updateNightvisionGUI )
	mineRefreshTimer = setTimer ( refreshNightvisionGoggles, 1000, 0, localPlayer)
end
--addCommandHandler ( "shownightvision", showNightvisionGUI )

function hideGogglesGUI()
	removeEventHandler ( "onClientRender", root, updateNightvisionGUI )
	removeEventHandler ( "onClientRender", root, updateInfraredGUI )
	killTimer ( mineRefreshTimer )
	clearAllGogglesGUI()
end
--addCommandHandler ( "hide", hideGogglesGUI )

local nightvisionGUI = {}
local infraredGUI = {}
function addNightvisionGUI(element, name)
	nightvisionGUI[element] = guiCreateLabel ( 0, 0, 100, 20, name, false )
	guiLabelSetColor ( nightvisionGUI[element], 255, 255, 255 )
	guiSetVisible ( nightvisionGUI[element], false )
end

function removeNightvisionGUI(element)
	guiSetVisible ( nightvisionGUI[element], false )
	destroyElement ( nightvisionGUI[element] )
	nightvisionGUI[element] = nil
end

function clearAllGogglesGUI()
	for element,label in pairs(nightvisionGUI) do
		guiSetVisible ( label, false )
		destroyElement ( label )
	end
	nightvisionGUI = {}
	for element,label in pairs(infraredGUI) do
		guiSetVisible ( label, false )
		destroyElement ( label )
	end
	infraredGUI = {}
end

function refreshNightvisionGoggles ()
	local itemlist = getElementsByType ( "colshape" )
	for index, item in ipairs(itemlist) do
		if ( getElementData ( item, "type" ) == "alandmine" ) then
			if not nightvisionGUI[item] then
				addNightvisionGUI(item, "MINE")
			end
		elseif ( getElementData ( item, "type" ) == "acamera" ) then
			if not nightvisionGUI[item] then
				addNightvisionGUI(item, "CAMERA")
			end
		end
	end
	for element,label in pairs(nightvisionGUI) do
		if not isElement(element) then
			removeNightvisionGUI(element)
		end
	end
end

local drawDistance = 25

function updateNightvisionGUI ()
	for item,label in pairs(nightvisionGUI) do
		if isElement ( item ) then
			-- outputDebugString ( "Element type: "..getElementType (item) )
			local itemx, itemy, itemz = getElementPosition( item )
			if ( getElementData(item,"type") == "alandmine" ) then itemz = itemz - 1 end
			local playerx,playery,playerz = getElementPosition ( localPlayer )
			local screenX, screenY = getScreenFromWorldPosition ( itemx, itemy, itemz )
			if (screenX) then
				if getDistanceBetweenPoints3D ( playerx, playery, playerz, itemx, itemy, itemz ) < drawDistance then
					guiSetVisible ( label, true )
					guiSetPosition ( label, screenX, screenY, false )
				else
					guiSetVisible ( label, false )
				end
			else
				guiSetVisible ( label, false )
			end
		end
	end
end

---INFRARED CODE
function showInfraredGUI()
	addEventHandler ( "onClientRender", root, updateInfraredGUI )
	mineRefreshTimer = setTimer ( refreshInfraredGoggles, 1000, 0, localPlayer)
end
--addCommandHandler ( "showinfrared", showInfraredGUI )

function addInfraredGUI(element, name)
	infraredGUI[element] = guiCreateLabel ( 0, 0, 100, 20, name, false )
	guiLabelSetColor ( infraredGUI[element], 255, 255, 255 )
	guiSetVisible ( infraredGUI[element], false )
end

function removeInfraredGUI(element)
	guiSetVisible ( infraredGUI[element], false )
	destroyElement ( infraredGUI[element] )
	infraredGUI[element] = nil
end


function refreshInfraredGoggles ()
	local itemlist = getElementsByType ( "player" )
	for index, item in ipairs(itemlist) do
		if item ~= localPlayer then
			if not infraredGUI[item] then
				if getPlayerTeam(item) ~= getPlayerTeam(localPlayer) then
					addInfraredGUI(item, "ENEMY")
				else
					addInfraredGUI(item, "TEAM")
				end
			end
		end
	end
	for element,label in pairs(infraredGUI) do
		if not isElement(element) then
			removeInfraredGUI(element)
		end
	end
end

function updateInfraredGUI ()
	for item,label in pairs(infraredGUI) do
		if isElement ( item ) then
			-- outputDebugString ( "Element type: "..getElementType (item) )
			local itemx, itemy, itemz = getElementPosition( item )
			local playerx,playery,playerz = getElementPosition ( localPlayer )
			local screenX, screenY = getScreenFromWorldPosition ( itemx, itemy, itemz )
			if (screenX) then
				if getDistanceBetweenPoints3D ( playerx, playery, playerz, itemx, itemy, itemz ) < drawDistance then
					guiSetVisible ( label, true )
					guiSetPosition ( label, screenX, screenY, false )
				else
					guiSetVisible ( label, false )
				end
			else
				guiSetVisible ( label, false )
			end
		end
	end
end
