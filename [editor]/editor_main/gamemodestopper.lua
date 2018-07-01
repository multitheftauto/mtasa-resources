function isResourceRunning(res)
	return getResourceState(res)=="running"
end

function isGamemode(res)
	return exports.mapmanager:isGamemode(res)
end

function isMap(res)
	return exports.mapmanager:isMap(res)
end

addEventHandler("onResourceStart", getResourceRootElement(),
	function()
		for index,resource in ipairs(getResources()) do
			if isResourceRunning(resource) and (isGamemode(resource) or isMap(resource)) then
				if hasObjectPermissionTo(getThisResource(), "function.stopResource") then
					stopResource(resource)
				else
					outputDebugString("Editor: Unable to stop running gamemodes (no access to function.stopResource)")
					return
				end
			end
		end
	end
)
