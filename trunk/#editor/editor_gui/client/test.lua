local localPlayer = getLocalPlayer()
local editorRes = getResourceFromName"editor_main"
local testDialog = {}
local hideDialog
local g_suspended
--
local lastTestGamemode

function createTestDialog()
	testDialog.window = guiCreateWindow ( screenX/2 - 110, screenY/2 - 145, 220, 290, "TEST", false )
	testDialog.gamemodesList = guiCreateGridList ( 0.02, 0.08, 0.98, 0.75, true, testDialog.window )
	testDialog.test = guiCreateButton ( 0.02, 0.84, 0.46, 0.12, "Test", true, testDialog.window )
	testDialog.cancel = guiCreateButton ( 0.5, 0.84, 0.46, 0.12, "Cancel", true, testDialog.window )
	guiGridListAddColumn ( testDialog.gamemodesList, "Gamemodes", 0.8 )
	--
	guiSetVisible ( testDialog.window, false )
	addEventHandler ( "onClientGUIClick",testDialog.cancel,testHideDialog,false )
	addEventHandler ( "onClientGUIClick",testDialog.test,testStart,false )
	--
	if getElementData ( localPlayer, "waitingToStart" ) then
		bindControl ( "toggle_test", "down", stopTest )
		addCommandHandler ( "stoptest", stopTest )
	else
		bindControl ( "toggle_test", "down", quickTest )
	end
end

function quickTest()
	if tutorialVars.blockQuickTest then return end
	if lastTestGamemode == "<None>" then lastTestGamemode = false end
	editor_main.dropElement()
	triggerServerEvent ( "testResource",localPlayer, text )
	unbindControl ( "toggle_test", "down", quickTest )
	if tutorialVars.test then tutorialNext() end
end


function testShowDialog()
	setGUIShowing(false)
	guiSetInputEnabled ( true )
	setWorldClickEnabled ( false )
	
	--[[  This is for disabling gamemode testing
	local yes,no = guiShowMessageBox ( "Are you sure you want to begin a Test?", "question", "Test?", true, "Yes", "No" )
	addEventHandler ( "onClientGUIClick", yes, confirmTest, false )
	addEventHandler ( "onClientGUIClick", no, testHideDialog, false )
	]]
	guiSetVisible ( testDialog.window, true )
	guiGridListClear ( testDialog.gamemodesList )
	local set = 0
	local row = guiGridListAddRow ( testDialog.gamemodesList )
	guiGridListSetItemText ( testDialog.gamemodesList, row, 1, "<None>", false, false )
	for key,gamemodeName in ipairs(currentMapSettings.addedGamemodes) do
		local row = guiGridListAddRow ( testDialog.gamemodesList )
		guiGridListSetItemText ( testDialog.gamemodesList, row, 1, gamemodeName, false, false )
		if gamemodeName == lastTestGamemode then
			set = row
		end
	end
	guiGridListSetSelectedItem(testDialog.gamemodesList,set,1)
	unbindControl ( "toggle_test", "down", quickTest )
	return true
end

function confirmTest()
	triggerServerEvent ( "testResource",localPlayer, false )
end

addEvent ("suspendGUI",true)
addEventHandler("suspendGUI",getRootElement(),
	function()
		if g_suspended then return end
		g_suspended = true
		guiSetVisible ( testDialog.window, false )
		guiSetInputEnabled ( false )
		freezeTime ( false )
		showCursor(false)
		editor_main.suspend ()
		addCommandHandler ( "stoptest", stopTest )
	end
)

addEvent ( "resumeGUI", true )
function resumeGUI ()
	if getElementData ( localPlayer, "waitingToStart" ) then
		setElementData ( localPlayer, "waitingToStart", nil, false )
		editor_main.startEditor()
		setGUIShowing(true)
		return
	end
	freezeTime ( true, currentMapSettings.timeHour, currentMapSettings.timeMinute )
	setWeather ( currentMapSettings.weather )
	setElementDimension ( localPlayer, editor_main.getWorkingDimension() )
	setElementAlpha ( localPlayer, 0 )
	fadeCamera ( true )
	--showCursor(true)
	removeCommandHandler ( "stoptest", stopTest )
	if not g_suspended then return end
	--
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	editor_main.resume (true)
	--editor_main.toggleEditorKeys(true)
	g_suspended = false
end
addEventHandler("resumeGUI",getRootElement(),resumeGUI)

function stopTest()
--[[	for k,player in ipairs(getElementsByType("player")) do
		if player ~= getLocalPlayer() then
			setElementDimension(player, editor_main.getWorkingDimension())
		end
	end]]
	if tutorialVars.test then tutorialNext() end
	triggerServerEvent ( "stopTest",localPlayer )
	unbindControl ( "toggle_test", "down", stopTest )
	bindControl ( "toggle_test", "down", quickTest )
	-- resumeGUI ()
end

function testHideDialog()
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	guiSetVisible ( testDialog.window, false )
	bindControl ( "toggle_test", "down", quickTest )
end

function testStart()
	local row = guiGridListGetSelectedItem (  testDialog.gamemodesList )
	if row ~= -1 then
		local text = guiGridListGetItemText ( testDialog.gamemodesList,row,1)
		lastTestGamemode = text
		if text == "<None>" then text = false end
		editor_main.dropElement()
		triggerServerEvent ( "testResource",localPlayer, text )
		if tutorialVars.test then tutorialNext() end
	end
end

addEventHandler ("onClientResourceStart",getRootElement(),
	function(resource)
		if resource ~= getResourceFromName"freeroam" then return end
		outputMessage ( "Editor test mode enabled.  Press F1 to show/hide controls", 0, 180, 0, 7000 )
		local button = freeroam.appendControl ( "wndMain", {"btn", text="Stop testing"})
		addEventHandler ( "onClientGUIClick",button,stopTest, false )
		local workingInterior = editor_main.getWorkingInterior()
		setElementInterior(localPlayer,workingInterior)
		setCameraInterior(workingInterior)
		bindControl ( "toggle_test", "down", stopTest )
	end	
)

