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
	local ip = getPlayerIP ( player )
	local ip_group = tonumber ( gettok ( ip, 1, 46 ) )
	local ip_code = ( gettok ( ip, 1, 46 ) * 16777216 ) + ( gettok ( ip, 2, 46 ) * 65536 ) + ( gettok ( ip, 3, 46 ) * 256 ) + ( gettok ( ip, 4, 46 ) )
	if ( not aCountries[ip_group] ) then
		loadIPGroup ( ip_group )
	end
	for id, group in ipairs ( aCountries[ip_group] ) do
		if ( ( group.rstart <= ip_code ) and ( ip_code <= group.rend ) ) then
			return group.rcountry
		end
	end
	return false
end

function loadIPGroup ( group )
	aCountries[group] = {}
	local node = xmlLoadFile ( "conf/ip2c/"..group..".xml" )
	if ( node ) then
		local ranges = 0
		while ( true ) do
			local range_node = xmlFindChild ( node, "range", ranges )
			if ( not range_node ) then break end
			local rstart = tonumber ( xmlNodeGetAttribute ( range_node, "start" ) )
			local rend = tonumber ( xmlNodeGetAttribute ( range_node, "end" ) )
			local rcountry = xmlNodeGetAttribute ( range_node, "country" )
			local count = #aCountries[group] + 1
			aCountries[group][count] = {}
			aCountries[group][count].rstart = rstart
			aCountries[group][count].rend = rend
			aCountries[group][count].rcountry = rcountry
			ranges = ranges + 1
		end
		xmlUnloadFile ( node )
	end
end