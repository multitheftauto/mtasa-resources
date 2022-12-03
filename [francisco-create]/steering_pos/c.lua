local tables = {}
local whichkey = {
    ["w"] = true,
    ["a"] = true,
    ["s"] = true,
    ["d"] = true,
}
local binds = false
addEventHandler("onClientVehicleStartExit",root,function()
    if source then 
        local rx1, ry1, rz1 = getVehicleComponentRotation(source, "wheel_lf_dummy")
        local rx2, ry2, rz2 = getVehicleComponentRotation(source, "wheel_rf_dummy")
        tables[localPlayer] = {on = {"wheel_lf_dummy",rz1},arka = {"wheel_rf_dummy",rz2},araba = source}
        binds = false
    end
end)

addEventHandler("onClientVehicleStartEnter",root,function()
    binds = true
end)

addEventHandler("onClientPedsProcessed",root,function()
   local veri = tables[localPlayer] or {}
   if veri then
        local on = veri.on
        local arka = veri.arka
        local araba = veri.araba
        if araba then
            setVehicleComponentRotation(araba,on[1],0,0,on[2])
            setVehicleComponentRotation(araba,arka[1],0,0,arka[2])
        end
    end
end)
addEventHandler("onClientKey",root,function(buton,pres)
    if not pres then 
        return 
    end
    if tables[localPlayer] == nil then return end
    if whichkey[buton] and binds and getPedOccupiedVehicle(localPlayer) then 
        tables[localPlayer] = nil
    end
end)