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

addEventHandler(
    "onResourceStart",
    root,
    function(resource)
        if (resource ~= getThisResource()) then
            for id, player in ipairs(getElementsByType("player")) do
                if (hasObjectPermissionTo(player, "general.tab_resources")) then
                    triggerClientEvent(player, "aClientResourceStart", root, getResourceName(resource))
                end
            end
            return
        end

        aSetupACL()
        aSetupCommands()
        aSetupStorage()

        for id, player in ipairs(getElementsByType("player")) do
            aPlayerInitialize(player)
        end
    end
)

addEventHandler(
    "onResourceStop",
    root,
    function(resource)
        if (resource ~= getThisResource()) then
            for id, player in ipairs(getElementsByType("player")) do
                if (hasObjectPermissionTo(player, "general.tab_resources")) then
                    triggerClientEvent(player, "aClientResourceStop", root, getResourceName(resource))
                end
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
            if (hasObjectPermissionTo(player, "general.adminpanel")) then
                triggerClientEvent(
                    player,
                    "aClientPlayerJoin",
                    source,
                    getPlayerIP(source),
                    getPlayerUserName(source),
                    getPlayerSerial(source),
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

function aPlayerInitialize(player)
    aPlayers[player] = {}
    aPlayers[player].country = getPlayerCountry(player)
    aPlayers[player].countryname = getPlayerCountryName(player)
    aPlayers[player].money = getPlayerMoney(player)
    aPlayers[player].muted = isPlayerMuted(player)
    aPlayers[player].frozen = isElementFrozen(player)
end

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
        if (hasObjectPermissionTo(source, "command." .. action)) then
            local func = aFunctions.team[action]
            if (func) then
                local result, mdata1, mdata2 = func(name, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("team", action, source, false, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0)
        end
    end
)

addEvent("aPlayer", true)
addEventHandler(
    "aPlayer",
    root,
    function(player, action, ...)
        if (hasObjectPermissionTo(source, "command." .. action)) then
            local mdata1 = ""
            local mdata2 = ""
            local func = aFunctions.player[action]
            if (func) then
                local result = nil
                result, mdata1, mdata2 = func(player, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("player", action, source, player, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0)
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
        if (hasObjectPermissionTo(source, "command." .. action)) then
            local mdata1 = ""
            local mdata2 = ""
            local func = aFunctions.vehicle[action]
            if (func) then
                local result = nil
                result, mdata1, mdata2 = func(player, vehicle, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    local seats = getVehicleMaxPassengers(vehicle) + 1
                    for i = 0, seats do
                        local passenger = getVehicleOccupant(vehicle, i)
                        if (passenger) then
                            if ((passenger == player) and (getPedOccupiedVehicle(source) ~= vehicle)) then
                                aAction("vehicle", action, source, passenger, mdata)
                            else
                                aAction("vehicle", action, passenger, passenger, mdata1, mdata2)
                            end
                        end
                    end
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0)
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
        if (hasObjectPermissionTo(source, "command." .. action)) then
            local func = aFunctions.resource[action]
            if (func) then
                local result, mdata1, mdata2 = func(resource, ...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("resource", action, source, player, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0)
        end
    end
)

addEvent("aServer", true)
addEventHandler(
    "aServer",
    root,
    function(action, ...)
        if (hasObjectPermissionTo(source, "command." .. action)) then
            local func = aFunctions.server[action]
            if (func) then
                local result, mdata1, mdata2 = func(...)
                if (result ~= false) then
                    if (type(result) == "string") then
                        action = result
                    end
                    aAction("server", action, source, player, mdata1, mdata2)
                end
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0)
        end
    end
)

addEvent("aServerGlitchRefresh", true)
addEventHandler(
    "aServerGlitchRefresh",
    root,
    function()
        triggerClientEvent("aClientRefresh", client, isGlitchEnabled("quickreload"), isGlitchEnabled("fastmove"), isGlitchEnabled("fastfire"), isGlitchEnabled("crouchbug"), isGlitchEnabled("highcloserangedamage"), isGlitchEnabled("hitanim"), isGlitchEnabled("fastsprint"), isGlitchEnabled("baddrivebyhitbox"), isGlitchEnabled("quickstand"))
    end
)

addEvent("aMessage", true)
addEventHandler(
    "aMessage",
    root,
    function(action, data)
        if (action == "new") then
            local time = getRealTime()
            local id = #aReports + 1
            aReports[id] = {}
            aReports[id].author = getPlayerName(source)
            aReports[id].category = tostring(data.category)
            aReports[id].subject = tostring(data.subject)
            aReports[id].text = tostring(data.message)
            aReports[id].time = time.monthday .. "/" .. time.month .. " " .. time.hour .. ":" .. time.minute
            aReports[id].read = false
        elseif (action == "get") then
            triggerClientEvent(source, "aMessage", source, "get", aReports)
        elseif (action == "read") then
            if (aReports[data]) then
                aReports[data].read = true
            end
        elseif (action == "delete") then
            if (aReports[data]) then
                table.remove(aReports, data)
            end
            triggerClientEvent(source, "aMessage", source, "get", aReports)
        else
            action = nil
        end
        for id, p in ipairs(getElementsByType("player")) do
            if (hasObjectPermissionTo(p, "general.adminpanel")) then
                triggerEvent("aSync", p, "messages")
            end
        end
    end
)

addEvent("aBans", true)
addEventHandler(
    "aBans",
    root,
    function(action, data)
        if (hasObjectPermissionTo(source, "command." .. action)) then
            local mdata = ""
            local more = ""
            if (action == "banip") then
                mdata = data
                if (not BanIP(data, source)) then
                    action = nil
                end
            elseif (action == "banserial") then
                mdata = data
                if (isValidSerial(data)) then
                    if (not BanSerial(string.upper(data), source)) then
                        action = nil
                    end
                else
                    outputChatBox("Error - Invalid serial", source, 255, 0, 0)
                    action = nil
                end
            elseif (action == "unbanip") then
                mdata = data
                if (not UnbanIP(data, source)) then
                    action = nil
                end
            elseif (action == "unbanserial") then
                mdata = data
                if (not UnbanSerial(data, source)) then
                    action = nil
                end
            else
                action = nil
            end

            if (action ~= nil) then
                aAction("bans", action, source, false, mdata, more)
                triggerEvent("aSync", source, "sync", "bans")
            end
            return true
        end
        outputChatBox("Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0)
        return false
    end
)

addEvent("aExecute", true)
addEventHandler(
    "aExecute",
    root,
    function(action, echo)
        if (hasObjectPermissionTo(source, "command.execute")) then
            local result = loadstring("return " .. action)()
            if (echo == true) then
                local restring = ""
                if (type(result) == "table") then
                    for k, v in pairs(result) do
                        restring = restring .. tostring(v) .. ", "
                    end
                    restring = string.sub(restring, 1, -3)
                    restring = "Table (" .. restring .. ")"
                elseif (type(result) == "userdata") then
                    restring = "Element (" .. getElementType(result) .. ")"
                else
                    restring = tostring(result)
                end
                outputChatBox("Command executed! Result: " .. restring, source, 0, 0, 255)
            end
            outputServerLog("ADMIN: " .. getPlayerName(source) .. " executed command: " .. action)
        end
    end
)

addEvent("aAdminChat", true)
addEventHandler(
    "aAdminChat",
    root,
    function(chat)
        for id, player in ipairs(getElementsByType("player")) do
            if (aPlayers[player]["chat"]) then
                triggerClientEvent(player, "aClientAdminChat", source, chat)
            end
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
