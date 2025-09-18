-- NEEDS CHECKING
-- stuff has that comment, search for it

aFunctions = {
    team = {
        ["createteam"] = function(name, r, g, b)
            local success
            if (tonumber(r)) and (tonumber(g)) and (tonumber(b)) then
                success = createTeam(name, tonumber(r), tonumber(g), tonumber(b))
            else
                success = createTeam(name)
            end
            if (not success) then
                outputChatBox('Team "' .. name .. '" could not be created.', client, 255, 0, 0)
            end
            return success, name
        end,
        ["destroyteam"] = function(team)
            if ((team) and (isElement(team)) and (getElementType(team) == "team")) then
                local name = getTeamName(team)
                return destroyElement(team), name
            else
                return false
            end
        end
    },
    player = {
        ["kick"] = function(player, data)
            setTimer(kickPlayer, 100, 1, player, client, data)
        end,
        ["ban"] = function(player, data)
            setTimer(banPlayer, 100, 1, player, true, true, true, client, data)
        end,
        ["mute"] = function(player, data)
            if (not data or not data.duration) then
                return
            end

            if isPlayerMuted(player) then
                return
            end

            local time
            if data.duration == 0 then
                time = "Permanent"
            else
                time = secondsToTimeDesc(data.duration)
            end

            aSetPlayerMuted(player, true, data.duration)
            return true, time
        end,
        ["unmute"] = function(player)
            if not isPlayerMuted(player) then
                return
            end

            aSetPlayerMuted(player, false)
        end,
        ["freeze"] = function(player)
            local vehicle = getPedOccupiedVehicle(player)

            if (vehicle and getVehicleController(vehicle) == player) then
                setElementFrozen(vehicle, true)
            end

            toggleAllControls(player, false, true, false)
            setElementFrozen(player, true)
        end,
        ["unfreeze"] = function(player)
            local vehicle = getPedOccupiedVehicle(player)

            if (vehicle and getVehicleController(vehicle) == player) then
                setElementFrozen(vehicle, false)
            end

            toggleAllControls(player, true, true, false)
            setElementFrozen(player, false)
        end,
        ["setnick"] = function(player, nick)
            if (#nick > 0) then
                local oldnick = getPlayerName(player)
                return setPlayerName(player, nick), oldnick
            else
                return false
            end
        end,
        ["shout"] = function(player, text)
            local textDisplay = textCreateDisplay()
            local textItem =
                textCreateTextItem(
                "(ADMIN)" .. stripColorCodes(getPlayerName(client)) .. ":\n\n" .. text,
                0.5,
                0.5,
                2,
                255,
                100,
                50,
                255,
                4,
                "center",
                "center"
            )
            textDisplayAddText(textDisplay, textItem)
            textDisplayAddObserver(textDisplay, player)
            setTimer(textDestroyTextItem, 5000, 1, textItem)
            setTimer(textDestroyDisplay, 5000, 1, textDisplay)
        end,
        ["sethealth"] = function(player, health1)
            local health = tonumber(health1)
            if (health) then
                if (health > 200 or health < 0) then
                    health = 100
                end
                return setElementHealth(player, health), health
            else
                return false
            end
        end,
        ["setarmour"] = function(player, armour1)
            local armour = tonumber(armour1)
            if (armour) then
                if (armour > 200 or armour < 0) then
                    armour = 100
                end
                return setPedArmor(player, armour), armour
            else
                return false
            end
        end,
        ["setskin"] = function(player, skin1)
            local skin = tonumber(skin1)
            if (not skin) then
                return false
            end
            return setElementModel(player, skin), skin
        end,
        ["setmoney"] = function(player, value)
            local money = tonumber(value)
            if (not money) then
                return false
            end
            if (not setPlayerMoney(player, money)) then
                outputChatBox("Invalid money value", client, 255, 0, 0)
                return false
            end
            return true, money
        end,
        ["setstat"] = function(player, stat, value)
            if (not value) then
                return false
            end
            if (tonumber(stat) == 300) then
                return setPedFightingStyle(player, tonumber(value)), "Fighting Style", value
            else
                return setPedStat(player, tonumber(stat), tonumber(value)), aStats[stat], value
            end
        end,
        ["setteam"] = function(player, team)
            if (getElementType(team) == "team") then
                return setPlayerTeam(player, team), getTeamName(team)
            end
            return false
        end,
        ["setinterior"] = function(player, data)
            for id, interior in ipairs(aInteriors) do
                if (interior["id"] == data) then
                    local vehicle = getPedOccupiedVehicle(player)
                    setElementInterior(player, interior["world"])
                    local x, y, z = interior["x"] or 0, interior["y"] or 0, interior["z"] or 0
                    local rot = interior["r"] or 0
                    if (vehicle) then
                        setElementInterior(vehicle, interior["world"])
                        setElementPosition(vehicle, x, y, z + 0.2)
                    else
                        setElementPosition(player, x, y, z + 0.2)
                        setPedRotation(player, rot)
                    end
                    return true, interior["id"]
                end
            end
            return false
        end,
        ["setdimension"] = function(player, dimension1)
            local dimension = tonumber(dimension1)
            if (dimension) then
                if (dimension > 65535) or (dimension < 0) then
                    dimension = 0
                end
                return setElementDimension(player, dimension), dimension
            else
                return false
            end
        end,
        ["jetpack"] = function(player)
            if (isPedWearingJetpack(player)) then
                setPedWearingJetpack(player, false)
                return true, "jetpackr"
            else
                if (getPedOccupiedVehicle(player)) then
                    outputChatBox(
                        "Unable to give a jetpack - " .. getPlayerName(player) .. " is in a vehicle",
                        client,
                        255,
                        0,
                        0
                    )
                else
                    if (setPedWearingJetpack(player, true)) then
                        return true, "jetpacka"
                    end
                end
            end
        end,
        ["setgroup"] = function(player, data, groupName)
            local account = getPlayerAccount(player)
            if (not isGuestAccount(account)) then
                local group = aclGetGroup(groupName)
                if (group) then
                    if (data == true) then
                        aclGroupAddObject(group, "user." .. getAccountName(account))
                        triggerEvent(EVENT_SYNC, client, SYNC_PLAYERACL, player)
                        return "admina", groupName
                    elseif (data == false) then
                        aclGroupRemoveObject(group, "user." .. getAccountName(account))
                        aPlayers[player]["chat"] = false
                        triggerEvent(EVENT_SYNC, client, SYNC_PLAYERACL, player)
                        return "adminr", groupName
                    end
                end
            else
                outputChatBox("Error - Player is not logged in.", client, 255, 100, 100)
            end
        end,
        ["givevehicle"] = function(player, id)
            local pvehicle = getPedOccupiedVehicle(player)
            local vx, vy, vz = getElementVelocity(player)
            local vehicle
            if (pvehicle) then
                local passengers = getVehicleOccupants(pvehicle)
                local x, y, z = getElementPosition(pvehicle)
                local rx, ry, rz = getVehicleRotation(pvehicle)
                destroyElement(pvehicle)
                vehicle = createVehicle(id, x, y, z, rx, ry, rz)
                local seats = getVehicleMaxPassengers(vehicle)
                for i, p in ipairs(passengers) do
                    if (p ~= player) then
                        local s = i - 1
                        if (s <= seats) then
                            setTimer(warpPedIntoVehicle, 500, 1, p, vehicle, s)
                        end
                    end
                end
            else
                local x, y, z = getElementPosition(player)
                local r = getPedRotation(player)
                vehicle = createVehicle(id, x, y, z, 0, 0, r)
            end
            setElementDimension(vehicle, getElementDimension(player))
            setElementInterior(vehicle, getElementInterior(player))
            warpPedIntoVehicle(player, vehicle)
            setElementVelocity(vehicle, vx, vy, vz)
            return true, getVehicleName(vehicle)
        end,
        ["giveweapon"] = function(player, weapon, ammo)
            if (giveWeapon(player, weapon, ammo, true)) then
                return true, getWeaponNameFromID(weapon), ammo
            end
            return false
        end,
        ["slap"] = function(player, data)
            if (getElementHealth(player) > 0) and (not isPedDead(player)) then
                local slap = tonumber(data) or 20
                if (slap > 0) then
                    if (slap > getElementHealth(player)) then
                        setTimer(killPed, 50, 1, player)
                    else
                        setElementHealth(player, getElementHealth(player) - slap)
                    end
                end
                local x, y, z = getElementVelocity(player)
                setElementVelocity(player, x, y, z + 0.2)
                return true, slap
            else
                return false
            end
        end,
        ["getscreen"] = function(player, quality)
            getPlayerScreen(player, client, quality)
        end,
        ["warp"] = function(player)
            warpPlayer(client, player)
        end,
        ["warpto"] = function(player, data)
            warpPlayer(player, data)
            return true, type(data) == "table" and getZoneName(unpack(data)) or getPlayerName(data)
        end
    },
    vehicle = {
        ["repair"] = function(player, vehicle)
            fixVehicle(vehicle)
            local rx, ry, rz = getVehicleRotation(vehicle)
            if (rx > 110) and (rx < 250) then
                local x, y, z = getElementPosition(vehicle)
                setVehicleRotation(vehicle, rx + 180, ry, rz)
                setElementPosition(vehicle, x, y, z + 2)
            end
        end,
        ["customize"] = function(player, vehicle, data)
            if (data[1] == "remove") then
                for id, upgrade in ipairs(getVehicleUpgrades(vehicle)) do
                    removeVehicleUpgrade(vehicle, upgrade)
                end
                return "customizer"
            else
                local mdata = ""
                for id, upgrade in ipairs(data) do
                    addVehicleUpgrade(vehicle, upgrade)
                    if (mdata == "") then
                        mdata = tostring(upgrade)
                    else
                        mdata = mdata .. ", " .. upgrade
                    end
                end
                return true, mdata
            end
        end,
        ["setpaintjob"] = function(player, vehicle, id)
            if (not setVehiclePaintjob(vehicle, id)) then
                outputChatBox("Invalid Paint job ID", client, 255, 0, 0)
                return false
            end
            return true, id
        end,
        ["setcolor"] = function(player, vehicle, data)
            for k, color in ipairs(data) do
                local c = tonumber(color)
                if (c) then
                    if (c < 0) or (c > 126) then
                        return false
                    end
                else
                    return false
                end
            end
            if
                (not setVehicleColor(
                    vehicle,
                    tonumber(data[1]),
                    tonumber(data[2]),
                    tonumber(data[3]),
                    tonumber(data[4])
                ))
             then
                return false
            end
        end,
        ["blowvehicle"] = function(player, vehicle)
            setTimer(blowVehicle, 100, 1, vehicle)
        end,
        ["destroyvehicle"] = function(player, vehicle)
            setTimer(destroyElement, 100, 1, vehicle)
        end
    },
    resource = {
        ["start"] = function(resource)
            startResource(resource, true)
        end,
        ["restart"] = function(resource)
            restartResource(resource)
        end,
        ["stop"] = function(resource)
            stopResource(resource)
        end,
        ["setsetting"] = function(resource, setting, value)
            if (setting and value) then
                set("*" .. getResourceName(resource) .. "." .. setting, value)
                requestSync(client, SYNC_RESOURCE, getResourceName(resource))
            end
        end
    },
    server = {
        ["setgame"] = function(game)
            if (not setGameType(tostring(game))) then
                outputChatBox("Error setting game type.", client, 255, 0, 0)
                return false
            end
            requestSync(client, SYNC_SERVER)
            return true, tostring(game)
        end,
        ["setmap"] = function(map)
            if (not setMapName(tostring(map))) then
                outputChatBox("Error setting map name.", client, 255, 0, 0)
                return false
            end
            requestSync(client, SYNC_SERVER)
            return true, tostring(map)
        end,
        ["settime"] = function(minutes, seconds)
            if (not setTime(tonumber(minutes), tonumber(seconds))) then
                outputChatBox("Error setting time.", client, 255, 0, 0)
                return false
            end
            return true, tostring(minutes) .. ":" .. tostring(seconds)
        end,
        ["setpassword"] = function(password)
            if (not password or password == "") then
                setServerPassword(nil)
                requestSync(client, SYNC_SERVER)
                return "resetpassword"
            elseif (string.len(password) > 32) then
                outputChatBox("Set password: 32 characters max", client, 255, 0, 0)
                return false
            elseif (not setServerPassword(password)) then
                outputChatBox("Error setting password", client, 255, 0, 0)
                return false
            end
            requestSync(client, SYNC_SERVER)
            return true, password
        end,
        ["setweather"] = function(id)
            if (not setWeather(tonumber(id))) then
                outputChatBox("Error setting weather.", client, 255, 0, 0)
                return false
            end
            return true, id .. " " .. getWeatherNameFromID(tonumber(id))
        end,
        ["blendweather"] = function(id)
            if (not setWeatherBlended(tonumber(id))) then
                outputChatBox("Error blending weather.", client, 255, 0, 0)
                return false
            end
            return true, id .. " " .. getWeatherNameFromID(tonumber(id))
        end,
        ["setgamespeed"] = function(speed)
            if (not setGameSpeed(tonumber(speed))) then
                outputChatBox("Error setting game speed.", client, 255, 0, 0)
                return false
            end
            return true, speed
        end,
        ["setgravity"] = function(gravity)
            if (setGravity(tonumber(gravity))) then
                for id, player in ipairs(getElementsByType("player")) do
                    setPedGravity(player, getGravity())
                end
            else
                outputChatBox("Error setting gravity.", client, 255, 0, 0)
                return false
            end
            return true, gravity
        end,
        ["setblurlevel"] = function(level)
            if (not setBlurLevel(level)) then
                outputChatBox("Error setting blur level.", client, 255, 0, 0)
                return false
            end
            return true, level
        end,
        ["setheathazelevel"] = function(level)
            if (not setHeatHaze(level)) then
                outputChatBox("Error setting heat haze level.", client, 255, 0, 0)
                return false
            end
            return true, level
        end,
        ["setwaveheight"] = function(height)
            if (not setWaveHeight(height)) then
                outputChatBox("Error setting wave height.", client, 255, 0, 0)
                return false
            end
            return true, height
        end,
        ["setfpslimit"] = function(limit)
            if (not setFPSLimit(limit)) then
                outputChatBox("Error setting fps limit.", client, 255, 0, 0)
                return false
            end
            return true, limit
        end,
        ["setworldproperty"] = function(property, enabled)
            if (enabled) then
                local v = enabled == "on" or enabled == "enabled" or enabled == "true"
                return setWorldSpecialPropertyEnabled(property, v), iif(v, "enabled", "disabled"), property
            else
                return false
            end
        end,
        ["setglitch"] = function(glitch, enabled)
            if (enabled) then
                local v = enabled == "on" or enabled == "enabled" or enabled == "true"
                return setGlitchEnabled(glitch, v), iif(v, "enabled", "disabled"), glitch
            else
                return false
            end
        end,
        ["shutdown"] = function()
            shutdown("triggered by "..getPlayerName(client))
        end,
        ["clearchat"] = function()
            clearChatBox()
            return true
        end,
        ["setconfig"] = function(configData)
            for k,v in pairs(configData) do
                setServerConfigSetting(k,v, true)
            end
            return true
        end
    },
    admin = {},
    bans = {}
}