

aColor = {
	Form = nil,
	Color = {
		r = 0,
		g = 0,
		b = 0,
		h = 0,
		s = 0
	},
	Picking = false,
	Thread = nil
}

function aColor.Open ( x, y, r, g, b, relative, parent )
	local sx, sy = guiGetScreenSize ()
	if ( not x or not y ) then
		x, y = getCursorPosition ()
		x = sx * x
		y = sy * y
	else
		if ( relative ) then
			if ( parent ) then
				local px, py = guiGetSize ( parent, false )
				x = px * x
				x = py * y
			else
				x = sx * x
				y = sy * y
			end
		end
		if ( parent ) then
			while ( parent ~= nil ) do
				local px, py = guiGetPosition ( parent, false )
				x = px + x
				y = py + y
				parent = getElementParent ( parent )
			end
		end
	end
	x = x - 1
	y = y - 1
	if ( r and g and b ) then
		aColor.Color.r = math.floor ( r ) % 256
		aColor.Color.g = math.floor ( g ) % 256
		aColor.Color.b = math.floor ( b ) % 256
	else
		aColor.Color = { r = 255, g = 0, b = 0 }
	end
	aColor.Color.h, aColor.Color.s = aColor.rgb2hs ( aColor.Color.r, aColor.Color.g, aColor.Color.b )

	if ( not aColor.Form ) then
		aColor.Form		= guiCreateStaticImage ( x, y, 210, 138, "client/images/black.png", false )
					  guiSetAlpha ( aColor.Form, 0.6 )
		aColor.Palette	= guiCreateStaticImage ( 5, 5, 128, 128, "client/images/palette.png", false, aColor.Form )
					  guiCreateLabel ( 138, 37, 10, 20, "R:", false, aColor.Form )
					  guiCreateLabel ( 138, 57, 10, 20, "G:", false, aColor.Form )
					  guiCreateLabel ( 138, 77, 10, 20, "B:", false, aColor.Form )
		aColor.R		= guiCreateEdit ( 155, 35, 50, 20, "", false, aColor.Form )
		aColor.G		= guiCreateEdit ( 155, 55, 50, 20, "", false, aColor.Form )
		aColor.B		= guiCreateEdit ( 155, 75, 50, 20, "", false, aColor.Form )
		aColor.Ok		= guiCreateButton ( 155, 113, 50, 20, "ok", false, aColor.Form )
		guiSetProperty ( aColor.Form, "AlwaysOnTop", "true" )

		aRegister ( "Color", aColor.Form, aColor.Open, aColor.Close )
	end

	guiSetText ( aColor.R, tostring ( aColor.Color.r ) )
	guiSetText ( aColor.G, tostring ( aColor.Color.g ) )
	guiSetText ( aColor.B, tostring ( aColor.Color.b ) )

	aColor.Picking = false
	guiSetVisible ( aColor.Form, true )

	addEventHandler ( "onClientRender", getRootElement(), aColor.onRender )
	addEventHandler ( "onClientGUIChanged", aColor.Form, aColor.onChanged )
	addEventHandler ( "onClientGUIBlur", aColor.Form, aColor.onBlur )
	setTimer ( function () -- some hack for window not to get insta closed if opened in click handler
		if ( aColor.Form and guiGetVisible ( aColor.Form ) ) then
			guiBringToFront ( aColor.Form )
			addEventHandler ( "onClientClick", getRootElement(), aColor.onClick )
		end
	end, 50, 1 )

	aColor.Thread = sourceCoroutine
	coroutine.yield ()
	aColor.Thread = nil
	return aColor.Color.r, aColor.Color.g, aColor.Color.b
end

function aColor.Close ( destroy )
	guiSetInputEnabled ( false )
	if ( aColor.Form ) then
		removeEventHandler ( "onClientGUIBlur", aColor.Form, aColor.onBlur )
		removeEventHandler ( "onClientGUIChanged", aColor.Form, aColor.onChanged )
		removeEventHandler ( "onClientClick", getRootElement(), aColor.onClick )
		removeEventHandler ( "onClientRender", getRootElement(), aColor.onRender )
		if ( destroy ) then
			destroyElement ( aColor.Form )
			aColor.Form = nil
		else
			guiSetVisible ( aColor.Form, false )
		end
		if ( aColor.Thread ) then
			coroutine.resume ( aColor.Thread )
		end
	end
end

function aColor.onClick ( button, state, x, y )
	local px, py = guiGetPosition ( aColor.Form, false )
	if ( state == "up" ) then
		if ( aColor.Picking ) then
			aColor.Picking = false
			return
		end

		local sx, sy = guiGetSize ( aColor.Form, false )
		if ( x < px or x > px + sx ) or ( y < py or y > py + sy ) then
			aColor.Close ()
			return
		end
	end
	if ( button ~= "left" ) then
		return
	end
	if ( x >= px + 5 and x <= px + 133 ) and
	   ( y >= py + 5 and y <= py + 133 ) then
		aColor.Picking = state == "down"
	end
end

function aColor.onRender ()
	if ( isConsoleActive() ) then
		return
	end
	local color = aColor.Color
	local x, y = guiGetPosition ( aColor.Form, false )
	x = x + 5
	y = y + 5

	if ( aColor.Picking ) then
		local sx, sy = guiGetScreenSize ()
		local cx, cy = getCursorPosition ()
		cx = sx * cx
		cy = sy * cy
		if ( cx < x ) then cx = x
		elseif ( cx > x + 127 ) then cx = x + 127 end
		if ( cy < y ) then cy = y
		elseif ( cy > y + 127 ) then cy = y + 127 end

		color.h, color.s = ( cx - x ) / 127, ( 127 - cy + y ) / 127
		color.r, color.g, color.b = aColor.hs2rgb ( color.h, color.s )
		guiSetText ( aColor.R, tostring ( color.r ) )
		guiSetText ( aColor.G, tostring ( color.g ) )
		guiSetText ( aColor.B, tostring ( color.b ) )
	end

	dxDrawLine ( x + 133, y + 10, x + 200, y + 10, tocolor ( color.r, color.g, color.b, 255 ), 20, true )

	x = x + color.h * 127
	y = y + ( 1 - color.s ) * 127

	local c = tocolor ( 0, 0, 0, 255 )
	dxDrawLine ( x - 7, y, x - 2, y, c, 2, true)
	dxDrawLine ( x + 2, y, x + 7, y, c, 2, true)
	dxDrawLine ( x, y - 7, x, y - 2, c, 2, true)
	dxDrawLine ( x, y + 2, x, y + 7, c, 2, true)
end

function aColor.onChanged ()
	local acc = { [aColor.R] = "r", [aColor.G] = "g", [aColor.B] = "b" }
	if ( acc[source] ) then
		local value = tonumber ( guiGetText ( source ) )
		
		if ( not value ) then
			if ( guiGetText ( source ) == "" ) then aColor.Color[acc[source]] = 0
			else guiSetText ( source, aColor.Color[acc[source]] ) end
		elseif ( value >= 0 and value <= 255 ) then
			aColor.Color[acc[source]] = value
		else
			guiSetText ( source, aColor.Color[acc[source]] )
		end
		aColor.Color.h, aColor.Color.s = aColor.rgb2hs ( aColor.Color.r, aColor.Color.g, aColor.Color.b )
	end
end

function aColor.onBlur ()
	local acc = { [aColor.R] = "r", [aColor.G] = "g", [aColor.B] = "b" }
	if ( acc[source] ) then
		if ( guiGetText ( source ) == "" ) then
			guiSetText ( source, "0" )
		end
	end
end

function aColor.hs2rgb ( h, s )
	local m2 = (0.5 + s) - (0.5 * s)
	local m1 = 1 - m2

	local r = aColor.hue2rgb(m1, m2, h + 1/3)
	local g = aColor.hue2rgb(m1, m2, h)
	local b = aColor.hue2rgb(m1, m2, h - 1/3)
	return math.floor ( r * 255 ), math.floor ( g * 255 ), math.floor ( b * 255 )
end

function aColor.hue2rgb ( m1, m2, h )
	if ( h < 0 ) then h = h + 1
	elseif ( h > 1 ) then h = h - 1 end

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

function aColor.rgb2hs ( r, g, b )
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local l = (min + max) / 2
	local h = 0
	local s = 0

	if ( max ~= min ) then
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

	return h, -s
end