--GUI's onClientMouseMove is flawed in the fact that it does not trigger when you move your mouse without a gui element on top
--this script works around that for the highlighter when the mouse is not on top of gui
--it also provides a guiGetMouseOverElement to retrieve the current mouse over element.
local worldDetector
function createWorldDetector()
	worldDetector = guiCreateProgressBar ( 0,0,1,1,true )
	guiSetAlpha ( worldDetector, 0 )
	guiMoveToBack( worldDetector )
	addEventHandler ( "onClientGUIWorldClick",worldDetector,function()
	if source == worldDetector or source == root then
	guiMoveToBack(worldDetector) end end )
end

local mouseOverElement = false
addEventHandler ( "onClientMouseMove", root,
function ( cursorX, cursorY )
	if not isGUICreated then return end
	if source == worldDetector then
		hideHighlighter()
		mouseOverElement = false
	else
		showHighlighter(source)
		mouseOverElement = source
	end
end )

function guiGetMouseOverElement()
	return mouseOverElement
end

