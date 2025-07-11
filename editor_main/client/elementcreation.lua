local elementDefinitions = {}

addEventHandler("doLoadEDF", root,
	function(definition, resourceName)
		elementDefinitions[resourceName] = definition.elements
	end
)

addEventHandler("doUnloadEDF", root,
	function(resourceName)
		elementDefinitions[resourceName] = nil
	end
)

triggerServerEvent("onClientRequestEDF", localPlayer)

-- sends the element creation request
function doCreateElement ( elementType, resourceName, creationParameters, attachLater, shortcut )
	creationParameters = creationParameters or {}
	if not creationParameters.position then
		local targetX, targetY, targetZ = processCameraLineOfSight()
		creationParameters.position = {targetX, targetY, targetZ + .5}
	end

	local requiresCreationBox = false
	for dataField, dataDefinition in pairs(elementDefinitions[resourceName][elementType].data) do
		-- if it is required, doesn't have a default, and we don't have an initial value, show the creation box
		if dataDefinition.required and not dataDefinition.default and not creationParameters[dataField] then
			requiresCreationBox = true
			break
		end
	end

	if requiresCreationBox then
		editor_gui.openPropertiesBox(elementType, resourceName)
	else
		creationParameters.interior = creationParameters.interior or getWorkingInterior()
		creationParameters.dimension = creationParameters.dimension or getWorkingDimension()

		if attachLater == nil then
			attachLater = true
		end
		if triggerEvent ( "onClientElementPreCreate", root, elementType, resourceName, creationParameters, attachLater, shortcut ) then
			triggerServerEvent( "doCreateElement", localPlayer, elementType, resourceName, creationParameters, attachLater, shortcut )
		end
	end
end

function doCloneElement ( element, attachMode )
	if getSelectedElement() then
		dropElement(true)
	end
	triggerServerEvent( "doCloneElement", element, attachMode )
end
