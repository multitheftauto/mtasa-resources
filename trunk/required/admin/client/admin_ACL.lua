--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_ACL.lua
*
*	Original File by lil_Toady
*
**************************************]]

_aclrights = {}

function hasPermissionTo ( object )
	if ( _aclrights[object] ) then
		return true
	end
	return false
end

addEvent ( "aPermissions", true )
addEventHandler ( "aPermissions", getLocalPlayer(), function ( table )
	for id, right in ipairs ( table ) do
		_aclrights[right] = true
		if ( aAdminForm ) then
			guiSetEnabled ( _guiprotected[right], true )
		end
	end
end )

addEventHandler ( "onAdminInitialize", _root, function()
	if ( #_guiprotected == 0 ) then
		triggerServerEvent ( "aPermissions", getLocalPlayer() )
	end
end )