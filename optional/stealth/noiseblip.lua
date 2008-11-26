addEvent ("soundblipon", true )
addEvent ("soundblipoff", true )
--playerBlip = {}
function turnonblip ( thisplayer )
	setPlayerNametagShowing ( thisplayer, true )
	local loudguysteam = getPlayerTeam ( thisplayer )
	if loudguysteam == team1 then
	--if not playerBlip[source] then
		createBlipAttachedTo ( source, 0, 2, 255, 0, 0 )
	--else
		--setElementVisibleTo(playerBlip[source], getRootElement(), true)
	--end
	end
	if loudguysteam == team2 then
	--if not playerBlip[source] then
		createBlipAttachedTo ( source, 0, 2, 0, 0, 255 )
	--else
		--setElementVisibleTo(playerBlip[source], getRootElement(), true)
	--end
	end
end

function turnoffblip ( thisplayer )
	setPlayerNametagShowing ( thisplayer, false )
	destroyBlipsAttachedTo ( source )
	--setElementVisibleTo(playerBlip[thisplayer], getRootElement(), false)
end

function clearplayerblip ()
	destroyBlipsAttachedTo(source)
end

function destroyBlipsAttachedTo(player)
if not isElement(player) then return false end
local attached = getAttachedElements ( player )
if not attached then return false end
	for k,element in ipairs(attached) do
		if getElementType ( element ) == "blip" then
			destroyElement ( element )
		end
	end
	return true
end

addEventHandler( "onPlayerQuit", getRootElement(), clearplayerblip )
addEventHandler ( "soundblipon", getRootElement(), turnonblip )
addEventHandler ( "soundblipoff", getRootElement(), turnoffblip )