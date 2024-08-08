-- log messages triggered by player
function logViolation(uPlayer, strMessage)
	local strPlayerName, strPlayerIP, strPlayerSerial = getPlayerName(uPlayer), getPlayerIP(uPlayer), getPlayerSerial(uPlayer);
	local strLogFileName = "violations.txt";
	local uFileHandle = fileExists(strLogFileName) and fileOpen(strLogFileName);
	
	if(not uFileHandle) then
		uFileHandle = fileCreate(strLogFileName);
		fileFlush(uFileHandle);
	else
		fileSetPos(uFileHandle, fileGetSize(uFileHandle));
	end
	
	local strViolationMessage = getDateTime().." CLIENT: "..strPlayerName.." | IP: "..strPlayerIP.." | SERIAL: "..strPlayerSerial.." | "..strMessage;
	
	outputDebugString(strViolationMessage, 4, 255, 255, 255);
	outputServerLog(strViolationMessage);
	fileWrite(uFileHandle, strViolationMessage.."\n");
	fileClose(uFileHandle);
end



-- log messages without player element
function logAction(strMessage)
	local strLogFileName = "actions.txt";
	local uFileHandle = fileExists(strLogFileName) and fileOpen(strLogFileName);
	
	if(not uFileHandle) then
		uFileHandle = fileCreate(strLogFileName);
		fileFlush(uFileHandle);
	else
		fileSetPos(uFileHandle, fileGetSize(uFileHandle));
	end
	
	local strActionMessage = getDateTime().." "..strMessage;
	
	outputDebugString(strActionMessage, 4, 255, 255, 255);
	outputServerLog(strActionMessage);
	fileWrite(uFileHandle, strActionMessage.."\n");
	fileClose(uFileHandle);
end



-- get the current date and time for logging
function getDateTime()
	local tblRealTime 	= getRealTime();
	local iDay 			= tblRealTime.monthday;
	local iMonth 		= tblRealTime.month + 1;
	local iYear 		= tblRealTime.year + 1900;
	local iHour 		= tblRealTime.hour;
	local iMinute 		= tblRealTime.minute;
	local iSecond 		= tblRealTime.second;
	
	if(iDay < 10) then iDay = "0"..iDay end;
	if(iMonth < 10) then iMonth = "0"..iMonth end;
	if(iHour < 10) then iHour = "0"..iHour end;
	if(iMinute < 10) then iMinute = "0"..iMinute end;
	if(iSecond < 10) then iSecond = "0"..iSecond end;
	
	return "["..tostring(iDay).."."..tostring(iMonth).."."..tostring(iYear).." - "..tostring(iHour)..":"..tostring(iMinute)..":"..tostring(iSecond).."]";
end