/*  MTA AMX compatibility layer
 *
 *  Extension functions
 */

#if defined _amx_included
	#endinput
#endif
#define _amx_included

native lua(const fn[], {Float,_}:...);
native amxRegisterPawnPrototypes(const prototype[][]);
native amxVersion(&Float:ver);
native amxVersionString(buffer[], maxsize);

// Players
native AddPlayerClothes(playerid, type, index);
native GetPlayerClothes(playerid, type);
native RemovePlayerClothes(playerid, type);
native ShowPlayerMarker(playerid, show);

// Vehicles
native GetVehicleVelocity(vehicleid, &Float:vx, &Float:vy, &Float:vz);
native SetVehicleVelocity(vehicleid, Float:vx, Float:vy, Float:vz);
native SetVehicleModel(vehicleid, model);
