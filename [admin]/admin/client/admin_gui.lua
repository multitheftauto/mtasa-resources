--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_gui.lua
*
*	Original File by lil_Toady
*
**************************************]]
_guiprotected = {}

local lists = {}

function guiCreateHeader ( x, y, w, h, text, relative, parent )
	local header = guiCreateLabel ( x, y, w, h, text, relative, parent )
	if ( header ) then
		guiLabelSetColor ( header, 255, 0, 0 )
		guiSetFont ( header, "default-bold-small" )
		return header
	end
	return false
end

_guiCreateTab = guiCreateTab
function guiCreateTab ( name, parent, right )
	local tab = _guiCreateTab ( name, parent )
	if ( tab ) then
		if ( right ) then
			right = "general.tab_"..right
			if ( not hasPermissionTo ( right ) ) then
				guiSetEnabled ( tab, false )
				_guiprotected[right] = tab
			end
		end
		return tab
	end
	return false
end

_guiCreateButton = guiCreateButton
function guiCreateButton ( x, y, w, h, text, relative, parent, right )
	local button = _guiCreateButton ( x, y, w, h, text, relative, parent )
	if ( button ) then
		if ( right ) then
			right = "command."..right
			if ( not hasPermissionTo ( right ) ) then
				guiSetEnabled ( button, false )
				_guiprotected[right] = button
			end
		end
		guiSetFont ( button, "default-bold-small" )
		return button
	end
	return false
end

function guiCreateList(x, y, w, h, tabHeight, header, relative, parent, right)
	local list = guiCreateButton(x, y, w, h, header, relative, parent, right)
	
	local parentWidth, parentHeight = guiGetSize(parent, false)

	local absoluteWidth = parentWidth * w
	local absoluteHeight = parentHeight * h

	local dropDown = guiCreateStaticImage(absoluteWidth - 20, 0, 20, 20, "client\\images\\dropdown.png", false, list)
	guiSetProperty(dropDown, 'AlwaysOnTop', 'True')
	
	addEventHandler('onClientGUIClick', dropDown, function()
		guiListSetVisible(list, true)
	end, false)

	local bg = guiCreateButton(x, y, w, tabHeight, '', relative, parent)
	guiSetProperty(bg, 'AlwaysOnTop', 'True')
	guiSetVisible(bg, false)

	local edit = guiCreateEdit(0, 0, absoluteWidth - 20, 20, '', false, bg)
	guiSetProperty(edit, 'AlwaysOnTop', 'True')
	
	addEventHandler('onClientGUIChanged', edit, function()
		guiListLoadItems(list)
	end)

	local searchIcon = guiCreateStaticImage(absoluteWidth - 40, 0, 20, 20, "client\\images\\search.png", false, edit)
	guiSetEnabled(searchIcon, false)
	guiSetProperty(searchIcon, 'AlwaysOnTop', 'True')

	local close = guiCreateButton(absoluteWidth-20, 0, 20, 20, 'X', false, bg)
	guiSetProperty(close, 'AlwaysOnTop', 'True')
	guiSetAlpha(close, 1)
	
	addEventHandler('onClientGUIClick', close, function()
		guiListSetVisible(list, false)
	end, false)

	local gridlist = guiCreateGridList(0, 0, 1, 1, true, bg)

	addEventHandler('onClientGUIDoubleClick', gridlist, function()
		local callback = lists[list].callback
		if (type(callback) == 'function') then
			local row = guiGridListGetSelectedItem(gridlist)
			local data = guiGridListGetItemData(gridlist, row, 1)
			local text = guiGridListGetItemText(gridlist, row, 1)
			if (row > -1) then
				callback(data, text)
				guiListSetVisible(list, false)
			end
		end
	end, false)


	lists[list] = {
		bg = bg,
		edit = edit,
		gridlist = gridlist,
		items = {},
		callback = function() end,
	}

	return list
end

function guiListSetVisible(list, state)
	if lists[list] then
		guiSetVisible(lists[list].bg, state)
		if state then
			guiFocus(lists[list].edit)
		end
		return true
	end
	return false
end

function guiListSetItems(list, items)
	if lists[list] then
		lists[list].items = items
		guiListLoadItems(list)
		return true
	end
	return false
end

function guiListSetCallBack(list, callback)
	if lists[list] then
		lists[list].callback = callback
		return true
	end
	return false
end

function guiListSetColumns(list, columns)
	if lists[list] then
		for _, v in ipairs(columns) do
			guiGridListAddColumn(lists[list].gridlist, v.text, v.width)
		end
		return true
	end
	return false
end

function guiListLoadItems(list)
	local listData = lists[list]
	if listData then
		local filter = guiGetText(listData.edit)
		guiGridListClear(listData.gridlist)
		for k, v in ipairs(listData.items) do
			if (v.text:lower():find(filter:lower())) then
				local row = guiGridListAddRow(listData.gridlist)
				guiGridListSetItemText(listData.gridlist, row, 1, tostring ( v.text ), false, false )
				guiGridListSetItemData(listData.gridlist, row, 1, tostring ( v.data ) )
			end
		end
		return true
	end
	return false
end

addEventHandler('onClientGUIClick', guiRoot, function(button)
	if (button == 'left') then
		local parent = getElementParent(source)
		if parent then
			for list in pairs(lists) do
				if guiGetVisible(list) and (parent ~= list) and (getElementParent(parent) ~= getElementParent(list)) then
					guiListSetVisible(list, false)
				end
			end
		end
	end
end)
