local VehicleBars = false

players = getElementsByType ( "player" )

addEventHandler( "onClientRender", getRootElement(),
	function(  )
	for k, player in pairs( getElementsByType("player") ) do
		local px, py, pz = getElementPosition( getLocalPlayer() )
		local x, y, z = getPedBonePosition(player, 2)
		local cx,cy,cz = getCameraMatrix(getLocalPlayer())
		if isElementOnScreen( player ) and getDistanceBetweenPoints2D(px, py, x, y) < 45 and isLineOfSightClear(cx,cy,cz, x,y,z, true, true, false, true, true, false, false) and player ~= getLocalPlayer() and getElementHealth(player) > 0 then
			local X, Y = getScreenFromWorldPosition( x, y, z )
			if X then
				local arm = getPedArmor( player );
				local health = getElementHealth( player );
				local lineLength = 56 * ( health / 100 );
				dxDrawRectangle( X - 30, Y - 130, 60, 10, tocolor( 0, 0, 0, 255), 10 );
				dxDrawRectangle( X - 28, Y - 128, lineLength, 6, tocolor( 255, 0, 0, 200 ), 6 );
				if arm ~= 0 then
					local lineLengthArm = 56 * ( arm / 100 );
					dxDrawRectangle( X - 30, Y - 142, 60, 10, tocolor( 0, 0, 0, 255), 10 );
					dxDrawRectangle( X - 28, Y - 140, lineLengthArm, 6, tocolor( 255, 255, 255, 200 ), 6 );
				end
				local namelen = string.len(getPlayerName(player))
				dxDrawText( getPlayerName(player), X - (3.5 * namelen), Y - 160, X - (3.5 * namelen), Y - 160, tocolor ( getPlayerNametagColor(player) ), 1, "default-bold")
			end
		end
	end
	for k, myPed in pairs( getElementsByType("ped") ) do
		local state = getElementData(myPed, "amx.shownametag")
		if state == true then
			local px, py, pz = getElementPosition( getLocalPlayer() )
			local x, y, z = getPedBonePosition(myPed, 2)
			if isElementOnScreen( myPed ) and getDistanceBetweenPoints2D(px, py, x, y) < 45 and getElementHealth(myPed) > 0 then
				local X, Y = getScreenFromWorldPosition( x, y, z )
				if X then
					local arm = getPedArmor( myPed );
					local health = getElementHealth( myPed );
					local lineLength = 56 * ( health / 100 );
					dxDrawRectangle( X - 30, Y - 130, 60, 10, tocolor( 0, 0, 0, 255), 10 );
					dxDrawRectangle( X - 28, Y - 128, lineLength, 6, tocolor( 255, 0, 0, 200 ), 6 );
					if arm ~= 0 then
					local lineLengthArm = 56 * ( arm / 100 );
					dxDrawRectangle( X - 30, Y - 142, 60, 10, tocolor( 0, 0, 0, 255), 10 );
					dxDrawRectangle( X - 28, Y - 140, lineLengthArm, 6, tocolor( 255, 255, 255, 200 ), 6 );
					end
					local BotName = getElementData(myPed, 'BotName');
					if not BotName then BotName = 'Bot' end
					local namelen = string.len(BotName)
					dxDrawText( tostring(BotName), X - (3.5 * namelen), Y - 160, X - (3.5 * namelen), Y - 160, tocolor ( 255, 255, 255, 255 ), 1, "default-bold")
				end
			end
		end
	end
	if VehicleBars == true then
		for k, vehicle in pairs( getElementsByType("vehicle") ) do
			local px, py, pz = getElementPosition( getLocalPlayer() )
			local x, y, z = getElementPosition( vehicle )
			local cx,cy,cz = getCameraMatrix(getLocalPlayer())
			if isElementOnScreen( vehicle ) and getDistanceBetweenPoints2D(px, py, x, y) < 50 and isLineOfSightClear(cx,cy,cz, x,y,z, true, false, false, true, true, false, false) and getElementHealth(vehicle) > 0  then
				local X, Y = getScreenFromWorldPosition( x, y, z )
				if X then
					local health = getElementHealth( vehicle );
					local lineLength = 76 * ( health / 1000 );
					dxDrawRectangle( X, Y, 80, 15, tocolor( 0, 0, 0, 255), 10 );
					dxDrawRectangle( X+2, Y+2, lineLength, 11, tocolor( 0, 255, 0, 200 ), 6 );
				--	local namelen = string.len(getVehicleName(vehicle))
				--	dxDrawText( getVehicleName(vehicle), X - (3.5 * namelen), Y - 160, X - (3.5 * namelen), Y - 160, tocolor ( 255, 255, 255, 255 ), 1, "default-bold")
				end
			end
		end
	end
end
)
