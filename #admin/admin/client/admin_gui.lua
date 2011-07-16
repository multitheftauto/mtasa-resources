--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_gui.lua
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