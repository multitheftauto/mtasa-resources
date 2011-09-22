function table.copy(theTable)
	local t = {}
	for k, v in pairs(theTable) do
		if type(v) == "table" then
			t[k] = table.copy(theTable)
		else
			t[k] = v
		end
	end
	return t
end

colorPicker = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 20,
		buttonWidth = .38,
		testWidth = .6,
		testHeight = 1,
		relative = false,
		value = "#ff0000ff",
		selectWindow =
		{
			width = 350,
			height = 400,
			paletteX = 18,
			paletteY = 30,
			luminanceOffset = 10,
			luminanceWidth = 15,
			alphaOffset = 25 + 17,
			alphaWidth = 15,
			rgbX = 265,
			rgbY = 300,
			rgbWidth = 50,
			rgbHeight = 21,
			hslX = 190,
			hslY = 300,
			hslWidth = 50,
			hslHeight = 21,
			historyX = 18,
			historyY = 300,
			historyWidth = 140,
			historyHeight = 80,
			noteX = 18,
			noteY = 378,
		}
	},
	constructor = function( info )
		info = info or colorPicker.default
		colorPicker.value = colorPicker.convertColorToTable(info.value)
		
		colorPicker.buttonWidth = info.width * colorPicker.default.buttonWidth

		local offset = 1 --px
		local height = 10
		local sizeX, sizeY
		if info.parent then
			sizeX, sizeY = guiGetSize(info.parent, false)
		end
		if not sizeX then
			sizeX, sizeY = guiGetScreenSize()
		end
		if info.relative then
			offset = offset / sizeX
			height = height / sizeY
		end

		colorPicker.GUI = {}
		colorPicker.children = {}
		
		-- Create the color selection window
		local screenW, screenH = guiGetScreenSize()
		colorPicker.selectWindow = info.selectWindow
		colorPicker.GUI.selectWindow = guiCreateWindow(screenW - info.selectWindow.width, (screenH - info.selectWindow.height) / 2,
		                                        info.selectWindow.width, info.selectWindow.height, "Pick a color", false)
		guiSetVisible(colorPicker.GUI.selectWindow, false)
		guiWindowSetSizable(colorPicker.GUI.selectWindow, false)

		colorPicker.GUI.palette = guiCreateStaticImage(colorPicker.selectWindow.paletteX, colorPicker.selectWindow.paletteY,
		                                        256, 256, "colorpicker/palette.png", false, colorPicker.GUI.selectWindow)
		colorPicker.GUI.alphaBar = guiCreateStaticImage(colorPicker.selectWindow.paletteX + 255 + colorPicker.selectWindow.alphaOffset, colorPicker.selectWindow.paletteY,
		                                         colorPicker.selectWindow.alphaWidth, 255, "colorpicker/alpha.png", false, colorPicker.GUI.selectWindow)
		colorPicker.isSelectOpen = false

		-- Create the RGB and HSL edit boxes
		colorPicker.children.R = guiCreateEdit(info.selectWindow.rgbX + 10, info.selectWindow.rgbY, info.selectWindow.rgbWidth, info.selectWindow.rgbHeight, tostring( colorPicker.value[1] ), false, colorPicker.GUI.selectWindow)
		guiEditSetMaxLength(colorPicker.children.R, 3)
		addEventHandler("onClientGUIChanged", colorPicker.children.R, colorPicker.forceNaturalAndRange)
		addEventHandler("onClientGUIChanged", colorPicker.children.R, colorPicker.selectionManualInputRGB)
		colorPicker.GUI.labelR = guiCreateLabel(info.selectWindow.rgbX, info.selectWindow.rgbY + 3,
		                                 10, 20, "R", false, colorPicker.GUI.selectWindow)
		guiSetFont(colorPicker.GUI.labelR, "default-bold-small")

		colorPicker.children.G = guiCreateEdit(info.selectWindow.rgbX + 10, info.selectWindow.rgbY + info.selectWindow.rgbHeight, info.selectWindow.rgbWidth, info.selectWindow.rgbHeight, tostring( colorPicker.value[2] ), false, colorPicker.GUI.selectWindow)
		guiEditSetMaxLength(colorPicker.children.G, 3)
		addEventHandler("onClientGUIChanged", colorPicker.children.G, colorPicker.forceNaturalAndRange)
		addEventHandler("onClientGUIChanged", colorPicker.children.G, colorPicker.selectionManualInputRGB)
		colorPicker.GUI.labelG = guiCreateLabel(info.selectWindow.rgbX, info.selectWindow.rgbY + 3 + info.selectWindow.rgbHeight,
		                                 10, 20, "G", false, colorPicker.GUI.selectWindow)
		guiSetFont(colorPicker.GUI.labelG, "default-bold-small")

		colorPicker.children.B = guiCreateEdit(info.selectWindow.rgbX + 10, info.selectWindow.rgbY + info.selectWindow.rgbHeight*2, info.selectWindow.rgbWidth, info.selectWindow.rgbHeight, tostring( colorPicker.value[3] ), false, colorPicker.GUI.selectWindow)
		guiEditSetMaxLength(colorPicker.children.B, 3)
		addEventHandler("onClientGUIChanged", colorPicker.children.B, colorPicker.forceNaturalAndRange)
		addEventHandler("onClientGUIChanged", colorPicker.children.B, colorPicker.selectionManualInputRGB)
		colorPicker.GUI.labelB = guiCreateLabel(info.selectWindow.rgbX, info.selectWindow.rgbY + 3 + info.selectWindow.rgbHeight*2,
		                                 10, 20, "B", false, colorPicker.GUI.selectWindow)
		guiSetFont(colorPicker.GUI.labelB, "default-bold-small")

		colorPicker.children.A = guiCreateEdit(info.selectWindow.rgbX + 10, info.selectWindow.rgbY + info.selectWindow.rgbHeight*3, info.selectWindow.rgbWidth, info.selectWindow.rgbHeight, tostring( colorPicker.value[4] ), false, colorPicker.GUI.selectWindow)
		guiEditSetMaxLength(colorPicker.children.A, 3)
		addEventHandler("onClientGUIChanged", colorPicker.children.A, colorPicker.forceNaturalAndRange)
		addEventHandler("onClientGUIChanged", colorPicker.children.A, colorPicker.selectionManualInputRGB)
		colorPicker.GUI.labelA = guiCreateLabel(info.selectWindow.rgbX - 25, info.selectWindow.rgbY + 3 + info.selectWindow.rgbHeight*3,
		                                 50, 20, "Alpha", false, colorPicker.GUI.selectWindow)
		guiSetFont(colorPicker.GUI.labelA, "default-bold-small")


		colorPicker.h, colorPicker.s, colorPicker.l = colorPicker.rgb2hsl(colorPicker.value[1] / 255, colorPicker.value[2] / 255, colorPicker.value[3] / 255)

		colorPicker.children.H = guiCreateEdit(info.selectWindow.hslX + 10, info.selectWindow.hslY, info.selectWindow.hslWidth, info.selectWindow.hslHeight, tostring( math.floor(colorPicker.h * 255) ), false, colorPicker.GUI.selectWindow)
		guiEditSetMaxLength(colorPicker.children.H, 3)
		addEventHandler("onClientGUIChanged", colorPicker.children.H, colorPicker.forceNaturalAndRange)
		addEventHandler("onClientGUIChanged", colorPicker.children.H, colorPicker.selectionManualInputHSL)
		colorPicker.GUI.labelH = guiCreateLabel(info.selectWindow.hslX, info.selectWindow.hslY + 3,
		                                 10, 20, "H", false, colorPicker.GUI.selectWindow)
		guiSetFont(colorPicker.GUI.labelH, "default-bold-small")
		
		colorPicker.children.S = guiCreateEdit(info.selectWindow.hslX + 10, info.selectWindow.hslY + info.selectWindow.hslHeight, info.selectWindow.hslWidth, info.selectWindow.hslHeight, tostring( math.floor(colorPicker.s * 255) ), false, colorPicker.GUI.selectWindow)
		guiEditSetMaxLength(colorPicker.children.S, 3)
		addEventHandler("onClientGUIChanged", colorPicker.children.S, colorPicker.forceNaturalAndRange)
		addEventHandler("onClientGUIChanged", colorPicker.children.S, colorPicker.selectionManualInputHSL)
		colorPicker.GUI.labelS = guiCreateLabel(info.selectWindow.hslX, info.selectWindow.hslY + 3 + info.selectWindow.hslHeight,
		                                 10, 20, "S", false, colorPicker.GUI.selectWindow)
		guiSetFont(colorPicker.GUI.labelS, "default-bold-small")

		colorPicker.children.L = guiCreateEdit(info.selectWindow.hslX + 10, info.selectWindow.hslY + info.selectWindow.hslHeight*2, info.selectWindow.hslWidth, info.selectWindow.hslHeight, tostring( math.floor(colorPicker.s * 255) ), false, colorPicker.GUI.selectWindow)
		guiEditSetMaxLength(colorPicker.children.L, 3)
		addEventHandler("onClientGUIChanged", colorPicker.children.L, colorPicker.forceNaturalAndRange)
		addEventHandler("onClientGUIChanged", colorPicker.children.L, colorPicker.selectionManualInputHSL)
		colorPicker.GUI.labelL = guiCreateLabel(info.selectWindow.hslX, info.selectWindow.hslY + 3 + info.selectWindow.hslHeight*2,
		                                 10, 20, "L", false, colorPicker.GUI.selectWindow)
		guiSetFont(colorPicker.GUI.labelL, "default-bold-small")

		-- Create the color history
		if not colorHistory then
			colorHistory = {}
			for i=1,9 do
				colorHistory[i] = { 255, 255, 255, 200 }
			end
		end

		colorPicker.GUI.historyLabel = guiCreateLabel(info.selectWindow.historyX, info.selectWindow.historyY,
		                                       150, 15, "Recently used colors:", false, colorPicker.GUI.selectWindow)
											   
		colorPicker.GUI.noteLabel = guiCreateLabel(info.selectWindow.noteX, info.selectWindow.noteY,
		                                       190, 15, "Click outside the window to close.", false, colorPicker.GUI.selectWindow)
		guiSetFont( colorPicker.GUI.noteLabel, "default-small" )

		colorPicker.avoidRecursion = false
	end,
	forceNaturalAndRange = function()
		local inputText = guiGetText( source )
		if not tonumber( inputText ) then
			local changedText = string.gsub( inputText, "[^%d]", "" )
			if changedText ~= inputText then
				guiSetText(source, changedText)
			end
		end
		
		local inputNumber = tonumber(guiGetText( source ))
		if inputNumber then
			local clampedNumber = inputNumber
			clampedNumber = math.max(clampedNumber, 0)
			clampedNumber = math.min(clampedNumber, 255)
			if clampedNumber ~= inputNumber then
				guiSetText(source, tostring(clampedNumber))
			end
		end
	end,
	setValue = function( value )
		colorPicker.value = colorPicker.convertColorToTable(value)

		colorPicker.updateTempColors()
		local avoidRecursion = colorPicker.avoidRecursion
		colorPicker.avoidRecursion = true
		colorPicker.updateSelectionWindowEdits()
		colorPicker.avoidRecursion = avoidRecursion

		return true
	end,
	selectionManualInputRGB = function()
		if not colorPicker.avoidRecursion then
			colorPicker.avoidRecursion = true
			local r, g, b, a = 	tonumber(guiGetText(colorPicker.children.R)),
								tonumber(guiGetText(colorPicker.children.G)),
								tonumber(guiGetText(colorPicker.children.B)),
								tonumber(guiGetText(colorPicker.children.A))
			if not r or not g or not b or not a then
				colorPicker.avoidRecursion = false
				return
			end
			colorPicker.h, colorPicker.s, colorPicker.l = colorPicker.rgb2hsl(r / 255, g / 255, b / 255)
			colorPicker.setValue({r, g, b, a})
			colorPicker.avoidRecursion = false
		end
	end,
	selectionManualInputHSL = function()
		if not colorPicker.avoidRecursion then
			colorPicker.avoidRecursion = true
			local h, s, l = tonumber(guiGetText(colorPicker.children.H)),
			                tonumber(guiGetText(colorPicker.children.S)),
							tonumber(guiGetText(colorPicker.children.L))
			if not h or not s or not l then
				colorPicker.avoidRecursion = false
				return
			end
			colorPicker.h, colorPicker.s, colorPicker.l = h / 255, s / 255, l / 256
			local r, g, b = colorPicker.hsl2rgb(colorPicker.h, colorPicker.s, colorPicker.l)
			colorPicker.setValue({r * 255, g * 255, b * 255, colorPicker.value[4]})
			colorPicker.avoidRecursion = false
		end
	end,
	updateSelectionWindowEdits = function()
		guiSetText(colorPicker.children.R, tostring(colorPicker.value[1]))
		guiSetText(colorPicker.children.G, tostring(colorPicker.value[2]))
		guiSetText(colorPicker.children.B, tostring(colorPicker.value[3]))
		guiSetText(colorPicker.children.A, tostring(colorPicker.value[4]))
		guiSetText(colorPicker.children.H, tostring(math.floor(colorPicker.h * 255)))
		guiSetText(colorPicker.children.S, tostring(math.floor(colorPicker.s * 255)))
		guiSetText(colorPicker.children.L, tostring(math.floor(colorPicker.l * 256)))
	end,
	updateTempColors = function()
		local r, g, b, a = colorPicker.value[1], colorPicker.value[2], colorPicker.value[3], colorPicker.value[4]
		tempColors[colorPicker.currentColor].r = r
		tempColors[colorPicker.currentColor].g = g
		tempColors[colorPicker.currentColor].b = b
		tempColors[colorPicker.currentColor].a = a
	end,
	openSelect = function( currentColor )
		if colorPicker.isSelectOpen then return end
		colorPicker.currentColor = currentColor
		local r, g, b, a = tempColors[currentColor].r, tempColors[currentColor].g, tempColors[currentColor].b, tempColors[currentColor].a
		colorPicker.setValue( { r, g, b, a } )

		guiSetVisible(colorPicker.GUI.selectWindow, true)
		guiBringToFront(colorPicker.GUI.selectWindow)
		addEventHandler("onClientRender", getRootElement(), colorPicker.updateSelectedValue)
		addEventHandler("onClientClick", getRootElement(), colorPicker.pickColor)

		colorPicker.isSelectOpen = true
		colorPicker.pickingColor = false
		colorPicker.pickingLuminance = false
		colorPicker.pickingAlpha = false
		colorPicker.h, colorPicker.s, colorPicker.l = colorPicker.rgb2hsl(colorPicker.value[1] / 255, colorPicker.value[2] / 255, colorPicker.value[3] / 255)
	end,
	closeSelect = function()
		if not colorPicker.isSelectOpen then return end
		colorPicker.currentColor = nil

		guiSetVisible(colorPicker.GUI.selectWindow, false)
		removeEventHandler("onClientRender", getRootElement(), colorPicker.updateSelectedValue)
		removeEventHandler("onClientClick", getRootElement(), colorPicker.pickColor)

		colorPicker.isSelectOpen = false

		colorPicker.addCurrentColorToHistory()
	end,
	addCurrentColorToHistory = function()
		-- First look up in color history to check if the
		-- current color is already present there
		for i=1,9 do
			local color = colorHistory[i]
			if color[1] == colorPicker.value[1] and
			   color[2] == colorPicker.value[2] and
			   color[3] == colorPicker.value[3] and
			   color[4] == colorPicker.value[4]
			then
				return
			end
		end

		-- Pop the last color and insert the new value
		table.remove(colorHistory)
		table.insert(colorHistory, 1, table.copy(colorPicker.value))
	end,
	updateSelectedValue = function()
		if not guiGetVisible(colorPicker.GUI.selectWindow) then return end

		local r, g, b, a

		-- Check for color changes
		local wx, wy = guiGetPosition(colorPicker.GUI.selectWindow, false)
		local paletteX, paletteY = wx + colorPicker.selectWindow.paletteX, wy + colorPicker.selectWindow.paletteY
		local luminanceX, luminanceY = paletteX + 255 + colorPicker.selectWindow.luminanceOffset, paletteY
		local alphaX, alphaY = paletteX + 255 + colorPicker.selectWindow.alphaOffset - 1, paletteY
		local cursorX, cursorY = getCursorPosition()
		local screenW, screenH = guiGetScreenSize()

		cursorX = cursorX * screenW
		cursorY = cursorY * screenH

		if colorPicker.pickingColor then
			if cursorX < paletteX then cursorX = paletteX
			elseif cursorX > paletteX + 255 then cursorX = paletteX + 255 end
			if cursorY < paletteY then cursorY = paletteY
			elseif cursorY > paletteY + 255 then cursorY = paletteY + 255 end

			setCursorPosition(cursorX, cursorY)

			colorPicker.h, colorPicker.s  = (cursorX - paletteX) / 255, (255 - cursorY + paletteY) / 255
			r, g, b = colorPicker.hsl2rgb(colorPicker.h, colorPicker.s, colorPicker.l)
			a = colorPicker.value[4] / 255
			colorPicker.avoidRecursion = true
			colorPicker.setValue({r*255, g*255, b*255, colorPicker.value[4]})
			colorPicker.avoidRecursion = false
		elseif colorPicker.pickingLuminance then
			if cursorY < luminanceY then cursorY = luminanceY
			elseif cursorY > luminanceY + 256 then cursorY = luminanceY + 256 end

			setCursorPosition(cursorX, cursorY)

			colorPicker.l = (256 - cursorY + luminanceY) / 256
			r, g, b = colorPicker.hsl2rgb(colorPicker.h, colorPicker.s, colorPicker.l)
			a = colorPicker.value[4] / 255
			colorPicker.avoidRecursion = true
			colorPicker.setValue({r*255, g*255, b*255, colorPicker.value[4]})
			colorPicker.avoidRecursion = false
		elseif colorPicker.pickingAlpha then
			if cursorY < alphaY then cursorY = alphaY
			elseif cursorY > alphaY + 255 then cursorY = alphaY + 255 end

			setCursorPosition(cursorX, cursorY)

			colorPicker.avoidRecursion = true
			colorPicker.setValue({colorPicker.value[1], colorPicker.value[2], colorPicker.value[3], cursorY - alphaY})
			colorPicker.avoidRecursion = false
			r, g, b, a = colorPicker.value[1] / 255, colorPicker.value[2] / 255, colorPicker.value[3] / 255, colorPicker.value[4] / 255
		else
			r, g, b, a = colorPicker.value[1] / 255, colorPicker.value[2] / 255, colorPicker.value[3] / 255, colorPicker.value[4] / 255
		end
		
		-- Draw the lines pointing to the current selected color
		local x = paletteX + (colorPicker.h * 255)
		local y = paletteY + ((1 - colorPicker.s) * 255)
		local color = tocolor(0, 0, 0, 255)

		dxDrawLine(x - 12, y, x - 2, y, color, 3, true)
		dxDrawLine(x + 2, y, x + 12, y, color, 3, true)
		dxDrawLine(x, y - 12, x, y - 2, color, 3, true)
		dxDrawLine(x, y + 2, x, y + 12, color, 3, true)

		-- Draw the luminance for this color
		local i
		for i=0,256 do
			local _r, _g, _b = colorPicker.hsl2rgb(colorPicker.h, colorPicker.s, (256 - i) / 256)
			local color = tocolor(_r * 255, _g * 255, _b * 255, 255)
			dxDrawRectangle(luminanceX, luminanceY + i, colorPicker.selectWindow.luminanceWidth, 1, color, true)
		end

		-- Draw the luminance position marker
		local arrowX = luminanceX + colorPicker.selectWindow.luminanceWidth + 4
		local arrowY = luminanceY + ((1 - colorPicker.l) * 256)
		dxDrawLine(arrowX, arrowY, arrowX + 8, arrowY, tocolor(255, 255, 255, 255), 2, true)

		-- Draw the alpha for this color
		for i=0,255 do
			local color = tocolor(colorPicker.value[1], colorPicker.value[2], colorPicker.value[3], i)
			dxDrawRectangle(alphaX, alphaY + i, colorPicker.selectWindow.alphaWidth + 1, 1, color, true)
		end

		-- Draw the alpha position marker
		arrowX = alphaX + colorPicker.selectWindow.alphaWidth + 4
		arrowY = alphaY + colorPicker.value[4]
		dxDrawLine(arrowX, arrowY, arrowX + 8, arrowY, tocolor(255, 255, 255, 255), 2, true)

		-- Draw the recently used colors
		local boxWidth = (colorPicker.selectWindow.historyWidth - 15) / 3
		local boxHeight = (colorPicker.selectWindow.historyHeight - 45) / 3
		for i=1,3 do
		  for j=1,3 do
		  	local color = colorHistory[j + ((i - 1) * 3)]
		  	local x = wx + colorPicker.selectWindow.historyX + ((boxWidth + 5) * (j-1))
			local y = wy + colorPicker.selectWindow.historyY + 30 + ((boxHeight + 5) * (i-1))
			dxDrawRectangle(x, y, boxWidth, boxHeight, tocolor(unpack(color)), true)
		  end
		end
	end,
	isCursorInArea = function( cursorX, cursorY, minX, minY, maxX, maxY )
		if cursorX < minX or cursorX > maxX or
		   cursorY < minY or cursorY > maxY
		then
			return false
		end
		return true
	end,
	pickColor = function( button, state, cursorX, cursorY )
		if button ~= "left" then return end

		local wx, wy = guiGetPosition(colorPicker.GUI.selectWindow, false)
		local ww, wh = guiGetSize(colorPicker.GUI.selectWindow, false)

		local isOutsideWindow = not colorPicker.isCursorInArea(cursorX, cursorY, wx, wy, wx+ww, wy+wh)

		local minX, minY, maxX, maxY = wx + colorPicker.selectWindow.paletteX,
		                               wy + colorPicker.selectWindow.paletteY,
					       wx + colorPicker.selectWindow.paletteX + 255,
					       wy + colorPicker.selectWindow.paletteY + 255
		local isInPalette = colorPicker.isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)

		minX, maxX = maxX + colorPicker.selectWindow.luminanceOffset,
		             maxX + colorPicker.selectWindow.luminanceOffset + colorPicker.selectWindow.luminanceWidth + 12
		maxY = maxY + 1
		local isInLuminance = colorPicker.isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)
		maxY = maxY - 1

		minX, maxX = wx + colorPicker.selectWindow.paletteX + 255 + colorPicker.selectWindow.alphaOffset,
		             wx + colorPicker.selectWindow.paletteX + 255 + colorPicker.selectWindow.alphaOffset + colorPicker.selectWindow.alphaWidth + 12
		local isInAlpha = colorPicker.isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)

		minX, minY, maxX, maxY = wx + colorPicker.selectWindow.historyX,
		                         wy + colorPicker.selectWindow.historyY,
					 wx + colorPicker.selectWindow.historyX + colorPicker.selectWindow.historyWidth,
					 wy + colorPicker.selectWindow.historyY + colorPicker.selectWindow.historyHeight
		local isInHistory = colorPicker.isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)

		if state == "down" then
			if isOutsideWindow then
				colorPicker.closeSelect()
			elseif isInPalette then
				colorPicker.pickingColor = true
			elseif isInLuminance then
				colorPicker.pickingLuminance = true
			elseif isInAlpha then
				colorPicker.pickingAlpha = true
			elseif isInHistory then
				colorPicker.pickHistory(cursorX - minX, cursorY - minY)
			end
		elseif state == "up" then
			if colorPicker.pickingColor then
				colorPicker.pickingColor = false
			elseif colorPicker.pickingLuminance then
				colorPicker.pickingLuminance = false
			elseif colorPicker.pickingAlpha then
				colorPicker.pickingAlpha = false
			end
		end
	end,
	pickHistory = function( cursorX, cursorY)
		local relX = cursorX
		local relY = cursorY - 25

		if relX < 0 or relY < 0 then return end

		local boxWidth = (colorPicker.selectWindow.historyWidth - 15) / 3
		local boxHeight = (colorPicker.selectWindow.historyHeight - 45) / 3

		local modX = relX % (boxWidth + 5)
		local modY = relY % (boxHeight + 5)

		if modX > boxWidth or modY > boxHeight then return end

		local j = math.floor(relX / (boxWidth + 5))
		local i = math.floor(relY / (boxHeight + 5))
		local box = j + 1 + i * 3

		if box < 1 or box > #colorHistory then return end
		local color = colorHistory[box]
		colorPicker.h, colorPicker.s, colorPicker.l = colorPicker.rgb2hsl(color[1] / 255, color[2] / 255, color[3] / 255)
		colorPicker.avoidRecursion = true
		colorPicker.setValue(color)
		colorPicker.avoidRecursion = false
	end,
	convertColorToTable = function( color )
		local result

		if type(color) == "string" then
			result = {getColorFromString(color)}
		elseif type(color) == "number" then
			local str
			if color > 0xFFFFFF then
				-- RGBA color
				str = "#" .. string.format("%08X", color)
			else
				-- RGB color
				str = "#" .. string.format("%06X", color)
			end
			result = {getColorFromString(str)}
		elseif type(color) == "table" then
			result = color
		else
			result = { 255, 255, 255, 255 }
		end

		local checkValue = function(value)
		                     if not value then return 255 end
				     value = math.floor(tonumber(value))
		                     if value < 0 then return 0
		                     elseif value > 255 then return 255
		                     else return value end
		                  end
		result[1] = checkValue(result[1])
		result[2] = checkValue(result[2])
		result[3] = checkValue(result[3])
		result[4] = checkValue(result[4])

		return result
	end,
	hsl2rgb = function(h, s, l)
		local m2
		if l < 0.5 then
			m2 = l * (s + 1)
		else
			m2 = (l + s) - (l * s)
		end
		local m1 = l * 2 - m2

		local hue2rgb = function(m1, m2, h)
			if h < 0 then h = h + 1
			elseif h > 1 then h = h - 1 end

			if h*6 < 1 then
				return m1 + (m2 - m1) * h * 6
			elseif h*2 < 1 then
				return m2
			elseif h*3 < 2 then
				return m1 + (m2 - m1) * (2/3 - h) * 6
			else
				return m1
			end
		end

		local r = hue2rgb(m1, m2, h + 1/3)
		local g = hue2rgb(m1, m2, h)
		local b = hue2rgb(m1, m2, h - 1/3)
		return r, g, b
	end,
	rgb2hsl = function(r, g, b)
		local max = math.max(r, g, b)
		local min = math.min(r, g, b)
		local l = (min + max) / 2
		local h
		local s

		if max == min then
			h = 0
			s = 0
		else
			local d = max - min

			if l < 0.5 then
				s = d / (max + min)
			else
				s = d / (2 - max - min)
			end

			if max == r then
				h = (g - b) / d
				if g < b then h = h + 6 end
			elseif max == g then
				h = (b - r) / d + 2
			else
				h = (r - g) / d + 4
			end

			h = h / 6
		end

		return h, s, l
	end,
}