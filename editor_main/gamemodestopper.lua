function isResourceRunning(res)
	return getResourceState(res) == "running"
end

function isGamemode(res)
	return exports.mapmanager:isGamemode(res)
end

function isMap(res)
	return exports.mapmanager:isMap(res)
end

function onResourceStart(startedResource)
	if not hasObjectPermissionTo(startedResource, "function.stopResource") then
		outputDebugString("Editor: Unable to stop running gamemodes (no access to function.stopResource)")

		return false
	end

	local resourcesTable = getResources()

	for resourceID = 1, #resourcesTable do
		local resourceElement = resourcesTable[resourceID]

		if isResourceRunning(resourceElement) then
			local gamemodeOrMap = isGamemode(resourceElement) or isMap(resourceElement)

			if gamemodeOrMap then
				stopResource(resourceElement)
			end
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)