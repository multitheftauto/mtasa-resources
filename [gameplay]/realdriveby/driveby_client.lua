local driver = false
local shooting = false
local helpText,helpAnimation
local exitingVehicle = false
local block
lastSlot = 0
settings = {}


--This function simply sets up the driveby upon vehicle entry
local function setupDriveby( player, seat )
	--If his seat is 0, store the fact that he's a driver
	if seat == 0 then
		driver = true
	else
		driver = false
	end
	--By default, we set the player's equiped weapon to nothing.
	setPedWeaponSlot( localPlayer, 0 )
	if settings.autoEquip then
		toggleDriveby()
	end
	exitingVehicle = false
	lastSlot = 0
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, setupDriveby )

--Tell the server the clientside script was downloaded and started
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),
	function()
		bindKey ( "mouse2", "down", "Toggle Driveby", "" )
		bindKey ( "e", "down", "Next driveby weapon", "1" )
		bindKey ( "q", "down", "Previous driveby weapon", "-1" )
		bindKey ( "mouse_wheel_up", "down", "Next driveby weapon", "1" )
		bindKey ( "mouse_wheel_down", "down", "Previous driveby weapon", "-1" )
		toggleControl ( "vehicle_next_weapon",false )
		toggleControl ( "vehicle_previous_weapon",false )
		triggerServerEvent ( "driveby_clientScriptLoaded", localPlayer )
		helpText = dxText:create("",0.5,0.85)
		helpText:scale(1)
		helpText:type("stroke",1)
	end
)

addEventHandler("onClientResourceStop",getResourceRootElement(getThisResource()),
	function()
		toggleControl ( "vehicle_next_weapon",true )
		toggleControl ( "vehicle_previous_weapon",true )
	end
)

--Get the settings details from the server, and act appropriately according to them
addEvent ( "doSendDriveBySettings", true )
addEventHandler("doSendDriveBySettings",localPlayer,
	function(newSettings)
		settings = newSettings
		--We change the blocked vehicles into an indexed table that's easier to check
		local newTable = {}
		for key,vehicleID in ipairs(settings.blockedVehicles) do
			newTable[vehicleID] = true
		end
		settings.blockedVehicles = newTable
		settings.driverallowed = {}
		if settings.driver[1] then
			for i=1, #settings.driver do
				settings.driverallowed[settings.driver[i]] = true
			end
		end
		settings.passengerallowed = {}
		if settings.passenger[1] then
			for i=1, #settings.passenger do
				settings.passengerallowed[settings.passenger[i]] = true
			end
		end
		if settings.blockInstantEject then
			addEventHandler ( "onClientVehicleStartExit", root, function ( player )
				if player == localPlayer then
					exitingVehicle = true
				end
			end )
		end
		if not settings.enabled then
			toggleDriveby()
		end
	end
)

--This function handles the driveby toggling key.
function toggleDriveby()
	--If he's not in a vehicle dont bother
	if not isPedInVehicle( localPlayer ) then return end
	--If its a blocked vehicle dont allow it
	local vehicleID = getElementModel ( getPedOccupiedVehicle ( localPlayer ) )
	if settings.blockedVehicles[vehicleID] then return end
	--Has he got a weapon equiped?
	local equipedWeapon = getPedWeaponSlot( localPlayer )
	if settings.enabled and equipedWeapon == 0 then
		if exitingVehicle then return end
		--Decide whether he is a driver or passenger
		--We need to get the switchTo weapon by finding any valid IDs
		local switchTo
		local switchToWeapon
		local lastSlotWeapon = getPedWeapon ( localPlayer, lastSlot )
		local weaponsTableAllowed = driver and settings.driverallowed or settings.passengerallowed
		local lastSlotAmmo = getPedTotalAmmo ( localPlayer, lastSlot )
		if not lastSlotAmmo or lastSlotAmmo == 0 or getSlotFromWeapon(lastSlotWeapon) == 0 or not weaponsTableAllowed[lastSlotWeapon] then
			local weaponsTable = driver and settings.driver or settings.passenger
			for key,weaponID in ipairs(weaponsTable) do
				local slot = getSlotFromWeapon ( weaponID )
				local weapon = getPedWeapon ( localPlayer, slot )
				if weapon == 1 then weapon = 0 end --If its a brass knuckle, set it to a fist to avoid confusion
				--if the weapon the player has is valid
				if weapon == weaponID then
					--If the ammo isn't 0
					if getPedTotalAmmo ( localPlayer, slot ) ~= 0 then
						--If no switchTo slot was defined, or the slot was 4 (SMG slot takes priority)
						if not switchTo or slot == 4 then
							switchTo = slot
							switchToWeapon = weaponID
						end
					end
				end
			end
		else
			switchTo = lastSlot
			switchToWeapon = lastSlotWeapon
		end
		--If a valid weapon was not found, dont set anything.
		if not switchTo then return end
		setPedDoingGangDriveby ( localPlayer, true )
		setPedWeaponSlot( localPlayer, switchTo )
		--Setup our driveby limiter
		limitDrivebySpeed ( switchToWeapon )
		--Disable look left/right keys, they seem to become accelerate/decelerate (carried over from PS2 version)
		toggleControl ( "vehicle_look_left",false )
		toggleControl ( "vehicle_look_right",false )
		toggleControl ( "vehicle_secondary_fire",false )
		toggleTurningKeys(vehicleID,false)
		addEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
		local prevw,nextw = next(getBoundKeys ( "Previous driveby weapon" )),next(getBoundKeys ( "Next driveby weapon" ))
		if prevw and nextw then
			if animation then Animation:remove() end
			helpText:text( "Scroll or press '"..prevw.."' or '"..nextw.."' to change weapon" )
			fadeInHelp()
			setTimer ( fadeOutHelp, 10000, 1 )
		end
	else
		--If so, unequip it
		setPedDoingGangDriveby ( localPlayer, false )
		setPedWeaponSlot( localPlayer, 0 )
		limitDrivebySpeed ( switchToWeapon )
		toggleControl ( "vehicle_look_left",true )
		toggleControl ( "vehicle_look_right",true )
		toggleControl ( "vehicle_secondary_fire",true )
		toggleTurningKeys(vehicleID,true)
		fadeOutHelp()
		removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
	end
end
addCommandHandler ( "Toggle Driveby", toggleDriveby )

function removeKeyToggles(vehicle)
	toggleControl ( "vehicle_look_left",true )
	toggleControl ( "vehicle_look_right",true )
	toggleControl ( "vehicle_secondary_fire",true )
	toggleTurningKeys(getElementModel(vehicle),true)
	fadeOutHelp()
	exitingVehicle = false
	removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
end


--This function handles the driveby switch weapon key
function switchDrivebyWeapon(key,progress)
	if block then return end
	progress = tonumber(progress)
	if not progress then return end
	--If the fire button is being pressed dont switch
	if shooting then return end
	--If he's not in a vehicle dont bother
	if not isPedInVehicle( localPlayer ) then return end
	--If he's not in driveby mode dont bother either
	local currentWeapon = getPedWeapon( localPlayer )
	if currentWeapon == 1 then currentWeapon = 0 end --If its a brass knuckle, set it to a fist to avoid confusion
	local currentSlot = getPedWeaponSlot(localPlayer)
	if currentSlot == 0 then return end
	local weaponsTable = driver and settings.driver or settings.passenger
	local weaponsTableAllowed = driver and settings.driverallowed or settings.passengerallowed
	--Compile a list of the player's weapons
	local switchTo
	for key,weaponID in ipairs(weaponsTable) do
		if weaponID == currentWeapon or not weaponsTableAllowed[currentWeapon] then
			local i = key + progress
			--We keep looping the table until we go back to our original key
			while i ~= key do
				nextWeapon = weaponsTable[i]
				if nextWeapon then
					local slot = getSlotFromWeapon ( nextWeapon )
					local weapon = getPedWeapon ( localPlayer, slot )
					if ( weapon == nextWeapon  ) then
						switchToWeapon = weapon
						switchTo = slot
						break
					end
				end
				--Go back to the beginning if there is no valid weapons left in the table
				if not weaponsTable[i+progress] then
					if progress < 0 then
						i = #weaponsTable
					else
						i = 1
					end
				else
					i = i + progress
				end
			end
			break
		end
	end
	--If a valid weapon was not found, dont set anything.
	if not switchTo then return end
	lastSlot = switchTo
	setPedWeaponSlot( localPlayer, switchTo )
	limitDrivebySpeed ( switchToWeapon )
end
addCommandHandler ( "Next driveby weapon", switchDrivebyWeapon )
addCommandHandler ( "Previous driveby weapon", switchDrivebyWeapon )

--Here lies the stuff that limits shooting speed (so slow weapons dont shoot ridiculously fast)
local limiterTimer
function limitDrivebySpeed ( weaponID )
	local speed = settings.shotdelay[tostring(weaponID)]
	if not speed then
		if not isControlEnabled ( "vehicle_fire" ) then
			toggleControl ( "vehicle_fire", true )
		end
		removeEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
		removeEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
		unbindKey ( "vehicle_fire", "both", limitedKeyPress )
	else
		if isControlEnabled ( "vehicle_fire" ) then
			toggleControl ( "vehicle_fire", false )
			addEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
			addEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
			bindKey ( "vehicle_fire","both",limitedKeyPress,speed)
		end
	end
end

function unbindFire()
	unbindKey ( "vehicle_fire", "both", limitedKeyPress )
	if not isControlEnabled ( "vehicle_fire" ) then
			toggleControl ( "vehicle_fire", true )
	end
	removeEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
	removeEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
end

function limitedKeyPress (key,keyState,speed)
	if keyState == "down" then
		if block == true then return end
		shooting = true
		pressKey ( "vehicle_fire" )
		block = true
		setTimer ( function() block = false end, speed, 1 )
		limiterTimer = setTimer ( pressKey,speed, 0, "vehicle_fire" )
	else
		shooting = false
		if isTimer ( limiterTimer ) then
			killTimer ( limiterTimer )
		end
	end
end

function pressKey ( controlName )
	setPedControlState ( controlName, true )
	setTimer ( setPedControlState, 150, 1, controlName, false )
end

---Left/right toggling
local bikes = { [581]=true,[509]=true,[481]=true,[462]=true,[521]=true,[463]=true,
	[510]=true,[522]=true,[461]=true,[448]=true,[468]=true,[586]=true }
function toggleTurningKeys(vehicleID, state)
	if bikes[vehicleID] then
		if not settings.steerBikes then
			toggleControl ( "vehicle_left", state )
			toggleControl ( "vehicle_right", state )
		end
	else
		if not settings.steerCars then
			toggleControl ( "vehicle_left", state )
			toggleControl ( "vehicle_right", state )
		end
	end
end

function fadeInHelp()
	if helpAnimation then helpAnimation:remove() end
	local _,_,_,a = helpText:color()
	if a == 255 then return end
	helpAnimation = Animation.createAndPlay(helpText, Animation.presets.dxTextFadeIn(300))
	setTimer ( function() helpText:color(255,255,255,255) end, 300, 1 )
end

function fadeOutHelp()
	if helpAnimation then helpAnimation:remove() end
	local _,_,_,a = helpText:color()
	if a == 0 then return end
	helpAnimation = Animation.createAndPlay(helpText, Animation.presets.dxTextFadeOut(300))
	setTimer ( function() helpText:color(255,255,255,0) end, 300, 1 )
end

local function onWeaponSwitchWhileDriveby (prevSlot, curSlot)
	if isPedDoingGangDriveby(source) then
		limitDrivebySpeed(getPedWeapon(source, curSlot))
	end
end
addEventHandler ("onClientPlayerWeaponSwitch", localPlayer, onWeaponSwitchWhileDriveby)
