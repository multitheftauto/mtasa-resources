screenWidth, screenHeight = guiGetScreenSize()

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		bindKey("lalt", "down", function(button, state) showCursor(not isCursorShowing()) end)
		addEventHandler("onClientRender", root, onDraw)
		addEventHandler("onClientClick", root, onClick)
	end
)

function onDraw()
	if isCursorShowing() then
		local posX, posY = getCursorPosition()
		posX, posY = posX * screenWidth, posY * screenHeight
		if (isPointInRect(posX, posY, 0, screenHeight - 48, 48, screenHeight)) then
			dxDrawRectangle(0, screenHeight - 48, 48, 48, tocolor(255, 255, 255, 110))
		end
	end
	dxDrawImage(0, screenHeight - 48, 48, 48, "chromiumIcon.png")
end

function onClick(button, state, posX, posY)
	if not isCursorShowing() then return end
	if button == "left" and state == "up" then
		if isPointInRect(posX, posY, 0, screenHeight - 48, 48, screenHeight) then
			showBrowser()
		end
	end
end

function isPointInRect(posX, posY, posX1, posY1, posX2, posY2)
	return (posX > posX1 and posX < posX2) and (posY > posY1 and posY < posY2)
end

function showBrowser()
	if WebBrowserGUI.instance ~= nil then return end
	WebBrowserGUI.instance = WebBrowserGUI:new()
end
