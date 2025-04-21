-- ghost_hider.lua (Client-Side)

-- Global variables
local ghostHide = false -- Flag to track whether the ghost is hidden
local g_Root = getRootElement()

-- Function to toggle the ghost visibility
function toggleGhostVisibility()
    if not playback then
        outputChatBox("#ff6666[GHOST HIDE] #ffffffNo ghost racer is active!", 255, 255, 255, true)
        return
    end

    ghostHide = not ghostHide
    local targetDimension = ghostHide and 2 or 0

    -- Hide/show the ghost's ped, vehicle, and blip
    if isElement(playback.ped) then
        setElementDimension(playback.ped, targetDimension)
    end
    if isElement(playback.vehicle) then
        setElementDimension(playback.vehicle, targetDimension)
    end
    local blip = getBlipAttachedTo(playback.ped)
    if blip then
        setElementDimension(blip, targetDimension)
    end

    -- Hide/show the nametag by removing/adding the draw handler
    if ghostHide then
        -- Remove the nametag drawing handler
        if playback.drawGhostNametag_HANDLER then
            removeEventHandler("onClientRender", g_Root, playback.drawGhostNametag_HANDLER)
            playback.drawGhostNametag_HANDLER = nil
            outputDebugString("Removed ghost nametag handler")
        end
    else
        -- Re-add the nametag drawing handler
        if not playback.drawGhostNametag_HANDLER then
            playback.drawGhostNametag_HANDLER = function() playback:drawGhostNametag(playback.nametagInfo) end
            addEventHandler("onClientRender", g_Root, playback.drawGhostNametag_HANDLER)
            outputDebugString("Added ghost nametag handler")
        end
    end

    -- Output a message to the player
    local message = ghostHide and "hidden" or "visible"
    outputChatBox("#ff6666[GHOST HIDE] #ffffffGhost racer is now " .. message, 255, 255, 255, true)
end

-- Bind the F3 key to toggle ghost visibility (F2 is already used by carhide)
bindKey("F3", "down", toggleGhostVisibility)

-- Function to get the blip attached to an element (copied from File 3)
function getBlipAttachedTo(elem)
    local elements = getAttachedElements(elem)
    for _, element in ipairs(elements) do
        if getElementType(element) == "blip" then
            return element
        end
    end
    return false
end

-- Ensure the ghost is shown when a new map starts
addEvent("onClientMapStarting", true)
addEventHandler("onClientMapStarting", g_Root, function()
    if ghostHide then
        toggleGhostVisibility() -- Reset to visible when a new map starts
    end
end)

-- Ensure the ghost is shown when the resource starts
addEventHandler("onClientResourceStart", getResourceRootElement(), function()
    ghostHide = false
end)
