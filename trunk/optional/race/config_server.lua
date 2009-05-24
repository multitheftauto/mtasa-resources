--
-- config_server.lua
--

--------------------------------
-- command hint on login
--------------------------------
addEventHandler("onPlayerLogin", root,
  function()
	local player = source
	if not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
		return
	end
	setTimer(
        function()
			outputChatBox ( "Type '/config' to configure race addons", player, 255, 127, 0 )
        end,
        500, 1 )
  end
)

--------------------------------
-- command hint on join (onPlayerJoin called at resource start for everyplayer by _joiner)
--------------------------------
addEventHandler('onPlayerJoin', g_Root,
	function()
		local player = source
		setTimer(
            function()
				if not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
					return
				end
				outputChatBox ( "Type '/config' to configure race addons", player, 255, 127, 0 )
            end,
            500, 1 )
	end
)

--------------------------------
-- The Command
--------------------------------
addCommandHandler('config',
    function(player)
		if not isPlayerInACLGroup(player, g_GameOptions.admingroup) then
			return
		end
		triggerClientEvent('onClientOpenConfig', player )
    end
)

--------------------------------
-- Response for client
--------------------------------
addEvent('onRequestAddonsInfo', true )
addEventHandler('onRequestAddonsInfo', g_ResRoot,
	function()
		local active, inactive = getAddonsInfo()
		triggerClientEvent('onClientReceiveAddonsInfo', source, active, inactive )
	end
)

addEvent('onRequestAddonsChange', true )
addEventHandler('onRequestAddonsChange', g_ResRoot,
	function(active, inactive)
		setAddonsInfo( active, inactive );
        exports.mapmanager:changeGamemode( getResourceFromName('race') )
	end
)


--------------------------------
-- Get info about addons running or not
--------------------------------
function getAddonsInfo()
	-- Find availible
	local availible = {}
	for _, resource in ipairs(getResources()) do
		if getResourceInfo ( resource, 'addon' ) == 'race' then
			table.insert(availible, getResourceName(resource) )
		end
	end
	-- Find active
	local active = {}
	for idx,name in ipairs(string.split(getString('race.addons'),',')) do
		if name ~= '' then
			local resource = getResourceFromName(name)
			if resource and getResourceInfo ( resource, 'addon' ) == 'race' then
				table.removevalue(availible, name )
				table.insert(active, name )
			end
		end
	end
	return active, availible
end


--------------------------------
-- Set active addons
--------------------------------
function setAddonsInfo(active, inactive)
	-- compile setting from active items
	local setting = table.concat(active,",")
	outputConsole( 'setting ' .. tostring(setting) )
	set('*addons',setting)
end

