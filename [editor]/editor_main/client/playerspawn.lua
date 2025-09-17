addEventHandler("onClientPlayerSpawn",localPlayer,
    function()
        if not getElementData(resourceRoot, "g_in_test") then
            setElementInterior(localPlayer, getWorkingInterior())
        end
    end
)