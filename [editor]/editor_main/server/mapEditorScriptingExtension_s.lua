-- FILE: 	mapEditorScriptingExtension_s.lua
-- PURPOSE:	Prevent the map editor feature set being limited by what MTA can load from a map file by adding a script file to maps
-- VERSION:	RemoveWorldObjects (v1)

function onResourceStartOrStop ( )
	for _, object in ipairs ( getElementsByType ( "removeWorldObject", source ) ) do
		local model = getElementData ( object, "model" )
		local lodModel = getElementData ( object, "lodModel" )
		local posX = getElementData ( object, "posX" )
		local posY = getElementData ( object, "posY" )
		local posZ = getElementData ( object, "posZ" )
		local interior = getElementData ( object, "interior" )
		local radius = getElementData ( object, "radius" )
		if ( eventName == "onResourceStart" ) then
			removeWorldModel ( model, radius, posX, posY, posZ, interior )
			removeWorldModel ( lodModel, radius, posX, posY, posZ, interior )
		else
			restoreWorldModel ( model, radius, posX, posY, posZ, interior )
			restoreWorldModel ( lodModel, radius, posX, posY, posZ, interior )
		end
	end
end
addEventHandler ( "onResourceStart", resourceRoot, onResourceStartOrStop )
addEventHandler ( "onResourceStop", resourceRoot, onResourceStartOrStop )