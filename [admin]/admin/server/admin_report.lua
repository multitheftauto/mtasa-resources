--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_reports.lua
*
*	Original File by CArg22
*
**************************************]]

if ( get("reportsEnabled") == "true" ) or true then
	addCommandHandler ( "report", function( plr ) 
        triggerClientEvent(admin, "aClientReports", resourceRoot )
    end )
end