--
-- util_tt_server.lua
--

g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())

function clientCall(player, fnName, ...)
	triggerClientEvent(onlyJoined(player), 'onClientCall_tt', player, fnName, ...)
end

function onlyJoined(player)
	return player
end


g_AllowedRPCFunctions = {}

function allowRPC(...)
	for i,name in ipairs({...}) do
		g_AllowedRPCFunctions[name] = true
	end
end

addEvent('onServerCall_tt', true)
addEventHandler('onServerCall_tt', getRootElement(),
	function(fnName, ...)
		if g_AllowedRPCFunctions[fnName] then
			local fn = _G
			for i,pathpart in ipairs(fnName:split('.')) do
				fn = fn[pathpart]
			end
			fn(...)
		end
	end
)


function isPlayerInACLGroup(player, groupName)
	local account = getPlayerAccount(player)
	if not account then
		return false
	end
	local accountName = getAccountName(account)
	for _,name in ipairs(string.split(groupName,',')) do
		local group = aclGetGroup(name)
		if group then
			for i,obj in ipairs(aclGroupListObjects(group)) do
				if obj == 'user.' .. accountName or obj == 'user.*' then
					return true
				end
			end
		end
	end
	return false
end


---------------------------------------------------------------------------
-- Version
---------------------------------------------------------------------------
function getBuildString()
	return getResourceInfo(getThisResource(), 'build') or 'n/a'
end

-----------------------------
-- Debug

function outputDebug( chan, msg )
	if _DEBUG_LOG then
		if not msg then
			msg = chan
			chan = 'UNDEF'
		end
		if table.find(_DEBUG_LOG,chan) then
			outputDebugString( getTickTimeStr() .. ' DEBUG_tt: ' .. msg )
		end
	end
	if g_PipeDebugTo then
		if not table.find(getElementsByType('player'), g_PipeDebugTo) then
			outputWarning( 'cleared g_PipeDebugTo' )
			g_PipeDebugTo = nil
		else
			outputConsole( getTickTimeStr() .. ' DEBUG_tt: ' .. (msg or chan), g_PipeDebugTo )
		end
	end
end


-- Always send to server window
-- and all client consoles
function outputWarning( msg )
	outputDebugString( getTickTimeStr() .. ' WARNING_tt: ' .. msg )
	outputConsole( getTickTimeStr() .. ' WARNING_tt: ' .. msg )
end

-- Always send to server window
-- and chat box window
function outputError( msg )
	outputDebugString( getTickTimeStr() .. ' ERROR_tt: ' .. msg )
	outputChatBox( getTickTimeStr() .. ' ERROR_tt: ' .. msg )
end


---------------------------------------------------------------------------
--
-- getRealDateTimeNowString()
--
-- current date and time as a sortable string
-- eg '2010-12-25 15:32:45'
--
---------------------------------------------------------------------------
function getRealDateTimeNowString()
	return getRealDateTimeString( getRealTime() )
end

function getRealDateTimeString( time )
	return string.format( '%04d-%02d-%02d %02d:%02d:%02d'
						,time.year + 1900
						,time.month + 1
						,time.monthday
						,time.hour
						,time.minute
						,time.second
						)
end


---------------------------------------------------------------------------
--
-- gets
--
---------------------------------------------------------------------------

-- get string or default
function getString(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return tostring(result)
end

-- get number or default
function getNumber(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return tonumber(result)
end

-- get true or false or default
function getBool(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return result == 'true'
end


---------------------------------------------------------------------------
--
-- Misc
--
---------------------------------------------------------------------------
-- Returns "name" or "name(accountname)" if they differ
function getAdminNameForLog(player)
	local name = getPlayerName( player )
	if not isGuestAccount( getPlayerAccount( player ) ) then
		local accountName = getAccountName( getPlayerAccount( player ) )
		if name ~= accountName then
			return name.."("..accountName..")"
		end
	end
	return name
end

