function onWorldObjectCreateOrDestroy ( )
	if ( getElementType ( source ) == "removeWorldObject" ) then
		local model = getElementData ( source, "model" )
		local lodModel = getElementData ( source, "lodModel" )
		local posX = getElementData ( source, "posX" )
		local posY = getElementData ( source, "posY" )
		local posZ = getElementData ( source, "posZ" )
		local interior = getElementData ( source, "interior" )
		local radius = getElementData ( source, "radius" )
		if ( eventName == "onElementCreate" ) then
			removeWorldModel ( model, radius, posX, posY, posZ, interior )
			removeWorldModel ( lodModel, radius, posX, posY, posZ, interior )
		else
			restoreWorldModel ( model, radius, posX, posY, posZ, interior )
			restoreWorldModel ( lodModel, radius, posX, posY, posZ, interior )
		end
	end
end
addEventHandler ( "onElementCreate", root, onWorldObjectCreateOrDestroy )
addEventHandler ( "onElementDestroy", root, onWorldObjectCreateOrDestroy )

function applyWorldObjectRemoval()
	for index, element in ipairs(getElementsByType("removeWorldObject")) do
		local model = getElementData ( element, "model" )
		local lodModel = getElementData ( element, "lodModel" )
		local posX = getElementData ( element, "posX" )
		local posY = getElementData ( element, "posY" )
		local posZ = getElementData ( element, "posZ" )
		local interior = getElementData ( element, "interior" )
		local radius = getElementData ( element, "radius" )
		removeWorldModel ( model, radius, posX, posY, posZ, interior )
		removeWorldModel ( lodModel, radius, posX, posY, posZ, interior )
	end
end
addEvent("editor.fullTestEnded", false)
addEventHandler("editor.fullTestEnded", root, function() setTimer(applyWorldObjectRemoval, 1000, 1) end) -- Timer is required
