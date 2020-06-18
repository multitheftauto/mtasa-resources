--
--  startDeathmatchClient(): initializes the deathmatch client
--
local function startDeathmatchClient()
    -- inform server we are ready to play
    triggerServerEvent("onDeathmatchPlayerReady", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, startDeathmatchClient)