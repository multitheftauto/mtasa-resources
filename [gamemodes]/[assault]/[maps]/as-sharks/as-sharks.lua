function player_Spawn (  )
	setPedStat ( source, 225, 999 )
	--outputChatBox ( "called for "..getClientName ( source ) )
	skin = getElementModel ( source )
	noshark = getAttachedElements ( source )
	for k,v in pairs(noshark) do
		if getElementType ( v ) == "object" then
			destroyElement ( v )
		end
	end
	if ( skin == 124 ) then
		local x,y,z = getElementPosition ( source )
		shark = createObject ( 1608, x, y, z )
		attachElements ( shark, source, 0, 0, -0.4, 0.000000, 0.000000, 0.000000 )
		setElementAlpha( source, 0 )
		--toggleControl ( source, "jump", false )
	else
		setElementAlpha( source, 255 )
		--toggleControl ( source, "jump", true )
	end
end
-- add the player_Spawn function as a handler for onPlayerSpawn
addEventHandler ( "onPlayerSpawn", getRootElement(), player_Spawn )

function player_Quit (  )
	noshark = getAttachedElements ( source )
	for k,v in pairs(noshark) do
		if getElementType ( v ) == "object" then
			destroyElement ( v )
		end
	end
end
addEventHandler ( "onPlayerQuit", getRootElement(), player_Quit )


function thisResourceStop ()
	for k,v in pairs(getElementsByType ( "player" )) do
		setElementAlpha ( v, 255 )
		setPedStat ( v, 225, 1 )
	end
	setGameSpeed ( 1 )
end
addEventHandler ( "onResourceStop", getResourceRootElement(getThisResource()), thisResourceStop )
