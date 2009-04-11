local rootElement = getRootElement()
local thisResourceRoot = getResourceRootElement(getThisResource())
local mapmanagerResource = getResourceFromName("mapmanager")
local serverConsole = getElementByIndex("console", 0)

local modeOptions = 0
local mapOptions = 0
local DONT_CHANGE_OPTION = {"Don't change", default=true}

local vote = {
	map = {},
	mode = {},
	kick = {},
	ban = {},
	kill = {},
}

local function isDisabled (cmd, source)
	if not get(cmd.."_enabled") then
		outputVoteManager(cmd..": this command is disabled.", source)
		return true
	end
	return false
end

local function removeLock (userName, command)
	vote[command].blockedPlayers[userName] = nil
end

local function chooseRandomMap (chosen)
	if not chosen then
		cancelEvent()
		math.randomseed(getTickCount())
		finishPoll(math.random(1, mapOptions))
	end
	removeEventHandler("onPollEnd", rootElement, chooseRandomMap)
end

local function chooseRandomMode (chosen)
	if not chosen then
		cancelEvent()
		math.randomseed(getTickCount())
		finishPoll(math.random(1, modeOptions))
	end
	removeEventHandler("onPollEnd", rootElement, chooseRandomMode)
end

--initializes built-in polls' settings
addEventHandler("onResourceStart", thisResourceRoot,
	function()
		for name, info in pairs(vote) do
			local settingsGroup = "vote"..name
			info.locktime    = get(settingsGroup.."_locktime")
			info.percentage  = get(settingsGroup.."_percentage") or nil
			info.timeout     = get(settingsGroup.."_timeout")    or nil
			info.allowchange = get(settingsGroup.."_allowchange")
			info.blockedPlayers = {}
			addCommandHandler("vote"..name, vote[name].handler )
		end
		
	end
)

--[[ user command handlers ]]--

function vote.map.handler(source,cmd,...)
    -- Handle map name with spaces
    local resource1Name = table.concat({...},' ')
    local resource2Name = nil
    if not getResourceFromName(resource1Name) then
        resource1Name = table.concat({...},' ',1,1)
        resource2Name = table.concat({...},' ',2)
    end

	source = source or serverConsole
	
	if isDisabled(cmd, source) then
		return
	end

	local sourceUserName
	if source ~= serverConsole then
		sourceUserName = getPlayerUserNameSafe(source)
	end
	if source ~= serverConsole and vote.map.blockedPlayers[sourceUserName] then
		outputVoteManager(cmd..": you have to wait "..vote.map.locktime.." seconds before starting another map vote.", source)
	else
		local resource1, resource2
		if resource1Name then
			resource1 = getResourceFromName(resource1Name)
			if not resource1 then
				outputVoteManager(cmd..": resource '"..resource1Name.."' does not exist.", source)
				return false
			end
		else
			outputVoteManager(cmd..": Usage: /"..cmd.." gamemode [map].", source)
			return false
		end
		if resource2Name then
			resource2 = getResourceFromName(resource2Name)
			if not resource2 then
				outputVoteManager(cmd..": resource '"..resource2Name.."' does not exist.", source)
				return false
			end
		end
		local voteMapStarted, voteMapReturnCode = voteMap(resource1, resource2)
		if voteMapStarted then
			outputVoteManager("Map vote started by "..getPlayerName(source)..".")
			if source ~= serverConsole then
				-- send Yes if it's a Yes/No vote (voteMapReturnCode == true)
				if voteMapReturnCode == true then
					triggerClientEvent(source,"doSendVote",rootElement,1)
				end
				vote.map.blockedPlayers[sourceUserName] = true
				setTimer(removeLock, vote.map.locktime * 1000, 1, sourceUserName, "map")
			end
		else
			if voteMapReturnCode == errorCode.pollAlreadyRunning then
				outputVoteManager(cmd..": another poll is in progress.", source)
			elseif voteMapReturnCode == errorCode.noGamemodeRunning then
				outputVoteManager(cmd..": no gamemode is running, you must specify a mode for the map.", source)
			elseif voteMapReturnCode == errorCode.onlyOneCompatibleMap then
				outputVoteManager(cmd..": there's less than two compatible maps for this gamemode.", source)
			elseif voteMapReturnCode == errorCode.invalidMap then
				outputVoteManager(cmd..": invalid map name.", source)
			end
		end
	end
end

function vote.mode.handler(source,cmd,resourceName)
	source = source or serverConsole

	if isDisabled(cmd, source) then
		return
	end
	
	local sourceUserName
	if source ~= serverConsole then
		sourceUserName = getPlayerUserNameSafe(source)
	end
	if source ~= serverConsole and vote.mode.blockedPlayers[sourceUserName] then
		outputVoteManager(cmd..": you have to wait "..vote.map.locktime.." seconds before starting another mode vote.", source)
	else
		local gamemodes = call(mapmanagerResource, "getGamemodes")
		
		--remove the current gamemode from the list
		for i, gamemode in ipairs(gamemodes) do
			if gamemode == call(mapmanagerResource, "getRunningGamemode") then
				table.remove(gamemodes, i)
			end
		end
		
		-- limit it to eight random modes
		if #gamemodes > 8 then
			math.randomseed(getTickCount())
			repeat
				table.remove(gamemodes, math.random(1, #gamemodes))
			until #gamemodes == 8
		end
		
		local voteModeStarted, voteModeReturnCode = voteBetweenModesThenMaps(unpack(gamemodes))
		if voteModeStarted then
			outputVoteManager("Mode vote started by "..getPlayerName(source)..".")
			if source ~= serverConsole then
				vote.mode.blockedPlayers[sourceUserName] = true
				setTimer(removeLock, vote.mode.locktime * 1000, 1, sourceUserName, "mode")
			end
		else
			if voteModeReturnCode == errorCode.pollAlreadyRunning then
				outputVoteManager(cmd..": another poll is in progress.", source)
			elseif voteModeReturnCode == errorCode.twoModesNeeded then
				outputVoteManager(cmd..": there are less than two modes available.", source)
			end
		end
	end
end

function vote.kick.handler(source,cmd,playername,...)
	source = source or serverConsole

	if isDisabled(cmd, source) then
		return
	end
	
	local sourceUserName
	if source ~= serverConsole then
		sourceUserName = getPlayerUserNameSafe(source)
	end
	if source ~= serverConsole and vote.kick.blockedPlayers[sourceUserName] then
		outputVoteManager(cmd..": you have to wait "..vote.kick.locktime.." seconds before starting another votekick.", source)
	else
		local reason = table.concat({...}," ")
		if #reason == 0 then
			reason = nil
		end
		local voteKickStarted, voteKickReturnCode = voteKick(getPlayerFromNick(playername or ""),reason)
		if voteKickStarted then
			outputVoteManager("Votekick started by "..getPlayerName(source)..".")

			if source ~= serverConsole then
				triggerClientEvent(source,"doSendVote",rootElement,1)
				vote.kick.blockedPlayers[sourceUserName] = true
				setTimer(removeLock, vote.kick.locktime * 1000, 1, sourceUserName, "kick")
			end
		else
			if voteKickReturnCode == errorCode.pollAlreadyRunning then
				outputVoteManager(cmd..": another poll is in progress.", source)
			elseif voteKickReturnCode == errorCode.invalidPlayer then
				outputVoteManager(cmd..": invalid player name.", source)
			end
		end
	end
end

function vote.ban.handler(source,cmd,playername,...)
	source = source or serverConsole

	if isDisabled(cmd, source) then
		return
	end
	
	local sourceUserName
	if source ~= serverConsole then
		sourceUserName = getPlayerUserNameSafe(source)
	end
	if source ~= serverConsole and vote.ban.blockedPlayers[sourceUserName] then
		outputVoteManager(cmd..": you have to wait "..vote.ban.locktime.." seconds before starting another voteban.", source)
	else
		local reason = table.concat({...}," ")
		if #reason == 0 then
			reason = nil
		end
		local voteBanStarted, voteBanReturnCode = voteBan(getPlayerFromNick(playername or ""),reason)
		if voteBanStarted then
			outputVoteManager("Voteban started by "..getPlayerName(source)..".")
			
			if source ~= serverConsole then
				triggerClientEvent(source,"doSendVote",rootElement,1)
				vote.ban.blockedPlayers[sourceUserName] = true
				setTimer(removeLock, vote.ban.locktime * 1000, 1, sourceUserName, "ban")
			end
		else
			if voteBanReturnCode == errorCode.pollAlreadyRunning then
				outputVoteManager(cmd..": another poll is in progress.", source)
			elseif voteBanReturnCode == errorCode.invalidPlayer then
				outputVoteManager(cmd..": invalid player name.", source)
			end
		end
	end
end

function vote.kill.handler(source,cmd,playername,...)
	source = source or serverConsole

	if isDisabled(cmd, source) then
		return
	end
	
	local sourceUserName
	if source ~= serverConsole then
		sourceUserName = getPlayerUserNameSafe(source)
	end
	if vote.kill.blockedPlayers[sourceUserName] then
		outputVoteManager(cmd..": you have to wait "..vote.kill.locktime.." seconds before starting another votekill.", source)
	else
		local reason = table.concat({...}," ")
		if #reason == 0 then
			reason = nil
		end
		local voteKillStarted, voteKillReturnCode = voteKill(getPlayerFromNick(playername or ""),reason)
		if voteKillStarted then
			outputVoteManager("Votekill started by "..getPlayerName(source)..".")
			triggerClientEvent(source,"doSendVote",rootElement,1)
			vote.kill.blockedPlayers[sourceUserName] = true
			setTimer(removeLock, vote.kill.locktime * 1000, 1, sourceUserName, "kill")
		else
			if voteKillReturnCode == errorCode.pollAlreadyRunning then
				outputVoteManager(cmd..": another poll is in progress.", source)
			elseif voteKillReturnCode == errorCode.invalidPlayer then
				outputVoteManager(cmd..": invalid player name.", source)
			end
		end
	end
end

--[[ exported functions ]]--

function voteMap(resource1, resource2)
	local gamemode, map
	if resource1 then
		if call(mapmanagerResource, "isMap", resource1) == true then
			map = resource1
		elseif call(mapmanagerResource, "isGamemode", resource1) == true then
			gamemode = resource1
		end
	end
	if resource2 then
		if call(mapmanagerResource, "isMap", resource2) == true then
			if not map then
				map = resource2
			end
		elseif call(mapmanagerResource, "isGamemode", resource2) == true then
			if not gamemode then
				gamemode = resource2
			end
		end
	end

	-- a map, a gamemode: vote for that pair
	if map and gamemode then
		if call(mapmanagerResource, "isMapCompatibleWithGamemode", map, gamemode) then
			local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
			local mapName = getResourceInfo(map, "name") or getResourceName(map)
			return (startPoll{
				title = "Change mode to "..gamemodeName.." on map "..mapName.."?",
				percentage = vote.map.percentage,
				visibleTo = rootElement,
				timeout = vote.map.timeout,
				allowchange = vote.map.allowchange;
				[1]={"Yes",call,mapmanagerResource,"changeGamemodeMap",map,gamemode},
				[2]={"No",outputVoteManager,"votemap: not enough votes to change to '"..gamemodeName.." on map '"..mapName.."'.",rootElement,vR,vG,vB;default=true},
			}), true
		else
			return false, errorCode.mapIsntCompatible
		end
		
	-- no map, a gamemode: vote between compatible maps for that gamemode
	elseif not map then
		return voteBetweenGamemodeCompatibleMaps(gamemode)
		
	-- a map, no gamemode: vote to change current gamemode map
	elseif not gamemode then
		local runningGamemode = call(mapmanagerResource, "getRunningGamemode")
		if not runningGamemode then
			return false, errorCode.noGamemodeRunning
		end
		
		if call(mapmanagerResource, "isMapCompatibleWithGamemode", map, runningGamemode) then
			local mapName = getResourceInfo(map, "name") or getResourceName(map)
			return (startPoll{
				title="Change map to "..mapName.."?",
				percentage = vote.map.percentage,
				visibleTo = rootElement,
				timeout = vote.map.timeout,
				allowchange = vote.map.allowchange;
				[1]={"Yes",call,mapmanagerResource,"changeGamemodeMap",map,runningGamemode},
				[2]={"No",outputVoteManager,"votemap: not enough votes to change to map '"..mapName.."'.",rootElement,vR,vG,vB;default=true},
			}), true
		else
			return false, errorCode.mapIsntCompatible
		end
		
	-- no map, no gamemode: vote between compatible maps for the running gamemode
	else
		local runningGamemode = call(mapmanagerResource, "getRunningGamemode")
		if runningGamemode then
			return voteBetweenGamemodeCompatibleMaps(runningGamemode), true
		else
			return false, errorCode.noGamemodeRunning
		end
	end
end

function voteKick(player, reason)
	if not player or getElementType(player) ~= "player" then
		return false, errorCode.invalidPlayer
	else
		local title = "Kick "..getPlayerName(player).."?"
		if reason then
			title = title.." ("..reason..")"
		end
		return startPoll{
			title=title,
			percentage = vote.kick.percentage,
			visibleTo = rootElement,
			timeout = vote.kick.timeout,
			allowchange = vote.kick.allowchange;
			[1]={"Yes",kickPlayer,player,serverConsole,reason},
			[2]={"No",outputVoteManager,"votekick: not enough votes to kick "..getPlayerName(player)..".",rootElement,vR,vG,vB;default=true},
		}
	end
end

function voteBan(player, reason)
	if not player or getElementType(player) ~= "player" then
		return false, errorCode.invalidPlayer
	else
		local title = "Ban "..getPlayerName(player).."?"
		if reason then
			title = title.." ("..reason..")"
		end
		return startPoll{
			title=title,
			percentage = vote.ban.percentage,
			visibleTo = rootElement,
			timeout = vote.ban.timeout,
			allowchange = vote.ban.allowchange;
			[1]={"Yes",banPlayer,player,serverConsole,reason},
			[2]={"No",outputVoteManager,"voteban: not enough votes to ban "..getPlayerName(player)..".",rootElement,vR,vG,vB;default=true},
		}
	end
end

function voteKill(player, reason)
	if not player or getElementType(player) ~= "player" then
		return false, errorCode.invalidPlayer
	else
		local title = "Kill "..getPlayerName(player).."?"
		if reason then
			title = title.." ("..reason..")"
		end
		return startPoll{
			title=title,
			percentage = vote.kill.percentage,
			visibleTo = rootElement,
			timeout = vote.kill.timeout,
			allowchange = vote.kill.allowchange;
			[1]={"Yes",killPed,player},
			[2]={"No",outputVoteManager,"votekill: not enough votes to kill "..getPlayerName(player)..".",rootElement,vR,vG,vB;default=true},
		}
	end
end

function voteBetweenModes(...)
	local args = {...}
	if #args < 2 then return end
	
	local poll = {
		title="Choose a mode & map:",
		visibleTo=rootElement,
		percentage=vote.mode.percentage,
		timeout=vote.mode.timeout,
		allowchange=vote.mode.allowchange;
	}
	
	local i = 1
	for index, item in ipairs(args) do
		--limit to eight maps
		if i > 8 then
			break
		end
		
		local gamemode, map
		if type(item) == "table" then
			gamemode = item[1]
			map = item[2]
		else
			gamemode = item
			map = nil
		end
		
		if map then
			if
				call(mapmanagerResource, "isGamemode", gamemode) and call(mapmanagerResource, "isMap", map)
			and not
				(call(mapmanagerResource, "getRunningGamemode") == gamemode and call(mapmanagerResource, "getRunningGamemodeMap") == map)
			then
				local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
				local mapName = getResourceInfo(map, "name") or getResourceName(map)
				table.insert(poll,{gamemodeName.." + "..mapName, call, mapmanagerResource, "changeGamemodeMap", map, gamemode})
				i = i + 1
			end
		else
			if call(mapmanagerResource, "isGamemode", gamemode) and not call(mapmanagerResource, "getRunningGamemode") == gamemode then
				local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
				table.insert(poll,{gamemodeName, call, mapmanagerResource, "changeGamemode", gamemode})
				i = i + 1
			end
		end
	end
	
	--if there were at least two valid maps
	modeOptions = #poll
	if modeOptions > 2 then
		local success = startPoll(poll)
		if success then
			addEventHandler("onPollEnd", rootElement, chooseRandomMode)
		end
		return success
	else
		return false, errorCode.twoModesNeeded
	end
end

function voteBetweenModesThenMaps(...)
	local args = {...}
	if #args < 2 then
		return false, errorCode.twoModesNeeded
	end
	
	local poll = {
		title="Choose a mode:",
		visibleTo=rootElement,
		percentage=vote.mode.percentage,
		timeout=vote.mode.timeout,
		allowchange=vote.mode.allowchange;
	}
	
	local i = 0
	for index, gamemode in ipairs(args) do
		i = i + 1
		--limit to eight modes
		if i > 8 then
			break
		end

		if call(mapmanagerResource, "isGamemode", gamemode) then
			local compatibleMaps = call(mapmanagerResource, "getMapsCompatibleWithGamemode", gamemode)
			local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
			--start a map vote if there are 2+ maps for the mode
			if #compatibleMaps > 1 then
				table.insert(poll,{gamemodeName, voteBetweenGamemodeCompatibleMaps, gamemode})
			--start with the only map if there is only one map for the mode
			elseif #compatibleMaps == 1 then
				table.insert(poll,{gamemodeName, call, mapmanagerResource, "changeGamemode", gamemode, compatibleMaps[1]})
			else
				table.insert(poll,{gamemodeName, call, mapmanagerResource, "changeGamemode", gamemode})
			end
		end
	end
	table.insert(poll, DONT_CHANGE_OPTION)
	
	--if there were at least two valid modes
	modeOptions = #poll - 1 -- ignore "don't change"
	if modeOptions > 2 then
		local success = startPoll(poll)
		if success then
			addEventHandler("onPollEnd", rootElement, chooseRandomMode)
		end
		return success
	else
		return false, errorCode.twoModesNeeded
	end
end

function voteBetweenMaps(...)
	local args = {...}
	if #args < 2 then
		return false, errorCode.twoMapsNeeded
	end
	
	local poll = {
		title="Choose a map:",
		visibleTo=rootElement,
		percentage=vote.map.percentage,
		timeout=vote.map.timeout,
		allowchange=vote.map.allowchange;
	}
	
	local i = 0
	for index, map in ipairs(args) do
		i = i + 1
		--limit to eight maps
		if i > 8 then
			break
		end
		if call(mapmanagerResource, "isMap", map) then
			local mapName = getResourceInfo(map, "name") or getResourceName(map)
			table.insert(poll,{mapName, call, mapmanagerResource, "changeGamemodeMap", map})
		end
	end
	
	--if there were at least two valid maps
	mapOptions = #poll
	if mapOptions > 2 then
		local success = startPoll(poll)
		if success then
			addEventHandler("onPollEnd", rootElement, chooseRandomMap)
		end
		return success
	else
		return false, errorCode.twoMapsNeeded
	end
end

function voteBetweenGamemodeCompatibleMaps(gamemode)
	local compatibleMaps = call(mapmanagerResource, "getMapsCompatibleWithGamemode", gamemode)
	
	-- limit it to eight random maps
	if #compatibleMaps > 8 then
		math.randomseed(getTickCount())
		repeat
			table.remove(compatibleMaps, math.random(1, #compatibleMaps))
		until #compatibleMaps == 8
	elseif #compatibleMaps < 2 then
		return false, errorCode.onlyOneCompatibleMap
	end
	
	local poll = {
		title="Choose a map:",
		visibleTo=rootElement,
		percentage=vote.map.percentage,
		timeout=vote.map.timeout,
		allowchange=vote.map.allowchange;
		}
	
	for index, map in ipairs(compatibleMaps) do
		local mapName = getResourceInfo(map, "name") or getResourceName(map)
		table.insert(poll, {mapName, call, mapmanagerResource, "changeGamemodeMap", map, gamemode})
	end
	
	table.insert(poll, DONT_CHANGE_OPTION)
	
	mapOptions = #poll - 1
	local success = startPoll(poll)
	if success then
		addEventHandler("onPollEnd", rootElement, chooseRandomMap)
	end
	return success
end