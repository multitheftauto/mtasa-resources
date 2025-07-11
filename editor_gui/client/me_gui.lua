enableSound = true --this enables or disables sound.  For the options menu
isCurrentButtonElement = false --this checks whether the currently highlighted button is an element icon, so EDF info can appear.
currentSelectedResource = false --this defines the currently selected resource
local wasCurrentBrowserShowing = false
local bar = {}
--These tables define the buttons that go on the top.  the names match their filename.
menuButtons = { { ["name"]="new" },{ ["name"]="open" },{ ["name"]="save" },{ ["name"]="save as" },{ ["name"]="options" },{ ["name"]="undo" },{ ["name"]="redo" }, { ["name"]="locations" }--[[,{ ["name"]="clipboard" },{ ["name"]="exit" } ]]}
secondMenuButtons = { { ["name"]="current elements" },{ ["name"]="map settings" },{["name"]="definitions"}, { ["name"]="test" } }

resourceElementDefinitions = {} --This table stores all edf definitions of every element type accroding to resource.
iconData = {} --iconData allows differentiation between different icon types, and stores the function for each icon.
elementIcons = {} --these are the icons that go along the bottom

local iconPath = "client/images/"
local defaultElementDefinition = "editor_main"
screenX, screenY = guiGetScreenSize() --this gets the local screen size to work out gui
guiConfig = {
	iconSize = 48, --this is the default icon size (width and height)
	topMenuAlign = "center",
	elementIconsAlign = "left"
}
local guiShowing = true --this is a variable used to detect if gui is hidden or shown.
local currentHUDAlpha
local requireBinds

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function startGUI(resource)
	outputConsole("GUI load time measures (ms):")
	TIME = getTickCount()
	createWorldDetector()
	---Create the other menus before creating the layout
	outputConsole("createWorldDetector() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createCurrentBrowser()
	outputConsole("createCurrentBrowser() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createOptionsDialog()
	outputConsole("createOptionsDialog() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createLocationsMenu()
	outputConsole("createLocationsMenu() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createBrowser()
	outputConsole("createBrowser() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createMapSettings()
	outputConsole("createMapSettings() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createDefinitionsDialog()
	outputConsole("createDefinitionsDialog() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createLoadDialog()
	outputConsole("createLoadDialog() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createSaveDialog()
	outputConsole("createSaveDialog() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	--create all the icons
	createGUILayout()
	outputConsole("createGUILayout() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createTestDialog()
	outputConsole("createTestDialog() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	createPropertiesBox()
	outputConsole("createPropertiesBox() : "..tostring(getTickCount()-TIME)); TIME = getTickCount()
	isGUICreated = true
	triggerServerEvent ( "onClientGUILoaded", localPlayer )
	welcomeUser()
	setHUDAlpha(0.2)
end
addEventHandler("onClientResourceStart",resourceRoot, startGUI )

function scrollEDF(key,keyState)
	if isCurrentButtonElement == false then return end
	if key == "edf_prev" then prevEDF()
	elseif key == "edf_next" then nextEDF()
	end
end

--these funcs are server side, so i port them to client in me_gui_server and these funcs
addEvent ( "doLoadEDF",true )
addEvent ( "doUnloadEDF",true )

function onEDFResourceStart(resource)
	if resourceElementDefinitions[getResourceName(resource)] then
		refreshElementIcons()
	end
end
addEventHandler ( "onClientResourceStart", root, onEDFResourceStart )

function createElementIcons ( tableEDF, resource )
	--store all our data neatly under the resource
	local defTable = clearNonCreatableElements ( tableEDF["elements"] )
	if table.size(defTable) > 0 then
		resourceElementDefinitions[resource] = defTable
		refreshElementIcons()
	end
end
addEventHandler ( "doLoadEDF", root, createElementIcons )


-----------------------------------------------
function destroyElementIcons ( resource )
	resourceElementDefinitions[resource] = nil
	if resource == currentSelectedResource then
		nextEDF()
	end
	refreshElementIcons()
end
addEventHandler ( "doUnloadEDF", root, destroyElementIcons )

edfResourcesNext = {}

function refreshElementIcons()
	currentBrowser.update()
	currentBrowserGUI.dropdown:setValue(1)
	for icon, Table in pairs(elementIcons) do --remove any old icons
		guiSetVisible ( icon, false )
		--destroyElement ( Table["button"] )
		destroyElement ( icon )
		elementIcons[icon] = nil
		iconData[icon] = nil
	end
	--
	edfResourcesNext = {}
	elementIcons = {}
	local nameTable = {} --this is used to ensure any elements with the same name have a varied label
	for resource,tableElements in pairs(resourceElementDefinitions) do
		if currentSelectedResource == false then
			currentSelectedResource = resource
			if ( currentSelectedResource == defaultElementDefinition ) then
				setSelectedResourceText ( "DEFAULT" )
			else
				setSelectedResourceText ( string.upper(currentSelectedResource) )
			end
		end
		local tableSize = #edfResourcesNext
		if ( not tableSize ) then tableSize = 0 end
		nextKey = tableSize + 1
		--make this table into an array so its sorted nicely
		edfResourcesNext[resource] = {}
		--
		--work out the offset for positioning
		local menuButtonsOffset
		if guiConfig.elementIconsAlign == "right" or guiConfig.elementIconsAlign == "center" then
			--count the number of elements
			local totalElements = 0
			for k,v in pairs(tableElements) do
				totalElements = totalElements + 1
			end
			if guiConfig.elementIconsAlign == "right" then
				menuButtonsOffset = screenX - (guiConfig.iconSize * totalElements)
			else
				menuButtonsOffset = ( screenX - (guiConfig.iconSize * totalElements))/2 --this works out where to start creating the top menu's gui, so it's centred.
			end
		else
			menuButtonsOffset = 0
		end
		local k = 0
		local sortingFunction = function(A, B)
			return tableElements[A]["friendlyname"] < tableElements[B]["friendlyname"]
		end
		for elementName,dataTable in orderedPairs(tableElements, sortingFunction) do
			--edf will have to pass a image straight to me_gui. therefore this check to see if an icon is false will have to make a generic icon rather than dir.
			local iconDir = dataTable["icon"]
			local friendlyName = dataTable["friendlyname"]
			if friendlyName == nil then friendlyName = elementName end
			local theIcon
			local posX = ((k)*guiConfig.iconSize) + menuButtonsOffset
			if not iconDir then --if edf never passed an icon
				--create a generic one
				theIcon = guiCreateStaticImage ( posX, screenY - guiConfig.iconSize, guiConfig.iconSize, guiConfig.iconSize, iconPath.."elementmenu/generic.png", false) --, getResourceFromName(key))
			else
				--otherwise create edf's icon
				if (getResourceFromName(resource)) then -- To prevent debug when trying to load from a not yet started resource
					theIcon = guiCreateStaticImage ( posX, screenY - guiConfig.iconSize, guiConfig.iconSize, guiConfig.iconSize, ":"..resource.."/"..iconDir, false)
				end
			end
			if not theIcon then
				--if edf's icon was not made successfully, then create a generic one.
				theIcon = guiCreateStaticImage ( posX, screenY - guiConfig.iconSize, guiConfig.iconSize, guiConfig.iconSize, iconPath.."elementmenu/generic.png", false)
			end
			addEventHandler ( "onClientGUIMouseDown", theIcon, buttonClicked, false )

			--store the icon type, and the function action of the button
			iconData[theIcon] = {}
			iconData[theIcon]["type"] = "elementIcons"
			iconData[theIcon]["clicked"] = elementIcons_Clicked
			iconData[theIcon]["mouseOver"] = elementIconsMouseOver

			--store this under the element icons table
			elementIcons[theIcon] = {}
			elementIcons[theIcon]["name"] = friendlyName
			elementIcons[theIcon]["elementName"] = elementName
			elementIcons[theIcon]["resource"] = resource


			--check if any other elements used the name
			if nameTable[elementName] ~= nil then
				--since we found another element with the same name, set the old name to element [resource]
				local oldIcon = nameTable[elementName]["icon"]
				local oldFriendlyName = nameTable[elementName]["friendlyName"]
				local oldResource = nameTable[elementName]["resource"]
				elementIcons[oldIcon]["labelName"] = oldFriendlyName.." ["..oldResource.."]"
				--set the current one with name [resource] too.
				elementIcons[theIcon]["labelName"] = friendlyName.." ["..resource.."]"
			end

			nameTable[elementName] = {}
			nameTable[elementName]["resource"] = resource
			nameTable[elementName]["friendlyName"] = friendlyName
			nameTable[elementName]["icon"] = theIcon

			table.insert ( edfResourcesNext[resource], theIcon )
			--hide any non selected icons
			if ( resource ~= currentSelectedResource ) or ( not guiShowing ) then
				guiSetVisible ( theIcon, false )
			end
			k = k + 1
		end
	end
	--we move the selected highlighter to the front, so that it appears above the new GUI
	if ( selected ) then
		guiMoveToBack ( selected )
		guiSetVisible ( selected, false )
	end
	setHUDAlpha(currentHUDAlpha)
	if getElementData ( localPlayer, "waitingToStart" ) then
		setGUIShowing(false)
	end
end

function createGUILayout()
	---create all of our top menu
	local gap = guiConfig.iconSize/2 --this calculates the gap in between the topMenu and the secondTopMenu
	local menuButtonsOffset
	if guiConfig.topMenuAlign == "left" then
		menuButtonsOffset = 0
	elseif guiConfig.topMenuAlign == "right" then
		menuButtonsOffset = screenX - ((guiConfig.iconSize * #menuButtons) + gap + (guiConfig.iconSize * #secondMenuButtons))
	else
		menuButtonsOffset = ( screenX - ( (guiConfig.iconSize * #menuButtons) + gap + (guiConfig.iconSize * #secondMenuButtons) ) )/2 --this works out where to start creating the top menu's gui, so it's centred.
	end

	local x
	for k,v in pairs(menuButtons) do --centre our top menu buttons
		local name = v["name"]
		x = ((k-1)*guiConfig.iconSize) + menuButtonsOffset
		local pathName = string.gsub(name, " ", "_" )
		v["icon"] = guiCreateStaticImage ( x, 0, guiConfig.iconSize, guiConfig.iconSize, iconPath.."topmenu/"..pathName..".png", false )

		iconData[v["icon"]] = {}
		iconData[v["icon"]]["type"] = "menuButtons"
		iconData[v["icon"]]["name"] = name --for highlighting.lua
		iconData[v["icon"]]["clicked"] = topMenuClicked[name]
		iconData[v["icon"]]["mouseOver"] = topMenuMouseOver

		addEventHandler ( "onClientGUIMouseDown", v["icon"], buttonClicked, false )
	end
	for k,v in pairs(secondMenuButtons) do --centre our top menu buttons
		local name = v["name"]
		local pathName = string.gsub(name, " ", "_" )
		v["icon"] = guiCreateStaticImage ( ((k-1)*guiConfig.iconSize) + x + guiConfig.iconSize + gap, 0, guiConfig.iconSize, guiConfig.iconSize, iconPath.."topmenu/second/"..pathName..".png", false )
		iconData[v["icon"]] = {}
		iconData[v["icon"]]["type"] = "secondMenuButtons"
		iconData[v["icon"]]["name"] = name --for highlighting.lua
		iconData[v["icon"]]["clicked"] = topMenuClicked[name]
		iconData[v["icon"]]["mouseOver"] = topMenuMouseOver

		addEventHandler ( "onClientGUIMouseDown", v["icon"], buttonClicked, false )
	end

	--create our highlighters
	selected = guiCreateStaticImage ( 0, 0, guiConfig.iconSize, guiConfig.iconSize, iconPath.."select.png", false )
	selectedShadow =  guiCreateLabel ( 0, 0, screenX, 16, "", false )
	selectedText =  guiCreateLabel ( 0, 0, screenX, 16, "", false )

	local resourceX = ( 5/960 * screenX )
	local resourceY = ( screenY - 85 )
	selectedResourceShadow =  guiCreateLabel ( resourceX, resourceY, screenX, 16, "", false )
	selectedResourceText =  guiCreateLabel ( resourceX + 1, resourceY + 1, screenX, 16, "", false )

	guiLabelSetColor ( selectedResourceText, 200, 25, 25 )
	guiLabelSetColor ( selectedText, 255, 255, 255 )
	guiLabelSetColor ( selectedResourceShadow, 0, 0, 0 )
	guiLabelSetColor ( selectedShadow, 0, 0, 0 )

	guiSetVisible ( selected, false )
	setHUDAlpha(currentHUDAlpha)
	if getElementData ( localPlayer, "waitingToStart" ) then
		setGUIShowing(false)
	end
end

function toggleHUDShowing(k1,k2,state)
	setGUIShowing(not guiShowing)
	setPlayerHudComponentVisible("radar", guiShowing)
	showChat ( guiShowing )
end

function setGUIShowing(state)
	for icon,data in pairs(iconData) do
		if data.type == "elementIcons" and state then
			if elementIcons[icon]["resource"] == currentSelectedResource then
				guiSetVisible ( icon,true )
			end
		else
			guiSetVisible ( icon, state )
		end
	end
	currentButton = false
	if state == false then
		guiSetVisible ( selected, false )
		setSelectedText ( 0.5, 0.5, "" )
		if guiGetVisible(currentBrowserGUI.browser) then
			wasCurrentBrowserShowing = true
		else wasCurrentBrowserShowing = false end
		closeCurrentBrowser()
	else
		if wasCurrentBrowserShowing then
			showCurrentBrowser ( false,false,false,false,false,true )
		end
	end
	guiSetVisible(selectedResourceText, state )
	guiSetVisible(selectedResourceShadow, state )
	guiShowing = state
	isCurrentButtonElement = false
end

function setHUDAlpha(level)
	if not level then return false end
	local isFalse
	for icon,data in pairs(iconData) do
		returnValue = guiSetAlpha ( icon, level )
		if not returnValue then isFalse = true end
	end
	guiSetAlpha ( selected, level )
	guiSetAlpha(selectedResourceText, level )
	guiSetAlpha(selectedResourceShadow, level )
	currentHUDAlpha = level
	return not isFalse
end

addEvent "onFreecamMode"
addEvent "onCursorMode"

addEventHandler ( "onFreecamMode", root, function() setHUDAlpha(0.2) hideHighlighter() end )
addEventHandler ( "onCursorMode", root, function() setHUDAlpha(1) end )

function destroyAllIconGUI()
	for icon,data in pairs(iconData) do
		guiSetVisible ( icon, false )
		destroyElement ( icon )
	end
	currentButton = false
	guiSetVisible ( selected, false )
	destroyElement ( selected )
	setSelectedText ( 0.5, 0.5, "" )
	destroyElement ( selectedText )
	destroyElement ( selectedShadow )
	guiSetVisible(selectedResourceText, false )
	guiSetVisible(selectedResourceShadow, false )
	destroyElement ( selectedResourceText )
	destroyElement ( selectedResourceShadow )
	iconData = {}
	elementIcons = {}
	isCurrentButtonElement = false
	currentSelectedResource = false
end

local mta_playSoundFrontEnd = playSoundFrontEnd
function playSoundFrontEnd ( sound )
	if enableSound == false then return false end
	returnValue  = mta_playSoundFrontEnd ( sound )
	return returnValue
end

function clearNonCreatableElements(elementTable)
	for elementName,data in pairs(elementTable) do
		if not data.createable then
			elementTable[elementName] = nil
		end
	end
	return elementTable
end

---This is for scrolling through EDF elements
function nextEDF ()
	for key, icons in pairs(edfResourcesNext[currentSelectedResource]) do
		guiSetVisible ( icons, false )
	end
	newKey = next ( edfResourcesNext, currentSelectedResource )
	if newKey == nil then
		for key,value in pairs(edfResourcesNext) do
			newKey = key
			break
		end
	end
	for key, icons in pairs(edfResourcesNext[newKey]) do
		guiSetVisible ( icons, true )
	end
	currentSelectedResource = newKey
	if ( currentSelectedResource == defaultElementDefinition ) then
		setSelectedResourceText ( "DEFAULT" )
	else
		setSelectedResourceText ( string.upper(currentSelectedResource) )
	end
end

function prevEDF ()
	for key, icons in pairs(edfResourcesNext[currentSelectedResource]) do
		guiSetVisible ( icons, false )
	end
	--we have to loop through to find the previous one
	local progress = 0
	local newKey
	for key, value in pairs(edfResourcesNext) do
		if ( key == currentSelectedResource ) then
			break
		end
		progress = progress + 1
	end
	if ( progress == 0 ) then
		for key,value in pairs(edfResourcesNext) do
			newKey = key
		end
	else
		local progressCheck = 1
		for key,value in pairs(edfResourcesNext) do
			if progressCheck == progress then
				newKey = key
				break
			end
			progressCheck = progressCheck + 1
		end
	end
	for key, icons in pairs(edfResourcesNext[newKey]) do
		guiSetVisible ( icons, true )
	end
	currentSelectedResource = newKey
	if ( currentSelectedResource == defaultElementDefinition ) then
		setSelectedResourceText ( "DEFAULT" )
	else
		setSelectedResourceText ( string.upper(currentSelectedResource) )
	end
end

--This allows quick resizing of gui labels
function resetLabelCanvasSize ( label )
	local extent = guiLabelGetTextExtent ( label )
	local height = guiLabelGetFontHeight ( label )
	guiSetSize ( label, extent,16,false )
	return true
end

function guiCreateMinimalLabel(x,y,width,height,text,relative,parent)
	--Syntax 1 (allows for width and height)
	if ( relative ) then
		local label = guiCreateLabel(x,y,width,height,text,relative,parent)
		resetLabelCanvasSize ( label )
		return label
	else
	--Syntax 2 (x,y,text,relative,parent)
		local label = guiCreateLabel(x,y,screenX,screenY,width,height,text)
		resetLabelCanvasSize ( label )
		return label
	end
end

--Stops gui input being enabled when the resource stops
addEventHandler ( "onClientResourceStop", resourceRoot,
	function()
		guiSetInputEnabled(false)
	end
)
