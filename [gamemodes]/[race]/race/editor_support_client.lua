--
-- editor_support_client.lua
--

function isEditor()
	if g_IsEditor == nil then
		g_IsEditor = getElementData(resourceRoot,"isEditor")
		outputDebug ( "Client: Is editor " .. tostring(g_IsEditor == true) )
	end
	return g_IsEditor == true
end


-- Hacks start here
if isEditor() then

	-- Copy cp_next into cp_now
	setElementData(g_Me, 'race.editor.cp_now', getElementData(g_Me, 'race.editor.cp_next'))

    -- override TitleScreen.show() and don't show things
	TitleScreen._show = TitleScreen.show
	function TitleScreen.show()
		TitleScreen._show ()
        hideGUIComponents('titleImage','titleText1','titleText2')
	end

	function editorInitRace()
		g_EditorSpawnPos = {getElementPosition(g_Vehicle)}
		TravelScreen.hide()
		TitleScreen.bringForwardFadeout(10000)

		-- Do fadeup and tell server client is ready
		setTimer(fadeCamera, 200, 1, true, 1.0)
		setTimer( function() triggerServerEvent('onNotifyPlayerReady', g_Me) end, 50, 1 )

		bindKey('1', 'down', editorSelectCheckpoint, -10)
		bindKey('2', 'down', editorSelectCheckpoint, -1)
		bindKey('3', 'down', editorSelectCheckpoint, 1)
		bindKey('4', 'down', editorSelectCheckpoint, 10)
		bindKey('6', 'down', editorSelectCheckpoint)
		bindKey('8', 'down', editorSelectVehicle, -1)
		bindKey('9', 'down', editorSelectVehicle, 1)
		bindKey('0', 'down', editorSelectVehicle)
		bindKey('F2', 'down', editorHideHelp)

		editorAddHelpLine("Race editor mode keys:" )
		editorAddHelpLine("1","CP - 10" )
		editorAddHelpLine("2","CP - 1" )
		editorAddHelpLine("3","CP + 1" )
		editorAddHelpLine("4","CP + 10" )
		editorAddHelpLine("5" )
		local startCp = getElementData(g_Me, "race.editor.cp_now")
		if startCp then
			editorAddHelpLine( "6","Previous test run CP (" .. tostring(startCp) .. ")" )
		else
			editorAddHelpLine( "6","Previous test run CP (n/a)" )
		end
		editorAddHelpLine("7" )
		editorAddHelpLine("8","Vehicles used in map -1" )
		editorAddHelpLine("9","Vehicles used in map +1" )
		editorAddHelpLine("0","Reselect last custom vehicle" )
		editorAddHelpLine( "" )
		editorAddHelpLine( "F1","(Create) Custom vehicle" )
		editorAddHelpLine( "F2","Hide this help" )

		if getElementData(g_Me, 'race.editor.hidehelp' ) then
			editorHideHelp()
		end
	end

	-- Help text
	editorHelpLines = {}
	function editorAddHelpLine(text1,text2)
		local idx = #editorHelpLines/2
		editorHelpLines[idx*2+1] = dxText:create(text1, 10, 250 + idx * 15, false, "default-bold", 1.0, "left" )
		editorHelpLines[idx*2+1]:color( 255, 250, 130, 240 )
		editorHelpLines[idx*2+1]:type( "border", 1 )
		editorHelpLines[idx*2+2] = dxText:create(text2 or "", 34, 250 + idx * 15, false, "default-bold", 1.0, "left" )
		editorHelpLines[idx*2+2]:color( 255, 250, 250, 230 )
		editorHelpLines[idx*2+2]:type( "border", 1 )
	end

	function editorHideHelp()
		for key,line in pairs(editorHelpLines) do
			line:visible(not line:visible())
		end
		setElementData(g_Me, 'race.editor.hidehelp', not editorHelpLines[1]:visible() )
	end


	-- Remember last passed cp for next time
	addEventHandler('onClientElementDataChange', root,
		function(dataName, oldValue )
			if source==g_Me and dataName == "race.checkpoint" then
				local i = getElementData(g_Me, 'race.checkpoint')
				if i then
					setElementData(g_Me, 'race.editor.cp_next', i-1 )
					outputDebug ( "race.editor.cp_next " .. tostring(i-1) )
				end
			end
		end
	)


	-- Use freeroam F1 menu to change vehicle
	addEventHandler('onClientElementStreamIn', root,
		function()
			if not isEditor() then return end
			-- See if custom vehicle selected in F1 menu
			if getElementType(source) == "vehicle" then
				local vehicle = source
				local x,y,z = getElementPosition(g_Me)
				local distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(vehicle))
				-- Is nearby, not mine and has no driver?
				if distance < 5 and vehicle ~= g_Vehicle and not getVehicleController(vehicle) then
					triggerServerEvent( "onEditorSelectCustomVehicle", resourceRoot, g_Me, vehicle )
				end
			end
		end
	)


	-- Handle key presses to change vehicle model
	function editorSelectVehicle(key, state, dir)
		triggerServerEvent( "onEditorSelectMapVehicle", resourceRoot, g_Me, dir )
	end

	local getKeyState = getKeyState
	do
		local mta_getKeyState = getKeyState
		function getKeyState(key)
			if isMTAWindowActive() then
				return false
			else
				return mta_getKeyState(key)
			end
		end
	end

	-- Handle key presses to change current cp
	function editorSelectCheckpoint(key, state, dir)
		if not g_CurrentCheckpoint then return end
		local nextIndex
		if not dir then
			nextIndex = getElementData(g_Me, 'race.editor.cp_now')
		else
			if getKeyState("lshift") or getKeyState("rshift") then
				if math.abs(dir) < 2 then
					dir = dir * 10
				end
			end
			nextIndex = g_CurrentCheckpoint - 1 + dir
		end
		if nextIndex >= 0 and nextIndex < #g_Checkpoints then

			setCurrentCheckpoint( nextIndex + 1 )
			setElementData(g_Me, 'race.editor.cp_next', nextIndex )

			local curpos
			if nextIndex == 0 then
				curpos = g_EditorSpawnPos		-- Use spawn pos for cp #0
			else
				curpos = g_Checkpoints[ nextIndex ].position
			end
			local nextpos = g_Checkpoints[ nextIndex + 1 ].position

			local rz = -math.deg( math.atan2 ( ( nextpos[1] - curpos[1] ), ( nextpos[2] - curpos[2] ) ) )

			local cx,cy,cz = getCameraMatrix()
			local pdistance = getDistanceBetweenPoints3D ( cx,cy,cz, getElementPosition(g_Vehicle) )

			setElementPosition( g_Vehicle, curpos[1], curpos[2], curpos[3] + 1 )
			setElementRotation( g_Vehicle, 0,0,rz )
			setTimer ( function ()
						setElementAngularVelocity( g_Vehicle, 0, 0, 0 )
						end, 50, 5 )
			setTimer ( function ()
						setElementVelocity( g_Vehicle, 0, 0, 0 )
						end, 50, 2 )

			-- hmmm, maybe this is nice or not
			if false then
				setCameraBehindVehicle( g_Vehicle, pdistance )
			end

			triggerServerEvent( "onEditorChangeForCheckpoint", resourceRoot, g_Me, nextIndex )
		end
	end

end
