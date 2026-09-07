local pagesXml
local wndHelp, btnClose, pageList, pageColumn
local pages = {}
local selectedResource
local popupQueue = {}

function selectHelpPage(resource)
	selectedResource = resource
	for pageResource, page in pairs(pages) do
		guiSetVisible(page.memo, pageResource == resource)
	end
end

function refreshPageList()
	guiGridListClear(pageList)
	local pageResources = {}
	for resource in pairs(pages) do
		table.insert(pageResources, resource)
	end
	if not pages[selectedResource] then
		selectedResource = pageResources[1]
	end
	for _, resource in ipairs(pageResources) do
		local row = guiGridListAddRow(pageList)
		guiGridListSetItemText(pageList, row, pageColumn, pages[resource].title, false, false)
		guiGridListSetItemData(pageList, row, pageColumn, getResourceName(resource))
		if resource == selectedResource then
			guiGridListSetSelectedItem(pageList, row, pageColumn)
		end
	end
	selectHelpPage(selectedResource)
end
local HELP_KEY = "F9"
local HELP_COMMAND = "gamehelp"
local POPUP_TIMEOUT = 15000 --ms
local FADE_DELTA = .03 --alpha per frame
local MAX_ALPHA = .9

addEvent("doShowHelp", true)
addEvent("doHideHelp", true)
addEvent("onHelpShown")
addEvent("onHelpHidden")

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		wndHelp  = guiCreateWindow(.2, .2, .6, .6, "Help", true)
		btnClose = guiCreateButton(.4, .92, .2, .08, "Close", true, wndHelp)
		pageList = guiCreateGridList(.02, .08, .14, .82, true, wndHelp)
		pageColumn = guiGridListAddColumn(pageList, "Help page", 1)

		addEventHandler("onClientGUIClick", pageList,
			function()
				local row = guiGridListGetSelectedItem(pageList)
				if row == -1 then return end
				local resourceName = guiGridListGetItemData(pageList, row, pageColumn)
				local resource = resourceName and getResourceFromName(resourceName)
				if resource and pages[resource] then
					selectHelpPage(resource)
				end
			end, false
		)
		guiSetVisible(wndHelp, false)

		guiWindowSetSizable(wndHelp, false)

		addEventHandler("onClientGUIClick", btnClose,
			function()
				if source == btnClose then
					clientToggleHelp(false)
				end
			end, false
		)

		pagesXml = xmlLoadFile("seen.xml")
		if not pagesXml then
			pagesXml = xmlCreateFile("seen.xml", "seen")
		end

		for i, resRoot in ipairs(getElementsByType("resource")) do
			local resource = getResourceFromName(getElementID(resRoot))
			if resource then
				addHelpTabFromXML(resource)
			end
		end

		addCommandHandler(HELP_COMMAND, clientToggleHelp)
		bindKey(HELP_KEY, "down", clientToggleHelp)
	end
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		showCursor(false)
	end
)

-- exports
function showHelp()
	return clientToggleHelp(true)
end
addEventHandler("doShowHelp", root, showHelp)

function hideHelp()
	return clientToggleHelp(false)
end
addEventHandler("doHideHelp", root, hideHelp)

-- Retain the export name; the returned content element is now a memo, not a tab.
function addHelpTab(resource, showPopup)
	if pages[resource] then
		return false
	end

	local title = getResourceName(resource)
	local text = ""
	local helpnode = getResourceConfig(":" .. title .. "/help.xml")
	if helpnode then
		title = xmlNodeGetAttribute(helpnode, "title") or title
		text = xmlNodeGetValue(helpnode) or ""
	end

	local memo = guiCreateMemo(.18, .08, .80, .82, text, true, wndHelp)
	guiMemoSetReadOnly(memo, true)
	pages[resource] = { title = title, memo = memo }
	refreshPageList()

	if showPopup ~= false then
		addHelpPopup(resource)
	end
	return memo
end

function removeHelpTab(resource)
	if type(resource) ~= "userdata" then
		resource = getResourceFromName(getElementID(source))
	end
	if not resource or not pages[resource] then
		return false
	end

	destroyElement(pages[resource].memo)
	pages[resource] = nil
	refreshPageList()
	return true
end
addEventHandler("onClientResourceStop", root, removeHelpTab)

--private
function addHelpTabFromXML(resource)
	if type(resource) ~= "userdata" then
		resource = getResourceFromName(getElementID(source))
	end
	if not resource or pages[resource] then return false end

	local helpnode = getResourceConfig(":" .. getResourceName(resource) .. "/help.xml")
	if helpnode then
		addHelpTab(resource, xmlNodeGetAttribute(helpnode, "popup") ~= "no")
	end
end
addEventHandler("onClientResourceStart", root, addHelpTabFromXML)
function clientToggleHelp(state)
	if state ~= true and state ~= false then
		state = not guiGetVisible(wndHelp)
	end
	guiSetVisible(wndHelp, state)
	if state == true then
		triggerEvent("onHelpShown", localPlayer)
		guiBringToFront(wndHelp)
		showCursor(true)
	else
		triggerEvent("onHelpHidden", localPlayer)
		showCursor(false)
	end
	return true
end

local function fadeIn(wnd)
	local function raiseAlpha()
		if not isElement(wnd) then
			removeEventHandler("onClientRender", root, raiseAlpha)
			return
		end
		local newAlpha = guiGetAlpha(wnd) + FADE_DELTA
		if newAlpha <= MAX_ALPHA then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", root, raiseAlpha)
		end
	end
	addEventHandler("onClientRender", root, raiseAlpha)
end

local function fadeOut(wnd)
	local function lowerAlpha()
		if not isElement(wnd) then
			removeEventHandler("onClientRender", root, lowerAlpha)
			return
		end
		local newAlpha = guiGetAlpha(wnd) - FADE_DELTA
		if newAlpha >= 0 then
			guiSetAlpha(wnd, newAlpha)
		else
			removeEventHandler("onClientRender", root, lowerAlpha)
			destroyElement(wnd)

			table.remove(popupQueue, 1)
			if #popupQueue > 0 then
				showHelpPopup(popupQueue[1])
			end
		end
	end
	addEventHandler("onClientRender", root, lowerAlpha)
end

function addHelpPopup(resource)
	local xmlContents = xmlNodeGetValue(pagesXml)
	local seenPages = split(xmlContents, string.byte(','))
	local resourceName = getResourceName(resource)
	for i, page in ipairs(seenPages) do
		if page == resourceName then
			return
		end
	end
	xmlNodeSetValue(pagesXml, xmlContents..resourceName..",")
	xmlSaveFile(pagesXml)

	table.insert(popupQueue, resource)
	if #popupQueue == 1 then
		showHelpPopup(resource)
	end
end

function showHelpPopup(resource)
	local screenX, screenY = guiGetScreenSize()
	local wndPopup = guiCreateWindow(0, screenY - 20, screenX, 0, '', false)

	local restitle = getResourceName(resource)
	local helpnode = getResourceConfig(":" .. getResourceName(resource) .. "/help.xml")

	if helpnode then

		local nameattribute = xmlNodeGetAttribute(helpnode, "title");

		if nameattribute then
			restitle = nameattribute;
		end

	end

	local text =
		"Help page available for ".. restitle .."! "..
		"Press "..HELP_KEY.." or type /"..HELP_COMMAND.." to read it."

	guiSetText(wndPopup, text)
	guiSetAlpha(wndPopup, 0)
	guiWindowSetMovable(wndPopup, false)
	guiWindowSetSizable(wndPopup, false)

	fadeIn(wndPopup)
	setTimer(fadeOut, POPUP_TIMEOUT, 1, wndPopup)
end
