--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_wrapper.lua
*
*	Original File by lil_Toady
*
**************************************]]
function table.reverse(t)
    local newt = {}
    for idx, item in ipairs(t) do
        newt[#t - idx + 1] = item
    end
    return newt
end

function table.cmp(t1, t2)
    if not t1 or not t2 or #t1 ~= #t2 then
        return false
    end
    for k, v in pairs(t1) do
        if v ~= t2[k] then
            return false
        end
    end
    return true
end

function table.compare(tab1, tab2)
    if tab1 and tab2 then
        if tab1 == tab2 then
            return true
        end
        if type(tab1) == "table" and type(tab2) == "table" then
            if table.size(tab1) ~= table.size(tab2) then
                return false
            end
            for index, content in pairs(tab1) do
                if not table.compare(tab2[index], content) then
                    return false
                end
            end
            return true
        end
    end
    return false
end

function table.size(tab)
    local length = 0
    if tab then
        for _ in pairs(tab) do
            length = length + 1
        end
    end
    return length
end

function table.iadd(tab1, tab2)
    for k, v in ipairs(tab2) do
        table.insert(tab1, v)
    end
    return tab1
end

function iif(cond, arg1, arg2)
    if (cond) then
        return arg1
    end
    return arg2
end

function getVehicleOccupants(vehicle)
    local tableOut = {}
    local seats = getVehicleMaxPassengers(vehicle) + 1
    for i = 0, seats do
        local passenger = getVehicleOccupant(vehicle, i)
        if (passenger) then
            table.insert(tableOut, passenger)
        end
    end
    return tableOut
end

function getWeatherNameFromID(weather)
    return iif(aWeathers[weather], aWeathers[weather], "Unknown")
end

function warp(p, to)
    local x, y, z, r, dim, int
    if type(to) == "table" then
        x, y, z = unpack(to)
        r, dim, int = 0, 0, 0
    else
        x, y, z = getElementPosition(to)
        r = getPedRotation(to)
        dim = getElementDimension(to)
        int = getElementInterior(to)
    end
    local target = getPedOccupiedVehicle(p) or p
    x = x - math.sin(math.rad(r)) * 2
    y = y + math.cos(math.rad(r)) * 2
    setTimer(setElementPosition, 1000, 1, target, x, y, z + 1)
    fadeCamera(p, false, 1, 0, 0, 0)
    setElementDimension(target, dim)
    setElementInterior(target, int)
    setTimer(fadeCamera, 1000, 1, p, true, 1)
end

function warpPlayer(p, to)
    if (isElement(to) and isPedInVehicle(to)) then
        local vehicle = getPedOccupiedVehicle(to)
        local seats = getVehicleMaxPassengers(vehicle) + 1
        local i = 0
        while (i < seats) do
            if (not getVehicleOccupant(vehicle, i)) then
                setTimer(warpPedIntoVehicle, 1000, 1, p, vehicle, i)
                fadeCamera(p, false, 1, 0, 0, 0)
                setTimer(fadeCamera, 1000, 1, p, true, 1)
                break
            end
            i = i + 1
        end
        if (i >= seats) then
            warp(p, to)
            outputConsole("Player's vehicle is full (" .. getVehicleName(vehicle) .. " - Seats: " .. seats .. ")", p)
        end
    else
        warp(p, to)
    end
end

function getMonthName(month)
    local names = {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    }
    return names[month]
end
