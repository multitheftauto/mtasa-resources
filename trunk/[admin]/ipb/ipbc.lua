local resX, resY = guiGetScreenSize()
local comboCategories = {"Server info", "Lua timing", "Lua memory", "Packet usage", "Sqlite timing", "Bandwidth reduction", "Bandwidth usage", "Server timing", "Function timing", "Debug info", "Debug table", "Help", "Lib memory"}

function onStart()
	window = guiCreateWindow((resX / 2) - 400, (resY / 2) - 259, 800, 518, "MTA:SA Ingame Performance Browser", false)
	guiSetAlpha(window, 0.97)
	guiSetVisible(window, false)
	guiWindowSetSizable(window, false)
	
	labelTarget = guiCreateLabel(11, 27, 43, 17, "Target:", false, window)
	labelIncludeClients = guiCreateLabel(13, 59, 96, 15, "Include clients:", false, window)
	labelCategory = guiCreateLabel(193, 28, 56, 19, "Category:", false, window)
	labelOptions = guiCreateLabel(490, 30, 56, 19, "Options:", false, window)
	labelFilter = guiCreateLabel(506, 59, 35, 21, "Filter:", false, window)
	labelShowing = guiCreateLabel(193, 59, 192, 20, "Showing stats of: server", false, window)
	
	comboCategory = guiCreateComboBox(259, 28, 150, 300, "Server info", false, window)
	for i, cat in ipairs(comboCategories) do
		guiComboBoxAddItem(comboCategory, cat)
	end
	addEventHandler("onClientGUIComboBoxAccepted", comboCategory, askForAnotherCategory, false)
	
	grid = guiCreateGridList(12, 91, 774, 410, false, window)
	guiGridListSetSelectionMode(grid, 0)
	guiGridListSetSortingEnabled(grid, false)
	editTarget = guiCreateEdit(60, 26, 122, 21, "server", false, window)
	guiSetEnabled(editTarget, false)
	includeClientsCheckbox = guiCreateCheckBox(103, 59, 16, 16, "", false, false, window)
	guiSetEnabled(includeClientsCheckbox, false)
	optionsBox = guiCreateEdit(556, 28, 122, 21, "", false, window)
	guiSetEnabled(optionsBox, false)
	filterBox = guiCreateEdit(556, 59, 122, 21, "", false, window)
	guiSetEnabled(filterBox, false)
	
	closeButton = guiCreateButton(730, 30, 56, 30, "Close", false, window)
	addEventHandler("onClientGUIClick", closeButton, closeStats, false)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function askForAnotherCategory()
	local item = guiComboBoxGetSelected(comboCategory)
	local text = guiComboBoxGetItemText(comboCategory, item)
	triggerServerEvent("ipb.changeCat", root, text)
end

function closeStats()
	guiSetVisible(window, false)
	showCursor(false)
end

function receiveStats(rtype, stat1, stat2)
	if (rtype == 1) then
		-- We're opening IPB
		guiSetVisible(window, true)
		showCursor(true)
		-- Add columns
		for index, data in pairs(stat1) do
			guiGridListAddColumn(grid, stat1[index], 0.2)
		end
	elseif (rtype == 2) then
		-- We're changing category
		guiGridListClear(grid)
		removeColumns()
		-- Add columns
		for index, data in pairs(stat1) do
			guiGridListAddColumn(grid, stat1[index], 0.2)
		end
	end
	-- We're adding IPB stats
	for index, data in pairs(stat2) do
		-- See if we need to add a new row
		if (guiGridListGetRowCount(grid) < index) then
			guiGridListAddRow(grid)
		end
		for index2, data2 in pairs(data) do
			if (#tostring(data2) < 2) then
				-- Make it so we can actually see column titles as auto size column ignores size of column title
				guiGridListSetItemText(grid, index - 1, index2, tostring(data2).."            ", false, false)
			else
				guiGridListSetItemText(grid, index - 1, index2, tostring(data2).."  ", false, false)
			end
		end
	end
	-- Make columns short
	for index, data in pairs(stat1) do
		guiGridListAutoSizeColumn(grid, index)
	end
end
addEvent("ipb.recStats", true)
addEventHandler("ipb.recStats", root, receiveStats)

function removeColumns()
	-- Hack fix for #5620 (guiGridListAddColumn returns wrong index after deleting Columns)
	-- Delete all the columns many times
	for i=0, guiGridListGetColumnCount(grid) do
		guiGridListRemoveColumn(grid, i)
	end
	for i=0, guiGridListGetColumnCount(grid) do
		guiGridListRemoveColumn(grid, i)
	end
	for i=0, guiGridListGetColumnCount(grid) do
		guiGridListRemoveColumn(grid, i)
	end
	for i=0, guiGridListGetColumnCount(grid) do
		guiGridListRemoveColumn(grid, i)
	end
	for i=0, guiGridListGetColumnCount(grid) do
		guiGridListRemoveColumn(grid, i)
	end
end