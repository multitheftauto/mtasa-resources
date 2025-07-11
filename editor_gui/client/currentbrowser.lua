currentBrowserGUI = {}
currentBrowser = {}
local cSelectedElement,workingDimension,hiddenDimension
local width = 0.25
local height = 1
local dimensionElement
local callbackFunction
local ignoredTable = {}

--Stoled from jbeta
local setElementDimension = setElementDimension
do
	local mta_setElementDimension = setElementDimension

	function setElementDimension ( element, dimension )
		mta_setElementDimension ( element, dimension )
		if getElementChildrenCount( element ) > 0 then
			for k, child in ipairs( getElementChildren( element ) ) do
				setElementDimension( child, dimension )
			end
		end
	end
end

function createCurrentBrowser ()
	workingDimension = editor_main.getWorkingDimension()
	hiddenDimension = workingDimension + 2 --If the checkbox is checked, dimension setting

	local windowWidth = screenX*width
	local windowHeight = screenY*height
	currentBrowserGUI.browser = guiCreateWindow 	( 1 - width, 0, width, height, "Current Elements...", true )
	currentBrowserGUI.gridlist = browserList:create(12, 85, windowWidth, windowHeight-128,{{["Name [ID]"]=0.85}},false, currentBrowserGUI.browser )
	currentBrowserGUI.search = guiCreateEdit ( 12, 50, windowWidth, 30, "Search...", false, currentBrowserGUI.browser )
	currentBrowserGUI.dropdown = editingControl.dropdown:create{["x"]=12,["y"]=25,["width"]=windowWidth,["height"]=20,["dropWidth"]=windowWidth,["dropHeight"]=200,["relative"]=false,["parent"]=currentBrowserGUI.browser,["rows"]={""}}
	--linked to options
	dialog.autosnap = editingControl.boolean:create{["x"]=12,["y"]=windowHeight-48,["width"]=windowWidth/2,["height"]=30,["relative"]=false,["parent"]=currentBrowserGUI.browser,["label"]="Autosnap camera"}
    currentBrowserGUI.isolate = guiCreateCheckBox ( 12, windowHeight-24, windowWidth/2, 30, "Isolate element", false, false, currentBrowserGUI.browser )
	currentBrowserGUI.restore = guiCreateButton ( windowWidth/4 * 2-10, windowHeight-40, windowWidth/4, 40, "Restore", false, currentBrowserGUI.browser )
    currentBrowserGUI.close = guiCreateButton ( windowWidth/4 * 3, windowHeight-40, windowWidth/4, 40, "Close", false, currentBrowserGUI.browser )
	guiSetProperty(currentBrowserGUI.browser,"RelativeMinSize","w:0.250000 h:0.400000")
	--
	guiSetAlpha ( currentBrowserGUI.browser, 50 )
	if isElement ( currentBrowserGUI.gridlist ) then
		guiSetAlpha ( currentBrowserGUI.gridlist, 50 )
	end
	guiSetAlpha ( currentBrowserGUI.search, 50 )
	if isElement ( currentBrowserGUI.dropdown ) then
		guiSetAlpha ( currentBrowserGUI.dropdown, 50 )
	end
	--
	guiSetVisible ( currentBrowserGUI.browser, false )
	currentBrowser.update()
	addEventHandler ( "onClientGUIClick", currentBrowserGUI.close, closeCurrentBrowser, false )
	addEventHandler ( "onClientGUIClick", currentBrowserGUI.isolate, currentBrowser.isolateClick, false )
	addEventHandler ( "onClientGUIClick", currentBrowserGUI.restore, restoreSelectedElement, false )
	addEventHandler ( "onClientGUISize", currentBrowserGUI.browser, currentBrowser.resized, false )
	currentBrowserGUI.gridlist:addCallback(currentBrowser.gridlistClick)
	currentBrowserGUI.gridlist:addDoubleClickCallback(currentBrowser.doubleClick)
end

local isResizing = false
function currentBrowser.resized()
	local windowWidth,windowHeight = guiGetSize(currentBrowserGUI.browser,false)
	currentBrowserGUI.gridlist:setSize(windowWidth, windowHeight-128)
	guiSetSize ( currentBrowserGUI.search,windowWidth,30,false)
	currentBrowserGUI.dropdown:setSize(windowWidth,20,windowWidth,200,false)
	dialog.autosnap:setPosition( 12, windowHeight-48,false )
	guiSetPosition ( currentBrowserGUI.isolate, 12, windowHeight-24,false )
	guiSetPosition ( currentBrowserGUI.close, windowWidth/4 * 3, windowHeight-40, false )
	guiSetSize ( currentBrowserGUI.close, windowWidth/4, 40, false )
	guiSetPosition ( currentBrowserGUI.restore, windowWidth/4 * 2-10, windowHeight-40, false )
	guiSetSize ( currentBrowserGUI.restore, windowWidth/4, 40, false )
	--
	if not isResizing then
		addEventHandler ( "onClientClick",root,resizeStop )
	end
	isResizing = true
end

function resizeStop ( button, state )
	if state == "up" then
		currentBrowser.prepareSearch()
		removeEventHandler ( "onClientClick",root,resizeStop )
		isResizing = false
	end
end

local elementList = {}
local linearresourceElementDefinitions = {}
function currentBrowser.update(elementArray)
	--Destroy the old dropdown
	local position = currentBrowserGUI.dropdown:getRow()
	currentBrowserGUI.dropdown:destroy()
	local dropdownArray = {}
	elementList = {}
	cSelectedElement = false
	dropdownArray[1] = "All elements"
	local nameTable = {}
	for resource,elementTable in pairs(resourceElementDefinitions) do
		for elementName,dataTable in pairs(elementTable) do
			if ( elementArray and isInArray(elementArray,elementName,resource) )
				or ( not elementArray )  and ( not ignoreArray ) then
				local friendlyName = dataTable["friendlyname"]
				if friendlyName == nil then friendlyName = elementName end
				--check if any other elements used the name
				local k = #dropdownArray + 1
				dropdownArray[k] = friendlyName
				if nameTable[elementName] ~= nil then
					--since we found another element with the same name, set the old name to element [resource]
					local oldRow = nameTable[elementName]["row"]
					local oldFriendlyName = nameTable[elementName]["friendlyName"]
					local oldResource = nameTable[elementName]["resource"]
					local text = oldFriendlyName.." ["..oldResource.."]"
					dropdownArray[oldRow] = text
					--set the current one with name [resource] too.
					local newText = friendlyName.." ["..resource.."]"
					dropdownArray[k] = newText
				end
				elementList[k] = {}
				elementList[k]["resource"] = resource
				elementList[k]["name"] = elementName

				nameTable[elementName] = {}
				nameTable[elementName]["resource"] = resource
				nameTable[elementName]["friendlyName"] = friendlyName
				nameTable[elementName]["row"] = k
			end
		end
	end
	currentBrowserGUI.dropdown = editingControl.dropdown:create{["x"]=12,["y"]=25,["width"]=screenX*width,["height"]=20,["dropWidth"]=screenX*width,["dropHeight"]=200,["relative"]=false,["parent"]=currentBrowserGUI.browser,["rows"]=dropdownArray}
	currentBrowserGUI.dropdown:setValue(position)
	currentBrowser.dropdownSelect = position
	currentBrowser.prepareSearch()
end

function isInArray(array,elementName,resourceName )
	for k,v in ipairs(array) do
		if ( type(v) == "table" ) then
			if v.elementName == elementName then
				if v.resourceName then
					if v.resourceName == resourceName then
						return true
					end
				else --if a resource name wasnt specified, then just return it anyway.
					return true
				end
			end
		elseif ( type(v) == "string" ) then
			if v == elementName then
				return true
			end
		end
	end
	return false
end

function currentBrowser.isolateClick ()
	local cellrow = currentBrowserGUI.gridlist:getSelected()
	local doIsolate = guiCheckBoxGetSelected ( currentBrowserGUI.isolate )
	if cellrow ~= 0 then
		currentBrowser.isolateElement (cSelectedElement,doIsolate)
	else
		guiCheckBoxSetSelected ( currentBrowserGUI.isolate, false )
	end
end

function currentBrowser.isolateElement (element,bool)
	local dimension
	if ( bool ) then
		dimension = hiddenDimension
		dimensionElement = element
	else
		dimension = workingDimension
		dimensionElement = false
	end
	setElementDimension ( localPlayer,dimension )
	setElementDimension ( element,dimension )
end


function currentBrowser.gridlistClick(cellrow)
    if cellrow ~= 0 then
        local fullText = currentBrowserGUI.gridlist:getSelectedText()
        -- Extract just the element name portion (before the bracket)
        local elementName = string.match(fullText, "^([^%[]+)")
        -- Trim any spaces at the end
        elementName = string.gsub(elementName, "%s+$", "")
        cSelectedElement = getElementByID(elementName)
        editor_main.selectElement(cSelectedElement, 2, false, cSelectedElement, cSelectedElement, true)
        if (dialog.autosnap:getValue()) then
            autoSnap(cSelectedElement)
        end
        if (dimensionElement) then
            setElementDimension(dimensionElement, workingDimension)
            setElementDimension(cSelectedElement, hiddenDimension)
            dimensionElement = cSelectedElement
        end
    elseif (dimensionElement) then
        setElementDimension(dimensionElement, workingDimension)
        setElementDimension(localPlayer, workingDimension)
        guiCheckBoxSetSelected(currentBrowserGUI.isolate, false)
        dimensionElement = false
    end
end

function currentBrowser.doubleClick()
	if ( not callbackFunction ) then
		if cSelectedElement then
			editor_main.selectElement ( cSelectedElement, 2 )
		end
	end
end

function currentBrowser.dropdownSelect ( element )
	if currentBrowserGUI.dropdown:getRow() ~= currentBrowser.dropdownSelect then
		currentBrowser.dropdownSelect = currentBrowserGUI.dropdown:getRow()
		currentBrowser.prepareSearch()
	end
end
addEventHandler ( "onClientDropDownSelect", root, currentBrowser.dropdownSelect )--------

local searchTimerDelay
function currentBrowser.searchChanged ( element )
	if element == currentBrowserGUI.search then
		if ignoreSearch == true then ignoreSearch = false return end
		ignoreSearch = false
		for k,v in ipairs(getTimers()) do
			if v == searchTimerDelay then
				killTimer(searchTimerDelay)
				break
			end
		end
		searchTimerDelay = setTimer ( currentBrowser.prepareSearch, 250, 1 )
	end
end
addEventHandler ( "onClientGUIChanged", root, currentBrowser.searchChanged )

function currentBrowser.prepareSearch()
	local query = guiGetText ( currentBrowserGUI.search ) --get the query
	local cellrow = currentBrowser.dropdownSelect
	if cellrow == -0 then cellrow = 1 end
	if cellrow ~= 1 then
		local resource = elementList[cellrow]["resource"]
		local elemType = elementList[cellrow]["name"]
		local array = getElementsByType ( elemType )
		array = clearOtherResourceElements(array,resource)
		array = clearReps ( array )
		array = clearDimensionElements ( array )
		array = clearIgnoredElements ( array )
		array = clearEditorElements ( array )
		array = setTableElementIDs(array)
		array = applySearch ( array, query )
		currentBrowserGUI.gridlist:setRows(array)
	else
		local search = {}
		for row,theTable in pairs(elementList) do
			local elementType = theTable["name"]
			local resource = theTable["resource"]
			local elemTable = getElementsByType(elementType)
			elemTable = clearOtherResourceElements ( elemTable, resource )
			elemTable = clearReps ( elemTable )
			elemTable = clearDimensionElements ( elemTable )
			elemTable = clearIgnoredElements ( elemTable )
			elemTable = clearEditorElements ( elemTable )
			for k,v in pairs(elemTable) do
				table.insert ( search, v )
			end
		end
		search = setTableElementIDs(search)
		search = applySearch ( search, query )
		currentBrowserGUI.gridlist:setRows(search)
	end
end

local previousInput = false
function currentBrowser.searchClick()
	if source == currentBrowserGUI.search then
		local text = guiGetText ( source )
		if text == "Search..." or text == "Search" then
			ignoreSearch = true
			guiSetText ( source, "" )
		end
		previousInput = true
		guiSetInputEnabled ( true )
	else
		local text = guiGetText ( currentBrowserGUI.search )
		if text == "" then
			guiSetText ( currentBrowserGUI.search, "Search..." )
		end
		if ( previousInput ) then
			previousInput = false
			guiSetInputEnabled ( false )
		end
	end
end

function applySearch ( array, query )
	if query == "" or query == "Search..." then return array end
	local search = {}
	for k,text in ipairs(array) do
		query = string.lower(query)
		if string.find ( string.lower(text), query ) ~= nil then
			table.insert ( search, text )
		end
	end
	return search
end

function setTableElementIDs(elemTable)
    local elementsWithIDs = {}
    for k, v in pairs(elemTable) do
        local elementID = getElementID(v)
		local numericID = ""
		if getElementType(v) == "object" or getElementType(v) == "vehicle" or getElementType(v) == "ped" then
			numericID = "[" .. (getElementData(v, "model") or getElementModel(v) or "Unknown") .. "]"
		end
        elementsWithIDs[k] = tostring(elementID) .. " " .. tostring(numericID)
    end
    return elementsWithIDs
end

function clearReps ( elemTable )
	local validElements = { }
	for k,v in pairs (elemTable) do
		--check if it is a representation (that is, if it is not its own edf parent)
		local edfParent = edf.edfGetParent ( v )
		if ( edfParent == v ) then
			table.insert(validElements, v)
		end
	end
	return validElements
end

function clearOtherResourceElements ( elemTable, resourceName )
	if not getResourceFromName("edf") then
		return elemTable
	end

	local newTable = {}
	for key,value in ipairs(elemTable) do
		local creator = edf.edfGetCreatorResource (value)
		local creatorName = creator and getResourceName(creator)
		if ( creatorName == resourceName ) or ( creatorName == "edf" and resourceName == "editor_main" ) then
			table.insert ( newTable, value )
		end
	end
	return newTable
end

function clearDimensionElements ( elemTable )
	local validElements = { }
	for key,value in ipairs(elemTable) do
		if getElementDimension(value) == editor_main.getWorkingDimension() then
			table.insert(validElements, value)
		end
	end
	return validElements
end

function clearIgnoredElements ( elemTable )
	local validElements = { }
	for key,value in ipairs(elemTable) do
		if not ignoredTable[value] then
			table.insert(validElements, value)
		end
	end
	return validElements
end

function clearEditorElements ( elemTable )
	local validElements = { }
	for key,value in ipairs(elemTable) do
		if not editor_main.isEditorElement(value) and not isElementLocal(value) then
			table.insert(validElements, value)
		end
	end
	return validElements
end

addEventHandler ( "onClientGUIClick", root,
function()
	if source == currentBrowserGUI.search then
		local text = guiGetText ( source )
		if text == "Search..." or text == "Search" then
			guiSetText ( source, "" )
		end
	else
		local text = guiGetText ( currentBrowserGUI.search )
		if text == "" then
			guiSetText ( currentBrowserGUI.search, "Search..." )
		end
	end
end )


function showCurrentBrowser ( elementArray, ignoredElements, elementType, resourceName, callback, restore )
	---element array syntax element[n].resourceName, element[n].elementName
	-- setGUIShowing(false)
	if currentBrowser.showing then
		closeCurrentBrowser()
	end
	currentBrowser.showing = true
	ignoredTable = {}
	ignoredElements = ignoredElements or {}
	for k,v in ipairs(ignoredElements) do
		ignoredTable[v] = true
	end
	currentBrowserGUI.dropdown:enable()
	currentBrowser.update(elementArray)
	if ( elementType ) then
		for k,dataTable in pairs(elementList) do
			if ( resourceName == dataTable.resource ) and ( elementType == dataTable.name ) then
				currentBrowserGUI.dropdown:setValue(k)
				currentBrowser.dropdownSelect = k
				if ( locked ) then
					currentBrowserGUI.dropdown:disable()
				end
				break
			end
		end
	elseif not restore then
		currentBrowser.dropdownSelect = 1
		currentBrowserGUI.dropdown:setValue(1)
	end
	if ( callback ) then
		callbackFunction = callback
		guiSetText ( currentBrowserGUI.close, "OK" )
	else
		callbackFunction = nil
		guiSetText ( currentBrowserGUI.close, "Close" )
	end
	currentBrowser.prepareSearch()
	currentBrowserGUI.gridlist:enable(cc.currentelements_up,cc.currentelements_down)
	local returnValue = guiSetVisible ( currentBrowserGUI.browser, true )
	addEventHandler ( "onClientGUIWorldClick", root, currentBrowser.searchClick )
	addEventHandler ( "onClientElementCreate",root,currentBrowser.prepareSearch )
	addEventHandler ( "onClientElementDestroyed",root,currentBrowser.prepareSearch )
	return returnValue
end

function closeCurrentBrowser()
    if (not currentBrowser.showing) then return end
    currentBrowser.showing = false
    cSelectedElement = false
    if (callbackFunction) then
        local fullText = currentBrowserGUI.gridlist:getSelectedText()
        if (not fullText) then
            callbackFunction(false)
        else
            -- Extract just the element name portion (before the bracket)
            local elementName = string.match(fullText, "^([^%[]+)")
            -- Trim any spaces at the end
            elementName = string.gsub(elementName, "%s+$", "")
            callbackFunction(elementName)
        end
        callbackFunction = nil
    end
    currentBrowserGUI.gridlist:disable()
    guiCheckBoxSetSelected(currentBrowserGUI.isolate, false)
    if (dimensionElement) then
        setElementDimension(dimensionElement, workingDimension)
        setElementDimension(localPlayer, workingDimension)
        dimensionElement = false
    end
    guiSetVisible(currentBrowserGUI.browser, false)
    dumpSettings()
    xmlSaveFile(settingsXML)
    removeEventHandler("onClientGUIWorldClick", root, currentBrowser.searchClick)
    removeEventHandler("onClientElementCreate", root, currentBrowser.prepareSearch)
    removeEventHandler("onClientElementDestroyed", root, currentBrowser.prepareSearch)
end

function restoreSelectedElement()
	if cSelectedElement then
		editor_main.destroySelectedElement()
		closeCurrentBrowser()
		
		setTimer(function()
			showCurrentBrowser()
		end, 100, 1)
	end
end

function isCurrentBrowserShowing()
	return guiGetVisible(currentBrowserGUI.browser)
end

addEventHandler ( "saveloadtest_return", root,
	function ( command )
		if command == "new" then
			currentBrowser.prepareSearch()
		end
	end
)

