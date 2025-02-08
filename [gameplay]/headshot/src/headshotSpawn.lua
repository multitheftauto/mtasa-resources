addEventHandler("onPlayerSpawn", root,
    function()
        if not isPedHeadless(source) then
            return
        end

        if not headshotSettingsGet("decap") then
            return
        end

        setPedHeadless(source, false)
    end
)