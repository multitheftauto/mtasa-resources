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