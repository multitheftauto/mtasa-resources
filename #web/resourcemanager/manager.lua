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
    local starttime = getRealTimes(getResourceLastStartTime ( resource ))
    local loadtime = getRealTimes(getResourceLoadTime ( resource ))
	local author =  mta_getResourceInfo ( resource, "author" )
	local version = mta_getResourceInfo ( resource, "version" )
    return {state=state, failurereason=failreason, starttime=starttime, loadtime=loadtime, author=author, version=version}
end

function getRealTimes(sek)
	if sek == "never" then return "Never" end
	local time = getRealTime(sek)
	if time.hour < 10 then time.hour = "0"..time.hour end
	if time.minute < 10 then time.minute = "0"..time.minute end
	if time.second < 10 then time.second = "0"..time.second end
	if time.month+1 < 10 then time.month = "0"..(time.month+1) end
	if time.monthday < 10 then time.monthday = "0"..time.monthday end
	
	return (time.year+1900).."-"..time.month.."-"..time.monthday.." "..time.hour..":"..time.minute..":"..time.second
end