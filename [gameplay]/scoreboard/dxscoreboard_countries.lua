if get("showCountries") == "true" then
	local countryData = "Country"
	local ip2cRunning = false

	addEventHandler("onResourceStart", resourceRoot, function()
		local ip2c = getResourceFromName("ip2c")
		if ip2c then
			local state = getResourceState(ip2c)
			if (state == "running") or (state == "loaded" and startResource(ip2c)) then
				ip2cRunning = true

				addEventHandler("onResourceStop", getResourceRootElement(ip2c), function()
					ip2cRunning = false
				end)
			end
		else
			print("ERROR: `showCountries` enabled in "..getResourceName(getThisResource())..", but ip2c resource not running!")
		end

		for i, player in ipairs(getElementsByType("player")) do
			local country = ip2cRunning and exports.ip2c:getPlayerCountry(player) or false
			if country then
				setElementData(player, countryData, {":ip2c/flags/"..country.code:lower()..".png", country.code})
			end
		end

		addEvent("onPlayerCountryFetched", true)
		addEventHandler("onPlayerCountryFetched", root, function(country)
			setElementData(source, countryData, {":ip2c/flags/"..country.code:lower()..".png", country.code})
		end)
	end)
end

-- Server staff can use the below command to spoof their country-code in TAB scoreboard to avoid undesired recognition by players.
-- Don't be too obvious, it's advised to pick a country close to your own (to simulate a realistic client > server ping for said country)
addCommandHandler("setcountry",
	function(thePlayer, command, country_code)
		local player_account = getPlayerAccount(thePlayer)
		if not player_account then
			outputChatBox("* You're not logged in.", thePlayer, 255, 100, 100)
			return false
		end
		local account_name = getAccountName(player_account)
		if not isObjectInACLGroup("user."..account_name, aclGetGroup("Admin")) and isObjectInACLGroup("user."..account_name, aclGetGroup("Moderator")) then
			outputChatBox("* You don't have permission to do that.", thePlayer, 255, 100, 100)
			return false
		end
		if not country_code then
			outputChatBox("* Usage: /setcountry countrycode", thePlayer, 255, 100, 100)
			outputChatBox("* Example: /setcountry ru", thePlayer, 255, 100, 100)
			return false
		end
		country_code = string.lower(country_code)
		local img = ":ip2c/flags/"..country_code..".png"
		if not fileExists(img) then
			outputChatBox("* Sorry, '"..country_code.."' is not an existing country code.", thePlayer, 255, 100, 100)
			return false
		end
		country_code = string.upper(country_code)
		setElementData(thePlayer, "Country", {img, country_code})
		outputChatBox("* Your country has been set to "..country_code.."!", thePlayer, 100, 255, 100)
		return true
	end
)
