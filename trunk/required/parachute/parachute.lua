root = getRootElement ()

local function onResourceStart ( resource )
  local players = getElementsByType ( "player" )
  for k, v in pairs ( players ) do
    setElementData ( v, "parachuting", false )
  end
end
addEventHandler ( "onResourceStart", getResourceRootElement ( getThisResource () ), onResourceStart )

function requestAddParachute ()
	for key,player in ipairs(getElementsByType"player") do
		if player ~= source then
			triggerClientEvent ( player, "doAddParachuteToPlayer", source )
		end
	end
end
addEvent ( "requestAddParachute", true )
addEventHandler ( "requestAddParachute", root, requestAddParachute )

function requestRemoveParachute ()
	takeWeapon ( source, 46 )
	for key,player in ipairs(getElementsByType"player") do
		if player ~= source then
			triggerClientEvent ( player, "doRemoveParachuteFromPlayer", source )
		end
	end
end
addEvent ( "requestRemoveParachute", true )
addEventHandler ( "requestRemoveParachute", root, requestRemoveParachute )