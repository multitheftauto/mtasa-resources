addEvent("LicensePlate:set", true)
addEventHandler("LicensePlate:set", root,
    function(vehicle, plate)
        local player = source

        if not player or not isElement(player) then return end
        if not vehicle or not isElement(vehicle) then return end

        if getPedOccupiedVehicle(player) ~= vehicle then
            outputChatBox("You are not in that vehicle.", player, 255, 0, 0)
            return
        end

        if #plate > 8 then
            outputChatBox("License plate too long.", player, 255, 0, 0)
            return
        end
        --[[if not string.match(plate, "^[A-Za-z0-9 ]+$") then
            outputChatBox("Invalid characters in license plate.", player, 255, 0, 0)
            return
        end]]

        setVehiclePlateText(vehicle, plate)
        outputChatBox("License plate set to: " .. plate, player, 0, 255, 0)
    end
)