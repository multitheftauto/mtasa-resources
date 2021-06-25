addEvent('onClientPlayerKillMessage', true)
addEventHandler('onClientPlayerKillMessage', root, function(killer, weapon, pR, pG, pB, kR, kG, kB)
    if wasEventCancelled() then return end
    outputKillMessage(source, pR, pG, pB, killer, kR, kG, kB, weapon)
end)

function outputKillMessage(player, pR, pG, pB, killer, kR, kG, kB, weapon)
    pR = tonumber(pR) or 255
    pG = tonumber(pG) or 255
    pB = tonumber(pB) or 255
    
    kR = tonumber(kR) or 255
    kG = tonumber(kG) or 255
    kB = tonumber(kB) or 255
    
    if (not player) or (not isElement(player)) or (getElementType(player) ~= 'player') then
        outputDebugString("outputKillMessage - Invalid 'wasted' player specified", 0, 0, 0, 100)
        return false
    end
    
    local killerName
    
    if isElement(killer) then
        if (getElementType(killer) ~= 'player') then
            outputDebugString("outputKillMessage - Invalid 'killer' player specified", 0, 0, 0, 100)
            return false
        end
        killerName = getPlayerName(killer)

    elseif (type(killer) == 'string') then
        killerName = killer
        
    end
    
    local message = {
        icon = getMessageIcon(weapon, killer),
        victim = {
            text = getPlayerName(player),
            color = {pR, pG, pB},
        }
    }
    
    if (type(killerName) == 'string') then
        message.killer = {
            text = killerName,
            color = {kR, kG, kB},
        }
    end
    
    return outputMessage(message)
end
