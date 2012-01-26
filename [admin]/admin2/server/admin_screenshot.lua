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
addEventHandler ( EVENT_SCREEN_SHOT, _root, function ( action, id, ... )
	if ( action == SCREENSHOT_SAVE ) then
		
	elseif ( action == SCREENSHOT_DELETE ) then

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
			account = string.gsub ( getPlayerName ( admin ), '#%x%x%x%x%x%x', '' )
		else
			account = getAccountName ( acc )
		end
	end
	aScreenShots.pending[tag] = { player = player, playername = getPlayerName ( player ), admin = admin, account = account, timeout = timeout }
end

local function collectTimedOutScreenShots ()
	for tag, data in pairs ( aScreenShots.pending ) do
		local timeout = data.timeout
		if ( ( not timeout ) or ( getTickCount () > timeout ) ) then
			aScreenShots.pending[tag] = nil
		end
	end
end

local function removeTempScreenShots ()
	local query = db.query ( "SELECT file FROM screenshots WHERE temp = 1" )
	if ( query ) then
		for i, row in ipairs ( query ) do
			if ( fileExists ( "screenshots\\"..row.file ) ) then
				fileDelete ( "screenshots\\"..row.file )
			end
		end
	end
	db.exec ( "DELETE FROM screenshots WHERE temp = 1" )
end

local function getFileFriendlyName ( string )
	if ( not string ) then
		return ""
	end
	local result = ""
	for s in string.gmatch ( string, "%a+" ) do
		result = result..s
	end
	return result
end

addEventHandler ( "onResourceStart", getResourceRootElement (), function ()
	db.exec ( "CREATE TABLE IF NOT EXISTS screenshots ( file TEXT, player TEXT, admin TEXT, description TEXT, time INTEGER, temp BOOL )" )
	removeTempScreenShots ()
end )

addEventHandler ( "onPlayerScreenShot", _root, function ( resource, status, jpeg, time, tag )
	collectTimedOutScreenShots ()
	if ( resource ~= getThisResource () ) then
		return
	end
	
	local data = aScreenShots.pending[tag]
	if ( not data ) then
		return
	end

	local id = 0
	if ( status == "ok" ) then
		-- save a local copy
		local time = getRealTime ()
		local file_time = string.format ( "%.2d-%.2d-%.2d_%.2d-%.2d-%.2d", time.year + 1900, time.month + 1, time.monthday, time.hour, time.minute, time.second )

		local file_counter = 1
		local file_player = getFileFriendlyName ( data.playername )
		if ( file_player == "" ) then file_player = "screen" end
		local file_name = file_player..'_'..file_time..'.jpg'
		while ( fileExists ( "screenshots\\"..file_name ) ) do
			file_name = file_player..'_'..file_time..'_'..file_counter..'.jpg'
			file_counter = file_counter + 1
		end

		local file = fileCreate ( "screenshots\\"..file_name )
		if ( file ) then
			fileWrite ( file, jpeg )
			fileClose ( file )

			local query = "INSERT INTO screenshots (file,player,admin,description,time,temp) VALUES (?,?,?,?,?,?)"
			db.exec ( query, file_name,
					     data.playername or 'Unknown',
					     data.account or 'Unknown',
					     "Toady's driving like a boss",
					     time.timestamp,
					     0 )

			id = db.last_insert_id ()
		end
	else
		jpeg = nil
	end

	-- making sure the bastard didn't leave yet
	local admin = data.admin
	if ( ( not admin ) or ( not isElement ( admin ) ) or ( getElementType ( admin ) ~= 'player' ) ) then
		return
	end

	triggerClientEvent ( admin, EVENT_SCREEN_SHOT, admin, status, file_name, id, jpeg )
end )