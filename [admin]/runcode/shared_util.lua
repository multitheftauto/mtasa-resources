-- This utility allows admins to do `_players.jbeta`
-- to return the player called "jbeta".
_players = setmetatable({}, {
    __index = function(_, name)
        return getPlayerFromName(name)
    end,

    -- Disable setting of items in _players
    __newindex = function() end,
})

function table.find(t, needle)
    for i, val in pairs(t) do
        if val == needle then
            return i
        end
    end
end
