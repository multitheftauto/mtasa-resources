--
-- viewermanager.lua
--

---------------------------------------------------------------------------
--
-- Viewer manager
--
--
--
---------------------------------------------------------------------------
viewerList = {}

function isViewer ( name )
	return viewerList[name] ~= nil
end

function addViewer ( name )
	viewerList[name] = Viewer:create(name)
end

function delViewer ( name )
	if viewerList[name] then
		viewerList[name]:destroy()
		viewerList[name] = nil
	end
end

function getViewer ( name )
	-- Expire old
	for _,viewer in pairs(viewerList) do
		if viewer:getSecondsSinceLastUsed () > 600 then
			delViewer (	name )
		end
	end
	if not viewerList[name] then
		-- Add new
		viewerList[name] = Viewer:create(name)
	end
	return viewerList[name]
end

