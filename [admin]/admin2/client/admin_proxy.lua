--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client/admin_proxy.lua
*
*	Original File by lil_Toady
*
**************************************]]

addEvent ( EVENT_PROXY, true )
addEventHandler ( EVENT_PROXY, getRootElement(), function ( action, data, value )
	if ( action == PROXY_ALL ) then
		setBlurLevel ( data[PROXY_BLUR] )
		for k, v in pairs ( data[PROXY_SPECIAL] ) do
			setWorldSpecialPropertyEnabled ( k, v )
		end
	elseif ( action == PROXY_BLUR ) then
		setBlurLevel ( data )
	elseif ( action == PROXY_SPECIAL ) then
		setWorldSpecialPropertyEnabled ( data, value )
	end
end )