
g_Listener = setmetatable({}, {__mode = "k"})

function addListener(player)
    if not g_Listener[player] then
        g_Listener[player] = {
            category = "Server info",
            options = "",
            filter = ""
        }
    end
end

function removeListener(player)
    g_Listener[player] = nil
end

function isListening(player)
    return g_Listener[player] and true
end

function sendListenerStats(player, mode)
    local settings = g_Listener[player]

    if settings then
        player:triggerEvent("ipb.updateStats", player, mode, getPerformanceStats(settings.category, settings.options, settings.filter))
    end
end

addEventHandler("onPlayerQuit", root,
    function ()
        removeListener(source)
    end
)

addEvent("ipb.toggle", true)
addEventHandler("ipb.toggle", root,
    function (enabled, category)
        if enabled and client:hasIPBAccess() then
            addListener(client)

            if category then
                g_Listener[client].category = category
            end

            sendListenerStats(client, STATS_MODE_NEW_LISTENER)
        else
            removeListener(client)
        end
    end
)

addEvent("ipb.updateCategory", true)
addEventHandler("ipb.updateCategory", root,
    function (category)
        if not isListening(client) then
            return
        end

        g_Listener[client].category = category
        sendListenerStats(client, STATS_MODE_CATEGORY_CHANGE)
    end
)

addEvent("ipb.updateOptions", true)
addEventHandler("ipb.updateOptions", root,
    function (options)
        if not isListening(client) then
            return
        end

        g_Listener[client].options = options
        sendListenerStats(client, STATS_MODE_OPTIONS_CHANGE)
    end
)

addEvent("ipb.updateFilter", true)
addEventHandler("ipb.updateFilter", root,
    function (filter)
        if not isListening(client) then
            return
        end

        g_Listener[client].filter = filter
        sendListenerStats(client, STATS_MODE_FILTER_CHANGE)
    end
)

function updateListeners()
    for player in pairs(g_Listener) do
        if isElement(player) then
            sendListenerStats(player, STATS_MODE_REFRESH)
        else
            g_Listener[player] = nil
        end
    end
end
Timer(updateListeners, UPDATE_FREQUENCY, 0)
