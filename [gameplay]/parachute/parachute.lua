
local function onResourceStart ( resource )
	local players = getElementsByType ( "player" )
	for k, v in pairs ( players ) do
		setElementData ( v, "parachuting", false )
	end
end
addEventHandler ( "onResourceStart", resourceRoot, onResourceStart )

function requestAddParachute ()
	local plrs = {}
	for key,player in ipairs(getElementsByType"player") do
		if player ~= source then
			table.insert(plrs, player)
		end
	end
	triggerClientEvent(plrs, "doAddParachuteToPlayer", source)
end
addEvent ( "requestAddParachute", true )
addEventHandler ( "requestAddParachute", root, requestAddParachute )

function requestRemoveParachute ()
	takeWeapon ( source, 46 )
	local plrs = {}
	for key,player in ipairs(getElementsByType"player") do
		if player ~= source then
			table.insert(plrs, player)
		end
	end
	triggerClientEvent(plrs, "doAddParachuteToPlayer", source)
end
addEvent ( "requestRemoveParachute", true )
addEventHandler ( "requestRemoveParachute", root, requestRemoveParachute )