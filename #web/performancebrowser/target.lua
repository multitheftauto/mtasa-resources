--
-- target.lua
--

Target = {}
Target.__index = Target
Target.instances = {}

---------------------------------------------------------------------------
--
-- Target:create()
--
--
--
---------------------------------------------------------------------------
function Target:create(player,key,name)
	local id = #Target.instances + 1
	Target.instances[id] = setmetatable(
		{
			id = id,
			player			= player,
			key				= key,
			name			= name,
			bSupportsStats	= true,
			resultCategories = {},
			resultStats		= {},
		},
		self
	)

	Target.instances[id]:postCreate()
	return Target.instances[id]
end


---------------------------------------------------------------------------
--
-- Target:postCreate()
--
--
--
---------------------------------------------------------------------------
function Target:postCreate()
	self.bIsServer = type(self.player) == 'string'
	if self.bIsServer then
		self.bSupportsStats = getPerformanceStats ~= nil
	end
end


---------------------------------------------------------------------------
--
-- Target:destroy()
--
--
--
---------------------------------------------------------------------------
function Target:destroy()
	Target.instances[self.id] = nil
	self.id = 0
end


---------------------------------------------------------------------------
--
-- Target:getPerformanceStats()
--
--
--
---------------------------------------------------------------------------
function Target:getPerformanceStats( username, queryCategoryName, queryOptionsText, queryFilterText )
	if self.bIsServer then
		local a, b = getPerformanceStats ( queryCategoryName, queryOptionsText, queryFilterText )
		return a, b, true
	else
		if queryCategoryName == "" then
			return self:getCategoriesFromRemote( username )
		else
			return self:getStatsFromRemote( username, queryCategoryName, queryOptionsText, queryFilterText )
		end
	end
end


---------------------------------------------------------------------------
--
-- Target:getCategoriesFromRemote()
--
--
--
---------------------------------------------------------------------------
function Target:getCategoriesFromRemote( username )
	--triggerClientEvent( self.player, "onClientRequestCategories", self.player )
	return self.resultCategories.a, self.resultCategories.b, true
end

--[[
addEvent('onNotifyCategories', true)
addEventHandler('onNotifyCategories', resourceRoot,
	function( a, b )
		local target = getTarget( client )
		target.resultCategories = {}
		target.resultCategories.a = a
		target.resultCategories.b = b
	end
)
--]]

---------------------------------------------------------------------------
--
-- Target:getResultsStoreForUsername()
--
--
--
---------------------------------------------------------------------------
function Target:getResultsStoreForUsername( username, bClear )
	if not self.resultStatList then
		self.resultStatList = {}
	end
	if not self.resultStatList[username] or bClear then
		self.resultStatList[username] = {}
	end
	return self.resultStatList[username]
end

---------------------------------------------------------------------------
--
-- Target:getStatsFromRemote()
--
--
--
---------------------------------------------------------------------------
function Target:getStatsFromRemote( username, queryCategoryName, queryOptionsText, queryFilterText )
	triggerClientEvent( self.player, "onClientRequestStats", self.player, username, queryCategoryName, queryOptionsText, queryFilterText )
	local store = self:getResultsStoreForUsername( username )
	local age = getTickCount() - ( store.timeAdded or 0 )
	local bUptoDate = ( store.queryCategoryName == queryCategoryName and
						store.queryOptionsText == queryOptionsText and
						store.queryFilterText == queryFilterText and
						age < 10000 )
	return store.a, store.b, bUptoDate
end

addEvent('onNotifyStats', true)
addEventHandler('onNotifyStats', resourceRoot,
	function( a, b, username, queryCategoryName, queryOptionsText, queryFilterText )
		local target = getTarget( client )
		local store = target:getResultsStoreForUsername( username, true )
		store.a = a
		store.b = b
		store.queryCategoryName = queryCategoryName
		store.queryOptionsText = queryOptionsText
		store.queryFilterText = queryFilterText
		store.timeAdded = getTickCount()
	end
)

