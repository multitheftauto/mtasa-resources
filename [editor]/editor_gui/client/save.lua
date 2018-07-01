local TEST_RESOURCE = "editor_test"
local DUMP_RESOURCE = "editor_dump"
local mapsInfo = {}
local resourcesInfo = {}
saveDialog = {}

function createSaveDialog()
	saveDialog.window	=	guiCreateWindow ( screenX/2 - 320, screenY/2 - 180, 640, 360, "SAVE...", false )
	saveDialog.mapsList = guiCreateGridList ( 0.02, 0.08, 0.98, 0.75, true, saveDialog.window )
	saveDialog.save = guiCreateButton ( 0.780357142, 0.85388845, 0.22857142, 0.05555555, "Save", true, saveDialog.window )
	saveDialog.cancel = guiCreateButton ( 0.780357142, 0.919444, 0.22857142, 0.05555555, "Cancel", true, saveDialog.window )
	saveDialog.mapName = guiCreateEdit ( 0.02, 0.87388845, 0.75, 0.08, "", true, saveDialog.window )
	--
	guiGridListAddColumn ( saveDialog.mapsList, "Name", 0.4 )
	guiGridListAddColumn ( saveDialog.mapsList, "Gamemodes", 0.4 )
	guiGridListAddColumn ( saveDialog.mapsList, "Version", 0.13 )
	guiGridListSetSelectionMode ( saveDialog.mapsList, 0 )
	guiSetVisible ( saveDialog.window, false )
	addEventHandler ( "onClientGUIClick", saveDialog.cancel, closeSaveDialog, false )
	addEventHandler ( "onClientGUIClick", saveDialog.save, saveMap, false )
	addEventHandler ( "onClientGUIDoubleClick", saveDialog.mapsList, saveMap, false )
	addEventHandler ( "onClientGUIClick", saveDialog.mapsList, setSaveEditBoxMapName, false )
	addEventHandler ( "onClientGUIAccepted", saveDialog.mapName,
		function ()
			if guiGetProperty(saveDialog.window, "Disabled") == "False" then
				saveMap()
			end
		end, false )
	addEventHandler ( "onClientGUIChanged", saveDialog.mapName,
		function ()
			local name = guiGetText(source)
			local correctFormat = string.gsub(name, " ", "-") -- Turn spaces into dashes
			local correctFormat = string.gsub(correctFormat, "[^%w-_{}]", "") -- Then remove bad charachters
			if name ~= correctFormat then
				guiSetText(source, correctFormat)
			end
		end, false )
end

function closeSaveDialog()
	guiSetVisible ( saveDialog.window, false )
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	guiSetProperty(saveDialog.window, "Disabled", "False")
end

function saveMap()
	mapName = guiGetText ( saveDialog.mapName )
	if mapName == "" then return end
	if mapsInfo[string.lower(mapName)] then
		local save,cancel = guiShowMessageBox ( "Are you sure you want to overwrite map \""..mapName.."\"?\n" ..
		                                        "This will cause original map data to be lost.",
						        "info", "Are you sure?", true, "Save", "Cancel" )
		addEventHandler ( "onClientGUIClick", save,   saveButton,   false )
		addEventHandler ( "onClientGUIClick", cancel, restoreSaveDialog, false )
		guiSetProperty(saveDialog.window, "Disabled", "True")
	elseif resourcesInfo[string.lower(mapName)] then
		guiShowMessageBox ( "Unable to save to \""..mapName.."\".  \n" ..
		                    "You cannot overwrite non-map resources.",
				    "error", "Cannot save", true )
	else
		local save,cancel = guiShowMessageBox ( "Are you sure you want to save to \""..mapName.."\"?",
		                                        "info", "Are you sure?", true, "Save", "Cancel" )
		addEventHandler ( "onClientGUIClick", save,   saveButton,   false )
		addEventHandler ( "onClientGUIClick", cancel, restoreSaveDialog, false )
		guiSetProperty(saveDialog.window, "Disabled", "True")
	end
end

function saveButton()
	local resourceName = guiGetText ( saveDialog.mapName )
	editor_main.saveResource ( resourceName )
end

function restoreSaveDialog()
  guiSetProperty(saveDialog.window, "Disabled", "False")
end

addEvent ( "saveAsShowDialog", true )
function saveShowDialog( resources )
	if ( exports.editor_main:getMode() ~= 2 ) then
		exports.editor_main:setMode(2)
	end
	setGUIShowing(false)
	guiSetInputEnabled ( true )
	setWorldClickEnabled ( false )
	guiSetText ( saveDialog.mapName, "" )
	guiGridListClear ( saveDialog.mapsList )
	for i,res in ipairs(resources) do
		if res["type"] == "map" and string.lower(res["friendlyName"]) ~= TEST_RESOURCE and string.lower(res["friendlyName"]) ~= DUMP_RESOURCE then
			local row = guiGridListAddRow ( saveDialog.mapsList )
			guiGridListSetItemText ( saveDialog.mapsList, row, 1, res["friendlyName"], false, false )
			guiGridListSetItemText ( saveDialog.mapsList, row, 2, res["gamemodes"], false, false )
			guiGridListSetItemText ( saveDialog.mapsList, row, 3, res["version"], false, false )
			mapsInfo[string.lower(res["friendlyName"])] = true
		end
		resourcesInfo[string.lower(res["friendlyName"])] = true
	end
	guiSetVisible ( saveDialog.window, true )
	guiBringToFront( saveDialog.mapName )
end
addEventHandler ( "saveAsShowDialog", getRootElement(), saveShowDialog )

function setSaveEditBoxMapName()
	local row = guiGridListGetSelectedItem ( saveDialog.mapsList )
	if row == -1 then
		guiSetText ( saveDialog.mapName, "" )
	else
		mapName = guiGridListGetItemText ( saveDialog.mapsList, row, 1 )
		guiSetText ( saveDialog.mapName, mapName )
	end
end
