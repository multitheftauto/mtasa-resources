function import ( resource, cmd, resourceString )
	if type(resource) == "string" then
		resource = getResourceFromName(resource)
	end
	if type(resourceString) == "string" then
		resource = getResourceFromName(resourceString)
	end
	if not resource then
		outputDebugString("editor: Bad argument to 'import'",0,255,255,255)
		return false
	end

	local rootElement
	if isElement(resource) then
		rootElement = resource
	else
		for k,v in pairs(getResources()) do
			if v == resource then
				rootElement = getResourceRootElement(resource)
				break
			end
		end
	end
	if not rootElement then
		return false
	end

	for creatorResource, dataTable in pairs(loadedEDF) do
		for elementType in pairs(dataTable.elements) do
			for i,element in ipairs(getElementsByType(elementType,rootElement)) do
				triggerEvent( "doCloneElement", element, false, creatorResource)
			end
		end
	end

	return true
end
addCommandHandler("import",import)

