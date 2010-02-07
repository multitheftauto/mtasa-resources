--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_maps.lua
*
*	Original File by eXo|Flobu
*
**************************************]]

local count

function createMapTab()
	aTabMap = {}
	aTabMap.Tab = guiCreateTab ( "Maps", aTabPanel )
	aTabMap.MapList = guiCreateGridList ( 0.03, 0.05, 0.35, 0.85, true, aTabMap.Tab )
					  guiGridListAddColumn( aTabMap.MapList, "Map Name", 2)
					  guiGridListAddColumn( aTabMap.MapList, "Resource Name", 1)
					  guiGridListAddColumn( aTabMap.MapList, "Gamemode", 0.5)
	aTabMap.Start = guiCreateButton ( 0.45, 0.05, 0.3, 0.04, "Start Gamemode with Map", true, aTabMap.Tab )
	aTabMap.CurMap = guiCreateLabel ( 0.46, 0.15, 0.40, 0.035, "Current Map: N/A", true, aTabMap.Tab )
	aTabMap.CurGamemode = guiCreateLabel ( 0.46, 0.2, 0.40, 0.035, "Current Gamemode: N/A", true, aTabMap.Tab )
	aTabMap.NextMap = guiCreateButton ( 0.45, 0.35, 0.3, 0.04, "Set Next Map", true, aTabMap.Tab )
	aTabMap.Delete = guiCreateButton ( 0.45, 0.40, 0.3, 0.04, "Delete Map", true, aTabMap.Tab )
	aTabMap.Revert = guiCreateButton ( 0.45, 0.45, 0.3, 0.04, "Revert Map", true, aTabMap.Tab )
	guiSetVisible(aTabMap.Delete, false)
	guiSetVisible(aTabMap.Revert, false)
	aTabMap.RefreshList = guiCreateButton ( 0.03, 0.91, 0.35, 0.04, "Refresh list", true, aTabMap.Tab )
	addEventHandler ("onClientGUIClick", aAdminForm, guiClick)
	addEventHandler ("onClientGUIDoubleClick", aAdminForm, guiDoubleClick)
end

function loadMaps(gamemodeMapTable, gamemode, map)
	guiSetText(aTabMap.CurMap,"Current Map: "..map)
	guiSetText(aTabMap.CurGamemode,"Current Gamemode: "..gamemode)
	if gamemodeMapTable then
		for id,gamemode in pairs (gamemodeMapTable) do
			guiGridListSetItemText ( aTabMap.MapList, guiGridListAddRow ( aTabMap.MapList ), 1, gamemode.name, true, false )
			if #gamemode.maps == 0 and gamemode.name ~= "no gamemode" and gamemode.name ~= "deleted maps" then
				local row = guiGridListAddRow ( aTabMap.MapList )
				guiGridListSetItemText ( aTabMap.MapList, row, 1, gamemode.name, false, false )
				guiGridListSetItemText ( aTabMap.MapList, row, 2, gamemode.resname, false, false )
				guiGridListSetItemText ( aTabMap.MapList, row, 3, gamemode.resname, false, false )
			else
				for id,map in ipairs (gamemode.maps) do
					local row = guiGridListAddRow ( aTabMap.MapList )
					guiGridListSetItemText ( aTabMap.MapList, row, 1, map.name, false, false )
					guiGridListSetItemText ( aTabMap.MapList, row, 2, map.resname, false, false )
					guiGridListSetItemText ( aTabMap.MapList, row, 3, gamemode.resname, false, false )
				end
			end
		end
	end
end
addEvent("getMaps_c", true)
addEventHandler("getMaps_c", getLocalPlayer(), loadMaps)

function guiClick(button)
	if button == "left" then
		if ( getElementParent ( source ) == aTabMap.Tab ) then
			if source == aTabMap.RefreshList then
				guiGridListClear(aTabMap.MapList)
				triggerServerEvent("getMaps_s", getLocalPlayer(), true)
			end
			if not guiGridListGetSelectedItem ( aTabMap.MapList ) == -1 then
				aMessageBox ( "error", "No map selected!" )
			end
			local mapName = guiGridListGetItemText ( aTabMap.MapList, guiGridListGetSelectedItem( aTabMap.MapList ), 1 )
			local mapResName = guiGridListGetItemText ( aTabMap.MapList, guiGridListGetSelectedItem( aTabMap.MapList ), 2 )
			local gamemode = guiGridListGetItemText ( aTabMap.MapList, guiGridListGetSelectedItem( aTabMap.MapList ), 3 )
			if source == aTabMap.MapList then
				if gamemode == "race" then
					guiSetEnabled(aTabMap.NextMap, true)
				else
					guiSetEnabled(aTabMap.NextMap, false)
				end
				-- if gamemode == "deleted maps" then
					-- guiSetEnabled(aTabMap.Start, false)
					-- guiSetEnabled(aTabMap.Delete, false)
					-- guiSetEnabled(aTabMap.Revert, true)
				-- else
					-- guiSetEnabled(aTabMap.Start, true)
					-- guiSetEnabled(aTabMap.Delete, true)
					-- guiSetEnabled(aTabMap.Revert, false)
				-- end
			elseif source == aTabMap.Start then
				triggerServerEvent("startGamemodeMap_s", getLocalPlayer(), gamemode, mapResName)
			elseif source == aTabMap.NextMap then
				if gamemode == "race" then
					triggerServerEvent("setNextMap_s", getLocalPlayer(), mapName)
				end
			elseif source == aTabMap.Delete then
				aMessageBox ( "question", "Are you sure to delete '"..mapName.."'?", "triggerServerEvent(\"deleteRevertMap_s\", getLocalPlayer(), true, \""..mapResName.."\", \""..mapName.."\")" )
			elseif source == aTabMap.Revert then
				triggerServerEvent("deleteRevertMap_s", getLocalPlayer(), false, mapResName, mapName)
			end
		end
	end
end

function guiDoubleClick(button)
	if button == "left" then
		if ( getElementParent ( source ) == aTabMap.Tab ) then
			local mapResName = guiGridListGetItemText ( aTabMap.MapList, guiGridListGetSelectedItem( aTabMap.MapList ), 2 )
			local gamemode = guiGridListGetItemText ( aTabMap.MapList, guiGridListGetSelectedItem( aTabMap.MapList ), 3 )
			if source == aTabMap.MapList then
				triggerServerEvent("startGamemodeMap_s", getLocalPlayer(), gamemode, mapResName)
			end
		end
	end
end

addEvent("deleteRevertMap_c", true)
addEventHandler("deleteRevertMap_c", getLocalPlayer(),
	function(success, delete, mapName)
		if success then
			guiGridListClear(aTabMap.MapList)
			triggerServerEvent("getMaps_s", getLocalPlayer(), true)
			if delete then
				aMessageBox ( "info", "Map '"..mapName.."' deleted successfully!" )
			else
				aMessageBox ( "info", "Map '"..mapName.."' reverted successfully!" )
			end
		else
			aMessageBox ( "error", "cant delete/revert!" )
		end
	end
)
