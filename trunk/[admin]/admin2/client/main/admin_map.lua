--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\main\admin_map.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aMap = {
	check = 0,
	permission = true,
	players = false,
	coords = false,
	cursor = false,
	last = false
}

addEventHandler ( "onClientRender", _root, function ()
	if ( not isPlayerMapVisible () ) then
		if ( aMap.last ) then
			if ( aMap.cursor ) then
				aMap.cursor = false
				showCursor ( false )
			end
		end
		return
	end
	
	--local tick = getTickCount()
	--if ( tick > check ) then
	--	aMap.permission = hasPermissionTo ( "command.warp" )
	--	check = tick + 10000
	--end

	if ( not aMap.permission ) then
		return
	end

	aMap.last = true

	local sx, sy = guiGetScreenSize ()
	local cx, cy = sx / 2, sy - 70
	local text = "Hold RMB to show cursor\nPress num_7 to "..iif ( aMap.players, "hide", "show" ).." player names\nPress num_9 to "..iif ( aMap.coords, "hide", "show" ).." player coordinates"
	if ( aMap.cursor ) then text = text.."\nClick on the map to warp" end
	dxDrawText ( text, cx+1, cy+1, cx+1, cy+1, 0xFF000000, 1, "default", "center" )
	dxDrawText ( text, cx, cy, cx, cy, 0xFFFFFFFF, 1, "default", "center" )

	if ( aMap.players or aMap.coords ) then
		local minX, minY, maxX, maxY = getPlayerMapBoundingBox ()
		local sx, sy = guiGetScreenSize ()
		local msx, msy = -(minX-maxX), -(minY-maxY)

		for k, player in ipairs ( getElementsByType ( "player" ) ) do
			local x, y, z = getElementPosition ( player )
			if ( ( x >= -3000 and x <= 3000 ) and ( y >= -3000 and y <= 3000 ) ) then
				local px = minX + msx * ( ( 3000 + x ) / 6000 )
				local py = minY + msy * ( ( 3000 - y ) / 6000 )
				text = ""
				if ( aMap.players ) then
					text = getPlayerName ( player )
				end
				if ( aMap.coords ) then
					if ( aMap.players ) then text = text.."\n" end
					text = text..string.format ( "%.03f", x ).."\n"..string.format ( "%.03f", y ).."\n"..string.format ( "%.03f", z )
				end
				dxDrawText ( text, px+1, py+1, px+1, py+1, 0xFF000000 )
				dxDrawText ( text, px, py )
			end
		end
	end
end )

addEventHandler ( "onClientClick", _root, function ( button, state, x, y )
	if ( isPlayerMapVisible () and button == "left" ) then
		local minX, minY, maxX, maxY = getPlayerMapBoundingBox ()
		if ( ( x >= minX and x <= maxX ) and ( y >= minY and y <= maxY ) ) then
			local msx, msy = -(minX-maxX), -(minY-maxY)
			local px = 6000 * ( ( x - minX ) / msx ) - 3000
			local py = 3000 - 6000 * ( ( y - minY ) / msy )
			setElementPosition ( getLocalPlayer(), px, py, 10 )
		end
	end
end )

bindKey ( "mouse2", "both", function ( key, state )
	if ( isPlayerMapVisible () ) then
		showCursor ( state == "down" )
		aMap.cursor = state == "down"
	end
end )

bindKey ( "num_7", "down", function ( key, state )
	if ( isPlayerMapVisible () ) then
		aMap.players = not aMap.players
	end
end )

bindKey ( "num_9", "down", function ( key, state )
	if ( isPlayerMapVisible () ) then
		aMap.coords = not aMap.coords
	end
end )