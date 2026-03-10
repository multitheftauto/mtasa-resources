--
--
-- performancebrowser.lua
--
--

-- Browser update
function setQuery ( counter, user, target, category, options, filter, showClients )
	local viewer = getViewer(user)
	return viewer:setQuery ( counter, target, category, options, filter, showClients )
end

-- Start monitoring timer
if (g_LuaTimingRecordings.EnabledOnServer) then
	setTimer(saveHighCPUResources, g_LuaTimingRecordings.Frequency, 0)
end