-- used to check how many explosion/projectile sync packets a client sends overtime
local iExplosionCheckInterval 		= 3000;	-- the interval in ms to check for players sending too many explosion and projectile sync packets
local tblPlayerProjectiles 			= {};	-- store players sending projectile sync packets
local tblRegularExplosions 			= {};	-- store players sending regular explosion sync packets
local tblVehicleExplosions 			= {};	-- store players sending vehicle explosion sync packets
local iPlayerProjectileThreshold 	= 10;	-- the threshold when we consider client suspicious for projectile creations
local iRegularExplosionThreshold 	= 10;	-- the threshold when we consider client suspicious for regular explosions
local iVehicleExplosionThreshold 	= 10;	-- the threshold when we consider client suspicious for vehicle explosions



-- add the elementdatas you want to protect from client updates in here
local tblProtectedElementDatas = {["Score"] = true};



-- https://wiki.multitheftauto.com/wiki/OnElementDataChange
-- gets triggered when a client tries to change a synced elementdata, check if client is permitted to change that specific data
-- also prevents one client changing the elementdata of another client
function clientChangesElementData(strKey, varOldValue, varNewValue)
	if(client and (tblProtectedElementDatas[strKey] or client ~= source)) then
		logViolation(client, "Tried to change elementdata \""..tostring(strKey).."\" of resource \""..tostring(sourceResource).."\" from \""..tostring(varOldValue).."\" to \""..tostring(varNewValue).."\"");
		setElementData(source, strKey, varOldValue);
	end
end
addEventHandler("onElementDataChange", root, clientChangesElementData);



-- https://wiki.multitheftauto.com/wiki/OnPlayerChangesProtectedData
-- gets triggered when a client tries to change protected element data
-- see elementdata_whitelisted config https://wiki.multitheftauto.com/wiki/Server_mtaserver.conf#elementdata_whitelisted
-- this needs to be setup in conjunction with your existing elementdatas to take necessary action!
-- the key feature is to prevent the client from updating non synced server elementdatas if they know the key and attached element
function clientChnagesProtectedData(uElement, strKey, unValue)
	logViolation(source, "Tried to change protected elementdata for key "..tostring(strKey).." to value "..tostring(unValue).." for element "..tostring(uElement).." ("..getElementType(uElement)..")");
end
addEventHandler("onPlayerChangesProtectedData", root, clientChnagesProtectedData);



-- https://wiki.multitheftauto.com/wiki/OnPlayerACInfo
-- gets triggered when AC detects something for client on connect
function clientNotifyACInfo(tblDetectedACList, iD3D9Size, strD3D9MD5, strD3D9SHA256)
	logViolation(source, "AC list detected: "..table.concat(tblDetectedACList, ",").." - D3D9Size: "..tostring(iD3D9Size).." - D3D9MD5: "..tostring(strD3D9MD5));
end
addEventHandler("onPlayerACInfo", root, clientNotifyACInfo);



-- https://wiki.multitheftauto.com/wiki/OnPlayerModInfo
-- gets triggered when client joins server with modified game files
function clientNotifyModInfo(strFileName, tblItemList)
	for _, strItemName in ipairs(tblItemList) do
		logViolation(source, "Mod detected - file: "..strFileName.." - GTA ID: "..strItemName.id.." - GTA name: "..strItemName.name);
	end
end
addEventHandler("onPlayerModInfo", root, clientNotifyModInfo);



-- force all connected players to send their AC/Mod info on resource start
addEventHandler("onResourceStart", resourceRoot, function()
	for _, uPlayer in ipairs(getElementsByType("player")) do
		resendPlayerModInfo(uPlayer);
		resendPlayerACInfo(uPlayer);
	end
end);



-- https://wiki.multitheftauto.com/wiki/OnPlayerNetworkStatus
-- gets triggered when connection from server to a client is interrupted
function clientNetworkStatus(iStatus, iTicks)
	if(iStatus == 0) then
		logViolation(source, "Network interruption has began after "..iTicks.." ticks");
	elseif(iStatus == 1) then
		logViolation(source, "Network interruption has stopped after "..iTicks.." ticks");
	end
end
addEventHandler("onPlayerNetworkStatus", root, clientNetworkStatus);



-- https://wiki.multitheftauto.com/wiki/OnPlayerProjectileCreation
-- gets triggered when a player creates a projectile sync packets (eg. shoots a weapon, vehicle weapon or via createProjectile)
function clientCreateProjectile(iWeaponType, fPX, fPY, fPZ, fForce, uTarget, fRX, fRY, fRZ, fVX, fVY, fVZ)
	if(isElement(source)) then
		if(tblPlayerProjectiles[source]) then
			tblPlayerProjectiles[source] = tblPlayerProjectiles[source] + 1;
		else
			tblPlayerProjectiles[source] = 1;
		end
	end
end
addEventHandler("onPlayerProjectileCreation", root, clientCreateProjectile);



-- https://wiki.multitheftauto.com/wiki/OnExplosion
-- gets triggered when an explosion occurs, either via server script or client sync packet
function clientCreateExplosion(fPX, fPY, fPZ, iType)
	if(isElement(source)) then
		if(getElementType(source) == "player") then
			if(tblRegularExplosions[source]) then
				tblRegularExplosions[source] = tblRegularExplosions[source] + 1;
			else
				tblRegularExplosions[source] = 1;
			end
		end
	end
end
addEventHandler("onExplosion", root, clientCreateExplosion);



-- https://wiki.multitheftauto.com/wiki/OnVehicleExplode
-- gets triggered when a vehicle explodes, either via server script or client sync packet
function clientCreateVehicleExplosion(bWithExplosion, uPlayer)
	if(isElement(uPlayer)) then
		if(tblVehicleExplosions[uPlayer]) then
			tblVehicleExplosions[uPlayer] = tblVehicleExplosions[uPlayer] + 1;
		else
			tblVehicleExplosions[uPlayer] = 1;
		end
	end
end
addEventHandler("onVehicleExplode", root, clientCreateVehicleExplosion);



-- setup a timer with specified interval above and check if any client sent too many sync packets in the given time
-- thresholds need to be adjusted for your need and actions taken!
setTimer(function()
	for uPlayer, iCounter in pairs(tblPlayerProjectiles) do
		if(iCounter >= iPlayerProjectileThreshold) then
			logViolation(uPlayer, "Exceeded projectile threshold "..tostring(iPlayerProjectileThreshold).." - Count: "..tostring(iCounter));
		end
	end
	
	for uPlayer, iCounter in pairs(tblRegularExplosions) do
		if(iCounter >= iRegularExplosionThreshold) then
			logViolation(uPlayer, "Exceeded regular explosions threshold "..tostring(iRegularExplosionThreshold).." - Count: "..tostring(iCounter));
		end
	end
	
	for uPlayer, iCounter in pairs(tblVehicleExplosions) do
		if(iCounter >= iVehicleExplosionThreshold) then
			logViolation(uPlayer, "Exceeded vehicle explosions threshold "..tostring(iVehicleExplosionThreshold).." - Count: "..tostring(iCounter));
		end
	end
	
	tblPlayerProjectiles = {};
	tblRegularExplosions = {};
	tblVehicleExplosions = {};
	
end, iExplosionCheckInterval, 0);