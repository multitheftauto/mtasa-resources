TextStuff = {}


function refreshString(text,id,update)
	if TextStuff[id] and text then
		TextStuff[id]['text'] = text
		TextStuff[id]['width'] = string.len(text)
		TextStuff[id][2] = {}
		TextStuff[id][2][0] = 0
		for i=1,string.len(text) do
			TextStuff[id][2][i] = dxGetTextWidth(string.sub(text,1,i),TextStuff[id]['font'][1],TextStuff[id]['font'][2])
		end
		if update then
			TextStuff[id][1] = text
		end
	end
end

countEE = 0

glow = 0
backcount = 40
function dxDrawEditBox(x,y,w,h,fs,f,fc,id,text,Type,ebc,dc)--x,y,width,height,font size,font,font color,default text,type,edit box color,dashcolor

	TextStuff[id] = TextStuff[id] or {}
	TextStuff[id]['Type'] = Type and 2 or 1
	TextStuff[id]['font'] = {fs,f}

	countEE = countEE + 1
	if not (TextStuff[id][1] == text) then
		refreshString(text,id,true)
	end
	TextStuff[id][3] = {x+(5*s),y,w,h}

	dxDrawRectangle(x,y,w,h,ebc or tocolor(255,255,255, 180), true)
	dxDrawText( TextStuff[id]['text'],x+(5*s),y,x+w,y+h,fc,fs,f,"left", "center", true, false, true, false, false)

	glow = glow + 0.1

	if glow == 20 then
		glow = -20
	end

	if isCursorShowing() then
		if TextStuff[id]['Selected'] then
			local width = TextStuff[id][2][TextStuff[id]['Selected']]
			if width then
				if (x+width+(5*s)) < (x+w) then
					local r,g,b = unpack(dc or {0,0,0})
					dxDrawRectangle(x+width+(5*s),y,1*s,h, tocolor(r,g,b, math.max(glow,0)*12.75), false)
				end
			end
		end
	end

	if getKeyState('backspace') then
		backcount = backcount - 1
		if backcount == 1 then
			dxEdit('backspace',nil,true)
		end
	end

	return TextStuff[id]['text']
end



allowed = {}
allowed['+'] = '+'
allowed['*'] = '*'
allowed['-'] = '-'
allowed['/'] = '/'
allowed['x'] = '*'
allowed['.'] = '.'


function doMath(input)

	local stg = tostring(input)
	for i,v in pairs(allowed) do
		local splt = split (stg,v)
		local A = tonumber(splt[1])
		local B = tonumber(splt[2])

		if A and B then
			if v == '+' then
				return tostring(A+B)
			elseif v == '*' then
				return tostring(A*B)
			elseif v == '-' then
				return tostring(A-B)
			elseif v == '/' then
				return tostring(A/B)
			end
		end
	end
end




function dxEdit(button,real)
	if EditSelected then
		if true then --functions.isCursorOnElement(unpack(TextStuff[EditSelected][3])) then
			toggleControl ('chatbox',false)
			if TextStuff[EditSelected]['Selected'] then
				local stringE = TextStuff[EditSelected]['text']
				if string.lower(button) == 'arrow_l' then
					TextStuff[EditSelected]['Selected'] = math.max(TextStuff[EditSelected]['Selected']-1,0)
				elseif string.lower(button) == 'arrow_r' then
					TextStuff[EditSelected]['Selected'] = TextStuff[EditSelected]['Selected']+1
				elseif (string.lower(button) == 'backspace') then
					backcount = 40
					if TextStuff[EditSelected]['Selected'] > 0 then
						local a = string.sub(stringE,1,TextStuff[EditSelected]['Selected']-1)
						local b = string.sub(stringE,TextStuff[EditSelected]['Selected']+1,-1)
						refreshString(a..b,EditSelected)
						TextStuff[EditSelected]['Selected'] = math.max(TextStuff[EditSelected]['Selected']-1,0)
					end
				else
					if TextStuff[EditSelected]['Type'] == 2 then
						if real == '=' or real == 'enter' then
							refreshString(doMath(TextStuff[EditSelected]['text']) or TextStuff[EditSelected]['text'],EditSelected)
							TextStuff[EditSelected]['Selected'] = string.len(TextStuff[EditSelected]['text'])
						end
						button = tonumber(button) or allowed[button]
					end

					local stringE = TextStuff[EditSelected]['text']

					if (not (button == '')) and button then

						local a = string.sub(stringE,1,TextStuff[EditSelected]['Selected'])..button
						local b = string.sub(stringE,TextStuff[EditSelected]['Selected']+1,-1)

						if string.len(a..b) < 30 then -- Need to make it so you set it when creating edit box!
							refreshString(a..b,EditSelected)
							TextStuff[EditSelected]['Selected'] = TextStuff[EditSelected]['Selected']+1
						end
					elseif (real == '=' or real == 'enter') then
						triggerEvent ( "onDxEdit", root,EditSelected,TextStuff[EditSelected]['text'])
					end
				end
			end
		else
			toggleControl ('chatbox',true)
		end
	end
end

-- This is triggered from Colorpicker.lua, don't kill me please.
function clickToSet(xA,yA)

	for ia,va in pairs(TextStuff) do
		va['Selected'] = nil
	end

	local currentlySelected = (EditSelected)

	for iA,v in pairs(TextStuff) do
		local x,y,w,h = unpack(v[3])
		if functions.isCursorOnElement(x,y,w,h) then
			EditSelected = iA
			local xB = xA-x -- This'll get our offset from the right.
			local distance = 100
			local selected = 26
			for i,vA in pairs(v[2]) do
				if math.max(-(vA-xB),vA-xB) < distance then
					distance = math.max(-(vA-xB),vA-xB)
					selected = i
					TextStuff[iA]['Selected'] = i
				end
			end

			if not (EditSelected == currentlySelected) then
				if currentlySelected then
					triggerEvent ( "onDxEdit", root,currentlySelected,TextStuff[currentlySelected]['text'])
				end
			end
			return
		end
	end

	if not (EditSelected == currentlySelected) then
		if currentlySelected then
			triggerEvent ( "onDxEdit", root,currentlySelected,TextStuff[currentlySelected]['text'])
		end
	end

	toggleControl ('chatbox',true)
	EditSelected = nil
end

