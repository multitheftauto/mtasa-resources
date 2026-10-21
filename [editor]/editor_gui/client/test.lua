local editorRes = getResourceFromName("editor_main")
local testDialog = {}
local hideDialog
local g_suspended
local inBasicTest = false
local lastTestGamemode
local lastGridListGamemode
local g_colPatchSetting
local testPending = false

local function setTestControl(handler)
	unbindControl("toggle_test", "down", quickTest)
	unbindControl("toggle_test", "down", stopTest)
	if handler then
		bindControl("toggle_test", "down", handler)
	end
end

function createTestDialog()
	testDialog.window = guiCreateWindow ( screenX/2 - 110, screenY/2 - 145, 220, 290, "TEST", false )
	testDialog.gamemodesList = guiCreateGridList ( 0.02, 0.08, 0.98, 0.75, true, testDialog.window )
	testDialog.basic = guiCreateButton ( 0.02, 0.84, 0.30, 0.12, "Basic Test", true, testDialog.window )
	testDialog.test = guiCreateButton ( 0.35, 0.84, 0.29, 0.12, "Full Test", true, testDialog.window )
	testDialog.cancel = guiCreateButton ( 0.65, 0.84, 0.30, 0.12, "Cancel", true, testDialog.window )
	guiGridListAddColumn ( testDialog.gamemodesList, "Gamemodes", 0.8 )
	--
	guiSetVisible ( testDialog.window, false )
	addEventHandler ( "onClientGUIClick", testDialog.cancel, testHideDialog, false )
	addEventHandler ( "onClientGUIClick", testDialog.test, testStart, false )
	addEventHandler ( "onClientGUIClick", testDialog.basic, basicTest, false )
	--
	if getElementData ( localPlayer, "waitingToStart" ) then
		setTestControl(stopTest)
		addCommandHandler ( "stoptest", stopTest )
	else
		setTestControl(quickTest)
	end
	bindControl ( "toggle_basictest", "down", basicTest )
end

function quickTest()
	if tutorialVars.blockQuickTest or g_suspended or testPending then return end
	testPending = true
	-- get the last gamemode that was addded to the map
	local rowCount = guiGridListGetRowCount(mapsettings.addedGamemodes)
	local currentLastGamemode = false
	if rowCount > 0 then
		currentLastGamemode = guiGridListGetItemText(mapsettings.addedGamemodes, rowCount - 1, 1)
		if currentLastGamemode == "<None>" then
			currentLastGamemode = false
		end
	end
	if lastGridListGamemode ~= currentLastGamemode then
		lastTestGamemode = currentLastGamemode
		lastGridListGamemode = currentLastGamemode
	end
	if lastTestGamemode == "<None>" then lastTestGamemode = false end
	editor_main.dropElement()
	triggerServerEvent ( "testResource",localPlayer, lastTestGamemode )
	setTestControl(nil)
	if tutorialVars.test then tutorialNext() end
end

function testShowDialog()
	if g_suspended or testPending then return end
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
		local row2 = guiGridListAddRow ( testDialog.gamemodesList )
		guiGridListSetItemText ( testDialog.gamemodesList, row2, 1, gamemodeName, false, false )
		if gamemodeName == lastTestGamemode then
			set = row2
		end
	end
	guiGridListSetSelectedItem(testDialog.gamemodesList,set,1)
	setTestControl(nil)
	return true
end

function confirmTest()
	if g_suspended or testPending then return end
	testPending = true
	setTestControl(nil)
	triggerServerEvent ( "testResource",localPlayer, false )
end

function suspendGUI()
	testPending = false
	if g_suspended then
		setTestControl(stopTest)
		return
	end
	g_suspended = true
	guiSetVisible ( testDialog.window, false )
	guiSetInputEnabled ( false )
	freezeTime ( false )
	showCursor(false)
	engineSetAsynchronousLoading ( true, false )
	editor_main.suspend ()
	-- Suspending clears editor controls, so bind the test control afterwards.
	setTestControl(stopTest)
	addCommandHandler ( "stoptest", stopTest )
	if (not inBasicTest) then return end
	inBasicTest = false
	removeEventHandler("onClientPlayerDamage", localPlayer, noDamageInBasicTest)
	toggleControl("fire", true)
	toggleControl("enter_exit", true)
	toggleControl("enter_passenger", true)
end
addEvent("suspendGUI", true)
addEventHandler("suspendGUI", root, suspendGUI)

function resumeGUI ()
	testPending = false
	removeCommandHandler("stoptest", stopTest)
	if getElementData ( localPlayer, "waitingToStart" ) then
		setElementData ( localPlayer, "waitingToStart", nil, false )
		g_suspended = false
		editor_main.startEditor()
		setGUIShowing(true)
		setTestControl(quickTest)
		return
	end
	freezeTime ( true, currentMapSettings.timeHour, currentMapSettings.timeMinute )
	setWeather ( currentMapSettings.weather )
	setElementDimension ( localPlayer, editor_main.getWorkingDimension() )
	setElementAlpha ( localPlayer, 0 )
	fadeCamera ( true )
	if not g_suspended then
		setTestControl(quickTest)
		return
	end
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	engineSetAsynchronousLoading ( false, true )
	editor_main.resume (true)
	-- Resuming restores the saved controls; replace any restored test binding.
	setTestControl(quickTest)
	g_suspended = false
	setCloudsEnabled(false)
end
addEvent("resumeGUI", true)
addEventHandler("resumeGUI", root, resumeGUI)

function stopTest()
	if testPending or not (g_suspended or getElementData(localPlayer, "waitingToStart")) then return end
	testPending = true
	setTestControl(nil)
	if tutorialVars.test then tutorialNext() end
	triggerServerEvent("stopTest", localPlayer)
end

function testHideDialog()
	if g_suspended or testPending then return end
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	guiSetVisible ( testDialog.window, false )
	setTestControl(quickTest)
end

function disableColPatchInTesting()
	-- Store the current setting
	g_colPatchSetting = sx_getOptionData("enableColPatch")
	-- Already disabled?
	if not g_colPatchSetting then return end

	-- Disable
	guiCheckBoxSetSelected(dialog.enableColPatch.GUI.checkbox, false)
	doActions()
end

function enableColPatchAfterTesting()
	-- Wasnt enabled?
	if not g_colPatchSetting then return end

	-- Enable
	guiCheckBoxSetSelected(dialog.enableColPatch.GUI.checkbox, true)
	confirmSettings()
end

function testStart()
	if g_suspended or testPending then return end
	local row = guiGridListGetSelectedItem (  testDialog.gamemodesList )
	if row ~= -1 then
		local text = guiGridListGetItemText ( testDialog.gamemodesList,row,1)
		lastTestGamemode = text
		if text == "<None>" then text = false end
		testPending = true
		setTestControl(nil)
		editor_main.dropElement()
		triggerServerEvent ( "testResource",localPlayer, text )
		if tutorialVars.test then tutorialNext() end
	end
end

local function freeroamStarting(resource)
	if resource ~= getResourceFromName("freeroam") then return end
	local message = "Editor test mode enabled.  Press F1 to show/hide controls"
	for i, vehicle in ipairs(getElementsByType("vehicle")) do
		if (getVehicleType(vehicle) == "Train" and getElementDimension(vehicle) == getElementDimension(localPlayer)) then
			message = message.." (Any trains are moved to the nearest track)"
			break
		end
	end
	outputMessage ( message, 0, 180, 0, 7000 )
	local button = freeroam.appendControl ( "wndMain", {"btn", text="Stop testing"})
	addEventHandler ( "onClientGUIClick",button,stopTest, false )
	local workingInterior = editor_main.getWorkingInterior()
	setElementInterior(localPlayer,workingInterior)
	setCameraInterior(workingInterior)
	disableColPatchInTesting()
end
addEventHandler("onClientResourceStart", root, freeroamStarting)

function freeroamStopping(resource)
	if resource ~= getResourceFromName("freeroam") then return end

	enableColPatchAfterTesting()
end
addEventHandler("onClientResourceStop", root, freeroamStopping)

function basicTest()
	if g_suspended or testPending then return end

	if (inBasicTest) then
		freezeTime(true, currentMapSettings.timeHour, currentMapSettings.timeMinute)
		setWeather(currentMapSettings.weather)
		setElementDimension(localPlayer, editor_main.getWorkingDimension())
		setElementAlpha(localPlayer, 0)
		fadeCamera(true)
		setGUIShowing(true)
		guiSetInputEnabled(false)
		setWorldClickEnabled(true)
		engineSetAsynchronousLoading ( false, true )
		editor_main.resume(true)
		inBasicTest = false
		removeEventHandler("onClientPlayerDamage", localPlayer, noDamageInBasicTest)
		toggleControl("fire", true)
		toggleControl("enter_exit", true)
		toggleControl("enter_passenger", true)

		-- Force object collisions (since they must be enabled when editing)
		for i, obj in pairs(getElementsByType("object")) do
			setElementCollisionsEnabled(obj, true)
		end

		enableColPatchAfterTesting()
	else
		editor_main.dropElement()
		guiSetVisible(testDialog.window, false)
		guiSetInputEnabled(false)
		freezeTime(false)
		showCursor(false)
		engineSetAsynchronousLoading ( true, false )
		editor_main.suspend ()
		setCameraTarget(localPlayer)
		toggleControl("fire", false)
		toggleControl("enter_exit", false)
		toggleControl("enter_passenger", false)
		inBasicTest = true
		addEventHandler("onClientPlayerDamage", localPlayer, noDamageInBasicTest)
		outputChatBox("Press F6 to leave basic test", 0, 255, 0)
		bindControl ( "toggle_basictest", "down", basicTest )

		-- Make any collisionless objects collisionless for basic test
		for i, obj in pairs(getElementsByType("object")) do
			local objectCollision = getElementData(obj, "collisions")
			if (objectCollision and objectCollision == "false") then
				setElementCollisionsEnabled(obj, false)
			end
		end

		disableColPatchInTesting()
	end
end

function noDamageInBasicTest()
	cancelEvent()
end

addEventHandler ( "saveloadtest_return", root,
	function ( command )
		if command == "new" or command == "open" then
			lastTestGamemode = nil
		end
	end
)

function isTesting()
	local editor = getResourceFromName("editor_main")
    if not editor or getResourceState(editor) ~= "running" then
        return false
    end
	-- Full test?
    if getElementData(getResourceRootElement(editor), "g_in_test") then
        return true
    end
	-- Baisc test?
	return inBasicTest
end