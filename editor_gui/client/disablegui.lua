local active = true
local toggleHistory = {}


local guiTypes = { "gui-window","gui-staticimage" }

addEventHandler ( "onClientRender",root,
function()
	local isNowActive = isMTAWindowActive()
	if isNowActive ~= active then
		toggleAllGUI(not isNowActive)
		active = isNowActive
	end
end )

function toggleAllGUI ( bool )
	if not bool then
		for k,elementType in ipairs(guiTypes) do
			for k2,element in ipairs(getElementsByType(elementType,getResourceGUIElement(getThisResource()))) do
				if guiGetVisible ( element ) then
					guiSetVisible ( element, false )
					table.insert ( toggleHistory, element )
				end
			end
		end
	else
		for k,element in ipairs(toggleHistory) do
			if isElement(element) then
				guiSetVisible ( element, true )
			end
		end
		toggleHistory = {}
	end
end
