
local function onResourceStart ( resource )
	local players = getElementsByType ( "player" )
	for k, v in pairs ( players ) do
		setElementData ( v, "parachuting", false )
	end
end
addEventHandler ( "onResourceStart", resourceRoot, onResourceStart )

function requestAddParachute ()
	local plrs = getElementsByType("player")
	for key,player in ipairs(plrs) do
		if player == client then
			table.remove(plrs, key)
			break
		end
	end
	triggerClientEvent(plrs, "doAddParachuteToPlayer", client)
end
addEvent ( "requestAddParachute", true )
addEventHandler ( "requestAddParachute", resourceRoot, requestAddParachute )

function requestRemoveParachute ()
	takeWeapon ( client, 46 )
	local plrs = getElementsByType("player")
	for key,player in ipairs(plrs) do
		if player == client then
			table.remove(plrs, key)
			break
		end
	end
	triggerClientEvent(plrs, "doRemoveParachuteFromPlayer", client)
end
addEvent ( "requestRemoveParachute", true )
addEventHandler ( "requestRemoveParachute", resourceRoot, requestRemoveParachute )