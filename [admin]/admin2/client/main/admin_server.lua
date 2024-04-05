--[[**********************************
*
*   Multi Theft Auto - Admin Panel
*
*   client\main\admin_server.lua
*
*   Original File by lil_Toady
*
**************************************]]
aServerTab = {
    Weathers = {},
    WeatherMax = 255,
    glitches = {
        QuickReload = 'Quick Reload',
        FastMove = 'Fast Move',
        FastFire = 'Fast Fire',
        CrouchBug = 'Crouch Bug',
        HighCloseRangeDamage = 'High Close Range Damage',
        HitAnim = 'Hit Anim',
        FastSprint = 'Fast Sprint',
        BadDrivebyHitBox = 'Bad Driveby Hit Box',
        QuickStand = 'Quick Stand',
        KickoutOfVehicle_OnModelReplace = 'Kickout Of Vehicle On Model Replace'
    },
    worldproperties = {
        HoverCars = 'Hover Cars',
        AirCars = 'Air Cars',
        ExtraBunny = 'Extra Bunny',
        ExtraJump = 'Extra Jump',
        RandomFoliage = 'Random Foliage',
        SniperMoon = 'Sniper Moon',
        ExtraAirResistance = 'Extra Air Resistance',
        UnderWorldWarp = 'Under World Warp',
        VehiclesSunGlare = "Vehicles Sun Glare",
        CoronaZTest = "Corona Z Test",
        WaterCreatures = "Water Creatures",
        BurnFlippedCars = "Burn Flipped Cars",
        FireBallDestruct = "Fire Ball Destruct"
    }
}

function aServerTab.Create(tab)
    aServerTab.Tab = tab

    guiCreateHeader(0.02, 0.015, 0.30, 0.035, "Server info:", true, tab)
    aServerTab.Server = guiCreateLabel(0.03, 0.060, 0.40, 0.035, "Server: Unknown", true, tab)
    aServerTab.Password = guiCreateLabel(0.03, 0.105, 0.40, 0.035, "Password: None", true, tab)
    aServerTab.GameType = guiCreateLabel(0.03, 0.150, 0.40, 0.035, "Game Type: None", true, tab)
    aServerTab.MapName = guiCreateLabel(0.03, 0.195, 0.40, 0.035, "Map Name: None", true, tab)
    aServerTab.Players = guiCreateLabel(0.03, 0.240, 0.20, 0.035, "Players: 0/0", true, tab)
    aServerTab.SetPassword = guiCreateButton(0.42, 0.060, 0.18, 0.04, "Set Password", true, tab, "setpassword")
    aServerTab.ResetPassword = guiCreateButton(0.42, 0.105, 0.18, 0.04, "Reset Password", true, tab, "setpassword")
    aServerTab.SetGameType = guiCreateButton(0.42, 0.150, 0.18, 0.04, "Set Game Type", true, tab, "setgame")
    aServerTab.SetMapName = guiCreateButton(0.42, 0.195, 0.18, 0.04, "Set Map Name", true, tab, "setmap")
    aServerTab.Shutdown = guiCreateButton(0.42, 0.240, 0.18, 0.04, "Shutdown", true, tab, "shutdown")
    aServerTab.ClearChat = guiCreateButton(0.42, 0.285, 0.18, 0.04, "Clear Chat", true, tab, "clearchat")
    guiCreateHeader(0.02, 0.305, 0.30, 0.035, "Server properties:", true, tab)
    aServerTab.WeatherCurrent =
        guiCreateLabel(
        0.03,
        0.350,
        0.45,
        0.035,
        "Current Weather: " .. getWeather() .. " (" .. getWeatherNameFromID(getWeather()) .. ")",
        true,
        tab
    )
    aServerTab.Weather = guiCreateComboBox(0.35, 0.3425, 0.25, 0.50, "Weather", true, tab)
    aServerTab.WeatherSet = guiCreateButton(0.50, 0.395, 0.10, 0.04, "Set", true, tab, "setweather")
    aServerTab.WeatherBlend = guiCreateButton(0.35, 0.395, 0.135, 0.04, "Blend", true, tab, "blendweather")

    local th, tm = getTime()
    aServerTab.TimeCurrent = guiCreateLabel(0.03, 0.440, 0.25, 0.035, "Time: " .. th .. ":" .. tm, true, tab)
    aServerTab.TimeH = guiCreateEdit(0.35, 0.440, 0.055, 0.04, "12", true, tab)
    aServerTab.TimeM = guiCreateEdit(0.425, 0.440, 0.055, 0.04, "00", true, tab)
    guiCreateLabel(0.415, 0.440, 0.05, 0.04, ":", true, tab)
    guiEditSetMaxLength(aServerTab.TimeH, 2)
    guiEditSetMaxLength(aServerTab.TimeM, 2)
    aServerTab.TimeSet = guiCreateButton(0.50, 0.440, 0.10, 0.04, "Set", true, tab, "settime")

    aServerTab.GravityCurrent =
        guiCreateLabel(0.03, 0.485, 0.28, 0.035, "Gravitation: " .. string.format("%.3f", getGravity()), true, tab)
    aServerTab.Gravity = guiCreateEdit(0.35, 0.485, 0.135, 0.04, "0.008", true, tab)
    aServerTab.GravitySet = guiCreateButton(0.50, 0.485, 0.10, 0.04, "Set", true, tab, "setgravity")

    aServerTab.SpeedCurrent = guiCreateLabel(0.03, 0.530, 0.30, 0.035, "Game Speed: " .. getGameSpeed(), true, tab)
    aServerTab.Speed = guiCreateEdit(0.35, 0.530, 0.135, 0.04, "1", true, tab)
    aServerTab.SpeedSet = guiCreateButton(0.50, 0.530, 0.10, 0.04, "Set", true, tab, "setgamespeed")

    aServerTab.BlurCurrent = guiCreateLabel(0.03, 0.575, 0.25, 0.035, "Blur Level: 36", true, tab)
    aServerTab.Blur = guiCreateEdit(0.35, 0.575, 0.135, 0.04, "36", true, tab)
    aServerTab.BlurSet = guiCreateButton(0.50, 0.575, 0.10, 0.04, "Set", true, tab, "setblurlevel")

    aServerTab.HeatHazeCurrent =
        guiCreateLabel(0.03, 0.620, 0.25, 0.035, "Heat Haze Level: " .. getHeatHaze(), true, tab)
    aServerTab.HeatHaze = guiCreateEdit(0.35, 0.620, 0.135, 0.04, "80", true, tab)
    aServerTab.HeatHazeSet = guiCreateButton(0.50, 0.620, 0.10, 0.04, "Set", true, tab, "setheathazelevel")
    guiSetEnabled(aServerTab.HeatHazeSet, true)

    aServerTab.WavesCurrent = guiCreateLabel(0.03, 0.665, 0.25, 0.035, "Wave Height: " .. getWaveHeight(), true, tab)
    aServerTab.Waves = guiCreateEdit(0.35, 0.665, 0.135, 0.04, "0", true, tab)
    aServerTab.WavesSet = guiCreateButton(0.50, 0.665, 0.10, 0.04, "Set", true, tab, "setwaveheight")

    local fpsLimit = getFPSLimit()
    aServerTab.FPSCurrent = guiCreateLabel(0.03, 0.710, 0.25, 0.035, "FPS Limit: "..fpsLimit, true, tab)
    aServerTab.FPS = guiCreateEdit(0.35, 0.710, 0.135, 0.04, fpsLimit, true, tab)
    aServerTab.FPSSet = guiCreateButton(0.50, 0.710, 0.10, 0.04, "Set", true, tab, "setfpslimit")

    aServerTab.ServerConf = guiCreateLabel(0.03, 0.755, 0.25, 0.035, "Server configuration", true, tab)
    aServerTab.ServerConfSet = guiCreateButton(0.35, 0.755, 0.25, 0.04, "Change", true, tab, "setserverconf")
    aServerConfig.Open()

    guiCreateHeader(0.02, 0.8, 0.30, 0.035, "Automatic scripts:", true, tab)
    aServerTab.PingKickerCheck =
        guiCreateCheckBox(0.03, 0.845, 0.30, 0.04, "Ping Kicker", false, true, tab, "setpingkicker")
    aServerTab.PingKicker = guiCreateEdit(0.35, 0.845, 0.135, 0.04, "300", true, tab)
    aServerTab.PingKickerSet = guiCreateButton(0.50, 0.845, 0.10, 0.04, "Set", true, tab, "setpingkicker")
    guiSetEnabled(aServerTab.PingKicker, false)
    guiSetEnabled(aServerTab.PingKickerSet, false)

    aServerTab.FPSKickerCheck =
        guiCreateCheckBox(0.03, 0.89, 0.30, 0.04, "FPS Kicker", false, true, tab, "setfpskicker")
    aServerTab.FPSKicker = guiCreateEdit(0.35, 0.89, 0.135, 0.04, "5", true, tab)
    aServerTab.FPSKickerSet = guiCreateButton(0.50, 0.89, 0.10, 0.04, "Set", true, tab, "setfpskicker")
    guiSetEnabled(aServerTab.FPSKicker, false)
    guiSetEnabled(aServerTab.FPSKickerSet, false)

    aServerTab.IdleKickerCheck =
        guiCreateCheckBox(0.03, 0.935, 0.30, 0.04, "Idle Kicker", false, true, tab, "setidlekicker")
    aServerTab.IdleKicker = guiCreateEdit(0.35, 0.935, 0.135, 0.04, "10", true, tab)
    aServerTab.IdleKickerSet = guiCreateButton(0.50, 0.935, 0.10, 0.04, "Set", true, tab, "setidlekicker")
    guiSetEnabled(aServerTab.IdleKicker, false)
    guiSetEnabled(aServerTab.IdleKickerSet, false)

    guiCreateHeader(0.62, 0.015, 0.30, 0.035, "Glitches & Special world properties:", true, tab)

    aServerTab.Glitches_Properties = guiCreateGridList(0.62, 0.06, 0.37, 0.87, true, tab)
    guiGridListAddColumn(aServerTab.Glitches_Properties, "Name", 0.8)
    guiGridListAddColumn(aServerTab.Glitches_Properties, "Enabled", 0.3)

    guiGridListSetItemText(aServerTab.Glitches_Properties, guiGridListAddRow(aServerTab.Glitches_Properties), 1, "Glitches", true, false)

    for k,v in pairs(aServerTab.glitches) do
        aServerTab[k] = guiGridListAddRow(aServerTab.Glitches_Properties)
        guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab[k], 1, v, false, false)
        guiGridListSetItemData(aServerTab.Glitches_Properties, aServerTab[k], 1, {'setglitch',k:lower()})
    end

    guiGridListSetItemText(aServerTab.Glitches_Properties, guiGridListAddRow(aServerTab.Glitches_Properties), 1, "Special world properties", true, false)

    for k,v in pairs(aServerTab.worldproperties) do
        aServerTab[k] = guiGridListAddRow(aServerTab.Glitches_Properties)
        guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab[k], 1, v, false, false)
        guiGridListSetItemData(aServerTab.Glitches_Properties, aServerTab[k], 1, {'setworldproperty',k:lower()})
    end

    addEventHandler("onClientGUIClick", aServerTab.Tab, aServerTab.onClientClick)
    addEventHandler("onClientGUIDoubleClick", aServerTab.Glitches_Properties, aServerTab.onClientDoubleClick, false)
    addEventHandler('onClientGUIChanged', aServerTab.Tab, aServerTab.onClientChanged)
    addEventHandler(EVENT_SYNC, root, aServerTab.onClientSync)
    addEventHandler("onAdminRefresh", aServerTab.Tab, aServerTab.onRefresh)

    local node = xmlLoadFile("conf\\weathers.xml")
    if (node) then
        local weathers = 0
        while (true) do
            local weather = xmlFindChild(node, "weather", weathers)
            if (not weather) then
                break
            end
            local id = tonumber(xmlNodeGetAttribute(weather, "id"))
            local name = xmlNodeGetAttribute(weather, "name")
            aServerTab.Weathers[id] = name
            weathers = weathers + 1
        end
    end

    for i3 = 0,19 do
        guiComboBoxAddItem(aServerTab.Weather, i3 .. " (" .. getWeatherNameFromID(i3) .. ")")
    end

    sync(SYNC_SERVER)

    aServerTab.onRefresh()
end

function aServerTab.onClientClick(button)
    if (button == "left") then
        if (source == aServerTab.SetGameType) then
            local gametype = inputBox("Game Type", "Enter game type:")
            if (gametype) then
                triggerServerEvent("aServer", localPlayer, "setgame", gametype)
            end
        elseif (source == aServerTab.SetMapName) then
            local mapname = inputBox("Map Name", "Enter map name:")
            if (mapname) then
                triggerServerEvent("aServer", localPlayer, "setmap", mapname)
            end
        elseif (source == aServerTab.SetPassword) then
            local password = inputBox("Server password", "Enter server password: (32 characters max)")
            if (password and password:len() > 0) then
                triggerServerEvent("aServer", localPlayer, "setpassword", password)
            end
        elseif (source == aServerTab.ResetPassword) then
            if (messageBox("Reset password?", MB_QUESTION, MB_YESNO)) then
                triggerServerEvent("aServer", localPlayer, "setpassword", "")
            end
        elseif (source == aServerTab.Shutdown) then
            if (messageBox("Are you sure you want to shutdown the server?", MB_QUESTION, MB_YESNO )) then
                triggerServerEvent("aServer", localPlayer, "shutdown")
            end
        elseif (source == aServerTab.ClearChat) then
            triggerServerEvent("aServer", localPlayer, "clearchat", "")
        elseif (source == aServerTab.WeatherSet) then
            local weather = guiComboBoxGetSelected(aServerTab.Weather)
            if weather ~= -1 then
                triggerServerEvent("aServer", localPlayer, "setweather", gettok(guiComboBoxGetItemText(aServerTab.Weather, weather), 1, 32))
            else
                triggerServerEvent("aServer", localPlayer, "setweather", 0)
            end
        elseif (source == aServerTab.WeatherBlend) then
            local weather = guiComboBoxGetSelected(aServerTab.Weather)
            if weather ~= -1 then
                triggerServerEvent("aServer", localPlayer, "blendweather", gettok(guiComboBoxGetItemText(aServerTab.Weather, weather), 1, 32))
            else
                triggerServerEvent("aServer", localPlayer, "blendweather", 0)
            end
        elseif (source == aServerTab.TimeSet) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "settime",
                guiGetText(aServerTab.TimeH),
                guiGetText(aServerTab.TimeM)
            )
        elseif (source == aServerTab.SpeedSet) then
            local speed = guiGetText(aServerTab.Speed)
            if tonumber(speed) then
                triggerServerEvent("aServer", localPlayer, "setgamespeed", speed)
            elseif #speed == 0 then
                triggerServerEvent("aServer", localPlayer, "setgamespeed", 1)
                guiSetText(aServerTab.Speed, 1)
            end
        elseif (source == aServerTab.GravitySet) then
            local gravity = guiGetText(aServerTab.Gravity)
            if tonumber(gravity) then
                triggerServerEvent("aServer", localPlayer, "setgravity", gravity)
            elseif #gravity == 0 then
                triggerServerEvent("aServer", localPlayer, "setgravity", 0.008)
                guiSetText(aServerTab.Gravity, 0.008)
            end
        elseif (source == aServerTab.WavesSet) then
            local waves = guiGetText(aServerTab.Waves)
            if tonumber(waves) then
                triggerServerEvent("aServer", localPlayer, "setwaveheight", waves)
            elseif #waves == 0 then
                triggerServerEvent("aServer", localPlayer, "setwaveheight", 0)
                guiSetText(aServerTab.Waves, 0)
            end
        elseif (source == aServerTab.BlurSet) then
            local blur = guiGetText(aServerTab.Blur)
            if tonumber(blur) then
                triggerServerEvent("aServer", localPlayer, "setblurlevel", blur)
            elseif #blur == 0 then
                triggerServerEvent("aServer", localPlayer, "setblurlevel", 36)
                guiSetText(aServerTab.Blur, 36)
            end
        elseif (source == aServerTab.HeatHazeSet) then
            local heathaze = guiGetText(aServerTab.HeatHaze)
            if tonumber(heathaze) then
                triggerServerEvent("aServer", localPlayer, "setheathazelevel", heathaze)
            elseif #heathaze == 0 then
                triggerServerEvent("aServer", localPlayer, "setheathazelevel", 80)
                guiSetText(aServerTab.HeatHaze, 80)
            end
        elseif (source == aServerTab.FPSSet) then
            local fps = guiGetText(aServerTab.FPS)
            fps = fps and tonumber(fps) or 0
            if fps >= 25 and fps <= 32767 then
                -- Warn user of fps-related physics bugs when fps > 74, per notes at https://wiki.multitheftauto.com/wiki/SetFPSLimit
                if fps > 74 then
                    if not messageBox("74 FPS is the breaking point that opens the door to various severe GTA bugs related to physics, and setting a higher limit than this is not recommended. Are you sure you want to proceed?", MB_WARNING, MB_YESNO) then
                        guiSetText(aServerTab.FPS, getFPSLimit())
                        return
                    end
                end
                triggerServerEvent("aServer", localPlayer, "setfpslimit", fps)
            elseif fps == 0 then
                triggerServerEvent("aServer", localPlayer, "setfpslimit", 74) -- 74 is default
                guiSetText(aServerTab.FPS, 74)
            else
                messageBox("Invalid FPS limit: range is 25 - 32767, or 0 for default.", MB_ERROR, MB_OK)
            end
        elseif (source == aServerTab.ServerConfSet) then
            aServerConfig.Open()
        elseif (source == aServerTab.QuickReload) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "quickreload",
                iif(guiCheckBoxGetSelected(aServerTab.QuickReload), "on", "off")
            )
        elseif (source == aServerTab.FastMove) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "fastmove",
                iif(guiCheckBoxGetSelected(aServerTab.FastMove), "on", "off")
            )
        elseif (source == aServerTab.FastFire) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "fastfire",
                iif(guiCheckBoxGetSelected(aServerTab.FastFire), "on", "off")
            )
        elseif (source == aServerTab.CrouchBug) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "crouchbug",
                iif(guiCheckBoxGetSelected(aServerTab.CrouchBug), "on", "off")
            )
        elseif (source == aServerTab.HighCloseRangeDamage) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "highcloserangedamage",
                iif(guiCheckBoxGetSelected(aServerTab.HighCloseRangeDamage), "on", "off")
            )
        elseif (source == aServerTab.HitAnim) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "hitanim",
                iif(guiCheckBoxGetSelected(aServerTab.HitAnim), "on", "off")
            )
        elseif (source == aServerTab.FastSprint) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "fastsprint",
                iif(guiCheckBoxGetSelected(aServerTab.FastSprint), "on", "off")
            )
        elseif (source == aServerTab.BadDrivebyHitBox) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "baddrivebyhitbox",
                iif(guiCheckBoxGetSelected(aServerTab.BadDrivebyHitBox), "on", "off")
            )
        elseif (source == aServerTab.QuickStand) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "quickstand",
                iif(guiCheckBoxGetSelected(aServerTab.QuickStand), "on", "off")
            )
        elseif (source == aServerTab.KickoutOfVehicle_OnModelReplace) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setglitch",
                "kickoutofvehicle_onmodelreplace",
                iif(guiCheckBoxGetSelected(aServerTab.KickoutOfVehicle_OnModelReplace), "on", "off")
            )
        elseif (source == aServerTab.HoverCars) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "hovercars",
                iif(guiCheckBoxGetSelected(aServerTab.HoverCars), "on", "off")
            )
        elseif (source == aServerTab.AirCars) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "aircars",
                iif(guiCheckBoxGetSelected(aServerTab.AirCars), "on", "off")
            )
        elseif (source == aServerTab.ExtraBunny) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "extrabunny",
                iif(guiCheckBoxGetSelected(aServerTab.ExtraBunny), "on", "off")
            )
        elseif (source == aServerTab.ExtraJump) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "extrajump",
                iif(guiCheckBoxGetSelected(aServerTab.ExtraJump), "on", "off")
            )
        elseif (source == aServerTab.RandomFoliage) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "randomfoliage",
                iif(guiCheckBoxGetSelected(aServerTab.RandomFoliage), "on", "off")
            )
        elseif (source == aServerTab.SniperMoon) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "snipermoon",
                iif(guiCheckBoxGetSelected(aServerTab.SniperMoon), "on", "off")
            )
        elseif (source == aServerTab.ExtraAirResistance) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "extraairresistance",
                iif(guiCheckBoxGetSelected(aServerTab.ExtraAirResistance), "on", "off")
            )
        elseif (source == aServerTab.UnderWorldWarp) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "underworldwarp",
                iif(guiCheckBoxGetSelected(aServerTab.UnderWorldWarp), "on", "off")
            )
        elseif (source == aServerTab.VehiclesSunGlare) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "vehiclesunglare",
                iif(guiCheckBoxGetSelected(aServerTab.VehiclesSunGlare), "on", "off")
            )
        elseif (source == aServerTab.CoronaZTest) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "coronaztest",
                iif(guiCheckBoxGetSelected(aServerTab.CoronaZTest), "on", "off")
            )
        elseif (source == aServerTab.WaterCreatures) then
            triggerServerEvent(
                "aServer",
                localPlayer,
                "setworldproperty",
                "watercreatures",
                iif(guiCheckBoxGetSelected(aServerTab.WaterCreatures), "on", "off")
            )
        end
    end
end

function aServerTab.onClientDoubleClick(button)
    if (button == "left") then
        local selectedRow = guiGridListGetSelectedItem(aServerTab.Glitches_Properties)
        if (selectedRow ~= -1) then
            local rowData = guiGridListGetItemData(aServerTab.Glitches_Properties, selectedRow, 1)
            if (rowData) then
                local isEnabled = guiGridListGetItemText(aServerTab.Glitches_Properties, selectedRow, 2) == "√"
                triggerServerEvent("aServer", localPlayer, rowData[1], rowData[2], iif(not isEnabled, "on", "off"))
            end
        end
    end
end

function aServerTab.onClientChanged()
    local actualText = guiGetText(source)
    local character = actualText:sub(#actualText, #actualText)
    if not tonumber(character) and character ~= '.' then
        guiSetText(source, actualText:sub(0, #actualText - 1))
    end
end

function aServerTab.onClientSync(type, table)
    if (type == SYNC_SERVER) then
        guiSetText(aServerTab.Server, "Server: " .. table["name"])
        guiSetText(aServerTab.Players, "Players: " .. #getElementsByType("player") .. "/" .. table["players"])
        guiSetText(aServerTab.Password, "Password: " .. getSensitiveText(table["password"] or "None"))
        guiSetText(aServerTab.GameType, "Game Type: " .. (table["game"] or "None"))
        guiSetText(aServerTab.MapName, "Map Name: " .. (table["map"] or "None"))
        aServerTab['currentPassword'] = table['password'] or nil
    end
end

function aServerTab.onRefresh()
    local th, tm = getTime()
    guiSetText(
        aServerTab.Players,
        "Players: " .. #getElementsByType("player") .. "/" .. gettok(guiGetText(aServerTab.Players), 2, 47)
    )
    guiSetText(aServerTab.TimeCurrent, "Time: " .. string.format("%02d:%02d", th, tm))
    guiSetText(aServerTab.GravityCurrent, "Gravitation: " .. string.format("%.3f", getGravity()))
    guiSetText(aServerTab.SpeedCurrent, "Game Speed: " .. getGameSpeed())
    guiSetText(
        aServerTab.WeatherCurrent,
        "Weather: " .. getWeather() .. " (" .. getWeatherNameFromID(getWeather()) .. ")"
    )
    guiSetText(aServerTab.BlurCurrent, "Blur Level: " .. getBlurLevel())
    guiSetText(aServerTab.HeatHazeCurrent, "Heat Haze Level: " .. getHeatHaze())
    guiSetText(aServerTab.WavesCurrent, "Wave Height: " .. getWaveHeight())
    guiSetText(aServerTab.FPSCurrent, "FPS Limit: " .. getFPSLimit())

    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.HoverCars, 2, isWorldSpecialPropertyEnabled("hovercars") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.AirCars, 2, isWorldSpecialPropertyEnabled("AirCars") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.ExtraBunny, 2, isWorldSpecialPropertyEnabled("extrabunny") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.ExtraJump, 2, isWorldSpecialPropertyEnabled("extrajump") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.RandomFoliage, 2, isWorldSpecialPropertyEnabled("randomfoliage") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.SniperMoon, 2, isWorldSpecialPropertyEnabled("snipermoon") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.ExtraAirResistance, 2, isWorldSpecialPropertyEnabled("extraairresistance") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.UnderWorldWarp, 2, isWorldSpecialPropertyEnabled("underworldwarp") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.VehiclesSunGlare, 2, isWorldSpecialPropertyEnabled("vehiclesunglare") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.CoronaZTest, 2, isWorldSpecialPropertyEnabled("coronaztest") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.WaterCreatures, 2, isWorldSpecialPropertyEnabled("watercreatures") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.BurnFlippedCars, 2, isWorldSpecialPropertyEnabled("burnflippedcars") and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.FireBallDestruct, 2, isWorldSpecialPropertyEnabled("fireballdestruct") and "√" or "", false, false)

    triggerServerEvent("aServerGlitchRefresh", localPlayer)
end

addEvent("aClientRefresh", true)
addEventHandler("aClientRefresh", localPlayer, function(quickreload, fastmove, fastfire, crouchbug, highcloserangedamage, hitanim, fastsprint, baddrivebyhitbox, quickstand, kickout)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.QuickReload, 2, quickreload and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.FastMove, 2, fastmove and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.FastFire, 2, fastfire and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.CrouchBug, 2, crouchbug and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.HighCloseRangeDamage, 2, highcloserangedamage and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.HitAnim, 2, hitanim and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.FastSprint, 2, fastsprint and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.BadDrivebyHitBox, 2, baddrivebyhitbox and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.QuickStand, 2, quickstand and "√" or "", false, false)
    guiGridListSetItemText(aServerTab.Glitches_Properties, aServerTab.KickoutOfVehicle_OnModelReplace, 2, kickout and "√" or "", false, false)
end)

function getWeatherNameFromID(weather)
    return iif(aServerTab.Weathers[weather], aServerTab.Weathers[weather], "Unknown")
end