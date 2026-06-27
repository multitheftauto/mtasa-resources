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

function getRandomRotation()
	if exports["editor_gui"]:sx_getOptionData("randomizeRotation") ~= true then
		return {0, 0, 0}
	end

	local getAxis = exports["editor_gui"]:sx_getOptionData("randomizeRotationAxis")
	local rotationMap = {
		["X"] = function() return {math.random(0, 360), 0, 0} end,
		["Y"] = function() return {0, math.random(0, 360), 0} end,
		["Z"] = function() return {0, 0, math.random(0, 360)} end,
		["XY"] = function() return {math.random(0, 360), math.random(0, 360), 0} end,
		["XZ"] = function() return {math.random(0, 360), 0, math.random(0, 360)} end,
		["YZ"] = function() return {0, math.random(0, 360), math.random(0, 360)} end,
		["XYZ"] = function() return {math.random(0, 360), math.random(0, 360), math.random(0, 360)} end,
	}

	local rotationFunc = rotationMap[getAxis] or function() return {0, 0, 0} end
	return rotationFunc()
end

-- sends the element creation request
function doCreateElement ( elementType, resourceName, creationParameters, attachLater, shortcut )
	creationParameters = creationParameters or {}
	if not creationParameters.position then
		local targetX, targetY, targetZ = processCameraLineOfSight()
		if elementType ~= "object" and elementType ~= "vehicle" then
			creationParameters.position = nil
		else
			creationParameters.position = {targetX, targetY, targetZ + .5}
		end
		creationParameters.rotation = getRandomRotation()
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
	local rotationData
	if exports["editor_gui"]:sx_getOptionData("randomizeRotation") == true then
		rotationData = getRandomRotation()
	end
	triggerServerEvent( "doCloneElement", element, attachMode, false, rotationData )
end
