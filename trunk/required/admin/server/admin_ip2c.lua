--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_ip2c.lua
*
*	Original File by lil_Toady
*
**************************************]]

aCountries = {}


function getPlayerCountry ( player )
	return getIpCountry ( getPlayerIP ( player ) )
end
function getIpCountry ( ip )
	local ip_group = tonumber ( gettok ( ip, 1, 46 ) )
	local ip_code = ( gettok ( ip, 1, 46 ) * 16777216 ) + ( gettok ( ip, 2, 46 ) * 65536 ) + ( gettok ( ip, 3, 46 ) * 256 ) + ( gettok ( ip, 4, 46 ) )
	if ( #aCountries == 0 ) then
		loadIPGroups ()
	end
	if ( not aCountries[ip_group] ) then
		aCountries[ip_group] = {}
	end
	for id, group in ipairs ( aCountries[ip_group] ) do
		if ( ( group.rstart <= ip_code ) and ( ip_code <= group.rend ) ) then
			return group.rcountry
		end
	end
	return false
end


-- Load all IP groups from "conf/IpToCountryCompact.csv"
function loadIPGroups ()
	unrelPosReset()

	local readFilename = "conf/IpToCountryCompact.csv";
	local hReadFile = fileOpen( readFilename, true )
	if not hReadFile then
		outputHere ( "Cannot read " .. readFilename )
		return
	end

	local buffer = ""
	while true do
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

			local parts = split( line, string.byte(',') )
			if #parts > 2 then
				local rstart = tonumber(parts[1])
				local rend = tonumber(parts[2])
				local rcountry = parts[3]

				-- Relative to absolute numbers
				rstart = unrelRange ( rstart )
				rend = unrelRange ( rend )

				local group = math.floor( rstart / 0x1000000 )

				if not aCountries[group] then
					aCountries[group] = {}
				end
				local count = #aCountries[group] + 1
				aCountries[group][count] = {}
				aCountries[group][count].rstart = rstart
				aCountries[group][count].rend = rend
				aCountries[group][count].rcountry = rcountry
			end
		end
	end

	fileClose(hReadFile)
end



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

		local buffer = ""
		while true do

			if ( getTickCount() > tick + 50 ) then
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
						-- Absolute to relative numbers
						rstart = relRange( rstart )
						rend = relRange( rend )
						-- Output line
						fileWrite( hWriteFile, rstart .. "," .. rend .. "," .. rcountry .. "\n" )
					end
				end
			end
		end

		fileClose(hWriteFile)
		fileClose(hReadFile)
		outputHere ( "makeCompactCsv done" )
	end


	function ipTestDo( ip )
		local country = getIpCountry ( ip )
		outputHere ( "ip " .. ip .. " is in " .. tostring(country) )
	end

	function ipTest()
		ipTestDo ( "46.1.2.3" )
		ipTestDo ( "88.1.2.3" )
		ipTestDo ( "46.208.74.201" )
		ipTestDo ( "102.1.2.3" )
	end

	addCommandHandler ( "iptest", ipTest )
end
