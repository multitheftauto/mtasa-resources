colorpicker = {colorbar = {0,0,0,nil,nil,"#FFFFFF"},color = {255,0,0,nil},text = nil}


function hex2rgb(hex)
	if string.len(hex) == 7 then
		local hex = hex:gsub("#","")
		if(string.len(hex) == 3) then
			return tonumber("0x"..hex:sub(1,1)) * 17, tonumber("0x"..hex:sub(2,2)) * 17, tonumber("0x"..hex:sub(3,3)) * 17
		elseif(string.len(hex) == 6) then
			return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
		end
	end
end

function rgb2hex(r,g,b)

	local hex_table = {[10] = 'A',[11] = 'B',[12] = 'C',[13] = 'D',[14] = 'E',[15] = 'F'}

	local r1 = math.floor(r / 16)
	local r2 = r - (16 * r1)
	local g1 = math.floor(g / 16)
	local g2 = g - (16 * g1)
	local b1 = math.floor(b / 16)
	local b2 = b - (16 * b1)

	if r1 > 9 then r1 = hex_table[r1] end
	if r2 > 9 then r2 = hex_table[r2] end
	if g1 > 9 then g1 = hex_table[g1] end
	if g2 > 9 then g2 = hex_table[g2] end
	if b1 > 9 then b1 = hex_table[b1] end
	if b2 > 9 then b2 = hex_table[b2] end

	if r1 and r2 and g1 and g2 and b1 and b2 then
		return "#" .. r1 .. r2 .. g1 .. g2 .. b1 .. b2
	end
end


functions.ColorPicker = function(what)
	colorpicker[what] = not colorpicker[what]
end




HexChart = {A=true,B=true,C=true,D=true,F=true}

function editBoxC(input,key)
	local table = colorpicker.colorbar

	if input == 'R' then
		local value = table[1] or 0
		if tonumber(key) then
			if string.len (value) < 4 then
				table[1] = math.min(value..key,255)
			end
		elseif key == 'backspace' then
			table[1] = tonumber(tostring(value):sub(1, -2))
		end
		table[6] = rgb2hex(math.floor(table[1] or 0),math.floor(table[2] or 0),math.floor(table[3] or 0))
	elseif input == 'G' then
		local value = table[2] or 0
		if tonumber(key) then
			if string.len (value) < 4 then
				table[2] = math.min(value..key,255)
			end
		elseif key == 'backspace' then
			table[2] = tonumber(tostring(value):sub(1, -2))
		end
		table[6] = rgb2hex(math.floor(table[1] or 0),math.floor(table[2] or 0),math.floor(table[3] or 0))
	elseif input == 'B' then
		local value = table[3] or 0
		if tonumber(key) then
			if string.len (value) < 4 then
				table[3] = math.min(value..key,255)
			end
		elseif key == 'backspace' then
			table[3] = tonumber(tostring(value):sub(1, -2))
		end
		table[6] = rgb2hex(math.floor(table[1] or 0),math.floor(table[2] or 0),math.floor(table[3] or 0))
	elseif input == 'Hex' then
		local value = table[6] or 0
		if HexChart[string.upper(key)] or tonumber(key)	then
			if string.len (value) < 7 then
				table[6] = value..string.upper(key)
			end
		elseif key == 'backspace' then
			if string.len (value) > 1 then
				table[6] = (tostring(value):sub(1, -2))
			end
		end

		local r,g,b = hex2rgb(table[6])

		if r then
			table[1] = r
			table[2] = g
			table[3] = b
		end
	end
end


colorpicker.cfunction = function ()
colorpicker.start = (xSize-(590*s))--984

local start = colorpicker.start

local arrow = functions.isCursorOnElement(start+(256*s), 39*s, 12*s, 12*s,'ColorPicker','Arrow')
local closE = functions.isCursorOnElement(start+(277*s), 39*s, 12*s, 12*s,'ColorPicker','Open')
local aColor = (arrow and 150 or 255)
local cColor = (closE and 150 or 255)
dxDrawRectangle(start, 33*s, 304*s, 24*s, tocolor(62, 62, 62, 130), false)
dxDrawText("Color Picker", start+(10*s), 33*s, start+(304*s), 57*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, true, false, false, false)

dxDrawImage(start+(256*s), 39*s, 12*s, 12*s,functions.prepImage('arrow'), colorpicker['Arrow'] and -90 or 0, 0, 0, tocolor(aColor, aColor, aColor,aColor), true)
functions.isCursorOnElement(start+(256*s), 39*s, 12*s, 12*s,'ColorPicker','Arrow')


	dxDrawImage(start+(277*s), 39*s, 12*s, 12*s,functions.prepImage('close'), 0, 0, 0, tocolor(cColor, cColor, cColor, cColor), true)

	if colorpicker['Arrow'] then

		dxDrawRectangle(start, 58*s, 304*s, 202*s, tocolor(0, 0, 0, 141), false)

		local r,g,b,hA = unpack(colorpicker.color)
		local ra,ga,ba,wB,hB,hex = unpack(colorpicker.colorbar)



		local A = functions.isCursorOnElement(start+(236)*s, 222*s, 61*s, 24*s)
		dxDrawRectangle(start+(236)*s, 222*s, 61*s, 24*s, tocolor(46, 46, 46, A and 100 or 177), false)
		dxDrawText(hex or "", start+(234)*s, 222*s, start+(295)*s, 246*s, tocolor(255, 255, 255, 177), 1.00*s, "default", "center", "center", false, true, false, false, false)
		if A then
			colorpicker.text = 'Hex'
		end

		local B = functions.isCursorOnElement(start+(234*s), 62*s, 61*s, 24*s)
		if B then
			colorpicker.text = 'R'
		end
		dxDrawRectangle(start+(234*s), 62*s, 61*s, 24*s, tocolor(46, 46, 46, B and 100 or 177), false)
		dxDrawText(math.floor(ra or 0), start+(234*s), 62*s, start+(295*s), 86*s, tocolor(255, 255, 255, 177), 1.00*s, "default", "center", "center", false, true, false, false, false)

		local C = functions.isCursorOnElement(start+(234*s), 92*s, 61*s, 24*s)
		if C then
			colorpicker.text = 'G'
		end
		dxDrawRectangle(start+(234*s), 92*s, 61*s, 24*s, tocolor(46, 46, 46, C and 100 or 177), false)
		dxDrawText(math.floor(ga or 0), start+(234*s), 92*s, start+(295*s), 116*s, tocolor(255, 255, 255, 177), 1.00*s, "default", "center", "center", false, true, false, false, false)

		local D = functions.isCursorOnElement(start+(234*s), 122*s, 61*s, 24*s)
		if D then
			colorpicker.text = 'B'
		end
		dxDrawRectangle(start+(234*s), 122*s, 61*s, 24*s, tocolor(46, 46, 46, D and 100 or 177), false)
		dxDrawText(math.floor(ba or 0), start+(234*s), 122*s, start+(295*s), 146*s, tocolor(255, 255, 255, 177), 1.00*s, "default", "center", "center", false, true, false, false, false)

		if not (A or B or C or D) then
			colorpicker.text = nil
		end

		dxDrawRectangle(start+(234*s), 152*s, 61*s, 24*s, tocolor(ra,ga,ba, 255), false)

		sv = functions.prepImage('sv')
		dxDrawRectangle(start+(5*s), 63*s, 193*s, 193*s, tocolor(r,g,b), false)
		dxDrawImage(start+(5*s), 63*s, 193*s, 193*s, sv, 0, 0, 0, tocolor(255, 255, 255, 255), true)

		h = functions.prepImage('h')
		dxDrawImage(start+(201*s), 62*s, 25*s, 194*s, h, 0, 0, 0, tocolor(255, 255, 255, 255), true)
		if hA then
			dxDrawImage(start+(196*s), hA-(6.25*s), 35*s, 12.5*s,functions.prepImage('cursor'), 0, 0, 0, tocolor(255, 255, 255, 255), true)
		end
		if wB then
			dxDrawImage(wB-(6.25*s),hB-(6.25*s), 12.5*s, 12.5*s,functions.prepImage('cursor2'), 0, 0, 0, tocolor(255, 255, 255, 255), true)
		end
	end
end


function trigger ( _,_,x, y,_,_,_,ignore )
	if SelectedA then
		SelectedA = getKeyState('mouse1')
	end

	if SelectedB then
		SelectedB = getKeyState('mouse1')
	end

	if colorpicker['Arrow'] then
		if getKeyState('mouse1') then

			if (not ignore) and (not SelectedB) then
				if functions.isCursorOnElement(colorpicker.start+(201*s), 0, 25*s, 300*s) and ((not SelectedB) or ignore) then
					SelectedA = true
					local total = (256/(194*s))
					local offset = (y-(62*s))*total
					local r,g,b,a = dxGetPixelColor(dxGetTexturePixels(h),0,offset)

					if r then
						colorpicker.color = {r,g,b,y}

						local _,_,_,xA,yA = unpack(colorpicker.colorbar)
						if tonumber(xA) then
							trigger ( nil,nil,xA, yA,nil,nil,nil,true)
						end
					end
				end
			end

			if ((ignore) or functions.isCursorOnElement(colorpicker.start+(5*s), 63*s, 193*s, 193*s)) and ((not SelectedA) or ignore) then
				SelectedB = not ignore
				local totalx,totaly = (256/(193*s)),(256/(193*s))
				local offsetx,offsety = (x-(colorpicker.start+(5*s)))*totalx,(y-(62*s))*totaly
				local r,g,b,a = dxGetPixelColor(dxGetTexturePixels(sv),offsetx,offsety)
				if r then
					local ab = 255-a
					local r,g,b = (r/255)*a,(g/255)*a,(b/255)*a
					local rA,gA,bA = unpack(colorpicker.color)
					local ra,ga,ba = (rA/255)*ab ,(gA/255)*ab ,(bA/255)*ab
					local hex = rgb2hex(math.floor(ra),math.floor(ga),math.floor(ba))
					colorpicker.colorbar = {ra+r,ga+g,ba+b,x,y,hex}
				end
			end
		end
	end
end

addEventHandler( "onClientCursorMove", getRootElement( ),trigger)


function addLabelOnClick ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	if state then
		trigger(nil,nil,absoluteX,absoluteY)
		clickToSet(absoluteX,absoluteY)
	end
end
addEventHandler ( "onClientClick", getRootElement(), addLabelOnClick )