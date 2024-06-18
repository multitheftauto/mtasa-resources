fadeCamera(true)
local gameOver = true
local shakingPieces = {}

function shakeOnRender()
    local currentTick = getTickCount()
    for object, originalTick in pairs(shakingPieces) do
        local tickDifference = currentTick - originalTick
        if tickDifference > 2400 then
            shakingPieces[object] = nil
        else
            --since newx/newy increases by 1 every 125ms, we can use this ratio to calculate a more accurate time
            local newx = tickDifference / 125 * 1
            local newy = tickDifference / 125 * 1
            if isElement(object) then
                setElementRotation(object, math.deg(0.555), 3 * math.cos(newy + 1), 3 * math.sin(newx + 1))
            end
        end
    end
end


addEvent("onClientShakePieces", true)
addEventHandler("onClientShakePieces", resourceRoot,
function ()
    -- we store the time when the piece was told to shake under a table, so multiple objects can be stored
    shakingPieces[source] = getTickCount()
end, true)

addEvent("onFalloutRoundEnd", true)
addEventHandler("onFalloutRoundEnd", resourceRoot,
function ()
    checkStatusTimer = nil
    if not gameOver then
        removeEventHandler("onClientRender", root, shakeOnRender)
        gameOver = true
    end
end, false)

function checkStatus()
    local x, y, z = getElementPosition(localPlayer)
    if z < 595 and (checkStatusTimer) then
        triggerServerEvent("onPlayerReportLoss", localPlayer)
        playSoundFrontEnd(4)
        killTimer(checkStatusTimer)
        checkStatusTimer = nil
    end
end

addEvent("onFalloutRoundStart", true)
addEventHandler("onFalloutRoundStart", resourceRoot,
function ()
    if gameOver then
        addEventHandler("onClientRender", root, shakeOnRender)
        gameOver = false
    end
    checkStatusTimer = setTimer(checkStatus, 500, 0)
end, false)