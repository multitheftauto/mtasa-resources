-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

function verifyRadioStreamURL(streamURL)
	local urlType = type(streamURL)
	local urlString = (urlType == "string")

	if (not urlString) then
		return false
	end

	local urlLength = utf8.len(streamURL)
	local urlValidLength = (urlLength <= RADIO_STREAM_URL_MAX_LENGTH)

	if (not urlValidLength) then
		return false
	end

	local urlHttp = utf8.find(streamURL, "http")

	if (not urlHttp) then
		return false
	end

	return true
end