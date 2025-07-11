--only on part 2
addEvent "onClientElementDrop"
addEvent "onClientElementSelect"
local editorRes = getResourceFromName"editor_main"
tutorialVars = {}

local tutorialAction = {
	enabledCursor = function()
				tutorialNext ()
				end,
	dropped1 = function() tutorialNext () end ,
	selected1 = function() if editor_main.getSubmode() == 1 then
				tutorialNext () end
				end,
	dropped2 = function() tutorialNext () end ,
	selected2 = function() if editor_main.getSubmode() == 2 then
				tutorialNext () end
				end,
	propOpen = function() if ( editor_main.getSelectedElement() ) then
				tutorialNext () end
			end,
	browserCursor = function() tutorialNext () end,
	applyClicked = function() tutorialNext (); guiSetEnabled(properties_btnClose,true) end,
	propOpenVehicle = function()
						local elem = editor_main.getSelectedElement()
						if elem then
							if getElementType(elem) == "vehicle" then
								tutorialNext()
							end
						end
					end,
	closeClicked2 = function() tutorialNext () end,
	cbClose = function() tutorialNext ( ) end


}
function createTutorial()
tutorial = {
	--1
	{ message = "You are currently in camera mode.  You can move around using the "..cc.camera_move_forwards..", "..cc.camera_move_backwards..", "..cc.camera_move_left..", and "..cc.camera_move_right.." keys.  Use the mouse to pan the camera around.  You can use the "..cc.mod_fast_speed.." modifier to increase the speed of the camera and the "..cc.mod_slow_speed.." modifier to slow down the speed of the camera.",
	initiate = function()
				tutorialVars.blockQuickTest = true
				editor_main.toggleEditorKeys (false)
				setTimer ( tutorialNext, 20000, 1 )
			end },
	--2
	{ message = "Press "..cc.toggle_cursor.." to enter cursor mode.  This will allow you to access the editor's menu.",
	initiate = function()
				editor_main.toggleEditorKeys (true)
				bindControl ( "toggle_cursor","down", tutorialAction.enabledCursor )
			end },
	--3
	{ message = "In cursor mode, the Editor's HUD buttons are accessible.  This is the main area where all creation and configuration is performed.  The 'element creation panel' located at the bottom is used to create elements.  Try creating an 'Object' from this panel by left clicking on the 'Object' icon.",
	initiate = function()
				unbindControl ( "toggle_cursor","down", tutorialAction.enabledCursor )
				for icon,iconData in pairs(elementIcons) do
					if iconData.resource == "editor_main" and iconData.elementName == "object" then
						tutorialBlock = icon
						glowButton ( icon )
					end
				end
				tutorialVars.browserBind = "objectID"
			end },
	--4
	{ message = "You have now entered the Model Browser.  This menu will allow you to browse through models of objects, vehicles and skins.",
	initiate = function()
		glowButton ()
		tutorialVars.browserBind = nil
		tutorialVars.browserDisableKeys = true
		tutorialVars.browserDisableCursor = true
		guiSetEnabled(browserGUI.ok,false)
		guiSetEnabled(browserGUI.cancel,false)
		setTimer(tutorialNext,7000,1)
	end },
	{ message = "To change your model category, use the drop down menu at the top.  It is also possible to filter down results further by entering a search in the Search box, where specific model IDs or general keywords can be entered.",
	initiate = function()
		setTimer(tutorialNext,16000,1)
	end },
	--5
	{ message = "Once you have found a model you would like to view, you can click on it from the Results list.  The columns show the internal name of the model, plus the internal ID assigned to it.  Try this now",
	initiate = function()
		tutorialVars.callBack = true
		--
	end },
	--6
		{ message = "Your model can now be seen as a rotating mesh on the right side of the screen. You can scroll through results without the mouse by using the "..cc.browser_up.." and "..cc.browser_down.." keys.   It is also possible to enter camera mode within the model browser.  Try doing this by pressing the "..cc.toggle_cursor.." button.",
	initiate = function()
		tutorialVars.callBack = nil
		tutorialVars.browserDisableCursor = nil
		bindControl ( "toggle_cursor","down", tutorialAction.browserCursor )
		--
	end },
	--7
	{ message = "You are now in camera mode.  You can view the model more clearly in this mode.  You can use the mouse to rotate the camera around the model, and the "..cc.browser_zoom_in.." and "..cc.browser_zoom_out.." keys to zoom in and out.  The "..cc.browser_up.." and "..cc.browser_down.." keys are still activated here to scroll through models.",
	initiate = function()
		unbindControl ( "toggle_cursor", "down", tutorialAction.browserCursor )
		setTimer(tutorialNext,25000,1)
	end },
	--8
	{ message = "The total search and the current selected search numbers are displayed in the top right corner of the screen.  The model name and ID are also displayed.",
	initiate = function()
		setTimer(tutorialNext,9000,1)
	end },
	--9
	{ message = "When you have found a model of your liking, enable cursor mode using the "..cc.toggle_cursor.." key, and press the OK button.",
	initiate = function()
		tutorialVars.browserDisableKeys = nil
		guiSetEnabled(browserGUI.ok,true)
		tutorialVars.browserOK = "objectID"
		--
	end },
	{ message = "You have now created an Object.  You can toggle between cursor and camera modes using the "..cc.toggle_cursor.." key.  This allows for varied placement systems for your element.  Find an area to place your object, and Click when you are done.",
	initiate = function()
			tutorialVars.browserOK = nil
			tutorialBlock = ""
			addEventHandler ("onClientElementDrop",root,tutorialAction.dropped1)
			end },
	--10
	{ message = "To pick up an element again, you can Right click on it.   Try this now.",
	initiate = function()
				removeEventHandler ("onClientElementDrop",root,tutorialAction.dropped1)
				addEventHandler ("onClientElementSelect",root,tutorialAction.selected1)
				--Incase they were silly enough to choose a collisionless object
				tutorialVars.rightClickTimer = setTimer(
					function()
						tutorialNext()
						tutorialNext()
					end,
					30000,
					1
					)
				end },
	--11
	{ message = "Place your element again by clicking in an appropriate positon.",
	initiate = function()
		for k,v in ipairs(getTimers()) do
			if v == tutorialVars.rightClickTimer then
				killTimer ( tutorialVars.rightClickTimer )
			end
		end
		addEventHandler ("onClientElementDrop",root,tutorialAction.dropped2)
		removeEventHandler ("onClientElementSelect",root,tutorialAction.selected1)
	end },
	{ message = "A tip for selecting objects with poor collisions is to enable 'High sensitivity mode'.  Press "..cc.high_sensitivity_mode.." to toggle this.  It will detect objects with poor collisions at the expense of accuracy. If you still cannot select the object, try 'Enable collision patches' in options.",
	initiate = function()
		setTimer ( tutorialNext, 15000, 1 )
	end },
	--12
	{ message = "It is also possible to control your element using the keyboard.  To enable keyboard movement, Left click on it.  Try this with the object.",
	initiate = function()
		addEventHandler ("onClientElementSelect",root,tutorialAction.selected2)
		removeEventHandler ("onClientElementDrop",root,tutorialAction.dropped2)
				end },
	--13
	{ message = "You can now manipulate the object using the keyboard.  Use the "..cc.element_move_forward..", "..cc.element_move_backward..", "..cc.element_move_left..", "..cc.element_move_right.." keys to move elements across the X and Y axes.  Use the "..cc.element_move_upwards.." and "..cc.element_move_downwards.." keys to move elements across the Z axis.",
	initiate = function()
		removeEventHandler ("onClientElementSelect",root,tutorialAction.selected2)
		setTimer(tutorialNext,17000,1)
		end },
	--14
	{ message = "You can use the "..cc.mod_rotate.." and "..cc.mod_rotate_local.." modifiers to switch into rotation mode.  While holding down the "..cc.mod_rotate.." or "..cc.mod_rotate_local.." key, press the "..cc.element_move_forward..", "..cc.element_move_backward..", "..cc.element_move_left..", "..cc.element_move_right..", "..cc.element_move_upwards.." and "..cc.element_move_downwards.." keys to rotate the element in world ("..cc.mod_rotate..") or local ("..cc.mod_rotate_local..") space.",
	initiate = function()
		setTimer(tutorialNext,16000,1)
	end },
	--15
	{ message = "The "..cc.mod_fast_speed.." and "..cc.mod_slow_speed.." speed modifiers remain active in keyboard mode.",
	initiate = function()
		setTimer(tutorialNext,14000,1)
	end },
	--16
	{ message = "The " ..cc.element_scale_up.." and "..cc.element_scale_down.." keys can be used to scale the object up and down.",
	initiate = function()
		setTimer(tutorialNext,15000,1)
	end },
	--17
	{ message = "It is important that you are able to change the attributes of your object.  This can be done via the properties box.  To open the properties box, press the "..cc.properties_toggle.." key while an element is selected.  Alternatively you can double click the element.",
	initiate = function()
		tutorialVars.detectPropertiesBox = true
	end },
	--18
	{ message = "This menu is the Properties box.  From here, all properties of an element can be accessed and modified.  Here you can manually change useful attributes such as position and rotation, or model.  You can mouse over an attribute to get information about that property.",
	initiate = function()
		tutorialVars.detectPropertiesBox = false
		unbindControl ( "properties_toggle","down", tutorialAction.propOpen )
		guiSetEnabled(properties_btnApply,false)
		guiSetEnabled(properties_btnCancel,false)
		guiSetEnabled(properties_btnOK,false)
		guiSetEnabled(properties_btnPullout,false)
		setTimer(tutorialNext,26000,1)
	end },
	--19
	{ message = "When you are done, choose 'OK' to close and apply all changes, alternatively press 'Cancel' to close and ignore all changes.",
	initiate = function()
		guiSetEnabled(properties_btnApply,true)
		guiSetEnabled(properties_btnCancel,true)
		guiSetEnabled(properties_btnOK,true)
		addEventHandler ( "onClientGUIClick",properties_btnApply,tutorialAction.applyClicked,false )
		addEventHandler ( "onClientGUIClick",properties_btnCancel,tutorialAction.applyClicked,false )
		addEventHandler ( "onClientGUIClick",properties_btnOK,tutorialAction.applyClicked,false )
		--
	end },
	--20
	{ message = "The same can be done for elements of any other type.  From the cursor mode menu, create a 'Vehicle'.",
	initiate = function()
		for icon,iconData in pairs(elementIcons) do
			if iconData.resource == "editor_main" and iconData.elementName == "vehicle" then
				tutorialBlock = icon
				glowButton ( icon )
			end
		end
		removeEventHandler ( "onClientGUIClick",properties_btnApply,tutorialAction.applyClicked,false )
		removeEventHandler ( "onClientGUIClick",properties_btnCancel,tutorialAction.applyClicked,false )
		removeEventHandler ( "onClientGUIClick",properties_btnOK,tutorialAction.applyClicked,false )
		tutorialVars = {}
		tutorialVars.browserBind = "vehicleID"
	end },
	--21
	{ message = "This is the model browser again, only for vehicles.  Choose a desired vehicle and press 'OK' to exit.",
	initiate = function()
		glowButton ()
		tutorialVars.browserOK = "vehicleID"
		tutorialVars.browserBind = nil
	end },
	{ message = "Place your vehicle, and use the "..cc.properties_toggle.." button to enter the properties box.",
	initiate = function()
		tutorialVars.browserOK = nil
		tutorialVars.browserBind = nil
		tutorialVars.detectPropertiesBox = true
	end },
	--22
	{ message = "Notice that the properties for this element are different to that of an object.  Set your desired properties, click 'OK' to apply these changes, or alternatively press 'Cancel' to ignore them.",
	initiate = function()
		tutorialVars.detectPropertiesBox = nil
		addEventHandler ( "onClientGUIClick",properties_btnCancel,tutorialAction.closeClicked2, false )
		addEventHandler ( "onClientGUIClick",properties_btnApply,tutorialAction.closeClicked2, false )
		addEventHandler ( "onClientGUIClick",properties_btnOK,tutorialAction.closeClicked2, false )
	end },
	--23
	{ message = "This mostly covers what is involved in creating and manipulating elements.  For more details, please refer to the manual.",
	initiate = function()
		tutorialBlock = ""
		removeEventHandler ( "onClientGUIClick",properties_btnCancel,tutorialAction.closeClicked2 )
		removeEventHandler ( "onClientGUIClick",properties_btnApply,tutorialAction.closeClicked2 )
		removeEventHandler ( "onClientGUIClick",properties_btnOK,tutorialAction.closeClicked2 )
		setTimer(tutorialNext,9000,1)
	end },
	--24
	{ message = "We will briefly look at some of the buttons at the Control panel.  This is placed at the top of your screen.  The 'new','open','save' and 'save as' buttons allow for creating new maps, opening them and saving them.",
	initiate = function()
		setTimer(tutorialNext,19000,1)
		local icons = {}
		for icon,iconData in pairs(iconData) do
			if iconData.name == "new" or  iconData.name == "open" or iconData.name == "save" or iconData.name == "save as" then
				table.insert (icons,icon)
			end
		end
		glowButton ( icons )
	end },
	--25
	{ message = "The 'options' dialog allows for configuration of move speeds, camera speeds, and general settings.  The 'undo' and 'redo' buttons allow reversal and affirmation of performed actions.  The 'locations' dialog allows for changing the location of editing, and for storing your favourite locations to be used.",
	initiate = function()
		glowButton ()
		setTimer(tutorialNext,30000,1)
		local icons = {}
		for icon,iconData in pairs(iconData) do
			if iconData.name == "options" or iconData.name == "undo" or  iconData.name == "redo" or iconData.name == "locations" then
				table.insert (icons,icon)
			end
		end
		glowButton ( icons )
	end },
	--26
	{ message = "The 'definitions' dialog allows importing of custom elements into the editor, so that maps for specific gamemodes can be produced quickly and easily. ",
	initiate = function()
		glowButton ()
		setTimer(tutorialNext,9000,1)
		for icon,iconData in pairs(iconData) do
			if iconData.name == "definitions" then
				glowButton ( icon )
			end
		end
	end },
	--27
	{ message = "The 'current elements' button allows browsing of your current elements, and is an easy way to locate specific elements when you have lots created.  Try opening the Current Elements dialog.",
	initiate = function()
		glowButton ()
		for icon,iconData in pairs(iconData) do
			if iconData.name == "current elements" then
				tutorialBlock = icon
				glowButton ( icon )
			end
		end
	end },
	--28
	{ message = "This is the Current Elements browser.  Similar to the Model Browser, you can also enter searches to find your already placed elements.",
	initiate = function()
		tutorialBlock = ""
		glowButton ()
		guiSetEnabled ( currentBrowserGUI.close,false )
		setTimer(tutorialNext,13000,1)
	end },
	--29
	{ message = "The dropdown at the top allows you filter to specific element types.   The 'Autosnap camera' checkbox allows toggling of whether the camera should immediately snap to the position of an element when it is selected.  The 'Isolate element' hides all other elements and allows clarity as to which element is selected.",
	initiate = function()
		setTimer(tutorialNext,26000,1)
	end },
	--30
	{ message = "Similar to the Model Browser, you can use the "..cc.currentelements_up.." and "..cc.currentelements_down.." keys to scroll through results in the list.",
	initiate = function()
		setTimer(tutorialNext,7000,1)
	end },
	--31
	{ message = "It is possible to select an element in keyboard mode by double clicking the item in the search.  Once this is done, you can move the element using the keyboard mode keys.  You can close the Current Elements browser anytime by hitting the 'Close' button.  Try this when you're done.",
	initiate = function()
		guiSetEnabled ( currentBrowserGUI.close,true)
		addEventHandler ( "onClientGUIClick",currentBrowserGUI.close,tutorialAction.cbClose , false )
	end },
	--32
	{ message = "The map settings dialog allows general configuration of your map.  Click the 'map settings' button to open up this dialog.",
	initiate = function()
		removeEventHandler ( "onClientGUIClick",currentBrowserGUI.close,tutorialAction.cbClose )
		for icon,iconData in pairs(iconData) do
			if iconData.name == "map settings" then
				tutorialBlock = icon
				glowButton ( icon )
			end
		end
	end },
	--33
	{ message = "The 'Environment' tab contains settings for time,weather, and other settings that affect the style of play within a map.  The 'Gamemode Settings' tab allows setting of specific settings related to a gamemode, according to Definitions that are loaded.",
	initiate = function()
		glowButton ()
		setTimer ( tutorialNext, 17000, 1 )
		tutorialVars.onMSClose = true
	end },
	--34
	{ message = "The Meta tab allows setting of general information for your map - the name, author, version and description.  Lastly, the 'Gamemodes' tab allows selecting of gamemodes that are compatible with your map.  Once you are done press the 'OK' button to apply the settings.",
	initiate = function()
	end },
	{ message = "Lastly, the 'test' dialog allows you to enter test mode.  Either open the dialog to choose the gamemode to test with (based upon definitions), or press "..cc.toggle_test.." to quickly enter test mode.  Try this now.",
	initiate = function()
		for icon,iconData in pairs(iconData) do
			if iconData.name == "test" then
				tutorialBlock = icon
				glowButton ( icon )
				tutorialVars.blockTutorialNext = true
			end
		end
		tutorialVars.blockQuickTest = nil
		tutorialVars.test = true
	end },
	{ message = "You have now entered test mode, which allows you to simulate normal gameplay.  Use F1 to bring up controls, and to end the test.   Alternatively press "..cc.toggle_test.." to end the test.",
	initiate = function()
		glowButton ()
	end },
	--35
	{ message = "You have reached the end of the Editor tutorial.  This tutorial has only covered some aspects that are available within the editor.  For all the details, please refer to the manual.",
	initiate = function()
		guiSetEnabled(properties_btnPullout,true)
		dialog.tutorialOnStart:setValue(false)
		dumpSettings()
		xmlSaveFile ( settingsXML )
		tutorialVars = {}
		tutorialBlock = nil
		tutorialID = nil
		removeEventHandler ( "onClientRender", root, drawGlow )
		stopTutorial()
		setTimer (
			function()
				removeEventHandler ( "onClientRender", root, drawRectangle )
				removeEventHandler ( "onClientRender", root, drawText )
			end,
			25000,
			1
			)
	end }
}
end
