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
	local isAdminResourceRunning = getResourceFromName( "admin" )
	isAdminResourceRunning = isAdminResourceRunning and getResourceState( isAdminResourceRunning ) == "running"

	local countryData = "Country"
	local defaultCountryIndicator = "N/A" -- If something somehow fails and setting is enabled in meta.xml

	for i, player in ipairs( getElementsByType( "player" ) ) do
		local cCode = isAdminResourceRunning and exports.admin:getPlayerCountry( player ) or defaultCountryIndicator
		setElementData( player, countryData, {":admin/client/images/flags/" .. cCode:lower() .. ".png", cCode} )
	end

	function setScoreboardData()
		local cCode = isAdminResourceRunning and exports.admin:getPlayerCountry( source ) or defaultCountryIndicator
		setElementData( source, countryData, {":admin/client/images/flags/" .. cCode:lower() .. ".png", cCode} )
	end

	addEventHandler( "onPlayerJoin", getRootElement(), setScoreboardData )
end
