--outputChatBox ( "Fallout Client Loaded", 255, 127, 0 ) --DEBUG
fadeCamera ( true ) --Remove MTA fade
gameOver = false
local shakingPieces = {}

function initGame()
	triggerServerEvent("serverClientLoad", root) -- Tells the server than the client is ready.
end
addEventHandler("onClientResourceStart", resourceRoot, initGame, false)

function shakeOnRender()
	if gameOver == false then
	    local currentTick = getTickCount()
	    for object,originalTick in pairs(shakingPieces) do
	        --calculate the amount of time that has passed in ms
	        local tickDifference = currentTick - originalTick
	        --if the time has exceeded its max
	        if tickDifference > 2400 then
				shakingPieces[object] = nil --remove it from the table loop
	        else
	            --since newx/newy increases by 1 every 125ms, we can use this ratio to calculate a more accurate time
	            local newx = tickDifference/125 * 1
	            local newy = tickDifference/125 * 1
	        	if isElement ( object ) then
					setElementRotation ( object, math.deg( 0.555 ), 3 * math.cos(newy + 1), 3 * math.sin(newx + 1) )
	        	end
			end
	    end
	end
end
addEventHandler ( "onClientRender", root, shakeOnRender )

function ShakePieces ( fallingPiece )
	--we store the time when the piece was told to shake under a table, so multiple objects can be stored
	shakingPieces[fallingPiece] = getTickCount()
end
addEvent("clientShakePieces",true) --For triggering from server
addEventHandler("clientShakePieces", root, ShakePieces)

function DetectionOff ( fallingPiece )
    checkStatusTimer = nil
	gameOver = true
end
addEvent("lossDetectionOff",true) --For triggering from server
addEventHandler("lossDetectionOff", root, DetectionOff)

function checkStatusB ( )
	local x, y, z =  getElementPosition ( localPlayer )
	if z < 595 and ( checkStatusTimer ) then
        --RootElement as localPlayer = source in server event
	    triggerServerEvent ( "serverReportLoss", localPlayer )
		playSoundFrontEnd(4)
		--outputChatBox ( "**************loss report**************" ) --DEBUG--DEBUG--DEBUG--DEBUG--DEBUG
	    killTimer ( checkStatusTimer )
	    checkStatusTimer = nil
	end
end

function checkHax ( )
	weapon = getPedWeapon ( localPlayer ) --anti cheat protection
	if weapon ~= 0 then
	   	setPedWeaponSlot ( localPlayer, 0 )
	   	triggerServerEvent ( "serverKillCheater", localPlayer )
	end
end
setTimer ( checkHax, 1000, 0 )

function checkStatus ( )
    gameOver = false --Reset as this is new game time
    checkStatusTimer = setTimer ( checkStatusB, 500, 0 )
end
addEvent("clientCheckStatus", true) --For triggering from server
addEventHandler("clientCheckStatus", root, checkStatus)
