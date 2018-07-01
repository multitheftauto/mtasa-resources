g_Root = getRootElement()

addEvent"onMapStarting"

GhostPlayback = {}
GhostPlayback.__index = GhostPlayback

function GhostPlayback:create( map )
	local result = {
		map = map,
		bestTime = math.huge,
		racer = "",
		recording = {},
		hasGhost = false,
		ped = nil,
		vehicle = nil,
		blip = nil
	}
	return setmetatable( result, self )
end

function GhostPlayback:destroy()
	if self.hasGhost then
		triggerClientEvent( "clearMapGhost", g_Root )
	end
	if isElement( self.ped ) then
		destroyElement( self.ped )
		outputDebug( "Destroyed ped." )
	end
	if isElement( self.vehicle ) then
		destroyElement( self.vehicle )
		outputDebug( "Destroyed vehicle." )
	end
	if isElement( self.blip ) then
		destroyElement( self.blip )
		outputDebug( "Destroyed blip." )
	end
	self = nil
end

function GhostPlayback:deleteGhost()
	local mapName = getResourceName( self.map )
	if fileExists( "ghosts/" .. mapName .. ".ghost" ) then
		fileDelete( "ghosts/" .. mapName .. ".ghost" )
		self:destroy()
		playback = nil
		return true
	end
	return false
end

function GhostPlayback:loadGhost()
	-- Load the old ghost if there is one
	local mapName = getResourceName( self.map )
	local ghost = xmlLoadFile( "ghosts/" .. mapName .. ".ghost" )

	-- Replace with backup if original doesn't exist
	if not ghost then
		local backup = xmlLoadFile( "ghosts/" .. mapName .. ".backup" )
		if backup then
			xmlUnloadFile( backup )
			copyFile( "ghosts/" .. mapName .. ".backup", "ghosts/" .. mapName .. ".ghost" )
			ghost = xmlLoadFile( "ghosts/" .. mapName .. ".ghost" )
			fileDelete( "ghosts/" .. mapName .. ".backup" )
		end
	end

	if ghost then
		-- Retrieve info about the ghost maker
		local info = xmlFindChild( ghost, "i", 0 )
		if info then
			self.racer = xmlNodeGetAttribute( info, "r" ) or "unknown"
			self.bestTime = tonumber( xmlNodeGetAttribute( info, "t" ) ) or math.huge
		end

		-- Construct a table
		local index = 0
		local node = xmlFindChild( ghost, "n", index )
		while (node) do
			if type( node ) ~= "userdata" then
				outputDebugString( "race_ghost - playback_server.lua: Invalid node data while loading ghost: " .. type( node ) .. ":" .. tostring( node ), 1 )
				self.recording = {}
				break
			end

			local attributes = xmlNodeGetAttributes( node )
			local row = {}
			for k, v in pairs( attributes ) do
				row[k] = convert( v )
			end
			table.insert( self.recording, row )
			index = index + 1
			node = xmlFindChild( ghost, "n", index )
		end
		xmlUnloadFile( ghost )

		-- Validate
		local bValidForMap = isBesttimeValidForMap( self.map, self.bestTime )
		local bValidForRecording = isBesttimeValidForRecording( self.recording, self.bestTime )
		if not bValidForMap or not bValidForRecording then
			-- Use backup file if it exists
			local backup = xmlLoadFile( "ghosts/" .. mapName .. ".backup" )
			if backup then
				xmlUnloadFile( backup )
				copyFile( "ghosts/" .. mapName .. ".ghost", "ghosts/" .. mapName .. ".invalid" )
				copyFile( "ghosts/" .. mapName .. ".backup", "ghosts/" .. mapName .. ".ghost" )
				fileDelete( "ghosts/" .. mapName .. ".backup" )
				outputDebugServer( "Trying backup as found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
				self.recording = {}
				return self:loadGhost()
			end
			if not bValidForMap then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for map. Error: " .. getMapBesttimeError( self.map, self.bestTime ) .. ")" )
			end
			if not bValidForRecording then
				outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
			end
			return false
		end

		-- Create the ped & vehicle
		for _, v in ipairs( self.recording ) do
			if v.ty == "st" then
				-- Check start is near a spawnpoint
				local bestDist = math.huge
				for _,spawnpoint in ipairs(getElementsByType("spawnpoint")) do
					bestDist = math.min( bestDist, getDistanceBetweenPoints3D( v.x, v.y, v.z, getElementPosition(spawnpoint) ) )
				end
				if bestDist > 5 then
					outputDebugServer( "Found an invalid ghost file", mapName, nil, " (Spawn point too far away - " .. bestDist .. ")" )
					return false
				end
				self.ped = createPed( v.p, v.x, v.y, v.z )
				self.vehicle = createVehicle( v.m, v.x, v.y, v.z, v.rX, v.rY, v.rZ )
				self.blip = createBlipAttachedTo( self.ped, 0, 1, 150, 150, 150, 50 )
				setElementParent( self.blip, self.ped )
				warpPedIntoVehicle( self.ped, self.vehicle )
                -- Disable client to server syncing to fix the ghost car jumping about
				setElementSyncer( self.ped, false )
				setElementSyncer( self.vehicle, false )
				outputDebugServer( "Found a valid ghost", mapName, nil, " (Besttime dif: " .. getRecordingBesttimeError( self.recording, self.bestTime ) .. ")" )
				self.hasGhost = true
				return true
			end
		end
	end
	outputDebugServer( "No ghost file", mapName, nil )
	return false
end

function GhostPlayback:sendGhostData( target )
	if self.hasGhost then
		triggerClientEvent( target or g_Root, "onClientGhostDataReceive", g_Root, self.recording, self.bestTime, self.racer, self.ped, self.vehicle )
	end
end

addEventHandler( "onMapStarting", g_Root,
	function()
		if playback then
			playback:destroy()
		end

		playback = GhostPlayback:create( exports.mapmanager:getRunningGamemodeMap() )
		playback:loadGhost()
		playback:sendGhostData()
	end
)

addEventHandler( "onPlayerJoin", g_Root,
	function()
		if playback then
			playback:sendGhostData( source )
		end
	end
)

function convert( value )
	if tonumber( value ) ~= nil then
		return tonumber( value )
	else
		if tostring( value ) == "true" then
			return true
		elseif tostring( value ) == "false" then
			return false
		else
			return tostring( value )
		end
	end
end
