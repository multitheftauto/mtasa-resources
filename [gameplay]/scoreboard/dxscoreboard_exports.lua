MAX_PRIRORITY_SLOT = 500

scoreboardColumns = {
	{ ["name"] = "name", ["width"] = 200, ["friendlyName"] = "Name", ["priority"] = 1 },
	{ ["name"] = "ping", ["width"] = 40, ["friendlyName"] = "Ping", ["priority"] = MAX_PRIRORITY_SLOT },
}

resourceColumns = {}

function toboolean( bool )
	bool = tostring( bool )
	if bool == "true" then
		return true
	elseif bool == "false" then
		return false
	else
		return nil
	end
end

forceShowTeams = toboolean( get( "forceShowTeams" ) ) or false
forceHideTeams = toboolean( get( "forceHideTeams" ) ) or false
allowColorcodedNames = toboolean( get( "allowColorcodedNames" ) ) or false
showCountries = toboolean( get( "showCountries" ) ) or false
scrollStep = tonumber( get( "scrollStep" ) ) or 1

if showCountries then
	table.insert (scoreboardColumns, { ["name"] = "Country", ["width"] = 50, ["friendlyName"] = "Country", ["priority"] = MAX_PRIRORITY_SLOT-1, ["isImage"] = true, ["imageW"] = 18, ["imageH"] = 12 })
end

local function iif( cond, arg1, arg2 )
	if cond then
		return arg1
	end
	return arg2
end

--scoreboardAddColumn (dataName,source,width,friendlyName,priority,isImage,imageW,imageH)
function scoreboardAddColumn( name, forElement, width, friendlyName, priority, isImage, imageW, imageH )
	if type( name ) == "string" then
		width = tonumber( width ) or 70
		friendlyName = friendlyName or name
		priority = tonumber( priority ) or getNextFreePrioritySlot( scoreboardGetColumnPriority( "name" ) )
		fixPrioritySlot( priority )
		forElement = iif( type( forElement ) == "userdata" and isElement( forElement ), forElement, getRootElement() )

		if forElement == getRootElement() then
			if not (priority > MAX_PRIRORITY_SLOT or priority < 1) then
				for key, value in ipairs( scoreboardColumns ) do
					if name == value.name then
						return false
					end
				end
				table.insert( scoreboardColumns, { ["name"] = name, ["width"] = width, ["friendlyName"] = friendlyName, ["priority"] = priority, ["isImage"] = isImage, ["imageW"] = imageW, ["imageH"] = imageH } )
				table.sort( scoreboardColumns, function ( a, b ) return a.priority < b.priority end )
				if sourceResource then
					if not resourceColumns[sourceResource] then resourceColumns[sourceResource] = {} end
					table.insert ( resourceColumns[sourceResource], name )
				end
				return triggerClientEvent( getRootElement(), "doScoreboardAddColumn", getRootElement(), name, width, friendlyName, priority, sourceResource, isImage, imageW, imageH )
			end
		else
			return triggerClientEvent( forElement, "doScoreboardAddColumn", getRootElement(), name, width, friendlyName, priority, sourceResource, isImage, imageW, imageH )
		end
	end
	return false
end

function scoreboardRemoveColumn( name, forElement )
	if type( name ) == "string" then
		forElement = iif( type( forElement ) == "userdata" and isElement( forElement ), forElement, getRootElement() )

		if forElement == getRootElement() then
			for key, value in ipairs( scoreboardColumns ) do
				if name == value.name then
					table.remove( scoreboardColumns, key )
					for resource, content in pairs( resourceColumns ) do
						table.removevalue( content, name )
					end
					return triggerClientEvent( getRootElement(), "doScoreboardRemoveColumn", getRootElement(), name )
				end
			end
		else
			return triggerClientEvent( forElement, "doScoreboardRemoveColumn", getRootElement(), name )
		end
	end
	return false
end

function scoreboardClearColumns( forElement )
	forElement = iif( type( forElement ) == "userdata" and isElement( forElement ), forElement, getRootElement() )

	if forElement == getRootElement() then
		while ( scoreboardColumns[1] ) do
			table.remove( scoreboardColumns, 1 )
			resourceColumns = {}
		end
		return triggerClientEvent( getRootElement(), "doScoreboardClearColumns", getRootElement() )
	else
		return triggerClientEvent( forElement, "doScoreboardClearColumns", getRootElement() )
	end
end

function scoreboardResetColumns( forElement )
	forElement = iif( type( forElement ) == "userdata" and isElement( forElement ), forElement, getRootElement() )

	if forElement == getRootElement() then
		while ( scoreboardColumns[1] ) do
			table.remove( scoreboardColumns, 1 )
			resourceColumns = {}
		end
		local result = triggerClientEvent( getRootElement(), "doScoreboardResetColumns", getRootElement() )
		if result then
			scoreboardAddColumn( "name", 200, "Name" )
			scoreboardAddColumn( "ping", 40, "Ping" )
			scoreboardAddColumn( "Country", 50, "Country", 20, true, 12, 8 )
		end
		return result
	else
		return triggerClientEvent( forElement, "doScoreboardResetColumns", getRootElement(), false )
	end
end

function scoreboardSetForced( forced, forElement )
	if type( forced ) == "boolean" then
		forElement = iif( type( forElement ) == "userdata" and isElement( forElement ), forElement, getRootElement() )
		return triggerClientEvent( forElement, "doScoreboardSetForced", getRootElement(), forced )
	else
		return false
	end
end

function scoreboardSetSortBy( name, desc, forElement )
	if type( name ) == "string" or name == nil then
		if name == nil then
			forElement = iif( type( desc ) == "userdata" and isElement( desc ), desc, getRootElement() )
		else
			forElement = iif( type( forElement ) == "userdata" and isElement( forElement ), forElement, getRootElement() )
		end
		desc = iif( type( desc ) == "boolean", desc, true )
		return triggerClientEvent( forElement, "doScoreboardSetSortBy", getRootElement(), name, desc )
	else
		return false
	end
end

function scoreboardGetColumnPriority( name )
	if type( name ) == "string" then
		for key, value in ipairs( scoreboardColumns ) do
			if name == value.name then
				return value.priority
			end
		end
	end
	return false
end

function scoreboardSetColumnPriority( name, priority, forElement )
	if type( name ) == "string" and type( priority ) == "number" then
		if not (priority > MAX_PRIRORITY_SLOT or priority < 1) then
			forElement = iif( type( forElement ) == "userdata" and isElement( forElement ), forElement, getRootElement() )
			if forElement == getRootElement() then
				local columnIndex = false
				for key, value in ipairs( scoreboardColumns ) do
					if name == value.name then
						columnIndex = key
					end
				end
				if columnIndex then
					scoreboardColumns[columnIndex].priority = -1 -- To empty out the current priority
					fixPrioritySlot( priority )
					scoreboardColumns[columnIndex].priority = priority
					table.sort( scoreboardColumns, function ( a, b ) return a.priority < b.priority end )
					return triggerClientEvent( forElement, "doScoreboardSetColumnPriority", getRootElement(), name, priority )
				end
			else
				return triggerClientEvent( forElement, "doScoreboardSetColumnPriority", getRootElement(), name, priority )
			end
		end
	end
	return false
end

function scoreboardForceTeamsVisible( enabled )
	if type( enabled ) == "boolean" then
		forceShowTeams = enabled
		return true
	end
	return false
end

function scoreboardForceTeamsHidden( enabled )
	if type( enabled ) == "boolean" then
		forceHideTeams = enabled
		return true
	end
	return false
end

function scoreboardGetColumnCount()
	return #scoreboardColumns
end

function onClientDXScoreboardResourceStart()
	for key, column in ipairs( scoreboardColumns ) do
		triggerClientEvent( client, "doScoreboardAddColumn", getRootElement(), column.name, column.width, column.friendlyName, column.priority, nil, column.isImage, column.imageW, column.imageH )
	end
end
addEvent( "onClientDXScoreboardResourceStart", true )
addEventHandler( "onClientDXScoreboardResourceStart", getResourceRootElement( getThisResource() ), onClientDXScoreboardResourceStart )

function requestServerInfo()
	local mapmanager = getResourceFromName( "mapmanager" )
	local output = {}
	output.forceshowteams = forceShowTeams
	output.forcehideteams = forceHideTeams
	output.allowcolorcodes = allowColorcodedNames
	output.scrollStep = scrollStep
	output.server = getServerName()
	output.players = getMaxPlayers()
	output.gamemode = false
	output.map = false
	if mapmanager and getResourceState( mapmanager ) == "running" then
		local gamemode = exports.mapmanager:getRunningGamemode()
		if gamemode then
			output.gamemode = getResourceInfo( gamemode, "name" ) or getResourceName( gamemode )
		end
		local map = exports.mapmanager:getRunningGamemodeMap()
		if map then
			output.map = getResourceInfo( map, "name" ) or getResourceName( map )
		end
	end
	triggerClientEvent( client, "sendServerInfo", getRootElement(), output )
end
addEvent( "requestServerInfo", true )
addEventHandler( "requestServerInfo", getResourceRootElement( getThisResource() ), requestServerInfo )

function removeResourceScoreboardColumns( resource )
	if resourceColumns[resource] then
		while resourceColumns[resource][1] do
			local success = scoreboardRemoveColumn( resourceColumns[resource][1], getRootElement() )
			if not success then break end
		end
		resourceColumns[resource] = nil
	end
end
addEventHandler( "onResourceStop", getRootElement(), removeResourceScoreboardColumns )

-- Compability
addScoreboardColumn = 	function( name, forElement, position, size )
							if type( size ) == "number" and size >= 0 and size <= 1.0 then
								size = size*700
							end
							return scoreboardAddColumn( name, forElement, size, name, position )
						end
removeScoreboardColumn = scoreboardRemoveColumn
resetScoreboardColumns = scoreboardResetColumns
setPlayerScoreboardForced = function( forElement, forced ) return scoreboardSetForced( forced, forElement ) end
