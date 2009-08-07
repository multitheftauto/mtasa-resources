--
-- util_ts_client.lua
--

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




