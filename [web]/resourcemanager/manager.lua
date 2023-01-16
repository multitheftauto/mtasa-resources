local mta_getResourceInfo = getResourceInfo

function getResourcesSearch ( partialName, state )
    local allResources = getResources()

	local listChunk = {}
	local stateChunk = {}

	for k,v in ipairs(allResources) do
		local resourceName = getResourceName(v)
		local resourceState = getResourceState(v)
		if ( (partialName == "" or string.find(resourceName, partialName)) and (state == "" or state == resourceState) ) then
			table.insert(listChunk, v)
			table.insert(stateChunk, resourceState)
		end
	end

	return listChunk, stateChunk
end

function getResourceInfo ( resource )

	local failreason =  getResourceLoadFailureReason ( resource )
	local state = getResourceState ( resource )
	local startTimestamp = getResourceLastStartTime(resource)
	local startTime = type(startTimestamp) == "number" and os.date("%Y-%m-%d %X", startTimestamp) or "Never"
	local loadTimestamp = getResourceLoadTime(resource)
	local loadTime = type(loadTimestamp) == "number" and os.date("%Y-%m-%d %X", loadTimestamp) or "Never"
	local author =  mta_getResourceInfo ( resource, "author" )
	local version = mta_getResourceInfo ( resource, "version" )
	return {state=state, failurereason=failreason, starttime=startTime, loadtime=loadTime, author=author, version=version}
end
