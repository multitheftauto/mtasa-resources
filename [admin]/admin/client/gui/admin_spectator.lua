--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_spectator.lua
*
*	Original File by lil_Toady
*
**************************************]]

aSpectator = { Offset = 5, AngleX = 0, AngleZ = 30, Spectating = nil }

function aSpectate ( player )
	if ( player == getLocalPlayer() ) then
		aMessageBox ( "error", "Can not spectate yourself" )
		return
	end
	aSpectator.Spectating = player
    setElementFrozen ( getLocalPlayer(), true )
	if ( ( not aSpectator.Actions ) or ( not guiGetVisible ( aSpectator.Actions ) ) ) then
		aSpectator.Initialize ()
	end
end

function aSpectator.Initialize ()
	if ( aSpectator.Actions == nil ) then
		local x, y = guiGetScreenSize()
		aSpectator.Actions		= guiCreateWindow ( x - 190, y / 2 - 200, 160, 400, "Actions", false )
		aSpectator.Ban			= guiCreateButton ( 0.10, 0.09, 0.80, 0.05, "Ban", true, aSpectator.Actions )
		aSpectator.Kick			= guiCreateButton ( 0.10, 0.15, 0.80, 0.05, "Kick", true, aSpectator.Actions )
		aSpectator.Freeze			= guiCreateButton ( 0.10, 0.21, 0.80, 0.05, "Freeze", true, aSpectator.Actions )
		aSpectator.SetSkin		= guiCreateButton ( 0.10, 0.27, 0.80, 0.05, "Set Skin", true, aSpectator.Actions )
		aSpectator.SetHealth		= guiCreateButton ( 0.10, 0.33, 0.80, 0.05, "Set Health", true, aSpectator.Actions )
		aSpectator.SetArmour		= guiCreateButton ( 0.10, 0.39, 0.80, 0.05, "Set Armour", true, aSpectator.Actions )
		aSpectator.SetStats		= guiCreateButton ( 0.10, 0.45, 0.80, 0.05, "Set Stats", true, aSpectator.Actions )
		aSpectator.Slap			= guiCreateButton ( 0.10, 0.51, 0.80, 0.05, "Slap! "..aCurrentSlap.."hp", true, aSpectator.Actions )
		aSpectator.Slaps			= guiCreateGridList ( 0.10, 0.51, 0.80, 0.48, true, aSpectator.Actions )
					  		  guiGridListAddColumn( aSpectator.Slaps, "", 0.85 )
					  		  guiSetVisible ( aSpectator.Slaps, false )
		local i = 0
		while i <= 10 do
			guiGridListSetItemText ( aSpectator.Slaps, guiGridListAddRow ( aSpectator.Slaps ), 1, tostring ( i * 10 ), false, false )
			i = i + 1
		end
		
		aSpectator.Skip			= guiCreateCheckBox ( 0.08, 0.85, 0.84, 0.04, "Skip dead players", true, true, aSpectator.Actions )
					  		  guiCreateLabel ( 0.08, 0.89, 0.84, 0.04, "____________________", true, aSpectator.Actions )
		aSpectator.Back			= guiCreateButton ( 0.10, 0.93, 0.80, 0.05, "Back", true, aSpectator.Actions )
	
		aSpectator.Players		= guiCreateWindow ( 30, y / 2 - 200, 160, 400, "Players", false )
			  	  	  		  guiWindowSetSizable ( aSpectator.Players, false )
		aSpectator.PlayerList		= guiCreateGridList ( 0.03, 0.07, 0.94, 0.92, true, aSpectator.Players )
					  		  guiGridListAddColumn( aSpectator.PlayerList, "Player Name", 0.85 )
		for id, player in ipairs ( getElementsByType ( "player" ) ) do
			local row = guiGridListAddRow ( aSpectator.PlayerList )
			guiGridListSetItemPlayerName ( aSpectator.PlayerList, row, 1, getPlayerName ( player ), false, false )
			if ( player == aSpectator.Spectating ) then guiGridListSetSelectedItem ( aSpectator.PlayerList, row, 1 ) end
		end
		aSpectator.Prev			= guiCreateButton ( x / 2 - 100, y - 50, 70, 30, "< Previous", false )
		aSpectator.Next			= guiCreateButton ( x / 2 + 30,  y - 50, 70, 30, "Next >", false )

		addEventHandler ( "onClientGUIClick", _root, aSpectator.ClientClick )
		addEventHandler ( "onClientGUIDoubleClick", _root, aSpectator.ClientDoubleClick )

		aRegister ( "Spectator", aSpectator.Actions, aSpectator.ShowGUI, aSpectator.Close )
	end

	bindKey ( "arrow_l", "down", aSpectator.SwitchPlayer, -1 )
	bindKey ( "arrow_r", "down", aSpectator.SwitchPlayer, 1 )
	bindKey ( "mouse_wheel_up", "down", aSpectator.MoveOffset, -1 )
	bindKey ( "mouse_wheel_down", "down", aSpectator.MoveOffset, 1 )
	bindKey ( "mouse2", "both", aSpectator.Cursor )
	addEventHandler ( "onClientPlayerWasted", _root, aSpectator.PlayerCheck )
	addEventHandler ( "onClientPlayerQuit", _root, aSpectator.PlayerCheck )
	addEventHandler ( "onClientCursorMove", _root, aSpectator.CursorMove )
	addEventHandler ( "onClientPreRender", _root, aSpectator.Render )
	
	guiSetVisible ( aSpectator.Actions, true )
	guiSetVisible ( aSpectator.Players, true )
	guiSetVisible ( aSpectator.Next, true )
	guiSetVisible ( aSpectator.Prev, true )
	aAdminMenuClose ( false )
end

function aSpectator.Cursor ( key, state )
	if state == "down" then
		showCursor(true)
	else
		showCursor(false)
	end
end

function aSpectator.Close ( destroy )
	unbindKey ( "arrow_l", "down", aSpectator.SwitchPlayer, -1 )
	unbindKey ( "arrow_r", "down", aSpectator.SwitchPlayer, 1 )
	unbindKey ( "mouse_wheel_up", "down", aSpectator.MoveOffset, -1 )
	unbindKey ( "mouse_wheel_down", "down", aSpectator.MoveOffset, 1 )
	unbindKey ( "mouse2", "both", aSpectator.Cursor )
	removeEventHandler ( "onClientPlayerWasted", _root, aSpectator.PlayerCheck )
	removeEventHandler ( "onClientPlayerQuit", _root, aSpectator.PlayerCheck )
	removeEventHandler ( "onClientMouseMove", _root, aSpectator.CursorMove )
	removeEventHandler ( "onClientPreRender", _root, aSpectator.Render )

	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceSpectator ) ) ) then
		if ( aSpectator.Actions ) then
			removeEventHandler ( "onClientGUIClick", _root, aSpectator.ClientClick )
			removeEventHandler ( "onClientGUIDoubleClick", _root, aSpectator.ClientDoubleClick )
			destroyElement ( aSpectator.Actions )
			destroyElement ( aSpectator.Players )
			destroyElement ( aSpectator.Next )
			destroyElement ( aSpectator.Prev )
			aSpectator.Actions = nil
		end
	else
		guiSetVisible ( aSpectator.Actions, false )
		guiSetVisible ( aSpectator.Players, false )
		guiSetVisible ( aSpectator.Next, false )
		guiSetVisible ( aSpectator.Prev, false )
	end
	setCameraTarget ( getLocalPlayer() )
    local x, y, z = getElementPosition(getLocalPlayer())
    setElementPosition(getLocalPlayer(), x, y, z+1)
    setElementVelocity (getLocalPlayer(), 0, 0, 0)
    setElementFrozen ( getLocalPlayer(), false )
	aSpectator.Spectating = nil
	showCursor ( true )
	aAdminMenu()
end

function aSpectator.ClientDoubleClick ( button )
	if ( source == aSpectator.Slaps ) then
		if ( guiGridListGetSelectedItem ( aSpectator.Slaps ) ~= -1 ) then
			aCurrentSlap = guiGridListGetItemText ( aSpectator.Slaps, guiGridListGetSelectedItem ( aSpectator.Slaps ), 1 )
			guiSetText ( aTab1.Slap, "Slap! "..aCurrentSlap.."hp" )
			guiSetText ( aSpectator.Slap, "Slap! "..aCurrentSlap.."hp" )
		end
		guiSetVisible ( aSpectator.Slaps, false )
	end
end

function aSpectator.ClientClick ( button )
	if ( source == aSpectator.Slaps ) then return end
	guiSetVisible ( aSpectator.Slaps, false )
	if ( button == "left" ) then
		if ( source == aSpectator.Back ) then aSpectator.Close ( false )
		elseif ( source == aSpectator.Ban ) then triggerEvent ( "onClientGUIClick", aTab1.Ban, "left" )
		elseif ( source == aSpectator.Kick ) then triggerEvent ( "onClientGUIClick", aTab1.Kick, "left" )
		elseif ( source == aSpectator.Freeze ) then triggerEvent ( "onClientGUIClick", aTab1.Freeze, "left" )
		elseif ( source == aSpectator.SetSkin ) then triggerEvent ( "onClientGUIClick", aTab1.SetSkin, "left" )
		elseif ( source == aSpectator.SetHealth ) then triggerEvent ( "onClientGUIClick", aTab1.SetHealth, "left" )
		elseif ( source == aSpectator.SetArmour ) then triggerEvent ( "onClientGUIClick", aTab1.SetArmour, "left" )
		elseif ( source == aSpectator.SetStats ) then triggerEvent ( "onClientGUIClick", aTab1.SetStats, "left" )
		elseif ( source == aSpectator.Slap ) then triggerEvent ( "onClientGUIClick", aTab1.Slap, "left" )
		elseif ( source == aSpectator.Next ) then aSpectator.SwitchPlayer ( 1 )
		elseif ( source == aSpectator.Prev ) then aSpectator.SwitchPlayer ( -1 )
		elseif ( source == aSpectator.PlayerList ) then
			if ( guiGridListGetSelectedItem ( source ) ~= -1 ) then
				aSpectate ( getPlayerFromNick ( guiGridListGetItemPlayerName ( source, guiGridListGetSelectedItem ( source ), 1 ) ) )
			end
		end
	elseif ( button == "right" ) then
		if ( source == aSpectator.Slap ) then
			guiSetVisible ( aSpectator.Slaps, true )
		else
			local show = not isCursorShowing()
			guiSetVisible ( aSpectator.Actions, show )
			guiSetVisible ( aSpectator.Players, show )
			guiSetVisible ( aSpectator.Next, show )
			guiSetVisible ( aSpectator.Prev, show )
			showCursor ( show )
		end
	end
end

function aSpectator.PlayerCheck ()
	if ( source == aSpectator.Spectating ) then
		aSpectator.SwitchPlayer ( 1 )
	end
end

function aSpectator.SwitchPlayer ( inc, arg, inc2 )
	if ( not tonumber ( inc ) ) then inc = inc2 end
	if ( not tonumber ( inc ) ) then return end
	local players = {}
	if ( guiCheckBoxGetSelected ( aSpectator.Skip ) ) then players = aSpectator.GetAlive()
	else players = getElementsByType ( "player" ) end
	if ( #players <= 0 ) then
		aMessageBox ( "question", "Nobody to spectate, exit spectator?", "aSpectator.Close ( false )" )
		return
	end
	local current = 1
	for id, player in ipairs ( players ) do
		if ( player == aSpectator.Spectating ) then
			current = id
		end
	end
	local next = ( ( current - 1 + inc ) % #players ) + 1
	if ( next == current ) then
		aMessageBox ( "question", "Nobody else to spectate, exit spectator?", "aSpectator.Close ( false )" )
		return
	end
	aSpectator.Spectating = players[next]
    setElementFrozen ( getLocalPlayer(), true )
end

function aSpectator.CursorMove ( rx, ry, x, y )
	if ( not isCursorShowing() ) then
		local sx, sy = guiGetScreenSize ()
		aSpectator.AngleX = ( aSpectator.AngleX + ( x - sx / 2 ) / 10 ) % 360
		aSpectator.AngleZ = ( aSpectator.AngleZ + ( y - sy / 2 ) / 10 ) % 360
		if ( aSpectator.AngleZ > 180 ) then
			if ( aSpectator.AngleZ < 315 ) then aSpectator.AngleZ = 315 end
		else
			if ( aSpectator.AngleZ > 45 ) then aSpectator.AngleZ = 45 end
		end
	end
end

function aSpectator.Render ()
	local sx, sy = guiGetScreenSize ()
	if ( not aSpectator.Spectating ) then
		dxDrawText ( "Nobody to spectate", sx - 170, 200, sx - 170, 200, tocolor ( 255, 0, 0, 255 ), 1 )
		return
	end

	local x, y, z = getElementPosition ( aSpectator.Spectating )

	if ( not x ) then
		dxDrawText ( "Error recieving coordinates", sx - 170, 200, sx - 170, 200, tocolor ( 255, 0, 0, 255 ), 1 )
		return
	end

	local ox, oy, oz
	ox = x - math.sin ( math.rad ( aSpectator.AngleX ) ) * aSpectator.Offset
	oy = y - math.cos ( math.rad ( aSpectator.AngleX ) ) * aSpectator.Offset
	oz = z + math.tan ( math.rad ( aSpectator.AngleZ ) ) * aSpectator.Offset
	setCameraMatrix ( ox, oy, oz, x, y, z )

	local sx, sy = guiGetScreenSize ()
	dxDrawText ( "Spectating: "..getPlayerName ( aSpectator.Spectating ), sx - 170, 200, sx - 170, 200, tocolor ( 255, 255, 255, 255 ), 1 )
	if ( _DEBUG ) then
		dxDrawText ( "DEBUG:\nAngleX: "..aSpectator.AngleX.."\nAngleZ: "..aSpectator.AngleZ.."\n\nOffset: "..aSpectator.Offset.."\nX: "..ox.."\nY: "..oy.."\nZ: "..oz.."\nDist: "..getDistanceBetweenPoints3D ( x, y, z, ox, oy, oz ), sx - 170, sy - 180, sx - 170, sy - 180, tocolor ( 255, 255, 255, 255 ), 1 )
	else
		if ( isCursorShowing () ) then
			dxDrawText ( "Tip: mouse2 - toggle free camera mode", 20, sy - 50, 20, sy - 50, tocolor ( 255, 255, 255, 255 ), 1 )
		else
			dxDrawText ( "Tip: Use mouse scroll to zoom in/out", 20, sy - 50, 20, sy - 50, tocolor ( 255, 255, 255, 255 ), 1 )
		end
	end
end

function aSpectator.MoveOffset ( key, state, inc )
	if ( not isCursorShowing() ) then
		aSpectator.Offset = aSpectator.Offset + tonumber ( inc )
		if ( aSpectator.Offset > 70 ) then aSpectator.Offset = 70
		elseif ( aSpectator.Offset < 2 ) then aSpectator.Offset = 2 end
	end
end

function aSpectator.GetAlive ()
	local alive = {}
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		if ( not isPlayerDead ( player ) ) then
			table.insert ( alive, player )
		end
	end
	return alive
end
