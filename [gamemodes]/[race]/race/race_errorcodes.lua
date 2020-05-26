errorCode = {}

local function loadAdditionalErrorCodes()
	-- Load error codes from votemanager resource if it's running
	local votemanagerResource = getResourceFromName("votemanager")
	if (votemanagerResource) then
		if (getResourceState(votemanagerResource) == "running") then
			local votemanagerErrorCodes = exports.votemanager:getErrorCodes()

			assert(type(votemanagerErrorCodes) == "table", "Error codes returned from votemanager are not of table type. Got [" .. type(votemanagerErrorCodes) .. "].")

			for key, code in pairs(votemanagerErrorCodes) do
				-- If the error code is defined already, error out
				assert(errorCode[key] == nil, "Error code conflict! Error code '" .. key .. "' already defined in race!")
				errorCode[key] = code
			end
		else
			outputDebugString("Could not load error codes from votemanager because it is not running.", 1)
		end
	else
		outputDebugString("Could not load error codes from votemanager because it is not available.", 1)
	end
end
if (localPlayer) then
	addEventHandler("onClientResourceStart", resourceRoot, loadAdditionalErrorCodes)
else
	addEventHandler("onResourceStart", resourceRoot, loadAdditionalErrorCodes)
end
