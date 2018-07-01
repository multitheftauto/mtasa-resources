local sound
radius = 2.6946883201599
offset = { 0, 0, 0 }
overboardScale = 1.05
overboardTime = 400
openingChutes = {}

function openChute ( object, player, time )
	sound = playSound3D ( "parachuteopen.mp3", getElementPosition(player) )
	setSoundMinDistance ( sound, 25 )
	setObjectScale ( object, 0 )
	openingChutes[object]  = {}
	openingChutes[object].time = time
	openingChutes[object].player = player
	openingChutes[object].originalTick = getTickCount()
	attachElements ( object, player, unpack(offset) )
	return true
end

function animateParachuteOpen()
	for object, infoTable in pairs(openingChutes) do
		if getElementData ( infoTable.player, "parachuting" ) then
			local time = t(infoTable.time)
			local newTime = time * overboardScale
			local player = infoTable.player
			local tickDifference = getTickCount() - infoTable.originalTick
			if ( isElement(sound)) then
				setElementPosition ( sound, getElementPosition(player) )
			end
			if ( infoTable.overboard ) then
				local overboardDifference = getTickCount() - infoTable.overboard
				if overboardDifference >= overboardTime then
					setObjectScale ( object, 1 )
					changeVelocity = true
					if not isPedDead ( player ) then
						setPedAnimation ( player, "PARACHUTE", "PARA_float", -1, false, false, false )
					end
					openingChutes[object] = nil
					return
				else
					local currentScale = overboardScale - 1
					local newScale = (1 - overboardDifference/overboardTime) * currentScale
					setObjectScale ( object, 1 + newScale )
				end
			else
				if tickDifference >= newTime then
					openingChutes[object].overboard = getTickCount()
				else
					local size = tickDifference/time
					setObjectScale ( object, size )
					setPedNewAnimation ( player, nil,"PARACHUTE", "PARA_open", -1, false, true, false )
					return
				end
			end
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), animateParachuteOpen )
