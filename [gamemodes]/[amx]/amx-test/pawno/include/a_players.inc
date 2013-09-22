/*  SA-MP Player Functions
 *
 *  (c) Copyright 2005-2012, SA-MP Team
 *
 */

#if defined _players_included
	#endinput
#endif
#define _players_included
#pragma library players

#define SPECIAL_ACTION_NONE				0
#define SPECIAL_ACTION_DUCK				1
#define SPECIAL_ACTION_USEJETPACK		2
#define SPECIAL_ACTION_ENTER_VEHICLE	3
#define SPECIAL_ACTION_EXIT_VEHICLE     4
#define SPECIAL_ACTION_DANCE1			5
#define SPECIAL_ACTION_DANCE2			6
#define SPECIAL_ACTION_DANCE3			7
#define SPECIAL_ACTION_DANCE4			8
#define SPECIAL_ACTION_HANDSUP			10
#define SPECIAL_ACTION_USECELLPHONE		11
#define SPECIAL_ACTION_SITTING			12
#define SPECIAL_ACTION_STOPUSECELLPHONE 13
#define SPECIAL_ACTION_DRINK_BEER		20
#define SPECIAL_ACTION_SMOKE_CIGGY		21
#define SPECIAL_ACTION_DRINK_WINE		22
#define SPECIAL_ACTION_DRINK_SPRUNK		23
#define SPECIAL_ACTION_CUFFED			24
#define SPECIAL_ACTION_CARRY			25

#define FIGHT_STYLE_NORMAL				4
#define FIGHT_STYLE_BOXING				5
#define FIGHT_STYLE_KUNGFU				6
#define FIGHT_STYLE_KNEEHEAD			7
#define FIGHT_STYLE_GRABKICK			15
#define FIGHT_STYLE_ELBOW				16

#define WEAPONSKILL_PISTOL 				0
#define WEAPONSKILL_PISTOL_SILENCED		1
#define WEAPONSKILL_DESERT_EAGLE		2
#define WEAPONSKILL_SHOTGUN				3
#define WEAPONSKILL_SAWNOFF_SHOTGUN		4
#define WEAPONSKILL_SPAS12_SHOTGUN		5
#define WEAPONSKILL_MICRO_UZI			6
#define WEAPONSKILL_MP5					7
#define WEAPONSKILL_AK47				8
#define WEAPONSKILL_M4					9
#define WEAPONSKILL_SNIPERRIFLE			10

#define WEAPONSTATE_UNKNOWN				-1
#define WEAPONSTATE_NO_BULLETS			0
#define WEAPONSTATE_LAST_BULLET			1
#define WEAPONSTATE_MORE_BULLETS		2
#define WEAPONSTATE_RELOADING			3

// Player
native SetSpawnInfo(playerid, team, skin, Float:x, Float:y, Float:z, Float:rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);
native SpawnPlayer(playerid);

// Player info
native SetPlayerPos(playerid, Float:x, Float:y, Float:z);
native SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z);
native GetPlayerPos(playerid, &Float:x, &Float:y, &Float:z);
native SetPlayerFacingAngle(playerid,Float:ang);
native GetPlayerFacingAngle(playerid,&Float:ang);
native IsPlayerInRangeOfPoint(playerid, Float:range, Float:x, Float:y, Float:z);
native Float:GetPlayerDistanceFromPoint(playerid, Float:X, Float:Y, Float:Z);
native IsPlayerStreamedIn(playerid, forplayerid);
native SetPlayerInterior(playerid,interiorid);
native GetPlayerInterior(playerid);
native SetPlayerHealth(playerid, Float:health);
native GetPlayerHealth(playerid, &Float:health);
native SetPlayerArmour(playerid, Float:armour);
native GetPlayerArmour(playerid, &Float:armour);
native SetPlayerAmmo(playerid, weaponslot, ammo);
native GetPlayerAmmo(playerid);
native GetPlayerWeaponState(playerid);
native GetPlayerTargetPlayer(playerid);
native SetPlayerTeam(playerid, teamid);
native GetPlayerTeam(playerid);
native SetPlayerScore(playerid,score);
native GetPlayerScore(playerid);
native GetPlayerDrunkLevel(playerid);
native SetPlayerDrunkLevel(playerid, level);
native SetPlayerColor(playerid,color);
native GetPlayerColor(playerid);
native SetPlayerSkin(playerid, skinid);
native GetPlayerSkin(playerid);
native GivePlayerWeapon(playerid, weaponid, ammo);
native ResetPlayerWeapons(playerid);
native SetPlayerArmedWeapon(playerid, weaponid);
native GetPlayerWeaponData(playerid, slot, &weapons, &ammo);
native GivePlayerMoney(playerid,money);
native ResetPlayerMoney(playerid);
native SetPlayerName(playerid, const name[]);
native GetPlayerMoney(playerid);
native GetPlayerState(playerid);
native GetPlayerIp(playerid, name[], len);
native GetPlayerPing(playerid);
native GetPlayerWeapon(playerid);
native GetPlayerKeys(playerid, &keys, &updown, &leftright);
native GetPlayerName(playerid, const name[], len);
native SetPlayerTime(playerid, hour, minute);
native GetPlayerTime(playerid, &hour, &minute);
native TogglePlayerClock(playerid, toggle);
native SetPlayerWeather(playerid, weather);
native ForceClassSelection(playerid);
native SetPlayerWantedLevel(playerid, level);
native GetPlayerWantedLevel(playerid);
native SetPlayerFightingStyle(playerid, style);
native GetPlayerFightingStyle(playerid);
native SetPlayerVelocity(playerid, Float:X, Float:Y, Float:Z);
native GetPlayerVelocity( playerid, &Float:X, &Float:Y, &Float:Z );
native PlayCrimeReportForPlayer(playerid, suspectid, crime);
native PlayAudioStreamForPlayer(playerid, url[], Float:posX = 0.0, Float:posY = 0.0, Float:posZ = 0.0, Float:distance = 50.0, usepos = 0);
native StopAudioStreamForPlayer(playerid);
native SetPlayerShopName(playerid, shopname[]);
native SetPlayerSkillLevel(playerid, skill, level);
native GetPlayerSurfingVehicleID(playerid);
native GetPlayerSurfingObjectID(playerid);
native RemoveBuildingForPlayer(playerid, modelid, Float:fX, Float:fY, Float:fZ, Float:fRadius);

// Attached to bone objects

#define MAX_PLAYER_ATTACHED_OBJECTS 10 // This is the number of attached indexes available ie 10 = 0-9

native SetPlayerAttachedObject(playerid, index, modelid, bone, Float:fOffsetX = 0.0, Float:fOffsetY = 0.0, Float:fOffsetZ = 0.0, Float:fRotX = 0.0, Float:fRotY = 0.0, Float:fRotZ = 0.0, Float:fScaleX = 1.0, Float:fScaleY = 1.0, Float:fScaleZ = 1.0, materialcolor1 = 0, materialcolor2 = 0);
native RemovePlayerAttachedObject(playerid, index);
native IsPlayerAttachedObjectSlotUsed(playerid, index);
native EditAttachedObject(playerid, index);

// Per-player TextDraws
native PlayerText:CreatePlayerTextDraw(playerid, Float:x, Float:y, text[]);
native PlayerTextDrawDestroy(playerid, PlayerText:text);
native PlayerTextDrawLetterSize(playerid, PlayerText:text, Float:x, Float:y);
native PlayerTextDrawTextSize(playerid, PlayerText:text, Float:x, Float:y);
native PlayerTextDrawAlignment(playerid, PlayerText:text, alignment);
native PlayerTextDrawColor(playerid, PlayerText:text, color);
native PlayerTextDrawUseBox(playerid, PlayerText:text, use);
native PlayerTextDrawBoxColor(playerid, PlayerText:text, color);
native PlayerTextDrawSetShadow(playerid, PlayerText:text, size);
native PlayerTextDrawSetOutline(playerid, PlayerText:text, size);
native PlayerTextDrawBackgroundColor(playerid, PlayerText:text, color);
native PlayerTextDrawFont(playerid, PlayerText:text, font);
native PlayerTextDrawSetProportional(playerid, PlayerText:text, set);
native PlayerTextDrawSetSelectable(playerid, PlayerText:text, set);
native PlayerTextDrawShow(playerid, PlayerText:text);
native PlayerTextDrawHide(playerid, PlayerText:text);
native PlayerTextDrawSetString(playerid, PlayerText:text, string[]);
native PlayerTextDrawSetPreviewModel(playerid, PlayerText:text, modelindex);
native PlayerTextDrawSetPreviewRot(playerid, PlayerText:text, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fZoom = 1.0);
native PlayerTextDrawSetPreviewVehCol(playerid, PlayerText:text, color1, color2);

// Per-player variable system (PVars)
native SetPVarInt(playerid, varname[], int_value);
native GetPVarInt(playerid, varname[]);
native SetPVarString(playerid, varname[], string_value[]);
native GetPVarString(playerid, varname[], string_return[], len);
native SetPVarFloat(playerid, varname[], Float:float_value);
native Float:GetPVarFloat(playerid, varname[]);
native DeletePVar(playerid, varname[]);

// PVar enumeration
#define PLAYER_VARTYPE_NONE			0
#define PLAYER_VARTYPE_INT			1
#define PLAYER_VARTYPE_STRING		2
#define PLAYER_VARTYPE_FLOAT		3

native GetPVarsUpperIndex(playerid);
native GetPVarNameAtIndex(playerid, index, ret_varname[], ret_len);
native GetPVarType(playerid, varname[]);

#define MAX_CHATBUBBLE_LENGTH 144
native SetPlayerChatBubble(playerid, text[], color, Float:drawdistance, expiretime);

// Player controls
native PutPlayerInVehicle(playerid, vehicleid, seatid);
native GetPlayerVehicleID(playerid);
native GetPlayerVehicleSeat(playerid);
native RemovePlayerFromVehicle(playerid);
native TogglePlayerControllable(playerid, toggle);
native PlayerPlaySound(playerid, soundid, Float:x, Float:y, Float:z);
native ApplyAnimation(playerid, animlib[], animname[], Float:fDelta, loop, lockx, locky, freeze, time, forcesync = 0);
native ClearAnimations(playerid, forcesync = 0);
native GetPlayerAnimationIndex(playerid); // return the index of any running applied animations (0 if none are running)
native GetAnimationName(index, animlib[], len1, animname[], len2); // get the animation lib/name for the index
native GetPlayerSpecialAction(playerid);
native SetPlayerSpecialAction(playerid,actionid);

// Player world/map related
native SetPlayerCheckpoint(playerid, Float:x, Float:y, Float:z, Float:size);
native DisablePlayerCheckpoint(playerid);
native SetPlayerRaceCheckpoint(playerid, type, Float:x, Float:y, Float:z, Float:nextx, Float:nexty, Float:nextz, Float:size);
native DisablePlayerRaceCheckpoint(playerid);
native SetPlayerWorldBounds(playerid,Float:x_max,Float:x_min,Float:y_max,Float:y_min);
native SetPlayerMarkerForPlayer(playerid, showplayerid, color);
native ShowPlayerNameTagForPlayer(playerid, showplayerid, show);

#define MAPICON_LOCAL			  0 // displays in the player's local are
#define MAPICON_GLOBAL			  1 // displays always
#define MAPICON_LOCAL_CHECKPOINT  2 // displays in the player's local area and has a checkpoint marker
#define MAPICON_GLOBAL_CHECKPOINT 3 // displays always and has a checkpoint marker

native SetPlayerMapIcon(playerid, iconid, Float:x, Float:y, Float:z, markertype, color, style = MAPICON_LOCAL);
native RemovePlayerMapIcon(playerid, iconid);

native AllowPlayerTeleport(playerid, allow);

// Player camera
native SetPlayerCameraPos(playerid,Float:x, Float:y, Float:z);

#define CAMERA_CUT	2
#define CAMERA_MOVE 1

native SetPlayerCameraLookAt(playerid, Float:x, Float:y, Float:z, cut = CAMERA_CUT);
native SetCameraBehindPlayer(playerid);
native GetPlayerCameraPos(playerid, &Float:x, &Float:y, &Float:z);
native GetPlayerCameraFrontVector(playerid, &Float:x, &Float:y, &Float:z);
native GetPlayerCameraMode(playerid);
native AttachCameraToObject(playerid, objectid);
native AttachCameraToPlayerObject(playerid, playerobjectid);
native InterpolateCameraPos(playerid, Float:FromX, Float:FromY, Float:FromZ, Float:ToX, Float:ToY, Float:ToZ, time, cut = CAMERA_CUT);
native InterpolateCameraLookAt(playerid, Float:FromX, Float:FromY, Float:FromZ, Float:ToX, Float:ToY, Float:ToZ, time, cut = CAMERA_CUT);

// Player conditionals
native IsPlayerConnected(playerid);
native IsPlayerInVehicle(playerid, vehicleid);
native IsPlayerInAnyVehicle(playerid);
native IsPlayerInCheckpoint(playerid);
native IsPlayerInRaceCheckpoint(playerid);

// Virtual Worlds
native SetPlayerVirtualWorld(playerid, worldid);
native GetPlayerVirtualWorld(playerid);

// Insane Stunts
native EnableStuntBonusForPlayer(playerid, enable);
native EnableStuntBonusForAll(enable);

// Spectating
#define SPECTATE_MODE_NORMAL	1
#define SPECTATE_MODE_FIXED		2
#define SPECTATE_MODE_SIDE		3

native TogglePlayerSpectating(playerid, toggle);
native PlayerSpectatePlayer(playerid, targetplayerid, mode = SPECTATE_MODE_NORMAL);
native PlayerSpectateVehicle(playerid, targetvehicleid, mode = SPECTATE_MODE_NORMAL);

// Recording for NPC playback
#define PLAYER_RECORDING_TYPE_NONE		0
#define PLAYER_RECORDING_TYPE_DRIVER	1
#define PLAYER_RECORDING_TYPE_ONFOOT	2

native StartRecordingPlayerData(playerid, recordtype, recordname[]);
native StopRecordingPlayerData(playerid);

native SelectTextDraw(playerid, hovercolor); // enables the mouse so the player can select a textdraw
native CancelSelectTextDraw(playerid);	// cancel textdraw selection with the mouse