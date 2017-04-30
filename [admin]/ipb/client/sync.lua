
addEvent("ipb.updateStats", true)
addEventHandler("ipb.updateStats", localPlayer,
    function (mode, columns, rows)
        if not GUI.window then
            return
        end

        GUI:fill(mode, columns, rows)
    end,
false)
