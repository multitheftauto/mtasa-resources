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
function getPlayerCountryName ( player )
	local ip = getPlayerIP ( player )
	local ip_group = tonumber ( gettok ( ip, 1, 46 ) )
	local ip_code = ( gettok ( ip, 1, 46 ) * 16777216 ) + ( gettok ( ip, 2, 46 ) * 65536 ) + ( gettok ( ip, 3, 46 ) * 256 ) + ( gettok ( ip, 4, 46 ) )
	if ( not aCountries[ip_group] ) then
		loadIPGroup ( ip_group )
	end
	for id, group in ipairs ( aCountries[ip_group] ) do
		if ( ( group.rstart <= ip_code ) and ( ip_code <= group.rend ) ) then
			return group.rcountryname
		end
	end
	return false
end

local CountryCodes = 
{
	["AC"]="Ascension Island",
	["AD"]="Andorra",
	["AE"]="United Arab Emirates",
	["AF"]="Afghanistan",
	["AG"]="Antigua And Barbuda",
	["AI"]="Anguilla",
	["AL"]="Albania",
	["AM"]="Armenia",
	["AN"]="Netherlands Antilles",
	["AO"]="Angola",
	["AQ"]="Antarctica",
	["AR"]="Argentina",
	["AS"]="American Samoa",
	["AT"]="Austria",
	["AU"]="Australia",
	["AW"]="Aruba",
	["AX"]="Aland Islands",
	["AZ"]="Azerbaijan",
	["BA"]="Bosnia And Herzegovina",
	["BB"]="Barbados",
	["BD"]="Bangladesh",
	["BE"]="Belgium",
	["BF"]="Burkina Faso",
	["BG"]="Bulgaria",
	["BH"]="Bahrain",
	["BI"]="Burundi",
	["BJ"]="Benin",
	["BM"]="Bermuda",
	["BN"]="Brunei Darussalam",
	["BO"]="Bolivia",
	["BR"]="Brazil",
	["BS"]="Bahamas",
	["BT"]="Bhutan",
	["BV"]="Bouvet Island",
	["BW"]="Botswana",
	["BY"]="Belarus",
	["BZ"]="Belize",
	["CA"]="Canada",
	["CC"]="Cocos (Keeling) Islands",
	["CD"]="Congo, The Democratic Republic Of The",
	["CF"]="Central African Republic",
	["CG"]="Congo",
	["CH"]="Switzerland",
	["CI"]="Cote D'ivoire",
	["CK"]="Cook Islands",
	["CL"]="Chile",
	["CM"]="Cameroon",
	["CN"]="China",
	["CO"]="Colombia",
	["CR"]="Costa Rica",
	["CS"]="Serbia and Montenegro",
	["CU"]="Cuba",
	["CV"]="Cape Verde",
	["CX"]="Christmas Island",
	["CY"]="Cyprus",
	["CZ"]="Czech Republic",
	["DE"]="Germany",
	["DJ"]="Djibouti",
	["DK"]="Denmark",
	["DM"]="Dominica",
	["DO"]="Dominican Republic",
	["DZ"]="Algeria",
	["EC"]="Ecuador",
	["EE"]="Estonia",
	["EG"]="Egypt",
	["EH"]="Western Sahara",
	["ER"]="Eritrea",
	["ES"]="Spain",
	["ET"]="Ethiopia",
	["EU"]="Europe",
	["FI"]="Finland",
	["FO"]="Faroe Islands",
	["FR"]="France",
	["GA"]="Gabon",
	["GB"]="United Kingdom",
	["GD"]="Grenada",
	["GL"]="Greenland",
	["GM"]="Gambia",
	["GW"]="Guinea-Bissau",
	["GY"]="Guyana",
	["HU"]="Hungary",
	["ID"]="Indonesia",
	["IE"]="Ireland",
	["IL"]="Israel",
	["IN"]="India",
	["IQ"]="Iraq",
	["IS"]="Iceland",
	["IT"]="Italy",
	["JA"]="Japan",
	["JM"]="Jamaica",
	["JP"]="Japan",
	["KW"]="Kuwait",
	["LT"]="Lithuania",
	["LU"]="Luxembourg",
	["LV"]="Latvia",
	["LY"]="Libyan Arab Jamahiriya",
	["MC"]="Monaco",
	["MG"]="Madagascar",
	["MH"]="Marshall Islands",
	["MIL"]="United States",
	["MT"]="Malta",
	["NG"]="Nigeria",
	["NL"]="Netherlands",
	["NO"]="Norway",
	["NR"]="Nauru",
	["PA"]="Panama",
	["PE"]="Peru",
	["PH"]="Philippines",
	["PK"]="Pakistan",
	["PL"]="Poland",
	["PR"]="Puerto Rico",
	["PS"]="Palestinian Territory, Occupied",
	["PT"]="Portugal",
	["QA"]="Qatar",
	["RE"]="Reunion",
	["RO"]="Romania",
	["RU"]="Russian Federation",
	["RW"]="Rwanda",
	["SE"]="Sweden",
	["SJ"]="Svalbard And Jan Mayen",
	["SL"]="Sierra Leone",
	["SO"]="Somalia",
	["SY"]="Syrian Arab Republic",
	["TD"]="Chad",
	["TO"]="Tonga",
	["TV"]="Tuvalu",
	["UA"]="Ukraine",
	["UK"]="United Kingdom",
	["UM"]="United States Minor Outlying Islands",
	["US"]="United States",
	["VN"]="Vietnam",
	["WF"]="Wallis And Futuna",
	["WS"]="Samoa",
	["YE"]="Yemen",
	["YT"]="Mayotte",
	["YU"]="Yugoslavia",
	["ZA"]="South Africa",
	["ZZ"]="None"
}
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
			aCountries[group][count].rcountryname = CountryCodes[rcountry]
			ranges = ranges + 1
		end
		xmlUnloadFile ( node )
	end
end