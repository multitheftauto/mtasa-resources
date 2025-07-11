addEvent "onClientGUIMouseDown"
addEvent "onClientGUIWorldClick"
local enableWorld = true
local lastClicked

-- bindKey ( cc.pickup_targeted_element, "up", worldClickEventTrigger, "pickup" )
-- bindKey ( cc.select_targeted_element, "up", worldClickEventTrigger, "select" )
addEventHandler ( "onClientClick",root,
function (button, state,absoluteX,absoluteY,worldX,worldY,worldZ,clicked )
	if state == "down" then
		local guiElement = guiGetMouseOverElement()
		lastClicked = guiElement
	end
	if isElement( lastClicked ) then
		triggerEvent ( "onClientGUIMouseDown",lastClicked,button, state,absoluteX, absoluteX)
		triggerEvent ( "onClientGUIWorldClick",lastClicked,button, state,absoluteX,absoluteY,worldX,worldY,worldZ,clicked)
	else
		triggerEvent ( "onClientGUIWorldClick",root,button, state,absoluteX,absoluteY,worldX,worldY,worldZ,clicked)
	end
end )

function setWorldClickEnabled ( bool )
	return editor_main.setWorldClickEnabled ( bool )
end
