local cache = {}
local IP2C_API_URL = "https://ip2c.org/?ip=%s" -- %s = IP
local CLEAR_CACHE_INTERVAL = 1000 * 60 * 60 * 4 -- 4 hours

-- return cache if exists
function getPlayerCountry(player)
    local IP = getPlayerIP(player)
    return cache[IP] or false
end

-- fetch country, cache result and trigger 'onPlayerCountryFetched' event with it
local function fetchCountry(player)
    local IP = getPlayerIP(player)

    if cache[IP] then
        triggerEvent("onPlayerCountryFetched", player, cache[IP])
    else
        fetchRemote(IP2C_API_URL:format(IP), "ip2c", 3, 5000, function(data, errno, player, IP)
            if (data and data ~= "ERROR") and (errno == 0) and isElement(player) then
                local status, code, longcode, name = unpack(split(data, ";"))

                -- status 0 - wronginput | 1 - success | 2 - unknown
                if status == "1" then
                    cache[IP] = { name = name, code = code, longcode = longcode }
                    triggerEvent("onPlayerCountryFetched", player, cache[IP])
                end
            end
        end, "", false, player, IP)
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    for i, player in ipairs(getElementsByType("player")) do
        fetchCountry(player)
    end

    addEventHandler("onPlayerJoin", root, function()
        fetchCountry(source)
    end)

    -- clear cache
    setTimer(function()
        local onlineIPs = {}
        for i, player in ipairs(getElementsByType("player")) do
            local IP = getPlayerIP(player)
            if cache[IP] then
                onlineIPs[IP] = cache[IP]
            end
        end
        cache = onlineIPs
    end, CLEAR_CACHE_INTERVAL, 0)
end)