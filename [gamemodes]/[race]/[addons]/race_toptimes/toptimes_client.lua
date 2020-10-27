--
-- toptimes_client.lua
--

CToptimes = {}
CToptimes.__index = CToptimes
CToptimes.instances = {}
g_Settings = {}

---------------------------------------------------------------------------
-- Client
-- Handle events from Race
--
-- This is the 'interface' from Race
--
---------------------------------------------------------------------------

addEventHandler('onClientResourceStart', g_ResRoot,
	function()
		triggerServerEvent('onLoadedAtClient_tt', g_Me)
	end
)

addEvent('onClientMapStarting', true)
addEventHandler('onClientMapStarting', getRootElement(),
	function(mapinfo)
		outputDebug( 'TOPTIMES', 'onClientMapStarting' )
		if g_CToptimes then
			g_CToptimes:onMapStarting(mapinfo)
		end
	end
)

addEvent('onClientMapStopping', true)
addEventHandler('onClientMapStopping', getRootElement(),
	function()
		outputDebug( 'TOPTIMES', 'onClientMapStopping' )
		if g_CToptimes then
			g_CToptimes:onMapStopping()
		end
	end
)

addEvent('onClientPlayerFinish', true)
addEventHandler('onClientPlayerFinish', getRootElement(),
	function()
		outputDebug( 'TOPTIMES', 'onClientPlayerFinish' )
		if g_CToptimes then
			g_CToptimes:doAutoShow()
		end
	end
)

addEvent('onClientSetMapName', true)
addEventHandler('onClientSetMapName', getRootElement(),
	function(manName)
		if g_CToptimes then
			g_CToptimes:setWindowTitle(manName)
		end
	end
)


function updateSettings(settings, playeradmin)
	outputDebug( 'TOPTIMES', 'updateSettings' )
	if g_CToptimes then
		if settings and settings.gui_x and settings.gui_y then
			g_CToptimes:setWindowPosition( settings.gui_x, settings.gui_y )
			g_CToptimes.startshow = settings.startshow
		end
		-- If admin changed this setting manually, then show the table to him
		if playeradmin == getLocalPlayer() then
			g_CToptimes:doToggleToptimes(true)
		end
	end
end


---------------------------------------------------------------------------
--
-- CToptimes:create()
--
--
--
---------------------------------------------------------------------------
function CToptimes:create()
	outputDebug ( 'TOPTIMES', 'CToptimes:create' )
	local id = #CToptimes.instances + 1
	CToptimes.instances[id] = setmetatable(
		{
			id = id,
			bManualShow		= false,		-- via key press
			bAutoShow		= false,		-- when player finished
			bGettingUpdates = false,		-- server should send us updates to the toptimes
			listStatus		= 'Empty',		-- 'Empty', 'Loading' or 'Full'
			gui				= {},			-- all gui items
			lastSeconds		= 0,
			targetFade		= 0,
			currentFade		= 0,
			autoOffTimer	= Timer:create(),
		},
		self
	)

	CToptimes.instances[id]:postCreate()
	return CToptimes.instances[id]
end


---------------------------------------------------------------------------
--
-- CToptimes:destroy()
--
--
--
---------------------------------------------------------------------------
function CToptimes:destroy()
	self:setHotKey(nil)
	self:closeWindow()
	self.autoOffTimer:destroy()
	CToptimes.instances[self.id] = nil
	self.id = 0
end


---------------------------------------------------------------------------
--
-- CToptimes:postCreate()
--
--
--
---------------------------------------------------------------------------
function CToptimes:postCreate()
	self:openWindow()
	self:setWindowPosition( 0.7, 0.02 )
	self:setHotKey('F5')
end


---------------------------------------------------------------------------
--
-- CToptimes:openWindow()
--
--
--
---------------------------------------------------------------------------
function CToptimes:openWindow ()
	if self.gui['container'] then
		return
	end

	self.size = {}
	self.size.x = 400-120
	self.size.y = 46 + 15 * 8

	local sizeX = self.size.x
	local sizeY = self.size.y

	-- windowbg is the root gui element.
	-- windowbg holds the backround image, to which the required alpha is applied
	self.gui['windowbg'] = guiCreateStaticImage(100, 100, sizeX, sizeY, 'img/timepassedbg.png', false, nil)
	guiSetAlpha(self.gui['windowbg'], 0.4)
	guiSetVisible( self.gui['windowbg'], false )

	-- windowbg as parent:

		self.gui['container'] = guiCreateStaticImage(0,0,1,1, 'img/blank.png', true, self.gui['windowbg'])
		guiSetProperty ( self.gui['container'], 'InheritsAlpha', 'false' )

		-- container as parent:

			self.gui['bar'] = guiCreateStaticImage(0, 0, sizeX, 18, 'img/timepassedbg.png', false, self.gui['container'])
			guiSetAlpha(self.gui['bar'], 0.4)

			self.gui['title'] = guiCreateLabel(0, 1, sizeX, 15, 'Top Times - ', false, self.gui['container'] )
			guiLabelSetHorizontalAlign ( self.gui['title'], 'center' )
			guiSetFont(self.gui['title'], 'default-bold-small')
			guiLabelSetColor ( self.gui['title'], 220, 220, 225 )

			self.gui['header'] = guiCreateLabel(19, 21, sizeX-30, 15, 'Pos      Time                            Name', false, self.gui['container'] )
			guiSetFont(self.gui['header'], 'default-small')
			guiLabelSetColor ( self.gui['header'], 192, 192, 192 )

			self.gui['headerul'] = guiCreateLabel(0, 21, sizeX, 15, string.rep('_', 38), false, self.gui['container'] )
			guiLabelSetHorizontalAlign ( self.gui['headerul'], 'center' )
			guiLabelSetColor ( self.gui['headerul'], 192, 192, 192 )

			self.gui['paneLoading'] = guiCreateStaticImage(0,0,1,1, 'img/blank.png', true, self.gui['container'])

			-- paneLoading as parent:

				self.gui['busy'] = guiCreateLabel(sizeX/4, 38, sizeX/2, 15, 'Please wait', false, self.gui['paneLoading'] )
				self.gui['busy2'] = guiCreateLabel(sizeX/4, 53, sizeX/2, 15, 'until next map', false, self.gui['paneLoading'] )
				guiLabelSetHorizontalAlign ( self.gui['busy'], 'center' )
				guiLabelSetHorizontalAlign ( self.gui['busy2'], 'center' )
				guiSetFont(self.gui['busy'], 'default-bold-small')
				guiSetFont(self.gui['busy2'], 'default-bold-small')

			self.gui['paneTimes'] = guiCreateStaticImage(0,0,1,1, 'img/blank.png', true, self.gui['container'])

			-- paneTimes as parent:

				-- All the labels in the time list
				self.gui['listTimes'] = {}
				self:updateLabelCount(8)

end


---------------------------------------------------------------------------
--
-- CToptimes:closeWindow()
--
--
--
---------------------------------------------------------------------------
function CToptimes:closeWindow ()
	destroyElement( self.gui['windowbg'] )
	self.gui = {}
end


---------------------------------------------------------------------------
--
-- CToptimes:setWindowPosition()
--
--
--
---------------------------------------------------------------------------
function CToptimes:setWindowPosition ( gui_x, gui_y )
	if self.gui['windowbg'] then
		local screenWidth, screenHeight = guiGetScreenSize()
		local posX = screenWidth/2 + 63 + ( screenWidth * (gui_x - 0.56) )
		local posY = 14 + ( screenHeight * (gui_y - 0.02) )

		local posXCurve = { {0, 0}, {0.7, screenWidth/2 + 63}, {1, screenWidth - self.size.x} }
		local posYCurve = { {0, 0}, {0.02, 14}, {1, screenHeight - self.size.y} }
-- 1280  0-1000
--       0.0 = 1280/2 - 140 = 0
--       0.5 = 1280/2 - 140 = 500
--       0.7 = 1280/2 - 140 = 500		= 703
--       1.0 = 1280 - 280 = 1000
-- 1024
		posX = math.evalCurve( posXCurve, gui_x )
		posY = math.evalCurve( posYCurve, gui_y )
		guiSetPosition( self.gui['windowbg'], posX, posY, false )
	end
end


---------------------------------------------------------------------------
--
-- CToptimes:setWindowTitle()
--
--
--
---------------------------------------------------------------------------
function CToptimes:setWindowTitle( mapName )
	if self.gui['title'] then
		-- Set the title
		guiSetText ( self.gui['title'], 'Top Times - ' .. mapName )
		-- Hide the 'until next map' message
		guiSetVisible (self.gui['busy2'], false)
	end
end


---------------------------------------------------------------------------
--
-- CToptimes:setHotKey()
--
--
--
---------------------------------------------------------------------------
function CToptimes:setHotKey ( hotkey )
	if self.hotkey then
		unbindKey ( self.hotkey, 'down', "showtimes" )
	end
	if hotkey and self.hotkey and hotkey ~= self.hotkey then
		outputConsole( "Race Toptimes hotkey is now '" .. tostring(hotkey) .. "'" )
	end
	self.hotkey = hotkey
	if self.hotkey then
		bindKey ( self.hotkey, 'down', "showtimes" )
	end
end


---------------------------------------------------------------------------
--
-- CToptimes:onMapStarting()
--
--
--
---------------------------------------------------------------------------
function CToptimes:onMapStarting(mapinfo)

	self.bAutoShow			= false
	self.bGettingUpdates	= false	 -- Updates are automatically cleared on the server at the start of a new map,
	self.listStatus		 = 'Empty'
	self.clientRevision	 = -1
	self:updateShow()
	self:setWindowTitle( mapinfo.name )

	if self.startshow then
		self:doToggleToptimes( true )
	end
end


---------------------------------------------------------------------------
--
-- CToptimes:onMapStopping()
--
--
--
---------------------------------------------------------------------------
function CToptimes:onMapStopping()

	self.bAutoShow			= false
	self.bGettingUpdates	= false	 -- Updates are automatically cleared on the server at the start of a new map,
	self.listStatus		 = 'Empty'
	self.clientRevision	 = -1
	self:doToggleToptimes(false)
	self:setWindowTitle( '' )

end


---------------------------------------------------------------------------
--
-- CToptimes:doAutoShow()
--
--
--
---------------------------------------------------------------------------
function CToptimes:doAutoShow()
	self.bAutoShow = true
	self:updateShow()
end


---------------------------------------------------------------------------
--
-- CToptimes:updateShow()
--
--
--
---------------------------------------------------------------------------
function CToptimes:updateShow()

	local bShowAny = self.bAutoShow or self.bManualShow
	self:enableToptimeUpdatesFromServer( bShowAny )

	--outputDebug( 'TOPTIMES', 'updateShow bAutoShow:'..tostring(self.bAutoShow)..' bManualShow:'..tostring(self.bManualShow)..' listStatus:'..self.listStatus )
	if not bShowAny then
		self.targetFade = 0
	elseif not self.bManualShow and self.listStatus ~= 'Full' then
		-- No change
	else
		local bShowLoading	= self.listStatus=='Loading'
		local bShowTimes	= self.listStatus=='Full'

		self.targetFade = 1
		guiSetVisible (self.gui['paneLoading'], bShowLoading)
		guiSetVisible (self.gui['paneTimes'], bShowTimes)
	end
end


---------------------------------------------------------------------------
--
-- CToptimes:enableUpdatesFromServer()
--
--
--
---------------------------------------------------------------------------
function CToptimes:enableToptimeUpdatesFromServer( bOn )
	if bOn ~= self.bGettingUpdates then
		self.bGettingUpdates = bOn
		triggerServerEvent('onClientRequestToptimesUpdates', g_Me, bOn, self.clientRevision )
	end
	if self.bGettingUpdates and self.listStatus == 'Empty' then
		self.listStatus = 'Loading'
	end
end


---------------------------------------------------------------------------
--
-- CToptimes:updateLabelCount()
--
--
--
---------------------------------------------------------------------------
function CToptimes:updateLabelCount(numLines)

	local sizeX = self.size.x
	local sizeY = self.size.y

	local parentGui = self.gui['paneTimes']
	local t = self.gui['listTimes']

	-- Expand/shrink the list
	while #t < numLines do
		local y = #t
		local x = #t<9 and 20 or 13
		local label = guiCreateLabel(x, 38+15*y, sizeX-x-10, 15, '', false, parentGui )
		guiSetFont(label, 'default-bold-small')
		table.insert( t, label )
	end

	while #t > numLines do
		local last = table.popLast(t)
		destroyElement( last )
	end

end


---------------------------------------------------------------------------
--
-- CToptimes:doOnServerSentToptimes()
--
--
--
---------------------------------------------------------------------------
function CToptimes:doOnServerSentToptimes( data, serverRevision, playerPosition )
	outputDebug( 'TOPTIMES', 'CToptimes:doOnServerSentToptimes ' .. tostring(#data) )

	-- Calc number lines to use and height of window
	local numLines = math.clamp( 0, #data, 50 )
	self.size.y = 46 + 15 * numLines

	-- Set height of window
	local sizeX = self.size.x
	local sizeY = self.size.y
	guiSetSize( self.gui['windowbg'], sizeX, sizeY, false )

	-- Make listTimes contains the correct number of labels
	self:updateLabelCount(numLines)

	-- Update the list items
	for i=1,numLines do

		local timeText = data[i].timeText
		if timeText:sub(1,1) == '0' then
			timeText = '  ' .. timeText:sub(2)
		end
		local line = string.format( '%d.  %s   %s', i, timeText, data[i].playerName )
		guiSetText ( self.gui['listTimes'][i], line )

		if i == playerPosition then
			guiLabelSetColor ( self.gui['listTimes'][i], 0, 255, 255 )
		else
			guiLabelSetColor ( self.gui['listTimes'][i], 255, 255, 255 )
		end

	end

	-- Debug
	if _DEBUG_CHECK then
		outputDebug( 'TOPTIMES', 'toptimes', string.format('crev:%s  srev:%s', tostring(self.clientRevision), tostring(serverRevision) ) )
		if self.clientRevision == serverRevision then
			outputDebug( 'TOPTIMES', 'Already have this revision' )
		end
	end

	-- Update status
	self.clientRevision = serverRevision
	self.listStatus = 'Full'
	self:updateShow()
end


function onServerSentToptimes( data, serverRevision, playerPosition )
	g_CToptimes:doOnServerSentToptimes( data, serverRevision, playerPosition )
end

---------------------------------------------------------------------------
--
-- CToptimes:doOnClientRender
--
--
--
---------------------------------------------------------------------------
function CToptimes:doOnClientRender()
	-- Early out test
	if self.targetFade == self.currentFade then
		return
	end

	-- Calc delta seconds since last call
	local currentSeconds = getTickCount() / 1000
	local deltaSeconds = currentSeconds - self.lastSeconds
	self.lastSeconds = currentSeconds


	deltaSeconds = math.clamp( 0, deltaSeconds, 1/25 )

	-- Calc max fade change for this call
	local fadeSpeed = self.targetFade < self.currentFade and 2 or 6
	local maxChange = deltaSeconds * fadeSpeed

	-- Update current fade
	local dif = self.targetFade - self.currentFade
	dif = math.clamp( -maxChange, dif, maxChange )
	self.currentFade = self.currentFade + dif

	-- Apply
	guiSetAlpha( self.gui['windowbg'], self.currentFade * 0.4 )
	guiSetAlpha( self.gui['container'], self.currentFade)
	guiSetVisible( self.gui['windowbg'], self.currentFade > 0 )
end


addEventHandler ( 'onClientRender', getRootElement(),
	function(...)
		if g_CToptimes then
			g_CToptimes:doOnClientRender(...)
		end
	end
)


---------------------------------------------------------------------------
--
-- CToptimes:doToggleToptimes()
--
--
--
---------------------------------------------------------------------------
function CToptimes:doToggleToptimes( bOn )

	-- Kill any auto off timer
	self.autoOffTimer:killTimer()

	-- Set bManualShow from bOn, or toggle if nil
	if bOn ~= nil then
		self.bManualShow = bOn
	else
		self.bManualShow = not self.bManualShow
	end

	-- Set auto off timer if switching on
	if self.bManualShow then
		self.autoOffTimer:setTimer( function() self:doToggleToptimes(false) end, 15000, 1 )
	end

	self:updateShow()

end


---------------------------------------------------------------------------
--
-- Commands and binds
--
--
--
---------------------------------------------------------------------------

function onHotKey()
	if g_CToptimes then
		g_CToptimes:doToggleToptimes()
	end
end
addCommandHandler ( "showtimes", onHotKey )

addCommandHandler('doF5',
	function(player,command,...)
		outputDebugString('doF5')
		if g_CToptimes then
			g_CToptimes:doToggleToptimes()
		end
	end
)


---------------------------------------------------------------------------
-- Global instance
---------------------------------------------------------------------------
g_CToptimes = CToptimes:create()
