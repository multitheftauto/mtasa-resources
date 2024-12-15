addCommandHandler("report", function( playerSource )
    if ( get("reportsEnabled") ~= "false" ) then
        triggerClientEvent( playerSource, "aClientReports", playerSource )
    else
         outputChatBox ( "Reports are not accepted currently.", playerSource, 255, 0, 0 )
    end
end, false, false)