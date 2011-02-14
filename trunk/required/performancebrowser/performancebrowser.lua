--
--
-- performancebrowser.lua
--
--


-- Browser wants to know what targets to put in the list
function getTargets ( user )
	--return getTargetNameList ()
	local viewer = getViewer(user)
	return viewer:getTargets()
end


-- Browser wants to know what categories to put in the list
function getCategories ( user )
	local viewer = getViewer(user)
	return viewer:getCategories()
end


-- Browser has changed display request
function setQuery ( user, target, category, options, filter )
	local viewer = getViewer(user)
	return viewer:setQuery ( target, category, options, filter )
end

-- Browser wants columns to display
function getHttpColumns ( user )
	local viewer = getViewer(user)
	return viewer:getHttpColumns ()
end

-- Browser wants rows to display
function getHttpRows( user )
	local viewer = getViewer(user)
	return viewer:getHttpRows ()
end

-- Browser wants selection indices
function getSelected( user )
	local viewer = getViewer(user)
	return viewer:getSelected ()
end
