--
-- toptimes_client.lua
--

CToptimes = {}
CToptimes.__index = CToptimes
CToptimes.instances = {}


---------------------------------------------------------------------------
-- Client
-- Handle events from Race
--
-- This is the 'interface' from Race
--
---------------------------------------------------------------------------

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
            bManualShow     = false,        -- via key press
            bAutoShow       = false,        -- when player finished
            bGettingUpdates = false,        -- server should send us updates to the toptimes
            listStatus      = 'Empty',      -- 'Empty', 'Loading' or 'Full'
            gui             = {},           -- all gui items
            lastSeconds = 0,
            targetFade = 0,
            currentFade = 0,
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
    self:closeWindow()
    if self.autoOffTimer then
        killTimer(self.autoOffTimer)
    end
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

    local screenWidth, screenHeight = guiGetScreenSize()

	local gui_x = 0.56
	local gui_y = 0.02

    self.rect = {}
    self.rect.x     = screenWidth/2 + 63 + ( screenWidth * (gui_x - 0.56) )
    self.rect.y     = 14 + ( screenHeight * (gui_y - 0.02) )
    self.rect.sizeX = 400-120
    self.rect.sizeY = 46 + 15 * 8

    local r = self.rect

    -- windowbg is the root gui element.
    -- windowbg holds the backround image, to which the required alpha is applied
    self.gui['windowbg'] = guiCreateStaticImage(r.x, r.y, r.sizeX, r.sizeY, 'img/timepassedbg.png', false, nil)
    guiSetAlpha(self.gui['windowbg'], 0.4)
    guiSetVisible( self.gui['windowbg'], false )

    -- windowbg as parent:

	    self.gui['container'] = guiCreateStaticImage(0,0,1,1, 'img/blank.png', true, self.gui['windowbg'])
        guiSetProperty ( self.gui['container'], 'InheritsAlpha', 'false' )

        -- container as parent:

            self.gui['bar'] = guiCreateStaticImage(0, 0, r.sizeX, 18, 'img/timepassedbg.png', false, self.gui['container'])
            guiSetAlpha(self.gui['bar'], 0.4)

            self.gui['title'] = guiCreateLabel(0, 1, r.sizeX, 15, 'Top Times - ', false, self.gui['container'] )
            guiLabelSetHorizontalAlign ( self.gui['title'], 'center' )
            guiSetFont(self.gui['title'], 'default-bold-small')
            guiLabelSetColor ( self.gui['title'], 220, 220, 225 )

            self.gui['header'] = guiCreateLabel(19, 21, r.sizeX-30, 15, 'Pos      Time                            Name', false, self.gui['container'] )
            guiSetFont(self.gui['header'], 'default-small')
            guiLabelSetColor ( self.gui['header'], 192, 192, 192 )

            self.gui['headerul'] = guiCreateLabel(0, 21, r.sizeX, 15, string.rep('_', 38), false, self.gui['container'] )
            guiLabelSetHorizontalAlign ( self.gui['headerul'], 'center' )
            guiLabelSetColor ( self.gui['headerul'], 192, 192, 192 )

	        self.gui['paneLoading'] = guiCreateStaticImage(0,0,1,1, 'img/blank.png', true, self.gui['container'])

            -- paneLoading as parent:

                self.gui['busy'] = guiCreateLabel(r.sizeX/4, 38, r.sizeX/2, 15, 'Please wait', false, self.gui['paneLoading'] )
                guiLabelSetHorizontalAlign ( self.gui['busy'], 'center' )
                guiSetFont(self.gui['busy'], 'default-bold-small')

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
    destroyElementList( self.gui )
    self.gui = {}
end

function destroyElementList ( list )
    for key,value in pairs(list) do
        if value then
            if type(value) == 'table' then
                outputDebug( 'TOPTIMES', 'destroyElementList '..tostring(value)..' '..tostring(key) )
                destroyElementList(value)
            else
                outputDebug( 'TOPTIMES', 'destroyElement '..tostring(value)..' '..tostring(key) )
                destroyElement(value)
            end
        end
    end
    list = {}
end


---------------------------------------------------------------------------
--
-- CToptimes:onMapStarting()
--
--
--
---------------------------------------------------------------------------
function CToptimes:onMapStarting(mapinfo)
   
    self.bAutoShow          = false
    self.bGettingUpdates    = false     -- Updates are automatically cleared on the server at the start of a new map,
    self.listStatus         = 'Empty'
    self.clientRevision     = -1
    self:updateShow()
    -- Set the title
    guiSetText ( self.gui['title'], 'Top Times - ' .. mapinfo.name )

end


---------------------------------------------------------------------------
--
-- CToptimes:onMapStopping()
--
--
--
---------------------------------------------------------------------------
function CToptimes:onMapStopping()
   
    self.bAutoShow          = false
    self.bGettingUpdates    = false     -- Updates are automatically cleared on the server at the start of a new map,
    self.listStatus         = 'Empty'
    self.clientRevision     = -1
    self:doToggleToptimes(false)
    -- Set the title
    guiSetText ( self.gui['title'], '')

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
        local bShowLoading  = self.listStatus=='Loading'
        local bShowTimes    = self.listStatus=='Full'

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

    local r = self.rect

    local parentGui = self.gui['paneTimes']
    local t = self.gui['listTimes']

    -- Expand/shrink the list
    while #t < numLines do
        local y = #t
        local x = #t<9 and 20 or 13
        local label = guiCreateLabel(x, 38+15*y, r.sizeX-x-10, 15, '', false, parentGui )
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
    outputDebug( 'TOPTIMES', 'CToptimes:doOnServerSentToptimes ' .. #data )

    -- Calc number lines to use and height of window
    local numLines = math.clamp( 0, #data, 50 )
    self.rect.sizeY = 46 + 15 * numLines

    -- Set height of window
    local r = self.rect
    guiSetSize( self.gui['windowbg'], r.sizeX, r.sizeY, false )

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
    if self.autoOffTimer then
        killTimer(self.autoOffTimer)
        self.autoOffTimer = nil
    end

    -- Set bManualShow from bOn, or toggle if nil
    if bOn ~= nil then
        self.bManualShow = bOn
    else
        self.bManualShow = not self.bManualShow
    end

    -- Set auto off timer if switching on
    if self.bManualShow then
        self.autoOffTimer = setTimer( function() self:doToggleToptimes(false) end, 15000, 1 )
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

bindKey('F5', 'down',
    function()
        if g_CToptimes then
           g_CToptimes:doToggleToptimes()
        end
    end
)

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
