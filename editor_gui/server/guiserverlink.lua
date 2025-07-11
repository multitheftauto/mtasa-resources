addEvent ( "loadsave_getResources",true )
addEvent ( "callServerside", true )

function serversideCall ( resourceName, functionName, ... )
	call ( getResourceFromName ( resourceName ), functionName, ...  )
end
addEventHandler ( "callServerside", root, serversideCall )

function loadsave_getResources ( dialog, player )
	if not source then source = player end
	local mapResources = getResources()
	local maps = {}
	local mapInfo
	for k,resource in ipairs(mapResources) do
		local resourceName = getResourceName ( resource )
		mapInfo = { name = resourceName }
		table.insert(maps, mapInfo)
		if mapmanager.isMap (resource) then
			mapInfo["type"] = "map"
			local gamemodes = mapmanager.getGamemodesCompatibleWithMap (resource)
			mapInfo["gamemodes"] = ""
			for i,gamemode in ipairs(gamemodes) do
				local prefix = ","
				if i == 1 then prefix = "" end
				mapInfo["gamemodes"] = mapInfo["gamemodes"]..prefix..getResourceName(gamemode)
			end
		elseif mapmanager.isGamemode ( resource ) then
			mapInfo["type"] = "gamemode"
		else
			mapInfo["type"] = "script"
		end
		mapInfo["version"] = getResourceInfo ( resource, "version" ) or ""
		mapInfo["friendlyName"] = resourceName
	end
	table.sort(maps, function(a, b) return a.name < b.name end)
	local currentDirectory = get('*editor_main.mapResourceOrganizationalDirectory')
	triggerClientEvent ( source, dialog.."ShowDialog", source, maps, currentDirectory )
end
addEventHandler ( "loadsave_getResources", root, loadsave_getResources )


function outputMessage ( text, player, r, g, b, time )
	player = player or root
	return triggerClientEvent ( player, "doOutputMessage", player, text, r, g, b, time )
end
