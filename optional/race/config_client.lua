--
-- config_client.lua
--

local gui = {}
local guiData = {}
local AddonsInfoList = {}


addEvent('onClientOpenConfig', true )
addEventHandler('onClientOpenConfig', g_ResRoot,
	function()
		openConfigMenu()
	end
)

--------------------------------
-- Config open
--------------------------------
function openConfigMenu ()
	if gui["form"] then
		return
	end
    showCursor ( true )

    -- Create a gui window
    gui["form"]				= guiCreateWindow ( 200, 230, 390, 420, "ADDONS", false )

    gui['headerul'] = guiCreateLabel(10, 25, 570, 25, string.rep('_', 98), false, gui["form"] )
    --guiLabelSetHorizontalAlign ( gui['headerul'], 'center' )
    guiLabelSetColor ( gui['headerul'], 160, 160, 192 )

    gui['header'] = guiCreateLabel(30, 25, 300, 25, 'Name' .. string.rep(' ', 36) .. 'Description', false, gui["form"] )
    guiSetFont(gui['header'], 'default-small')
    guiLabelSetColor ( gui['header'], 160, 160, 192 )

	gui["scrollpane"]		= guiCreateScrollPane( 0, 0, 1, 1, true, gui["form"] )
	gui["button_apply"]		= guiCreateButton( 0, 0, 1, 1, 'Apply',		false, gui["form"] )
	gui["button_cancel"]	= guiCreateButton( 0, 0, 1, 1, 'Cancel',	false, gui["form"] )
	gui["label1"]			= guiCreateLabel( 0, 0, 1, 1, 'Get more race addons from http://community.mtasa.com/',	false, gui["form"] )
	gui["label2"]			= guiCreateLabel( 0, 0, 1, 1, "Note: Some addons may not take effect",	false, gui["form"] )
	gui["label3"]			= guiCreateLabel( 0, 0, 1, 1, "until the start of the next map.",	false, gui["form"] )
	gui["checkboxes"] = {}

	guiLabelSetHorizontalAlign( gui["label1"], 'center'  )
	guiLabelSetHorizontalAlign( gui["label2"], 'center'  )
	guiLabelSetHorizontalAlign( gui["label3"], 'center'  )
	guiSetFont( gui["label2"], 'default-bold-small' )
	guiSetFont( gui["label3"], 'default-bold-small' )
	guiLabelSetColor ( gui['label1'], 230, 230, 210 )
	guiLabelSetColor ( gui['label2'], 255, 255, 255 )
	guiLabelSetColor ( gui['label3'], 255, 255, 255 )

	guiSetVisible(gui["scrollpane"],false)
	guiScrollPaneSetScrollBars(gui["scrollpane"],false, true)

	triggerServerEvent('onRequestAddonsInfo', g_Me )
end


addEvent('onClientReceiveAddonsInfo', true )
addEventHandler('onClientReceiveAddonsInfo', g_ResRoot,
	function(addonsInfoMap)
		-- Map to list
		AddonsInfoList = {}
		for name,info in pairs(addonsInfoMap) do
			table.insert( AddonsInfoList, info )
		end
		-- alpha sort
		table.sort(AddonsInfoList, function(a,b) return(a.tag > b.tag) end)
		-- create lines
		local idx = 1
		for _,info in ipairs(AddonsInfoList) do
			local checkbox = guiCreateCheckBox ( 10,  10+idx*20, 150, 20, info.tag, info.enabled, false, gui["scrollpane"] )
			local label1 = guiCreateLabel      ( 160, 10+idx*20+3, 220,  20, info.description, false, gui["scrollpane"] )
			if not checkbox then
				outputDebugString( "checkbox failed" )
			end
			gui["checkboxes"][idx] = checkbox
			guiData[checkbox] = idx
			idx = idx + 1
		end
		resizeMenu()
		guiSetVisible(gui["scrollpane"],true)
	end
)

function resizeMenu()
	local rect = {}
	rect.x, rect.y, rect.sx, rect.sy = 0,0,guiGetSize ( gui["form"], false )

	-- Trim top
	_,rect = rectSplitY( rect, 50 )

	-- Divide into list and buttons area
	local rectTop, rectBot = rectSplitY( rect, -115 )

	-- Set list rect
	guiSetRect( gui["scrollpane"], rectTop, false )

	-- gap
	local rectLabel1, rectCur = rectSplitY( rectBot, 7 )

	-- get rect for label1
	local rectLabel1, rectCur = rectSplitY( rectCur, 25 )
	guiSetRect( gui["label1"], rectLabel1, false )

	-- gap
	rectSplitY( rectCur, 10 )

	-- get rect for label2
	local rectLabel2, rectCur = rectSplitY( rectCur, 15 )
	guiSetRect( gui["label2"], rectLabel2, false )

	-- get rect for label3
	local rectLabel3, rectCur = rectSplitY( rectCur, 15 )
	guiSetRect( gui["label3"], rectLabel3, false )

	-- get rect bottom bar
	local _,rectCur = rectSplitY( rectCur, -30 )

	-- get rect for close button
	local rectCur, rectClose = rectSplitX( rectCur, -95 )
	guiSetPosition ( gui["button_cancel"], rectClose.x, rectClose.y, false )
	guiSetSize ( gui["button_cancel"], 90, 22, false )

	-- get rect for ok button
	local rectCur, rectOk = rectSplitX( rectCur, -95 )
	guiSetPosition ( gui["button_apply"], rectOk.x, rectOk.y, false )
	guiSetSize ( gui["button_apply"], 90, 22, false )
	guiSetEnabled ( gui["button_apply"], false )
end

--------------------------------
-- Config close
--------------------------------
function closeConfigMenu ()
	if gui["form"] then
		destroyElement( gui["form"] )
		gui = {}
		guiData = {}
	end
    showCursor ( false )
end


--------------------------------
-- Config events
--------------------------------
addEventHandler ( "onClientGUISize", g_ResRoot,
	function ()
		if source == gui["form"] then
			resizeMenu()
		end
	end
)

addEventHandler ( "onClientGUIClick", g_ResRoot,
	function ()
		if not gui["form"] then
			return
		end
		if source == gui["button_apply"] then
			-- list to map
			local addonsInfoMap = {}
			for _,info in ipairs(AddonsInfoList) do
				addonsInfoMap[info.name] = info
			end
			triggerServerEvent('onRequestAddonsChange', g_Me, addonsInfoMap )
			closeConfigMenu()
			return
		end
		if source == gui["button_cancel"] then
			closeConfigMenu()
			return
		end
		for i,checkbox in ipairs(gui["checkboxes"]) do
			if source == checkbox then
				local idx = guiData[checkbox]
				AddonsInfoList[idx].enabled = guiCheckBoxGetSelected ( checkbox )
				guiSetEnabled ( gui["button_apply"], true )
				return
			end
		end

	end
)


--------------------------------
-- rect utils
--------------------------------
function rectSplitX(rect,pos)
	if pos < 0 then
		pos = rect.sx + pos
	end
	local right = table.deepcopy(rect)
	local left = table.deepcopy(rect)
	-- Move left end
	left.sx = pos
	-- Move right start
	right.x = right.x + pos
	right.sx = right.sx - pos
	return left,right
end

function rectSplitY(rect,pos)
	if pos < 0 then
		pos = rect.sy + pos
	end
	local top = table.deepcopy(rect)
	local bot = table.deepcopy(rect)
	-- Move top end
	top.sy = pos
	-- Move bot start
	bot.y = bot.y + pos
	bot.sy = bot.sy - pos
	return top,bot
end

function guiSetRect( element, rect, relative )
	guiSetPosition ( element, rect.x, rect.y, relative )
	guiSetSize ( element, rect.sx, rect.sy, relative )
end
