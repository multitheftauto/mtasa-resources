
addEvent("ipb.accessControl", true)
addEventHandler("ipb.accessControl", localPlayer,
    function (access)
        if access then
            GUI:create()
            GUI:setVisible(true)
        else
            GUI:destroy()
        end
    end,
false)
