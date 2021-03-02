pVehicle = getPedOccupiedVehicle ( localPlayer )
local lastVehicle = nil

-- Yeah, lots of eventhandlers for one thing.

-- This will be triggered when a player is warped into a vehicle.
addEventHandler ( "onClientPlayerVehicleEnter", localPlayer,
    function ( vehicle )
        pVehicle = vehicle
        checkVehicleChange ( )
    end 
)

-- For when a player dies whilst inside a vehicle
addEventHandler ( "onClientPlayerWasted", localPlayer,
    function()
        logCreated = false
        pVehicle = false
        setVisible ( false )
    end
)


-- And exiting normally.
addEventHandler ( "onClientVehicleStartExit", root,
    function ( player )
        -- Possible fix for when someone is trying to jack a locked vehicle, you cant open the editor anymore.
        if player == localPlayer and not isVehicleLocked ( source ) then
            clearLog ( )
            pVehicle = false
            setVisible ( false )
        end
    end
)

-- When the vehicle explodes where you're in
addEventHandler ( "onClientVehicleExplode", root,
    function ( )
        if getPedOccupiedVehicle ( localPlayer ) == source then
            clearLog ( )
            pVehicle = false
            setVisible ( false )
        end
    end
)

-- When the vehicle you're in destroys
addEventHandler("onClientElementDestroy", root, function()
        if (source == localPlayer.vehicle) then
            clearLog()
            pVehicle = false
            setVisible(false)
        end
    end
)

-- For when the vehicle element model changes.
addEventHandler ( "onClientElementStreamIn", root,
    function ( )
        if getElementType ( source ) == "vehicle" and source == getPedOccupiedVehicle ( localPlayer ) then
            pVehicle = source
            triggerEvent ( "updateVehicleText", pVehicle )
            forceVehicleChange ( )
        end
    end
)

-- Update the editor menu if the vehicle is changed
function checkVehicleChange ( )
    if pVehicle then
        triggerEvent ( "updateVehicleText", pVehicle )
        if pVehicle ~= lastVehicle then
            requestMiniLog ( pVehicle )
            lastVehicle = pVehicle
            guiShowView ( "engine" )
        end
    end
end

function forceVehicleChange ( )
    guiDestroyWarningWindow ( )
    
    if pVehicle then
        triggerEvent ( "updateVehicleText", pVehicle )
        requestMiniLog ( pVehicle )
    end
    
    lastVehicle = pVehicle
    guiShowView ( "engine" )
end