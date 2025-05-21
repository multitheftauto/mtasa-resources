--[[
-- This resource is not finished. Make sure to read the below notes, as well as always use the latest code version from https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/parachute2
-- If you are willing to collaborate finishing this resource, or with testing/feedback
-- Then please visit the #parachute channel in MTA Development Discord ( invite link: https://discord.gg/GNN6PRtTnu )
-- Specifically, the posts around this point are relevant,as they are regarding this resource: https://discord.com/channels/801330706252038164/801411291024457778/1361397061123051832
-- Use on production servers is still discouraged, unless you're satisfied with what you see and think it's already better than MTA's parachuting up until now
-- Special thanks to -ffs-Plasma (initial version, written from scratch, and his research on original SA behavior/Parachute SCM)
--]]

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

local fAccelerate                        = 0.1;

local function handleParachuteLogic()
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
			fRotationX, fRotationY, fRotationZ = getElementRotation(localPlayer);

			if (not isPedOnGround(localPlayer) and not getPedContactElement(localPlayer)) then
				if (fVZ < -0.1) then
					if ((fPZ - fGroundPosition) > 20) then
						if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end
						setPedWeaponSlot(localPlayer, 11);
						setPedAnimation(localPlayer, "parachute", "fall_skydive", -1, true, true, false, false);
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
					setPedAnimation(localPlayer, "parachute", "fall_skydive_accel", -2, true, true, false, false);
				end

				if (fControlLeft ~= 0) then
					fRotationZ = fRotationZ - 1;
				elseif (fControlRight ~= 0) then
					fRotationZ = fRotationZ + 1;
				end

				if (fRotationZ < 0) then
					fRotationZ = fRotationZ + 360;
				elseif (fRotationZ > 360) then
					fRotationZ = fRotationZ - 360;
				end

				local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress, "Linear");

				fEasingProgress = fEasingProgress + 0.01

				if (fEasingProgress > 1) then
					fEasingProgress = 1;
				end

				setElementRotation(localPlayer, fPitch, 0, fRotationZ);

				strPlayerAction = "FORWARDS";
			elseif (fControlBackwards ~= 0) then
				if (strPlayerAction ~= "BACKWARDS") then
					setPedAnimation(localPlayer, "parachute", "fall_skydive", -2, true, true, false, false);
				end

				if (fControlLeft ~= 0) then
					fRotationZ = fRotationZ - 1;
				elseif (fControlRight ~= 0) then
					fRotationZ = fRotationZ + 1;
				end

				if (fRotationZ < 0) then
					fRotationZ = fRotationZ + 360;
				elseif (fRotationZ > 360) then
					fRotationZ = fRotationZ - 360;
				end

				local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress2, "Linear");

				fEasingProgress2 = fEasingProgress2 + 0.01;

				if (fEasingProgress2 > 1) then
					fEasingProgress2 = 1;
				end

				setElementRotation(localPlayer, fPitch * -1, 0, fRotationZ);

				strPlayerAction = "BACKWARDS";
			else
				if (fControlLeft ~= 0) then
					if (strPlayerAction ~= "LEFT") then
						setPedAnimation(localPlayer, "parachute", "fall_skydive_l", -2, true, true, false, false);
					end

					fRotationZ = fRotationZ - 1;

					if (fRotationZ < 0) then
						fRotationZ = fRotationZ + 360;
					end

					setElementRotation(localPlayer, 0, 0, fRotationZ);

					strPlayerAction = "LEFT";
				elseif (fControlRight ~= 0) then
					if (strPlayerAction ~= "RIGHT") then
						setPedAnimation(localPlayer, "parachute", "fall_skydive_r", -2, true, true, false, false);
					end

					fRotationZ = fRotationZ + 1;

					if (fRotationZ > 360) then
						fRotationZ = fRotationZ - 360;
					end

					setElementRotation(localPlayer, 0, 0, fRotationZ);

					strPlayerAction = "RIGHT";
				else
					if (strPlayerAction ~= "NONE") then
						setPedAnimation(localPlayer, "parachute", "fall_skydive", -2, true, true, false, false);
					end

					strPlayerAction = "NONE";
				end

				if (fEasingProgress > 0) then
					local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress, "Linear");

					fEasingProgress = fEasingProgress - 0.01;

					if (fEasingProgress < 0) then
						fEasingProgress = 0;
					end

					setElementRotation(localPlayer, fPitch, 0, fRotationZ);
				end

				if (fEasingProgress2 > 0) then
					local fPitch = interpolateBetween(0, 0, 0, 50, 0, 0, fEasingProgress2, "Linear");

					fEasingProgress2 = fEasingProgress2 - 0.01;

					if (fEasingProgress2 < 0) then
						fEasingProgress2 = 0;
					end

					setElementRotation(localPlayer, fPitch * -1, 0, fRotationZ);
				end
			end

			-- Handle player velocity/rotation (Not sure how yet, block commented out)

			--[[

			-- X
			fParachuteX = fParachuteX / 4.267;
			fParachuteX = fParachuteX - fParachuteRoll;
			fParachuteX = fParachuteX / 20;
			--fParachuteX = fParachuteX * para_time_step;
			fParachuteRoll = fParachuteRoll + fParachuteX;
			
			fParachuteX = fParachuteRoll / 5;
			--fParachuteX = fParachuteX * para_time_step;
			fParachuteYaw = fParachuteX;
			
			if(fParachuteYaw > 180) then
				fParachuteYaw = fParachuteYaw - 360;
			end
			
			if(fParachuteYaw < -180) then
				fParachuteYaw = fParachuteYaw + 360;
			end
			
			-- Y
			fParachuteX = fParachuteX / 4.267;
			fParachuteX = fParachuteX - fParachutePitch;
			fParachuteX = fParachuteX / 20;
			--fParachuteX = fParachuteX * para_time_step;
			fParachutePitch = fParachutePitch + fParachuteX;
			--]]

			-- player opening parachute
			if (getControlState(localPlayer, "fire") and strParachuteState == "READY") then
				strPlayerState = "ACTION";
				setPedAnimation(localPlayer, "parachute", "para_open", -2, false, false, false, true);
				setPedAnimationSpeed(localPlayer, "para_open", 8);

				if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end
				uParachuteSound = playSFX("genrl", 137, 21, true);

				setTimer(function()
					if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end
					uParachuteSound = playSFX("genrl", 137, 66, false);
				end, 1100, 1);
			end

			-- player hit the ground without opening parachute
			if ((fPZ - fGroundPosition) < 2) then
				strPlayerState = "HITGROUND";
				strParachuteState = "NOTREADY";
				setPedAnimation(localPlayer, "parachute", "fall_skydive_die", -1, false, false, false, false);
				setTimer(cleanupParachute, 2000, 1);
			end
		end

		-- player opening parachute
		if (strPlayerState == "ACTION") then
			-- is it too late?
			if ((fPZ - fGroundPosition) < 2) then
				strPlayerState = "HITGROUND";
				strParachuteState = "NOTREADY";
				setPedAnimation(localPlayer, "parachute", "fall_skydive_die", -1, false, false, false, false);
				setTimer(cleanupParachute, 2000, 1);
			else
				if (strParachuteState ~= "OPENING") then
					strParachuteState = "OPENING";

					-- prepare parachute opening animation
					uParachuteObject = createObject(1310, 0, 0, 0);
					attachElements(uParachuteObject, localPlayer);
					setObjectScale(uParachuteObject, 0);
					-- SCM: PLAY_OBJECT_ANIM parac para_open_o PARACHUTE 1000.0 0 1
					iParachuteAnim = getTickCount();

					setTimer(function()
						strPlayerState = "GLIDING";
						strParachuteState = "OPENED";
					end, 1000, 1);
				end
			end
		end

		-- do parachute opening animation
		if (iParachuteAnim) then
			if ((getTickCount() - iParachuteAnim) < 500) then
				setObjectScale(uParachuteObject, (getTickCount() - iParachuteAnim) / 500);
			else
				setObjectScale(uParachuteObject, 1);
				iParachuteAnim = false;

				-- create parachute collision
				uParachuteCollision = createObject(3060, 0, 0, 0);
				setElementAlpha(uParachuteCollision, 0);
				attachElements(uParachuteCollision, uParachuteObject);
				-- SCM: SET_OBJECT_DYNAMIC para_col TRUE
				-- SCM: SET_OBJECT_RECORDS_COLLISIONS para_col TRUE
			end
		end

		-- player is gliding with parachute
		if (strPlayerState == "GLIDING") then
			setPedAnimation(localPlayer, "parachute", "para_float", -2, true, false, false, true);
			-- SCM: PLAY_OBJECT_ANIM parac para_float_o PARACHUTE 1.0 1 1

			if (fControlForwards ~= 0 and strPlayerAction ~= "FORWARDS") then
				strPlayerAction = "FORWARDS";
				setPedAnimation(localPlayer, "parachute", "para_float", -2, true, false, false, true);
				-- SCM: PLAY_OBJECT_ANIM parac para_float_o PARACHUTE 1.0 1 1
			elseif (fControlBackwards ~= 0 and strPlayerAction ~= "BACKWARDS") then
				strPlayerAction = "BACKWARDS";
				setPedAnimation(localPlayer, "parachute", "para_decel", -2, true, false, false, true);
				-- SCM: PLAY_OBJECT_ANIM parac para_decel_o PARACHUTE 1.0 1 1
			elseif (fControlLeft ~= 0 and strPlayerAction ~= "LEFT") then
				strPlayerAction = "LEFT";
				setPedAnimation(localPlayer, "parachute", "para_steerl", -2, true, false, false, true);
				-- SCM: PLAY_OBJECT_ANIM parac para_steerL_o PARACHUTE 1.0 1 1
			elseif (fControlRight ~= 0 and strPlayerAction ~= "RIGHT") then
				strPlayerAction = "RIGHT";
				setPedAnimation(localPlayer, "parachute", "para_steerr", -2, true, false, false, true);
				-- SCM: PLAY_OBJECT_ANIM parac para_steerR_o PARACHUTE 1.0 1 1
			else
				if (strPlayerAction ~= "NONE") then
					setPedAnimation(localPlayer, "parachute", "para_float", -2, true, false, false, true);
				-- SCM: PLAY_OBJECT_ANIM parac para_float_o PARACHUTE 1.0 1 1
				end

				strPlayerAction = "NONE";
			end

			-- SCM:
			-- IF HAS_OBJECT_COLLIDED_WITH_ANYTHING para_col
			-- PLAY_OBJECT_ANIM parac para_rip_loop_o PARACHUTE 8.0 1 1

			--[[setElementVelocity(localPlayer, x, y, z);
			setElementRotation(localPlayer, 0, 0, yaw);

			-- player landed
			if (fVZ > -0.1) then
			strPlayerState = "LANDED";
			strParachuteState = "CLOSING";
			end--]]
		end

		-- player landed
		if (strPlayerState == "LANDED") then

		end
	end
end
addEventHandler("onClientRender", root, handleParachuteLogic);

function cleanupParachute(bLandedGood)
	iParachuteAnim = false;
	bHasParachute = false;
	strParachuteState = "NONE";
	strPlayerState = "GROUND";
	strPlayerAction = "NONE";

	if (isElement(uParachuteCollision)) then destroyElement(uParachuteCollision) end;
	if (isElement(uParachuteObject)) then destroyElement(uParachuteObject) end;
	if (isElement(uParachuteSound)) then destroyElement(uParachuteSound) end;

	toggleControl("next_weapon", true);
	toggleControl("previous_weapon", true);

	if (not bLandedGood) then
		-- todo: remove weapon from player via server
		-- takeWeapon(client, 46);
	end
end