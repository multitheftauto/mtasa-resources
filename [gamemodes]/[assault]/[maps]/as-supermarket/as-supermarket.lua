function player_Spawn (  )
	--outputChatBox ( "called for "..getClientName ( source ) )
	skin = getElementModel ( source )
	notrolley = getAttachedElements ( source )
	for k,v in pairs(notrolley) do
		if getElementType ( v ) == "object" then
			destroyElement ( v )
		end
	end
	if ( skin ~= 217 ) then
		local x,y,z = getElementPosition ( source )
		trolley = createObject ( 1349, x, y, z, 0, 0, 0 )
		attachElements ( trolley, source, 0, 1.0, -0.45, 0.000000, 0.000000, 90 )
		toggleControl ( source, "jump", false )
	else
		setElementAlpha( source, 255 )
		toggleControl ( source, "jump", true )
	end
end
-- add the player_Spawn function as a handler for onPlayerSpawn
addEventHandler ( "onPlayerSpawn", getRootElement(), player_Spawn )

function player_Quit (  )
	notrolley = getAttachedElements ( source )
	for k,v in pairs(notrolley) do
		if getElementType ( v ) == "object" then
			destroyElement ( v )
		end
	end
end
addEventHandler ( "onPlayerQuit", getRootElement(), player_Quit )
