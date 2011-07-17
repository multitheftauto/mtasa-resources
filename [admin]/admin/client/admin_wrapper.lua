--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_wrapper.lua
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

_getVehicleNameFromID = getVehicleNameFromModel
function getVehicleNameFromID ( id )
	local avehspecial = { [596] = "Police LS",
				    [597] = "Police SF",
				    [598] = "Police LV",
				    [556] = "Monster 2",
				    [557] = "Monster 3"
				  }
	if ( avehspecial[id] ) then
		return avehspecial[id]
	end
	return _getVehicleNameFromID ( id )
end

_getVehicleIDFromName = getVehicleModelFromName
function getVehicleIDFromName ( name )
	local avehspecial = { ["Police LS"] = 596,
				    ["Police SF"] = 597,
				    ["Police LV"] = 598,
				    ["Monster 2"] = 556,
				    ["Monster 3"] = 557
				  }
	if ( avehspecial[name] ) then
		return avehspecial[name]
	end
	return _getVehicleIDFromName ( name )
end