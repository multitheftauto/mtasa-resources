--
-- toptimes_server.lua
--

SToptimesManager = {}
SToptimesManager.__index = SToptimesManager
SToptimesManager.instances = {}


---------------------------------------------------------------------------
-- Server
-- Handle events from Race
--
-- This is the 'interface' from Race
--
---------------------------------------------------------------------------

addEvent('onMapStarting')
addEventHandler('onMapStarting', g_Root,
	function(mapInfo, mapOptions, statsKey)
        if g_SToptimesManager then
		    g_SToptimesManager:setModeAndMap( mapInfo.modename, mapInfo.name, statsKey )
        end
	end
)

addEvent('onPlayerFinish')
addEventHandler('onPlayerFinish', g_Root,
	function(rank, time)
        if g_SToptimesManager then
		    g_SToptimesManager:playerFinished( source, time)
	    end
	end
)

addEventHandler('onResourceStop', g_ResRoot,
	function()
        if g_SToptimesManager then
    		g_SToptimesManager:unloadingMap()
	    end
	end
)


---------------------------------------------------------------------------
--
-- Events fired from here
--
---------------------------------------------------------------------------

addEvent("onPlayerToptimeImprovement")

---------------------------------------------------------------------------


---------------------------------------------------------------------------
--
-- SToptimesManager:create()
--
-- Create a SToptimesManager instance
--
---------------------------------------------------------------------------
function SToptimesManager:create()
    local id = #SToptimesManager.instances + 1
    SToptimesManager.instances[id] = setmetatable(
        {
            id = id,
            playersWhoWantUpdates   = {},
            updateQueue             = {},
            serviceQueueTimer       = nil,
            displayTopCount         = 8,       -- Top number of times to display
            mapTimes                = nil,      -- SMaptimes:create()
            serverRevision          = 0,        -- To prevent redundant updating to clients
        },
        self
    )
    SToptimesManager.instances[id]:postCreate()
    return SToptimesManager.instances[id]
end


---------------------------------------------------------------------------
--
-- SToptimesManager:destroy()
--
-- Destroy a SToptimesManager instance
--
---------------------------------------------------------------------------
function SToptimesManager:destroy()
    SToptimesManager.instances[self.id] = nil
    self.id = 0
end


---------------------------------------------------------------------------
--
-- SToptimesManager:postCreate()
--
--
--
---------------------------------------------------------------------------
function SToptimesManager:postCreate()
end


---------------------------------------------------------------------------
--
-- SToptimesManager:setModeAndMap()
--
-- Called when a new map has been loaded
--
---------------------------------------------------------------------------
function SToptimesManager:setModeAndMap( raceModeName, mapName, statsKey )
    outputDebug( 'TOPTIMES', 'SToptimesManager:setModeAndMap ' .. raceModeName .. '<>' .. mapName )

    -- Reset updatings from the previous map
    self.playersWhoWantUpdates = {}
    self.updateQueue = {}
    if self.serviceQueueTimer then
        killTimer(self.serviceQueueTimer)
    end
    self.serviceQueueTimer = nil

    -- Remove old map times
    if self.mapTimes then
        self.mapTimes:flush()   -- Ensure last stuff is saved
        self.mapTimes:destroy()
    end

    -- Get map times for this map
    self.mapTimes = SMaptimes:create( raceModeName, mapName, statsKey )
    self.mapTimes:load()

    -- Get the toptimes data ready to send
    self:updateTopText()
end


---------------------------------------------------------------------------
--
-- SToptimesManager:unloadingMap()
--
-- Called when unloading
--
---------------------------------------------------------------------------
function SToptimesManager:unloadingMap()
    if self.mapTimes then
        self.mapTimes:flush()   -- Ensure last stuff is saved
    end
end


---------------------------------------------------------------------------
--
-- SToptimesManager:playerFinished()
--
-- If time is good enough, insert into database
--
---------------------------------------------------------------------------
function SToptimesManager:playerFinished( player, newTime, dateRecorded )

	if not self.mapTimes then
		outputDebug( 'TOPTIMES', 'SToptimesManager:playerFinished - self.mapTimes == nil' )
		return
	end

    dateRecorded = dateRecorded or getRealDateTimeNowString()

    local oldTime	= self.mapTimes:getTimeForPlayer( player )    -- Can be false if no previous time
    local newPos	= self.mapTimes:getPositionForTime( newTime, dateRecorded )

    -- See if time is an improvement for this player
    if not oldTime or newTime < oldTime then

		local oldPos    = self.mapTimes:getIndexForPlayer( player )
		triggerEvent("onPlayerToptimeImprovement", player, newPos, newTime, oldPos, oldTime, self.displayTopCount, self.mapTimes:getValidEntryCount() )

        -- See if its in the top display
        if newPos <= self.displayTopCount then
            outputDebug( 'TOPTIMES', getPlayerName(player) .. ' got toptime position ' .. newPos )
        end

        if oldTime then
            outputDebug( 'TOPTIMES', getPlayerName(player) .. ' new personal best ' .. newTime .. ' ' .. oldTime - newTime )
        end

        self.mapTimes:setTimeForPlayer( player, newTime, dateRecorded )

        -- updateTopText if database was changed
        if newPos <= self.displayTopCount then
            self:updateTopText()
        end
    end

    outputDebug( 'TOPTIMES', '++ SToptimesManager:playerFinished ' .. tostring(getPlayerName(player)) .. ' time:' .. tostring(newTime) )
end


---------------------------------------------------------------------------
--
-- SToptimesManager:updateTopText()
--
-- Update the toptimes client data for the current map
--
---------------------------------------------------------------------------
function SToptimesManager:updateTopText()
    -- Update data

    -- Read top rows from map toptimes table and send to all players who want to know
    self.toptimesDataForMap = self.mapTimes:getToptimes( self.displayTopCount )
    self.serverRevision = self.serverRevision + 1

    -- Queue send to all players
    for i,player in ipairs(self.playersWhoWantUpdates) do
        self:queueUpdate(player)
    end
end


---------------------------------------------------------------------------
--
-- SToptimesManager:onServiceQueueTimer()
--
-- Pop a player off the updateQueue and send them an update
--
---------------------------------------------------------------------------
function SToptimesManager:onServiceQueueTimer()
    outputDebug( 'TOPTIMES', 'SToptimesManager:onServiceQueueTimer()' )
    -- Process next player
    if #self.updateQueue > 0 and self.mapTimes then
        local player = self.updateQueue[1]
        local playerPosition = self.mapTimes:getIndexForPlayer( player )
        clientCall( player, 'onServerSentToptimes', self.toptimesDataForMap, self.serverRevision, playerPosition );
    end
    table.remove(self.updateQueue,1)
    -- Stop timer if end of update queue
    if #self.updateQueue < 1 then
        killTimer(self.serviceQueueTimer)
        self.serviceQueueTimer = nil
    end
end


---------------------------------------------------------------------------
--
-- SToptimesManager:addPlayerToUpdateList()
--
--
--
---------------------------------------------------------------------------
function SToptimesManager:addPlayerToUpdateList( player )
    if not table.find( self.playersWhoWantUpdates, player) then
        table.insert( self.playersWhoWantUpdates, player )
        outputDebug( 'TOPTIMES', 'playersWhoWantUpdates : ' .. #self.playersWhoWantUpdates )
    end
end

function SToptimesManager:removePlayerFromUpdateList( player )
    table.removevalue( self.playersWhoWantUpdates, player )
end


---------------------------------------------------------------------------
--
-- SToptimesManager:queueUpdate()
--
--
--
---------------------------------------------------------------------------
function SToptimesManager:queueUpdate( player )
    if not table.find( self.updateQueue, player) then
        table.insert( self.updateQueue, player )
    end

    if not self.serviceQueueTimer then
        self.serviceQueueTimer = setTimer( function() self:onServiceQueueTimer() end, 100, 0 )
    end
end


function SToptimesManager:unqueueUpdate( player )
    table.removevalue( self.updateQueue, player )
end


---------------------------------------------------------------------------
--
-- SToptimesManager:doOnClientRequestToptimesUpdates()
--
--
--
---------------------------------------------------------------------------
function SToptimesManager:doOnClientRequestToptimesUpdates( player, bOn, clientRevision )
    outputDebug( 'TOPTIMES', 'SToptimesManager:onClientRequestToptimesUpdates: '
            .. tostring(getPlayerName(player)) .. '<>' .. tostring(bOn) .. '< crev:'
            .. tostring(clientRevision) .. '< srev:' .. tostring(self.serverRevision) )
    if bOn then
        self:addPlayerToUpdateList(player)
        if clientRevision ~= self.serverRevision then
            outputDebug( 'TOPTIMES', 'queueUpdate for'..getPlayerName(player) )
            self:queueUpdate(player)
        end
    else
        self:removePlayerFromUpdateList(player)
        self:unqueueUpdate(player)
    end

end


addEvent('onClientRequestToptimesUpdates', true)
addEventHandler('onClientRequestToptimesUpdates', getRootElement(),
	function( bOn, clientRevision )
        g_SToptimesManager:doOnClientRequestToptimesUpdates( source, bOn, clientRevision )
	end
)



---------------------------------------------------------------------------
--
-- Testing
--
--
--
---------------------------------------------------------------------------

addCommandHandler('settopcount',
    function( player, command, value )
		if not _TESTING and not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
        value = tonumber(value)
        if value > 0 then
            value = math.max( 1, math.min( value, 50 ) )
            if value ~= g_SToptimesManager.displayTopCount then
                g_SToptimesManager.displayTopCount = value
                g_SToptimesManager:updateTopText()
            end
        end
    end
)


---------------------------------------------------------------------------
-- Global instance
---------------------------------------------------------------------------
g_SToptimesManager = SToptimesManager:create()
