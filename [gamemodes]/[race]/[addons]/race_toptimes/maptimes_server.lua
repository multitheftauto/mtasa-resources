--
-- maptimes_server.lua
--

SMaptimes = {}
SMaptimes.__index = SMaptimes
SMaptimes.instances = {}


---------------------------------------------------------------------------
--
-- SMaptimes:create()
--
-- Create a SMaptimes instance
--
---------------------------------------------------------------------------
function SMaptimes:create( raceModeName, mapName, statsKey )
	local id = #SMaptimes.instances + 1
	SMaptimes.instances[id] = setmetatable(
		{
			id = id,
			raceModeName	= raceModeName,
			mapName		 = mapName,
			statsKey		= statsKey,
			dbTable		 = nil,
		},
		self
	)
	SMaptimes.instances[id]:postCreate()
	return SMaptimes.instances[id]
end


---------------------------------------------------------------------------
--
-- SMaptimes:destroy()
--
-- Destroy a SMaptimes instance
--
---------------------------------------------------------------------------
function SMaptimes:destroy()
	self.dbTable:destroy()
	SMaptimes.instances[self.id] = nil
	self.id = 0
end


---------------------------------------------------------------------------
--
-- SMaptimes:postCreate()
--
--
--
---------------------------------------------------------------------------
function SMaptimes:postCreate()
	local tableName = self:makeDatabaseTableName( self.raceModeName, self.mapName )
	local columns = { 'playerName', 'playerSerial', 'timeMs', 'timeText', 'dateRecorded', 'extra' }
	local columnTypes = { 'TEXT', 'TEXT', 'REAL', 'TEXT', 'TEXT' }
	self.dbTable = SDatabaseTable:create( tableName, columns, columnTypes )
end


---------------------------------------------------------------------------
--
-- SMaptimes:validateDbTableRow()
--
-- Make sure each cell in the row contains a valid value
--
---------------------------------------------------------------------------
function SMaptimes:validateDbTableRow( index )
	local row = self.dbTable.rows[index]
	row.playerName		= removeColorCoding ( tostring(row.playerName) or "playerName" )
	row.playerSerial	= tostring(row.playerSerial) or "playerSerial"
	row.timeMs			= tonumber(row.timeMs) or 0
	row.timeText		= tostring(row.timeText) or "00:00:000"
	row.dateRecorded	= tostring(row.dateRecorded) or "1900-00-00 00:00:00"
	row.extra			= tostring(row.extra) or ""
end


---------------------------------------------------------------------------
--
-- SMaptimes:flush()
--
-- Destroy a SMaptimes instance
--
---------------------------------------------------------------------------
function SMaptimes:flush()
	outputDebug( 'TOPTIMES', 'SMaptimes:flush()')
	self:save()
end


---------------------------------------------------------------------------
--
-- SMaptimes:makeDatabaseTableName()
--
--
--
---------------------------------------------------------------------------
function SMaptimes:makeDatabaseTableName( raceModeName, mapName )
	return 'race maptimes ' .. raceModeName .. ' ' .. mapName
end


---------------------------------------------------------------------------
--
-- SMaptimes:timeMsToTimeText()
--
--
--
---------------------------------------------------------------------------
function SMaptimes:timeMsToTimeText( timeMs )

	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	local ms		= timeMs - seconds * 1000;

	return string.format( '%02d:%02d:%03d', minutes, seconds, ms );
end


---------------------------------------------------------------------------
--
-- SMaptimes:load()
--
--
--
---------------------------------------------------------------------------
function SMaptimes:load()
	self.dbTable:load()

	-- Make sure each cell in the table contains a valid value - saves lots of checks later
	for i,row in ipairs(self.dbTable.rows) do
		self:validateDbTableRow( i )
	end

	self:sort()
end


---------------------------------------------------------------------------
--
-- SMaptimes:save()
--
--
--
---------------------------------------------------------------------------
function SMaptimes:save()
	self.dbTable:save()
end


---------------------------------------------------------------------------
--
-- SMaptimes:sort()
--
-- Not quick
--
---------------------------------------------------------------------------
function SMaptimes:sort()

	self:checkIsSorted('Presort')

	table.sort(self.dbTable.rows, function(a, b)
									return a.timeMs < b.timeMs or ( a.timeMs == b.timeMs and a.dateRecorded < b.dateRecorded )
								  end )

	self:checkIsSorted('Postsort')

end


---------------------------------------------------------------------------
--
-- SMaptimes:checkIsSorted()
--
-- Debug
--
---------------------------------------------------------------------------
function SMaptimes:checkIsSorted(msg)

	for i=2,#self.dbTable.rows do
		local prevTime	= self.dbTable.rows[i-1].timeMs
		local time		= self.dbTable.rows[i].timeMs
		if prevTime > time then
			outputWarning( 'Maptimes sort error: ' .. msg .. ' timeMs order error at ' .. i )
		end

		if prevTime == time then
			prevDate	= self.dbTable.rows[i-1].dateRecorded
			date		= self.dbTable.rows[i].dateRecorded
			if prevDate > date then
				outputWarning( 'Maptimes sort error: ' .. msg .. ' dateRecorded order error at ' .. i )
			end
		end
	end

end


---------------------------------------------------------------------------
--
-- SMaptimes:getToptimes()
--
-- Return a table of the top 'n' toptimes
--
---------------------------------------------------------------------------
function SMaptimes:getToptimes( howMany )

	if _DEBUG_CHECK then
		self:checkIsSorted('getToptimes')
	end

	local result = {}

	for i=1,howMany do
		if i <= #self.dbTable.rows then
			result[i] = {
							timeText	= self.dbTable.rows[i].timeText,
							playerName	= self.dbTable.rows[i].playerName
						}
		else
			result[i] = {
							timeText	= ' -- Empty -- ',
							playerName	= ''
						}
		end
	end

	return result
end


---------------------------------------------------------------------------
--
-- SMaptimes:getValidEntryCount()
--
-- Return a count of the number of toptimes
--
---------------------------------------------------------------------------
function SMaptimes:getValidEntryCount()
	return #self.dbTable.rows
end

---------------------------------------------------------------------------
--
-- SMaptimes:addPlayer()
--
--
--
---------------------------------------------------------------------------
function SMaptimes:addPlayer( player )

	table.insert( self.dbTable.rows, {
									playerName		= getPlayerName(player),
									playerSerial	= getPlayerSerial(player),
									timeMs			= 0,
									timeText		= '00:00:000',
									dateRecorded	= '1900-00-00 00:00:00',
									extra			= ''
								} )

	-- Make sure new row has valid values
	self:validateDbTableRow( #self.dbTable.rows )

	return #self.dbTable.rows
end


---------------------------------------------------------------------------
--
-- SMaptimes:getIndexForPlayer()
--
-- Can return false if player has no entry
--
---------------------------------------------------------------------------
function SMaptimes:getIndexForPlayer( player )

	if self.statsKey == 'serial' then
		-- Find player by serial
		local serial = getPlayerSerial(player)
		for i,row in ipairs(self.dbTable.rows) do
			if serial == row.playerSerial then
				return i
			end
		end
	else
		-- Find player by name
		local name = getPlayerName(player)
		for i,row in ipairs(self.dbTable.rows) do
			if name == row.playerName then
				return i
			end
		end
	end

	return false
end


---------------------------------------------------------------------------
--
-- SMaptimes:getPositionForTime()
--
-- Always succeeds
--
---------------------------------------------------------------------------
function SMaptimes:getPositionForTime( time, dateRecorded )

	for i,row in ipairs(self.dbTable.rows) do
		if time < row.timeMs then
			return i
		end
		if time == row.timeMs and dateRecorded < row.dateRecorded then
			return i
		end
	end

	return #self.dbTable.rows + 1
end


---------------------------------------------------------------------------
--
-- SMaptimes:getTimeForPlayer()
--
-- Can return false if player has no entry
--
---------------------------------------------------------------------------
function SMaptimes:getTimeForPlayer( player )

	local i = self:getIndexForPlayer( player )

	if not i then
		return false
	end

	return self.dbTable.rows[i].timeMs

end


---------------------------------------------------------------------------
--
-- SMaptimes:setTimeForPlayer()
--
-- Update the time for this player
--
---------------------------------------------------------------------------
function SMaptimes:setTimeForPlayer( player, time, dateRecorded )

	-- Find current entry for player
	local oldIndex = self:getIndexForPlayer( player )

	if not oldIndex then
		-- No entry yet, so add it to the end
		oldIndex = self:addPlayer( player )
		if oldIndex ~= self:getIndexForPlayer( player ) then
			outputError( "oldIndex ~= self:getIndexForPlayer( player )" )
		end
	end

	-- Copy it out and then remove it from the table
	local row = self.dbTable.rows[oldIndex]
	table.remove( self.dbTable.rows, oldIndex )

	-- Update it
	row.playerName		= getPlayerName(player)	 -- Refresh the name
	row.timeMs			= time
	row.timeText		= self:timeMsToTimeText(time)
	row.dateRecorded	= dateRecorded

	-- Put it back in at the correct position to maintain sort order
	local newIndex = self:getPositionForTime( row.timeMs, row.dateRecorded )
	table.insert( self.dbTable.rows, newIndex, row )

	if _DEBUG_CHECK then
		self:checkIsSorted('setTimeForPlayer')
	end

end


---------------------------------------------------------------------------
--
-- SMaptimes:deletefirst()
--
-- Remove the best time from this map
--
---------------------------------------------------------------------------
function SMaptimes:deletetime(place)

	place = tonumber(place) or 1

	-- Although the list should be sorted already, make sure
	self:sort()

	-- Remove the first row
	if #self.dbTable.rows >= place then
		-- Copy it out and then remove it from the table
		local row = self.dbTable.rows[place]
		table.remove( self.dbTable.rows, place )
		return row
	end

	return false
end
