g_RPCFunctionsValidation = {
    addPedClothes = function(thePlayer, clothesTexture, clothesModel, clothesType, ...)
        if client ~= thePlayer then return false end
        if type(clothesTexture) ~= "string" then return false end
        if type(clothesModel) ~= "string" then return false end
        if type(clothesType) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    addVehicleUpgrade = function(theVehicle, upgrade, ...)
        if getPedOccupiedVehicle(client) ~= theVehicle then return false end
        if type(upgrade) ~= "number" and type(upgrade) ~= "string" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    fadeVehiclePassengersCamera = function(toggle, ...)
        if type(toggle) ~= "boolean" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    fixVehicle = function(theVehicle, ...)
        if getPedOccupiedVehicle(client) ~= theVehicle then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    giveMeVehicles = function(vehicleId, ...)
        if type(vehicleId) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    giveMeWeapon = function(weapon, amount, ...)
        if type(weapon) ~= "number" and type(weapon) ~= "string" then return false end
        if type(amount) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    removePedClothes = function(thePlayer, clothesType, ...)
        if client ~= thePlayer then return false end
        if type(clothesType) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    removePedFromVehicle = function(thePlayer, ...)
        if client ~= thePlayer then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    removeVehicleUpgrade = function(theVehicle, upgrade, ...)
        if getPedOccupiedVehicle(client) ~= theVehicle then return false end
        if type(upgrade) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setElementAlpha = function(thePlayer, alpha, ...)
        if client ~= thePlayer then return false end
        if type(alpha) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setElementInterior = function(thePlayerOrVehicle, interior, ...)
        if client ~= thePlayerOrVehicle and thePlayerOrVehicle ~= getPedOccupiedVehicle(client) then return false end
        if type(tonumber(interior)) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setElementPosition = function(element, x, y, z)
        if client ~= element and element ~= getPedOccupiedVehicle(client) then return false end
        if type(x) ~= "number" then return false end
        if type(y) ~= "number" then return false end
        if type(z) ~= "number" then return false end
        return true
    end,
    setCameraInterior = function (thePlayer, interior, ...)
        if client ~= thePlayer then return false end
        if type(tonumber(interior)) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setMySkin = function(skinId, ...)
        if type(skinId) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setPedAnimation = function(thePlayer, block, anim, time, loop, updatePosition, ...)
        if client ~= thePlayer then return false end
        if (block == false and #{ anim, time, loop, updatePosition, ... } == 0) then return true end
        if block ~= nil and type(block) ~= "string" then return false end
        if anim ~= nil and type(anim) ~= "string" then return false end
        if time ~= nil and type(time) ~= "number" then return false end
        if loop ~= nil and type(loop) ~= "boolean" then return false end
        if updatePosition ~= nil and type(updatePosition) ~= "boolean" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setPedFightingStyle = function(thePlayer, style, ...)
        if client ~= thePlayer then return false end
        if type(style) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setPedGravity = function(thePlayer, gravity, ...)
        if client ~= thePlayer then return false end
        if type(gravity) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setPedStat = function(thePlayer, stat, value, ...)
        if client ~= thePlayer then return false end
        if type(stat) ~= "number" then return false end
        if type(value) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setPedWalkingStyle = function(thePlayer, styleId, ...)
        if client ~= thePlayer then return false end
        if type(styleId) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    
    setPedWearingJetpack = function(thePlayer, toggle, ...)
        if client ~= thePlayer then return false end
        if type(toggle) ~= "boolean" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setVehicleColor = function(theVehicle, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4, ...)
        if getPedOccupiedVehicle(client) ~= theVehicle then return false end
        if r1 and (type(r1) ~= "number" or type(g1) ~= "number" or type(b1) ~= "number") then return false end
        -- Starting the next look up at g2, because for the Palette format which uses 4 arguments.
        if g2 and (type(r2) ~= "number" or type(g2) ~= "number" or type(b2) ~= "number") then return false end
        if r3 and (type(r3) ~= "number" or type(g3) ~= "number" or type(b3) ~= "number") then return false end
        if r4 and (type(r4) ~= "number" or type(g4) ~= "number" or type(b4) ~= "number") then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setVehicleHeadLightColor = function(theVehicle, r, g, b, ...)
        if getPedOccupiedVehicle(client) ~= theVehicle then return false end
        if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setVehicleOverrideLights = function(theVehicle, value, ...)
        if getPedOccupiedVehicle(client) ~= theVehicle then return false end
        if type(value) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    setVehiclePaintjob = function(theVehicle, value, ...)
        if getPedOccupiedVehicle(client) ~= theVehicle then return false end
        if type(value) ~= "number" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end,
    warpMeIntoVehicle = function(theVehicle, ...)
        if not isElement(theVehicle) then return false end
        if getElementType(theVehicle) ~= "vehicle" then return false end
        if (#{ ... } > 0) then return false end
        return true
    end
}
