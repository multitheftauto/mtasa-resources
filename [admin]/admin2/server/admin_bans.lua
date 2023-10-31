--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	server/admin_bans.lua
*
*	Original File by lil_Toady
*
**************************************]]
local aBans = {
    List = {}
}

addEventHandler(
    "onResourceStart",
    resourceRoot,
    function()
        for i, ban in ipairs(getBans()) do
            aBans.List[aBans.GenerateID(ban)] = ban
        end
    end
)

addEventHandler(
    "onBan",
    root,
    function(ban)
        local id = aBans.GenerateID(ban)
        aBans.List[id] = ban

        data = {
            type = "a",
            id = id,
            ban = getBanData(ban)
        }

        requestSync(root, SYNC_BAN, data)
    end
)

addEventHandler(
    "onPlayerBan",
    root,
    function(ban)
        local id = aBans.GenerateID(ban)
        aBans.List[id] = ban

        data = {
            type = "a",
            id = id,
            ban = getBanData(ban)
        }

        requestSync(root, SYNC_BAN, data)
    end
)

addEventHandler(
    "onUnban",
    root,
    function(ban)
        for id, b in pairs(aBans.List) do
            if (b == ban) then
                data = {
                    type = "d",
                    id = id
                }

                requestSync(root, SYNC_BAN, data)

                aBans.List[id] = nil
            end
        end
    end
)

function aBans.GenerateID(ban)
    local id = getBanTime(ban)
    if (not id or id == 0) then
        id = math.random(1, 1000000)
    end
    while (aBans.List[id]) do
        id = id + 1
    end
    return tostring(id)
end

function getBansList()
    return aBans.List
end

function getBanData(ban)
    t = {}

    t.nick = getBanNick(ban) or nil
    t.ip = getBanIP(ban) or nil
    t.serial = getBanSerial(ban) or nil
    t.username = getBanUsername(ban) or nil
    t.banner = getBanAdmin(ban) or nil
    t.reason = getBanReason(ban) or nil
    t.time = getBanTime(ban) or nil
    t.unban = getUnbanTime(ban) or nil
    if (not t.unban or not t.time or t.unban <= t.time) then
        t.unban = nil
    end

    return t
end

local function handleBanRequest(action, data)
    -- TODO: add commands 'ban' and 'unban'
    -- Basic security check
    if client and source ~= client then
        return
    end
    
    -- Permissions check
    if not hasObjectPermissionTo(source, "command."..action) then
        outputChatBox("Access denied for '" .. tostring(action) .. "'", source, 255, 168, 0)
        return
    end

    -- Add ban
    if action == "ban" then
        local ban
        if isElement(data.player) then
            ban = banPlayer(data.player, data.ip ~= "" and true, false, data.serial ~= "" and true, source, data.reason, data.duration)
        else
            ban = addBan(data.ip ~= "" and data.ip or nil, nil, data.serial ~= "" and data.serial or nil, source, data.reason, data.duration)
            if data.playerName then
                setBanNick(ban, data.playerName)
            end
        end
        -- Unlikely to occur, but advise admin if ban failed for some reason
        if not ban then
            outputChatBox("Ban action failed - check ban details.", source, 255, 0, 0)
            return
        end
        -- Log this action
        if isElement(data.player) then
            aAction("bans", "banplayer", source, data.player, data.reason or "None")
        else
            aAction("bans", "addban", source, nil, data.ip or "None", data.serial or "None")
        end
    -- Remove ban
    elseif action == "unban" then
        local ban = aBans.List[data]

        -- Unlikely to occur, but advise admin if ban failed for some reason
        if not ban then
            outputChatBox("Ban action failed - check ban details.", source, 255, 0, 0)
            return
        end

        if ban then
            local banData = getBanData(ban)
            removeBan(ban, source)
            aAction("bans", "unban", source, nil, banData.ip or "None", banData.serial or "None")
        end
    end
end

addEvent(EVENT_BAN, true)
addEventHandler(EVENT_BAN, root, handleBanRequest)