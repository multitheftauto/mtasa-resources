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
	function(mapInfo, mapOptions, gameOptions)
		if g_SToptimesManager then
			g_SToptimesManager:setModeAndMap( mapInfo.modename, mapInfo.name, gameOptions.statsKey )
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

addEventHandler('onPlayerQuit', g_Root,
	function()
		if g_SToptimesManager then
			g_SToptimesManager:removePlayerFromUpdateList(source)
			g_SToptimesManager:unqueueUpdate(source)
		end
	end
)

addEventHandler('onResourceStart', g_ResRoot,
	function()
		local raceInfo = getRaceInfo()
		if raceInfo and g_SToptimesManager then
			g_SToptimesManager:setModeAndMap( raceInfo.mapInfo.modename, raceInfo.mapInfo.name, raceInfo.gameOptions.statsKey )
		end
	end
)

function getRaceInfo()
	local raceResRoot = getResourceRootElement( getResourceFromName( "race" ) )
	return raceResRoot and getElementData( raceResRoot, "info" )
end

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
			playersWhoWantUpdates	= {},
			updateQueue			 = {},
			serviceQueueTimer		= nil,
			displayTopCount		 = 8,		-- Top number of times to display
			mapTimes				= nil,		-- SMaptimes:create()
			serverRevision			= 0,		-- To prevent redundant updating to clients
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
	cacheSettings()
	self.displayTopCount = g_Settings.numtimes
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
		self.mapTimes:flush()	-- Ensure last stuff is saved
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
		self.mapTimes:flush()	-- Ensure last stuff is saved
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

	-- Check if top time recording is disabled for this player
	if getElementData ( player, "toptimes" ) == "off" then
		return
	end

	if not self.mapTimes then
		outputDebug( 'TOPTIMES', 'SToptimesManager:playerFinished - self.mapTimes == nil' )
		return
	end

	dateRecorded = dateRecorded or getRealDateTimeNowString()

	local oldTime	= self.mapTimes:getTimeForPlayer( player )	-- Can be false if no previous time
	local newPos	= self.mapTimes:getPositionForTime( newTime, dateRecorded )

	-- See if time is an improvement for this player
	if not oldTime or newTime < oldTime then

		local oldPos	= self.mapTimes:getIndexForPlayer( player )
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
	if not self.mapTimes then return end
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
-- Commands and binds
--
--
--
---------------------------------------------------------------------------

addCommandHandler( "deletetime",
	function( player, cmd, place )
		if not _TESTING and not isPlayerInACLGroup(player, g_Settings.admingroup) then
			return
		end
		if g_SToptimesManager and g_SToptimesManager.mapTimes then
			local row = g_SToptimesManager.mapTimes:deletetime(place)
			if row then
				g_SToptimesManager:updateTopText()
				local mapName = tostring(g_SToptimesManager.mapTimes.mapName)
				local placeText = place and "#" .. tostring(place) .. " " or ""
				local slotDesc = "'" .. placeText .. "[" .. tostring(row.timeText) .. "] " .. tostring(row.playerName) .. "'"
				local adminName = tostring(getPlayerName(player))
				local adminLogName = getAdminNameForLog(player)
				outputChatBox( "Top time " .. slotDesc .. " deleted by " .. adminName )
				outputServerLog( "Toptimes: " .. adminLogName .. " deleted " .. slotDesc .. " from map '" .. mapName .. "'" )
			end
		end
	end
)


---------------------------------------------------------------------------
--
-- Settings
--
--
--
---------------------------------------------------------------------------
function cacheSettings()
	g_Settings = {}
	g_Settings.numtimes		= getNumber('numtimes',8)
	g_Settings.startshow	= getBool('startshow',false)
	g_Settings.gui_x		= getNumber('gui_x',0.56)
	g_Settings.gui_y		= getNumber('gui_y',0.02)
	g_Settings.admingroup	= getString("admingroup","Admin")
end

-- React to admin panel changes
addEvent ( "onSettingChange" )
addEventHandler('onSettingChange', g_ResRoot,
	function(name, oldvalue, value, playeradmin)
		outputDebug( 'MISC', 'Setting changed: ' .. tostring(name) .. '  value:' .. tostring(value) .. '  value:' .. tostring(oldvalue).. '  by:' .. tostring(player and getPlayerName(player) or 'n/a') )
		cacheSettings()
		-- Update here
		if g_SToptimesManager then
			g_SToptimesManager.displayTopCount = g_Settings.numtimes
			g_SToptimesManager:updateTopText()
		end
		-- Update clients
		clientCall(g_Root,'updateSettings', g_Settings, playeradmin)
	end
)

-- New player joined
addEvent('onLoadedAtClient_tt', true)
addEventHandler('onLoadedAtClient_tt', g_Root,
	function()
		-- Tell newly joined client current settings
		clientCall(source,'updateSettings', g_Settings)

		-- This could also be the toptimes resource being restarted, so send some mapinfo
		local raceInfo = getRaceInfo()
		if raceInfo then
		    triggerClientEvent('onClientSetMapName', source, raceInfo.mapInfo.name )
		end
	end
)


---------------------------------------------------------------------------
-- Global instance
---------------------------------------------------------------------------
g_SToptimesManager = SToptimesManager:create()
