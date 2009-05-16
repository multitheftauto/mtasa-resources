veLastShot = 0
veLastShot1 = 0
veLastShot2 = 0
theGay = getLocalPlayer()
shootingPlayers = {}
shootingLaserPlayers = {}
bullets = 1000
isShooting = false
isShootingLaser = false
reloadTime = 0
_addEventHandler = addEventHandler
_removeEventHandler = removeEventHandler
_bindKey = bindKey
_unbindKey = unbindKey
function fireRockets() --the main secondary weapon function
if isPlayerDead(getLocalPlayer()) then return --if your dead, return... I dont want dead people start shooting ;>
else
	if isPedInVehicle ( getLocalPlayer() ) then --if your in a vehicle
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() ) --get your current vehicle
			if secWeapon == "sam4" then --if your secondary weapon is "sam4"
				if ( veLastShot > getTickCount() ) then return end --reload related
				veLastShot = getTickCount() + 20000 --^
				reloadTime = 20000
				local driver = getVehicleOccupant ( vehicle ) --get the driver of the vehicle (should be you...)
				if driver then --if a driver was found
					setTimer ( fireRocket, 50, 1, getLocalPlayer() ) --set a timer to start firing rockets
					setTimer ( fireRocket, 200, 1, getLocalPlayer() ) --2nd
					setTimer ( fireRocket, 350, 1, getLocalPlayer() ) --3rd
					setTimer ( fireRocket, 500, 1, getLocalPlayer() ) --and the 4th
					guiNiceProgressBarSetProgress ( rcHealthBar, 0 ) --reload related
					guiSetText ( rcHealthText, " - Reload: 0%" ) --^
					--reload = setTimer ( reloadRocket, 1000, 19, getLocalPlayer() ) --reload...
					guiNiceProgressBarSetAlpha ( rcHealthBar, 0.5 ) --reload...
					--reload1 = setTimer ( hideGUI, 22000, 1, getLocalPlayer() ) --reload...
					addEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
				end
			elseif secWeapon == "sam8" then --if your current secondary weapon is "sam8"
				if ( veLastShot > getTickCount() ) then return end --reload related
				veLastShot = getTickCount() + 20000 --^
				reloadTime = 20000
				local driver = getVehicleOccupant ( vehicle ) 
				if driver then
					setTimer ( fireRocket, 50, 1, getLocalPlayer() )
					setTimer ( fireRocket, 250, 1, getLocalPlayer() )
					setTimer ( fireRocket, 450, 1, getLocalPlayer() )
					setTimer ( fireRocket, 650, 1, getLocalPlayer() )
					setTimer ( fireRocket, 850, 1, getLocalPlayer() )
					setTimer ( fireRocket, 1050, 1, getLocalPlayer() )
					setTimer ( fireRocket, 1250, 1, getLocalPlayer() )
					setTimer ( fireRocket, 1450, 1, getLocalPlayer() ) --set 8 timers to fire a total of 8 missiles.
					guiNiceProgressBarSetProgress ( rcHealthBar, 0 )
					guiSetText ( rcHealthText, " - Reload: 0%" )
					--reload = setTimer ( reloadRocket, 1000, 19, getLocalPlayer() )
					guiNiceProgressBarSetAlpha ( rcHealthBar, 0.5 )
					--reload1 = setTimer ( hideGUI, 22000, 1, getLocalPlayer() )
					addEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
				end
			elseif secWeapon == "sam" then --if your secondary weapon is a single SAM
				if ( veLastShot > getTickCount() ) then return end
				veLastShot = getTickCount() + 10000
				reloadTime = 10000
				local driver = getVehicleOccupant ( vehicle )
				if driver then
					setTimer ( fireRocket, 50, 1, getLocalPlayer() ) --set one timer to fire ONE missile
					guiNiceProgressBarSetProgress ( rcHealthBar, 0 )
					guiSetText ( rcHealthText, " - Reload: 0%" )
					--reload = setTimer ( reloadRocket1, 1000, 9, getLocalPlayer() )
					guiNiceProgressBarSetAlpha ( rcHealthBar, 0.5 )
					--reload1 = setTimer ( hideGUI, 10000, 1, getLocalPlayer() )
					addEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
				end
			elseif secWeapon == "mine" then --if your seconadry weapon is mines
				if ( veLastShot > getTickCount() ) then return end
				veLastShot = getTickCount() + 5000
				reloadTime = 5000
				local driver = getVehicleOccupant ( vehicle )
				if driver then
					setTimer ( fireRocket, 50, 1, getLocalPlayer() ) --set a timer to lay one mine (yes yes, i know the function is missnamed...)
					guiNiceProgressBarSetProgress ( rcHealthBar, 0 )
					guiSetText ( rcHealthText, " - Reload: 0%" )
					--reload = setTimer ( reloadRocket2, 1000, 4, getLocalPlayer() )
					guiNiceProgressBarSetAlpha ( rcHealthBar, 0.5 )
					--reload1 = setTimer ( hideGUI, 5000, 1, getLocalPlayer() )
					addEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
				end
			elseif secWeapon == "molotov" then --if you have molotovs
			if ( veLastShot > getTickCount() ) then return end
				veLastShot = getTickCount() + 10000
				reloadTime = 10000
				local driver = getVehicleOccupant ( vehicle )
				if driver then
					setTimer ( fireRocket, 50, 1, getLocalPlayer() ) --fire one molotov
					guiNiceProgressBarSetProgress ( rcHealthBar, 0 )
					guiSetText ( rcHealthText, " - Reload: 0%" )
					--reload = setTimer ( reloadRocket1, 1000, 9, getLocalPlayer() )
					guiNiceProgressBarSetAlpha ( rcHealthBar, 0.5 )
					--reload1 = setTimer ( hideGUI, 10000, 1, getLocalPlayer() )
					addEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
				end
			elseif secWeapon == "heatseaking" then --if your secondary weapon is heatseking missiles.
				local driver = getVehicleOccupant ( vehicle )
				if driver then
					if ( veLastShot > getTickCount() ) then return end
					displayGUItextToPlayer(0.45, 0.3, "tracking...", "default-bold-small", 255, 255, 255, 5000) --display a message
					addEventHandler("onClientRender", getLocalPlayer(), heatTrack) --add a handler
					local tempvehicles = getElementsByType("vehicle") --get a list of all the vehicles
					targeting = setTimer (heatTarget, 3000, 0, tempvehicles) --set a timer to start looping through all the vehicles
				end
			end
	end
end
end

function heatTrack () --this is called onRender when mouse2 is pressed
	local cX, cY = guiGetPosition (crosshair, true) --get the crosshair position
	if not moveDirection then --if theres no current move direction..
		moveDirection = "left" --default it to left
	end
	if cX >= 0.8 then --if the crosshair's position is over or the same as 0.8
		moveDirection = "right" --set the direction to right.
	elseif cX <= 0.2 then --if the corsshairs's position is under or the same as 0.2
		moveDirection = "left" --set the direction to left
	end
	if moveDirection == "left" then --if the current direction is left
		local cX = cX + 0.01 --add 0.01 to the current position
		guiSetPosition(crosshair, cX, cY, true) --set the new position
	elseif moveDirection == "right" then --if the current direction is right
		local cX = cX - 0.01 --withdraw 0.01 from the current direction.
		guiSetPosition(crosshair, cX, cY, true) --set the new position
	end
end

heatMaxDist = 100 --maximum distance
function heatTarget (vehicles) --this is called each 3rd second
displayGUItextToPlayer(0.45, 0.3, "tracking...", "default-bold-small", 255, 255, 255, 5000) --display a message
for k,v in ipairs(vehicles) do --loop ythrough all the vehicles
	if (isElement(v)) then --if its an element...
		if isElementOnScreen(v) == true and getVehicleOccupant(v) ~= getLocalPlayer() then --if the element is on screen, and the driver is not you
			local x, y, z = getElementPosition(v) --get its position
			local px, py, pz = getElementPosition ( getLocalPlayer() ) --get your position
			local screenX, screenY = getScreenFromWorldPosition (x, y, z) --get the screen position based on the target position
			if (screenX) then --if it was successfull
				local distance = getDistanceBetweenPoints3D ( px, py, pz, x, y, z ) --calculate the distance bewtween you and the target
				if distance < heatMaxDist then --if the distance is smaller than the max distance...
					local col, fx, fy, fz, element = processLineOfSight ( px, py, pz + 0.5, x, y, z ) --calculate the line of sight
					if not ( col ) or element == v then --if theres nothing in the way, or if the element is the target
						target = v --tell the script a target has been found
						removeEventHandler("onClientRender", getLocalPlayer(), heatTrack) --stoop moving the crosshair
						killTimer (targeting) --kill the timer
						targeting = nil --
						break --stop the loop, we already have out target.
					end
				end
			end
		end
	end
end
						
if ( target ) then --if theres a target
	if ( getElementType ( target ) == "vehicle" ) then --if the target is a vehicle
		driver = getVehicleOccupant ( target ) --get the driver
		if ( driver ~= getLocalPlayer()  ) then --make sure the driver isnt you!
			if ( targeting ) then --if the timer wasnt killed the first time...
				killTimer (targeting) --kill it again
				targeting = nil
			end
			displayGUItextToPlayer(0.45, 0.3, "Target locked!", "default-bold-small", 255, 0, 0, 3000) --display a message
			addEventHandler("onClientRender", getLocalPlayer(), heatContact) --add a handler
		end
	end
end
end

function heatContact () --this is called onRender when a target has been found ,and mouse2 is pressed
	if isElementOnScreen ( target ) == true then --if the target is on screen
		local x, y, z = getElementPosition(target) --get its position
		local screenX, screenY = getScreenFromWorldPosition (x, y, z) --get the screen position based on the target position
		guiSetPosition(crosshair, screenX, screenY, false) --set the crosshair at the same position as the target
		targetFound = true --tell a script a target is ready to be destroyd
	else --if the target ISNT on screen
		removeEventHandler("onClientRender", getLocalPlayer(), heatContact) --remove the handler
		guiSetPosition(crosshair, 0.48, 0.4, true) --set the crosshair position to its original plave
		displayGUItextToPlayer(0.45, 0.3, "Target out of sight!", "default-bold-small", 0, 0, 255, 5000) --display a message
		target = nil --remove the target
		targetFound = false --tell the script theres no target.
	end	
end
function fireHeat () --this is called whenever mouse2 is released.
if secWeapon == "heatseaking" then --if seconadry weapon is heatseaking...
	if targetFound == true then --if you have a target locked on.
		if ( veLastShot > getTickCount() ) then return end --reload releated...
		veLastShot = getTickCount() + 50000 --^
		reloadTime = 50000
		guiNiceProgressBarSetProgress ( rcHealthBar, 0 ) --^
		guiSetText ( rcHealthText, " - Reload: 0%" ) --^
		--setTimer ( reloadRocket1, 5000, 9, getLocalPlayer() ) --^
		guiNiceProgressBarSetAlpha ( rcHealthBar, 0.5 ) --^
		--setTimer ( hideGUI, 50000, 1, getLocalPlayer() ) --^
		addEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
		local x, y, z = getElementPosition (getLocalPlayer()) --get your position
		createProjectile ( getLocalPlayer(), 20, x, y, z + 4, 2.0, target ) --create a heatseaking missile over you, with the target as argument.
		removeEventHandler("onClientRender", getLocalPlayer(), heatContact) --remove the heat contact handler
		guiSetPosition(crosshair, 0.48, 0.4, true) --set the crosshair to its original place
		targetFound = false --remove the target.
		target = nil --remove the target
	end
	if ( targeting ) then --if the timer wasnt killed the first 2 times...
		killTimer (targeting) --kill it again
		targeting = nil
		removeEventHandler("onClientRender", getLocalPlayer(), heatTrack) --remove the handler
		guiSetPosition(crosshair, 0.48, 0.4, true) --restore the crosshair
	end
end
end

addCommandHandler("heat", function ()
secWeapon = "heatseaking"
end)

function fireRocket() --the main fire secondary weapon function
	local vehicle = getPedOccupiedVehicle ( getLocalPlayer() ) --get your vehicle
	if secWeapon == "sam4" then --if your secondary weapon is sam4
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() ) --quite unnecesary this... but meh...
		local sX, sY, sZ = getElementPosition ( vehicle ) --get the vehicles position
		createProjectile ( getLocalPlayer(), 19, sX, sY, sZ + 4, 4.0 ) --create a rocket
	elseif secWeapon == "sam8" then --same as sam4...
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
		local sX, sY, sZ = getElementPosition ( vehicle )
		createProjectile ( getLocalPlayer(), 19, sX, sY, sZ + 5, 4.0 )
	elseif secWeapon == "sam" then --same here...
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
		local sX, sY, sZ = getElementPosition ( vehicle )
		createProjectile ( getLocalPlayer(), 19, sX, sY, sZ + 3, 5.0 )
	elseif secWeapon == "mine" then --if you got mines...
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
		local sX, sY, sZ = getElementPosition ( vehicle )
		triggerServerEvent ( "zeMINE", getLocalPlayer(), sX, sY, sZ ) --trigger a server event to lay a mine.
	elseif secWeapon == "molotov" then --same as sam's..
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
		local sX, sY, sZ = getElementPosition ( vehicle )
		createProjectile ( getLocalPlayer(), 18, sX, sY, sZ + 5, 1.0 )
	end
end

function placeStinger(player) --quite missnamed function, but this handles almost all accessories.
if isPlayerDead(getLocalPlayer()) then return --if your dead, do nothing.
else
	if ( veLastShot2 > getTickCount() ) then return end --reload related.
	veLastShot2 = getTickCount() + 2000
	if thrWeapon == "stinger" then --if you got stinger...
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
		local sX, sY, sZ = getElementPosition ( vehicle )
		triggerServerEvent ( "zeStinger", getLocalPlayer(), sX, sY, sZ ) --trigger a server event to place it.
	elseif thrWeapon == "nos" then --if you got nitro
		setControlState("vehicle_fire", true) --force your vehicle fire to true.
		setTimer(setControlState, 100, 1, "vehicle_fire", false) --set it to false 100ms later.
	elseif thrWeapon == "jump" then --if you got "springs".
		local vehicle = getPedOccupiedVehicle(getLocalPlayer()) --get your vehicle
		local velx, vely, velz = getElementVelocity(vehicle) --get the current velocity
		setElementVelocity(vehicle, velx, vely, velz+0.3) --add 0.3 to the Z velocity, to make it "jump"
	elseif thrWeapon == "oil" then --if you got oil...
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
		local sX, sY, sZ = getElementPosition ( vehicle )
		triggerServerEvent ( "zeSlippery", getLocalPlayer(), sX, sY, sZ ) --trigger a server event to place it.
	end
end
end

addEvent("oilScale", true) --this is an event to tell all the clients to scale the oil (since it HUGE by default)
addEventHandler("oilScale", getRootElement(), function (oil)
	for k,v in pairs(oil) do --loop through the table
		if isElement(v) then --if its an element
			setObjectScale(v, 0.02) --set the new scale.
		end
	end
end)

function reloadRocket(player) --reload... i cant be botherd to go into details, since im not pleased with it...
	local current = guiNiceProgressBarGetProgress ( rcHealthBar )
	if current < 100 then
		local reload = veLastShot - getTickCount()
		local reload = math.floor(reload)
		local progress = 100 / ( ( 1000 - reloadTime) / ( reload - ( reloadTime - 1000 ) ))
		if progress < 0 then
			progress = 0
		end
		guiSetText ( rcHealthText, " - Reload: "..math.floor(progress).."%" )
		guiNiceProgressBarSetProgress ( rcHealthBar, progress )
		guiSetVisible ( rcHealthText, true )
		guiSetVisible ( rcHealthBar, true )
	else
		guiSetText ( rcHealthText, " - Reload: 100%" )
		guiNiceProgressBarSetAlpha ( rcHealthBar, 0 )
		guiNiceProgressBarSetProgress ( rcHealthBar, 100 )
		removeEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
	end
end
--time = 450 - ( progress * 4.5 ) + 50

function reloadRocket1(player) --reload... i cant be botherd to go into details, since im not pleased with it...
		local test = veLastShot - getTickCount()
		progress = 100 / ( (1000 - reloadTime) / ( test - reloadTime ))
		guiNiceProgressBarGetProgress ( rcHealthBar )
		local health = guiNiceProgressBarGetProgress ( rcHealthBar ) + 10
		guiSetText ( rcHealthText, " - Reload: "..health.."%" )
		guiNiceProgressBarSetProgress ( rcHealthBar, health )
		guiSetVisible ( rcHealthText, true )
		guiSetVisible ( rcHealthBar, true )
end

function reloadRocket2(player) --reload... i cant be botherd to go into details, since im not pleased with it...
		guiNiceProgressBarGetProgress ( rcHealthBar )
		local health = guiNiceProgressBarGetProgress ( rcHealthBar ) + 20
		guiSetText ( rcHealthText, " - Reload: "..health.."%" )
		guiNiceProgressBarSetProgress ( rcHealthBar, health )
		guiSetVisible ( rcHealthText, true )
		guiSetVisible ( rcHealthBar, true )
end

function reloadMiniRocket(player) --reload... i cant be botherd to go into details, since im not pleased with it...
	local current = guiNiceProgressBarGetProgress ( miniRocketBar )
	if current < 100 then
		local reload = veLastShot1 - getTickCount()
		local reload = math.floor(reload)
		local progress = 100 / ( ( 1000 - reload2ndTime) / ( reload - ( reload2ndTime - 1000) ))
		if progress < 0 then
			progress = 0
		end
		guiSetText ( miniRocketText, " - Reload: "..math.floor(progress).."%" )
		guiNiceProgressBarSetProgress ( miniRocketBar, progress )
		guiSetVisible ( miniRocketText, true )
		guiSetVisible ( miniRocketBar, true )
	else
		guiSetText ( miniRocketText, " - Reload: 100%" )
		guiNiceProgressBarSetAlpha ( miniRocketBar, 0 )
		guiNiceProgressBarSetProgress ( miniRocketBar, 100 )
		removeEventHandler("onClientRender", getLocalPlayer(), reloadMiniRocket)
	end
end
miniLastShot = 0
reload2ndTime = 0
function fireMiniRocket() --this is the primary weapon function.
if isPlayerDead(getLocalPlayer()) then return --if your dead, do nothing...
else
	if isPedInVehicle ( getLocalPlayer() ) then --if youre in a vehicle...
		local vehicle = getPedOccupiedVehicle ( getLocalPlayer( ) ) --get your vehicle
		if priWeapon == "explosion" then --if your primary weapon is "small missile"
			if ( veLastShot1 > getTickCount() ) then return end --reload related...
			veLastShot1 = getTickCount() + 2000
			local distance = 30 --max distance
			if getElementModel (vehicle) == 431 then --if youre in a bus....
				sX, sY, sZ = getElementPosition ( getLocalPlayer() ) --get your position, rather than the vehicles.
			else
				sX, sY, sZ = getElementPosition ( vehicle ) --else get the vehicles position
			end
			local fX, fY, fZ = sX, sY, sZ
			local rX, rY, rZ = getElementRotation ( vehicle )
			local rZ = 360 - rZ
			local rX = 360 - rX
			local offset = math.sqrt ( ( distance ^ 2 ) * 2 )
			sX = sX + math.sin ( math.rad ( rZ ) ) * 1.5
			sY = sY + math.cos ( math.rad ( rZ ) ) * 1.5
			fX = fX + math.sin ( math.rad ( rZ ) ) * offset
			fY = fY + math.cos ( math.rad ( rZ ) ) * offset
			fZ = fZ - math.tan ( math.rad ( rX ) ) * offset --alot of math i hardly understand myself...
			local col, x, y, z, element = processLineOfSight ( sX, sY, sZ + 0.5, fX, fY, fZ ) --process the line of sight
			if ( col ) and element ~= getLocalPlayer() and element ~= getPedOccupiedVehicle(getLocalPlayer()) then --if you got a collision in the way, and the element is not you or your vehicle...
				triggerServerEvent ( "VehicleShot", getLocalPlayer(), x, y, z ) --trigger a server event
				if getElementModel (vehicle) == 431 then --if your in a bus, repeat everything once (to fire 2 small missiles)
					setTimer (function()
						local distance = 30
						sX, sY, sZ = getElementPosition ( getLocalPlayer() )
						local fX, fY, fZ = sX, sY, sZ
						local rX, rY, rZ = getElementRotation ( vehicle )
						--local rX = 360 - rX
						local rZ = 360 - rZ
						local rX = 360 - rX
						--local rZ = 360 - rZ
						local offset = math.sqrt ( ( distance ^ 2 ) * 2 )
						sX = sX + math.sin ( math.rad ( rZ ) ) * 1.5
						sY = sY + math.cos ( math.rad ( rZ ) ) * 1.5
						fX = fX + math.sin ( math.rad ( rZ ) ) * offset
						fY = fY + math.cos ( math.rad ( rZ ) ) * offset
						fZ = fZ - math.tan ( math.rad ( rX ) ) * offset
						local col, x, y, z, element = processLineOfSight ( sX, sY, sZ + 0.5, fX, fY, fZ )
						if ( col ) and element ~= getLocalPlayer() and element ~= getPedOccupiedVehicle(getLocalPlayer()) then 
							triggerServerEvent ( "VehicleShot", getLocalPlayer(), x, y, z )
						else 
							triggerServerEvent ( "VehicleShot", getLocalPlayer(), fX, fY, fZ )
						end
					end, 500, 1 )
				end
			else 
				triggerServerEvent ( "VehicleShot", getLocalPlayer(), fX, fY, fZ ) --if theres no collision what so ever, create the explosion as far as the max distance allows.
				if getElementModel (vehicle) == 431 then --repeat once if your in a bus...
					setTimer (function()
						local distance = 30
						sX, sY, sZ = getElementPosition ( getLocalPlayer() )
						local fX, fY, fZ = sX, sY, sZ
						local rX, rY, rZ = getElementRotation ( vehicle )
						--local rX = 360 - rX
						local rZ = 360 - rZ
						local rX = 360 - rX
						--local rZ = 360 - rZ
						local offset = math.sqrt ( ( distance ^ 2 ) * 2 )
						sX = sX + math.sin ( math.rad ( rZ ) ) * 1.5
						sY = sY + math.cos ( math.rad ( rZ ) ) * 1.5
						fX = fX + math.sin ( math.rad ( rZ ) ) * offset
						fY = fY + math.cos ( math.rad ( rZ ) ) * offset
						fZ = fZ - math.tan ( math.rad ( rX ) ) * offset
						local col, x, y, z, element = processLineOfSight ( sX, sY, sZ + 0.5, fX, fY, fZ )
						if ( col ) and element ~= getLocalPlayer() and element ~= getPedOccupiedVehicle(getLocalPlayer()) then 
							triggerServerEvent ( "VehicleShot", getLocalPlayer(), x, y, z )
						else 
							triggerServerEvent ( "VehicleShot", getLocalPlayer(), fX, fY, fZ )
						end
					end, 500, 1 )
				end
			end
			guiNiceProgressBarSetProgress ( miniRocketBar, 0 )
			guiSetText ( miniRocketText, " - Reload: 0%" )
			guiSetVisible ( miniRocketText, true )
			guiSetVisible ( miniRocketBar, true )
			--setTimer ( reloadMiniRocket, 1000, 2, getLocalPlayer() )
			guiNiceProgressBarSetAlpha ( miniRocketBar, 0.5 )
			--setTimer ( hideGUI1, 2100, 1, getLocalPlayer() )
			reload2ndTime = 2000
			addEventHandler("onClientRender", getLocalPlayer(), reloadMiniRocket)
		elseif priWeapon == "minigun" then --if you got a minigun...
			if guiNiceProgressBarGetProgress ( miniAmmoBar ) == 0 then return --if your out of ammo, do nothing
			else
				if ( miniLastShot > getTickCount() ) then return end --anti-spam check
				isShooting = true --a check to tell the script your currently shooting
				miniLastShot = getTickCount() + 500
				triggerServerEvent ( "startFire", getLocalPlayer() ) --trigger a server event to tell all the other players youre shooting
				shootingPlayers[getLocalPlayer()] = true --add yourself to the shootPlayers table.
			end
		elseif priWeapon == "laser" then
			--outputChatBox ("local laser start")
			if ( miniLastShot > getTickCount() ) then return end --anti-spam check
			isShootingLaser = true
			miniLastShot = getTickCount() + 500
			triggerServerEvent ( "startFireLaser", getLocalPlayer() )
			shootingLaserPlayers[getLocalPlayer()] = true
		end
	end
end
end


function clientResourceStart ()
	toggleControl("vehicle_fire", false) --force vehicle_fire to off.
	local x, y = guiGetScreenSize()
	x = ( x / 2 ) - 100
	y = y * 0.9
	if not deathscore then
		deaths = 0
		if tonumber(maxdeaths1) > 0 then --and tonumber(theMode1) == 1 then
			deathscore = guiCreateLabel(0.85, 0.15, 0.10, 0.10, "Deaths: " ..deaths.."/"..maxdeaths1.."", true)
		else
			deathscore = guiCreateLabel(0.85, 0.15, 0.10, 0.10, "Deaths: " ..deaths.."", true)
		end
		guiSetFont(deathscore, "default-bold-small")
		guiLabelSetColor (deathscore, 255,255,255)
	else
		if maxdeaths1 > 0 and tonumber(theMode1) == 1 then
			guiSetText(deathscore, "Deaths: " ..deaths.."/"..maxdeaths1.."")
		else
			guiSetText(deathscore, "Deaths: " ..deaths.."")
		end
	end
		rcHealthBar = guiCreateNiceProgressBar ( x, y, 200, 20, false )
		rcHealthText = guiCreateLabel ( x, y, 100, 25, "", false )
		guiNiceProgressBarSetProgress ( rcHealthBar, 100, "left" )
		guiSetVisible ( rcHealthText, false )
		guiSetVisible ( rcHealthBar, false )
		guiLabelSetColor ( rcHealthText, 0, 255, 0, 255 )
		local x1, y1 = guiGetScreenSize()
		x1 = ( x1 / 2 ) - 100
		y1 = y1 * 0.85
		miniRocketBar = guiCreateNiceProgressBar ( x1, y1, 200, 20, false )
		miniRocketText = guiCreateLabel ( x1, y1, 100, 25, "", false )
		guiLabelSetColor ( miniRocketText, 0, 255, 0, 255 )
		guiSetVisible ( miniRocketText, false )
		guiSetVisible ( miniRocketBar, false )
		guiNiceProgressBarSetProgress ( miniRocketBar, 100, "left" )
		miniAmmoBar = guiCreateNiceProgressBar ( x1, y1, 200, 20, false )
		guiProgressBarSetProgress(miniAmmoBar, 100)
		miniAmmoText = guiCreateLabel ( x1, y1, 100, 25, "", false )
		guiSetVisible ( miniAmmoText, false )
		guiSetVisible ( miniAmmoBar, false )
		guiLabelSetColor ( miniAmmoText, 0, 255, 0, 255 )
		local x2, y2 = guiGetScreenSize()
		x2 = ( x2 / 4 ) - 150
		y2 = y2 * 0.4
		healthBar = guiCreateNiceProgressBar ( 0.775, 0.225, 0.18, 0.03, true )
		healthText = guiCreateLabel ( 0.775, 0.225, 0.18, 0.03, "", true )
		guiLabelSetColor ( healthText, 0, 200, 0, 255 )
		guiSetVisible ( healthText, false )
		guiSetVisible ( healthBar, false )
		setTimer ( fireMiniGun, 100, 0 )
		addEventHandler ("onClientRender", getRootElement(), fireZeLaser )
		--ok, theres no way i can be arsed to comment each and every line here... Basicly what it does is, gets the screen size, creates the reloadbars, gui labels etc etc...

end

addEventHandler("onClientPlayerSpawn", getLocalPlayer(), function () --this triggers each time you spawn
	if ( secondaim ) then --due to an mta bug i destroy the second aim each time you spawn, and recreates it... and still it aitn visible sometimes >_<
		destroyElement(secondaim)
		secondaim = nil
	end
	if not ( crosshair ) then --if you aint got a primary crosshair
		crosshair = guiCreateStaticImage(0.48, 0.4, 0.04, 0.05, "cross.png", true, nil) --create one
	end
	secondaim = createMarker ( 0, 0, 1, "corona", 1, 0, 0, 255, 255 ) --recreate the second aim.
	bindKey ( "mouse2", "down", fireRockets )
	bindKey ( "mouse2", "up", fireHeat )
	bindKey ( "mouse1", "down", fireMiniRocket )
	bindKey ( "mouse1", "up", stopPriWeapon )
	bindKey ( "r", "down", placeStinger ) --bind all the keys.
	showPlayerHudComponent("health", false)
	showPlayerHudComponent("money", false)
	showPlayerHudComponent("weapon", false)
	showPlayerHudComponent("vehicle_name", false)
	showPlayerHudComponent("armour", false)
	showPlayerHudComponent("area_name", false) --hide GTA's own HUD stuff.
	
	setTimer(enterVehicle, 1000, 1) --set a timer to trigger the enterVehicle event.

end)

addEventHandler("onClientPlayerWasted", getLocalPlayer(), function() --when you die...
	deaths = deaths + 1 --add one death to your current deaths.
	if maxdeaths1 > 0 then --this is used for elimination mode
		if tonumber(deaths) <= tonumber(maxdeaths1) then --if your current deaths is below or the same as the max death setting.
			guiSetText(deathscore, "Deaths: " ..deaths.."/"..maxdeaths1.."") --print it.
		end
	else
		guiSetText(deathscore, "Deaths: " ..deaths.."") --for deathmatch mode: just keep adding one death each time you die
	end
	if ( reload ) then --if you where reloading when u died.
		killTimer(reload) --stop reloading
		reload = nil
		killTimer(reload1)
		reload1 = nil
	end
	if isShooting == true then --if you where shooting your minigun when i died.
		stopMiniRocket() --stop it.
	end
	if isEventHandled("onClientRender", getLocalPlayer(), reloadRocket) == true then
		removeEventHandler("onClientRender", getLocalPlayer(), reloadRocket)
	end
	if isEventHandled("onClientRender", getLocalPlayer(), reloadMiniRocket) == true then
		removeEventHandler("onClientRender", getLocalPlayer(), reloadMiniRocket)
	end
	if isShootingLaser == true then
		stopZeLaserBeam()
	end
	if isReCharging == true then
		isReCharging = false
		removeEventHandler("onClientRender", getLocalPlayer(), startLaserReCharge)
	end
	destroyElement(secondaim) --yepp. i destroy the second aim here aswell....
	secondaim = nil
	if secondHealthBar then --if you got a 2nd healthbar
		guiSetVisible(secondHealthBar, false) --hide it
		guiSetVisible(secondHealthText, false)
	end
	if crosshair then --destroy your primary crosshair
		destroyElement(crosshair)
		crosshair = nil
	end
	guiSetVisible ( rcHealthText, false )
	guiSetVisible ( rcHealthBar, false )
	guiSetVisible ( miniAmmoText, false )
	guiSetVisible ( miniAmmoBar, false )
	guiSetVisible ( miniRocketBar, false )
	guiSetVisible ( miniRocketText, false )
	guiSetVisible ( healthBar, false )
	guiSetVisible ( healthText, false ) --hide all the gui related stuff
	shootingPlayers = {}
	shootingLaserPlayers = {}
	unbindKey ( "mouse2", "down", fireRockets )
	unbindKey ( "mouse2", "up", fireHeat )
	unbindKey ( "mouse1", "down", fireMiniRocket )
	unbindKey ( "mouse1", "up", stopPriWeapon )
	unbindKey ( "r", "down", placeStinger ) --unbind all the keys.
end)

function stopPriWeapon ()
	if priWeapon == "minigun" then
		stopMiniRocket()
	elseif priWeapon == "laser" then
		stopZeLaserBeam()
	end
end

addEvent("resetDeaths",true) --this event is triggerd when the game restarts, to reset your death scores.
addEventHandler("resetDeaths", getRootElement(), function()
	deaths = 0
	if maxdeaths1 > 0 then
		guiSetText(deathscore, "Deaths: " ..deaths.."/"..maxdeaths1.."")
	else
		guiSetText(deathscore, "Deaths: " ..deaths.."")
	end
end)

function hideGUI (player) --hide guis...
	guiNiceProgressBarSetAlpha ( rcHealthBar, 0 )
end

function hideGUI1 (player) --hide guis....
	guiNiceProgressBarSetAlpha ( miniRocketBar, 0 )
end

function stopMiniRocket ( theGay ) --stops the minigun from firing, also triggerd when u release mouse1
	isShooting = false --tell the script u stopped shooting
	triggerServerEvent ( "stopFire", getLocalPlayer() ) --trigger a server event to tell all the other players you stopped shooting
	shootingPlayers[getLocalPlayer()] = nil --remove yourself from the table
	guiNiceProgressBarSetAlpha ( miniAmmoBar, 0 )
end

function Shooting ()
	shootingPlayers[source] = true
end
addEvent ( "zeBullet", true )
addEventHandler ( "zeBullet", getRootElement(), Shooting )

function stopShooting ()
	shootingPlayers[source] = nil
end
addEvent ( "stopBullets", true )
addEventHandler ( "stopBullets", getRootElement(), stopShooting )

function fireMiniGun () --the main minigun function... im lazy, so i wont go into details... You dont want to edit this anyway.... no... no you dont! i said NO!
--
for player,v in pairs(shootingPlayers) do
	if isPedInVehicle ( player ) then
		if player == getLocalPlayer() then
			if guiNiceProgressBarGetProgress ( miniAmmoBar ) <= 0 then
				triggerServerEvent ( "stopFire", getLocalPlayer() )
			else
			playSoundFrontEnd(27)
			local ammo = guiNiceProgressBarGetProgress ( miniAmmoBar ) - 0.2
			guiNiceProgressBarSetProgress ( miniAmmoBar, ammo )
			ammo = ammo * 5
			guiSetText ( miniAmmoText, " - Ammo: "..math.ceil(ammo).."" )
			guiSetVisible ( miniAmmoText, true )
			guiSetVisible ( miniAmmoBar, true )
			guiNiceProgressBarSetAlpha ( miniAmmoBar, 0.5	)
			end
		end
		local vehicle = getPedOccupiedVehicle ( player )
			if player == getLocalPlayer() and guiNiceProgressBarGetProgress ( miniAmmoBar ) <= 0 then return end
			local distance = 30
			if getElementModel (vehicle) == 431 then
				sX, sY, sZ = getElementPosition ( getLocalPlayer() )
			else
				sX, sY, sZ = getElementPosition ( vehicle )
			end
			local fX, fY, fZ = sX, sY, sZ
			local rX, rY, rZ = getElementRotation ( vehicle )
			local rX = 360 - rX
			local rZ = 360 - rZ
			--local rZ = 360 - rZ
			local offset = math.sqrt ( ( distance ^ 2 ) * 2 )
			sX = sX + math.sin ( math.rad ( rZ ) ) * 1.5
			sY = sY + math.cos ( math.rad ( rZ ) ) * 1.5
			fX = fX + math.sin ( math.rad ( rZ ) ) * offset
			fY = fY + math.cos ( math.rad ( rZ ) ) * offset
			fZ = fZ - math.tan ( math.rad ( rX ) ) * offset
			local col, x, y, z, element = processLineOfSight ( sX, sY, sZ + 0.5, fX, fY, fZ - 0.5, true,true )
			if ( col ) then 
				bulletz = createObject ( 3106, sX, sY, sZ + 0.6, 0, 0, 0 )
				setElementCollisionsEnabled (bulletz, false)
				moveObject ( bulletz, 200, x, y, z - 0.3 )
				setTimer ( destroyElement, 1000, 1, bulletz )
				if ( element ) then
					if ( getElementType ( element ) == "vehicle" ) then
						driver = getVehicleOccupant ( element )
						if ( driver == getLocalPlayer() and driver ~= player ) then
							daHealth = getElementHealth ( element ) - 50
							if daHealth < 0 then
								daHealth = 0
							end
							setElementHealth ( element, daHealth )
						end
					end
				end
			else
				bulletz = createObject ( 3106, sX, sY, sZ + 0.6, 0, 0, 0 )
				setElementCollisionsEnabled (bulletz, false)
				moveObject ( bulletz, 100, fX, fY, fZ + 0.5 )
				setTimer ( destroyElement, 500, 1, bulletz )
			end
	end
end
end

function enterVehicle (player) --when you enter a vehicle...
	--priWeapon = "laser"
	guiSetVisible ( rcHealthText, true )
	guiSetVisible ( rcHealthBar, true )
	veLastShot = 0
	guiNiceProgressBarSetAlpha ( rcHealthBar, 0 )
	guiNiceProgressBarSetProgress ( rcHealthBar, 100 )
	guiSetText ( rcHealthText, " - Reload: 100%" )
	local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
	local zeHealth = getElementHealth ( vehicle )
	local zeHealth = zeHealth / 10
	if zeHealth > 100 then
		armor = zeHealth - 100
		armor = armor * 2
		if not secondHealthBar then
			secondHealthBar = guiCreateNiceProgressBar ( 0.775, 0.265, 0.18, 0.03, true )
			secondHealthText = guiCreateLabel ( 0.775, 0.265, 0.18, 0.03, "", true )
			guiLabelSetColor ( secondHealthText, 0, 200, 0, 255 )
		else
			guiSetVisible(secondHealthBar, true)
			guiSetVisible(secondHealthText, true)
		end
		guiNiceProgressBarSetProgress ( secondHealthBar, tonumber(armor), "left" )
		guiNiceProgressBarSetProgress ( healthBar, 100, "left" )
		guiSetText ( healthText, " - Health: 100%" )
		guiSetText ( secondHealthText, " - Armor: "..math.ceil(armor).. "%" )
		guiNiceProgressBarSetAlpha ( secondHealthBar, 0.5 )
		setTimer ( guiNiceProgressBarSetAlpha, 100, 1, secondHealthBar, 0 )
	else
		if secondHealthBar then
			guiNiceProgressBarSetProgress ( secondHealthBar, 0, "left" )
		end
		guiNiceProgressBarSetProgress ( healthBar, tonumber(zeHealth), "left" )
		guiSetText ( healthText, " - Health:" ..math.ceil(zeHealth).. "%" )
		guiSetVisible ( healthBar, true )
		guiSetVisible ( healthText, true )
		guiNiceProgressBarSetAlpha ( healthBar, 0.5 )
		setTimer ( guiNiceProgressBarSetAlpha, 100, 1, healthBar, 0 )
	end
	if priWeapon == "explosion" then
		guiSetVisible ( miniAmmoText, false )
		guiSetVisible ( miniAmmoBar, false )
		guiSetVisible ( miniRocketBar, true )
		guiSetVisible ( miniRocketText, true )
		guiSetText ( miniRocketText, " - Reload: 100%" )
	elseif priWeapon == "minigun" then
		guiNiceProgressBarSetProgress ( miniAmmoBar, 100 )
		guiSetVisible ( miniAmmoBar, true )
		guiSetVisible ( miniAmmoText, true )
		guiSetText ( miniAmmoText, " - Ammo: 500" )
		guiSetVisible ( miniRocketText, false )
		guiSetVisible ( miniRocketBar, false )
	elseif priWeapon == "laser" then
		guiNiceProgressBarSetProgress ( miniAmmoBar, 100 )
		guiSetVisible ( miniAmmoBar, true )
		guiSetVisible ( miniAmmoText, true )
		guiSetText ( miniAmmoText, " - 100% Charged" )
	end
	if thrWeapon == "armor" then
		setTimer(triggerServerEvent, 500, 1, "zeArmor", getLocalPlayer())
	elseif thrWeapon == "nos" then
		setTimer(triggerServerEvent, 500, 1, "zeNOS", getLocalPlayer())
	end
end
addEventHandler ( "onClientPlayerVehicleEnter", getRootElement(), enterVehicle )
addEvent ( "enterVehicle", true )
addEventHandler ( "enterVehicle", getRootElement(), enterVehicle )

hasReplaced = false
function replaceTheLaser ()
if source == theLaser then
	if hasReplaced == false then
		hasReplaced = true
		local txd = engineLoadTXD ( "minigx.txd" )
		engineImportTXD ( txd, 1337 )
		dff = engineLoadDFF ( "lasergun.dff", 0 )
		engineReplaceModel ( dff, 1337 )
	end
	removeEventHandler("onClientElementStreamIn", theLaser, replaceTheLaser)
	destroyElement(source)
end
end
addEvent("replaceLaser", true)
addEventHandler("replaceLaser", getRootElement(), replaceTheLaser)

function exitVehicle (player)
if ( source == getLocalPlayer() ) then
	cancelEvent()
	outputChatBox ("Stay in the car!")
end
end
addEventHandler ( "onClientVehicleStartExit", getRootElement(), exitVehicle )

function vehicleDamage ()
if getVehicleOccupant(source) == getLocalPlayer() then
	local maMan = getVehicleOccupant ( source )
	local zeHealth = getElementHealth ( source )
	local zeHealth = zeHealth / 10
	if zeHealth > 100 then
		armor = zeHealth - 100
		armor = armor * 2
		if not secondHealthBar then
			secondHealthBar = guiCreateNiceProgressBar ( 0.775, 0.265, 0.18, 0.03, true )
			secondHealthText = guiCreateLabel ( 0.775, 0.265, 0.18, 0.03, "", true )
			guiLabelSetColor ( secondHealthText, 0, 255, 0, 255 )
		else
			guiSetVisible(secondHealthBar, true)
			guiSetVisible(secondHealthText, true)
		end
		guiNiceProgressBarSetProgress ( secondHealthBar, tonumber(armor), "left" )
		guiNiceProgressBarSetProgress ( healthBar, 100, "left" )
		guiSetText ( healthText, " - Health: 100%" )
		guiSetText ( secondHealthText, " - Armor: "..math.ceil(armor).. "%" )
		guiNiceProgressBarSetAlpha ( secondHealthBar, 0.5 )
		setTimer ( guiNiceProgressBarSetAlpha, 100, 1, secondHealthBar, 0 )
	else
		if secondHealthBar then
			guiNiceProgressBarSetProgress ( secondHealthBar, 0, "left" )
			guiSetText(secondHealthText, " - Armor: 0%" )
		end
		guiNiceProgressBarSetProgress ( healthBar, tonumber(zeHealth), "left" )
		guiSetText ( healthText, " - Health:" ..math.ceil(zeHealth).. "%" )
		guiSetVisible ( healthBar, true )
		guiNiceProgressBarSetAlpha ( healthBar, 0.5 )
		setTimer ( guiNiceProgressBarSetAlpha, 100, 1, healthBar, 0 )
	end
end
end
addEvent ("damageVehicle", true)
addEventHandler ( "damageVehicle", getRootElement(), vehicleDamage )


function noCollBandito (myWeapon, mySecWeapon1, mySecWeapon2, mySecWeapon3)
if isElement(myWeapon) then
	setElementCollisionsEnabled (myWeapon, false)
end
if isElement(mySecWeapon1) then
	setElementCollisionsEnabled (mySecWeapon1, false)
end
if isElement(mySecWeapon2) then
	setElementCollisionsEnabled (mySecWeapon2, false)
end
if isElement(mySecWeapon3) then
	setElementCollisionsEnabled (mySecWeapon3, false)
end
end
addEvent ("noCollBandito", true)
addEventHandler ("noCollBandito", getRootElement(), noCollBandito)

function secondaryCrossHair ()
if isPedInVehicle ( getLocalPlayer()) then
if not ( secondaim ) then return end
local vehicle = getPedOccupiedVehicle ( getLocalPlayer() )
			local distance = 20
			if getElementModel (vehicle) == 431 then
				sX, sY, sZ = getElementPosition ( getLocalPlayer() )
			else
				sX, sY, sZ = getElementPosition ( vehicle )
			end
			local fX, fY, fZ = sX, sY, sZ
			local rX, rY, rZ = getElementRotation ( vehicle )
			local rX = 360 - rX
			local rZ = 360 - rZ
			--local rZ = 360 - rZ
			local offset = math.sqrt ( ( distance ^ 2 ) * 2 )
			sX = sX + math.sin ( math.rad ( rZ ) ) * 1.5
			sY = sY + math.cos ( math.rad ( rZ ) ) * 1.5
			fX = fX + math.sin ( math.rad ( rZ ) ) * offset
			fY = fY + math.cos ( math.rad ( rZ ) ) * offset
			fZ = fZ - math.tan ( math.rad ( rX ) ) * offset
			local col, x, y, z, element = processLineOfSight ( sX, sY, sZ + 0.5, fX, fY, fZ - 0.5, true,true )
			if ( col ) and element ~= getLocalPlayer and element ~= getPedOccupiedVehicle(getLocalPlayer()) then
				setElementPosition ( secondaim, x, y, z )
			else
				setElementPosition ( secondaim, fX, fY, fZ )
			end
end
end
addEventHandler ("onClientRender", getRootElement(), secondaryCrossHair )

addCommandHandler("laser", function ()
	priWeapon = "laser"
end)

function startZeLaser ()
	--outputChatBox("is shooting laser")
	shootingLaserPlayers[source] = true
end
addEvent ( "zeLaserBeam", true )
addEventHandler ( "zeLaserBeam", getRootElement(), startZeLaser )

function stopZeLaser ()
	--outputChatBox ("has stopped shooting laser")
	shootingLaserPlayers[source] = nil
end
addEvent ( "stopLaserBeam", true )
addEventHandler ( "stopLaserBeam", getRootElement(), stopZeLaser )

isReCharging = false
function stopZeLaserBeam ( theGay ) --stops the laser from firing, also triggerd when you release mouse1
	isShootingLaser = false --tell the script u stopped shooting
	addEventHandler("onClientRender", getLocalPlayer(), startLaserReCharge)
	isReCharging = true
	playSoundFrontEnd(48)
	triggerServerEvent ( "stopFireLaser", getLocalPlayer() ) --trigger a server event to tell all the other players you stopped shooting
	shootingLaserPlayers[getLocalPlayer()] = nil --remove yourself from the table
	guiNiceProgressBarSetAlpha ( miniAmmoBar, 0 )
end

function startLaserReCharge()
	local ammo = guiNiceProgressBarGetProgress ( miniAmmoBar ) + 0.2
	if ammo <= 100 then
		guiNiceProgressBarSetProgress ( miniAmmoBar, ammo )
		guiSetText ( miniAmmoText, " - "..math.ceil(ammo).."% charged" )
	else
		isReCharging = false
		removeEventHandler("onClientRender", getLocalPlayer(), startLaserReCharge)
	end
end
	
function fireZeLaser () --the main minigun function... im lazy, so i wont go into details... You dont want to edit this anyway.... no... no you dont! i said NO!
for player,v in pairs(shootingLaserPlayers) do
	if isPedInVehicle ( player ) then
		if player == getLocalPlayer() then
			if guiNiceProgressBarGetProgress ( miniAmmoBar ) <= 0 then
				triggerServerEvent ( "stopFire", getLocalPlayer() )
				playSoundFrontEnd(48)
			else
				playSoundFrontEnd(47)
				if isReCharging == true then
					isReCharging = false
					removeEventHandler("onClientRender", getLocalPlayer(), startLaserReCharge)
				end
				local ammo = guiNiceProgressBarGetProgress ( miniAmmoBar ) - 0.4
				guiNiceProgressBarSetProgress ( miniAmmoBar, ammo )
				guiSetText ( miniAmmoText, " - "..math.ceil(ammo).."% charged" )
				guiSetVisible ( miniAmmoText, true )
				guiSetVisible ( miniAmmoBar, true )
				guiNiceProgressBarSetAlpha ( miniAmmoBar, 0.5	)
			end
		end
		local vehicle = getPedOccupiedVehicle ( player )
			if player == getLocalPlayer() and guiNiceProgressBarGetProgress ( miniAmmoBar ) <= 0 then return end
			local distance = 30
			if getElementModel (vehicle) == 431 then
				sX, sY, sZ = getElementPosition ( getLocalPlayer() )
			else
				sX, sY, sZ = getElementPosition ( vehicle )
			end
			local fX, fY, fZ = sX, sY, sZ
			local rX, rY, rZ = getElementRotation ( vehicle )
			local rX = 360 - rX
			local rZ = 360 - rZ
			--local rZ = 360 - rZ
			local offset = math.sqrt ( ( distance ^ 2 ) * 2 )
			sX = sX + math.sin ( math.rad ( rZ ) ) * 1.5
			sY = sY + math.cos ( math.rad ( rZ ) ) * 1.5
			fX = fX + math.sin ( math.rad ( rZ ) ) * offset
			fY = fY + math.cos ( math.rad ( rZ ) ) * offset
			fZ = fZ - math.tan ( math.rad ( rX ) ) * offset
			local col, x, y, z, element = processLineOfSight ( sX, sY, sZ + 0.5, fX, fY, fZ - 0.5, true,true )
			if ( col ) then 
				dxDrawLine3D (sX, sY, sZ, x, y, z, tocolor (255, 0, 0, 255), 2)
				if ( element ) then
					if ( getElementType ( element ) == "vehicle" ) then
						driver = getVehicleOccupant ( element )
						if ( driver == getLocalPlayer() and driver ~= player ) then
							daHealth = getElementHealth ( element ) - 10
							if daHealth < 0 then
								daHealth = 0
							end
							setElementHealth ( element, daHealth )
						end
					end
				end
			else
				dxDrawLine3D (sX, sY, sZ, fX, fY, fZ, tocolor (255, 0, 0, 255), 2)
			end
	end
end
end



function unbindKey (key, state, theFunction )
	if isBound[key] then
		if (state) then
			if isBound[key]["up"] == state then
				isBound[key]["up"] = nil
				if (theFunction) then
					isBound[key]["functionU"] = nil
					_unbindKey(key, state, theFunction)
				else
					_unbindKey(key, state)
				end
			elseif isBound[key]["down"] == state then
				isBound[key]["down"] = nil
				if (theFunction) then
					isBound[key]["functionD"] = nil
					_unbindKey(key, state, theFunction)
				else
					_unbindKey(key, state)
				end
			elseif isBound[key]["both"] == state then
				isBound[key]["both"] = nil
				if (theFunction) then
					isBound[key]["functionB"] = nil
					_unbindKey(key, state, theFunction)
				else
					_unbindKey(key, state)
				end
			end
			return true
		else
			_unbindKey(key)
			return true
		end
	else
		return false
	end
end

isBound = {}
function bindKey (key, state, theFunction)
	if not (isBound[key]) then
		isBound[key] = {}
	end
	isBound[key]["key"] = key
	if state == "down" then
		isBound[key]["down"] = state
		isBound[key]["functionD"] = theFunction
	elseif state == "up" then
		isBound[key]["up"] = state
		isBound[key]["functionU"] = theFunction
	elseif state == "both" then
		isBound[key]["both"] = state
		isBound[key]["functionB"] = theFunction
	end
	_bindKey (key, state, theFunction)
end

function isKeyBound (key, state, theFunction)
if not isBound[key] then return false end
	if isBound[key]["key"] == key then
		if not ( state ) then
			return true
		else
			if ( state == "up" ) then
				if isBound[key]["up"] == state then
					if ( theFunction ) then
						if isBound[key]["functionU"] == theFunction then
							return true
						else
							return false
						end
					else
						return true
					end
				else
					return false
				end
			elseif ( state == "down" ) then
				if isBound[key]["down"] == state then
					if ( theFunction ) then
						if isBound[key]["functionD"] == theFunction then
							return true
						else
							return false
						end
					else
						return true
					end
				else
					return false
				end
			elseif ( state == "both" ) then
				if isBound[key]["both"] == state then
					if ( theFunction ) then
						if isBound[key]["functionB"] == theFunction then
							return true
						else
							return false
						end
					else
						return true
					end
				else
					return false
				end
			end
		end
	else
		return false
	end
end

handledEvents = {}
function addEventHandler (event, element, theFunction, propagated)
	if not propagated then
		propagated = nil
	end
	
	if not ( handledEvents[event] ) then 
		handledEvents[event] = {}
	end

		if handledEvents[event][theFunction] == theFunction then
			return false
		else
			handledEvents[event][event] = event
			handledEvents[event][element] = element
			handledEvents[event][theFunction] = theFunction
			isHandled = _addEventHandler(event, element, theFunction, propagated)
			return isHandled
		end
end

function isEventHandled (event, element, theFunction)
	if handledEvents[event] then
		if handledEvents[event][event] == event then
			if ( element ) then
				if handledEvents[event][element] == element then
					if ( theFunction ) then
						if handledEvents[event][theFunction] == theFunction then
							return true
						else
							return false
						end
					else
						return true
					end
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
	else
		return false
	end
end

function removeEventHandler (event, element, theFunction)
	if handledEvents[event][event] == event and handledEvents[event][element] == element and handledEvents[event][theFunction] == theFunction then
		handledEvents[event][theFunction] = nil
	end
	_removeEventHandler(event, element, theFunction)
end
