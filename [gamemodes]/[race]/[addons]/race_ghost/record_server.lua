addEvent( "onGhostDataReceive", true )

addEventHandler( "onGhostDataReceive", g_Root,
	function( recording, bestTime, racer, mapName )
		if not isBesttimeValidForRecording( recording, bestTime ) then
			outputDebugServer( "Received an invalid ghost recording", mapName, racer, " (Besttime not valid for recording. Error: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )
			return
		end

		outputDebugServer( "Saving ghost file", mapName, racer, " (Besttime dif: " .. getRecordingBesttimeError( recording, bestTime ) .. ")" )
		-- Create a backup in case of a cheater run
		local ghost = xmlLoadFile( "ghosts/" .. mapName .. ".ghost" )
		if ghost then
			local info = xmlFindChild( ghost, "i", 0 )
			local currentBestTime = math.huge
			if info then
				currentBestTime = tonumber( xmlNodeGetAttribute( info, "t" ) ) or math.huge
			end

			if currentBestTime ~= math.huge and currentBestTime - bestTime >= SUSPECT_CHEATER_LIMIT then -- Cheater?
				outputDebug( "Creating a backup file for " .. mapName .. ".backup" )
				copyFile( "ghosts/" .. mapName .. ".ghost", "ghosts/" .. mapName .. ".backup" )
			end
			xmlUnloadFile( ghost )
		end

		local ghost = xmlCreateFile( "ghosts/" .. mapName .. ".ghost", "ghost" )
		if ghost then
			local info = xmlCreateChild( ghost, "i" )
			if info then
				xmlNodeSetAttribute( info, "r", tostring( racer ) )
				xmlNodeSetAttribute( info, "t", tostring( bestTime ) )
			end

			for _, info in ipairs( recording ) do
				local node = xmlCreateChild( ghost, "n" )
				for k, v in pairs( info ) do
					if type(v) == "number" then
						xmlNodeSetAttribute( node, tostring( k ), math.floor(v * 10000 + 0.5) / 10000 )
					else
						xmlNodeSetAttribute( node, tostring( k ), tostring( v ) )
					end
				end
			end
			xmlSaveFile( ghost )
			xmlUnloadFile( ghost )
		else
			outputDebug( "Failed to create a ghost file!" )
		end
	end
)
