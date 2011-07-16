--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_ban.lua
*
*	Original File by lil_Toady
*
**************************************]]

aBanForm = nil

function aBanDetails ( ip )
	if ( aBanForm == nil ) then
		local x, y = guiGetScreenSize()
		aBanForm		= guiCreateWindow ( x / 2 - 130, y / 2 - 150, 260, 300, "Ban Details", false )
		aBanIP			= guiCreateLabel ( 0.03, 0.10, 0.80, 0.09, "", true, aBanForm )
		aBanNick		= guiCreateLabel ( 0.03, 0.20, 0.80, 0.09, "", true, aBanForm )
		aBanDate		= guiCreateLabel ( 0.03, 0.30, 0.80, 0.09, "", true, aBanForm )
		aBanTime		= guiCreateLabel ( 0.03, 0.40, 0.80, 0.09, "", true, aBanForm )
		aBanBanner		= guiCreateLabel ( 0.03, 0.50, 0.80, 0.09, "", true, aBanForm )
		aBanClose		= guiCreateButton ( 0.80, 0.88, 0.17, 0.08, "Close", true, aBanForm )

		guiSetVisible ( aBanForm, false )
		addEventHandler ( "onClientGUIClick", aBanForm, aClientBanClick )
		--Register With Admin Form
		aRegister ( "BanDetails", aBanForm, aBanDetails, aBanDetailsClose )
	end
	if ( aBans["IP"][ip] ) then
		guiSetText ( aBanIP, "IP: "..ip )
		guiSetText ( aBanNick, "Nickname: "..iif ( aBans["IP"][ip]["nick"], aBans["IP"][ip]["nick"], "Unknown" ) )
		guiSetText ( aBanDate, "Date: "..iif ( aBans["IP"][ip]["date"], aBans["IP"][ip]["date"], "Unknown" ) )
		guiSetText ( aBanTime, "Time: "..iif ( aBans["IP"][ip]["time"], aBans["IP"][ip]["time"], "Unknown" ) )
		guiSetText ( aBanBanner, "Banned by: "..iif ( aBans["IP"][ip]["banner"], aBans["IP"][ip]["banner"], "Unknown" ) )
		if ( aBanReason ) then destroyElement ( aBanReason ) end
		aBanReason = guiCreateLabel ( 0.03, 0.60, 0.80, 0.30, "Reason: "..iif ( aBans["IP"][ip]["reason"], aBans["IP"][ip]["reason"], "Unknown" ), true, aBanForm )
		guiLabelSetHorizontalAlign ( aBanReason, "left", true )
		guiSetVisible ( aBanForm, true )
		guiBringToFront ( aBanForm )
	elseif ( aBans["Serial"][ip] ) then
		guiSetText ( aBanIP, "Serial: "..ip )
		guiSetText ( aBanNick, "Nickname: "..iif ( aBans["Serial"][ip]["nick"], aBans["Serial"][ip]["nick"], "Unknown" ) )
		guiSetText ( aBanDate, "Date: "..iif ( aBans["Serial"][ip]["date"], aBans["Serial"][ip]["date"], "Unknown" ) )
		guiSetText ( aBanTime, "Time: "..iif ( aBans["Serial"][ip]["time"], aBans["Serial"][ip]["time"], "Unknown" ) )
		guiSetText ( aBanBanner, "Banned by: "..iif ( aBans["Serial"][ip]["banner"], aBans["Serial"][ip]["banner"], "Unknown" ) )
		if ( aBanReason ) then destroyElement ( aBanReason ) end
		aBanReason = guiCreateLabel ( 0.03, 0.60, 0.80, 0.30, "Reason: "..iif ( aBans["Serial"][ip]["reason"], aBans["Serial"][ip]["reason"], "Unknown" ), true, aBanForm )
		guiLabelSetHorizontalAlign ( aBanReason, "left", true )
		guiSetVisible ( aBanForm, true )
		guiBringToFront ( aBanForm )
	end
end

function aBanDetailsClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceBan ) ) ) then
		if ( aBanForm ) then
			removeEventHandler ( "onClientGUIClick", aBanForm, aClientBanClick )
			destroyElement ( aBanForm )
			aBanForm = nil
		end
	else
		guiSetVisible ( aBanForm, false )
	end
end

function aClientBanClick ( button )
	if ( button == "left" ) then
		if ( source == aBanClose ) then
			aBanDetailsClose ( false )
		elseif ( source == aBanUnban ) then
			triggerEvent ( "onClientGUIClick", aTab4.BansUnban, "left" )
		end
	end
end