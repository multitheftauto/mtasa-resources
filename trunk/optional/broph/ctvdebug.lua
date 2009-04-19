root = getRootElement ()
players = getElementsByType ( "player" )

function onDebugStart ( name )
	if ( name == getThisResource() ) then
		local players = getElementsByType ( "player" )
		for k,v in ipairs(players) do
	        bindKey ( v, "l", "down", toggleVehicleLights )
		end
	end
end

-- function outputOnLoad ( name )
	-- for k,v in ipairs(getElementsByType ( "vehicle" )) do
	-- local model = getVehicleID ( v )
	-- local id = getVehicleNameFromID ( model )
	-- local x, y, z = getElementPosition ( v )
	-- local rx, ry, rz = getVehicleRotation ( v )
	-- local c1, c2, c3, c4 = getVehicleColor ( v )
    -- outputConsole ( "<vehicle id=\"" .. id .. "\" model=\"" .. model .. "\" posX=\"" .. x .. "\" posY=\"" .. y .. "\" posZ=\"" .. z .. "\" rotX=\"" .. rx .. "\" rotY=\"" .. ry .. "\" rotZ=\"" .. rz .. "\" colors=\"" .. c1 .. "," .. c2 .. "," .. c3 .. "," .. c4 .. "\"/>" )
	-- outputDebugString ( "<vehicle id=\"" .. id .. "\" model=\"" .. model .. "\" posX=\"" .. x .. "\" posY=\"" .. y .. "\" posZ=\"" .. z .. "\" rotX=\"" .. rx .. "\" rotY=\"" .. ry .. "\" rotZ=\"" .. rz .. "\" colors=\"" .. c1 .. "," .. c2 .. "," .. c3 .. "," .. c4 .. "\"/>" )
	-- end
-- end

-- Enabled this old function with new purpose - MK
function consoleCommands ( player )
	if ( player ) then
		outputChatBox ( "Command List printed to console, press F8.", player )
		outputConsole ( "createpickup", player )
		outputConsole ( "createmarker", player )
		outputConsole ( "setmapname", player )
		outputConsole ( "removemarkers", player )
		outputConsole ( "creategangzone", player )
		outputConsole ( "removegangzones", player )
		outputConsole ( "setgangzoneflashing", player )
		outputConsole ( "hp", player )
		outputConsole ( "tagcolor", player )
		outputConsole ( "tagtext", player )
		outputConsole ( "createobject", player )
		outputConsole ( "loc", player )
		outputConsole ( "locxyz", player )
		outputConsole ( "createvehicle", player )
		outputConsole ( "cv", player )
		outputConsole ( "give", player )
		outputConsole ( "warpto", player )
		outputConsole ( "settime", player )
		outputConsole ( "setweather", player )
		outputConsole ( "blendweather", player )
		outputConsole ( "setskin", player )
		outputConsole ( "listclothes", player )
		outputConsole ( "addclothes", player )
		outputConsole ( "removeclothes", player )
		outputConsole ( "repair", player )
		outputConsole ( "setcolor", player )
		outputConsole ( "checkupgrades", player )
		outputConsole ( "addupgrade", player )
		outputConsole ( "removeupgrade", player )
		outputConsole ( "setpaintjob", player )
		outputConsole ( "jetpack", player )
		outputConsole ( "attachtrailer", player )
		outputConsole ( "setstat", player )
		outputConsole ( "getpos", player )
		outputConsole ( "setpos", player )
		outputConsole ( "garage", player )
	 end
 end

function createpkup ( source, command, types, info, respawntime, ammo )
	if (tonumber(types) == 0 or tonumber(types) == 1) then
	local x,y,z = getElementPosition ( source )
	local rot = getPedRotation ( source )
	createPickup ( -2.25 * math.sin (math.rad (rot)) + x , 2.25 * math.cos (math.rad (rot)) + y, z, types, info, respawntime )
	elseif (tonumber(types) == 2 or tonumber(types) == 3) then
	local x,y,z = getElementPosition ( source )
	local rot = getPedRotation ( source )
	createPickup ( -2.25 * math.sin (math.rad (rot)) + x , 2.25 * math.cos (math.rad (rot)) + y, z, types, info, respawntime, ammo )
	else
	outputChatBox ( "Pickup could not be created, PAL!", source, 255, 0, 0 )
	end
end

function makemarker(source, command, markertype, size, red, green, blue, alpha)
	local x,y,z = getElementPosition ( source )
	local rot = getPedRotation ( source )
	createMarker ( -2.25 * math.sin (math.rad (rot)) + x, -2.25 * math.sin (math.rad (rot)) + y, -2.25 * math.sin (math.rad (rot)) + z, tostring(markertype), tonumber(size), tonumber(red), tonumber(green), tonumber(blue), tonumber(alpha) )
end	

function setmapname(source, command, mapname)
	setMapName ( tostring(mapname) )
end

function removemarkers()
	for k,v in ipairs(getElementsByType ( "marker" )) do
	destroyElement ( v )
	end
end

function gangzone(source, command, x, y, xunit, yunit, red, green, blue, alpha)
	createRadarArea ( tonumber(x), tonumber(y), tonumber(xunit), tonumber(yunit), tonumber(red), tonumber(green), tonumber(blue), tonumber(alpha), root )
end

function remgangzone()
	for k,v in ipairs(getElementsByType ( "radararea" )) do
	destroyElement ( v )
	end
end

function gangzoneflashing(source, command, flashing)
	if ( tonumber(flashing) == 0 ) then
	for k,v in ipairs(getElementsByType ( "radararea" )) do
	setRadarAreaFlashing ( v, false )
	end
	elseif ( tonumber(flashing) == 1 ) then
	for k,v in ipairs(getElementsByType ( "radararea" )) do
	setRadarAreaFlashing ( v, true )
	end
	end
end

function hplookup ( source, command, id )
	if ( id ) then
		local player = getPlayerFromNick ( id )
		if ( player ) then
			local invehicle = isPedInVehicle ( player )
		if ( invehicle == true ) then
			local playername = getPlayerName ( player )
			local hplookedup = getElementHealth ( player )
			local vehicle = getPedOccupiedVehicle ( player )
			local vehiclehealth = getElementHealth ( vehicle )  / 10
			local result = math.ceil ( hplookedup )
			local vehresult = math.ceil( vehiclehealth ) - 100
			outputChatBox ( "* " .. playername .. "'s Health: " .. result .. "% - Vehicle Damage: " .. math.abs(vehresult) .. "%", root, 255, 255, 0 )
		elseif ( invehicle == false ) then
			local playername = getPlayerName ( player )
			local hplookedup = getElementHealth ( player )
			local result = math.ceil( hplookedup )
			outputChatBox ( "* " .. playername .. "'s Health: " .. result .. "%", root, 255, 255, 0 )
		end
		else
		outputChatBox ( "Player not found!", source, 255, 255, 0 )
	end
end
	if ( not id ) then
		local hplookedup = getElementHealth ( source )
		local playername = getPlayerName ( source )
		local invehicle = isPedInVehicle ( source )
		if ( invehicle == true ) then
			local vehicle = getPedOccupiedVehicle ( source )
			local vehiclehealth = getElementHealth ( vehicle ) / 10
			local result = math.ceil ( hplookedup )
			local vehresult = math.ceil( vehiclehealth ) - 100
			outputChatBox ( "* " .. playername .. "'s Health: " .. result .. "% - Vehicle Damage: " .. math.abs(vehresult) .. "%", root, 255, 255, 0 )			
		elseif ( invehicle == false ) then
			local result = math.ceil( hplookedup )
			outputChatBox ( "* " .. playername .. "'s Health: " .. result .. "%", root, 255, 255, 0 )
		end
	end
end

function tagcolor(source, command, r, g, b)
	setPlayerNametagColor(source, r, g, b)
end

function tagtext(source, command, message)
	setPlayerNametagText(source, message)
end


-- Modified createobject for easier usage - MK
function createobjectforplayer( player, command, object )
	local rotation_Z, distance = 0, 5
	local PlayerRotation = getPedRotation ( player )
	local rotation_Z = PlayerRotation + 90
	local Player_x, Player_y, Player_z = getElementPosition ( player )
	local Player_x = Player_x + (( math.cos( math.rad ( rotation_Z ))) * distance )
	local Player_y = Player_y + (( math.sin( math.rad ( rotation_Z ))) * distance )
	cobject = createObject ( object, Player_x, Player_y, Player_z, 0, 0, rotation_Z )
	if  ( cobject ) then
	outputChatBox ( "Object: " ..object.. " Created", player, 0, 255, 255 )
	else
	outputChatBox ( "Object " ..object.. " could not be created", player, 0, 255, 255 )
	end
end

function playerloc(source)
	if ( source ) then
	local playername = getPlayerName(source)
	local location = getElementZoneName(source)
	outputChatBox ( "* " ..playername.. "'s Location: " ..location.. ", " ..getElementZoneName(source, true), root, 0, 255, 255 )
	else
	outputChatBox ( "Location not found", root, 0, 255, 255 )
	end
end

function locationxyz(source, command, x, y, z)
	local location = getZoneName ( x, y, z )
	if ( location ) then
		outputChatBox ("* Location: " ..location, root, 0, 255, 255)
		else
		outputChatBox ("* Location not found.", root, 0, 255, 255)
	end
end



-- Added Garage Open/Close function - MK
function garageControl(source, command, garageID)
	if ( tonumber(garageID) ) and (not isGarageOpen(tonumber(garageID))) then
	setGarageOpen(tonumber(garageID), true)
	else 
	setGarageOpen(tonumber(garageID), false)
	end
end



-- Fixed vehicle spawn position - MK
function consoleCreateVehicle ( player, commandName, first, second, third )
	if ( player ) then
		local id, x, y, z, r, d = 0, 0, 0, 0, 0, 5
		local plate = false
		pr = getPedRotation ( player )
		r = pr + 90
		x, y, z = getElementPosition ( player )
		x = x + ( ( math.cos ( math.rad ( r ) ) ) * d )
		y = y + ( ( math.sin ( math.rad ( r ) ) ) * d )
		if ( third ) then
			id = getVehicleModelFromName ( first .. " " .. second )
			plate = third
		elseif ( second ) then
			if ( getVehicleModelFromName ( first .. " " .. second ) ) then
				id = getVehicleModelFromName ( first .. " " .. second )
     		else
     			id = getVehicleModelFromName ( first )
				if ( not id ) then
					id = tonumber ( first )
				end
     			plate = second
			end			
		else
			id = getVehicleModelFromName ( first )
			if ( not id ) then
				id = tonumber ( first )
			end
		end
		local veh = false
		if ( plate == false ) then
			veh = createVehicle ( id, x, y, z, 0, 0, r )
			--toggleVehicleRespawn ( veh, false )
		else
			veh = createVehicle ( id, x, y, z, 0, 0, r, plate )
			--toggleVehicleRespawn ( veh, false )
		end
     	if ( veh == false ) then  outputConsole ( "Failed to create vehicle.", player )  end
	end
end

function consoleGive ( player, commandName, string1, string2, string3 )
	if ( player ) then
	    if ( string3 ) then
         	local status = giveWeapon ( player, getWeaponIDFromName ( string1 .. " " .. string2 ), string3, true )
         	if ( not status ) then
				outputConsole ( "Failed to give weapon.", player )
			end
	    elseif ( string2 ) then
	        if ( tonumber ( string1 ) ) then
	        	local status = giveWeapon ( player, string1, string2, true )
         		if ( not status ) then
					outputConsole ( "Failed to give weapon.", player )
				end
			else
			    local status = giveWeapon ( player, getWeaponIDFromName ( string1 ), string2, true )
         		if ( not status ) then
					outputConsole ( "Failed to give weapon.", player )
				end
			end
		else
		    outputConsole ( "Failed to give weapon.", player )
	    end
	end
end

function consoleWarpTo ( player, commandName, player2nick )
	if ( player ) then
    	local x, y, z, r, d = 0, 0, 0, 0, 2.5
    	local player2 = getPlayerFromNick ( player2nick )
    	if ( player2 ) then
        	if ( isPedInVehicle ( player2 ) ) then
        		local player2vehicle = getPedOccupiedVehicle ( player2 )
--outputDebugString ( "The player is in a " .. getVehicleName ( player2vehicle ) )
				local maxseats = getVehicleMaxPassengers ( player2vehicle ) + 1
--outputDebugString ( "The vehicle has " .. maxseats .. " seats" )
				local i = 0
				while ( i < maxseats ) do
					if ( getVehicleOccupant ( player2vehicle, i ) ) then
--outputDebugString ( "Seat " .. i .. " is occupied" )
						i = i + 1
					else
--outputDebugString ( "Seat " .. i .. " is free" )
						break
					end
				end
				if ( i < maxseats ) then
--outputDebugString ( "i (" .. i .. ") is less than maxseats (" .. maxseats .. "), warping player..." )
					--setTimer ( "warpPlayerIntoVehicle", 1000, 1, player, player2vehicle, i )
					--fadeCamera ( player, false, 1, 0, 0, 0 )
					--setTimer ( "fadeCamera", 1000, 1, player, true, 1 )
					local status = warpPedIntoVehicle ( player, player2vehicle, i )
					if ( status ) then
--outputDebugString ( "warpPlayerIntoVehicle returned true" )
					else
--outputDebugString ( "warpPlayerIntoVehicle returned false" )
					end
				else
					outputConsole ( "Sorry, the player's vehicle is full (" .. getVehicleName ( player2vehicle ) .. " " .. i .. "/" .. maxseats .. ")", player )
				end
			else
				x, y, z = getElementPosition ( player2 )
				r = getPedRotation ( player2 )
				interior = getElementInterior ( player2 )
				dimension = getElementDimension ( player2 )
 	   			x = x - ( ( math.cos ( math.rad ( r + 90 ) ) ) * d )
			   	y = y - ( ( math.sin ( math.rad ( r + 90 ) ) ) * d )
				setTimer ( setElementInterior, 800, 1, player, interior )
				setTimer ( setElementDimension, 900, 1, player, dimension )
   				setTimer ( setElementPosition, 1000, 1, player, x, y, z )
   				setTimer ( setPedRotation, 1000, 1, player, r )
				fadeCamera ( player, false, 1, 0, 0, 0 )
				setTimer ( fadeCamera, 1000, 1, player, true, 1 )
			end
		else
			outputConsole ( "No such player.", player )
		end
	end
end

function consoleSetTime ( player, commandName, hour, minute )
	if ( player ) then
		if ( setTime ( hour, minute ) == false ) then  outputConsole ( "Failed to set time.", player )  end
	end
end

function consoleSetWeather ( player, commandName, id )
	if ( player ) then
		if ( setWeather ( id ) == false ) then  outputConsole ( "Failed to set weather.", player )  end
	end
end

function consoleBlendWeather ( player, commandName, id )
	if ( player ) then
		if ( setWeatherBlended ( id ) == false ) then  outputConsole ( "Failed to blend weather.", player )  end
	end
end

function consoleSetSkin ( player, commandName, id )
	if ( player and id ) then
    	local blip = getElementData ( player, "blip" )
		local x, y, z = getElementPosition ( player )
		local r = getPedRotation ( player )
		local interior = getElementInterior ( player )
		local dimension = getElementDimension ( player  )
		local status = spawnPlayer ( player, x, y, z, r, id )
		setElementInterior ( player, interior )
		setElementDimension ( player, dimension )
		if ( status ) then
    		if ( blip ) then
    			destroyElement ( blip )
    		end
		else
			outputConsole ( "Failed to spawn player.", player )		
		end
	end
end

function consoleListClothes ( player, commandName, type )
	if ( player and type ) then
		type = tonumber ( type )
		local clothesstrings = {}
		local length_index = 0
		local texture, model = getClothesByTypeIndex ( type, 0 )
		outputConsole ( getClothesTypeName ( type ) .. " (" .. type ..") textures and models:", player )
		local index = 1
		while ( getClothesByTypeIndex ( type, index ) ) do
			texture, model = getClothesByTypeIndex ( type, index )
			if ( math.mod ( index-1, 10 ) ~= 0 ) then --
				clothesstrings[length_index] = clothesstrings[length_index] .. ", " .. texture .. " " .. model
			else
			    length_index = length_index + 1
				clothesstrings[length_index] = texture .. " " .. model
			end
			index = index + 1
		end
		for k,v in ipairs(clothesstrings) do
			outputConsole ( v, player )
		end
	end
end

function consoleAddClothes ( player, commandName, type, texture, model )
	if ( player ) then
		if ( getElementModel ( player ) == 0 ) then
			if ( addPedClothes ( player, texture, model, tonumber ( type ) ) == false ) then
				outputConsole ( "Failed to add clothes.", player )
			end
		else
			outputConsole ( "You must have the CJ model.", player )
		end
	end
end

function consoleRemoveClothes ( player, commandName, type )
	if ( player ) then
		if ( getElementModel ( player ) == 0 ) then
			if ( removePedClothes ( player, tonumber ( type ) ) == false ) then
				outputConsole ( "Failed to remove clothes.", player )
			end
		else
			outputConsole ( "You must have the CJ model.", player )
		end
	end
end

function consoleRepairVehicle ( player, commandName )
	if ( player ) then
		if ( isPedInVehicle ( player ) ) then
			local veh = getPedOccupiedVehicle ( player )
			fixVehicle ( veh )
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end

function consoleSetColor ( player, commandName, col1, col2, col3, col4 )
	if ( player ) then
		if ( isPedInVehicle ( player ) ) then
			local veh = getPedOccupiedVehicle ( player )
			local col1old, col2old, col3old, col4old = getVehicleColor ( veh )
			if ( ( not col1 ) or col1 == "-1" ) then  col1 = col1old  end 
			if ( ( not col2 ) or col2 == "-1" ) then  col2 = col2old  end 
			if ( ( not col3 ) or col3 == "-1" ) then  col3 = col3old  end 
			if ( ( not col4 ) or col4 == "-1" ) then  col4 = col4old  end
			if ( setVehicleColor ( veh, tonumber ( col1 ), tonumber ( col2 ), tonumber ( col3 ), tonumber ( col4 ) ) == false ) then
				outputConsole ( "Failed to set vehicle color.", player )
			end 
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end		
	end
end

function consoleCheckUpgrades ( player, commandName )
	if ( player ) then
		if ( isPedInVehicle ( player ) ) then
			local veh = getPedOccupiedVehicle ( player )
		    local upgrades = getVehicleUpgrades ( veh )
			local slotstrings = {}
		    outputConsole ( "Compatible upgrades for " .. getVehicleName ( veh ) .. ":", player )
		    local id = 1000
		    while ( id <= 1193 ) do
		        if ( addVehicleUpgrade ( veh, id ) ) then
		        	if ( slotstrings[getVehicleUpgradeSlotName ( id )] ) then
		        		slotstrings[getVehicleUpgradeSlotName ( id )] = slotstrings[getVehicleUpgradeSlotName ( id )] .. ", " .. id
		        	else
		        		slotstrings[getVehicleUpgradeSlotName ( id )] = " " .. getVehicleUpgradeSlotName ( id ) .. " - " .. id
		        	end
                    removeVehicleUpgrade ( veh, id )
				end
				id = id + 1
			end
			for k,v in ipairs(slotstrings) do
				outputConsole ( v, player )
			end
			for k,v in ipairs(upgrades) do
   				addVehicleUpgrade ( veh, v )
			end
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end

function consoleAddUpgrade ( player, commandName, id )
	if ( player ) then
		if ( isPedInVehicle ( player ) ) then
			local veh = getPedOccupiedVehicle ( player )
			if ( addVehicleUpgrade ( veh, tonumber ( id ) ) ) then
			    --outputConsole ( getVehicleUpgradeSlotName ( tonumber ( id ) ) .. " upgrade added.", player )
			else
				outputConsole ( "Failed to add upgrade.", player )
			end
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end

function consoleRemoveUpgrade ( player, commandName, id )
	if ( player ) then
		if ( isPedInVehicle ( player ) ) then
			local veh = getPedOccupiedVehicle ( player )
			if ( removeVehicleUpgrade ( veh, tonumber ( id ) ) ) then
			    outputConsole ( getVehicleUpgradeSlotName ( tonumber ( id ) ) .. " upgrade removed.", player )
			else
				outputConsole ( "Failed to remove upgrade.", player )
			end
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end

function consoleSetPaintJob ( player, commandName, id )
	if ( player ) then
		if ( isPedInVehicle ( player ) ) then
			local veh = getPedOccupiedVehicle ( player )
			if ( setVehiclePaintjob ( veh, tonumber ( id ) ) ) then
			    outputConsole ( "Paintjob " .. id .. " set.", player )
			else
				outputConsole ( "Failed to set paintjob.", player )
			end
		else
		    outputConsole ( "You must be in a vehicle.", player )
		end
	end
end

function consoleJetPack ( player, commandName )
	if ( player ) then
		if ( not doesPedHaveJetPack ( player ) ) then
			local status = givePedJetPack ( player )
			if ( not status ) then
				outputConsole ( "Failed to give jetpack.", player )
			end
		else
			local status = removePedJetPack ( player )
			if ( not status ) then
				outputConsole ( "Failed to remove jetpack.", player )
			end
		end
	end
end

function consoleAttachTrailer ( player, commandName, trailerid, vehicleid )
	if ( player ) then
		if ( vehicleid ) then
			local sx, sy, id, x, y, z, r, d = 0, 0, 0, 0, 0, 0, 0, 5
			r = getPedRotation ( player )
			sx, sy, z = getElementPosition ( player )
			x = sx + ( math.cos ( math.rad ( r ) ) * d )
			y = sy + ( math.sin ( math.rad ( r ) ) * d )
			local veh = createVehicle ( tonumber ( vehicleid ), x, y, z, 0, 0, r )
			x = sx + ( ( math.cos ( math.rad ( r ) ) ) * ( d + 7.5 ) )
			y = sy + ( ( math.sin ( math.rad ( r ) ) ) * ( d + 7.5 ) )
			local trailer = createVehicle ( tonumber ( trailerid ), x, y, z, 0, 0, r )
            if ( veh and trailer ) then
				--toggleVehicleRespawn ( veh, false )
				--toggleVehicleRespawn ( trailer, false )
            	if ( attachTrailerToVehicle ( veh, trailer ) == false ) then  outputConsole ( "Failed to attach vehicle.", player )  end
			else
				outputConsole ( "Failed to create vehicle and/or trailer.", player )
			end
		else			
			if ( isPedInVehicle ( player ) ) then
				local veh = getPedOccupiedVehicle ( player )
				local sx, sy, id, x, y, z, rx, ry, rz, d = 0, 0, 0, 0, 0, 0, 0, 0, 0, 7.5
				rx, ry, rz = getVehicleRotation ( veh )
				sx, sy, z = getElementPosition ( veh )
				x = sx + ( ( math.cos ( math.rad ( rz + 270 ) ) ) * d )
				y = sy + ( ( math.sin ( math.rad ( rz + 270 ) ) ) * d )
				local trailer = createVehicle ( tonumber ( trailerid ), x, y, z, rx, ry, rz )
     			if ( trailer ) then
					--toggleVehicleRespawn ( trailer, false )
            		if ( attachTrailerToVehicle ( veh, trailer ) == false ) then  outputConsole ( "Failed to attach vehicle.", player )  end
				else
					outputConsole ( "Failed to create trailer.", player )
				end
			else
			    outputConsole ( "You must be in a vehicle if VEHICLEID argument is excluded.", player )
			end
		end
	end
end

function consoleSetStat ( player, commandName, id, value )
	if ( player ) then
		id = tonumber ( id )
		value = tonumber ( value )
		if ( id and value ) then
	        local flag = setPedStat ( player, id, value )
			if ( flag ) then
				outputConsole ( "Stat " .. id .. " set to: " .. getPedStat ( player, id ), player ) -- doesn't work
			else
				outputConsole ( "Failed to set stat.", player )
			end
		end
	end
end

function consoleGetPosition ( player, commandName )
	local vehicle = getPedOccupiedVehicle ( player )
	if ( vehicle ) then
		local trailer = getVehicleTowedByVehicle ( vehicle ) 
		if ( trailer ) then
			local x, y, z = getElementPosition ( vehicle )
			local rx, ry, rz = getVehicleRotation ( vehicle )
			local x2, y2, z2 = getElementPosition ( trailer )
			local rx2, ry2, rz2 = getVehicleRotation ( trailer )
			outputChatBox ( "Vehicle pos/rot: " .. x .. " " .. y .. " " .. z .. ", " .. rx .. " " .. ry .. " " .. rz, player )
			outputChatBox ( "Trailer pos/rot: " .. x2 .. " " .. y2 .. " " .. z2 .. ", " .. rx2 .. " " .. ry2 .. " " .. rz2, player )
		else
			local x, y, z = getElementPosition ( vehicle )
			local rx, ry, rz = getVehicleRotation ( vehicle )
			outputChatBox ( "Vehicle pos/rot: " .. x .. " " .. y .. " " .. z .. ", " .. rx .. " " .. ry .. " " .. rz, player )
		end
	else
		local x, y, z = getElementPosition ( player )
		local r = getPedRotation ( player )
		outputChatBox ( "Player pos/rot: " .. x .. " " .. y .. " " .. z .. ", " .. r, player )
	end
end

function consoleSetPosition ( player, commandName, x, y, z )
	x = tonumber ( x ) 
	y = tonumber ( y ) 
	z = tonumber ( z )
	if ( x and y and z ) then 
		local vehicle = getPedOccupiedVehicle ( player )
		if ( vehicle ) then
			setElementPosition ( vehicle, x, y, z )
		else
			setElementPosition ( player, x, y, z )
		end
	end
end

function toggleVehicleLights ( player, key, state )
	if ( getPedOccupiedVehicleSeat ( player ) == 0 ) then
		local veh = getPedOccupiedVehicle ( player )
		if ( getVehicleOverrideLights ( veh ) ~= 2 ) then
			setVehicleOverrideLights ( veh, 2 )
		else
			setVehicleOverrideLights ( veh, 1 )
		end
	end
end   

function playerJoin ()
    bindKey ( source, "l", "down", toggleVehicleLights )
end

addEventHandler ( "onResourceStart", root, onDebugStart )
addEventHandler ( "onPlayerJoin", root, playerJoin )

--///

-- addCommandHandler ( "output", outputOnLoad )
addCommandHandler ( "commands", consoleCommands )
addCommandHandler ( "createpickup", createpkup )
addCommandHandler ( "createmarker", makemarker )
addCommandHandler ( "setmapname", setmapname )
addCommandHandler ( "removemarkers", removemarkers )
addCommandHandler ( "creategangzone", gangzone )
addCommandHandler ( "removegangzones", remgangzone )
addCommandHandler ( "setgangzoneflashing", gangzoneflashing )
addCommandHandler ( "hp", hplookup )
addCommandHandler ( "tagcolor", tagcolor )
addCommandHandler ( "tagtext", tagtext )
addCommandHandler ( "createobject", createobjectforplayer )
addCommandHandler ( "loc", playerloc )
addCommandHandler ( "locxyz", locationxyz )
addCommandHandler ( "createvehicle", consoleCreateVehicle )
addCommandHandler ( "cv", consoleCreateVehicle )
addCommandHandler ( "give", consoleGive )
addCommandHandler ( "warpto", consoleWarpTo )
addCommandHandler ( "settime", consoleSetTime )
addCommandHandler ( "setweather", consoleSetWeather )
addCommandHandler ( "blendweather", consoleBlendWeather )
addCommandHandler ( "setskin", consoleSetSkin )
addCommandHandler ( "listclothes", consoleListClothes )
addCommandHandler ( "addclothes", consoleAddClothes )
addCommandHandler ( "removeclothes", consoleRemoveClothes )
addCommandHandler ( "repair", consoleRepairVehicle )
addCommandHandler ( "setcolor", consoleSetColor )
addCommandHandler ( "checkupgrades", consoleCheckUpgrades )
addCommandHandler ( "addupgrade", consoleAddUpgrade )
addCommandHandler ( "removeupgrade", consoleRemoveUpgrade )
addCommandHandler ( "setpaintjob", consoleSetPaintJob )
addCommandHandler ( "jetpack", consoleJetPack )
addCommandHandler ( "attachtrailer", consoleAttachTrailer )
addCommandHandler ( "setstat", consoleSetStat )
addCommandHandler ( "getpos", consoleGetPosition )
addCommandHandler ( "setpos", consoleSetPosition )
addCommandHandler ( "garage", garageControl )




