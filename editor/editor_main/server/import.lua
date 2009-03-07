function import ( resource )
	if type(resource) == "string" then
		resource = getResourceFromName(resource)
	end
	if not resource then
		outputDebugString("editor: Bad argument to 'import'",0,255,255,255)
		return false
	end
	local found
	for k,v in pairs(getResources()) do
		if v == resource then
			found = true
			break
		end
	end
	if not found then
		outputDebugString("editor: Bad argument to 'import'",0,255,255,255)
		return false	
	end
	local newElements = {}
	local resourceRoot = getResourceRootElement(resource)
	if not resourceRoot then
		return false
	end
	for creatorResource, dataTable in pairs(loadedEDF) do
		for elementType in pairs(dataTable.elements) do
			for i,element in ipairs(getElementsByType(elementType,resourceRoot)) do
				triggerEvent( "doCloneElement", element, false, creatorResource)
			end
		end
	end
	return true
end
addCommandHandler("import",import)