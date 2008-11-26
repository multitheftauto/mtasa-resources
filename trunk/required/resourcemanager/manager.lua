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
    local starttime = getResourceLastStartTime ( resource )
    local loadtime = getResourceLoadTime ( resource )
	local author =  mta_getResourceInfo ( resource, "author" )
	local version = mta_getResourceInfo ( resource, "version" )
    return {state=state, failurereason=failreason, starttime=starttime, loadtime=loadtime, author=author, version=version}
end