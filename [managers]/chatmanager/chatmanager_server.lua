local chatTime = {}
local lastChatMessage = {}
local _getPlayerName = getPlayerName

function chatHandler(msg, type)
	if type == 0 then
		cancelEvent()
		if not hasObjectPermissionTo(source, "command.kick") and not hasObjectPermissionTo(source, "command.mute") then
			if chatTime[source] and chatTime[source] + tonumber(get("*mainChatDelay")) > getTickCount() then
				outputChatBox("Stop spamming main chat!", source, 255, 0, 0)
				return
			else
				chatTime[source] = getTickCount()
			end
			if get("*blockRepeatMessages") == "true" and lastChatMessage[source] and lastChatMessage[source] == msg then
				outputChatBox("Stop repeating yourself!", source, 255, 0, 0)
				return
			else
				lastChatMessage[source] = msg
			end
		end
		if isElement(source) then
			local r, g, b = 255, 255, 255
			if get("*nameColorMode") == "nametag" then
				r, g, b = getPlayerNametagColor(source)
			elseif get("*nameColorMode") == "team" then
				local team = getPlayerTeam(source)
				if (team) then
					r, g, b = getTeamColor(team)
				end
			end

			local playerName = getPlayerName(source)
			outputChatBox(playerName .. ': #FFFFFF' .. stripHex(msg), root, r, g, b, true)
			outputServerLog( "CHAT: " .. playerName .. ": " .. msg )
		end
	end
end
addEventHandler('onPlayerChat', root, chatHandler)

function quitHandler()
	chatTime[source] = nil
	lastChatMessage[source] = nil
end
addEventHandler('onPlayerQuit', root, quitHandler)

function getPlayerName(player)
	return get("*removeHex") and _getPlayerName(player):gsub("#%x%x%x%x%x%x","") or _getPlayerName(player)
end

function stripHex(str)
    local oldLen
    repeat
        oldLen = str:len()
        str = str:gsub('#%x%x%x%x%x%x', '')
    until str:len() == oldLen
    return str
end