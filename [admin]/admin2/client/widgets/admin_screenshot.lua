--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	client\widgets\admin_screenshot.lua
*
*	Original File by lil_Toady
*
**************************************]]

aScreenShot = {
	Form = nil
}

function aScreenShot.Open ()
	local sx, sy = guiGetScreenSize ()

	if ( not aScreenShot.Form ) then
		aScreenShot.Form		= guiCreateWindow ( sx / 2 - 160, sy / 2 - 120, 320, 240, "Screen Shot", false )

	end
end

function aScreenShot.Close ( destroy )

end