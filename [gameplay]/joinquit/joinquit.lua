local showColorCodes = true; 		-- Shows player's names colorcoded if set to true, and if set to false it doesn't
local defaultHexCode = "#FFFFFF"; 	-- Hex code for what color to output messages in (only used if showColorCodes is true)

countryName = { 
    ["AF"] = "Afghanistan", 
    ["AX"] = "Aland Islands", 
    ["AL"] = "Albania", 
    ["DZ"] = "Algeria", 
    ["AS"] = "American Samoa", 
    ["AD"] = "Andorra", 
    ["AO"] = "Angola", 
    ["AI"] = "Anguilla", 
    ["AQ"] = "Antarctica", 
    ["AG"] = "Antigua And Barbuda", 
    ["AR"] = "Argentina", 
    ["AM"] = "Armenia", 
    ["AW"] = "Aruba", 
    ["AU"] = "Australia", 
    ["AT"] = "Austria", 
    ["AZ"] = "Azerbaijan", 
    ["BS"] = "Bahamas", 
    ["BH"] = "Bahrain", 
    ["BD"] = "Bangladesh", 
    ["BB"] = "Barbados", 
    ["BY"] = "Belarus", 
    ["BE"] = "Belgium", 
    ["BZ"] = "Belize", 
    ["BJ"] = "Benin", 
    ["BM"] = "Bermuda", 
    ["BT"] = "Bhutan", 
    ["BO"] = "Bolivia", 
    ["BA"] = "Bosnia And Herzegovina", 
    ["BW"] = "Botswana", 
    ["BV"] = "Bouvet Island", 
    ["BR"] = "Brazil", 
    ["IO"] = "British Indian Ocean Territory", 
    ["BN"] = "Brunei Darussalam", 
    ["BG"] = "Bulgaria", 
    ["BF"] = "Burkina Faso", 
    ["BI"] = "Burundi", 
    ["KH"] = "Cambodia", 
    ["CM"] = "Cameroon", 
    ["CA"] = "Canada", 
    ["CV"] = "Cape Verde", 
    ["KY"] = "Cayman Islands", 
    ["CF"] = "Central African Republic", 
    ["TD"] = "Chad", 
    ["CL"] = "Chile", 
    ["CN"] = "China", 
    ["CX"] = "Christmas Island", 
    ["CC"] = "Cocos (Keeling) Islands", 
    ["CO"] = "Colombia", 
    ["KM"] = "Comoros", 
    ["CG"] = "Congo", 
    ["CD"] = "Congo, Democratic Republic", 
    ["CK"] = "Cook Islands", 
    ["CR"] = "Costa Rica", 
    ["CI"] = "Cote D'Ivoire", 
    ["HR"] = "Croatia", 
    ["CU"] = "Cuba", 
    ["CY"] = "Cyprus", 
    ["CZ"] = "Czech Republic", 
    ["DK"] = "Denmark", 
    ["DJ"] = "Djibouti", 
    ["DM"] = "Dominica", 
    ["DO"] = "Dominican Republic", 
    ["EC"] = "Ecuador", 
    ["EG"] = "Egypt", 
    ["SV"] = "El Salvador", 
    ["GQ"] = "Equatorial Guinea", 
    ["ER"] = "Eritrea", 
    ["EE"] = "Estonia", 
    ["ET"] = "Ethiopia", 
    ["FK"] = "Falkland Islands (Malvinas)", 
    ["FO"] = "Faroe Islands", 
    ["FJ"] = "Fiji", 
    ["FI"] = "Finland", 
    ["FR"] = "France", 
    ["GF"] = "French Guiana", 
    ["PF"] = "French Polynesia", 
    ["TF"] = "French Southern Territories", 
    ["GA"] = "Gabon", 
    ["GM"] = "Gambia", 
    ["GE"] = "Georgia", 
    ["DE"] = "Germany", 
    ["GH"] = "Ghana", 
    ["GI"] = "Gibraltar", 
    ["GR"] = "Greece", 
    ["GL"] = "Greenland", 
    ["GD"] = "Grenada", 
    ["GP"] = "Guadeloupe", 
    ["GU"] = "Guam", 
    ["GT"] = "Guatemala", 
    ["GG"] = "Guernsey", 
    ["GN"] = "Guinea", 
    ["GW"] = "Guinea-Bissau", 
    ["GY"] = "Guyana", 
    ["HT"] = "Haiti", 
    ["HM"] = "Heard Island & Mcdonald Islands", 
    ["VA"] = "Holy See (Vatican City State)", 
    ["HN"] = "Honduras", 
    ["HK"] = "Hong Kong", 
    ["HU"] = "Hungary", 
    ["IS"] = "Iceland", 
    ["IN"] = "India", 
    ["ID"] = "Indonesia", 
    ["IR"] = "Iran, Islamic Republic Of", 
    ["IQ"] = "Iraq", 
    ["IE"] = "Ireland", 
    ["IM"] = "Isle Of Man", 
    ["IL"] = "Israel", 
    ["IT"] = "Italy", 
    ["JM"] = "Jamaica", 
    ["JP"] = "Japan", 
    ["JE"] = "Jersey", 
    ["JO"] = "Jordan", 
    ["KZ"] = "Kazakhstan", 
    ["KE"] = "Kenya", 
    ["KI"] = "Kiribati", 
    ["KR"] = "Korea", 
    ["KW"] = "Kuwait", 
    ["KG"] = "Kyrgyzstan", 
    ["LA"] = "Lao People's Democratic Republic", 
    ["LV"] = "Latvia", 
    ["LB"] = "Lebanon", 
    ["LS"] = "Lesotho", 
    ["LR"] = "Liberia", 
    ["LY"] = "Libyan Arab Jamahiriya", 
    ["LI"] = "Liechtenstein", 
    ["LT"] = "Lithuania", 
    ["LU"] = "Luxembourg", 
    ["MO"] = "Macao", 
    ["MK"] = "Macedonia", 
    ["MG"] = "Madagascar", 
    ["MW"] = "Malawi", 
    ["MY"] = "Malaysia", 
    ["MV"] = "Maldives", 
    ["ML"] = "Mali", 
    ["MT"] = "Malta", 
    ["MH"] = "Marshall Islands", 
    ["MQ"] = "Martinique", 
    ["MR"] = "Mauritania", 
    ["MU"] = "Mauritius", 
    ["YT"] = "Mayotte", 
    ["MX"] = "Mexico", 
    ["FM"] = "Micronesia, Federated States Of", 
    ["MD"] = "Moldova", 
    ["MC"] = "Monaco", 
    ["MN"] = "Mongolia", 
    ["ME"] = "Montenegro", 
    ["MS"] = "Montserrat", 
    ["MA"] = "Morocco", 
    ["MZ"] = "Mozambique", 
    ["MM"] = "Myanmar", 
    ["NA"] = "Namibia", 
    ["NR"] = "Nauru", 
    ["NP"] = "Nepal", 
    ["NL"] = "Netherlands", 
    ["AN"] = "Netherlands Antilles", 
    ["NC"] = "New Caledonia", 
    ["NZ"] = "New Zealand", 
    ["NI"] = "Nicaragua", 
    ["NE"] = "Niger", 
    ["NG"] = "Nigeria", 
    ["NU"] = "Niue", 
    ["NF"] = "Norfolk Island", 
    ["MP"] = "Northern Mariana Islands", 
    ["NO"] = "Norway", 
    ["OM"] = "Oman", 
    ["PK"] = "Pakistan", 
    ["PW"] = "Palau", 
    ["PS"] = "Palestinian Territory, Occupied", 
    ["PA"] = "Panama", 
    ["PG"] = "Papua New Guinea", 
    ["PY"] = "Paraguay", 
    ["PE"] = "Peru", 
    ["PH"] = "Philippines", 
    ["PN"] = "Pitcairn", 
    ["PL"] = "Poland", 
    ["PT"] = "Portugal", 
    ["PR"] = "Puerto Rico", 
    ["QA"] = "Qatar", 
    ["RE"] = "Reunion", 
    ["RO"] = "Romania", 
    ["RU"] = "Russian Federation", 
    ["RW"] = "Rwanda", 
    ["BL"] = "Saint Barthelemy", 
    ["SH"] = "Saint Helena", 
    ["KN"] = "Saint Kitts And Nevis", 
    ["LC"] = "Saint Lucia", 
    ["MF"] = "Saint Martin", 
    ["PM"] = "Saint Pierre And Miquelon", 
    ["VC"] = "Saint Vincent And Grenadines", 
    ["WS"] = "Samoa", 
    ["SM"] = "San Marino", 
    ["ST"] = "Sao Tome And Principe", 
    ["SA"] = "Saudi Arabia", 
    ["SN"] = "Senegal", 
    ["RS"] = "Serbia", 
    ["SC"] = "Seychelles", 
    ["SL"] = "Sierra Leone", 
    ["SG"] = "Singapore", 
    ["SK"] = "Slovakia", 
    ["SI"] = "Slovenia", 
    ["SB"] = "Solomon Islands", 
    ["SO"] = "Somalia", 
    ["ZA"] = "South Africa", 
    ["GS"] = "South Georgia And Sandwich Isl.", 
    ["ES"] = "Spain", 
    ["LK"] = "Sri Lanka", 
    ["SD"] = "Sudan", 
    ["SR"] = "Suriname", 
    ["SJ"] = "Svalbard And Jan Mayen", 
    ["SZ"] = "Swaziland", 
    ["SE"] = "Sweden", 
    ["CH"] = "Switzerland", 
    ["SY"] = "Syrian Arab Republic", 
    ["TW"] = "Taiwan", 
    ["TJ"] = "Tajikistan", 
    ["TZ"] = "Tanzania", 
    ["TH"] = "Thailand", 
    ["TL"] = "Timor-Leste", 
    ["TG"] = "Togo", 
    ["TK"] = "Tokelau", 
    ["TO"] = "Tonga", 
    ["TT"] = "Trinidad And Tobago", 
    ["TN"] = "Tunisia", 
    ["TR"] = "Turkey", 
    ["TM"] = "Turkmenistan", 
    ["TC"] = "Turks And Caicos Islands", 
    ["TV"] = "Tuvalu", 
    ["UG"] = "Uganda", 
    ["UA"] = "Ukraine", 
    ["AE"] = "United Arab Emirates", 
    ["GB"] = "United Kingdom", 
    ["US"] = "United States", 
    ["UM"] = "United States Outlying Islands", 
    ["UY"] = "Uruguay", 
    ["UZ"] = "Uzbekistan", 
    ["VU"] = "Vanuatu", 
    ["VE"] = "Venezuela", 
    ["VN"] = "Viet Nam", 
    ["VG"] = "Virgin Islands, British", 
    ["VI"] = "Virgin Islands, U.S.", 
    ["WF"] = "Wallis And Futuna", 
    ["EH"] = "Western Sahara", 
    ["YE"] = "Yemen", 
    ["ZM"] = "Zambia", 
    ["ZW"] = "Zimbabwe", 
}

function getCountry()
    local country = exports.admin:getPlayerCountry(source)
    if type(country) == 'string' then
        return countryName[country] or 'N/A'
    end
    return 'N/A'
end

-- This function converts RGB colors to colorcodes like #ffffff
function RGBToHex(red, green, blue, alpha)

	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end


addEventHandler('onPlayerJoin', root,
	function()
		local getCountry = getCountry()
		if showColorCodes then
			outputChatBox(defaultHexCode .. '#FA8072* ' .. RGBToHex(getPlayerNametagColor(source)) .. getPlayerName(source) .. defaultHexCode .. ' #FA8072has joined the game. (#FFFFFF'..getCountry..'#FA8072)', root, 255, 100, 100, true)
		else
			outputChatBox('* ' .. getPlayerName(source) .. ' has joined the game', 255, 100, 100)
		end

	end
)


addEventHandler('onPlayerChangeNick', root,
	function(oldNick, newNick, countryName)
		if showColorCodes then
			outputChatBox(defaultHexCode .. '#FA8072* ' .. RGBToHex(getPlayerNametagColor(source)) .. oldNick .. defaultHexCode .. '#FA8072 is now known as (' .. RGBToHex(getPlayerNametagColor(source)) .. newNick .."#FA8072)", root, 255, 100, 100, true)
		else
			outputChatBox('* ' .. oldNick .. ' is now known as ' .. newNick, root, 255, 100, 100)
		end
	end
)


addEventHandler('onPlayerQuit', root,
	function(reason)
		local getCountry = getCountry()
		if showColorCodes then
			outputChatBox(defaultHexCode .. '#FA8072* ' .. RGBToHex(getPlayerNametagColor(source)) .. getPlayerName(source) .. defaultHexCode .. '#FA8072 has left the game [#FFFFFF' .. reason .. '#FA8072]', root, 255, 100, 100, true)
		else
			outputChatBox('* ' .. getPlayerName(source) .. ' has left the game [' .. reason .. ']', root, 255, 100, 100)
		end
	end
)
