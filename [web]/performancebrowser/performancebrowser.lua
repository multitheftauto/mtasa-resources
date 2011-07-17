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
