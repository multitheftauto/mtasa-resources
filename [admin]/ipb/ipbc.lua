local resX, resY = guiGetScreenSize()

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
	guiComboBoxAddItem(comboCategory, "Server info")
	guiComboBoxAddItem(comboCategory, "Lua timing")
	guiComboBoxAddItem(comboCategory, "Lua memory")
	guiComboBoxAddItem(comboCategory, "Packet usage")
	guiComboBoxAddItem(comboCategory, "Sqlite timing")
	guiComboBoxAddItem(comboCategory, "Bandwidth reduction")
	guiComboBoxAddItem(comboCategory, "Bandwidth usage")
	guiComboBoxAddItem(comboCategory, "Server timing")
	guiComboBoxAddItem(comboCategory, "Function timing")
	guiComboBoxAddItem(comboCategory, "Debug info")
	guiComboBoxAddItem(comboCategory, "Debug table")
	guiComboBoxAddItem(comboCategory, "Help")
	guiComboBoxAddItem(comboCategory, "Lib memory")
	addEventHandler("onClientGUIComboBoxAccepted", comboCategory, askForAnotherCategory, false)
	
	grid = guiCreateGridList(12, 91, 774, 410, false, window)
	guiGridListSetSelectionMode(grid, 0)
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
		guiSetVisible(window, true)
		showCursor(true)
		-- Add columns
		for index, data in pairs(stat1) do
			guiGridListAddColumn(grid, stat1[index], 0.2)
		end
	elseif (rtype == 2) then
		guiGridListClear(grid)
		-- Problems occur here:
		for i=1, guiGridListGetColumnCount(grid) do
			guiGridListRemoveColumn(grid, i)
		end
		-- Add columns
		for index, data in pairs(stat1) do
			guiGridListAddColumn(grid, stat1[index], 0.2)
			--outputDebugString("adding column "..stat1[index])
		end
	end
	-- Add a ton of rows
	for i=1, 200 do
		guiGridListAddRow(grid)
	end
	for index, data in pairs(stat2) do
		for index2, data2 in pairs(data) do
			guiGridListSetItemText(grid, index - 1, index2, tostring(data2).."  ", false, false)
		end
	end
	-- Make columns short
	for index, data in pairs(stat1) do
		guiGridListAutoSizeColumn(grid, index)
	end
end
addEvent("ipb.recStats", true)
addEventHandler("ipb.recStats", root, receiveStats)

-- For testing problems:

function removeColumns()
	for i=0, guiGridListGetColumnCount(grid) do
		outputDebugString("removing column id a "..i.." "..tostring(guiGridListRemoveColumn(grid, i)))
		guiGridListRemoveColumn(grid, i)
	end
	for i=0, guiGridListGetColumnCount(grid) do
		outputDebugString("removing column id b "..i.." "..tostring(guiGridListRemoveColumn(grid, i)))
		guiGridListRemoveColumn(grid, i)
	end
end
addCommandHandler("removecolumns", removeColumns)