-- checks if a player nickname is valid in terms of length and ascii chars
function isPlayerNameValid(strPlayerName)
	if(not strPlayerName) then return false end;
	if(not tostring(strPlayerName)) then return false end;
	if(#strPlayerName == 0) then return false end;
	if(#strPlayerName > 22) then return false end;
	
	for i = 1, #strPlayerName do
		local strChar = strPlayerName:sub(i, i);
		local iCharByte = strChar:byte();
		
		if(iCharByte < 33 or iCharByte > 126) then return false end;
	end

	return true;
end