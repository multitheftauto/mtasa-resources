--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_screenshot.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aScreenShots = {
	pending = {},
	xml = nil,
	quality = {
		[SCREENSHOT_QLOW] = {
			w = 320,
			h = 240,
			q = 30,
			b = 2500,
		},
		[SCREENSHOT_QMEDIUM] = {
			w = 640,
			h = 480,
			q = 50,
			b = 2000,
		},
		[SCREENSHOT_QHIGH] = {
			w = 1024,
			h = 768,
			q = 70,
			b = 1500,
		}
	}
}

addEvent ( EVENT_SCREEN_SHOT, true )
addEventHandler ( EVENT_SCREEN_SHOT, _root, function ( action, tag )
	if ( action == SCREENSHOT_SAVE ) then
		local temp = xmlFindChild ( aScreenShots.xml, "temp", 0 )
		for id, node in ipairs ( xmlNodeGetChildren ( temp ) ) do
			local t = xmlNodeGetAttribute ( node, "tag" )
			if ( t == tag ) then
				xmlDestroyNode ( node )
			end
		end
	end
end )

function getPlayerScreen ( player, admin, q )
	if ( not q ) then q = SCREENSHOT_QLOW end
	local quality = aScreenShots.quality[q]
	if ( not quality ) then
		quality = aScreenShots.quality[SCREENSHOT_QLOW]
	end

	local tag = "a"..math.random ( 1, 1000 )
	while ( aScreenShots.pending[tag] ~= nil ) do
		tag = "a"..math.random ( 1, 1000 )
	end

	takePlayerScreenShot( player, quality.w, quality.h, tag, quality.q, quality.b )

	local timeout = getTickCount () + 1000 * 60 * 15
	local account = 'Unknown'
	if ( admin and isElement ( admin ) ) then
		local acc = getPlayerAccount ( admin )
		if ( isGuestAccount ( acc ) ) then
			account = getPlayerName ( admin )
		else
			account = getAccountName ( acc )
		end
	end
	aScreenShots.pending[tag] = { player = player, admin = admin, account = account, timeout = timeout }
end

local function collectTimedOutScreenShots ()
	for tag, data in pairs ( aScreenShots.pending ) do
		local timeout = data.timeout
		if ( ( not timeout ) or ( getTickCount () > timeout ) ) then
			aScreenShots.pending[tag] = nil
		end
	end
end

local function checkScreenShotCache ()
	-- lets see if we have anything to remove
	local temp = xmlFindChild ( aScreenShots.xml, "temp", 0 )
	if ( not temp ) then
		temp = xmlCreateChild ( aScreenShots.xml, "temp" )
	end

	for id, node in ipairs ( xmlNodeGetChildren ( temp ) ) do
		local file = xmlNodeGetAttribute ( node, "file" )
		if ( file ) then
			if ( fileExists ( file ) ) then
				fileDelete ( file )
			end
		end
		xmlDestroyNode ( node )
	end

	-- make sure the file list is up to date
	local list = xmlFindChild ( aScreenShots.xml, "list", 0 )
	if ( not list ) then
		list = xmlCreateChild ( aScreenShots.xml, "list" )
	end

	for id, node in ipairs ( xmlNodeGetChildren ( list ) ) do
		local file = xmlNodeGetAttribute ( node, "file" )
		if ( file ) then
			if ( not fileExists ( file ) ) then
				xmlDestroyNode ( node )
			end
		end
	end

	xmlSaveFile ( aScreenShots.xml )
end

addEventHandler ( "onResourceStart", getResourceRootElement (), function ()
	aScreenShots.xml = xmlLoadFile ( "conf\\screenshots.xml" )
	if ( not aScreenShots.xml ) then
		aScreenShots.xml = xmlCreateFile ( "conf\\screenshots.xml", "screenshots" )
		if ( not aScreenShots.xml ) then
			-- still failed? gtfo, no admin for you
			outputDebugString ( "Failed to load screenshots.xml. Stopping" )
			cancelEvent ()
			return
		end
	end
	checkScreenShotCache ()
end )

addEventHandler ( "onResourceStop", getResourceRootElement (), checkScreenShotCache )

addEventHandler ( "onPlayerScreenShot", _root, function ( resource, status, jpeg, time, tag )
	collectTimedOutScreenShots ()
	if ( resource ~= getThisResource () ) then
		return
	end
	
	local data = aScreenShots.pending[tag]
	if ( not data ) then
		return
	end

	-- making sure the bastard didn't leave yet
	local admin = data.admin
	if ( ( not admin ) or ( not isElement ( admin ) ) or ( getElementType ( admin ) ~= 'player' ) ) then
		return
	end

	if ( status == "ok" ) then
		-- save a local copy
		local time = getRealTime ()
		local file_time = time.year..'-'..( time.month + 1 )..'-'..time.monthday..'_'
		file_time = file_time..( time.hour + 1 )..'-'..time.minute..'-'..time.second

		local file_counter = 1
		local file_player = data.player and getPlayerName ( data.player ) or 'Unknown'
		local file_name = "screenshots\\"..file_player..'-'..file_time..'.jpg'
		while ( fileExists ( file_name ) ) do
			file_name = "screenshots\\"..file_player..'-'..file_time..'_'..file_counter..'.jpg'
			file_counter = file_counter + 1
		end

		local file = fileCreate ( file_name )
		if ( file ) then
			fileWrite ( file, jpeg )
			fileClose ( file )

			-- store it in the screenshots list
			local list = xmlFindChild ( aScreenShots.xml, "list", 0 )
			if ( list ) then
				local node = xmlCreateChild ( list, "screenshot" )
				if ( node ) then
					xmlNodeSetAttribute ( node, "file", file_name )
					xmlNodeSetAttribute ( node, "player", file_player )
					xmlNodeSetAttribute ( node, "admin", data.account or 'Unknown' )
					xmlNodeSetAttribute ( node, "time", time.timestamp )
				end
			end

			-- screenshot will be removed, unless admin tells us to save it
			local temp = xmlFindChild ( aScreenShots.xml, "temp", 0 )
			if ( not temp ) then
				temp = xmlCreateChild ( aScreenShots.xml, "temp" )
			end
			node = xmlCreateChild ( temp, "screenshot" )
			if ( node ) then
				xmlNodeSetAttribute ( node, "file", file_name )
				xmlNodeSetAttribute ( node, "tag", tag )
			end
			xmlSaveFile ( aScreenShots.xml )
		end
	else
		jpeg = nil
	end

	triggerClientEvent ( admin, EVENT_SCREEN_SHOT, admin, status, jpeg, tag )
end )