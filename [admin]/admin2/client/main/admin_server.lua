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
        QuickStand = 'Quick Stand'
    },
    worldproperties = {
        HoverCars = 'Hover Cars',
        AirCars = 'Air Cars',
        ExtraBunny = 'Extra Bunny',
        ExtraJump = 'Extra Jump',
        RandomFoliage = 'Random Foliage',
        SniperMoon = 'Sniper Moon',
        ExtraAirResistance = 'Extra Air Resistance',
        UnderWorldWarp = 'Under World Warp'
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

    aServerTab.FPSCurrent = guiCreateLabel(0.03, 0.710, 0.25, 0.035, "FPS Limit: 36", true, tab)
    aServerTab.FPS = guiCreateEdit(0.35, 0.710, 0.135, 0.04, "36", true, tab)
    aServerTab.FPSSet = guiCreateButton(0.50, 0.710, 0.10, 0.04, "Set", true, tab, "setfpslimit")

    guiCreateHeader(0.02, 0.755, 0.30, 0.035, "Automatic scripts:", true, tab)
    aServerTab.PingKickerCheck =
        guiCreateCheckBox(0.03, 0.800, 0.30, 0.04, "Ping Kicker", false, true, tab, "setpingkicker")
    aServerTab.PingKicker = guiCreateEdit(0.35, 0.800, 0.135, 0.04, "300", true, tab)
    aServerTab.PingKickerSet = guiCreateButton(0.50, 0.800, 0.10, 0.04, "Set", true, tab, "setpingkicker")
    guiSetEnabled(aServerTab.PingKicker, false)
    guiSetEnabled(aServerTab.PingKickerSet, false)

    aServerTab.FPSKickerCheck =
        guiCreateCheckBox(0.03, 0.845, 0.30, 0.04, "FPS Kicker", false, true, tab, "setfpskicker")
    aServerTab.FPSKicker = guiCreateEdit(0.35, 0.845, 0.135, 0.04, "5", true, tab)
    aServerTab.FPSKickerSet = guiCreateButton(0.50, 0.845, 0.10, 0.04, "Set", true, tab, "setfpskicker")
    guiSetEnabled(aServerTab.FPSKicker, false)
    guiSetEnabled(aServerTab.FPSKickerSet, false)

    aServerTab.IdleKickerCheck =
        guiCreateCheckBox(0.03, 0.890, 0.30, 0.04, "Idle Kicker", false, true, tab, "setidlekicker")
    aServerTab.IdleKicker = guiCreateEdit(0.35, 0.890, 0.135, 0.04, "10", true, tab)
    aServerTab.IdleKickerSet = guiCreateButton(0.50, 0.890, 0.10, 0.04, "Set", true, tab, "setidlekicker")
    guiSetEnabled(aServerTab.IdleKicker, false)
    guiSetEnabled(aServerTab.IdleKickerSet, false)

    guiCreateHeader(0.65, 0.015, 0.30, 0.035, "Allowed glitches:", true, tab)
    local i = 1
    for k,v in pairs(aServerTab.glitches) do
        aServerTab[k] = guiCreateCheckBox(0.66, 0.015 + (0.045 * i), 0.40, 0.04, v, false, true, tab, "setglitch")
        guiSetEnabled(aServerTab[k], true)
        i = i + 1
    end

    local headerPosition = 0.060 + (0.045 * i)
    guiCreateHeader(0.65, headerPosition, 0.30, 0.035, "Special world properties:", true, tab)
    local i2 = 1
    for k,v in pairs(aServerTab.worldproperties) do
        aServerTab[k] = guiCreateCheckBox(0.66, headerPosition + (0.045 * i2), 0.40, 0.04, v, false, true, tab, 'setworldproperty')
        guiSetEnabled(aServerTab[k], true)
        i2 = i2 + 1
    end

    i,i2 = nil,nil

    addEventHandler("onClientGUIClick", aServerTab.Tab, aServerTab.onClientClick)
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

    for i = 0,19 do
        guiComboBoxAddItem(aServerTab.Weather, i .. " (" .. getWeatherNameFromID(i) .. ")")
    end

    sync(SYNC_SERVER)

    aServerTab.onRefresh()
end

function aServerTab.onClientClick(button)
    if (button == "left") then
        if (source == aServerTab.SetGameType) then
            local gametype = inputBox("Game Type", "Enter game type:")
            if (gametype) then
                triggerServerEvent("aServer", getLocalPlayer(), "setgame", gametype)
            end
        elseif (source == aServerTab.SetMapName) then
            local mapname = inputBox("Map Name", "Enter map name:")
            if (mapname) then
                triggerServerEvent("aServer", getLocalPlayer(), "setmap", mapname)
            end
        elseif (source == aServerTab.SetPassword) then
            local password = inputBox("Server password", "Enter server password: (32 characters max)")
            if (password and password:len() > 0) then
                triggerServerEvent("aServer", getLocalPlayer(), "setpassword", password)
            end
        elseif (source == aServerTab.ResetPassword) then
            if (messageBox("Reset password?", MB_QUESTION, MB_YESNO)) then
                triggerServerEvent("aServer", getLocalPlayer(), "setpassword", "")
            end
        elseif (source == aServerTab.Shutdown) then
            if (messageBox("Are you sure you want to shutdown the server?", MB_QUESTION, MB_YESNO )) then
                triggerServerEvent("aServer", getLocalPlayer(), "shutdown")
            end
        elseif (source == aServerTab.ClearChat) then
            triggerServerEvent("aServer", getLocalPlayer(), "clearchat", "")
        elseif (source == aServerTab.WeatherSet) then
            local weather = guiComboBoxGetSelected(aServerTab.Weather)
            if weather ~= -1 then
                triggerServerEvent("aServer", getLocalPlayer(), "setweather", gettok(guiComboBoxGetItemText(aServerTab.Weather, weather), 1, 32))
            else
                triggerServerEvent("aServer", getLocalPlayer(), "setweather", 0)
            end
        elseif (source == aServerTab.WeatherBlend) then
            local weather = guiComboBoxGetSelected(aServerTab.Weather)
            if weather ~= -1 then
                triggerServerEvent("aServer", getLocalPlayer(), "blendweather", gettok(guiComboBoxGetItemText(aServerTab.Weather, weather), 1, 32))
            else
                triggerServerEvent("aServer", getLocalPlayer(), "blendweather", 0)
            end
        elseif (source == aServerTab.TimeSet) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "settime",
                guiGetText(aServerTab.TimeH),
                guiGetText(aServerTab.TimeM)
            )
        elseif (source == aServerTab.SpeedSet) then
            local speed = guiGetText(aServerTab.Speed)
            if tonumber(speed) then
                triggerServerEvent("aServer", getLocalPlayer(), "setgamespeed", speed)
            elseif #speed == 0 then
                triggerServerEvent("aServer", getLocalPlayer(), "setgamespeed", 1)
                guiSetText(aServerTab.Speed, 1)
            end
        elseif (source == aServerTab.GravitySet) then
            local gravity = guiGetText(aServerTab.Gravity)
            if tonumber(gravity) then
                triggerServerEvent("aServer", getLocalPlayer(), "setgravity", gravity)
            elseif #gravity == 0 then
                triggerServerEvent("aServer", getLocalPlayer(), "setgravity", 0.008)
                guiSetText(aServerTab.Gravity, 0.008)
            end
        elseif (source == aServerTab.WavesSet) then
            local waves = guiGetText(aServerTab.Waves)
            if tonumber(waves) then
                triggerServerEvent("aServer", getLocalPlayer(), "setwaveheight", waves)
            elseif #waves == 0 then
                triggerServerEvent("aServer", getLocalPlayer(), "setwaveheight", 0)
                guiSetText(aServerTab.Waves, 0)
            end
        elseif (source == aServerTab.BlurSet) then
            local blur = guiGetText(aServerTab.Blur)
            if tonumber(blur) then
                triggerServerEvent("aServer", getLocalPlayer(), "setblurlevel", blur)
            elseif #blur == 0 then
                triggerServerEvent("aServer", getLocalPlayer(), "setblurlevel", 36)
                guiSetText(aServerTab.Blur, 36)
            end
        elseif (source == aServerTab.HeatHazeSet) then
            local heathaze = guiGetText(aServerTab.HeatHaze)
            if tonumber(heathaze) then
                triggerServerEvent("aServer", getLocalPlayer(), "setheathazelevel", heathaze)
            elseif #heathaze == 0 then
                triggerServerEvent("aServer", getLocalPlayer(), "setheathazelevel", 80)
                guiSetText(aServerTab.HeatHaze, 80)
            end
        elseif (source == aServerTab.FPSSet) then
            local fps = guiGetText(aServerTab.FPS)
            if tonumber(fps) then
                triggerServerEvent("aServer", getLocalPlayer(), "setfpslimit", fps)
            elseif #fps == 0 then
                triggerServerEvent("aServer", getLocalPlayer(), "setfpslimit", 36) -- 36 is default
                guiSetText(aServerTab.FPS, 36)
            end
        elseif (source == aServerTab.QuickReload) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "quickreload",
                iif(guiCheckBoxGetSelected(aServerTab.QuickReload), "on", "off")
            )
        elseif (source == aServerTab.FastMove) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "fastmove",
                iif(guiCheckBoxGetSelected(aServerTab.FastMove), "on", "off")
            )
        elseif (source == aServerTab.FastFire) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "fastfire",
                iif(guiCheckBoxGetSelected(aServerTab.FastFire), "on", "off")
            )
        elseif (source == aServerTab.CrouchBug) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "crouchbug",
                iif(guiCheckBoxGetSelected(aServerTab.CrouchBug), "on", "off")
            )
        elseif (source == aServerTab.HighCloseRangeDamage) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "highcloserangedamage",
                iif(guiCheckBoxGetSelected(aServerTab.HighCloseRangeDamage), "on", "off")
            )
        elseif (source == aServerTab.HitAnim) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "hitanim",
                iif(guiCheckBoxGetSelected(aServerTab.HitAnim), "on", "off")
            )
        elseif (source == aServerTab.FastSprint) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "fastsprint",
                iif(guiCheckBoxGetSelected(aServerTab.FastSprint), "on", "off")
            )
        elseif (source == aServerTab.BadDrivebyHitBox) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "baddrivebyhitbox",
                iif(guiCheckBoxGetSelected(aServerTab.BadDrivebyHitBox), "on", "off")
            )
        elseif (source == aServerTab.QuickStand) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setglitch",
                "quickstand",
                iif(guiCheckBoxGetSelected(aServerTab.QuickStand), "on", "off")
            )
        elseif (source == aServerTab.HoverCars) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "hovercars",
                iif(guiCheckBoxGetSelected(aServerTab.HoverCars), "on", "off")
            )
        elseif (source == aServerTab.AirCars) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "aircars",
                iif(guiCheckBoxGetSelected(aServerTab.AirCars), "on", "off")
            )
        elseif (source == aServerTab.ExtraBunny) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "extrabunny",
                iif(guiCheckBoxGetSelected(aServerTab.ExtraBunny), "on", "off")
            )
        elseif (source == aServerTab.ExtraJump) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "extrajump",
                iif(guiCheckBoxGetSelected(aServerTab.ExtraJump), "on", "off")
            )
        elseif (source == aServerTab.RandomFoliage) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "randomfoliage",
                iif(guiCheckBoxGetSelected(aServerTab.RandomFoliage), "on", "off")
            )
        elseif (source == aServerTab.SniperMoon) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "snipermoon",
                iif(guiCheckBoxGetSelected(aServerTab.SniperMoon), "on", "off")
            )
        elseif (source == aServerTab.ExtraAirResistance) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "extraairresistance",
                iif(guiCheckBoxGetSelected(aServerTab.ExtraAirResistance), "on", "off")
            )
        elseif (source == aServerTab.UnderWorldWarp) then
            triggerServerEvent(
                "aServer",
                getLocalPlayer(),
                "setworldproperty",
                "underworldwarp",
                iif(guiCheckBoxGetSelected(aServerTab.UnderWorldWarp), "on", "off")
            )
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
        guiSetText(aServerTab.Password, "Password: " .. (table["password"] or "None"))
        guiSetText(aServerTab.GameType, "Game Type: " .. (table["game"] or "None"))
        guiSetText(aServerTab.MapName, "Map Name: " .. (table["map"] or "None"))
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
    guiCheckBoxSetSelected(aServerTab.HoverCars, isWorldSpecialPropertyEnabled("hovercars"))
    guiCheckBoxSetSelected(aServerTab.AirCars, isWorldSpecialPropertyEnabled("aircars"))
    guiCheckBoxSetSelected(aServerTab.ExtraBunny, isWorldSpecialPropertyEnabled("extrabunny"))
    guiCheckBoxSetSelected(aServerTab.ExtraJump, isWorldSpecialPropertyEnabled("extrajump"))
    guiCheckBoxSetSelected(aServerTab.RandomFoliage, isWorldSpecialPropertyEnabled("randomfoliage"))
    guiCheckBoxSetSelected(aServerTab.SniperMoon, isWorldSpecialPropertyEnabled("snipermoon"))
    guiCheckBoxSetSelected(aServerTab.ExtraAirResistance, isWorldSpecialPropertyEnabled("extraairresistance"))
    guiCheckBoxSetSelected(aServerTab.UnderWorldWarp, isWorldSpecialPropertyEnabled("underworldwarp"))

    triggerServerEvent("aServerGlitchRefresh", localPlayer)
end

addEvent("aClientRefresh", true)
addEventHandler("aClientRefresh", localPlayer, function(quickreload, fastmove, fastfire, crouchbug, highcloserangedamage, hitanim, fastsprint, baddrivebyhitbox, quickstand)
    guiCheckBoxSetSelected(aServerTab.QuickReload, quickreload)
    guiCheckBoxSetSelected(aServerTab.FastMove, fastmove)
    guiCheckBoxSetSelected(aServerTab.FastFire, fastfire)
    guiCheckBoxSetSelected(aServerTab.CrouchBug, crouchbug)
    guiCheckBoxSetSelected(aServerTab.HighCloseRangeDamage, highcloserangedamage)
    guiCheckBoxSetSelected(aServerTab.HitAnim, hitanim)
    guiCheckBoxSetSelected(aServerTab.FastSprint, fastsprint)
    guiCheckBoxSetSelected(aServerTab.BadDrivebyHitBox, baddrivebyhitbox)
    guiCheckBoxSetSelected(aServerTab.QuickStand, quickstand)
end)

function getWeatherNameFromID(weather)
    return iif(aServerTab.Weathers[weather], aServerTab.Weathers[weather], "Unknown")
end
