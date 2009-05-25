--
-- config_client.lua
--

local gui = {}
local AddonsActive = {}
local AddonsInactive = {}


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
    gui["form"]				= guiCreateWindow ( 200, 300, 370, 220, "ADDONS", false )
	gui["scrollpane"]		= guiCreateScrollPane( 0, 0, 1, 1, true, gui["form"] )
	gui["button_ok"]		= guiCreateButton( 0, 0, 1, 1, 'Ok',		false, gui["form"] )
	gui["button_cancel"]	= guiCreateButton( 0, 0, 1, 1, 'Cancel',	false, gui["form"] )
	gui["label1"]			= guiCreateLabel( 0, 0, 1, 1, 'Get more race addons from http://blaaaaaaaaaaah/',	false, gui["form"] )
	gui["label2"]			= guiCreateLabel( 0, 0, 1, 1, "Note: Pressing 'Ok' will apply changes and restart race",	false, gui["form"] )
	gui["checkboxes"] = {}

	guiLabelSetHorizontalAlign( gui["label1"], 'center'  )
	guiLabelSetHorizontalAlign( gui["label2"], 'center'  )
	guiSetFont( gui["label1"], 'default-bold-small' )
	guiSetFont( gui["label2"], 'default-bold-small' )

	guiSetVisible(gui["scrollpane"],false)
	guiScrollPaneSetScrollBars(gui["scrollpane"],false, true)

	triggerServerEvent('onRequestAddonsInfo', g_ResRoot )
end


addEvent('onClientReceiveAddonsInfo', true )
addEventHandler('onClientReceiveAddonsInfo', g_ResRoot,
	function(active, inactive)
		AddonsActive = active
		AddonsInactive = inactive
		local idx = 1
		for _,name in ipairs(AddonsActive) do
			gui["checkboxes"][idx] = guiCreateCheckBox ( 10, 10+idx*20, 200, 20, name, true, false, gui["scrollpane"] )
			idx = idx + 1
		end
		for _,name in ipairs(AddonsInactive) do
			gui["checkboxes"][idx] = guiCreateCheckBox ( 10, 10+idx*20, 200, 20, name, false, false, gui["scrollpane"] )
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
	_,rect = rectSplitY( rect, 30 )

	-- Divide into list and buttons area
	local rectTop, rectBot = rectSplitY( rect, -90 )

	-- Set list rect
	guiSetRect( gui["scrollpane"], rectTop, false )

	-- gap
	local rectLabel1, rectCur = rectSplitY( rectBot, 7 )

	-- get rect for label1
	local rectLabel1, rectCur = rectSplitY( rectCur, 25 )
	guiSetRect( gui["label1"], rectLabel1, false )

	-- get rect for label2
	local rectLabel2, rectCur = rectSplitY( rectCur, 25 )
	guiSetRect( gui["label2"], rectLabel2, false )

	-- get rect bottom bar
	local _,rectCur = rectSplitY( rectCur, -30 )

	-- get rect for close button
	local rectCur, rectClose = rectSplitX( rectCur, -95 )
	guiSetPosition ( gui["button_cancel"], rectClose.x, rectClose.y, false )
	guiSetSize ( gui["button_cancel"], 90, 22, false )

	-- get rect for ok button
	local rectCur, rectOk = rectSplitX( rectCur, -95 )
	guiSetPosition ( gui["button_ok"], rectOk.x, rectOk.y, false )
	guiSetSize ( gui["button_ok"], 90, 22, false )
end

--------------------------------
-- Config close
--------------------------------
function closeConfigMenu ()
	if gui["form"] then
		destroyElement( gui["form"] )
		gui = {}
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
		if source == gui["button_ok"] then
			triggerServerEvent('onRequestAddonsChange', g_ResRoot, AddonsActive, AddonsInactive )
			closeConfigMenu()
			return
		end
		if source == gui["button_cancel"] then
			closeConfigMenu()
			return
		end
		for i,checkbox in ipairs(gui["checkboxes"]) do
			if source == checkbox then
				local name = guiGetText(checkbox)
				if guiCheckBoxGetSelected ( checkbox ) then
					table.removevalue(AddonsInactive,name)
					table.insert(AddonsActive,name)
				else
					table.removevalue(AddonsActive,name)
					table.insert(AddonsInactive,name)
				end
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
