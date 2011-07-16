function getResourcesByState ( state )
    local allResources = getResources()
	local matchingResources = {}
	
	for theKey, theResource in pairs(allResources) do
        if ( getResourceState ( theResource ) == state ) then
            local visible = getResourceInfo ( theResource, "showInResourceBrowser" )
            if visible == "true" or visible == "yes" then
				table.insert(matchingResources, {resource=theResource, description=getResourceInfo(theResource, "description"), name=getResourceInfo(theResource, "name"), pages=getResourceInfo(theResource, "pages"), noDefaultPage=getResourceInfo(theResource, "noDefaultPage")} )
			end
        end
	end

    return matchingResources
end