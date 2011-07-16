--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_servermaps.lua
*
*	Original File by eXo|Flobu
*
**************************************]]

function getServerMaps (loadList)
	if checkClient( true, source, 'getServerMaps' ) then return end
	local tableOut
	if loadList then
		tableOut = {}
		-- local deletedMaps = {}
		local gamemodes = {}
		gamemodes = call(getResourceFromName("mapmanager"), "getGamemodes")
		for id,gamemode in ipairs (gamemodes) do
			tableOut[id] = {}
			tableOut[id].name = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
			tableOut[id].resname = getResourceName(gamemode)
			tableOut[id].maps = {}
			local maps = call(getResourceFromName("mapmanager"), "getMapsCompatibleWithGamemode" , gamemode)
			for _,map in ipairs (maps) do
				table.insert(tableOut[id]["maps"] ,{name = getResourceInfo(map, "name") or getResourceName(map), resname = getResourceName(map)})
			end
			table.sort(tableOut[id]["maps"], sortCompareFunction)
		end
		table.sort((tableOut), sortCompareFunction)
		table.insert(tableOut, {name = "no gamemode", resname = "no gamemode", maps = {}})
		local countGmodes = #tableOut
		local maps = call(getResourceFromName("mapmanager"), "getMapsCompatibleWithGamemode")
		for id,map in ipairs (maps) do
			-- if fileOpen(":"..getResourceName(map).."/deleted") then
				-- table.insert(deletedMaps ,{name = getResourceInfo(map, "name") or getResourceName(map), resname = getResourceName(map)})
			-- else
				table.insert(tableOut[countGmodes]["maps"] ,{name = getResourceInfo(map, "name") or getResourceName(map), resname = getResourceName(map)})
			-- end
		end
		-- table.sort(deletedMaps, sortCompareFunction)
		table.sort(tableOut[countGmodes]["maps"], sortCompareFunction)
		-- table.insert(tableOut, {name = "deleted maps", resname = "deleted maps", maps = {}})
		-- local countGmodes = countGmodes + 1
		-- tableOut[countGmodes]["maps"] = deletedMaps
	end
	local map = call(getResourceFromName("mapmanager"), "getRunningGamemodeMap")
	local gamemode = call(getResourceFromName("mapmanager"), "getRunningGamemode")
	gamemode = gamemode and getResourceName(gamemode) or "N/A"
	map = map and getResourceName(map) or "N/A"
	triggerClientEvent(source ,"getMaps_c", source, tableOut, gamemode, map)
end
addEvent("getMaps_s", true)
addEventHandler("getMaps_s", getRootElement(), getServerMaps)

function startGamemodeMap(gamemode, map)
	if checkClient( true, source, 'startGamemodeMap' ) then return end
	if gamemode == "no gamemode" then
		call(getResourceFromName("mapmanager"), "changeGamemodeMap", getResourceFromName(map))
	else
		if gamemode == map then
			call(getResourceFromName("mapmanager"), "changeGamemode", getResourceFromName(gamemode))
		else
			if gamemode == getResourceName(call(getResourceFromName("mapmanager"), "getRunningGamemode")) then
				call(getResourceFromName("mapmanager"), "changeGamemodeMap", getResourceFromName(map))
			else
				call(getResourceFromName("mapmanager"), "changeGamemode", getResourceFromName(gamemode), getResourceFromName(map))
			end
		end
	end
end
addEvent("startGamemodeMap_s", true)
addEventHandler("startGamemodeMap_s", getRootElement(), startGamemodeMap)

function deleteRevertMap(delete, mapResName, mapName)
	if checkClient( true, source, 'deleteRevertMap' ) then return end
	outputDebugString("delete = "..tostring(delete).." mapResName = "..tostring(mapResName).." mapName = "..tostring(mapName))
	if mapResName then
		local success
		local map = getResourceFromName(mapResName)
		if delete then
			local gamemodes = getResourceInfo(map, "gamemodes")
			local setInfo = setResourceInfo(map, "gamemodes", "")
			local newfile = fileCreate(":"..mapResName.."/deleted")
			local flushInfo
			if newfile and gamemodes then
				fileWrite(newfile, gamemodes)
				flushInfo = fileFlush(newfile)
				fileClose(newfile)
			end
			outputDebugString("setinfo = "..tostring(setInfo).." flushInfo = "..tostring(flushInfo).." gamemodes = "..tostring(gamemodes))
			if setInfo and flushInfo then
				success = true
			end
		else
			local file = fileOpen(":"..mapResName.."/deleted")
			local fdel, setInfo
			if file then
				local gamemodes = fileRead(file, 100)
				fileClose(file)
				fdel = fileDelete(":"..mapResName.."/deleted")
				setInfo = setResourceInfo(map, "gamemodes", gamemodes)
			end
			outputDebugString("setinfo = "..tostring(setInfo).." fdel = "..tostring(fdel))
			if setInfo and fdel then
				success = true
			end
		end
		triggerClientEvent(source ,"deleteRevertMap_c", source, success, delete, mapName)
	end
end
addEvent("deleteRevertMap_s", true)
addEventHandler("deleteRevertMap_s", getRootElement(), deleteRevertMap)


function setNextMap(mapName)
	if checkClient( true, source, 'setNextMap', mapName ) then return end
	executeCommandHandler("nextmap", source, mapName)
end
addEvent("setNextMap_s", true)
addEventHandler("setNextMap_s", getRootElement(),setNextMap)

function sortCompareFunction(s1, s2)
	if type(s1) == "table" and type(s2) == "table" then
		s1, s2 = s1.name, s2.name
	end
    s1, s2 = s1:lower(), s2:lower()
    if s1 == s2 then
        return false
    end
    local byte1, byte2 = string.byte(s1:sub(1,1)), string.byte(s2:sub(1,1))
    if not byte1 then
        return true
    elseif not byte2 then
        return false
    elseif byte1 < byte2 then
        return true
    elseif byte1 == byte2 then
        return sortCompareFunction(s1:sub(2), s2:sub(2))
    else
        return false
    end
end