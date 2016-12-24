-- needs configurable blip colors, and team support
root = getRootElement ()
color = { 0, 255, 0 }
players = {}
resourceRoot = getResourceRootElement ( getThisResource () )

function onResourceStart ( resource )
  	for id, player in ipairs( getElementsByType ( "player" ) ) do
		if ( players[player] ) then
			local blip = createBlipAttachedTo ( player, 0, 2, players[source][1], players[source][2], players[source][3] )
			setElementData ( player, "blip", blip )
		else
			local blip = createBlipAttachedTo ( player, 0, 2, color[1], color[2], color[3] )
			setElementData ( player, "blip", blip )
		end
	end
end

function onPlayerSpawn ( spawnpoint )
	if ( players[source] ) then
		local blip = createBlipAttachedTo ( source, 0, 2, players[source][1], players[source][2], players[source][3] )
		setElementData ( source, "blip", blip )
	else
		local blip = createBlipAttachedTo ( source, 0, 2, color[1], color[2], color[3] )
		setElementData ( source, "blip", blip )
	end
end

function onPlayerQuit ()
	destroyBlipsAttachedTo ( source )
end

function onPlayerWasted ( totalammo, killer, killerweapon )
	destroyBlipsAttachedTo ( source )
end

function setBlipsColor ( source, commandName, r, g, b )
	if ( tonumber ( b ) ) then
		color = { tonumber ( r ), tonumber ( g ), tonumber ( b ) }
  		for id, player in ipairs( getElementsByType ( "player" ) ) do
			destroyBlipsAttachedTo ( player )
			if ( players[player] ) then
				local blip = createBlipAttachedTo ( player, 0, 2, players[source][1], players[source][2], players[source][3] )
				setElementData ( player, "blip", blip )
			else
				local blip = createBlipAttachedTo ( player, 0, 2, color[1], color[2], color[3] )
				setElementData ( player, "blip", blip )
			end
		end
	end
end

function setBlipColor ( source, commandName, r, g, b )
	if ( tonumber ( b ) ) then
		destroyBlipsAttachedTo ( source )
		players[source] = { tonumber ( r ), tonumber ( g ), tonumber ( b ) }
  		createBlipAttachedTo ( source, 0, 2, players[source][1], players[source][2], players[source][3] )
	end
end

function setPlayerBlipColor ( source, commandName, player, r, g, b)
	if not player or not r or not g or not b then
		outputChatBox("Syntax: /setblipcolor <player name> <r> <g> <b>", source)
	return end
	local target = getPlayerFromPartialName(player)
	if not target then 
		outputChatBox("There is no player with that nickname.", source)
	return end 
	local blip = getElementData(target, "blip")
	if not blip then 
		outputChatBox("Unexepted error.", source)
	return end
	if r > 0 and r < 256 and g > 0 and g < 256 and b > 0 and g < 256 then
		setBlipColor(target, r, g, b)
	else 
		outputChatBox("Bad color.", source)
	end
end

addCommandHandler ( "setblipcolor", setPlayerBlipColor)
addCommandHandler ( "setblipscolor", setBlipsColor )
addCommandHandler ( "setblipcolor", setBlipColor )
addEventHandler ( "onResourceStart", resourceRoot, onResourceStart )
addEventHandler ( "onPlayerSpawn", root, onPlayerSpawn )
addEventHandler ( "onPlayerQuit", root, onPlayerQuit )
addEventHandler ( "onPlayerWasted", root, onPlayerWasted )

function destroyBlipsAttachedTo(player)
	local attached = getAttachedElements ( player )
	if ( attached ) then
		for k,element in ipairs(attached) do
			if getElementType ( element ) == "blip" then
				destroyElement ( element )
			end
		end
	end
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end
