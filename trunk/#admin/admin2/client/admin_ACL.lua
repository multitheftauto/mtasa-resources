--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_ACL.lua
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
	if ( hasPermissionTo ( "general.adminpanel" ) ) then
		outputChatBox ( "Press 'p' to open your admin panel", player )
		bindKey ( "p", "down", "adminpanel" )
	end
end )

addEventHandler ( "onClientResourceStart", getResourceRootElement ( getThisResource() ), function()
	triggerServerEvent ( "aPermissions", getLocalPlayer() )
    triggerServerEvent ( "aClientInitialized", getLocalPlayer () )
end )