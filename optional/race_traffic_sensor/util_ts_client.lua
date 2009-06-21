--
-- util_ts_client.lua
--

g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_Me = getLocalPlayer()


addEvent('onClientCall_rts', true)
addEventHandler('onClientCall_rts', getRootElement(),
	function(fnName, ...)
		local fn = _G
		local path = fnName:split('.')
		for i,pathpart in ipairs(path) do
			fn = fn[pathpart]
		end
		if not fn then
			outputDebugString( 'onClientCall_rts fn is nil for ' .. tostring(fnName) )
		else
			fn(...)
		end
	end
)

function createServerCallInterface()
	return setmetatable(
		{},
		{
			__index = function(t, k)
				t[k] = function(...) triggerServerEvent('onServerCall_rts', g_Me, k, ...) end
				return t[k]
			end
		}
	)
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
			outputConsole( getTickTimeStr() .. ' cDEBUG_rts: ' .. msg )
			outputDebugString( getTickTimeStr() .. ' cDEBUG_rts: ' .. msg )
		end
	end
	if g_bPipeDebug then
		outputConsole( getTickTimeStr() .. ' cDEBUG_rts: ' .. (msg or chan) )
	end
end

function outputWarning( msg )
	outputConsole( getTickTimeStr() .. ' cWARNING_rts: ' .. msg )
	outputDebugString( getTickTimeStr() .. ' cWARNING_rts: ' .. msg )
end




