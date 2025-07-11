definitionsDialog = {}
local allEDF = {}


function createDefinitionsDialog()
	definitionsDialog.window		=	guiCreateWindow ( screenX/2 - 300, screenY/2 - 150, 600, 300, "DEFINITIONS", false )
	guiSetVisible ( definitionsDialog.window, false )
	--create the Element Definitions tab
	definitionsDialog.availEDF = guiCreateGridList ( 0.02, 0.08, 0.3, 0.80, true, definitionsDialog.window )
	definitionsDialog.addedEDF = guiCreateGridList ( 0.68, 0.08, 0.3, 0.80, true, definitionsDialog.window )
	guiGridListAddColumn ( definitionsDialog.availEDF, "Available definitions", 0.8 )
	guiGridListAddColumn ( definitionsDialog.addedEDF, "Added definitions", 0.8 )
	definitionsDialog.edfAdd = guiCreateButton ( 0.4, 0.3, 0.2, 0.1, "Add", true, definitionsDialog.window )
	definitionsDialog.edfRemove = guiCreateButton ( 0.4, 0.6, 0.2, 0.1, "Remove", true, definitionsDialog.window )
	definitionsDialog.ok = guiCreateButton ( 0.5, 0.89, 0.22857142, 0.062, "OK", true, definitionsDialog.window )
	definitionsDialog.cancel = guiCreateButton ( 0.780357142, 0.89, 0.22857142, 0.062, "Cancel", true, definitionsDialog.window )
	guiWindowSetSizable ( definitionsDialog.window, false )
	--
	addEventHandler ( "onClientGUIClick", definitionsDialog.edfAdd, edfAddDefs,false )
	addEventHandler ( "onClientGUIDoubleClick", definitionsDialog.availEDF, edfAddDefs,false )
	addEventHandler ( "onClientGUIClick", definitionsDialog.edfRemove, edfRemoveDefs,false )
	addEventHandler ( "onClientGUIDoubleClick", definitionsDialog.addedEDF, edfRemoveDefs,false )
	--
	addEventHandler ( "onClientGUIClick", definitionsDialog.cancel, cancelDefinitions,false )
	addEventHandler ( "onClientGUIClick", definitionsDialog.ok, confirmDefinitions,false )
end

function edfAddDefs ()
	local row = guiGridListGetSelectedItem ( definitionsDialog.availEDF )
	local text = guiGridListGetItemText ( definitionsDialog.availEDF, row, 1 )
	if text == "" then return end
	guiGridListRemoveRow ( definitionsDialog.availEDF,row )
	local newRow = guiGridListAddRow ( definitionsDialog.addedEDF )
	guiGridListSetItemText ( definitionsDialog.addedEDF, newRow, 1, text, false, false )
end

function edfRemoveDefs ()
	local row = guiGridListGetSelectedItem ( definitionsDialog.addedEDF )
	local text = guiGridListGetItemText ( definitionsDialog.addedEDF, row, 1 )
	if text == "" then return end
	guiGridListRemoveRow ( definitionsDialog.addedEDF,row )
	local newRow = guiGridListAddRow ( definitionsDialog.availEDF )
	guiGridListSetItemText ( definitionsDialog.availEDF, newRow, 1, text, false, false )
end


function cancelDefinitions ()
	guiSetVisible ( definitionsDialog.window, false )
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
end


function confirmDefinitions ()
	dumpEDF("availEDF")
	--setEDF("availEDF")
	--
	dumpEDF("addedEDF")
	--setEDF("addedEDF")
	triggerServerEvent ( "reloadEDFDefinitions", localPlayer, allEDF )
	setGUIShowing(true)
	guiSetInputEnabled ( false )
	setWorldClickEnabled ( true )
	guiSetVisible ( definitionsDialog.window, false )
end

function dumpEDF(gui)
	local totalRows = guiGridListGetRowCount(definitionsDialog[gui])
	local row = 0
	local items = {}
	while row ~= totalRows do
		local text = guiGridListGetItemText ( definitionsDialog[gui], row, 1 )
		if text ~= "" then
			table.insert ( items, text )
		end
		row = row + 1
	end
	allEDF[gui] = items
end

---set functions
function setEDF(gui)
	guiGridListClear ( definitionsDialog[gui] )
	for k,v in ipairs(allEDF[gui]) do
		local row = guiGridListAddRow ( definitionsDialog[gui] )
		guiGridListSetItemText ( definitionsDialog[gui], row, 1, v, false, false )
	end
end

addEvent ("syncEDFDefinitions",true)
addEventHandler ( "syncEDFDefinitions", root,
function ( newEDF )
	allEDF = newEDF
	setEDF("availEDF")
	setEDF("addedEDF")
end
)


