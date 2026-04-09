--[[**********************************
*
*   Multi Theft Auto - Admin Panel
*
*   server/admin_server.lua
*
*   Original File by lil_Toady
*
**************************************]]
_types = {"player", "team", "vehicle", "resource", "bans", "server", "admin"}

aPlayers = {}
aLogMessages = {}
aInteriors = {}
aStats = {}
aReports = {}
aWeathers = {}

local AUTOMATIC_SCRIPT_CHECK_INTERVAL = 5000
local AUTOMATIC_SCRIPT_JOIN_GRACE = 60000
local AUTOMATIC_SCRIPT_FPS_STALE_TIME = 10000
local AUTOMATIC_SCRIPT_CONSECUTIVE_VIOLATIONS = 3

function getAutomaticScriptSetting(name)
    return tonumber(get("#" .. name)) or 0
end

function resetAutomaticScriptViolation(player, name)
    local automaticScripts = aPlayers[player] and aPlayers[player].automaticScripts
    if automaticScripts then
        automaticScripts[name] = 0
    end
end

function addAutomaticScriptViolation(player, name)
    local automaticScripts = aPlayers[player] and aPlayers[player].automaticScripts
    if not automaticScripts then
        return 0
    end

    automaticScripts[name] = (automaticScripts[name] or 0) + 1
    return automaticScripts[name]
end

function kickPlayerByAutomaticScript(player, reason)
    outputServerLog("ADMIN: Automatic script kicked " .. getPlayerName(player) .. " (" .. reason .. ")")
    kickPlayer(player, reason)
end

function checkAutomaticScriptsForPlayer(player)
    local playerData = aPlayers[player]
    if not playerData then
        return
    end

    if (getTickCount() - (playerData.joinTick or 0)) < AUTOMATIC_SCRIPT_JOIN_GRACE then
        resetAutomaticScriptViolation(player, "pingkicker")
        resetAutomaticScriptViolation(player, "fpskicker")
        return
    end

    local pingLimit = getAutomaticScriptSetting("pingkicker")
    if pingLimit > 0 then
        local ping = getPlayerPing(player)
        if ping > pingLimit then
            if addAutomaticScriptViolation(player, "pingkicker") >= AUTOMATIC_SCRIPT_CONSECUTIVE_VIOLATIONS then
                kickPlayerByAutomaticScript(player, string.format("Ping too high (%d > %d)", ping, pingLimit))
                return
            end
        else
            resetAutomaticScriptViolation(player, "pingkicker")
        end
    else
        resetAutomaticScriptViolation(player, "pingkicker")
    end

    local idleLimit = getAutomaticScriptSetting("idlekicker")
    if idleLimit > 0 then
        local idleTime = getPlayerIdleTime(player) or 0
        if idleTime >= idleLimit * 60000 then
            kickPlayerByAutomaticScript(
                player,
                string.format("Idle for too long (%d min >= %d min)", math.floor(idleTime / 60000), idleLimit)
            )
            return
        end
    end

    local fpsLimit = getAutomaticScriptSetting("fpskicker")
    if fpsLimit > 0 then
        local currentFPS = playerData.currentFPS
        local lastFPSReport = playerData.lastFPSReport or 0
        local fpsReportAge = getTickCount() - lastFPSReport

        if currentFPS and fpsReportAge <= AUTOMATIC_SCRIPT_FPS_STALE_TIME then
            if currentFPS < fpsLimit then
                if addAutomaticScriptViolation(player, "fpskicker") >= AUTOMATIC_SCRIPT_CONSECUTIVE_VIOLATIONS then
                    kickPlayerByAutomaticScript(
                        player,
                        string.format("FPS too low (%d < %d)", math.floor(currentFPS + 0.5), fpsLimit)
                    )
                end
            else
                resetAutomaticScriptViolation(player, "fpskicker")
            end
        else
            resetAutomaticScriptViolation(player, "fpskicker")
        end
    else
        resetAutomaticScriptViolation(player, "fpskicker")
    end
end

function checkAutomaticScripts()
    for _, player in ipairs(getElementsByType("player")) do
        if isElement(player) then
            checkAutomaticScriptsForPlayer(player)
        end
    end
end

function aHandleIP2CUpdate()
    local playersToUpdate = false
    local playersTable = getElementsByType("player")

    for playerID = 1, #playersTable do
        local playerElement = playersTable[playerID]

        if not playersToUpdate then
            playersToUpdate = {}
        end

        updatePlayerCountry(playerElement)
        playersToUpdate[#playersToUpdate + 1] = playerElement
    end

    if not playersToUpdate then
        return
    end

    for playerID = 1, #playersTable do
        local playerElement = playersTable[playerID]
        local hasAdminPermission = hasObjectPermissionTo(playerElement, "general.adminpanel", false)

        if hasAdminPermission then
            
            for playerToUpdateID = 1, #playersToUpdate do
                local playerToUpdate = playersToUpdate[playerToUpdateID]

                triggerClientEvent(playerElement, "aClientPlayerJoin", playerToUpdate,
                    false, false, false, false,
                    aPlayers[playerToUpdate].country,
                    aPlayers[playerToUpdate].countryname
                )
            end
        end
    end
end

function aHandleIp2cSetting()
    local enabled = get("*useip2c")
    if enabled and enabled == "true" then
        local ip2c = getResourceFromName("ip2c")
        if ip2c and getResourceState(ip2c) == "loaded" then
            -- Persistent
            startResource(ip2c, true)
        end
    elseif (not enabled) or (enabled == "false") then
        local ip2c = getResourceFromName("ip2c")
        if ip2c and getResourceState(ip2c) == "running" then
            stopResource(ip2c)
        end
    end
end

addEventHandler(
    "onResourceStart",
    root,
    function(resource)
        if (resource ~= getThisResource()) then
            local resourceName = getResourceName(resource)
            for id, player in ipairs(getElementsByType("player")) do
                if (hasObjectPermissionTo(player, "general.tab_resources", false)) then
                    triggerClientEvent(player, "aClientResourceStart", root, resourceName)
                end
            end
            if resourceName == "ip2c" then
                aHandleIP2CUpdate()
            end
            return
        end

        aSetupACL()
        aSetupCommands()
        aSetupStorage()
        for id, player in ipairs(getElementsByType("player")) do
            aPlayerInitialize(player)
        end
        aHandleIp2cSetting()
        setTimer(checkAutomaticScripts, AUTOMATIC_SCRIPT_CHECK_INTERVAL, 0)
    end
)

addEventHandler(
    "onResourceStop",
    root,
    function(resource)
        if (resource ~= getThisResource()) then
            local resourceName = getResourceName(resource)
            for id, player in ipairs(getElementsByType("player")) do
                if (hasObjectPermissionTo(player, "general.tab_resources", false)) then
                    triggerClientEvent(player, "aClientResourceStop", root, resourceName)
                end
            end
            if resourceName == "ip2c" then
                aHandleIP2CUpdate()
            end
        else
            aReleaseStorage()
        end
        aclSave()
    end
)

addEventHandler(
    "onPlayerJoin",
    root,
    function()
        aPlayerInitialize(source)
        for id, player in ipairs(getElementsByType("player")) do
            if (hasObjectPermissionTo(player, "general.adminpanel", false)) then
                triggerClientEvent(
                    player,
                    "aClientPlayerJoin",
                    source,
                    getPlayerIP(source),
                    getPlayerUserName(source),
                    getPlayerSerial(source),
                    false,
                    aPlayers[source]["country"],
                    aPlayers[source]["countryname"]
                )
            end
        end
        setPedGravity(source, getGravity())
    end
)

addEventHandler(
    "onPlayerQuit",
    root,
    function()
        aPlayers[source] = nil
    end
)

function updatePlayerCountry(player)
    local isIP2CResourceRunning = getResourceFromName( "ip2c" )
    isIP2CResourceRunning = isIP2CResourceRunning and getResourceState( isIP2CResourceRunning ) == "running"
    aPlayers[player].country = isIP2CResourceRunning and exports.ip2c:getPlayerCountry(player) or false
    if aPlayers[player].country then
        aPlayers[player].countryname = isIP2CResourceRunning and exports.ip2c:getCountryName(aPlayers[player].country) or false
    end
end

function aPlayerInitialize(player)
    aPlayers[player] = {}
    aPlayers[player].money = getPlayerMoney(player)
    aPlayers[player].muted = isPlayerMuted(player)
    aPlayers[player].frozen = isElementFrozen(player)
    aPlayers[player].joinTick = getTickCount()
    aPlayers[player].currentFPS = false
    aPlayers[player].lastFPSReport = 0
    aPlayers[player].automaticScripts = {
        pingkicker = 0,
        fpskicker = 0
    }
    updatePlayerCountry(player)
end

addEvent("aClientPerformanceUpdate", true)
addEventHandler("aClientPerformanceUpdate", root,
    function(fps)
        local playerData = aPlayers[client]
        if not playerData then
            return
        end

        local numericFPS = tonumber(fps)
        if (not numericFPS) or numericFPS < 0 or numericFPS > 500 then
            return
        end

        playerData.currentFPS = numericFPS
        playerData.lastFPSReport = getTickCount()
    end
)

function aAction(type, action, admin, player, data, more)
    if (aLogMessages[type]) then
        function aStripString(string, hex)
            if not hex then
                hex = ""
            end
            string = tostring(string)
            string = string.gsub(string, "$admin", isAnonAdmin(admin) and "Admin" or (getPlayerName(admin) .. hex))
            string = string.gsub(string, "$data2", more or "")
            if (player) then
                string = string.gsub(string, "$player", getPlayerName(player) .. hex)
            end
            return string.gsub(string, "$data", (data and data .. hex or ""))
        end
        local node = aLogMessages[type][action]
        if (node) then
            local r, g, b = node["r"], node["g"], node["b"]
            local hex = RGBToHex(r, g, b)

            if (node["all"]) then
                outputChatBox(aStripString(node["all"], hex), root, r, g, b, true)
            end
            if (node["admin"]) and (admin ~= player) then
                outputChatBox(aStripString(node["admin"], hex), admin, r, g, b, true)
            end
            if (node["player"]) then
                outputChatBox(aStripString(node["player"], hex), player, r, g, b, true)
            end
            if (node["log"]) then
                outputServerLog(aStripString(node["log"]))
            end
        end
    end
end

addEvent("aTeam", true)
addEventHandler(
    "aTeam",
    root,
    function(action, name, ...)
        if (hasObjectPermissionTo(client, "command." .. action, false)) then
            local func = aFunctions.team[action]
            if (func) then
                local result, mdata1, mdata2 = func(name, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("team", action, client, false, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", client, 255, 168, 0)
        end
    end
)

addEvent("aPlayer", true)
addEventHandler(
    "aPlayer",
    root,
    function(player, action, ...)
        if (hasObjectPermissionTo(client, "command." .. action, false)) then
            local mdata1, mdata2
            local func = aFunctions.player[action]
            if (func) then
                local result
                result, mdata1, mdata2 = func(player, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("player", action, client, player, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", client, 255, 168, 0)
        end
    end
)

addEvent("aVehicle", true)
addEventHandler(
    "aVehicle",
    root,
    function(player, action, ...)
        local vehicle = getPedOccupiedVehicle(player)
        if (not vehicle) then
            return
        end
        if (hasObjectPermissionTo(client, "command." .. action, false)) then
            local mdata1, mdata2
            local func = aFunctions.vehicle[action]
            if (func) then
                local result
                result, mdata1, mdata2 = func(player, vehicle, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    local seats = getVehicleMaxPassengers(vehicle) + 1
                    for i = 0, seats do
                        local passenger = getVehicleOccupant(vehicle, i)
                        if (passenger) then
                            if ((passenger == player) and (getPedOccupiedVehicle(client) ~= vehicle)) then
                                aAction("vehicle", action, client, passenger, mdata)
                            else
                                aAction("vehicle", action, passenger, passenger, mdata1, mdata2)
                            end
                        end
                    end
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", client, 255, 168, 0)
        end
    end
)

addEvent("aResource", true)
addEventHandler(
    "aResource",
    root,
    function(name, action, ...)
        if (not name or not action) then
            return
        end
        local resource = getResourceFromName(name)
        if (not resource) then
            return
        end
        if (hasObjectPermissionTo(client, "command." .. action, false)) then
            local func = aFunctions.resource[action]
            if (func) then
                local result, mdata1, mdata2 = func(resource, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("resource", action, client, player, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", client, 255, 168, 0)
        end
    end
)

addEvent("aServer", true)
addEventHandler(
    "aServer",
    root,
    function(action, ...)
        if (hasObjectPermissionTo(client, "command." .. action, false)) then
            local func = aFunctions.server[action]
            if (func) then
                local result, mdata1, mdata2 = func(...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("server", action, client, player, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", client, 255, 168, 0)
        end
    end
)

addEvent("aServerGlitchRefresh", true)
addEventHandler(
    "aServerGlitchRefresh",
    root,
    function()
        triggerClientEvent(client, "aClientRefresh", client, isGlitchEnabled("quickreload"), isGlitchEnabled("fastmove"), isGlitchEnabled("fastfire"), isGlitchEnabled("crouchbug"), isGlitchEnabled("highcloserangedamage"), isGlitchEnabled("hitanim"), isGlitchEnabled("fastsprint"), isGlitchEnabled("baddrivebyhitbox"), isGlitchEnabled("quickstand"), isGlitchEnabled("kickoutofvehicle_onmodelreplace"))
    end
)

addEvent("aServerConfigRefresh", true)
addEventHandler("aServerConfigRefresh", root, function()
    triggerClientEvent(client, "aClientConfigRefresh", client, getServerConfigSetting("minclientversion"), getServerConfigSetting("recommendedclientversion"), getServerConfigSetting("bandwidth_reduction"), getServerConfigSetting("bullet_sync"), getServerConfigSetting("max_player_triggered_events_per_interval"), getServerConfigSetting("camera_sync_interval"), getServerConfigSetting("player_sync_interval"), getServerConfigSetting("player_triggered_event_interval"), getServerConfigSetting("keysync_analog_sync_interval"), getServerConfigSetting("keysync_mouse_sync_interval"), getServerConfigSetting("ped_sync_interval"), getServerConfigSetting("unoccupied_vehicle_sync_interval"), getServerConfigSetting("lightweight_sync_interval"))
end)

addEvent("aMessage", true)
addEventHandler(
    "aMessage",
    root,
    function(action, data)
        if (action == "new") then
            local time = getRealTime()
            local id = #aReports + 1
            aReports[id] = {}
            aReports[id].author = getPlayerName(client)
            aReports[id].category = tostring(data.category)
            aReports[id].subject = tostring(data.subject)
            aReports[id].text = tostring(data.message)
            aReports[id].time = string.format("%02d/%02d %02d:%02d", time.monthday, time.month+1, time.hour, time.minute)
            aReports[id].read = false
        elseif (action == "get") then
            triggerClientEvent(client, "aMessage", client, "get", aReports)
            return
        elseif (action == "read") then
            if (aReports[data]) then
                aReports[data].read = true
            end
            triggerClientEvent(client, "aMessage", client, "get", aReports)
        elseif (action == "delete") then
            local id = data[1]
            if (not aReports[id]) then
                outputChatBox("Error - Message not found.", client, 255, 0, 0)
                triggerClientEvent(client, "aMessage", client, "get", aReports)
                return
            end

            local message = data[2]
            for key, value in pairs(aReports[id]) do
                if (message[key] ~= value) then
                    outputChatBox("Error - Message mismatch, please try again.", client, 255, 0, 0)
                    triggerClientEvent(client, "aMessage", client, "get", aReports)
                    return
                end
            end

            table.remove(aReports, id)
            triggerClientEvent(client, "aMessage", client, "get", aReports)
        end
        for id, p in ipairs(getElementsByType("player")) do
            if (hasObjectPermissionTo(p, "general.adminpanel", false)) then
                triggerEvent(EVENT_SYNC, p, SYNC_MESSAGES)
            end
        end
    end
)

addEvent("aAdminChat", true)
addEventHandler(
    "aAdminChat",
    root,
    function(chat)
        local sender = client or source
        if not chat or #chat > (ADMIN_CHAT_MAXLENGTH or 255) then
            return
        end
        for _, player in ipairs(getElementsByType("player")) do
            if aPlayers[player] and aPlayers[player]["chat"] then
                triggerClientEvent(player, "aClientAdminChat", sender, chat)
            end
        end
    end
)

addEvent(EVENT_ANONYMOUS_UPDATE, true)
addEventHandler(
    EVENT_ANONYMOUS_UPDATE,
    root,
    function(state)
        if (hasObjectPermissionTo(client, "general.adminpanel", false)) then
            aPlayers[client]["AnonymousAdmin"] = state
        end
    end
)

addCommandHandler(get("adminChatCommandName"),
    function(thePlayer, cmd, ...)
        if (hasObjectPermissionTo(thePlayer, "general.tab_adminchat", false) and #arg > 0) then
            triggerEvent("aAdminChat", thePlayer, table.concat(arg, " "))
        end
    end
)

addEvent("aMapWarp", true)
addEventHandler(
    "aMapWarp",
    resourceRoot,
    function(x, y, z)
        local pX, pY, pZ = tonumber(x), tonumber(y), tonumber(z)
        if not pX or not pY or not pZ then
            return
        end
        
        if (not hasObjectPermissionTo(client, "general.adminMapWarp", false)) then
            return
        end

        setElementPosition(client, pX, pY, pZ)
        outputServerLog("ADMIN: ".. getPlayerName(client) .. " warped to map coordinates: " .. tostring(pX) .. ", " .. tostring(pY) .. ", " .. tostring(pZ))
    end
)
