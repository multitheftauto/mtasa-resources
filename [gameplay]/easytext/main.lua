local root = getRootElement ()
local resourceRoot = getResourceRootElement ( getThisResource () )
local textTable = {}

function displayMessageForPlayer ( player, textID, message, duration, posX, posY, colorR, colorG, colorB, alpha, scale )
	--assert ( player and message and textID, "cannot display message - no player, message, or textID argument(s) provided" )
	if not ( player and message and textID ) then  outputDebugString("Warning: cannot display message - no player, message, or textID argument(s) provided")  return false  end
	if ( textTable[player][textID] ) then
		if ( textTable[player][textID].timer ) then
			killTimer ( textTable[player][textID].timer )
		end
	else
		textTable[player][textID] = {}
		textTable[player][textID].display = textCreateDisplay ()
		textTable[player][textID].item = textCreateTextItem ( "", .5, .5, "medium", 255, 255, 255, 255, 2, "center", "center" )
		textDisplayAddText ( textTable[player][textID].display, textTable[player][textID].item )
		textDisplayAddObserver ( textTable[player][textID].display, player )
	end
	duration = duration or 5000
	posX = posX or 0.5
	posY = posY or 0.5
	colorR = colorR or 255
	colorG = colorG or 255
	colorB = colorB or 255
	alpha = alpha or 255
	scale = scale or 2
	textItemSetText ( textTable[player][textID].item, message )
	textItemSetPosition ( textTable[player][textID].item, posX, posY )
	textItemSetColor ( textTable[player][textID].item, colorR, colorG, colorB, alpha )
	textItemSetScale ( textTable[player][textID].item, scale )
	textTable[player][textID].timer = setTimer ( clearText, duration, 1, player, textID )
	return true
end

function clearMessageForPlayer ( player, textID )
	--assert ( player and textID, "cannot clear message - no player, or textID argument(s) provided" )
	if not ( player and textID ) then  outputDebugString("Warning: cannot clear message - no player, or textID argument(s) provided")  return false  end
	if ( textTable[player][textID] ) then
		if ( textTable[player][textID].timer ) then
		    -- if this timer exists, there is a display currently being shown that can be cleared
			killTimer ( textTable[player][textID].timer )
			clearText ( player, textID )
			return true
  		else
	    	return false
		end
	else
	    return false
	end
end

function clearText ( player, textID )
	textItemSetText ( textTable[player][textID].item, "" )
	textTable[player][textID].timer = false
end

function onPlayerJoin_easyText ()
	textTable[source] = {}
end
addEventHandler ( "onPlayerJoin", root, onPlayerJoin_easyText )

function onEasyTextStart ( resource )
	for i,v in ipairs ( getElementsByType ( "player" ) ) do
		textTable[v] = {}
	end
end
addEventHandler ( "onResourceStart", resourceRoot, onEasyTextStart )

function onPlayerQuit_easyText ()
	for k,v in pairs ( textTable[source] ) do
		if ( v.timer ) then
			killTimer ( v.timer )
		end
		textDestroyDisplay ( v.display )
		textDestroyTextItem ( v.item )
	end
	textTable[source] = nil
end
addEventHandler ( "onPlayerQuit", root, onPlayerQuit_easyText )

function onEasyTextStop ( resource )
	for playerIndex,playerValue in ipairs ( getElementsByType ( "player" ) ) do
		for k,v in pairs ( textTable[playerValue] ) do
			if ( v.timer ) then
				killTimer ( v.timer )
			end
			textDestroyDisplay ( v.display )
			textDestroyTextItem ( v.item )
		end
		textTable[playerValue] = nil
	end
end
addEventHandler ( "onResourceStop", resourceRoot, onEasyTextStop )
