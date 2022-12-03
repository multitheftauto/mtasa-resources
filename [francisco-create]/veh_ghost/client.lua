local how = 2
function ghostmode_on()
local playerVehicle = getPedOccupiedVehicle(localPlayer)
if(playerVehicle) then
if how == 2 then
for i,v in pairs(getElementsByType("vehicle")) do
setElementCollidableWith(v, playerVehicle, false)
end
how = 1
outputChatBox("activate")
else
for i,v in pairs(getElementsByType("vehicle")) do
setElementCollidableWith(v, playerVehicle, true)
end
how = 2
outputChatBox("deactivate")
end
end
end
addCommandHandler("ghost", ghostmode_on)