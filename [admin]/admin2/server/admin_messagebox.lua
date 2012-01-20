--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_messagebox.lua
*
*	Original File by lil_Toady
*
**************************************]]

MB_WARNING = 1
MB_ERROR = 2
MB_QUESTION = 3
MB_INFO = 4

function messageBox ( player, message, icon )
	triggerClientEvent ( client, EVENT_MESSAGE_BOX, client, text, type )
end