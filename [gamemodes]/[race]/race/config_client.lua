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

	gui['headerul'] = guiCreateLabel(10, 25, 670, 25, string.rep('_', 98), false, gui["form"] )
	guiLabelSetColor ( gui['headerul'], 160, 160, 192 )
	gui['headerul2'] = guiCreateLabel(10, 28, 670, 25, string.rep('_', 98), false, gui["form"] )
	guiLabelSetColor ( gui['headerul2'], 160, 160, 192 )

	gui['headers'] = {}
	gui['headers'][1] = guiCreateLabel(30, 25, 90, 25, 'State', false, gui["form"] )
	gui['headers'][2] = guiCreateLabel(50, 25, 90, 25, '', false, gui["form"] )
	gui['headers'][3] = guiCreateLabel(70, 25, 90, 25, 'Name', false, gui["form"] )
	gui['headers'][4] = guiCreateLabel(90, 25, 90, 25, 'Description', false, gui["form"] )
	for idx,header in ipairs( gui['headers'] ) do
		guiSetFont(header, 'default-small')
		guiLabelSetColor ( header, 160, 160, 192 )
	end

	gui["scrollpane"]		= guiCreateScrollPane( 0, 0, 1, 1, true, gui["form"] )
	gui["button_close"]		= guiCreateButton( 0, 0, 1, 1, 'Close',		false, gui["form"] )
	gui["label1"]			= guiCreateLabel( 0, 0, 1, 1, 'Get more race addons from http://community.mtasa.com/',	false, gui["form"] )
	gui["label2"]			= guiCreateLabel( 0, 0, 1, 1, "Note: Some addons may not take effect",	false, gui["form"] )
	gui["label3"]			= guiCreateLabel( 0, 0, 1, 1, "until the start of the next map.",	false, gui["form"] )
	gui["rows"] = {}

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
		table.sort(AddonsInfoList, function(a,b) return(a.tag < b.tag) end)
		-- create lines
		local colLengths = {}
		for idx,info in ipairs(AddonsInfoList) do
			if not gui["rows"][idx] then gui["rows"][idx] = {} end
			local row = gui["rows"][idx]
			if not row.checkbox then
				row.name			= guiCreateLabel ( 50,  10+idx*20,   150, 20, info.tag, false, gui["scrollpane"] )
				row.state			= guiCreateLabel ( 160, 10+idx*20, 220, 20, info.state, false, gui["scrollpane"] )
				row.description		= guiCreateLabel ( 260, 10+idx*20, 220, 20, info.description, false, gui["scrollpane"] )
				row.checkbox	 = guiCreateCheckBox ( 10,  10+idx*20-2,   150, 20, "", info.enabled, false, gui["scrollpane"] )
				guiLabelSetColor ( row.state, 255, 0, 0 )
			end

			-- Alternate row colors + active highlight
			local r, g, b = 255, 255, 255
			if idx % 2 == 1 then
				b = b * 0.6
			else
				b = b * 0.8
			end
			if info.state ~= "running" then
				r = r * 0.5
				g = g * 0.5
				b = b * 0.5
			end
			guiLabelSetColor ( row.name, r, g, b )
			guiLabelSetColor ( row.description, r, g, b )

			guiSetText( row.name, info.tag )
			guiSetText( row.state, info.state == "running" and "ON" or "" )
			guiSetText( row.description, info.description )

			colLengths[1] = 27
			colLengths[2] = 20
			colLengths[3] = math.max( colLengths[3] or 0, guiLabelGetTextExtent ( row.name ) + 20 )
			colLengths[4] = math.max( colLengths[4] or 0, guiLabelGetTextExtent ( row.description ) + 20 )
		end

		-- Layout columns
		local colPositions = {}
		colPositions[1] = 10
		colPositions[2] = colPositions[1] + colLengths[1]
		colPositions[3] = colPositions[2] + colLengths[2]
		colPositions[4] = colPositions[3] + colLengths[3]
		colPositions[5] = colPositions[4] + colLengths[4]

		local sx,sy,px,py
		for idx,header in ipairs(gui["headers"]) do
			px,py = guiGetPosition( header, false )
			guiSetPosition( header, colPositions[idx], py, false )
		end

		for idx,row in ipairs(gui["rows"]) do
			local row = gui["rows"][idx]

			sx,sy = guiGetSize( row.state, false )
			px,py = guiGetPosition( row.state, false )
			guiSetSize( row.state, colLengths[1], sy, false )
			guiSetPosition( row.state, colPositions[1], py, false )

			sx,sy = guiGetSize( row.checkbox, false )
			px,py = guiGetPosition( row.checkbox, false )
			guiSetSize( row.checkbox, colLengths[2] + colLengths[3], sy, false )
			guiSetPosition( row.checkbox, colPositions[2], py, false )

			sx,sy = guiGetSize( row.name, false )
			px,py = guiGetPosition( row.name, false )
			guiSetSize( row.name, colLengths[3], sy, false )
			guiSetPosition( row.name, colPositions[3], py, false )

			sx,sy = guiGetSize( row.description, false )
			px,py = guiGetPosition( row.description, false )
			guiSetSize( row.description, colLengths[4], sy, false )
			guiSetPosition( row.description, colPositions[4], py, false )
		end

		x,y = guiGetSize( gui["form"], false )
		guiSetSize( gui["form"], colPositions[5]+50, y, false )

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
	local rectTop, rectBot = rectSplitY( rect, -110 )

	-- Set list rect
	guiSetRect( gui["scrollpane"], rectTop, false )

	-- get rect for headerul2
	local rectHeaderul2, rectCur = rectSplitY( rectBot, 18 )
	guiSetRect( gui["headerul2"], rectHeaderul2, false )

	-- gap
	local _, rectCur = rectSplitY( rectBot, 25 )

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
	guiSetPosition ( gui["button_close"], rectClose.x, rectClose.y, false )
	guiSetSize ( gui["button_close"], 90, 22, false )
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
		if source == gui["button_close"] then
			closeConfigMenu()
			return
		end
		for idx,row in ipairs(gui["rows"]) do
			if source == row.checkbox then
				-- Toggle
				AddonsInfoList[idx].enabled = guiCheckBoxGetSelected ( row.checkbox )
				-- list to map
				local addonsInfoMap = {}
				for _,info in ipairs(AddonsInfoList) do
					addonsInfoMap[info.name] = info
				end
				-- Send to server
				triggerServerEvent('onRequestAddonsChange', g_Me, addonsInfoMap )
				-- Update status
				setTimer( function() triggerServerEvent('onRequestAddonsInfo', g_Me ) end, 150, 1 )
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
