fadeCamera(true)
gameOver = false
local shakingPieces = {}

function initGame()
    triggerServerEvent("serverClientLoad", root)
end
addEventHandler("onClientResourceStart", resourceRoot, initGame, false)

function shakeOnRender()
    if gameOver == false then
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
end
addEventHandler("onClientRender", root, shakeOnRender)

function ShakePieces(fallingPiece)
    --we store the time when the piece was told to shake under a table, so multiple objects can be stored
    shakingPieces[fallingPiece] = getTickCount()
end
addEvent("clientShakePieces", true)
addEventHandler("clientShakePieces", root, ShakePieces)

function DetectionOff(fallingPiece)
    checkStatusTimer = nil
    gameOver = true
end
addEvent("lossDetectionOff", true)
addEventHandler("lossDetectionOff", root, DetectionOff)

function checkStatusB()
    local x, y, z = getElementPosition(localPlayer)
    if z < 595 and (checkStatusTimer) then
        triggerServerEvent("serverReportLoss", localPlayer)
        playSoundFrontEnd(4)
        killTimer(checkStatusTimer)
        checkStatusTimer = nil
    end
end

function checkStatus()
    gameOver = false
    checkStatusTimer = setTimer(checkStatusB, 500, 0)
end
addEvent("clientCheckStatus", true)
addEventHandler("clientCheckStatus", root, checkStatus)