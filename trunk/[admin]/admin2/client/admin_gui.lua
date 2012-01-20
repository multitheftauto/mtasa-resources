--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_gui.lua
*
*	Original File by lil_Toady
*
**************************************]]
_guiprotected = {}

function guiCreateHeader ( x, y, w, h, text, relative, parent )
	local header = guiCreateLabel ( x, y, w, h, text, relative, parent )
	if ( header ) then
		guiLabelSetColor ( header, 255, 0, 0 )
		guiSetFont ( header, "default-bold-small" )
		return header
	end
	return false
end

function guiCreateInnerImage ( image, parent, above )
	local sx, sy = guiGetSize ( parent, false )
	local img = nil
	if ( above ) then
		img = guiCreateStaticImage ( 0, 0, 0, 0, image, false, getElementParent ( parent ) )
		local px, py = guiGetPosition ( parent, false )
		guiSetPosition ( img, px + sx - sy, py, false )
	else
		img = guiCreateStaticImage ( 0, 0, 0, 0, image, false, parent )
		guiSetPosition ( img, sx - sy, 0, false )
	end
	guiSetSize ( img, sy, sy, false )
	return img
end

local _guiCreateWindow = guiCreateWindow
function guiCreateWindow ( ... )
	local window = _guiCreateWindow ( ... )
	if ( window ) then
		guiWindowSetSizable ( window, false )
		return window
	end
	return nil
end

local _guiCreateTab = guiCreateTab
function guiCreateTab ( name, parent, right )
	local tab = _guiCreateTab ( name, parent )
	if ( tab ) then
		if ( right ) then
			right = "general.tab_"..right
			if ( not hasPermissionTo ( right ) ) then
				guiSetEnabled ( tab, false )
				_guiprotected[right] = tab
			end
		end
		return tab
	end
	return false
end

local _guiCreateButton = guiCreateButton
function guiCreateButton ( x, y, w, h, text, relative, parent, right )
	local button = _guiCreateButton ( x, y, w, h, text, relative, parent )
	if ( button ) then
		if ( right ) then
			right = "command."..right
			if ( not hasPermissionTo ( right ) ) then
				guiSetEnabled ( button, false )
				_guiprotected[right] = button
			end
		end
		guiSetFont ( button, "default-bold-small" )
		return button
	end
	return false
end

local _guiCreateCheckBox = guiCreateCheckBox
function guiCreateCheckBox ( x, y, w, h, text, checked, relative, parent, right )
	local check = _guiCreateCheckBox ( x, y, w, h, text, checked, relative, parent )
	if ( check ) then
		if ( right ) then
			right = "command."..right
			if ( not hasPermissionTo ( right ) ) then
				guiSetEnabled ( check, false )
				_guiprotected[right] = check
			end
		end
		return check
	end
	return false
end

local guiColorPickers = {}
function guiCreateColorPicker ( x, y, w, h, r, g, b, relative, parent )
	local mask = guiCreateLabel ( x, y, w, h, "", relative, parent )
	guiLabelSetHorizontalAlign ( mask, "left", true )
	guiColorPickers[mask] = { r = r or 255, g = g or 0, b = b or 0 }
	addEventHandler ( "onClientGUIClick", mask, function ( key, state )
		local info = guiColorPickers[source]
		if ( key == "left" and state == "up" and info ) then
			local x, y = guiGetAbsolutePosition ( mask )
			local sx, sy = guiGetSize ( mask, false )
			info.picking = true
			info.r, info.g, info.b = aColor.Open ( x + sx, y - 5, info.r, info.g, info.b )
			info.picking = nil
		end
	end )
	addEventHandler ( "onClientElementDestroy", mask, function ()
		guiColorPickers[source] = nil
	end )
end

addEventHandler ( "onClientRender", getRootElement(), function ()
	if ( isConsoleActive() ) then
		return
	end
	for mask, info in pairs ( guiColorPickers ) do
		if ( guiGetVisible ( mask ) ) then
			if ( info.picking ) then
				info.r, info.g, info.b = aColor.Color.r, aColor.Color.g, aColor.Color.b
			end
			local x, y = guiGetAbsolutePosition ( mask )
			local sx, sy = guiGetSize ( mask, false )
			dxDrawLine ( x, y + sy / 2, x + sx, y + sy / 2, tocolor ( info.r, info.g, info.b, 255 ), sy, true )
		end
	end
end )

local guiBlendTable = {}
function guiBlendElement ( element, alpha, hide )
	local increment = ( alpha - guiGetAlpha ( element ) ) * 10
	guiBlendTable[element] = { inc = increment, hide = hide, target = alpha }
end

addEventHandler ( "onClientRender", _root, function ()
	for element, v in pairs ( guiBlendTable ) do
		local a = guiGetAlpha ( element ) + v.inc / 40
		if ( v.inc < 0 and a <= v.target ) then
			a = v.target
			if ( v.hide ) then guiSetVisible ( element, false ) end
			guiBlendTable[element] = nil
		elseif ( v.inc > 0 and a >= v.target ) then
			a = v.target
			guiBlendTable[element] = nil
		end
		guiSetAlpha ( element, a )
	end
end )

function guiCreateContextMenu ( element )
	local menu = guiCreateStaticImage ( 0, 0, 100, 0, "client/images/black.png", false )
	guiSetVisible ( menu, false )
	if ( element ) then
		guiSetContextMenu ( element, menu )
	end
	return menu
end

function guiSetContextMenu ( element, menu )
	addEventHandler ( "onClientGUIClick", element, function ( button )
		contextSource = source
		if ( getElementType ( source ) == "gui-gridlist" and guiGridListGetSelectedItem ( source ) == -1 ) then
			return
		end 
		if ( button == "right" ) then
			local sx, sy = guiGetScreenSize()
			local x, y = getCursorPosition ()
			x, y = sx * x, sy * y
			guiSetPosition ( menu, x, y, false )
			guiSetVisible ( menu, true )
			guiBringToFront ( menu )

			setTimer ( function ()
				addEventHandler ( "onClientClick", getRootElement(), function ( button, state, x, y )
					local sx, sy = guiGetSize ( menu, false )
					local px, py = guiGetPosition ( menu, false )
					if ( x < px or x > px + sx ) or ( y < py or y > py + sy ) then
						guiSetVisible ( menu, false )
						removeEventHandler ( "onClientClick", getRootElement(), debug.getinfo ( 1, "f" ).func )
					end
				end )
			end, 50, 1 )
		end
	end, false )
	addEventHandler ( "onClientGUIClick", menu, function ( button )
		guiSetVisible ( menu, false )
	end )
end

function guiContextMenuAddItem ( element, text )
	local height = 16
	local sx, sy = guiGetSize ( element, false )
	local n = #getElementChildren ( element )
	local bg = guiCreateStaticImage ( 1, n * height + 1, 0, height, "client/images/black.png", false, element )
	local item = guiCreateLabel ( 0, 0, 0, height, "  "..text.."  ", false, bg )
	local extent = guiLabelGetTextExtent ( item )
	local width = guiGetSize ( element, false ) - 2
	if ( extent > width ) then
		width = extent
	end
	guiSetSize ( element, width + 2, ( n + 1 ) * height + 2, false )
	guiSetSize ( bg, width, height, false )
	guiSetSize ( item, width, height, false )

	addEventHandler ( "onClientMouseEnter", item, function ()
		guiStaticImageLoadImage ( getElementParent ( source ), "client/images/blue.png" )
	end, false )
	addEventHandler ( "onClientMouseLeave", item, function ()
		guiStaticImageLoadImage ( getElementParent ( source ), "client/images/black.png" )
	end, false )
	return item
end

function guiCreateToolTip ( element )

end

function guiGetAbsolutePosition ( element )
	local x, y = guiGetPosition ( element, false )
	local parent = getElementParent ( element )
	while ( parent ~= getResourceGUIElement() ) do
		local px, py = guiGetPosition ( parent, false )
		x = x + px
		y = y + py
		parent = getElementParent ( parent )
	end
	return x, y
end

function guiHandleInput ( element )
	addEventHandler ( "onClientGUIFocus", element, function ()
		guiSetInputEnabled ( true )
	end, false )
	addEventHandler ( "onClientGUIBlur", element, function ()
		guiSetInputEnabled ( false )
	end, false )
end