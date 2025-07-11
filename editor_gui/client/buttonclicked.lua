local mainRes = getResourceFromName"editor_main"
topMenuClicked = {} --a table storing all functions when the topmenu is clicked

--since the highlighter covers an icon button, this function acts as a redirect and triggers the function for the proper button
function buttonClicked(mouseButton, state )
	if state ~= "up" then return end --Happens when you release the click
	if source == guiGetMouseOverElement() then --we dont attach it to the event handler, because "selected" changes (we cant destroy or order GUI)
		--tutorial hooks in here
		if ( tutorialBlock ) then
			if currentButton == tutorialBlock and mouseButton == "left" then
				--if we need to outbranch, these could be made into events later
				playSoundFrontEnd ( 41 )
				--iconData stores the appropriate function to call for a button.  The button itself is passed as a var incase its an element icon.
				iconData[currentButton]["clicked"]( currentButton, mouseButton )
				if tutorialVars.blockTutorialNext then return end
				tutorialNext()
			end
		else
			if currentButton then
				--if we need to outbranch, these could be made into events later
				playSoundFrontEnd ( 41 )
				--iconData stores the appropriate function to call for a button.  The button itself is passed as a var incase its an element icon.
				if (iconData[currentButton].name == "save" or iconData[currentButton].name == "save as") then
					exports.editor_main:dropElement()
				end
				iconData[currentButton]["clicked"]( currentButton, mouseButton )
			end
		end
	end
end


---This is for when one of the element icons is clicked
function elementIcons_Clicked ( source, mouseButton )
	if mouseButton == "left" then
		local elementType = elementIcons[source]["elementName"]
		local resourceName = elementIcons[source]["resource"]
		--triggerServerEvent ( "edfCreateElement", root, elementType, resourceName )
		local shortcut = resourceElementDefinitions[resourceName][elementType].shortcut -- E.g. immediately open model browser
		call(getResourceFromName("editor_main"),"doCreateElement", elementType, resourceName, false, true, shortcut )
	elseif mouseButton == "middle" then
		local elementType = elementIcons[source]["elementName"]
		local resourceName = elementIcons[source]["resource"]
		--triggerServerEvent ( "edfCreateElement", root, elementType, resourceName )
		call(getResourceFromName("editor_main"),"doCreateElement", elementType, resourceName )
	elseif mouseButton == "right" then
		local showing = isCurrentBrowserShowing()
		if not showing then
			local elementType = elementIcons[source]["elementName"]
			local resourceName = elementIcons[source]["resource"]
			showCurrentBrowser ( false, false, elementType, resourceName )
		else
			closeCurrentBrowser()
		end
	end
end

function newCallback(callbackResult)
	if callbackResult == "YES" then
		editor_main.newResource()
	end

	guiSetInputEnabled(false)
end

--These are individual functions for each topmenu button
function topMenuClicked.new ()
	editor_main.dropElement ()
	guiSetInputEnabled(true)
	exports.dialogs:messageBox("New", "Are you sure you want to create a new map? Any unsaved data will be lost.", "newCallback", "QUESTION", "YESNO")
end

function topMenuClicked.open ()
	editor_main.dropElement ()
	triggerServerEvent ( "loadsave_getResources", localPlayer, "open" )
end

function topMenuClicked.save ()
	triggerServerEvent ( "quickSaveResource", localPlayer )
end

function topMenuClicked.options ()
	dumpGUISettings()
	guiSetVisible(dialog.window, true )
	setGUIShowing(false)
	guiSetInputEnabled ( true )
	setWorldClickEnabled ( false )
	inputSettings ( optionsSettings )
end

function topMenuClicked.locations()
	guiSetInputEnabled ( true )
	guiSetVisible ( locationsWindow, true )
end

function topMenuClicked.undo ()
	if ( editor_main.getSelectedElement() ) then playSoundFrontEnd(32) return end
	triggerServerEvent ( "callServerside", localPlayer, "editor_main", "undo" )
end

function topMenuClicked.redo ()
	if ( editor_main.getSelectedElement() ) then playSoundFrontEnd(32) return end
	triggerServerEvent ( "callServerside", localPlayer, "editor_main", "redo" )
end


function topMenuClicked.test ()
	testShowDialog()
end

topMenuClicked["map settings"] = function ()
	guiGridListSetSelectedItem ( mapsettings.settingsList, -1, -1 )
	if ( valueWidget ) then
		valueWidget:destroy()
		valueWidget = nil
	end
	storeOldMapSettings()
	toggleSettingsGUI(false)
	addEventHandler ( "onClientGUIMouseDown", mapsettings.settingsList, settingsListMouseDown )
	mapsettings.rowValues = copyTable ( mapsettings.gamemodeSettings )
	setMapSettings()
	setGUIShowing(false)
	guiSetInputEnabled ( true )
	setWorldClickEnabled ( false )
	guiSetVisible(mapsettings.window, true )
	mapSettingsCamera = {getCameraMatrix()}
end

topMenuClicked["current elements"] = function ()
	local showing = isCurrentBrowserShowing()
	if not showing then
		showCurrentBrowser ()
	else
		closeCurrentBrowser()
	end
end

topMenuClicked.definitions = function ()
	setEDF("availEDF")
	setEDF("addedEDF")
	setGUIShowing(false)
	guiSetInputEnabled ( true )
	setWorldClickEnabled ( false )
	guiSetVisible ( definitionsDialog.window, true )
end

topMenuClicked["save as"] = function ()
	triggerServerEvent ( "loadsave_getResources", localPlayer, "saveAs" )
end
