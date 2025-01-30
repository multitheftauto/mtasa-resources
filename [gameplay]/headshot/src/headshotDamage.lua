addEvent("onPlayerHeadshot", false)
addEvent("onPlayerPreHeadshot", false)

addEventHandler("onPlayerDamage", root,
    function(headshotAttacker, headshotCause, headshotBodypart, headshotDamage)
        if not headshotAttacker or not isElement(headshotAttacker) or getElementType(headshotAttacker) ~= "player" then
            return
        end

        if headshotBodypart ~= 9 then
            return
        end

        triggerEvent("onPlayerPreHeadshot", source, headshotAttacker, headshotCause, headshotDamage)

        if wasEventCancelled() then
            return
        end

        killPed(source, headshotAttacker, headshotCause, headshotBodypart)

        triggerEvent("onPlayerHeadshot", source, headshotAttacker, headshotCause)

        if not headshotSettingsGet("decap") then
            return
        end

        setPedHeadless(source, true)
    end
)