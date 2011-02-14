--
-- targetmanager.lua
--

---------------------------------------------------------------------------
--
-- Target manager
--
--
--
---------------------------------------------------------------------------
targetList = {}

addEvent('onNotifyTargetEnabled', true)
addEventHandler('onNotifyTargetEnabled', resourceRoot,
	function( bEnabled, a, b )
		if bEnabled then
			addTarget( client )
			local target = getTarget( client )
			target.resultCategories = {}
			target.resultCategories.a = a
			target.resultCategories.b = b
		else
			delTarget ( client )
		end
	end
)


addEventHandler('onResourceStart', resourceRoot,
	function( resource )
		addTarget ( "server" )
	end
)

addEventHandler('onPlayerQuit', root,
	function()
		delTarget ( source )
	end
)


function getPlayerKey ( player )
	if type(player) == 'string' then
		return root
	else
		return player
	end
end


function getPlayerTag ( player )
	if type(player) == 'string' then
		return player
	else
		return "client: "..getPlayerName(player)
	end
end


function isTarget ( player )
	return targetList[getPlayerKey(player)] ~= nil
end

function addTarget ( player )
	targetList[getPlayerKey(player)] = Target:create(player,getPlayerKey(player),getPlayerTag(player))
end

function delTarget ( player )
	if targetList[getPlayerKey(player)] then
		targetList[getPlayerKey(player)]:destroy()
		targetList[getPlayerKey(player)] = nil
	end
end

function getTarget ( player )
	if not targetList[getPlayerKey(player)] then
		-- Add new
		targetList[getPlayerKey(player)] = Target:create(player,getPlayerKey(player))
	end
	return targetList[getPlayerKey(player)]
end

function getTargetFromName ( name )
	for _,target in pairs(targetList) do
		if target.name == name then
			return target
		end
	end
	return nil
end

function getTargetNameList ()
	local result = {}
	for _,target in pairs(targetList) do
		table.insert( result, target.name )
	end
	return result
end

function getTargetIndex ( t )
	local idx = 1
	for _,target in pairs(targetList) do
		if target == t then
			return idx
		end
		idx = idx + 1
	end
	return 1
end

function getTargetNameIndex ( name )
	return getTargetIndex ( getTargetFromName ( name ) )
end


function validateTarget ( t )
	for i,target in pairs(targetList) do
		if target == t then
			return t
		end
	end
	for i,target in pairs(targetList) do
		return target
	end
	return nil
end
