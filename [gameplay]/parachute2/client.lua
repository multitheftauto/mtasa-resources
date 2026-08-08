--[[
-- This resource is not finished. Make sure to read the below notes, as well as always use the latest code version from https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/parachute2
-- If you are willing to collaborate finishing this resource, or with testing/feedback
-- Then please visit the #parachute channel in MTA Development Discord ( invite link: https://discord.gg/GNN6PRtTnu )
-- Specifically, the posts around this point are relevant,as they are regarding this resource: https://discord.com/channels/801330706252038164/801411291024457778/1361397061123051832
-- Use on production servers is still discouraged, unless you're satisfied with what you see and think it's already better than MTA's parachuting up until now
-- Special thanks to -ffs-Plasma (initial version, written from scratch, and his research on original SA behavior/Parachute SCM)
--
-- === Changes made in this revision ==
-- 1) All velocity handling (which was entirely commented-out) has been implemented for FREEFALL, the
--    opening transition (ACTION) and GLIDING, so the parachute actually affects movement instead of
--    only playing animations while gravity does its normal thing.
-- 2) GLIDING now detects reaching the ground/water and transitions to LANDED, calling cleanupParachute().
--    Previously there was no such check, so the player got stuck forever in GLIDING once the chute opened
--    (and next_weapon/previous_weapon controls were never re-enabled).
-- 3) All per-frame increments (rotation, easing progress, velocities) are now scaled with the real time
--    elapsed between onClientRender calls (tickDiff), so behaviour no longer depends on the player's FPS.
-- 4) The freefall trigger threshold was tuned from -0.1 to FREEFALL_TRIGGER_VZ (see constants below), since
--    -0.1 triggered on almost any downward velocity instead of only "falling fast enough".
-- 5) The canopy object is now attached with setElementDimension/setElementStreamable(false) (so it can't
--    pop out of existence mid-flight or end up in the wrong interior), opens with the same "overboard"
--    bounce effect as the sibling resource's openChute.lua, and -- crucially -- our own parachuting state
--    is now broadcast via elementData so OTHER clients can draw our canopy and a basic pose for us too.
--    Previously only the local player ever saw their own parachute; everyone else saw nothing.
-- All new constants below are tunable -- there was no authoritative value for them in the available SCM
-- excerpt (the relevant para_float_Vy/para_freefall_Vz/etc. globals were commented out), so they were
-- picked to feel reasonably close to the classic single-player parachute and to the values already used
-- by the sibling resource (parachute_cl.lua / skydiving_cl.lua). Tweak freely to match your server's feel.
--]]

-- Frame-rate / gravity independence helpers -----------------------------------------------------------
local FPS_BENCHMARK = 29    -- the fps all the "per frame" constants below were tuned against
local BASE_GRAVITY   = 0.006

-- Scales a "per benchmark-frame" value by the real elapsed time (tickDiff, in ms) since the last render.
local function scaleByTick(perFrameValue, tickDiff)
	return perFrameValue * (tickDiff * FPS_BENCHMARK / 1000)
end

-- Scales a speed by the current gravity setting, same idea as utility.lua's s() in the sibling resource.
local function scaleByGravity(speed)
	return speed * (getGravity() / BASE_GRAVITY)
end

-- Peds keep a separate internal "heading" (get/setPedRotation) that drives their actual movement and
-- animation facing -- it is NOT the same value as the element's raw Z rotation you set with
-- setElementRotation. Only setting one of the two makes the rendered body face one way while the ped's
-- real movement/velocity behaves as if facing another (exactly "spins one way, gets pushed another way").
-- parachute_cl.lua (the working sibling resource) always sets both together, with setPedRotation getting
-- the negative of whatever Z we give setElementRotation -- so we do the same here, in one place.
local function setParachuteRotation(fPitch, fHeadingZ)
	setElementRotation(localPlayer, fPitch, 0, fHeadingZ);
	setPedRotation(localPlayer, -fHeadingZ);
end

-- Tunable gameplay constants ----------------------------------------------------------------------------
local FREEFALL_ACCEL        = 0.01  -- how quickly vertical speed approaches terminal velocity (deprecated)
local FREEFALL_TRIGGER_VZ     = -0.3  -- vertical speed needed before we start the automatic skydive
local MIN_GROUND_HEIGHT       = 20    -- height above ground needed before skydiving starts (SCM: player_height > 20.0)
local LOW_GROUND_HEIGHT       = 2     -- height at which we consider the player has reached the ground

local FREEFALL_MAX_FALL_SPEED = -0.35 -- terminal velocity while free-falling (no chute)
local FREEFALL_MAXACCEL_POS   = 3     -- Max forwards/backwards POS/accel until SA gravity stalls freefall speed 
local FREEFALL_MINACCEL_POS   = 0     -- If you want to start falling forwards/backwards speedy
local FREEFALL_MOVE_SPEED     = 0.20  -- horizontal speed while leaning forward/backward in freefall

local GLIDE_FALL_SPEED        = -0.17 -- normal descent speed with the parachute open
local GLIDE_FALL_SPEED_SLOW   = -0.065 -- descent speed while flaring (holding backwards)
local GLIDE_MOVE_SPEED        = 0.2   -- horizontal speed while gliding
local GLIDE_ACCEL             = 0.02  -- how quickly vertical speed eases towards its target
local GLIDE_TURN_SPEED        = 1.5   -- turn rate (degrees per benchmark frame) while gliding

local DIE_FALL_SPEED          = -0.9  -- if still falling this fast at LOW_GROUND_HEIGHT, the player dies instead of landing

-- Object models used for the visual canopy and its (invisible) collision object
local CHUTE_OBJECT_MODEL     = 1310
local CHUTE_COLLISION_MODEL  = 3060

-- Opening animation: the canopy scales 0 -> ~OVERBOARD_SCALE over OPEN_SCALE_TIME ms, then eases
-- back down to 1.0 over OVERBOARD_TIME ms, giving it a little "bounce" as it fully opens
-- (same idea as openChute.lua/animateParachuteOpen in the sibling resource).
local OPEN_SCALE_TIME  = 500
local OVERBOARD_SCALE  = 1.05
local OVERBOARD_TIME   = 800

local SOUND_MIN_DISTANCE = 25

-- Scales the canopy object up from 0 to OVERBOARD_SCALE, then eases it back down to 1.0 -- same
-- "overboard" bounce effect as openChute.lua/animateParachuteOpen. Returns true while still
-- animating, false once it has settled at scale 1.0 (object left at scale 1 in that case).
-- Shared between our own canopy and the ones we draw locally for other players.
local function updateChuteObjectScale(object, startTick)
	local elapsed             = getTickCount() - startTick;
	local overboardTriggerTime = OPEN_SCALE_TIME * OVERBOARD_SCALE;

	if (elapsed < overboardTriggerTime) then
		setObjectScale(object, elapsed / OPEN_SCALE_TIME);
		return true;
	else
		local overboardElapsed = elapsed - overboardTriggerTime;

		if (overboardElapsed >= OVERBOARD_TIME) then
			setObjectScale(object, 1);
			return false;
		else
			local overshoot = OVERBOARD_SCALE - 1;
			setObjectScale(object, 1 + (1 - overboardElapsed / OVERBOARD_TIME) * overshoot);
			return true;
		end
	end
end

local strParachuteState                  = "NONE";
local strPlayerState                     = "GROUND";
local strPlayerAction                    = "NONE";
local bHasParachute                      = false;
local uParachuteSound                    = nil;
local uParachuteObject                   = nil;
local uParachuteCollision                = nil;
local iParachuteAnim                     = false;
local fParachuteX                        = 0;
local fParachuteY                        = 0;
local fParachuteZ                        = 0;
local fParachuteYaw                      = 0;
local fParachuteRoll                     = 0;
local fParachutePitch                    = 0;
local fRotationX, fRotationY, fRotationZ = 0, 0, 0;
local fEasingProgress                    = 0;
local fEasingProgress2                   = 0;
local fEasingProgress3                   = 0;
local currentAcceleration                = 0;
local fAccelerate                        = 0.1;
local hasPlayerfallen                    = false;
-- used to interpolate velocity smoothly from freefall speed down to glide speed while the chute opens
local fOpenStartTick                     = nil;
local fOpenStartVX, fOpenStartVY, fOpenStartVZ = 0, 0, 0;

local lastTick                           = nil;
local g_lastBroadcastState               = nil;
	function onParachute (prevSlot, curSlot)
		if getPedWeapon(localPlayer, curSlot) == 46 then --if the switched weapon is parachute
			local function handleParachuteLogic()
			local currentTick = getTickCount();
			lastTick = lastTick or currentTick;
			local tickDiff = currentTick - lastTick;
			lastTick = currentTick;
		
			-- avoid dividing by/scaling with a zero or negative delta (can happen on the very first frame, or if the
			-- tick counter hasn't advanced yet)
			if (tickDiff <= 0) then
				return;
			end
		
			if (getElementHealth(localPlayer) > 0) then
				-- get pos/rot/vel/ground from localPlayer
				local fPX, fPY, fPZ          = getElementPosition(localPlayer);
				local fRX, fRY, fRZ          = getElementRotation(localPlayer);
				local fVX, fVY, fVZ          = getElementVelocity(localPlayer);
				local fGroundPosition        = getGroundPosition(fPX, fPY, fPZ);
		
				-- get player input
				local fControlForwards       = getPedAnalogControlState(localPlayer, "forwards");
				local fControlBackwards      = getPedAnalogControlState(localPlayer, "backwards");
				local fControlLeft           = getPedAnalogControlState(localPlayer, "left");
				local fControlRight          = getPedAnalogControlState(localPlayer, "right");
		
				-- movement/direction velocity
				local fMVX, fMVY, fMVZ, fMRZ = 0, 0, 0, 0;
		
				-- check if player got parachute
				if (getPedWeapon(localPlayer, 11) ~= 0) then
					if (getPedTotalAmmo(localPlayer, 11) > 0) then
						bHasParachute = true;
					end
				end
		
				-- if we do anything with parachute, disable weapon switching
				if (strParachuteState ~= "NONE") then
					toggleControl("next_weapon", false);
					toggleControl("previous_weapon", false);
				end
		
				-- can we go to freefall/skydive
				if (strPlayerState == "GROUND" and bHasParachute) then
					local _, _, fRotationZ_ = getElementRotation(localPlayer);
					fRotationZ = fRotationZ_
		
					if (not isPedOnGround(localPlayer) and not getPedContactElement(localPlayer)) then
						if (fVZ < FREEFALL_TRIGGER_VZ) then
							if ((fPZ - fGroundPosition) > MIN_GROUND_HEIGHT) then
								if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end
								setPedWeaponSlot(localPlayer, 11);
								setPedAnimation(localPlayer, "parachute", "fall_skydive", -1, true, true, false, false, 1000);
								uParachuteSound   = playSFX("genrl", 137, 20, true);
								strParachuteState = "READY";
								strPlayerState    = "FREEFALL";
							end
						end
					end
				end
		
				-- player is in freefall aka. skydive
				if (strPlayerState == "FREEFALL") then
					if (fControlForwards ~= 0) then
						if (strPlayerAction ~= "FORWARDS") then
							setPedAnimation(localPlayer, "parachute", "fall_skydive_accel", -2, true, true, false, false, 1000);
						end
		
						if (fControlLeft ~= 0) then
							fRotationZ = fRotationZ + scaleByTick(10, tickDiff);
						elseif (fControlRight ~= 0) then
							fRotationZ = fRotationZ - scaleByTick(10, tickDiff);
						end
		
						if (fRotationZ < 0) then
							fRotationZ = fRotationZ + 360;
						elseif (fRotationZ > 360) then
							fRotationZ = fRotationZ - 360;
						end
		
						local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress, "Linear");
		
						fEasingProgress = fEasingProgress + scaleByTick(0.03, tickDiff)
			
						if (fEasingProgress > 1) then
							fEasingProgress = 1;
						end
		
						setParachuteRotation(fPitch, -1*fRotationZ);
		
						strPlayerAction = "FORWARDS";
					elseif (fControlBackwards ~= 0) then
						if (strPlayerAction ~= "BACKWARDS") then
							setPedAnimation(localPlayer, "parachute", "fall_skydive", -2, true, true, false, false, 500);
						end
		
						if (fControlLeft ~= 0) then
							fRotationZ = fRotationZ + scaleByTick(2.5, tickDiff);
						elseif (fControlRight ~= 0) then
							fRotationZ = fRotationZ - scaleByTick(2.5, tickDiff);
						end
		
						if (fRotationZ < 0) then
							fRotationZ = fRotationZ + 360;
						elseif (fRotationZ > 360) then
							fRotationZ = fRotationZ - 360;
						end
		
						local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress, "Linear");
		
						fEasingProgress = fEasingProgress - scaleByTick(0.025, tickDiff);
						
						if (fEasingProgress < -1) then
							fEasingProgress = -1;
						end
		
						setParachuteRotation(fPitch, -1*fRotationZ);
		
						strPlayerAction = "BACKWARDS";
					else
						if (fControlLeft ~= 0) then
							if (strPlayerAction ~= "LEFT") then
								setPedAnimation(localPlayer, "parachute", "fall_skydive_l", -2, true, true, false, false, 500);
							end
		
							fRotationZ = fRotationZ + scaleByTick(2.5, tickDiff);
		
							if (fRotationZ < 0) then
								fRotationZ = fRotationZ + 360;
							end
		
							setParachuteRotation(0, -1*fRotationZ);
		
							strPlayerAction = "LEFT";
						elseif (fControlRight ~= 0) then
							if (strPlayerAction ~= "RIGHT") then
								setPedAnimation(localPlayer, "parachute", "fall_skydive_r", -2, true, true, false, false, 500);
							end
		
							fRotationZ = fRotationZ - scaleByTick(2.5, tickDiff);
		
							if (fRotationZ > 360) then
								fRotationZ = fRotationZ - 360;
							end
		
							setParachuteRotation(0, -1*fRotationZ);
		
							strPlayerAction = "RIGHT";
						else
							if (strPlayerAction ~= "NONE") then
								setPedAnimation(localPlayer, "parachute", "fall_skydive", -2, true, true, false, false, 1000);
							end
		
							strPlayerAction = "NONE";
						end
						-- easing from forwards to neutral pitch
						if (fEasingProgress > 0) then
							local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress, "Linear");
		
							fEasingProgress = fEasingProgress - scaleByTick(0.01, tickDiff);
							
							if (fEasingProgress < 0) then
								fEasingProgress = 0;
							end
						
							
							setParachuteRotation(fPitch, -1*fRotationZ);
						end
						-- easing from backwards to neutral pitch
							if (fEasingProgress < 0) then
							local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress, "Linear");
		
							fEasingProgress = fEasingProgress + scaleByTick(0.01, tickDiff);
							
							if (fEasingProgress == 0) then
								fEasingProgress = 0;
							end
						
							
							setParachuteRotation(fPitch, -1*fRotationZ);
						end
					end
									-- Actual freefall physics: fall towards terminal velocity, move horizontally when leaning
					do
						local fTargetVZ = FREEFALL_MAX_FALL_SPEED;
		
						if (fVZ > fTargetVZ) then
							fVZ = math.max(fTargetVZ, fVZ - scaleByGravity(scaleByTick(FREEFALL_ACCEL, tickDiff)));
						end
		
						-- local-space input: X = strafe right(+)/left(-), Y = forward(+)/backward(-)
						local fLocalX, fLocalY = 0, 0;
		
						if (fControlForwards ~= 0) then
							fLocalY = fLocalY + 1;
						elseif (fControlBackwards ~= 0) then
							fLocalY = fLocalY - 1;
						end
		
						if (fControlRight ~= 0 and fControlForwards ~= 0) then
							fLocalX = fLocalX + 0.5;
							fLocalY = fLocalY + 1;
						elseif (fControlLeft ~= 0 and fControlForwards ~= 0) then
							fLocalX = fLocalX - 0.5;
							fLocalY = fLocalY + 1;
						end
						
						
						-- start from whatever horizontal velocity the player already has (momentum from a run,
						-- jump, vehicle ejection, etc.) -- only overridden below if a movement key is held
						local fDirX, fDirY = fVX, fVY;
						
						if (fLocalX ~= 0 or fLocalY ~= 0) then
							-- normalize so diagonal (e.g. forward+right) isn't faster than a single direction
							local fLen = math.sqrt(fLocalX * fLocalX + fLocalY * fLocalY);
							fLocalX = fLocalX / fLen;
							fLocalY = fLocalY / fLen;
							
							local fFacing = math.rad(fRotationZ);
							
							-- MTA's rotation Z is clockwise, so forward is (-sin, cos) and right is (cos, sin)
							local fForwardX, fForwardY = -math.sin(fFacing), math.cos(fFacing);
							local fRightX, fRightY     = math.cos(fFacing), math.sin(fFacing);
							-- Foward/backwards movement in air						
							if ((FREEFALL_MINACCEL_POS < FREEFALL_MAXACCEL_POS) and fLocalY > 0) then
								if FREEFALL_MINACCEL_POS < 0 then
									--if we were in backwards minaccel do this so we don't go near 0 (nostall mid-air) 
									FREEFALL_MINACCEL_POS = (0.02*FREEFALL_MAXACCEL_POS)
								end
									saLikeAnimInterp = 0.31*(FPS_BENCHMARK/1000);
									FREEFALL_MINACCEL_POS = saLikeAnimInterp + FREEFALL_MINACCEL_POS
									--outputChatBox("testB: local "..FREEFALL_MINACCEL_POS..", "..fLocalY)
							elseif (FREEFALL_MINACCEL_POS > (0.99*FREEFALL_MAXACCEL_POS)) then
									FREEFALL_MINACCEL_POS = FREEFALL_MAXACCEL_POS							
							end
								if ((FREEFALL_MINACCEL_POS > (-1*FREEFALL_MAXACCEL_POS)) and fLocalY < 0) then
									if FREEFALL_MINACCEL_POS > 0 then
										--if we were in Forwards minaccel do this so we don't go near 0 (nostall mid-air)  
										FREEFALL_MINACCEL_POS = -1*(0.02*FREEFALL_MAXACCEL_POS)
									end
									saLikeAnimInterp = 0.31*(FPS_BENCHMARK/1000);
									FREEFALL_MINACCEL_POS = - 1*(saLikeAnimInterp) + FREEFALL_MINACCEL_POS
									--outputChatBox("testC: "..FREEFALL_MINACCEL_POS)
								elseif (FREEFALL_MINACCEL_POS < (-0.99*FREEFALL_MAXACCEL_POS)) then 
									FREEFALL_MINACCEL_POS = (-1*FREEFALL_MAXACCEL_POS)
								end
								--Forwards
									local fFacing = math.rad(fRotationZ);
									local fForwardX, fForwardY = -math.sin(fFacing), math.cos(fFacing);
									fDirX = ((fForwardX * FREEFALL_MINACCEL_POS) * fLocalY + fRightX * fLocalX) * FREEFALL_MOVE_SPEED;
									fDirY = ((fForwardY * FREEFALL_MINACCEL_POS) * fLocalY + fRightY * fLocalX) * FREEFALL_MOVE_SPEED;
								-- Backwards
								if FREEFALL_MINACCEL_POS < 0 then 
									fDirX = (-1*(fForwardX * FREEFALL_MINACCEL_POS) * fLocalY + fRightX * fLocalX) * FREEFALL_MOVE_SPEED;
									fDirY = (-1*(fForwardY * FREEFALL_MINACCEL_POS) * fLocalY + fRightY * fLocalX) * FREEFALL_MOVE_SPEED;
								end
						end
						-- it goes back to 0 accel (decellerate math) 
						if (strPlayerAction == "NONE") or (strPlayerAction == "LEFT" or strPlayerAction == "RIGHT")then
							if (FREEFALL_MINACCEL_POS > 0) then
								handleVar = FREEFALL_MINACCEL_POS
								FREEFALL_MINACCEL_POS = handleVar - BASE_GRAVITY
							end
							if (FREEFALL_MINACCEL_POS < 0) then
								handleVar = FREEFALL_MINACCEL_POS
								FREEFALL_MINACCEL_POS = handleVar + BASE_GRAVITY
							end
						end
						--Based on the last action 
						if strPlayerAction == "FORWARDS" then
							lastAction = "FORWARDS"
						end
							if strPlayerAction == "BACKWARDS" then
							lastAction = "BACKWARDS"
						end
						--So we decellerate the player while he doesn't press moves based on his previous action
							if (strPlayerAction == "NONE" or (strPlayerAction == "LEFT" or strPlayerAction == "RIGHT")) then
								if lastAction == "FORWARDS" then
									if FREEFALL_MINACCEL_POS > (0.99*FREEFALL_MAXACCEL_POS) then 
										-- so after releasing that key the character doesn't look he "gained more speed"
										FREEFALL_MINACCEL_POS = (0.9*FREEFALL_MAXACCEL_POS)
									end
										local fFacing = math.rad(fRotationZ);
										local fForwardX, fForwardY = -math.sin(fFacing), math.cos(fFacing);
										fDirX = ((fForwardX * FREEFALL_MINACCEL_POS)) * FREEFALL_MOVE_SPEED;
										fDirY = ((fForwardY * FREEFALL_MINACCEL_POS)) * FREEFALL_MOVE_SPEED;
								end
									if lastAction == "BACKWARDS" then
										if FREEFALL_MINACCEL_POS < (-0.99*FREEFALL_MAXACCEL_POS) then
											-- so after releasing that key the character doesn't look he "gained more speed"
											 FREEFALL_MINACCEL_POS = (-0.9*FREEFALL_MAXACCEL_POS)
										end
											local fFacing = math.rad(fRotationZ);
											local fForwardX, fForwardY = -math.sin(fFacing), math.cos(fFacing);
											fDirX = ((fForwardX * FREEFALL_MINACCEL_POS)) * FREEFALL_MOVE_SPEED;
											fDirY = ((fForwardY * FREEFALL_MINACCEL_POS)) * FREEFALL_MOVE_SPEED;
										--ok
								end
							end
						setElementVelocity(localPlayer, fDirX, fDirY, fVZ*0.995);
					end
					
					
					-- player opening parachute
					if (getPedControlState(localPlayer, "fire") and strParachuteState == "READY") then
						strPlayerState = "ACTION";
						setPedAnimation(localPlayer, "parachute", "para_open", -2, false, false, false, true);
						setPedAnimationSpeed(localPlayer, "para_open", 8);
						
						-- remember the velocity we had at the moment of opening, so we can smoothly
						-- interpolate it towards the glide speed instead of snapping to it
						fOpenStartTick               = getTickCount();
						fOpenStartVX, fOpenStartVY, fOpenStartVZ = getElementVelocity(localPlayer);
						
						if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end
						uParachuteSound = playSFX("genrl", 137, 21, true);
						if (uParachuteSound) then
							setSoundMinDistance(uParachuteSound, SOUND_MIN_DISTANCE);
						end
						
						setTimer(function()
							if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end
							uParachuteSound = playSFX("genrl", 137, 66, false);
						end, 1100, 1);
					end
					
					-- player hit the ground without opening parachute
					if ((fPZ - fGroundPosition) < LOW_GROUND_HEIGHT) then
						strPlayerState = "HITGROUND";
						strParachuteState = "NOTREADY";
						-- to apply death animation for when Skydiving give player hp 
						addEventHandler("onClientPlayerDamage", localPlayer, function(_, weapon)
							if weapon == 54 then
								setElementHealth(localPlayer, 100)
								setPedAnimation(localPlayer, "parachute", "fall_skydive_die", -1, false, false, false, false, -1);
								hasPlayerfallen = true
							else
								outputChatBox("You might hit!",0, 255, 0);
							end
						end);
						setTimer(cleanupParachute, 2000, 1);
					end
					setTimer( function()
						if (getElementHealth(localPlayer) > 0.5) then
							local crX, crY,crZ = getElementVelocity(localPlayer)
							currentAcceleration = -1*(crX*crY*crZ)*1000
							if currentAcceleration < 0 then 
								currentAcceleration = -1*currentAcceleration*1000
							end
							outputChatBox("Accel é: "..currentAcceleration, 0,60,120)
							if currentAcceleration == 0 and not hasPlayerfallen then 
								strPlayerState = "HITBUILDING";
								strParachuteState = "NOTREADY";
								setElementVelocity(localPlayer,0,0,0)
								outputChatBox("you Should have Died",100,100,50);
								--triggerServerEvent here
								setElementHealth(localPlayer, 0)
								setTimer(cleanupParachute, 2000, 1);
								return 0
							end
						end
					end, 100, 1)
				end
				
				-- player opening parachute
				if (strPlayerState == "ACTION") then
					-- is it too late?
					if ((fPZ - fGroundPosition) < LOW_GROUND_HEIGHT) then
						strPlayerState = "HITGROUND";
						strParachuteState = "NOTREADY";
						setPedAnimation(localPlayer, "parachute", "fall_skydive_die", -1, false, false, false, false);
						setTimer(cleanupParachute, 2000, 1);
					else
						if (strParachuteState ~= "OPENING") then
							strParachuteState = "OPENING";
		
							-- prepare parachute opening animation
							uParachuteObject = createObject(CHUTE_OBJECT_MODEL, 0, 0, 0);
							attachElements(uParachuteObject, localPlayer);
							setObjectScale(uParachuteObject, 0);
							-- purely visual: disable physical collisions so it doesn't clip/collide with the camera
							setElementCollisionsEnabled(uParachuteObject, false);
							-- keep it in the same interior/dimension as the player, and don't let it get
							-- streamed out mid-air (both would make it pop in/out or vanish)
							setElementDimension(uParachuteObject, getElementDimension(localPlayer));
							setElementStreamable(uParachuteObject, false);
							-- SCM: PLAY_OBJECT_ANIM parac para_open_o PARACHUTE 1000.0 0 1
							iParachuteAnim = getTickCount();
		
							setTimer(function()
								strPlayerState = "GLIDING";
								strParachuteState = "OPENED";
							end, 1000, 1);
						end
		
						-- smoothly bring velocity from whatever it was in freefall down to glide speed,
						-- over the same ~2000-5000ms the opening animation/object scaling take
						-- If you want to make it easier to not die when opening the chute, you can decrease to 1000ms
						if (fOpenStartTick) then
							local fProgress = math.min(1, (getTickCount() - fOpenStartTick) / 3000);
							local fNewVZ    = fOpenStartVZ + (GLIDE_FALL_SPEED - fOpenStartVZ) * fProgress;
							local fNewVX    = fOpenStartVX * (1 - fProgress);
							local fNewVY    = fOpenStartVY * (1 - fProgress);
		
							setElementVelocity(localPlayer, fNewVX, fNewVY, fNewVZ);
						end
					end
				end
		
				-- do parachute opening animation
				if (iParachuteAnim) then
					if (not updateChuteObjectScale(uParachuteObject, iParachuteAnim)) then
						iParachuteAnim = false;
		
						-- create parachute collision
						uParachuteCollision = createObject(CHUTE_COLLISION_MODEL, 0, 0, 0);
						setElementAlpha(uParachuteCollision, 0);
						attachElements(uParachuteCollision, uParachuteObject);
						-- SCM: SET_OBJECT_DYNAMIC para_col TRUE
						-- SCM: SET_OBJECT_RECORDS_COLLISIONS para_col TRUE
					end
				end
		
				-- player is gliding with parachute
				if (strPlayerState == "GLIDING") then
					-- decide which animation this frame wants, then only actually change it if it's different
					-- from what's already playing (holding a key must NOT re-trigger the same animation, or
					-- worse, fall through to the "NONE" branch and reset to para_float every frame)
					local strDesiredAction;
		
					if (fControlForwards ~= 0) then
						strDesiredAction = "FORWARDS";
					elseif (fControlBackwards ~= 0) then
						strDesiredAction = "BACKWARDS";
					elseif (fControlLeft ~= 0) then
						strDesiredAction = "LEFT";
					elseif (fControlRight ~= 0) then
						strDesiredAction = "RIGHT";
					else
						strDesiredAction = "NONE";
					end
		
					if (strDesiredAction ~= strPlayerAction) then
						strPlayerAction = strDesiredAction;
		
						if (strPlayerAction == "FORWARDS") then
							setPedAnimation(localPlayer, "parachute", "para_float", -2, true, false, false, true, 500);
							-- SCM: PLAY_OBJECT_ANIM parac para_float_o PARACHUTE 1.0 1 1
						elseif (strPlayerAction == "BACKWARDS") then
							setPedAnimation(localPlayer, "parachute", "para_decel", -2, true, false, false, true, 500);
							-- SCM: PLAY_OBJECT_ANIM parac para_decel_o PARACHUTE 1.0 1 1
						elseif (strPlayerAction == "LEFT") then
							setPedAnimation(localPlayer, "parachute", "para_steerl", -2, true, false, false, true, 500);
							-- SCM: PLAY_OBJECT_ANIM parac para_steerL_o PARACHUTE 1.0 1 1
						elseif (strPlayerAction == "RIGHT") then
							setPedAnimation(localPlayer, "parachute", "para_steerr", -2, true, false, false, true, 500);
							-- SCM: PLAY_OBJECT_ANIM parac para_steerR_o PARACHUTE 1.0 1 1
						else
							setPedAnimation(localPlayer, "parachute", "para_float", -2, true, false, false, true, 500);
							-- SCM: PLAY_OBJECT_ANIM parac para_float_o PARACHUTE 1.0 1 1
						end
					end
		
					-- descent speed: normal, or slower ("flare") while holding backwards
					local fTargetVZ = (fControlBackwards ~= 0) and GLIDE_FALL_SPEED_SLOW or GLIDE_FALL_SPEED;
		
					if (fVZ > fTargetVZ) then
						fVZ = fTargetVZ;
					elseif (fVZ < fTargetVZ) then
						fVZ = math.min(fTargetVZ, fVZ + scaleByGravity(scaleByTick(GLIDE_ACCEL, tickDiff)));
					end
		
					-- steering
					if (fControlLeft ~= 0) then
						fRotationZ = fRotationZ + scaleByTick(GLIDE_TURN_SPEED, tickDiff);
					elseif (fControlRight ~= 0) then
						fRotationZ = fRotationZ - scaleByTick(GLIDE_TURN_SPEED, tickDiff);
					end
		
					if (fRotationZ < 0) then
						fRotationZ = fRotationZ + 360;
					elseif (fRotationZ > 360) then
						fRotationZ = fRotationZ - 360;
					end
		
					local fFacing = math.rad(fRotationZ);
					-- MTA's rotation Z is clockwise, so the facing vector is (-sin, cos), not (sin, cos)
					local fVX2    = -math.sin(fFacing) * GLIDE_MOVE_SPEED;
					local fVY2    = math.cos(fFacing) * GLIDE_MOVE_SPEED;
					--Parachute PED rotation fix -1*
					setParachuteRotation(0, -1*fRotationZ);
					setElementVelocity(localPlayer, fVX2, fVY2, fVZ);
		
					-- water landing
					if (isElementInWater(localPlayer)) then
						strPlayerState = "LANDED";
						strParachuteState = "CLOSING";
						setPedAnimation(localPlayer, "parachute", "para_land_water", -1, false, false, false, false);
						setTimer(cleanupParachute, 1000, 1, true);
					-- ground landing / crash
					elseif ((fPZ - fGroundPosition) < LOW_GROUND_HEIGHT) then
						if (fVZ < DIE_FALL_SPEED) then
							strPlayerState = "HITGROUND";
							strParachuteState = "NOTREADY";
							setPedAnimation(localPlayer, "parachute", "fall_skydive_die", -1, false, false, false, false);
							setTimer(cleanupParachute, 2000, 1);
						else
							strPlayerState = "LANDED";
							strParachuteState = "CLOSING";
							setPedAnimation(localPlayer, "parachute", "para_land", -1, false, false, false, false);
							setTimer(cleanupParachute, 1000, 1, true);
						end
					end
				end
		
				-- player landed (nothing to do per-frame here: cleanupParachute is already scheduled above)
				-- if (strPlayerState == "LANDED") then
				-- end
		
				-- Let other clients know what we're doing, so they can draw our canopy and a basic pose for
				-- us too (setElementData is networked automatically; a plain setPedAnimation/createObject call
				-- only ever affects what WE see, never other players).
				if (strPlayerState ~= g_lastBroadcastState) then
					g_lastBroadcastState = strPlayerState;
					setElementData(localPlayer, "chuteState", strPlayerState);
				end
			end
		end
		addEventHandler("onClientRender", root, handleParachuteLogic);
	end
end
addEventHandler("onClientPlayerWeaponSwitch", localPlayer, onParachute)
function cleanupParachute(bLandedGood)
	iParachuteAnim        = false;
	bHasParachute         = false;
	strParachuteState     = "NONE";
	strPlayerState        = "GROUND";
	strPlayerAction       = "NONE";
	fOpenStartTick        = nil;
	fEasingProgress       = 0;
	fEasingProgress2      = 0;
	FREEFALL_MINACCEL_POS = 0;
	hasPlayerfallen       = false;

	if (isElement(uParachuteCollision)) then destroyElement(uParachuteCollision) end;
	if (isElement(uParachuteObject)) then destroyElement(uParachuteObject) end;
	if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end;

	toggleControl("next_weapon", true);
	toggleControl("previous_weapon", true);

	g_lastBroadcastState = strPlayerState;
	setElementData(localPlayer, "chuteState", strPlayerState);

	-- if (not bLandedGood) then
		-- todo: remove weapon from player via server
		-- takeWeapon(client, 46);
	-- end
end

--[[
	=== Remote player sync ===
	Everything above only ever touches localPlayer -- setPedAnimation and createObject calls we make
	are 100% local to our own screen. Without this, every other client on the server would see us
	falling/gliding with no parachute object and no matching animation at all.

	g_lastBroadcastState above already keeps our own "chuteState" elementData in sync (elementData set
	on a player is networked automatically), so all we need here is: watch other players' "chuteState"
	and mirror a canopy object + a basic pose for them locally, the same way parachute_cl.lua does with
	its "parachuting"/g_parachuters pattern.
--]]
--[[
local g_remoteChutes = {}; -- [player] = { object = <object>, scaleStart = <tick or nil> }

local function removeRemoteChute(player)
	local info = g_remoteChutes[player];

	if (info) then
		if (isElement(info.object)) then destroyElement(info.object) end
		g_remoteChutes[player] = nil;
	end
end

addEventHandler("onClientElementDataChange", root, function(strDataName)
	if (strDataName ~= "chuteState" or source == localPlayer or getElementType(source) ~= "player") then
		return;
	end

	local strState = getElementData(source, "chuteState");

	if (strState == "ACTION" or strState == "GLIDING") then
		if (not g_remoteChutes[source]) then
			local uObject = createObject(CHUTE_OBJECT_MODEL, 0, 0, 0);
			attachElements(uObject, source);
			setObjectScale(uObject, 0);
			setElementCollisionsEnabled(uObject, false);
			setElementDimension(uObject, getElementDimension(source));
			setElementStreamable(uObject, false);

			g_remoteChutes[source] = { object = uObject, scaleStart = getTickCount() };
		end
	else
		removeRemoteChute(source);
	end
end);

addEventHandler("onClientRender", root, function()
	for player, info in pairs(g_remoteChutes) do
		if (not isElement(player) or not isElement(info.object)) then
			g_remoteChutes[player] = nil;
		else
			-- keep animating the "bounce" open effect until it settles
			if (info.scaleStart and not updateChuteObjectScale(info.object, info.scaleStart)) then
				info.scaleStart = nil;
			end

			if (isElementStreamedIn(player)) then
				local strState              = getElementData(player, "chuteState");
				local fVelX, fVelY, fVelZ   = getElementVelocity(player);

				-- we don't know this player's real control state, so approximate their facing/pose
				-- from their velocity direction, same idea as parachute_cl.lua's remote player loop
				if (strState == "GLIDING") then
					setPedAnimation(player, "parachute", "para_float", -2, true, false, false, true);

					if (fVelX ~= 0 or fVelY ~= 0) then
						local fHeading = math.deg(math.atan2(-fVelX, fVelY));
						setElementRotation(player, 0, 0, fHeading);
					end
				elseif (strState == "ACTION") then
					setPedAnimation(player, "parachute", "para_open", -2, false, false, false, true);
				end
			end
		end
	end
end);

addEventHandler("onClientPlayerQuit", root, function()
	removeRemoteChute(source);
end);
]]