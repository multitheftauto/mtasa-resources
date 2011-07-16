--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_wrapper.lua
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

_guiCreateTab = guiCreateTab
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

_guiCreateButton = guiCreateButton
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

_getVehicleNameFromModel = getVehicleNameFromModel
function getVehicleNameFromModel ( id )
	local avehspecial = { [596] = "Police LS",
				    [597] = "Police SF",
				    [598] = "Police LV",
				    [556] = "Monster 2",
				    [557] = "Monster 3",
				    [609] = "Black Boxville",
				    [604] = "Damaged Glendale",
				    [544] = "Fire Truck (Ladder)",
				    [502] = "Hotring Racer 2",
				    [503] = "Hotring Racer 3",
				    [505] = "Rancher (From \"Lure\")",
				    [605] = "Damaged Sadler"
				  }
	if ( avehspecial[id] ) then
		return avehspecial[id]
	end
	return _getVehicleNameFromModel ( id )
end

_getVehicleModelFromName = getVehicleModelFromName
function getVehicleModelFromName ( name )
	local avehspecial = { ["Police LS"] = 596,
				    ["Police SF"] = 597,
				    ["Police LV"] = 598,
				    ["Monster 2"] = 556,
				    ["Monster 3"] = 557,
				    ["Black Boxville"] = 609,
				    ["Damaged Glendale"] = 604,
				    ["Fire Truck (Ladder)"] = 544,
				    ["Hotring Racer 2"] = 502,
				    ["Hotring Racer 3"] = 503,
				    ["Rancher (From \"Lure\")"] = 505,
				    ["Damaged Sadler"] = 605
				  }
	if ( avehspecial[name] ) then
		return avehspecial[name]
	end
	return _getVehicleModelFromName ( name )
end

function getMonthName ( month )
	local names = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	return names[month]
end

function iif ( cond, arg1, arg2 )
	if ( cond ) then
		return arg1
	end
	return arg2
end

function getPlayerFromNick ( nick )
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		if ( getPlayerName ( player ) == nick ) then return player end
	end
	return false
end