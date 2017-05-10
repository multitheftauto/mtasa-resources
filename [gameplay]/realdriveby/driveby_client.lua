addEvent ( "doSendDriveBySettings", true )
addEvent ( "deletePedForDrivebyFix", true )
addEvent ( "savePedForDrivebyFix", true )

---Left/right toggling
local bikes = { [581]=true,[509]=true,[481]=true,[462]=true,[521]=true,[463]=true,
	[510]=true,[522]=true,[461]=true,[448]=true,[468]=true,[586]=true }
local driver = false
local shooting = false
local exitingvehicle = false 
local helpText, helpAnimation, block
local lastSlot = 0
local settings = {}
local functions = {}  -- using this table to easily localize functions
local limiterTimer
local peds = {}
local pedowner = {}


-- Use this to detect damage on the player using driveby on a bike --
local function pedGotHit ( attacker, weapon, bodypart, loss )
	-- Let the attacker trigger it --
	if attacker == localPlayer and pedowner[source] ~= attacker then
		triggerEvent ( "onClientPlayerDamage", pedowner[source], attacker, weapon, bodypart, loss )
	end
end


-- function to change the alpha of the helptext --
local function helpTextChangeAlpha ( alpha )
	helpText:color(255,255,255,alpha)
end


-- fade in help --
local function fadeInHelp ()
	if helpAnimation then helpAnimation:remove() end
	local _,_,_,a = helpText:color()
	if a ~= 255 then
		helpAnimation = Animation.createAndPlay(helpText, Animation.presets.dxTextFadeIn(300))
		setTimer ( helpTextChangeAlpha, 300, 1, 255 )
	end
end


-- fade out help --
local function fadeOutHelp ()
	if helpAnimation then helpAnimation:remove() end
	local _,_,_,a = helpText:color()
	if a ~= 0 then
		helpAnimation = Animation.createAndPlay(helpText, Animation.presets.dxTextFadeOut(300))
		setTimer ( helpTextChangeAlpha, 300, 1, 0 )
	end
end


-- remove keys for using driveby --
functions.removeKeyToggles = function ( vehicle )
	toggleControl ( "vehicle_look_left",true )
	toggleControl ( "vehicle_look_right",true )
	toggleControl ( "vehicle_secondary_fire",true )
	functions.toggleTurningKeys(getElementModel(vehicle),true)
	fadeOutHelp()
	removeEventHandler ( "onClientPlayerVehicleExit", localPlayer, functions.removeKeyToggles )
end


--Get the settings details from the server, and act appropriately according to them
addEventHandler("doSendDriveBySettings",localPlayer, function ( newSettings, thepeds )
	settings = newSettings
	--We change the tables into an indexed table that's easier to check
	local newTable = {}
	if settings.blockedVehicles[1] then
		for i=1, #settings.blockedVehicles do
			newTable[settings.blockedVehicles[i]] = true
		end
	end
	settings.blockedVehicles = newTable
	newTable = {}
	if settings.driver[1] then
		for i=1, #settings.driver do 
			newTable[settings.driver[i]] = true
		end
	end
	settings.driver = newTable
	-- get the peds of the guys using driveby --
	newTable = {}
	if settings.passenger[1] then
		for i=1, #settings.passenger do 
			newTable[settings.passenger[i]] = true
		end
	end
	settings.passenger = newTable
	peds = {}
	pedowner = {}
	for i, v in pairs ( thepeds ) do
		peds[i] = v 
		pedowner[v] = i
	end
	if eject_on_driveby_fix then
		--[[ Block driveby when exiting vehicle: 
  		setPedDoingGangDriveby ejects the player if he is trying to get out of the vehicle (without animations ) ]]
		addEventHandler ( "onClientVehicleStartExit", root, function ( player )
		if player == localPlayer then
			exitingvehicle = true
		end
	end
end )	


-- Use driveby --
functions.toggleDriveby = function()
	-- if you are in a vehicle --
	if isPedInVehicle ( localPlayer ) then
		local veh = getPedOccupiedVehicle ( localPlayer )
		local vehicleID = getElementModel ( veh )
		-- if the vehicle isn't blocked for using driveby --
		if not settings.blockedVehicles[vehicleID] then
			local equipedWeapon = getPedWeaponSlot ( localPlayer )
			-- if you dont have any equiped weapons (not doing driveby) --
			if equipedWeapon == 0 then
				-- if the player isn't exiting the vehicle --
	 			if not exitingvehicle then
					local weaponsTable = driver and settings.driver or settings.passenger
					local switchTo
					local switchToWeapon
					local lastSlotAmmo = getPedTotalAmmo ( localPlayer, lastSlot )
					local lastSlotWeapon = getPedWeapon ( localPlayer, lastSlot )
					-- if you didn't used a weapon last time or don't have ammo for it, get a new weapon --
					if ( not lastSlotAmmo or lastSlotAmmo == 0 or lastSlot == 0 ) and not weaponsTable[lastSlotWeapon] then
						for i=1, 12 do
							local weapon = getPedWeapon ( localPlayer, i )
							if weaponsTable[( weapon == 1 and 0 or weapon )] then
								if getPedTotalAmmo ( localPlayer, i ) ~= 0 then
									if not switchTo or i == 4 then
										switchTo = i
										switchToWeapon = weapon
										break
									end
								end
							end
						end
					else 
						switchTo = lastSlot
						switchToWeapon = lastSlotWeapon
					end
					-- if you got a weapon to switch to --
					if switchTo then
						setPedDoingGangDriveby ( localPlayer, true )
						setPedWeaponSlot( localPlayer, switchTo )
						functions.limitDrivebySpeed ( switchToWeapon )
						toggleControl ( "vehicle_look_left",false )
						toggleControl ( "vehicle_look_right",false )
						toggleControl ( "vehicle_secondary_fire",false )
						functions.toggleTurningKeys(vehicleID,false)
						if settings.bikeHitboxFix and getVehicleType ( veh ) == "Bike" then
							triggerServerEvent ( "createPedForDrivebyFix", localPlayer )
						end
						addEventHandler ( "onClientPlayerVehicleExit",localPlayer,functions.removeKeyToggles )
						local prevw,nextw = next(getBoundKeys ( "Previous driveby weapon" )),next(getBoundKeys ( "Next driveby weapon" ))
						if prevw and nextw then
							if animation then 
								Animation:remove() 
							end
							helpText:text( "Press '"..prevw.."' or '"..nextw.."' to change weapon" )
							fadeInHelp()
							setTimer ( fadeOutHelp, 10000, 1 )
						end
					end
				end
			else -- if you are already in driveby
				setPedDoingGangDriveby ( localPlayer, false )
				setPedWeaponSlot( localPlayer, 0 )
				functions.limitDrivebySpeed ( switchToWeapon )
				toggleControl ( "vehicle_look_left",true )
				toggleControl ( "vehicle_look_right",true )
				toggleControl ( "vehicle_secondary_fire",true )
				functions.toggleTurningKeys(vehicleID,true)
				fadeOutHelp()
				triggerServerEvent ( "destroyPedForDrivebyFix", localPlayer )
				removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,functions.removeKeyToggles )
			end
		end
	end
end
addCommandHandler ( "Toggle Driveby", functions.toggleDriveby )



--This function handles the driveby switch weapon key
functions.switchDrivebyWeapon = function(cmd,progress)
	if not block then
		-- progress = -1 (previous weapon) or 1 (next weapon)
		progress = tonumber(progress)
		if progress then
			if not shooting then
				if isPedInVehicle( localPlayer ) then
					local currentWeapon = getPedWeapon( localPlayer )
					local currentSlot = getPedWeaponSlot(localPlayer)
					if currentSlot ~= 0 then
						local weaponsTable = driver and settings.driver or settings.passenger
						local switchTo, switchToWeapon
						if not weaponsTable[currentWeapon] then
							switchToWeapon = 0
							switchTo = 0
						end
						local j = currentSlot + progress
						while j ~= currentSlot do
							local nextWeapon = getPedWeapon ( localPlayer, j )
							if nextWeapon and weaponsTable[nextWeapon] then
								switchToWeapon = nextWeapon
								switchTo = j
								break
							end
							if j + progress < 0 or j + progress > 12 then
								j = progress < 0 and 12 or 1
							else
								j = j + progress
							end
						end
						--If a valid weapon was not found, dont set anything.
						if switchTo then
							lastSlot = switchTo
							setPedWeaponSlot( localPlayer, switchTo )
							functions.limitDrivebySpeed ( switchToWeapon )
						end
					end
				end
			end
		end
	end
end
addCommandHandler ( "Next driveby weapon", functions.switchDrivebyWeapon )
addCommandHandler ( "Previous driveby weapon", functions.switchDrivebyWeapon )


--Here lies the stuff that limits shooting speed (so slow weapons dont shoot ridiculously fast)
functions.limitDrivebySpeed = function( weaponID )
	local speed = settings.shotdelay[tostring(weaponID)]
	if not speed then 
		if not isControlEnabled ( "vehicle_fire" ) then 
			toggleControl ( "vehicle_fire", true )
		end
		removeEventHandler("onClientPlayerVehicleExit",localPlayer,functions.unbindFire)
		removeEventHandler("onClientPlayerWasted",localPlayer,functions.unbindFire)
		unbindKey ( "vehicle_fire", "both", functions.limitedKeyPress )
	elseif isControlEnabled ( "vehicle_fire" ) then 
		toggleControl ( "vehicle_fire", false )
		addEventHandler("onClientPlayerVehicleExit",localPlayer,functions.unbindFire)
		addEventHandler("onClientPlayerWasted",localPlayer,functions.unbindFire)
		bindKey ( "vehicle_fire","both",functions.limitedKeyPress,speed)
	end
end


functions.unbindFire = function()
	unbindKey ( "vehicle_fire", "both", functions.limitedKeyPress )
	if not isControlEnabled ( "vehicle_fire" ) then 
		toggleControl ( "vehicle_fire", true )
	end
	removeEventHandler("onClientPlayerVehicleExit",localPlayer,functions.unbindFire)
	removeEventHandler("onClientPlayerWasted",localPlayer,functions.unbindFire)
end


functions.pressKey = function ( controlName )
	setControlState ( controlName, true )
	setTimer ( setControlState, 150, 1, controlName, false )
end


functions.blockfalse = function()
	block = false 
end 


functions.limitedKeyPress = function(key,keyState,speed)
	if keyState == "down" then
		if not block then
			shooting = true
			functions.pressKey ( "vehicle_fire" )
			block = true
			setTimer ( functions.blockfalse, speed, 1 )
			limiterTimer = setTimer ( functions.pressKey, speed, 0, "vehicle_fire" )
		end
	else
		shooting = false
		if isTimer ( limiterTimer ) then
			killTimer ( limiterTimer )
		end
	end
end


functions.toggleTurningKeys = function(vehicleID, state)
	if bikes[vehicleID] then
		if not settings.steerBikes then
			toggleControl ( "vehicle_left", state )
			toggleControl ( "vehicle_right", state )
		end
	elseif not settings.steerCars then
		toggleControl ( "vehicle_left", state )
		toggleControl ( "vehicle_right", state )
	end
end


--This function simply sets up the driveby upon vehicle entry
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function ( _, seat )
	--If his seat is 0, store the fact that he's a driver
	exitingvehicle = false 
	driver = seat == 0
	lastSlot = 0
	--By default, we set the player's equiped weapon to nothing.
	setPedWeaponSlot( localPlayer, 0 )
	if settings.autoEquip then
		functions.toggleDriveby()
	end
end )


addEventHandler ("onClientPlayerWeaponSwitch", localPlayer, function ( _, curSlot )
	if isPedDoingGangDriveby(source) then	
		functions.limitDrivebySpeed(getPedWeapon(source, curSlot))
	end
end )


--Tell the server the clientside script was downloaded and started
addEventHandler ( "onClientResourceStart", resourceRoot, function()
	bindKey ( "mouse2", "down", "Toggle Driveby", "" )
	bindKey ( "e", "down", "Next driveby weapon", "1" )
	bindKey ( "q", "down", "Previous driveby weapon", "-1" )
	toggleControl ( "vehicle_next_weapon",false )
	toggleControl ( "vehicle_previous_weapon",false )
	triggerServerEvent ( "driveby_clientScriptLoaded", localPlayer )
	helpText = dxText:create("",0.5,0.85)
	helpText:scale(1)
	helpText:type("stroke",1)
end )


addEventHandler ( "onClientResourceStop", resourceRoot, function()
	toggleControl ( "vehicle_next_weapon",true )
	toggleControl ( "vehicle_previous_weapon",true )
end )


addEventHandler ( "deletePedForDrivebyFix", root, function ( )
	if peds[source] then
		pedowner[peds[source]] = nil 
	end
	peds[source] = nil 
end )


addEventHandler ( "savePedForDrivebyFix", root, function ( ped ) 
	local veh = getPedOccupiedVehicle ( source )
	if isElement ( veh ) then
		--setElementAlpha ( ped, 0 )
		peds[source] = ped 
		pedowner[ped] = source
		addEventHandler ( "onClientPedDamage", ped, pedGotHit )
		--setElementCollidableWith ( ped, veh, false )
		if source == localPlayer then
			setElementCollisionsEnabled ( ped, false )
		else 
			setElementCollisionsEnabled ( ped, true )
		end
		
	end
end )
