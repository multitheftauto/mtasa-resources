errorCode = {}

local function loadAdditionalErrorCodes()
	-- Load error codes from votemanager resource if it's running
	local votemanagerResource = getResourceFromName("votemanager")
	if (votemanagerResource) then
		if (getResourceState(votemanagerResource) == "running") then
			local votemanagerErrorCodes = exports.votemanager:getErrorCodes()
			if (votemanagerErrorCodes) and (type(votemanagerErrorCodes) == "table") then
				for key, code in pairs(votemanagerErrorCodes) do
					-- If the error code is not defined here already, then set it
					if (errorCode[key] == nil) then
						errorCode[key] = code
					end
				end
			else
				outputDebugString("Could not load error codes from votemanager because it returned '" .. tostring(votemanagerErrorCodes) .. "' [" .. type(votemanagerErrorCodes) .. "]. Expected a table.", 1)
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
