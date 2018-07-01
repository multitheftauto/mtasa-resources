--
-- config_server.lua
--

--------------------------------
-- The Command
--------------------------------
addCommandHandler('config',
    function(player)
		if not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		triggerClientEvent( player, 'onClientOpenConfig', player )
    end
)

--------------------------------
-- Response for client
--------------------------------
addEvent('onRequestAddonsInfo', true )
addEventHandler('onRequestAddonsInfo', g_ResRoot,
	function()
		if checkClient( true, source, 'onRequestAddonsInfo' ) then return end
		local addonsInfoMap = getAddonsInfo()
		triggerClientEvent( source, 'onClientReceiveAddonsInfo', source, addonsInfoMap )
	end
)

addEvent('onRequestAddonsChange', true )
addEventHandler('onRequestAddonsChange', g_ResRoot,
	function(addonsInfoMap)
		if checkClient( true, source, 'onRequestAddonsChange' ) then return end
		setAddonsInfo( addonsInfoMap );
	end
)


--------------------------------
-- Get info about addons running or not
--------------------------------
function getAddonsInfo()
	-- Find availible
	local addonsInfoMap = {}
	for _, resource in ipairs(getResources()) do
		if getResourceInfo ( resource, 'addon' ) == 'race' then
			local info = {}
			info.name = getResourceName ( resource )
			info.tag = getResourceInfo ( resource, 'name' ) or getResourceName(resource)
			info.build = getResourceInfo ( resource, 'build' ) or ''
			info.version = getResourceInfo ( resource, 'version' ) or ''
			info.author = getResourceInfo ( resource, 'author' ) or ''
			info.description = getResourceInfo ( resource, 'description' ) or ''
			info.enabled = false
			info.state = getResourceState ( resource )
			addonsInfoMap[info.name] = info
		end
	end
	-- Find active
	for idx,name in ipairs(string.split(getString('race.addons'),',')) do
		if addonsInfoMap[name] then
			addonsInfoMap[name].enabled = true
		end
	end
	return addonsInfoMap
end


--------------------------------
-- Set active addons
--------------------------------
function setAddonsInfo(newAddonsInfoMap)
	local oldAddonsInfoMap = getAddonsInfo()

	-- compile setting from enabled items
	local activeList = {}
	for _,info in pairs(newAddonsInfoMap) do
		if info.enabled then
			table.insert( activeList, info.name )
		end
	end
	local setting = table.concat(activeList,",")
	set('*addons',setting)

	-- Stop or start addons as required
	for _,newInfo in pairs(newAddonsInfoMap) do
		for _,oldInfo in pairs(oldAddonsInfoMap) do
			if oldInfo.name == newInfo.name and oldInfo.enabled ~= newInfo.enabled then
				local resource = getResourceFromName( newInfo.name )
				if newInfo.enabled then
					if getResourceState(resource) ~= 'running' then
						startResource(resource)
					end
				else
					if getResourceState(resource) == 'running' then
						stopResource(resource)
					end
				end
			end
		end
	end
end

