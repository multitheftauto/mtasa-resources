--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_commands.lua
*
*	Original File by lil_Toady
*
**************************************]]
_commands = {}

function getPlayerWildcard(string)
    local player = getPlayerFromName(string)
    if (player) then
        return player
    end
    for id, plr in ipairs(getElementsByType("player")) do
        if (string.find(string.upper(getPlayerName(plr)), string.upper(string))) then
            return plr
        end
    end
    return false
end

-- Yet to be finished
function aSetupCommands()
    local node = xmlLoadFile("conf\\commands.xml")
    if (node) then
        for id, type in ipairs(_types) do
            local subnode = xmlFindChild(node, type, 0)
            if (subnode) then
                local commands = 0
                while (xmlFindChild(subnode, "command", commands) ~= false) do
                    local command = xmlFindChild(subnode, "command", commands)
                    local handler = xmlNodeGetAttribute(command, "handler")
                    local call = xmlNodeGetAttribute(command, "call")
                    local args = xmlNodeGetAttribute(command, "args")
                    _commands[handler] = {}
                    _commands[handler].type = type
                    _commands[handler].action = call
                    if (args) then
                        _commands[handler].args = args
                    end
                    addCommandHandler(handler, aCommand, true)
                    commands = commands + 1
                end
            end
        end
    end
end

function aCommand(admin, command, ...)
    if (get("consolecommands") ~= true) then
        return
    end
    local call = _commands[command]
    if (call) then
        if (hasObjectPermissionTo(admin, "command." .. call.action, false)) then
            arg2 = aCommandToArgs({...}, call.args)
            if (call.type == "player") then
                triggerEvent("aPlayer", admin, arg2[1], call.action, arg2[2], arg2[3])
            elseif (call.type == "vehicle") then
                triggerEvent("aVehicle", admin, arg2[1], call.action, arg2[2], arg2[3])
            else
                triggerEvent(
                    "a" .. string.upper(string.sub(call.type, 1, 1)) .. string.sub(call.type, 2),
                    admin,
                    call.action,
                    arg2[1],
                    arg2[2],
                    arg2[3],
                    arg2[4]
                )
            end
        else
            outputChatBox("Access denied for '" .. tostring(action) .. "'", admin, 255, 168, 0)
        end
    end
end

function aCommandToArgs(argv, args)
    for id, argt in ipairs(split(args, 44)) do
        if (argv[id]) then
            if (argt == "T") then
                argv[id] = getTeamFromName(argv[id])
            elseif (argt == "P") then
                argv[id] = getPlayerWildcard(argv[id])
            elseif (argt == "t") then
                argv[id] = {argv[id]}
            elseif (argt == "s") then
                argv[id] = tostring(argv[id])
            elseif (argt == "i") then
                argv[id] = tonumber(argv[id])
            elseif (argt == "t-") then
                local atable = {}
                for i = id, #argv do
                    table.insert(atable, argv[id])
                    table.remove(argv, id)
                end
                argv[id] = atable
            elseif (argt == "s-") then
                local string = ""
                for i = id, #argv do
                    string = string .. " " .. argv[i]
                    table.remove(argv, i)
                end
                argv[id] = string
            end
        end
    end
    return argv
end
