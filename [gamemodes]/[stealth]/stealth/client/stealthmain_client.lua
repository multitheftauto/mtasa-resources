local screenX,screenY = guiGetScreenSize()
local spectateButton
addEvent("swaptoggle", true )

function swaptheteams(thisplayer, teamswap)
	aretheyswapped = teamswap
end

addEventHandler("swaptoggle", root, swaptheteams)

addEvent("showSpectateText",true)
function showSpectateText(text,show)
		if not spectateButton then
			spectateButton = guiCreateButton ( 0,0,1,1,"",false)
			guiSetEnabled ( spectateButton, false )
			guiSetFont ( spectateButton, "clear-normal-normal" )
		end
		local tempText = guiCreateLabel ( 0,0,1000,18,text,false)
		guiSetFont ( tempText, "clear-normalnormal" )
		local length = guiLabelGetTextExtent ( tempText )
		destroyElement ( tempText )
		local buttonLength = length + 40
		local x = (screenX - buttonLength)/2
		guiSetPosition ( spectateButton,x, 0.75 * screenY, false )
		guiSetSize ( spectateButton,buttonLength, 30, false )
		guiSetText ( spectateButton, text )
		guiSetVisible ( spectateButton, show )
--		showCursor ( true )
end
addEventHandler ( "showSpectateText",root,showSpectateText )


addEvent("cameramode", true)

function movetocam()
	showSpectateText("",false)
	local cams = getElementsByType ("camera")
	if #cams > 0 then
		local random = math.random( 1, #cams )
		if ( cams[random] ) then
			local x = getElementData ( cams[random], "posX" )
			local y = getElementData ( cams[random], "posY" )
			local z = getElementData ( cams[random], "posZ" )
			local a = getElementData ( cams[random], "targetX" )
			local b = getElementData ( cams[random], "targetY" )
			local c = getElementData ( cams[random], "targetZ" )
			setCameraMatrix(x, y, z, a, b, c)
		end
	else --Most likely a setting
		local cameraData = getElementData(resourceRoot,"camera")
		if cameraData then
			local x,y,z = unpack(cameraData[1])
			local a,b,c = unpack(cameraData[2])
			setCameraMatrix(x, y, z, a, b, c)
		end
	end
end

addEventHandler("cameramode", root, movetocam)


function updateCam (data)
	if data ~= "camera" then return end
	if not getElementData(source,data) then return end
	movetocam()
end
addEventHandler ( "onClientElementDataChange", resourceRoot, updateCam )

addEvent("Startround",true)

function starttheround(player)
	outputChatBox("Round Started", 255, 69, 0)
	sitthisoneout = setTimer ( idlethisround, 30000, 1, player )
	team = getPlayerTeam ( player )
	showCursor ( true )
	if (team) then
		teamname = getTeamName ( team )
		if teamname == "RED" then
			if aretheyswapped == 0 then
				guiSetVisible ( spiesMenu, true )
			else
				guiSetVisible ( mercenariesMenu, true )
			end
		end
		if teamname == "BLUE" then
			if aretheyswapped == 0 then
				guiSetVisible ( mercenariesMenu, true )
			else
				guiSetVisible ( spiesMenu, true )
			end
		end
	end
	if goggleson == 1 then
		local tableofplayers = getElementsByType("player")
		for tableKey, tableValue in pairs(tableofplayers) do
			iscloaked = getElementData ( tableValue, "stealthmode" )
			if iscloaked == "on" then
				setElementModel ( tableValue, 111 )
				player = tableValue
				alphachangedelay = setTimer ( setalpha, 100, 1, player )
			end
		end
	end
end

addEventHandler("Startround", root, starttheround)

function idlethisround (player)
	sitthisoneout = nil
	guiSetVisible ( spiesMenu, false )
	guiSetVisible ( mercenariesMenu, false )
	outputChatBox ( "Sitting out this round", 255, 69, 0)
end


function confirmSelections ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clicked )
	--work out the team name judging by what OK button they hit, and the menu they''re using so we know which one to hide.
	local teamName
	if source == mercenariesOK then
		teamName = "mercenaries" --if its the mercernariesOK it must be the mercenaries team
	elseif source == spiesOK then
		teamName = "spies"
	else --if it wasnt either, for some reason, just stop the function.
		return
	end
	showCursor (false)
	primarySelection = getSelectedWeapon ( teamName, "primary" )
	secondarySelection = getSelectedWeapon ( teamName, "secondary" )
	throwableSelection = getSelectedWeapon ( teamName, "throwable" )
	spygadgetSelection = getSelectedWeapon ( teamName, "spygadget" )

	--now lets check that they have selected all their weapons, and not left any blank

	if primarySelection == false then
		if source == mercenariesOK then
			local randID = math.random ( 1,#mercenariesWeapons.primary) - 1
			setSelectedWeapon ( teamName, "primary", randID )
		elseif source == spiesOK then
			local randID = math.random ( 1,#spiesWeapons.primary) - 1
			setSelectedWeapon ( teamName, "primary", randID )
		end
	end
	--repeat the process
	if secondarySelection == false then
		if source == mercenariesOK then
			local randID = math.random ( 1,#mercenariesWeapons.secondary) - 1
			setSelectedWeapon ( teamName, "secondary", randID )
		elseif source == spiesOK then
			local randID = math.random ( 1,#spiesWeapons.secondary) - 1
			setSelectedWeapon ( teamName, "secondary", randID )
		end
	end
	if throwableSelection == false then
		if source == mercenariesOK then
			local randID = math.random ( 1,#mercenariesWeapons.throwable) - 1
			setSelectedWeapon ( teamName, "throwable", randID )
		elseif source == spiesOK then
			local randID = math.random ( 1,#spiesWeapons.throwable) - 1
			setSelectedWeapon ( teamName, "throwable", randID )
		end
	end
	if spygadgetSelection == false then
		if source == mercenariesOK then
			local randID = math.random ( 1,#mercenariesWeapons.spygadget) - 1
			setSelectedWeapon ( teamName, "spygadget", randID )
		elseif source == spiesOK then
			local randID = math.random ( 1,#spiesWeapons.spygadget) - 1
			setSelectedWeapon ( teamName, "spygadget", randID )
		end
	end

	--now we retrieve the new selections, incase they have changed
	primarySelection = getSelectedWeapon ( teamName, "primary" )
	secondarySelection = getSelectedWeapon ( teamName, "secondary" )
	throwableSelection = getSelectedWeapon ( teamName, "throwable" )
	spygadgetSelection = getSelectedWeapon ( teamName, "spygadget" )

	---now do whatever you want with these selections.  ive left outputChatBox as an example.  remember to use guiSetVisible to hide the menu.
	if (sitthisoneout) then
		killTimer (sitthisoneout)
		sitthisoneout = nil
	end
	if teamName == "mercenaries" then
		guiSetVisible ( mercenariesMenu, false )
		triggerServerEvent ("domercspawn", localPlayer, localPlayer )
	end

	if teamName == "spies" then
		guiSetVisible ( spiesMenu, false )
		triggerServerEvent ("dospyspawn", localPlayer, localPlayer )
	end
	setTimer (triggerServerEvent, 1000, 1, "givetheguns", localPlayer, localPlayer, primarySelection, secondarySelection, throwableSelection, spygadgetSelection )

end

addEvent("onClientGamemodeMapStop",true)

function stealthmapstop ()
	if (sitthisoneout) then
		killTimer (sitthisoneout)
		sitthisoneout = nil
	end
	guiSetVisible ( spiesMenu, false )
	guiSetVisible ( mercenariesMenu, false )
end

addEventHandler( "onClientGamemodeMapStop", root, stealthmapstop )


--EVERYTHING AFTER THIS IS IS THE GEARSELECT GUI


--[[-------------------------------------------------------------------------
To hide or show your menu, use
guiSetVisible ( spiesMenu, bool showing )
or
guiSetVisible ( mercenariesMenu, bool showing )

Where bool showing can be true or false appropriately.

Remember, this script hides the menus by default and leaves them to you to display.  If you just want to test, you can comment out lines 161 & 162 where
i use guiSetVisible to hide it.
----
To retrieve what item is selected in a certain category, use
getSelectedWeapon (  string teamName, string category )
* teamName: This can either be "spies" or "mercenaries"
* category: This is the selection category.  Can either be "primary", "secondary", "throwable", "spygadget"

This will return the exact string of the item they selected (see appropriate values in the table below) in that category.
If they didnt select one, or an invalid team or category was input, it will return false.

----
To forcefully set an item in a certain category, use
setSelectedWeapon (  string teamName, string category, int row )
* teamName: This can either be "spies" or "mercenaries"
* category: This is the selection category.  Can either be "primary", "secondary", "throwable", "spygadget"
* row: An integer representing which row of the item list should be selected.  This starts from 0

It will return true if successful, false otherwise.  Passing too high or low numbers will just deselect the item.

---
Lastly, ive left some code in the confirmSelections function below, which is commented.  You should find this useful.
-----------------------------------------------------------------------------]]

--set the weapons you want here.  Easilly change the names or add new ones, so long as syntax is correct
mercenariesWeapons = {
["primary"] = {
				"spaz-12",
				"m4",
				"shotgun"
				},
["secondary"] = {
				"desert eagle",
				"pistols",
				"uzis"
				},
["throwable"] = {
				"grenade",
				"satchel",
				"teargas"
				},
["spygadget"] = {
				"radar burst",
				"goggles",
				"prox mine",
				"camera",
				"shield"
				}
}
spiesWeapons = {
["primary"] = {
				"sniper",
				"ak47",
				"rifle"
				},
["secondary"] = {
				"pistols",
				"tec-9s",
				"silenced"
				},
["throwable"] = {
				"molotov",
				"satchel",
				"teargas"
				},
["spygadget"] = {
				"cloak",
				"radar burst",
				"prox mine",
				"camera",
				"armor"
				}
}
--lua cant tell the order of tables which have strings as keys.  so you have to define what order categories should be created in the menu
catOrder = {
["primary"] = 0,
["secondary"] = 1,
["throwable"] = 2,
["spygadget"] = 3
}


local menuX = 0.15
local menuY = 0.33
local menuWidth = 0.7
local menuHeight = 0.34

local gridlistGap = 0.05

---------------------I dont suggest you edit anything below this line unless you know what you''re doing-----------------

function setupStealthMenus ( name )
	if name ~= getThisResource() then return end
	--create our windows
	mercenariesMenu = guiCreateWindow ( menuX, menuY, menuWidth, menuHeight, "Mercenaries", true )
	spiesMenu = guiCreateWindow ( menuX, menuY, menuWidth, menuHeight, "Spies", true )
	--call the setup menu selections function, which will setup the menu items according to the tables configured above
	setupMenuSelections ( mercenariesMenu, mercenariesWeapons, "mercenaries" )
	setupMenuSelections ( spiesMenu, spiesWeapons, "spies" )
	--create our OK buttons
	spiesOK = guiCreateButton ( 0.4, 0.85, 0.20, 0.15, "OK", true, spiesMenu )
	mercenariesOK = guiCreateButton ( 0.4, 0.85, 0.20, 0.15, "OK", true, mercenariesMenu )

	--make it so they cant be moved or sized
--	guiWindowSetMovable ( spiesMenu, false )
--	guiWindowSetMovable ( mercenariesMenu, false )
--	guiWindowSetSizable ( spiesMenu, false )
--	guiWindowSetSizable ( mercenariesMenu, false )

	--hide them by default
	guiSetVisible ( mercenariesMenu, false )
	guiSetVisible ( spiesMenu, false )

	addEventHandler ( "onClientGUIClick", mercenariesOK, confirmSelections )
	addEventHandler ( "onClientGUIClick", spiesOK, confirmSelections )
end
addEventHandler ( "onClientResourceStart", root, setupStealthMenus )

local retrieveGridList = {}
retrieveGridList["mercenaries"] = {}
retrieveGridList["spies"] = {}

function setupMenuSelections ( window, weapons, teamName )
	--work out how many columns we have
	local categories = 0
	for k,v in pairs(weapons) do
		categories = categories + 1
	end
	--first we work out how many gaps we have to make, which is the number of weapon selections - 1
	local gapWidth = gridlistGap * ( categories - 1 )
	--we equally divide the remaining space between the number of required weapon selections
	local gridlistWidth = ( 1.0 - gapWidth ) / categories
	--now we create our gridlists
	for category,weaponsTable in pairs(weapons) do
		local position = catOrder[category]
		local x = position * ( gridlistWidth + gridlistGap )
		local gridList = guiCreateGridList ( x, 0.1, gridlistWidth, 0.75, true, window )
		guiGridListAddColumn ( gridList, category, 0.7 )
		retrieveGridList[teamName][category] = gridList
		local row = 0
		for key, weaponName in pairs ( weaponsTable ) do
			guiGridListAddRow ( gridList )
			guiGridListSetItemText ( gridList, row, 1, weaponName, false, false )
			row = row + 1
		end
	end
end

function getSelectedWeapon ( teamName, category )
	if teamName ~= "mercenaries" and teamName ~= "spies" then return false end
	if retrieveGridList[teamName][category] == nil then return false end
	local gridList = retrieveGridList[teamName][category]
	local row = guiGridListGetSelectedItem ( gridList )
	if row == -1 then return false end
	local selectedWeapon = guiGridListGetItemText ( gridList, row, 1 )
	return selectedWeapon
end

function setSelectedWeapon ( teamName, category, row )
	if teamName ~= "mercenaries" and teamName ~= "spies" then return false end
	if retrieveGridList[teamName][category] == nil then return end
	local gridList = retrieveGridList[teamName][category]
	local returnValue = guiGridListSetSelectedItem ( gridList, row, 1 )
	return returnValue
end


function cleanup (theresource)
	thisone = getThisResource()
	if theresource == thisone then
		setElementAlpha ( getLocalPlayer (), 255 )
		timers = getTimers()
		for timerKey, timerValue in ipairs(timers) do
	        killTimer ( timerValue )
		end
		unbindKey ("fire", "down", triggerpulled )
		unbindKey ("r", "down", "Use Gadget/Spectate Next" )
		unbindKey ("forwards", "down", walksoundstart )
		unbindKey ("backwards", "down", walksoundstart )
		unbindKey ("left", "down", walksoundstart )
		unbindKey ("right", "down", walksoundstart )
		unbindKey ("forwards", "up", walksoundstop )
		unbindKey ("backwards", "up", walksoundstop )
		unbindKey ("left", "up", walksoundstop )
		unbindKey ("right", "up", walksoundstop )
	end
end

addEventHandler("onClientResourceStop", root, cleanup)


--Code for Laser sight on weapons.  Currently only for sniper and M4 weapons
local laserWeapons = {}
function drawLasers()
	for k,player in ipairs(getElementsByType"player") do
		local playerWeapon = getPedWeapon ( player )
		if ( laserWeapons[playerWeapon] ) then
			local startX,startY,startZ,targetX,targetY,targetZ
			local boneX,boneY,boneZ = getPedBonePosition ( player, 25 )
			startX,startY,startZ = getPedWeaponMuzzlePosition ( player )
			if boneX and startX then
				if getPedControlState(player, "aim_weapon") then
					targetX, targetY, targetZ = getPedTargetEnd(player)
				else
					targetX,targetY,targetZ = extendLine ( boneX,boneY,boneZ,startX,startY,startZ - 0.1,500 )
				end

				local bool,hitX,hitY,hitZ = processLineOfSight ( startX,startY,startZ,targetX,targetY,targetZ, true, true, true, true, true, false, false, true )
				if not bool or not hitX then
					hitX,hitY,hitZ = targetX,targetY,targetZ
				end
				dxDrawLine3D ( startX,startY,startZ, hitX,hitY,hitZ, tocolor(255,0,0,50), 1, false, 1 )
			end
		end
	end
end

function TeamSelected ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clicked )
	if source == TeamSelect_Red then
		showCursor ( false )
		triggerServerEvent ("dojoinTeam1", localPlayer, localPlayer )
		guiSetVisible ( TeamSelect_Window[1], false )
	elseif source == TeamSelect_Blue then
		showCursor ( false )
		triggerServerEvent ("dojoinTeam2", localPlayer, localPlayer )
		guiSetVisible ( TeamSelect_Window[1], false )
	end
end

addEventHandler ( "onClientResourceStart", resourceRoot,
	function()
		movetocam(localPlayer)
		local weaponsTable = getElementData(root,"lasersight")
		if type(weaponsTable) == "table" and #weaponsTable > 0 then
			for k,weaponID in ipairs(weaponsTable) do
				laserWeapons[weaponID] = true
			end
			addEventHandler("onClientRender",root,drawLasers)
		end
		showCursor ( true )
		TeamSelect_Window = {}
		TeamSelect_Button = {}
		TeamSelect_Label = {}
		TeamSelect_Window[1] = guiCreateWindow(0.25,0.35,0.5,0.25,"Choose your Team",true)
		TeamSelect_Red = guiCreateButton(0.04,0.2189,0.4244,0.4852,"RED",true,TeamSelect_Window[1])
		TeamSelect_Blue = guiCreateButton(0.5222,0.2189,0.4244,0.4852,"BLUE",true,TeamSelect_Window[1])
		TeamSelect_Label[2] = guiCreateLabel(0.3422,0.7988,0.5111,0.1183,"F3 to return to this menu",true,TeamSelect_Window[1])
		guiLabelSetVerticalAlign(TeamSelect_Label[2],"top")
		guiLabelSetHorizontalAlign(TeamSelect_Label[2],"left",false)
		addEventHandler ( "onClientGUIClick", TeamSelect_Red, TeamSelected)
		addEventHandler ( "onClientGUIClick", TeamSelect_Blue, TeamSelected)
		guiSetVisible(TeamSelect_Window[1], false)
	end
)

addEvent("doshowTeamWindow",true)
function showTeamWindow ()
	guiSetVisible ( TeamSelect_Window[1], true )
	showCursor ( true )
end
addEventHandler ( "doshowTeamWindow",root, showTeamWindow )

function extendLine ( x,y,z,x2,y2,z2,length )
	local vx = x2 - x
	local vy = y2 - y
	local vz = z2 - z
	local ratio = length/(getDistanceBetweenPoints3D ( x,y,z,x2,y2,z2 ))
	vx = vx*ratio
	vy = vy*ratio
	vz = vz*ratio
	return (x + vx),(y + vy),(z + vz)
end

