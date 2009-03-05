loadDialog = {}
local open
local mainRes = getResourceFromName"editor_main"

function createLoadDialog()
	loadDialog.window	=	guiCreateWindow ( screenX/2 - 320, screenY/2 - 180, 640, 360, "OPEN...", false )
	loadDialog.mapsList = guiCreateGridList ( 0.02, 0.08, 0.98, 0.75, true, loadDialog.window )
	loadDialog.open = guiCreateButton ( 0.780357142, 0.85388845, 0.22857142, 0.05555555, "Open", true, loadDialog.window )
	loadDialog.cancel = guiCreateButton ( 0.780357142, 0.919444, 0.22857142, 0.05555555, "Cancel", true, loadDialog.window )
	loadDialog.mapName = guiCreateEdit ( 0.02, 0.87388845, 0.75, 0.08, "", true, loadDialog.window )
	guiWindowSetSizable ( loadDialog.window, false )
	guiEditSetReadOnly ( loadDialog.mapName, true )
	--
	guiGridListAddColumn ( loadDialog.mapsList, "Name", 0.4 )
	guiGridListAddColumn ( loadDialog.mapsList, "Gamemodes", 0.4 )
	guiGridListAddColumn ( loadDialog.mapsList, "Version", 0.13 )
	guiGridListSetSelectionMode ( loadDialog.mapsList, 0 )
	guiSetVisible ( loadDialog.window, false )
	addEventHandler ( "onClientGUIClick", loadDialog.cancel, closeLoadDialog, false )
	addEventHandler ( "onClientGUIClick", loadDialog.open, openMap, false )
	addEventHandler ( "onClientGUIDoubleClick", loadDialog.mapsList, openMap, false )
	addEventHandler ( "onClientGUIClick", loadDialog.mapsList, setEditBoxMapName, false )
end

function closeLoadDialog()
	guiSetVisible ( loadDialog.window, false )
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
end

function openMap()
	local row = guiGridListGetSelectedItem ( loadDialog.mapsList )
	if row == -1 then return end
	mapName = guiGridListGetItemText ( loadDialog.mapsList, row, 1 )
	open = guiShowMessageBox ( "Are you sure you want to load map \""..mapName.."\"?\nAny unsaved changes will be lost.", "info", "Are you sure?", true, "Open", "Cancel" )
	addEventHandler ( "onClientGUIClick", open, openButton, false )
end

function openButton ()
	local resourceName = guiGetText ( loadDialog.mapName )
	editor_main.openResource ( resourceName )
end

addEvent ( "openShowDialog",true )
function openShowDialog( resources )
	setGUIShowing(false)
	guiSetInputEnabled ( true )
	setWorldClickEnabled ( false )
	guiSetText ( loadDialog.mapName, "" )
	guiGridListClear ( loadDialog.mapsList )
	for i,res in ipairs(resources) do
		if res["type"] == "map" then
			local row = guiGridListAddRow ( loadDialog.mapsList )
			guiGridListSetItemText ( loadDialog.mapsList, row, 1, res["friendlyName"], false, false )
			guiGridListSetItemText ( loadDialog.mapsList, row, 2, res["gamemodes"], false, false )
			guiGridListSetItemText ( loadDialog.mapsList, row, 3, res["version"], false, false )
		end
	end
	guiSetVisible ( loadDialog.window, true )
end
addEventHandler ( "openShowDialog", getRootElement(), openShowDialog )

function setEditBoxMapName()
	local row = guiGridListGetSelectedItem ( loadDialog.mapsList )
	if row == -1 then
		guiSetText ( loadDialog.mapName, "" )
	else
		mapName = guiGridListGetItemText ( loadDialog.mapsList, row, 1 )
		guiSetText ( loadDialog.mapName, mapName ) 
	end
end
