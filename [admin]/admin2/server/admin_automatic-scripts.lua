--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_automatic-scripts.lua
*
*	Original File by lil_Toady
*
**************************************]]

addEvent("aRequestAutomaticScripts", true)
addEvent("aAutomaticScriptKick", true)

local aAllScripts = {"pingkicker", "fpskicker", "idlekicker"}

local aAutoScripts = {}

for k, v in pairs(aAllScripts) do
    aAutoScripts[v] = {
        toggle = function(state, onStart)
            if (state == get(("#%s_state"):format(v))) then
                return false
            end
            if set(("#%s_state"):format(v), state) then
                if (not onStart) then
                    triggerClientEvent(root, "aOnAutomaticScriptChange", resourceRoot, v, {
                        state = get(("#%s_state"):format(v)),
                        limit = get(("#%s"):format(v)),
                    })
                end
                return true
            end
            return false
        end,
        changeValue = function(newValue)
            if (newValue == get(("#%s"):format(v))) then
                return false
            end
            triggerClientEvent(root, "aOnAutomaticScriptChange", resourceRoot, v, {
                state = get(("#%s_state"):format(v)),
                limit = get(("#%s"):format(v)),
            })
        end
    }
end

function toggleAutomaticScript(scriptName, state, onStart)
    if (not aAutoScripts[scriptName]) or (not aAutoScripts[scriptName].toggle) then
        return false
    end
    return aAutoScripts[scriptName].toggle(state, onStart)
end

function changeAutomaticScriptValue(scriptName, newValue)
    if set(("#%s"):format(scriptName), newValue) then
        triggerClientEvent(root, "aOnAutomaticScriptChange", resourceRoot, scriptName, {
            state = get(("#%s_state"):format(scriptName)),
            limit = newValue,
        })
        return true
    end
    return false
end

addEventHandler(
    "aAutomaticScriptKick",
    root,
    function(reason)
        if isElement(client) then
            kickPlayer(client, reason)
        end
    end
)

addEventHandler(
    "onResourceStart",
    resourceRoot,
    function()
        for scriptName in pairs(aAutoScripts) do
            if get(("%s_state"):format(scriptName)) then
                toggleAutomaticScript(scriptName, true, true)
            end
        end
    end
)

addEventHandler(
    "aRequestAutomaticScripts",
    resourceRoot,
    function()
        local infos = {}
        for k, v in pairs(aAllScripts) do
            infos[v] = {
                state = get(("#%s_state"):format(v)),
                limit = get(("#%s"):format(v)),
            }
        end
        triggerClientEvent(client, "aReceiveAutoScripts", client, infos)
    end
)
