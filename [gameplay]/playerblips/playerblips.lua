blips = {}

function createBlips()
  	for i, player in ipairs( getElementsByType ( "player" ) ) do
		if ( not isPlayerDead( player ) ) then
			local r, g, b = getTeamColor( getPlayerTeam( player ) )
			if ( not blips[player] ) then
				blips[player] = createBlipAttachedTo( player, 0, 2, r, g, b, 255 )
			else
				setBlipColor( blips[player], r, g, b, 255 )
			end
		end
	end
end
addEventHandler( "onResourceStart", resourceRoot, createBlips )
setTimer( createBlips, 500, 0 )

function destroyBlip()
	destroyElement( blips[source] )
	blips[source] = nil
end
addEventHandler( "onPlayerQuit", root, destroyBlip )
addEventHandler( "onPlayerWasted", root, destroyBlip )
