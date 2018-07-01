local WARNING_HEIGHT = 300 -- height at which the 'open your parachute' message is shown
local slow_speed = 0.75 -- overall (x,y,z) speed limit after which z_accelerate is used
local accelerate_speed = 0.03 -- forward acceleration speed while holding forward (skydiving)
local z_accelerate = 0.007 -- forward acceleration while not holding any controls (freefalling)
local x_rotation = 45 -- limits how far forwards the player will dip while skydiving forwards
local rotation_accelerate = 0.75 -- speed at which the player dips forward while skydiving
local freefall_speed = 0.2 -- minimum freefall speed the player can have

local lastTick
local warning
divingTick = 0
divingSpeed = nil
local g_skydivers = {}

local function onRender()
	--Process the local player
	lastTick = lastTick or getTickCount()
	local currentTick = getTickCount()
	local tickDiff =  currentTick - lastTick
	lastTick = currentTick
	if tickDiff > 0 then
		if ( getPedWeapon ( localPlayer, 11 ) == 46 ) and not getElementData(localPlayer, "parachuting") and not doesPedHaveJetPack(localPlayer) and not isElementAttached(localPlayer) and not isPedDead(localPlayer) then
			local velX, velY, velZ = getElementVelocity ( localPlayer )
			local x,y,z = getElementPosition(localPlayer)
			if ( not isPedOnGround ( localPlayer ) and not getPedContactElement ( localPlayer ) and velZ ~= 0 )
			and not isElementInWater(localPlayer) and not testLineAgainstWater ( x,y,z,x,y,z + 12) then

				if not getElementData(localPlayer,"skydiving") then
					if not processLineOfSight ( x,y,z, x,y,z-MIN_GROUND_HEIGHT, true, true,false,true,true,false,false,false,localPlayer ) and not testLineAgainstWater ( x,y,z - MIN_GROUND_HEIGHT,x,y,z) then
						if divingTick == 0 then
							divingTick = currentTick
						end

						-- let 1 second pass before starting the skydive, stops instant skydiving when jumping over high gaps
						if currentTick > (divingTick + t(900)) then
							setElementData(localPlayer,"skydiving",true)
							setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "FALL_skyDive", -1, true, true, false )
							setPedWeaponSlot(localPlayer,11)
							toggleControl ( "next_weapon", false )
							toggleControl ( "previous_weapon", false )
							addEventHandler ( "onClientPlayerWasted", localPlayer, onSkyDivingWasted )
						end
					else
						divingTick = 0
					end
				else
					-- after a few seconds start checking for slow/upwards freefalling (wait a while to avoid speeding up the moment you start diving)
					if (not divingSpeed) and currentTick > (divingTick + t(3000)) then divingSpeed = true end

					local rotX,_,rotZ = getElementRotation ( localPlayer )
					rotZ = -rotZ
					local accel
					local velocityChanged
					if divingSpeed then
						-- stop people being able to gain height while parachuting into a slope by adding a minimum speed, doesnt address the root cause though i cant see a better way of fixing this
						if velZ > -freefall_speed then
							velZ = -s(freefall_speed)
						end
					end

					if ( getMoveState "forwards" ) then
						accel = true
						local dirX = math.sin ( math.rad ( rotZ ) )
						local dirY = math.cos ( math.rad ( rotZ ) )
						velX = velX + dirX * s(accelerate_speed)
						velY = velY + dirY * s(accelerate_speed)
						if rotX < x_rotation then
							rotX = rotX + a(rotation_accelerate,tickDiff)
						end
						setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "FALL_SkyDive_Accel", -1, true, true, false )
						if getMoveState"left" then
							rotZ = rotZ - a(3,tickDiff)
						elseif getMoveState"right" then
							rotZ = rotZ + a(3,tickDiff)
						end
					elseif ( getMoveState"left" ) then
						rotZ = rotZ - a(3,tickDiff)
						setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "FALL_SkyDive_L", -1, true, true, false )
					elseif ( getMoveState"right" ) then
						rotZ = rotZ + a(3,tickDiff)
						setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "FALL_SkyDive_R", -1, true, true, false )
					else
						if rotX > 0 then
							rotX = rotX - a(rotation_accelerate,tickDiff)
						end
						setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "FALL_skyDive", -1, true, true, false )
					end
					if not accel then
						local speed = getDistanceBetweenPoints3D(0,0,0,velX,velY,velZ)
						if speed > slow_speed then
							velZ = velZ - s(z_accelerate)
							setElementVelocity ( localPlayer, velX, velY, velZ )
							velocityChanged = true
						end
					end
					if not velocityChanged then
						velX = math.sin ( math.rad ( rotZ ) ) * s(0.1)
						velY = math.cos ( math.rad ( rotZ ) ) * s(0.1)
						setElementVelocity ( localPlayer, velX, velY, velZ )
					end
					setPedRotation ( localPlayer, -rotZ )
					setElementRotation ( localPlayer, rotX, 0, rotZ )
					if not warning and processLineOfSight ( x,y,z, x,y,z-WARNING_HEIGHT, true, false,false,true,false,false,false,false,localPlayer ) then
						addEventHandler ( "onClientRender", root, warningText )
						warningText() -- Prevent the event handler being called next frame
					end
				end
			elseif isPedOnGround ( localPlayer ) and getElementData(localPlayer,"skydiving") then
				setPedNewAnimation(localPlayer,"animation_state","PARACHUTE","FALL_skyDive_DIE", t(3000), false, true, true)
				toggleControl ( "next_weapon", true )
				toggleControl ( "previous_weapon", true )
				stopSkyDiving()
			elseif (testLineAgainstWater ( x,y,z,x,y,z + 12) or isElementInWater(localPlayer)) and getElementData(localPlayer,"skydiving") then
				toggleControl ( "next_weapon", true )
				toggleControl ( "previous_weapon", true )
				stopSkyDiving()
				setPedAnimation(localPlayer)
			elseif divingTick > 0 then
				divingTick = 0
			end
		end
	end
	--Process remote players
	for player,bool in pairs(g_skydivers) do
		if player ~= localPlayer and getElementData ( player, "skydiving" ) and isElementStreamedIn(player) then
			local velX,velY,velZ = getElementVelocity ( player )
			local rotz = 6.2831853071796 - math.atan2 ( ( velX ), ( velY ) ) % 6.2831853071796
			local animation = getElementData ( player, "animation_state" )
			local animation = animIDs[animation]
			setPedNewAnimation ( player, nil, "PARACHUTE", animation, -1, false, true, false )
			local rotX = getElementRotation(player)
			if ( animation == "FALL_SkyDive_Accel" ) then
				if ( rotX < x_rotation ) then
					rotX = rotX + rotation_accelerate
				end
			elseif rotX > 0 then
				rotX = rotX - rotation_accelerate
			end
			setElementRotation ( player, rotX, 0, -math.deg(rotz) )
		end
	end
end
addEventHandler ( "onClientRender", root, onRender )


function onSkyDivingWasted()
	toggleControl ( "next_weapon", true )
	toggleControl ( "previous_weapon", true )
	stopSkyDiving()
	setPedAnimation(localPlayer)
	setPedAnimation(localPlayer,"PARACHUTE","FALL_skyDive_DIE", t(3000), false, true, false)
	g_skydivers[localPlayer] = nil
end

function stopSkyDiving()
	warning = nil
	local _,_,rotZ = getElementRotation ( localPlayer )
	setElementRotation ( localPlayer, 0, 0, -rotZ )
	setElementData(localPlayer,"skydiving",false)
	removeEventHandler ( "onClientPlayerWasted", localPlayer, onSkyDivingWasted )
	removeEventHandler ( "onClientRender", root, warningText )
	divingSpeed = nil
	divingTick = 0
	g_skydivers[localPlayer] = nil
end

local g_screenX,g_screenY = guiGetScreenSize()
local shadowColor = tocolor(0,0,0)
local color = tocolor(255,255,255)
function warningText()
	warning = true
	dxDrawText ( "Open your parachute!",
		0 + 3, g_screenY*0.75 + 3,
		g_screenX, g_screenY,
		shadowColor, 2, "default", "center", "top", false, true, false )
	dxDrawText ( "Open your parachute!",
		0, g_screenY*0.75,
		g_screenX, g_screenY,
		color, 2, "default", "center", "top", false, true, false )
end

function isPlayerSkyDiving(player)
	return getElementData(player, "skydiving", false)
end

function updateSkyDiving ( data, oldval )
	if ( source ~= localPlayer and data == "skydiving" ) then
		if ( getElementData ( source, "skydiving" ) == true ) then
			g_skydivers[source] = true
		else
			g_skydivers[source] = nil
		end
	end
end
addEventHandler ( "onClientElementDataChange", root, updateSkyDiving )

function skyDivingQuit()
	g_skydivers[source] = nil
end
addEventHandler("onClientPlayerQuit", root, skyDivingQuit)
