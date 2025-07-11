local locations = {}
local interiorsTable, bookmarksTable
local bookmarksXML
--functions
local addToGridlist,addBookmark,removeBookmark,listClick,listDoubleClick,getLocationsTable
local dumpPosition,bestInterior,pestInterior,setLocation,getLocation,close

function createLocationsMenu()
	locations.window = guiCreateWindow ( screenX/2 - 320, screenY/2 - 180, 640, 360, "LOCATIONS", false )
	guiSetVisible ( locations.window, false )
	locationsWindow = locations.window
	guiWindowSetSizable ( dialog.window, false )
	local tabpanel = guiCreateTabPanel ( 0.02388, 0.09444, 0.36, 0.81389, true, locations.window )
	locations.presetTab = guiCreateTab("Preset",tabpanel)
	locations.bookmarksTab = guiCreateTab("Bookmarks",tabpanel)
	locations.close = guiCreateButton ( 0.780357142, 0.919444, 0.22857142, 0.05555555, "Close", true, locations.window )
	--
	locations.plist = guiCreateGridList ( 0.02, 0.02, 0.96, 0.96, true, locations.presetTab )
	guiGridListAddColumn ( locations.plist, "Location names", 0.85 )

	guiCreateLabel ( 276, 85, 70, 17, "name:", false, locations.window )
	locations.name = guiCreateEdit ( 353, 75, 245, 30, "", false, locations.window )

	guiCreateLabel ( 276, 140, 70, 17, "x position:", false, locations.window )
	guiCreateLabel ( 276, 170, 70, 17, "y position:", false, locations.window )
	guiCreateLabel ( 276, 200, 70, 17, "z position:", false, locations.window )
	locations.x = editingControl.number:create{["x"]=353,["y"]=129,["width"]=245,["height"]=30,["relative"]=false,["maxLength"]=30,["parent"]=locations.window }
	locations.y = editingControl.number:create{["x"]=353,["y"]=159,["width"]=245,["height"]=30,["relative"]=false,["maxLength"]=30,["parent"]=locations.window }
	locations.z = editingControl.number:create{["x"]=353,["y"]=189,["width"]=245,["height"]=30,["relative"]=false,["maxLength"]=30,["parent"]=locations.window }
	guiCreateLabel ( 276, 246, 85, 17, "interior world:", false, locations.window )

	locations.world = editingControl.natural:create{["x"]=386,["y"]=237,["width"]=61,["height"]=30,["relative"]=false,["parent"]=locations.window }
	locations.go = guiCreateButton ( 352, 290, 122, 26, "Go!", false, locations.window )
	locations.dump = guiCreateButton ( 457, 237, 142, 30, "Dump current position", false, locations.window )
	-------------------------------------------------------
	locations.blist = guiCreateGridList ( 0.02, 0.02, 0.96, 0.85, true, locations.bookmarksTab )
	guiGridListAddColumn ( locations.blist, "Location names", 0.85 )
	locations.badd = guiCreateButton ( 0.02, 0.87, 0.47, 0.12, "Add", true, locations.bookmarksTab )
	locations.brem = guiCreateButton ( 0.49, 0.87, 0.47, 0.12, "Remove", true, locations.bookmarksTab )

	---
	addEventHandler ( "onClientGUIClick", locations.badd, addBookmark, false )
	addEventHandler ( "onClientGUIClick", locations.brem, removeBookmark, false )
	addEventHandler ( "onClientGUIClick", locations.blist, listClick,false )
	addEventHandler ( "onClientGUIClick", locations.plist, listClick,false )
	addEventHandler ( "onClientGUIDoubleClick", locations.blist, listDoubleClick,false )
	addEventHandler ( "onClientGUIDoubleClick", locations.plist, listDoubleClick,false )
	addEventHandler ( "onClientGUIClick", locations.go, setInterior,false )
	addEventHandler ( "onClientGUIClick", locations.dump, dumpPosition,false )
	addEventHandler ( "onClientGUIClick", locations.close, close,false )
	---
	--adding stuff
	local interiorsXML = getResourceConfig ( "client/presets.xml" )
	interiorsTable = getLocationsTable ( interiorsXML, "location" )
	local newTable = {}
	for k,v in orderedPairs(interiorsTable) do
		table.insert ( newTable, k )
	end
	addToGridlist ( locations.plist, newTable )
	--
	if bookmarksXML then
		xmlUnloadFile ( bookmarksXML )
	end
	bookmarksXML = xmlLoadFile ( "bookmarks.xml" )
	if not bookmarksXML then
		bookmarksXML = xmlCreateFile ( "bookmarks.xml","bookmarks")
		local newNode = xmlCreateChild ( bookmarksXML, "location" )
		xmlNodeSetAttribute ( newNode, "id", "Grove Street" )
		xmlNodeSetAttribute ( newNode, "posX", 2483 )
		xmlNodeSetAttribute ( newNode, "posY", -1666 )
		xmlNodeSetAttribute ( newNode, "posZ", 21 )
		xmlNodeSetAttribute ( newNode, "world", 0 )
	end
	bookmarksTable = getLocationsTable ( bookmarksXML, "location" )

	newTable = {}
	for k,v in orderedPairs(bookmarksTable) do
		table.insert ( newTable, k )
	end
	addToGridlist ( locations.blist, newTable )
end

local speed = 3 --how many to do
local addTime = 50 --how often to do it
function addToGridlist ( gridlist, table, key )
	if not key then key = 1 end
	if ( table[key] ) then
		local row = guiGridListAddRow ( gridlist )
		guiGridListSetItemText ( gridlist, row, 1, table[key], false, false )
		if math.mod ( key, speed ) == 0 then
			setTimer ( addToGridlist, addTime, 1, gridlist, table, key + 1 )
		else
			addToGridlist ( gridlist, table, key + 1 )
		end
	end
end

function addBookmark ()
	local name = guiGetText ( locations.name )
	local x = locations.x:getValue()
	local y = locations.y:getValue()
	local z = locations.z:getValue()
	local world = locations.world:getValue()
	if name == "" then
		exports.dialogs:messageBox("Bad value", "No location name was specified!", false, "ERROR", "OK")
		return
	end
	if bookmarksTable[name] then
		exports.dialogs:messageBox("Bad value", "A location of name \"" .. name .."\" already exists!", false, "ERROR", "OK")
		return
	end
	bookmarksTable[name] = {}
	bookmarksTable[name].posX = x
	bookmarksTable[name].posY = y
	bookmarksTable[name].posZ = z
	bookmarksTable[name].interior = world
	local newNode = xmlCreateChild ( bookmarksXML, "location" )
	xmlNodeSetAttribute ( newNode, "id", name )
	xmlNodeSetAttribute ( newNode, "posX", x )
	xmlNodeSetAttribute ( newNode, "posY", y )
	xmlNodeSetAttribute ( newNode, "posZ", z )
	xmlNodeSetAttribute ( newNode, "world", world )
	bookmarksTable[name].node = newNode
	local row = guiGridListAddRow ( locations.blist )
	guiGridListSetItemText ( locations.blist, row, 1, name, false, false )
end

function removeBookmark ()
	local row = guiGridListGetSelectedItem ( locations.blist )
	local name = guiGridListGetItemText ( locations.blist, row, 1 )
	if not bookmarksTable[name] then return end
	xmlDestroyNode ( bookmarksTable[name].node )
	bookmarksTable[name] = nil
	guiGridListRemoveRow ( locations.blist, row )
end

function listClick()
	local row = guiGridListGetSelectedItem ( source )
	if row == -1 then return end
	local id = guiGridListGetItemText ( source, row, 1 )
	local info = interiorsTable[id] or bookmarksTable[id]
	guiSetText ( locations.name, id )
	locations.x:setValue(info.posX)
	locations.y:setValue(info.posY)
	locations.z:setValue(info.posZ)
	locations.world:setValue(info.interior)
end

function listDoubleClick()
	local row = guiGridListGetSelectedItem ( source )
	if row == -1 then return end
	setInterior()
end

function getLocationsTable ( interiorsXML, nodeName )
	local xmlInteriorID = 0
	local interiors = {}
	while xmlFindChild ( interiorsXML, nodeName, xmlInteriorID ) ~= false do
		local node = xmlFindChild ( interiorsXML, nodeName, xmlInteriorID )
		local id = xmlNodeGetAttribute ( node, "id" )
		interiors[id] = {}
		interiors[id]["posX"] = xmlNodeGetAttribute ( node, "posX" )
		interiors[id]["posY"] = xmlNodeGetAttribute ( node, "posY" )
		interiors[id]["posZ"] = xmlNodeGetAttribute ( node, "posZ" )
		interiors[id]["interior"] = xmlNodeGetAttribute ( node, "world" )
		interiors[id]["node"] = node
		xmlInteriorID = xmlInteriorID + 1
	end
	return interiors
end

function dumpPosition()
	local x,y,z,world = getLocation()
	locations.x:setValue(x)
	locations.y:setValue(y)
	locations.z:setValue(z)
	locations.world:setValue(world)
	-- Whatever bname is it was never implemented
	-- local name = guiGetText(locations.bname)
	-- if bookmarksTable[name] or interiorsTable[name] then
		-- guiSetText ( locations.bname, "" )
	-- end
end

function setInterior()
	local x = tonumber(locations.x:getValue())
	local y = tonumber(locations.y:getValue())
	local z = tonumber(locations.z:getValue())
	local world = tonumber(locations.world:getValue())
	setLocation ( x,y,z,world )
end

function setLocation ( x,y,z,world )
	if not x then
		exports.dialogs:messageBox("Bad value", "Invalid \"x position\" specified", false, "ERROR", "OK")
		return
	end
	if not y then
		exports.dialogs:messageBox("Bad value", "Invalid \"y position\" specified", false, "ERROR", "OK")
		return
	end
	if not z then
		exports.dialogs:messageBox("Bad value", "Invalid \"z position\" specified", false, "ERROR", "OK")
		return
	end
	if not world then
		locations.world:setValue(0)
		world = 0
	end
	local camX,camY,camZ,cameraLookX,cameraLookY,cameraLookZ = getCameraMatrix()
	--we move backwards from the camera angle, invert the vector
	local vectorX = cameraLookX - camX
	local vectorY = cameraLookY - camY
	local vectorZ = cameraLookZ - camZ
	-- calculate a camera position based on the current position and an offset based on the new vector
	local lookX = x + vectorX
	local lookY = y + vectorY
	local lookZ = z + vectorZ

	editor_main.setWorkingInterior (world)
	return setCameraMatrix ( x,y,z, lookX, lookY, lookZ )
end

function getLocation()
	local x,y,z = getCameraMatrix()
	local world = editor_main.getWorkingInterior()
	return x,y,z,world
end

function close()
	guiSetInputEnabled ( false )
	guiSetVisible ( locations.window, false )
	xmlSaveFile ( bookmarksXML )
end
