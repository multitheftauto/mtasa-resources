
local protectedElementDataKeys = {
	["Wins"] = true,
	["Losses"] = true,
	["W/L Ratio"] = true
}

--[[
	Disallow remote modification of element data to prevent unauthorized changes.
]]
function protectPlayerElementData(theKey, oldValue, newValue)
	if protectedElementDataKeys[theKey] and client then
		setElementData(source, theKey, oldValue)
		outputDebugString ( "Player " .. getPlayerName(client) .. " " .. getPlayerSerial(client) .. " tried to modify his score.", 0, 255, 255, 255 )
	end
end
