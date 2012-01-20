--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_session.lua
*
*	Original File by lil_Toady
*
**************************************]]

local aSession = {}

addEvent ( "aClientAdminMenu", true )
addEventHandler ( "aClientAdminMenu", _root, function ()
	if ( aAdminMain.Form ) and ( guiGetVisible ( aAdminMain.Form ) == true ) then
		aAdminMain.Close ( false )
	else
		aAdminMain.Open ()
	end
end )

addEvent ( EVENT_SESSION, true )
addEventHandler ( EVENT_SESSION, getLocalPlayer(), function ( data )
	local changed = false
	for right, v in pairs ( aSession ) do
		if ( not data[right] ) then
			changed = true
		end
	end

	aSession = data

	if ( hasPermissionTo ( "general.adminpanel" ) ) then
		outputChatBox ( "Press 'p' to open your admin panel", player )
		bindKey ( "p", "down", "adminpanel" )
	elseif ( aAdminMain.Form ) then
		outputChatBox ( "Your administration rights have been revoked" )
		aAdminMain.Close ( true )
	elseif ( changed ) then
		local reopen = false
		if ( aAdminMain.Form ) then
			reopen = guiGetVisible ( aAdminMain.Form )
		end
		aAdminMain.Close ( true )
		if ( reopen ) then
			outputChatBox ( "Administration rights have been updated" )
			aAdminMain.Open ()
		end
	end
end )

addEventHandler ( "onClientResourceStart", getResourceRootElement ( getThisResource() ), function()
	triggerServerEvent ( EVENT_SESSION, getLocalPlayer(), SESSION_START )
end )

addEventHandler ( "onClientResourceStop", getResourceRootElement ( getThisResource() ), function ()
	guiSetInputEnabled ( false )
end )

function hasPermissionTo ( object )
	if ( aSession[object] ) then
		return true
	end
	return false
end

function sync ( ... )
	triggerServerEvent ( EVENT_SYNC, getLocalPlayer(), ... )
end