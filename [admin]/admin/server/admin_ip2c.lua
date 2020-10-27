--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_ip2c.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aCountries = {}
local IP2C_FILENAME = "conf/IpToCountryCompact.csv"
local IP2C_UPDATE_URL = "http://mirror.multitheftauto.com/mtasa/scripts/IpToCountryCompact.csv"
local IP2C_UPDATE_INTERVAL_SECONDS = 60 * 60 * 24 * 1	-- Update no more than once a day

function getPlayerCountry ( player )
	return getIpCountry ( getPlayerIP ( player ) )
end
function getIpCountry ( ip )
	if not loadIPGroupsIsReady() then return false end
	local ip_group = tonumber ( gettok ( ip, 1, 46 ) )
	local ip_code = ( gettok ( ip, 2, 46 ) * 65536 ) + ( gettok ( ip, 3, 46 ) * 256 ) + ( gettok ( ip, 4, 46 ) )
	if ( not aCountries[ip_group] ) then
		return false
	end
	for id, group in ipairs ( aCountries[ip_group] ) do
		local buffer = ByteBuffer:new( group )
		local rstart = buffer:readInt24()
		if ip_code >= rstart then
			local rend = buffer:readInt24()
			if ip_code <= rend then
				local rcountry = buffer:readBytes( 2 )
				return rcountry ~= "ZZ" and rcountry
			end
		end
	end
	return false
end

-- Returns false if aCountries is not ready
function loadIPGroupsIsReady ()
	if ( get ( "*useip2c" ) == "false" ) then return false end
	if not ipGroupsStatus then
		ipGroupsStatus = "working"
		CoroutineSleeper:new( loadIPGroupsWorker )
	end
	return ipGroupsStatus == "ready"
end
setTimer( loadIPGroupsIsReady, 1000, 1 )


-- Load all IP groups from "conf/IpToCountryCompact.csv"
function loadIPGroupsWorker ( cor )

	-- Maybe update file using the 'internet'
	checkForIp2cFileUpdate( cor )

	-- Read file
	unrelPosReset()
	local tick = getTickCount()
	local fileReader = FileLineReader:new( IP2C_FILENAME )
	while true do
		local line = fileReader:readLine()
		if not line then
			break
		end

		-- See if time to pause execution
		if getTickCount() > tick + 50 then
			cor:sleep(50)
			tick = getTickCount()
		end

		-- Parse line
		local parts = split( line, string.byte(',') )
		if #parts > 2 then
			local rstart = tonumber(parts[1])
			local rend = tonumber(parts[2])
			local rcountry = parts[3]

			-- Relative to absolute numbers
			rstart = unrelRange ( rstart )
			rend = unrelRange ( rend )

			-- Top byte is group
			local group = math.floor( rstart / 0x1000000 )

			-- Remove top byte from ranges
			rstart = rstart - group * 0x1000000
			rend = rend - group * 0x1000000

			if not aCountries[group] then
				aCountries[group] = {}
			end
			local count = #aCountries[group] + 1

			-- Add country/IP range to aCountries
			local buffer = ByteBuffer:new()
			buffer:writeInt24( rstart )
			buffer:writeInt24( rend )
			buffer:writeBytes( rcountry, 2 )
			aCountries[group][count] = buffer.data
		end
	end
	ipGroupsStatus = "ready"
	collectgarbage("collect")

	-- Update currently connected players
	for user,info in pairs( aPlayers ) do
		info["country"] = getPlayerCountry ( user )

		-- Send info to all admins
		for id, admin in ipairs(getElementsByType("player")) do
			if ( hasObjectPermissionTo ( admin, "general.adminpanel" ) ) then
				triggerClientEvent ( admin, "aClientPlayerJoin", user, false, false, false, false, false, aPlayers[user]["country"] )
			end
		end
	end

	return true
end

-- For squeezing data together
ByteBuffer = {
	new = function(self, indata)
		local newItem = { data = indata or "", readPos = 1 }
		return setmetatable(newItem, { __index = ByteBuffer })
	end,

	Copy = function(self)
		return ByteBuffer:new(self.data)
	end,

	-- Write
	writeInt24 = function(self,value)
		local b0 = math.floor(value / 1) % 256
		local b1 = math.floor(value / 256) % 256
		local b2 = math.floor(value / 65536) % 256
		self.data = self.data .. string.char(b0,b1,b2)
	end,

	writeBytes = function(self, chars, count)
		self.data = self.data .. string.sub(chars,1,count)
	end,

	-- Read
	readInt24 = function(self,value)
		local b0,b1,b2 = string.byte(self.data, self.readPos, self.readPos+2)
		self.readPos = self.readPos + 3
		return b0 + b1 * 256 + b2 * 65536
	end,

	readBytes = function(self, count)
		self.readPos = self.readPos + count
		return string.sub(self.data, self.readPos - count, self.readPos - 1)
	end,
}


-- Make a stream of absolute numbers relative to each other
local relPos = 0
function relPosReset()
	relPos = 0
end
function relRange( v )
	local rel = v - relPos
	relPos = v
	return rel
end

-- Make a stream of relative numbers absolute
local unrelPos = 0
function unrelPosReset()
	unrelPos = 0
end
function unrelRange( v )
	local unrel = v + unrelPos
	unrelPos = unrel
	return unrel
end


----------------------------------------------------------------------------------------
-- Check MTA HQ for possible update of IpToCountry file
----------------------------------------------------------------------------------------
function checkForIp2cFileUpdate( cor )
	-- Time for update?
	local timeNow = getRealTime().timestamp
	local lastUpdateTime = tonumber( get( "ip2cUpdateTime" ) ) or 0
	local timeSinceUpdate = timeNow - lastUpdateTime
	if ( timeSinceUpdate >= 0 and timeSinceUpdate < IP2C_UPDATE_INTERVAL_SECONDS ) then
		return	-- Not yet
	end

	set( "ip2cUpdateTime", timeNow )

	-- Get md5
	local fetchedMd5,errno = fetchRemoteContent( cor, IP2C_UPDATE_URL .. ".md5" );
	if errno ~= 0 then return end

	-- check md5 against current file
	local currentMd5 = md5( fileLoadContent( IP2C_FILENAME ) );
	if currentMd5 == string.upper(fetchedMd5) then
		return  -- We already have the latest file
	end

	-- Fetch remote ip2c file
	local fetchedCsv,errno = fetchRemoteContent( cor, IP2C_UPDATE_URL );
	if errno ~= 0 then return end

	-- Check download was correct
	local newMd5 = md5( fetchedCsv );
	if newMd5 ~= string.upper(fetchedMd5) then
		return  -- Download error, or md5 file incorrect
	end

	-- Update file
	fileSaveContent( IP2C_FILENAME, fetchedCsv );
end


----------------------------------------------------------------------------------------
-- Fetch remote content and wait for response
----------------------------------------------------------------------------------------
function fetchRemoteContent( cor, url )
	local dataOut,errnoOut = nil, nil
	if fetchRemote( url, 2, function(data,errno) dataOut=data errnoOut=errno end ) then
		while( errnoOut == nil ) do
			cor:sleep(50)
		end
	end
	return dataOut,errnoOut or -1
end

----------------------------------------------------------------------------------------
-- Load file contents to a string
----------------------------------------------------------------------------------------
function fileLoadContent( filename )
	local hFile = fileOpen( filename )
	if ( hFile ) then
		local data = fileRead( hFile, fileGetSize( hFile ) )
		fileClose( hFile )
		return data
	else
		return false
	end
end

----------------------------------------------------------------------------------------
-- Save a string to file
----------------------------------------------------------------------------------------
function fileSaveContent( filename, data )
	local hFile = fileCreate( filename )
	if ( hFile ) then
		fileWrite( hFile, data )
		fileClose( hFile )
		return true
	else
		return false
	end
end

----------------------------------------------------------------------------------------
-- FileLineReader
--   Read a file line by line
----------------------------------------------------------------------------------------
FileLineReader = {
	-- filename is file to read
	new = function(self, filename)
		local obj = setmetatable({}, { __index = FileLineReader })
		self.hFile = fileOpen( filename )
		self.buffer = ""
		return obj
	end,

	-- Close file
	close = function(self)
		if self.hFile then
			fileClose( self.hFile )
		end
		self.hFile = nil
	end,

	-- Read line. Return false if EOF
	readLine = function(self)
		if not self.hFile then return false end
		while true do
			local endpos = string.find(self.buffer, "\n")
			-- Found '\n' ?
			if endpos then
				local line = string.sub(self.buffer, 1, endpos - 1)
				self.buffer = string.sub(self.buffer, endpos + 1)
				return line
			end
			-- Get more bytes if possible
			if fileIsEOF( self.hFile ) then
				if string.len( self.buffer ) > 0 then
					-- Last line has no '\n'
					local line = self.buffer
					self.buffer = ""
					return line
				end
				self:close()
				return false
			end
			self.buffer = self.buffer .. fileRead( self.hFile, 500 )
		end
	end,
}

----------------------------------------------------------------------------------------
-- CoroutineSleeper
--   Wrapper for coroutine which can sleep and automatically resume
----------------------------------------------------------------------------------------
CoroutineSleeper = {
	-- myFunc is coroutine entry point
	new = function(self, myFunc, ...)
		local obj = setmetatable({}, { __index = CoroutineSleeper })
		-- Use inner function to call myFunc, so we can auto :detach when finished
    	obj.handle = coroutine.create( function(obj, ...)
											myFunc(obj, ...)
											obj:detach()
										end )
		coroutine.resume(obj.handle,obj, ...)
		return obj
	end,

	-- Remove ref to coroutine
	detach = function(self)
		self.handle = nil
	end,

	-- Check if still has ref to coroutine
	isAttached = function(self)
		return self.handle ~= nil
	end,

	-- Sleep for a bit, then automatically resume
	sleep = function(self, ms)
		if not self:isAttached() then return end
		setTimer( function()
    		if not self:isAttached() then return end
			local status = coroutine.status(self.handle)
			if (status == "suspended") then
				coroutine.resume(self.handle)
			elseif (status == "dead") then
				self.handle = nil
			end
		end, math.max( ms, 50 ), 1 )
		coroutine.yield()
	end,
}
