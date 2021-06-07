local rootElement = getRootElement()
local thisResourceRoot = getResourceRootElement(getThisResource())
local serverConsole = getElementByIndex("console", 0)

local modeOptions = 0
local mapOptions = 0
local DONT_CHANGE_OPTION = {"Don't change", default=false}
local currentPollSize = 0

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
		finishPoll(math.random(1, math.min(mapOptions,currentPollSize)))
	end
	removeEventHandler("onPollEnd", rootElement, chooseRandomMap)
end

local function chooseRandomMode (chosen)
	if not chosen then
		cancelEvent()
		math.randomseed(getTickCount())
		finishPoll(math.random(1, math.min(modeOptions,currentPollSize)))
	end
	removeEventHandler("onPollEnd", rootElement, chooseRandomMode)
end

function setCurrentPollSize ( size )
	currentPollSize = size
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
			if name == "ban" then
				info.banip       = get(settingsGroup.."_banip")
				info.banusername = get(settingsGroup.."_banusername")
				info.banserial   = get(settingsGroup.."_banserial")
				info.duration    = get(settingsGroup.."_duration")
			end
			info.blockedPlayers = {}
			addCommandHandler("vote"..name, vote[name].handler )
		end

	end
)

--[[ user command handlers ]]--

function vote.map.handler(source,cmd,...)
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
    local resource1Name = #{...}>0 and table.concat({...},' ',1,1) or nil
    local resource2Name = #{...}>1 and table.concat({...},' ',2)   or nil
	source = source or serverConsole

	if isDisabled(cmd, source) then
		return
	end

	local sourceSerial
	if source ~= serverConsole then
		sourceSerial = getPlayerSerial(source)
	end
	if source ~= serverConsole and vote.map.blockedPlayers[sourceSerial] then
		outputVoteManager(cmd..": you have to wait "..vote.map.locktime.." seconds before starting another map vote.", source)
	else
		local resource1, resource2
		if resource1Name then
			if resource1Name == "*" then
				resource1 = "*"
			else
				resource1, errormsg = findMap(resource1Name)
				if not resource1 then
					if exports.mapmanager:isGamemode(getResourceFromName(resource1Name)) then
						resource1 = getResourceFromName(resource1Name)
					else
						outputVoteManager(errormsg, source)
						return false
					end
				end
			end
			if resource2Name then
				resource2, errormsg = findMap(resource2Name, resource1)
				if not resource2 then
					outputVoteManager(errormsg, source)
					return false
				end
			end
		end
		-- if using votemap to do a mode change, ensure that votemode has not been disabled
		if exports.mapmanager:isGamemode(resource1) and not exports.mapmanager:isMap(resource1) and exports.mapmanager:getRunningGamemode() ~= resource1 and isDisabled("votemode", source) then
			return
		end
		local voteMapStarted, voteMapReturnCode = voteMap(resource1, resource2)
		if voteMapStarted then
			outputVoteManager("Map vote started by "..getPlayerName(source)..".")
			if source ~= serverConsole then
				-- send Yes if it's a Yes/No vote (voteMapReturnCode == true)
				if voteMapReturnCode == true then
					triggerClientEvent(source,"doSendVote",rootElement,1)
				end
                if vote.map.locktime >= 0.05 then
                    vote.map.blockedPlayers[sourceSerial] = true
                    setTimer(removeLock, vote.map.locktime * 1000, 1, sourceSerial, "map")
                end
			end
		else
			if voteMapReturnCode == errorCode.pollAlreadyRunning then
				outputVoteManager(cmd..": another poll is in progress.", source)
			elseif voteMapReturnCode == errorCode.noGamemodeRunning then
				outputVoteManager(cmd..": no gamemode is running, you must specify a mode for the map.", source)
			elseif voteMapReturnCode == errorCode.invalidMap then
				outputVoteManager(cmd..": invalid map name.", source)
			end
		end
	end
end

function vote.mode.handler(source,cmd)
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
	source = source or serverConsole

	if isDisabled(cmd, source) then
		return
	end

	local sourceSerial
	if source ~= serverConsole then
		sourceSerial = getPlayerSerial(source)
	end
	if source ~= serverConsole and vote.mode.blockedPlayers[sourceSerial] then
		outputVoteManager(cmd..": you have to wait "..vote.mode.locktime.." seconds before starting another mode vote.", source)
	else
		local gamemodes = exports.mapmanager:getGamemodes()

		--remove the current gamemode from the list
		for i, gamemode in ipairs(gamemodes) do
			if gamemode == exports.mapmanager:getRunningGamemode() then
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
                if vote.mode.locktime >= 0.05 then
                    vote.mode.blockedPlayers[sourceSerial] = true
                    setTimer(removeLock, vote.mode.locktime * 1000, 1, sourceSerial, "mode")
                end
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

	local sourceSerial
	if source ~= serverConsole then
		sourceSerial = getPlayerSerial(source)
	end
	if source ~= serverConsole and vote.kick.blockedPlayers[sourceSerial] then
		outputVoteManager(cmd..": you have to wait "..vote.kick.locktime.." seconds before starting another votekick.", source)
	else
		local reason = table.concat({...}," ")
		if #reason == 0 then
			reason = nil
		end
		local voteKickStarted, voteKickReturnCode = voteKick(getPlayerByNamepart(playername),reason)
		if voteKickStarted then
			outputVoteManager("Votekick started by "..getPlayerName(source)..".")

			if source ~= serverConsole then
				triggerClientEvent(source,"doSendVote",rootElement,1)
                if vote.kick.locktime >= 0.05 then
                    vote.kick.blockedPlayers[sourceSerial] = true
                    setTimer(removeLock, vote.kick.locktime * 1000, 1, sourceSerial, "kick")
                end
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

	local sourceSerial
	if source ~= serverConsole then
		sourceSerial = getPlayerSerial(source)
	end
	if source ~= serverConsole and vote.ban.blockedPlayers[sourceSerial] then
		outputVoteManager(cmd..": you have to wait "..vote.ban.locktime.." seconds before starting another voteban.", source)
	else
		local reason = table.concat({...}," ")
		if #reason == 0 then
			reason = nil
		end
		local voteBanStarted, voteBanReturnCode = voteBan(getPlayerByNamepart(playername),reason)
		if voteBanStarted then
			outputVoteManager("Voteban started by "..getPlayerName(source)..".")

			if source ~= serverConsole then
				triggerClientEvent(source,"doSendVote",rootElement,1)
                if vote.ban.locktime >= 0.05 then
                    vote.ban.blockedPlayers[sourceSerial] = true
                    setTimer(removeLock, vote.ban.locktime * 1000, 1, sourceSerial, "ban")
                end
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

	local sourceSerial
	if source ~= serverConsole then
		sourceSerial = getPlayerSerial(source)
	end
	if vote.kill.blockedPlayers[sourceSerial] then
		outputVoteManager(cmd..": you have to wait "..vote.kill.locktime.." seconds before starting another votekill.", source)
	else
		local reason = table.concat({...}," ")
		if #reason == 0 then
			reason = nil
		end
		local voteKillStarted, voteKillReturnCode = voteKill(getPlayerByNamepart(playername),reason)
		if voteKillStarted then
			outputVoteManager("Votekill started by "..getPlayerName(source)..".")
			triggerClientEvent(source,"doSendVote",rootElement,1)
            if vote.kill.locktime >= 0.05 then
                vote.kill.blockedPlayers[sourceSerial] = true
                setTimer(removeLock, vote.kill.locktime * 1000, 1, sourceSerial, "kill")
            end
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
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
	local gamemode, map
	if resource1 then
        if resource1 == "*" then
            map = "*"
        else
            if exports.mapmanager:isMap(resource1) == true then
                map = resource1
            elseif exports.mapmanager:isGamemode(resource1) == true then
                gamemode = resource1
            end
        end
	end
	if resource2 then
		if exports.mapmanager:isMap(resource2) == true then
			if not map then
				map = resource2
			end
		elseif exports.mapmanager:isGamemode(resource2) == true then
			if not gamemode then
				gamemode = resource2
			end
		end
	end

    -- map equals "*": vote for a random map on the current gamemode
    if map and map == "*" then
        local runningGamemode = exports.mapmanager:getRunningGamemode()
		if not runningGamemode then
			return false, errorCode.noGamemodeRunning
		end

        local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode(runningGamemode)
        map = exports.mapmanager:getRunningGamemodeMap()
        if map then
            local currentMap = getResourceName(map)
            for i,map in ipairs(compatibleMaps) do
                if getResourceName(map) == currentMap then
                    table.remove(compatibleMaps, i)
                    break
                end
            end
        end

        return (startPoll {
            title='Change to a random map on this gamemode?',
            percentage = vote.map.percentage,
            visibleTo = rootElement,
            timeout = vote.map.timeout,
            allowchange = vote.map.allowchange;
            [1]={'Yes',call,getResourceFromName("mapmanager"),"changeGamemodeMap",compatibleMaps[math.random(1, #compatibleMaps)]},
            [2]={"No",outputVoteManager,"votemap: not enough votes to change to a random map on this gamemode.",rootElement,vR,vG,vB;default=true},
        }), true

	-- a map, a gamemode: vote for that pair
	elseif map and gamemode then
		if exports.mapmanager:isMapCompatibleWithGamemode(map, gamemode) then
			local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
			local mapName = getResourceInfo(map, "name") or getResourceName(map)
			return (startPoll{
                title = "Change mode to "..gamemodeName.." on map "..mapName.."?",
				percentage = vote.map.percentage,
				visibleTo = rootElement,
				timeout = vote.map.timeout,
				allowchange = vote.map.allowchange;
				[1]={"Yes",call,getResourceFromName("mapmanager"),"changeGamemodeMap",map,gamemode},
				[2]={"No",outputVoteManager,"votemap: not enough votes to change to '"..gamemodeName.."' on map '"..mapName.."'.",rootElement,vR,vG,vB;default=true},
			}), true
		else
			return false, errorCode.mapIsntCompatible
		end

	-- no map, a gamemode: vote between compatible maps for that gamemode
	elseif not map and gamemode then
		return voteBetweenGamemodeCompatibleMaps(gamemode)

	-- a map, no gamemode: vote to change current gamemode map
	elseif map and not gamemode then
		local runningGamemode = exports.mapmanager:getRunningGamemode()
		if not runningGamemode then
			return false, errorCode.noGamemodeRunning
		end

		if exports.mapmanager:isMapCompatibleWithGamemode(map, runningGamemode) then
			local mapName = getResourceInfo(map, "name") or getResourceName(map)
			return (startPoll{
				title="Change map to "..mapName.."?",
				percentage = vote.map.percentage,
				visibleTo = rootElement,
				timeout = vote.map.timeout,
				allowchange = vote.map.allowchange;
				[1]={"Yes",call,getResourceFromName("mapmanager"),"changeGamemodeMap",map,runningGamemode},
				[2]={"No",outputVoteManager,"votemap: not enough votes to change to map '"..mapName.."'.",rootElement,vR,vG,vB;default=true},
			}), true
		else
			return false, errorCode.mapIsntCompatible
		end

	-- no map, no gamemode: vote between compatible maps for the running gamemode
	else
		local runningGamemode = exports.mapmanager:getRunningGamemode()
		if runningGamemode then
			return voteBetweenGamemodeCompatibleMaps(runningGamemode)
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
		else
			reason = ""
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
		else
			reason = ""
		end
		return startPoll{
			title=title,
			percentage = vote.ban.percentage,
			visibleTo = rootElement,
			timeout = vote.ban.timeout,
			allowchange = vote.ban.allowchange;
			[1]={"Yes",banPlayer,player,vote.ban.banip,vote.ban.banusername,vote.ban.banserial,serverConsole,reason,vote.ban.duration},
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
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
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
				exports.mapmanager:isGamemode(gamemode) and exports.mapmanager:isMap(map)
			and not
				(exports.mapmanager:getRunningGamemode() == gamemode and exports.mapmanager:getRunningGamemodeMap() == map)
			then
				local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
				local mapName = getResourceInfo(map, "name") or getResourceName(map)
				table.insert(poll,{gamemodeName.." + "..mapName, call, getResourceFromName("mapmanager"), "changeGamemodeMap", map, gamemode})
				i = i + 1
			end
		else
			if exports.mapmanager:isGamemode(gamemode) and not exports.mapmanager:getRunningGamemode() == gamemode then
				local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
				table.insert(poll,{gamemodeName, call, getResourceFromName("mapmanager"), "changeGamemode", gamemode})
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
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
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

		if exports.mapmanager:isGamemode(gamemode) then
			local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode(gamemode)
			local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
			--start a map vote if there are 2+ maps for the mode
			if #compatibleMaps > 1 then
				table.insert(poll,{gamemodeName, voteBetweenGamemodeCompatibleMaps, gamemode})
			--start with the only map if there is only one map for the mode
			elseif #compatibleMaps == 1 then
				table.insert(poll,{gamemodeName, call, getResourceFromName("mapmanager"), "changeGamemode", gamemode, compatibleMaps[1]})
			else
				table.insert(poll,{gamemodeName, call, getResourceFromName("mapmanager"), "changeGamemode", gamemode})
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
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
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
		if exports.mapmanager:isMap(map) then
			local mapName = getResourceInfo(map, "name") or getResourceName(map)
			table.insert(poll,{mapName, call, getResourceFromName("mapmanager"), "changeGamemodeMap", map})
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
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
	local compatibleMaps = exports.mapmanager:getMapsCompatibleWithGamemode(gamemode)

	-- limit it to eight random maps
	if #compatibleMaps > 8 then
		math.randomseed(getTickCount())
		repeat
			table.remove(compatibleMaps, math.random(1, #compatibleMaps))
		until #compatibleMaps == 8
	elseif #compatibleMaps < 2 then
        local gamemodeName = getResourceInfo(gamemode, "name") or getResourceName(gamemode)
        if #compatibleMaps == 1 then
            local mapName = getResourceInfo(compatibleMaps[1], "name") or getResourceName(compatibleMaps[1])
            return (startPoll{
                title = "Change mode to "..gamemodeName.." on map "..mapName.."?",
                percentage = vote.map.percentage,
                visibleTo = rootElement,
                timeout = vote.map.timeout,
                allowchange = vote.map.allowchange;
                [1]={"Yes",call,getResourceFromName("mapmanager"),"changeGamemodeMap",compatibleMaps[1],gamemode},
                [2]={"No",outputVoteManager,"votemap: not enough votes to change to '"..gamemodeName.."' on map '"..mapName.."'.",rootElement,vR,vG,vB;default=true},
            }), true
        elseif #compatibleMaps < 1 then
            return (startPoll{
                title = "Change mode to "..gamemodeName.."?",
                percentage = vote.map.percentage,
                visibleTo = rootElement,
                timeout = vote.map.timeout,
                allowchange = vote.map.allowchange;
                [1]={"Yes",call,getResourceFromName("mapmanager"),"changeGamemode",gamemode},
                [2]={"No",outputVoteManager,"votemap: not enough votes to change to '"..gamemodeName.."'.",rootElement,vR,vG,vB;default=true},
            }), true
        end
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
		table.insert(poll, {mapName, call, getResourceFromName("mapmanager"), "changeGamemodeMap", map, gamemode})
	end

	table.insert(poll, DONT_CHANGE_OPTION)

	mapOptions = #poll - 1
	local success = startPoll(poll)
	if success then
		addEventHandler("onPollEnd", rootElement, chooseRandomMap)
	end
	return success
end

--Find a player which matches best
function getPlayerByNamepart(namePart)
	if not namePart then return false end
	-- Before searching see if somebody already has the exact name specified
	if getPlayerFromName(namePart) then
		return getPlayerFromName(namePart)
	end
	namePart = string.lower(namePart)
	--escape all metachars
	namePart = string.gsub(namePart, "([%*%+%?%.%(%)%[%]%{%}%\%/%|%^%$%-])","%%%1")
	local playername
	local bestaccuracy = 0
	local foundPlayer, b, e
	for _,player in ipairs(getElementsByType("player")) do
		b,e = string.find(string.lower(getPlayerName(player)), namePart)
		if b and e then
			if e-b > bestaccuracy then
				bestaccuracy = e-b
				foundPlayer = player
			end
		end
	end

	return foundPlayer or false
end

--Find a map which matches, or nil and a text message if there is not one match
function findMap( query, gamemode)
	local maps = findMaps( query, gamemode )

	-- Make status string
	local status = "Found " .. #maps .. " match" .. ( #maps==1 and "" or "es" )
	for i=1,math.min(5,#maps) do
		status = status .. ( i==1 and ": " or ", " ) .. "'" .. getMapName( maps[i] ) .. "'"
	end
	if #maps > 5 then
		status = status .. " (" .. #maps - 5 .. " more)"
	end

	if #maps == 0 then
		return nil, status .. " for '" .. query .. "'"
	end
	if #maps == 1 then
		return maps[1], status
	end
	if #maps > 1 then
		return nil, status
	end
end

-- Find all maps which match the query string
function findMaps( query, gamemode )
	if not getResourceFromName("mapmanager") or getResourceState(getResourceFromName("mapmanager")) ~= "running" then
		return outputDebugString("Votemanager did not function correctly because the \'mapmanager\' resource isn't running.",0)
	end
	local results = {}
	--escape all meta chars
	query = string.gsub(query, "([%*%+%?%.%(%)%[%]%{%}%\%/%|%^%$%-])","%%%1")
	-- Loop through and find matching maps
	local maps = gamemode and exports.mapmanager:getMapsCompatibleWithGamemode(gamemode) or exports.mapmanager:getMaps()
	for i,resource in ipairs(maps) do
		local resName = getResourceName( resource )
		local infoName = getMapName( resource  )

		-- Look for exact match first
		if query == resName or query == infoName then
			return {resource}
		end

		-- Find match for query within infoName
		if string.find( infoName:lower(), query:lower() ) then
			table.insert( results, resource )
		end
	end
	return results
end

function getMapName( map )
	return getResourceInfo( map, "name" ) or getResourceName( map ) or "unknown"
end

addCommandHandler("stopvote",
	function(player)
		if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
			stopPoll()
		end
	end
)
