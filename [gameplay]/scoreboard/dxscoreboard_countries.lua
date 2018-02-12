function toboolean( bool )
	bool = tostring( bool )
	if bool == "true" then
		return true
	elseif bool == "false" then
		return false
	else
		return nil
	end
end

showCountries = toboolean( get( "showCountries" ) ) or false

if showCountries then
local countryData = "Country"
local defaultCountryIndicator = "US" --If something somehow fails and setting is enabled in meta.xml
	for i,players in ipairs(getElementsByType("player")) do
		local cCode = exports.admin:getPlayerCountry(players)
		setElementData(players,countryData,{":admin/client/images/flags/"..string.lower(cCode or defaultCountryIndicator)..".png",cCode or defaultCountryIndicator})
	end

	function setScoreboardData ()
		local cCode = exports.admin:getPlayerCountry(source)
		setElementData(source, countryData,{":admin/client/images/flags/"..string.lower(cCode or defaultCountryIndicator)..".png",cCode or defaultCountryIndicator})
	end
addEventHandler("onPlayerJoin", getRootElement(), setScoreboardData)
end
