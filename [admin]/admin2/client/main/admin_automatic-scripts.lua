--[[**********************************
*
*   Multi Theft Auto - Admin Panel
*
*   client\main\admin_server.lua
*
*   Original File by lil_Toady
*
**************************************]]
addEvent("aOnAutomaticScriptChange", true)
addEvent("aReceiveAutoScripts", true)

local aAutoScripts = {}

aAutoScripts["pingkicker"] = {
    state = nil,
    timer = nil,
    limit = 300,
    checkInterval = 3000,
    toggle = function(state)
        if isElement(aServerTab.PingKickerCheck) then
            guiCheckBoxSetSelected(aServerTab.PingKickerCheck, state)
        end
        if isElement(aServerTab.PingKicker) then
            guiSetText(aServerTab.PingKicker, aAutoScripts["pingkicker"].limit)
        end
    end,
    execute = function()
        local myPing = getPlayerPing(localPlayer)
        if (myPing > aAutoScripts["pingkicker"].limit) then
            triggerServerEvent("aAutomaticScriptKick", localPlayer, ("ping exceeded the limit (%i > %i)"):format(myPing, aAutoScripts["pingkicker"].limit))
        end
    end
}

aAutoScripts["fpskicker"] = {
    state = nil,
    timer = nil,
    limit = 10,
    checkInterval = 3000,
    toggle = function(state)
        if isElement(aServerTab.FPSKickerCheck) then
            guiCheckBoxSetSelected(aServerTab.FPSKickerCheck, state)
        end
        if isElement(aServerTab.FPSKicker) then
            guiSetText(aServerTab.FPSKicker, aAutoScripts["fpskicker"].limit)
        end
    end,
    execute = function()
        local myFPS = getCurrentFPS(localPlayer)
        if (myFPS < aAutoScripts["fpskicker"].limit) then
            triggerServerEvent("aAutomaticScriptKick", localPlayer, ("fps below the limit (%i < %i)"):format(myFPS, aAutoScripts["fpskicker"].limit))
        end
    end
}

aAutoScripts["fpskicker"] = {
    state = nil,
    timer = nil,
    limit = 10,
    checkInterval = 3000,
    toggle = function(state)
        if isElement(aServerTab.FPSKickerCheck) then
            guiCheckBoxSetSelected(aServerTab.FPSKickerCheck, state)
        end
        if isElement(aServerTab.FPSKicker) then
            guiSetText(aServerTab.FPSKicker, aAutoScripts["fpskicker"].limit)
        end
    end,
    execute = function()
        local myFPS = getCurrentFPS(localPlayer)
        if (myFPS < aAutoScripts["fpskicker"].limit) then
            triggerServerEvent("aAutomaticScriptKick", localPlayer, ("fps below the limit (%i < %i)"):format(myFPS, aAutoScripts["fpskicker"].limit))
        end
    end
}

aAutoScripts["idlekicker"] = {
    state = nil,
    timer = nil,
    limit = 60,
    checkInterval = 3000,
    lastAction = getTickCount(),
    toggle = function(state)
        if isElement(aServerTab.IdleKickerCheck) then
            guiCheckBoxSetSelected(aServerTab.IdleKickerCheck, state)
        end
        if isElement(aServerTab.IdleKicker) then
            guiSetText(aServerTab.IdleKicker, aAutoScripts["idlekicker"].limit)
        end
    end,
    execute = function()
        local idleTime = (getTickCount() - aAutoScripts["idlekicker"].lastAction)
        local max = aAutoScripts["idlekicker"].limit * 60000
        if (idleTime > max) then
            triggerServerEvent("aAutomaticScriptKick", localPlayer, ("more than %i minutes afk"):format(aAutoScripts["idlekicker"].limit))
        end
    end
}

function toggleAutomaticScript(scriptName, state)
    if (not aAutoScripts[scriptName]) then
        return false
    end
    if (state == aAutoScripts[scriptName].state) then
        return false
    end
    if state then
        aAutoScripts[scriptName].timer = setTimer(aAutoScripts[scriptName].execute, aAutoScripts[scriptName].checkInterval, 0)
    else
        if isTimer(aAutoScripts[scriptName].timer) then
            killTimer(aAutoScripts[scriptName].timer)
        end
        aAutoScripts[scriptName].timer = nil
    end
    aAutoScripts[scriptName].state = state
end

function getAutomaticScriptInfo(scriptName, info)
    return aAutoScripts[scriptName] and aAutoScripts[scriptName][info] or false
end

addEventHandler(
    "aOnAutomaticScriptChange",
    resourceRoot,
    function(scriptName, info)
        if (not aAutoScripts[scriptName]) then
            return false
        end
        aAutoScripts[scriptName].limit = info.limit
        toggleAutomaticScript(scriptName, info.state)
    end
)
addEventHandler(
    "aReceiveAutoScripts",
    localPlayer,
    function(info)
        for k, v in pairs(info) do
            if aAutoScripts[k] then
                aAutoScripts[k].limit = v.limit
                toggleAutomaticScript(k, v.state)
            end
        end
    end
)
addEventHandler(
    "onClientResourceStart",
    resourceRoot,
    function()
        triggerServerEvent("aRequestAutomaticScripts", resourceRoot)
    end
)

local fps = 0

function getCurrentFPS()
    return fps
end

addEventHandler("onClientPreRender", root, function(delta)
    fps = (1 / delta) * 1000
end)

local function detectAction()
    aAutoScripts["idlekicker"].lastAction = getTickCount()
end
addEventHandler("onClientKey", root, detectAction)
addEventHandler("onClientCursorMove", root, detectAction)
