FALL_VELOCITY = 0.9 -- how fast you have to be going (z) before you stop landing properly and just hit the ground
MIN_GROUND_HEIGHT = 20 -- how high above the ground you need to be before parachuting will start
local y_turn_offset = 20 -- limits how far to the sides the player will lean when turning left or right
local rotation_accelerate = 0.5 -- speed at which the player will lean when turning
slowfallspeed = -0.07 -- fall speed with legs up
fallspeed = -0.15 -- fall speed with legs down
haltspeed = 0.02
movespeed = 0.2 -- horizontal speed
turnspeed = 1.5 -- rotation speed when turning
lastspeed = 0
opentime = 1000

-- Save bandwidth by converting these strings into numbers for "animation_state" element data
animIDs = {
	"PARA_decel",
	"PARA_steerL",
	"PARA_steerR",
	"PARA_float",
	"FALL_skyDive_DIE",
	"PARA_Land",
	"PARA_Land_Water",
	"FALL_skyDive",
	"FALL_SkyDive_Accel",
	"FALL_SkyDive_L",
	"FALL_SkyDive_R",
	"FALL_skyDive",
}

function getAnimIDFromName(animName)
	for i, anim in ipairs(animIDs) do
		if (anim == animName) then
			return i
		end
	end
	return false
end

local lastAnim = {}
local lastTick
local removing = false
local g_parachuters = {}
local parachutes = {}

local function onResourceStart ( resource )
	bindKey ( "fire", "down", onFire )
	bindKey ( "enter_exit", "down", onEnter )
end
addEventHandler ( "onClientResourceStart", resourceRoot, onResourceStart )

local function onRender ( )
	lastTick = lastTick or getTickCount()
	local currentTick = getTickCount()
	local tickDiff =  currentTick - lastTick
	lastTick = currentTick
	if tickDiff > 0 then
		if ( getElementData ( localPlayer, "parachuting" ) ) then
			if ( changeVelocity ) then
				velX, velY, velZ = getElementVelocity ( localPlayer )
				if ( not isPedOnGround ( localPlayer ) and not getPedContactElement ( localPlayer ) and velZ ~= 0) then

					_,rotY,rotZ = getElementRotation ( localPlayer )
					rotZ = -rotZ
					local currentfallspeed = s(fallspeed)
					local currentmovespeed = s(movespeed)

					if ( getMoveState ( "backwards" ) ) then
						currentfallspeed = s(slowfallspeed)
					end

					-- going too fast, slow down to appropriate speed
					if ( velZ < currentfallspeed ) then
						if ( lastspeed < 0 ) then
							if ( lastspeed >= currentfallspeed ) then
								velZ = currentfallspeed
							else
								velZ = lastspeed + s(haltspeed)
							end
						end
					-- going too slow, speed back up to appropriate speed
					elseif ( velZ > currentfallspeed ) then
						velZ = currentfallspeed

						if lastspeed <= velZ then
							currentmovespeed = currentmovespeed / 2
						end
					end

					lastspeed = velZ
					local dirX = math.sin ( math.rad ( rotZ ) )
					local dirY = math.cos ( math.rad ( rotZ ) )
					velX = dirX * currentmovespeed
					velY = dirY * currentmovespeed
					if ( velZ == currentfallspeed ) then
						if ( getMoveState ( "backwards" ) ) then
							setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "PARA_decel", -1, false, true, false )
							if  getMoveState ( "left" ) then
								rotZ = rotZ - a(turnspeed,tickDiff)
								if y_turn_offset > rotY then
									rotY = rotY + a(rotation_accelerate,tickDiff)
								end
							elseif getMoveState ( "right" ) then
								rotZ = rotZ + a(turnspeed ,tickDiff)
								if -y_turn_offset < rotY then
									rotY = rotY - a(rotation_accelerate,tickDiff)
								end
							elseif 0 > math.floor(rotY) then
								rotY = rotY + a(rotation_accelerate,tickDiff)
							elseif 0 < math.floor(rotY) then
								rotY = rotY - a(rotation_accelerate,tickDiff)
							end
						elseif ( getMoveState ( "left" ) ) then
							rotZ = rotZ - a(turnspeed,tickDiff)
							if y_turn_offset > rotY then
								rotY = rotY + a(rotation_accelerate,tickDiff)
							end
							setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "PARA_steerL", -1, false, true, false )
						elseif ( getMoveState ( "right" ) ) then
							rotZ = rotZ + a(turnspeed ,tickDiff)
							if -y_turn_offset < rotY then
								rotY = rotY - a(rotation_accelerate,tickDiff)
							end
							setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "PARA_steerR", -1, false, true, false )
						else
							setPedNewAnimation ( localPlayer, "animation_state", "PARACHUTE", "PARA_float", -1, false, true, false )
							if 0 > math.floor(rotY) then
								rotY = rotY + a(rotation_accelerate,tickDiff)
							elseif 0 < math.floor(rotY) then
								rotY = rotY - a(rotation_accelerate,tickDiff)
							end
						end
						setPedRotation ( localPlayer, -rotZ )
						setElementRotation ( localPlayer,0,rotY, rotZ )
					end
					setElementVelocity ( localPlayer, velX, velY, velZ )
				else
					if velZ >= FALL_VELOCITY then --they're going to have to fall down at this speed
						removeParachute(localPlayer,"land")
						setPedAnimation(localPlayer,"PARACHUTE","FALL_skyDive_DIE", -1, true, true, true, true)
					else
						removeParachute(localPlayer,"land")
						setPedNewAnimation ( localPlayer, nil, "PARACHUTE", "PARA_Land", -1, false, true, true, false )
					end
				end
			end

			local posX,posY,posZ = getElementPosition(localPlayer)
			if testLineAgainstWater ( posX,posY,posZ + 10, posX,posY,posZ) then --Shoot a small line to see if in water
				removeParachute(localPlayer,"water")
				setPedNewAnimation ( localPlayer, nil, "PARACHUTE", "PARA_Land_Water", -1, false, true, true, false )
			end
		end
	end
	--Render remote players
	for player,t in pairs(g_parachuters) do
		if player ~= localPlayer and getElementData ( player, "parachuting" ) and isElementStreamedIn(player) then
			local velX,velY,velZ = getElementVelocity ( player )
			local rotz = 6.2831853071796 - math.atan2 ( ( velX ), ( velY ) ) % 6.2831853071796
			local animation = getElementData ( player, "animation_state" )
			local animation = animIDs[animation]
			setPedNewAnimation ( player, nil, "PARACHUTE", animation, -1, false, true, false )
			local _,rotY = getElementRotation(player)
			--Sync the turning rotation
			if animation == "PARA_steerL" then
				if y_turn_offset > rotY then
					rotY = rotY + rotation_accelerate
				end
			elseif animation == "PARA_steerR" then
				if -y_turn_offset < rotY then
					rotY = rotY - rotation_accelerate
				end
			else
				if 0 > math.floor(rotY) then
					rotY = rotY + rotation_accelerate
				elseif 0 < math.floor(rotY) then
					rotY = rotY - rotation_accelerate
				end
			end
			setElementRotation ( player, 0, rotY, -math.deg(rotz) )
		end
	end
end
addEventHandler ( "onClientRender", root, onRender )

function onFire ( key, keyState )
	if ( not getElementData ( localPlayer, "parachuting" ) ) and getElementData(localPlayer,"skydiving") then
		local x,y,z = getElementPosition(localPlayer)
		if not processLineOfSight ( x,y,z, x,y,z-MIN_GROUND_HEIGHT, true, true,false,true,true,false,false,false,localPlayer ) then
			stopSkyDiving()
			addLocalParachute()
			addEventHandler ( "onClientPlayerWasted", localPlayer, onWasted )
		end
	end
end

function onEnter ()
	if ( getElementData ( localPlayer, "parachuting" ) ) then
		removeParachute(localPlayer,"water")
		setPedAnimation(localPlayer)
	end
end

function onWasted()
	removeParachute(localPlayer,"water")
	setPedAnimation(localPlayer)
	setPedAnimation(localPlayer,"PARACHUTE","FALL_skyDive_DIE", t(3000), false, true, false)
end

function addLocalParachute()
	local x,y,z = getElementPosition ( localPlayer )
	local chute = createObject ( 3131, x,y,z )
	setElementDimension(chute, getElementDimension( localPlayer ) )
	setElementStreamable(chute, false )
	parachutes[localPlayer] = chute
	openChute ( chute, localPlayer, opentime )
	setElementData ( localPlayer, "parachuting", true )
	triggerServerEvent ( "requestAddParachute", resourceRoot )
end

function setPedAnimationDelayed(player)
	if (isElement(player)) then
		setPedAnimation(player)
	end
end

function removeParachute(player,type)
	if player == localPlayer then
		if removing then return end
		removing = true
	end

	local chute = getPlayerParachute ( player )
	setTimer ( setPedAnimationDelayed, t(3000), 1, player )
	openingChutes[chute] = nil
	if chute then
		if type == "land" then
			Animation.createAndPlay(
			  chute,
			  {{ from = 0, to = 100, time = t(2500), fn = animationParachute_land }}
			)
			setTimer ( function()
				detachElements ( chute, player )
				setTimer ( destroyElement, t(3000), 1, chute )
			end,
			t(2500),
			1
			)
		elseif type == "water" then
			Animation.createAndPlay(
			  chute,
			  {{ from = 0, to = 100, time = t(2500), fn = animationParachute_landOnWater }}
			)
			setTimer ( destroyElement, t(2500), 1, chute )
		end
	end
	lastAnim[player] = nil
	if player == localPlayer then
		divingTick = 0
		divingSpeed = nil
		lastspeed = math.huge
		toggleControl ( "next_weapon", true )
		toggleControl ( "previous_weapon", true )
		changeVelocity = false
		setElementData ( localPlayer, "animation_state", nil )
		setTimer ( setElementData, 1000, 1, localPlayer, "parachuting", false )
		setTimer ( function() removing = false end, 1100, 1)
		removeEventHandler ( "onClientPlayerWasted", localPlayer, onWasted )
		triggerServerEvent ( "requestRemoveParachute", resourceRoot )
	end
	parachutes[player] = nil
end

function animationParachute_land(chute,xoff)
	setElementAttachedOffsets ( chute, offset[1],offset[2],offset[3], math.rad(xoff), 0, 0 )
end

function animationParachute_landOnWater(chute,xoff)
	setElementAttachedOffsets ( chute, offset[1],offset[2],-xoff/10, math.rad(xoff), 0, 0 )
end

addEvent ( "doAddParachuteToPlayer", true)
addEventHandler ( "doAddParachuteToPlayer", root,
	function()
		local x,y,z = getElementPosition ( source )
		local chute = createObject ( 3131, x, y, z )
		setElementDimension( chute, getElementDimension( source ) )
		setElementStreamable(chute, false )
		parachutes[source] = chute
		openChute ( chute, source, opentime )
	end
)

addEvent ( "doRemoveParachuteFromPlayer", true)
addEventHandler ( "doRemoveParachuteFromPlayer", root,
	function()
		if not isPedOnGround ( source ) or not getPedContactElement ( source ) then
			setPedNewAnimation ( source, nil, "PARACHUTE", "PARA_Land", -1, false, true, true, false )
			removeParachute(source, "land" )
		else
			setPedNewAnimation ( source, nil, "PARACHUTE", "PARA_Land_Water", -1, false, true, true, false )
			removeParachute(source, "water" )
		end
	end)

function setPedNewAnimation ( ped, elementData, animgroup, animname, ... )
	if animname ~= lastAnim[ped] then
		lastAnim[ped] = animname
		if elementData ~= nil then
			local animID = getAnimIDFromName(animname)
			setElementData ( ped, elementData, animID )
		end
		return setPedAnimation ( ped, animgroup, animname, ... )
	end
	return true
end

function getPlayerParachute(player)
	return parachutes[player] or false
end

function isPlayerParachuting(player)
	return getElementData(player, "parachuting", false)
end

function updateParachuting ( data, oldval )
	if ( source ~= localPlayer and data == "parachuting" ) then
		if ( getElementData ( source, "parachuting" ) == true ) then
			g_parachuters[source] = true
		else
			g_parachuters[source] = nil
		end
	end
end
addEventHandler ( "onClientElementDataChange", root, updateParachuting )

function playerQuitWhenParachuting()
	if (isPlayerParachuting(source)) then
		destroyElement(getPlayerParachute(source))
		parachutes[source] = nil
		g_parachuters[source] = nil
	end
end
addEventHandler("onClientPlayerQuit", root, playerQuitWhenParachuting)
