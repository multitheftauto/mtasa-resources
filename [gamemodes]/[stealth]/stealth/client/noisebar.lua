function setupstuff ()
	blipshowing = 0
	soundlevel = 0
	local x, y = guiGetScreenSize()
	x = x * 0.092
	y = y * 0.71
	thesoundbar = guiCreateProgressBar ( x, y, 100, 20, false )
	SoundText = guiCreateLabel ( .35 , 0, 100, 20, "Sound", true, thesoundbar )
	guiLabelSetColor ( SoundText, 1, 1, 1 )
	fadesoundout = setTimer ( reducesoundlevel, 1000, 0 )
	casualcheck = setTimer ( noisecheck, 1000, 0 )
	watchedTasks = { TASK_SIMPLE_TIRED=true, TASK_SIMPLE_IN_AIR=true, TASK_SIMPLE_PLAYER_ON_FIRE=true, TASK_SIMPLE_JUMP=true, TASK_SIMPLE_JETPACK=true, TASK_SIMPLE_HIT_FRONT=true, TASK_SIMPLE_HIT_HEAD=true, TASK_SIMPLE_HIT_LEFT=true, TASK_SIMPLE_HIT_RIGHT=true, TASK_SIMPLE_HIT_WALL=true, TASK_SIMPLE_HIT_BACK=true, TASK_SIMPLE_HIT_BEHIND=true, TASK_SIMPLE_HIT_BY_GUN_BACK=true, TASK_SIMPLE_HIT_BY_GUN_FRONT=true, TASK_SIMPLE_HIT_BY_GUN_LEFT=true, TASK_SIMPLE_HIT_BY_GUN_RIGHT=true, TASK_SIMPLE_FALL=true, TASK_SIMPLE_FIGHT=true, TASK_SIMPLE_FIGHT_CTRL=true, TASK_SIMPLE_EVASIVE_DIVE=true, TASK_SIMPLE_EVASIVE_STEP=true, TASK_SIMPLE_DROWN=true, TASK_SIMPLE_DROWN_IN_CAR=true, TASK_SIMPLE_DRIVEBY_SHOOT=true, TASK_SIMPLE_DIE=true, TASK_SIMPLE_DIE_IN_CAR=true, TASK_SIMPLE_DETONATE=true, TASK_SIMPLE_CLIMB=true, TASK_SIMPLE_CHOKING=true, TASK_SIMPLE_CAR_SLOW_BE_DRAGGED_OUT=true, TASK_SIMPLE_CAR_SLOW_DRAG_PED_OUT=true, TASK_SIMPLE_CAR_QUICK_BE_DRAGGED_OUT=true, TASK_SIMPLE_CAR_QUICK_DRAG_PED_OUT=true, TASK_SIMPLE_CAR_GET_IN=true, TASK_SIMPLE_CAR_GET_OUT=true, TASK_SIMPLE_CAR_JUMP_OUT=true, TASK_SIMPLE_CAR_DRIVE=true, TASK_SIMPLE_BIKE_JACKED=true, TASK_SIMPLE_BE_DAMAGED=true, TASK_SIMPLE_BE_HIT=true, TASK_SIMPLE_BE_HIT_WHILE_MOVING=true, TASK_SIMPLE_GOGGLES_OFF=true, TASK_SIMPLE_GOGGLES_ON=true }
	controls = { "fire", "next_weapon", "previous_weapon", "jump", "forwards","backwards","left","right","sprint","enter_exit","vehicle_fire","vehicle_secondary_fire","steer_forwards","steer_back","accelerate","brake_reverse","horn","handbrake","special_control_left","special_control_right","special_control_down","special_control_up" }
	for k,v in pairs(controls) do
		bindKey (v, "both", noisecheck )
	end
	guiSetVisible ( thesoundbar, false )
	bindKey ("forwards", "down", walksoundstart )
	bindKey ("backwards", "down", walksoundstart )
	bindKey ("left", "down", walksoundstart )
	bindKey ("right", "down", walksoundstart )
	bindKey ("forwards", "up", walksoundstop )
	bindKey ("backwards", "up", walksoundstop )
	bindKey ("left", "up", walksoundstop )
	bindKey ("right", "up", walksoundstop )
end

--THIS RESETS THE PLAYERS SOUNDLEVEL, BINDS THE KEYS, AND TRIGGERS ALL THE FUNCTIONS THAT DETECT SOUND
function setupsoundstuff ( source )
	blipshowing = 0
	soundlevel = 0
	alreadylimping = 0
	toggleControl ("right", true )
	toggleControl ("left", true )
	toggleControl ("forwards", true )
	toggleControl ("backwards", true )
	guiSetVisible ( thesoundbar, true )
end

--THIS CHECKS IF THE PLAYER IS DOING CERTAIN THINGS THAT ARE KNOWN TO MAKE NOISE
function noisecheck ( source, key, keystate )
	thetask = getPedSimplestTask(localPlayer)
	if watchedTasks[thetask] then
		soundlevel = soundlevel+1
	end
end

--THIS IS THE TIMER TO BRING THE SOUNDLEVEL BACK DOWN AND UPDATE THE PLAYERS NOISELEVEL
function reducesoundlevel ()
	if soundlevel > 0 then
		soundlevel = soundlevel-1
	end
	if soundlevel > 10 then --THIS CAPS THE MAX SOUND LEVEL AT 10
		soundlevel = 10
	end
	barlevel = soundlevel * 10
	guiProgressBarSetProgress ( thesoundbar, barlevel )
--	guiSetVisible ( thesoundbar, true )
	smoothfade = setTimer ( smoothreduce, 100, 9 )
	setElementData ( getLocalPlayer (), "noiselevel", soundlevel )
	if soundlevel > 0 then
		if blipshowing == 0 then
			local isDead = isPedDead(getLocalPlayer ())
			if (isDead == false) then
				blipshowing = 1
			end
		end
	end
	if soundlevel == 0 then
		if blipshowing == 1 then
			blipshowing = 0
		end
	end
	updateRemoteSoundLevels()
end
--THIS REDUCES THE BAR VISUALLY WITHOUT EFFECTING THE ACTUAL VALUES
function smoothreduce ()
	local newprobar = guiProgressBarGetProgress (thesoundbar)
	guiProgressBarSetProgress ( thesoundbar, newprobar-1 )
--	guiSetVisible ( thesoundbar, true )
end


--THIS PART MAKES NOISE WHEN A PLAYER GETS HURT
bodyPartAnim = {
	[7] = {	"DAM_LegL_frmBK",	42	},
	[8] = {	"DAM_LegR_frmBK",	52	},
}

function damagenoise ( attacker, weapon, bodypart, loss )
	soundlevel = soundlevel+2
	restartdamagedetect = setTimer ( readddamage, 1000, 1 )
	--Only continue if our bodypart is one of the legs
	if ( bodypart ~= 7 ) and ( bodypart ~= 8 ) then
		return
	end
	local isplayerlimping = getElementData ( getLocalPlayer (), "legdamage" )
	if isplayerlimping ~= 1 then
		if (attacker) then
			local attackerteam = getPlayerTeam (attacker)
			local yourteam = getPlayerTeam (getLocalPlayer ())
			if attackerteam == yourteam then
				if getTeamFriendlyFire ( yourteam ) == false then
					--do nothing
					return
				end
			end
			if not getElementData ( source, "armor" ) then
				--outputChatBox("You've been hit in the leg.", 255, 69, 0)
				setPedAnimation ( localPlayer, "ped", bodyPartAnim[bodypart][1], true, true, false )
				setTimer ( setPedAnimation, 600, 1, localPlayer )
				setElementData ( getLocalPlayer (), "legdamage", 1 )
				--Blood stuff
				local function blood()
					local boneX,boneY,boneZ = getPedBonePosition(localPlayer, bodyPartAnim[bodypart][2])
					local rot = math.rad(getPedRotation ( localPlayer ))
					fxAddBlood ( boneX,boneY,boneZ, -math.sin(rot), math.cos(rot), -0.1, 500, 1.0 )
				end
				blood()
				setTimer(blood,50,50)
				--
				local makeplayerlimp = setTimer ( limpeffect, 1000, 1, source, key, state )
			end
		end
	end
end

function readddamage ()
	-- addEventHandler ( "onClientPedDamage", getLocalPlayer (), damagenoise )
end


--THIS PART MAKES SHOOTING A WEAPON MAKE NOISE
function shootingnoise ( weapon )
	if weapon == 22 then
		soundlevel = soundlevel +1
	elseif weapon == 24 then
		soundlevel = soundlevel +2
	elseif weapon == 25 then
		soundlevel = soundlevel +2
	elseif weapon == 27 then
		soundlevel = soundlevel +2
	elseif weapon == 28 then
		soundlevel = soundlevel +1
	elseif weapon == 29 then
		soundlevel = soundlevel +1
	elseif weapon == 30 then
		soundlevel = soundlevel +1
	elseif weapon == 31 then
		soundlevel = soundlevel +1
	elseif weapon == 32 then
		soundlevel = soundlevel +1
	elseif weapon == 33 then
		soundlevel = soundlevel +2
	elseif weapon == 34 then
		soundlevel = soundlevel +3
	end
end

--THIS PART CAUSES PLAYERS TO MAKE NOISE IF THEY DONT CROUCH OR SLOW WALK
function walksoundstart (source, key, keystate)
	if isplayermoving ~= 1 then
		movementsound = setTimer ( movementcheck, 900, 0 )
		isplayermoving = 1
	end
end


--LIMP TIMING

function limpeffect ( source, key, keystate )
	if isPedInVehicle (getLocalPlayer ()) then
		return
	else
		islimping = getElementData ( getLocalPlayer (), "legdamage" )
		if islimping == 1 then
			local makeplayerlimp = setTimer ( limpeffectparttwo , 200, 1, source, key, state )
			if 	lookingthroughcamera ~= 1 then
				toggleControl ("right", false )
				toggleControl ("left", false )
				toggleControl ("forwards", false )
				toggleControl ("backwards", false )
			end
		end
	end
end

function limpeffectparttwo ( source, key, keystate )
	if isPedInVehicle (getLocalPlayer ()) then
		return
	else
		islimping = getElementData ( getLocalPlayer (), "legdamage" )
		if islimping == 1 then
			local makeplayerlimp = setTimer ( limpeffect, 500, 1, source, key, state )
			if 	lookingthroughcamera ~= 1 then
				if shieldon ~= 1 then
					toggleControl ("right", true )
					toggleControl ("left", true )
					toggleControl ("forwards", true )
					toggleControl ("backwards", true )
				end
			end
		end
	end
end

function startalimp ()
	local theplayer = getLocalPlayer ()
	if (getPedArmor ( theplayer )) == 0 then
		setElementData ( getLocalPlayer (), "legdamage", 1 )
		local makeplayerlimp = setTimer ( limpeffect, 300, 1, source, key, state )
	end
end

addCommandHandler ( "crippleme", startalimp )


function movementcheck ( source, key, keystate )
	if ( isPedDucked ( getLocalPlayer () ) ) == false then
		if ( getPedControlState ( "sprint" ) ) then
			soundlevel = soundlevel +1
		end
		if ( getPedControlState ( "walk" ) ) == false then
			soundlevel = soundlevel +1
		end
	end
end

function walksoundstop ( source, key, keystate )
	if isplayermoving == 1 then
		if ( getPedControlState ( "forwards" ) ) == false and ( getPedControlState ( "backwards" ) ) == false and ( getPedControlState ( "left" ) ) == false and ( getPedControlState ( "right" ) ) == false then
			killTimer ( movementsound )
			isplayermoving = 0
		end
	end
end

function setuptrigger ( theresource )
	if theresource == getThisResource() then
		setupstuff()
	end
end

function hidesoundbar ( theresource )
	guiSetVisible ( thesoundbar, false )
end

addEventHandler ( "onClientPlayerWasted", getLocalPlayer (), hidesoundbar )
addEventHandler ( "onClientPlayerDamage", getLocalPlayer (), damagenoise )
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer (), shootingnoise )
addEventHandler ( "onClientPlayerSpawn", getLocalPlayer (), setupsoundstuff )
addEventHandler ( "onClientResourceStart", resourceRoot, setuptrigger)
