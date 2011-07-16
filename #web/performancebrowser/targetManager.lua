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

function getTargetFromName ( name, showClients )
	for _,target in pairs(targetList) do
		if target.name == name then
			if showClients == "true" or target.name == "server" then
				return target
			end
		end
	end
	return nil
end

function getTargetNameList ( showClients )
	local result = {}
	for _,target in pairs(targetList) do
		if showClients == "true" or target.name == "server" then
			table.insert( result, target.name )
		end
	end
	return result
end

function getTargetIndex ( t, showClients )
	local idx = 1
	for _,target in pairs(targetList) do
		if target == t then
			if showClients == "true" or target.name == "server" then
				return idx
			end
		end
		idx = idx + 1
	end
	return 1
end

function validateTarget ( t, showClients )
	for i,target in pairs(targetList) do
		if target == t then
			if showClients == "true" or target.name == "server" then
				return t
			end
		end
	end
	for i,target in pairs(targetList) do
		if showClients == "true" or target.name == "server" then
			return target
		end
	end
	return nil
end
