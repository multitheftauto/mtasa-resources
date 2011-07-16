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
local makeCor

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
	if ( #aCountries == 0 and not makeCor) then
    	makeCor = coroutine.create(loadIPGroupsWorker)
    	coroutine.resume(makeCor)
	end
	return makeCor == nil
end
setTimer( loadIPGroupsIsReady, 1000, 1 )

-- Load all IP groups from "conf/IpToCountryCompact.csv"
function loadIPGroupsWorker ()
	unrelPosReset()

	local readFilename = "conf/IpToCountryCompact.csv";
	local hReadFile = fileOpen( readFilename, true )
	if not hReadFile then
		outputHere ( "Cannot read " .. readFilename )
		return
	end

	local buffer = ""
	local tick = getTickCount()
	while true do
		local endpos = string.find(buffer, "\n")

		if makeCor and ( getTickCount() > tick + 50 ) then
			-- Execution exceeded 50ms so pause and resume in 50ms
			setTimer(function()
				local status = coroutine.status(makeCor)
				if (status == "suspended") then
					coroutine.resume(makeCor)
				elseif (status == "dead") then
					makeCor = nil
				end
			end, 50, 1)
			coroutine.yield()
			tick = getTickCount()
		end
		
		-- If can't find CR, try to load more from the file
		if not endpos then
			if fileIsEOF( hReadFile ) then
				break
			end
			buffer = buffer .. fileRead( hReadFile, 500 )
		end

		if endpos then
			-- Process line
			local line = string.sub(buffer, 1, endpos - 1)
			buffer = string.sub(buffer, endpos + 1)

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
	end
	fileClose(hReadFile)
	makeCor = nil
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


-- IP2C logging
function outputHere( msg )
	--outputServerLog ( msg )
	outputChatBox ( msg )
end


----------------------------------------------------------------------------------------
--
-- Set to true to enable commands "makecsv" and "iptest"
--
----------------------------------------------------------------------------------------
local makeAndTestCompactCsv = false


if makeAndTestCompactCsv then

	local makeCor

	-- Takes a 'IPV4 CSV' file sourced from http://software77.net/geo-ip/
	-- and makes a smaller one for use by Admin
	addCommandHandler ( "makecsv",
		function ()
			local status = makeCor and coroutine.status(makeCor)
			if (status == "suspended") then
				outputHere( "Please wait" )
				return
			end
			makeCor = coroutine.create ( makeCompactCsvWorker )
			coroutine.resume ( makeCor )
		end
	)


	function makeCompactCsvWorker ()
		outputHere ( "makeCompactCsv started" )
		relPosReset()

		local readFilename = "conf/IpToCountry.csv";
		local hReadFile = fileOpen( readFilename, true )
		if not hReadFile then
			outputHere ( "Cannot read " .. readFilename )
			return
		end

		local writeFilename = "conf/IpToCountryCompact.csv";
		local hWriteFile = fileCreate( writeFilename, true )
		if not hWriteFile then
			fileClose(hReadFile)
			outputHere ( "Cannot create " .. writeFilename )
			return
		end

		local tick = getTickCount()

		local cur = {}
		local buffer = ""
		while true do

			if ( makeCor and getTickCount() > tick + 50 ) then
				-- Execution exceeded 50ms so pause and resume in 50ms
				setTimer(function()
					local status = coroutine.status(makeCor)
					if (status == "suspended") then
						coroutine.resume(makeCor)
					elseif (status == "dead") then
						makeCor = nil
					end
				end, 50, 1)
				coroutine.yield()
				tick = getTickCount()
			end

			local endpos = string.find(buffer, "\n")

			-- If can't find CR, try to load more from the file
			if not endpos then
				if fileIsEOF( hReadFile ) then
					break
				end
				buffer = buffer .. fileRead( hReadFile, 500 )
			end

			if endpos then
				-- Process line
				local line = string.sub(buffer, 1, endpos - 1)
				buffer = string.sub(buffer, endpos + 1)

				-- If not a comment line
				if string.sub(line,1,1) ~= '#' then
					-- Parse out required fields
					local _,_,rstart,rend,rcountry = string.find(line, '"(%w+)","(%w+)","%w+","%w+","(%w+)"' )
					if rcountry then

						rstart = tonumber(rstart)
						rend = tonumber(rend)

						--
						-- Save memory by joining ranges here
						--
						local group = math.floor( rstart / 0x1000000 )
						if group == cur.group and rstart == cur.rend + 1 and rcountry == cur.rcountry then
							-- We can extend previous range
							cur.rend = rend
						else
							-- Otherwise flush previous range
							writeCountryRange(hWriteFile, cur.rstart, cur.rend, cur.rcountry)
							-- and start a new one
							cur.group = group
							cur.rstart = rstart
							cur.rend = rend
							cur.rcountry = rcountry
						end
					end
				end
			end
		end
		-- Flush last range
		writeCountryRange(hWriteFile, cur.rstart, cur.rend, cur.rcountry)
		fileClose(hWriteFile)
		fileClose(hReadFile)
		outputHere ( "makeCompactCsv done" )
	end

	function writeCountryRange(hWriteFile, rstart, rend, rcountry)
		if not rstart then return end
		-- Absolute to relative numbers
		rstart = relRange( rstart )
		rend = relRange( rend )
		-- Output line
		fileWrite( hWriteFile, rstart .. "," .. rend .. "," .. rcountry .. "\n" )
	end

	function ipTestDo( c, ip )
		local country = getIpCountry ( ip )
		outputHere ( "ip " .. ip .. " is in " .. tostring(country) .. " (Expected " .. c .. ")" )
	end

	function ipTest()
		ipTestDo ( "DE", "46.1.2.3" )
		ipTestDo ( "ES", "88.1.2.3" )
		ipTestDo ( "FR", "109.1.2.3" )
		ipTestDo ( "AR", "190.1.2.3" )
		ipTestDo ( "AU", "203.1.2.3" )
	end

	addCommandHandler ( "iptest", ipTest )
end
