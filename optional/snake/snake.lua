size = 0.02
direction = "right"
lastdir = "right"
pause = false
started = false
firstStart = false
checkbox = {}
positions = {}
	positions[1] = 0.1
	positions[2] = 10
	positions[3] = 20
	positions[4] = 30
	positions[5] = 40
	positions[6] = 50
	positions[7] = 60
	positions[8] = 70
	positions[9] = 80
	positions[10] = 90
function mainWindow ()
	if not gameWindow then
		firstStart = true
		gameWindow = guiCreateWindow (0.2, 0.2, 0.6, 0.6, "Snake!", true)
		gameArea = guiCreateGridList (0.3, 0.06, 0.7, 0.95, true, gameWindow)
		score = guiCreateLabel(0.05, 0.1, 0, 0, "Score: 0", true, gameWindow)
		speed1 = guiCreateLabel(0.1, 0.53, 0, 0, "Speed", true, gameWindow)
		guiSetFont(speed1, "default-bold-small")
		guiSetSize ( speed1, guiLabelGetTextExtent ( speed1 ), guiLabelGetFontHeight ( speed1 ), false )
		local sizeD = guiLabelGetFontHeight ( speed1 )
		difficulty = guiCreateProgressBar (0.05, 0.55, 0.20, 0.10, true, gameWindow)
		local x, y = guiGetPosition(difficulty, false)
		local sx, sy = guiGetSize(difficulty, false)
		guiSetPosition(difficulty, x, y + sizeD, false)
		guiProgressBarSetProgress(difficulty, 1)
		addEventHandler("onClientGUIClick", difficulty, function (button, state, posX, posY)
			local cX = guiGetScreenSize() * getCursorPosition()
			local pX, pY = guiGetPosition(difficulty, false)
			local x = cX / pX
			local x = x - 8
			local x = x * 28
			local progress = x
			if progress <= 1 then
				progress = 1
			elseif progress >= 100 then
				progress = 100
			end
			guiProgressBarSetProgress(difficulty, math.floor(progress))
		end, false)
		guiSetFont (score, "default-bold-small")
		startPause = guiCreateButton(0.05, 0.7, 0.20, 0.10, "Start!", true, gameWindow)
		addEventHandler("onClientGUIClick", startPause, startOrPauseSnake, false)
		guiSetSize ( score, guiLabelGetTextExtent ( score ), guiLabelGetFontHeight ( score ), false )
		currentScore = 0
		showCursor(true)
	else
		guiSetVisible(gameWindow, true)
		showCursor(true)
	end
	bindKey ("arrow_u", "down", function () direction = "up" end)
	bindKey ("arrow_r", "down", function () direction = "right" end)
	bindKey ("arrow_d", "down", function () direction = "down" end)
	bindKey ("arrow_l", "down", function () direction = "left" end)
	bindKey ("space", "down", startOrPauseSnake)
end
addCommandHandler("snake", mainWindow)
--progress == - 10 per progress
function startOrPauseSnake ()
local progress = guiProgressBarGetProgress(difficulty)
time = 450 - ( progress * 4.5 ) + 50
if started == false then
	started = true
	if gameOver then
		destroyElement(gameOver)
	end
	guiSetText(startPause, "Pause!")
	checkbox = {}
	direction = "right"
	lastdir = "right"
	currentScore = 0
	guiSetText (score, "Score: "..currentScore)
	checkbox[1] = guiCreateCheckBox(0.4,0.4, size, size, "", true, true, gameArea)
	checkbox[2] = guiCreateCheckBox(0.4-size,0.4, size, size, "", false, true, gameArea)
	checkbox[3] = guiCreateCheckBox(0.4-size-size,0.4, size, size, "", false, true, gameArea)
	checkbox[4] = guiCreateCheckBox(0.4-size-size-size,0.4, size, size, "", false, true, gameArea)
	x = positions[math.random(1, 10)] / 100
	y = positions[math.random(1, 10)] / 100
	fruit = guiCreateCheckBox (x, y, size, size, "", true, true, gameArea)
	movement = setTimer(moveit, time, 0)
	last = #checkbox
else
	if pause == false then
		guiSetText(startPause, "Start!")
		killTimer(movement)
		pause = true
	else
		guiSetText(startPause, "Pause!")
		movement = setTimer(moveit, time, 0)
		pause = false
	end
end
end

function stopTheSnake ()
if ( wannaStart ) then
	guiSetVisible(wannaStart, false)
	showCursor(false)
end
	if firstStart == false then return end
	if started == true and pause == false then
		killTimer(movement)
		pause = true
		guiSetText(startPause, "Start!")
		guiSetVisible(gameWindow, false)
		showCursor(false)
	elseif started == true and pause == true then
		guiSetVisible(gameWindow, false)
		showCursor(false)
	elseif started == false then
		guiSetVisible(gameWindow, false)
		showCursor(false)
	end
	unbindKey ("arrow_u", "down")
	unbindKey ("arrow_r", "down")
	unbindKey ("arrow_d", "down")
	unbindKey ("arrow_l", "down")
	unbindKey ("space", "down", startOrPauseSnake)
end
addEvent("stopSnakeC", true)
addEventHandler("stopSnakeC", getRootElement(), stopTheSnake)
addCommandHandler("stopsnake", stopTheSnake)

addEvent("startSnakeC", true)
addEventHandler("startSnakeC", getRootElement(), function ()
	if not wannaStart then
		showCursor(true)
		wannaStart = guiCreateWindow (0.4,0.3, 0, 0, "Play Snake?", true)
		guiSetSize(wannaStart, 250, 200, false)
		playText = guiCreateLabel(0.1, 0.3, 0.9,0.7, "Would you like to play some snake while you wait?", true, wannaStart)
		guiSetFont(playText, "default-bold-small")
		guiLabelSetHorizontalAlign(playText, "left", true)
		--guiSetSize ( playText, guiLabelGetTextExtent ( playText ), guiLabelGetFontHeight ( playText ), false )
		yeaplay = guiCreateButton(0.1, 0.8, 0.3, 0.2, "Yes", true, wannaStart)
		addEventHandler("onClientGUIClick", yeaplay, function ()
			guiSetVisible(wannaStart, false)
			mainWindow ()
		end, false)
		noplay = guiCreateButton(0.6, 0.8, 0.3, 0.2, "No", true, wannaStart)
		addEventHandler("onClientGUIClick", noplay, function ()
			guiSetVisible(wannaStart, false)
			showCursor(false)
		end, false)
	else
		guiSetVisible(wannaStart, true)
		showCursor(true)
	end
end)

posX = {}
posY = {}
function moveit ()
	--posX[1], posY[1] = guiGetPosition(checkbox[1], true)
		i = 0
	if direction == "right" then
		if lastdir == "left" then direction = "left"
		else
		lastdir = "right"
		for k,v in ipairs(checkbox) do
			i = i + 1
			if v == checkbox[1] then
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i] + (size ), posY[i], true)
				--posX, posY = guiGetPosition(v, true)
			else
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i-1], posY[i-1], true)
			end
		end
		end
	elseif direction == "down" then
		if lastdir == "up" then direction = "up"
		else
		lastdir = "down"
		for k,v in ipairs(checkbox) do
			i = i + 1
			if v == checkbox[1] then
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i], posY[i] + (size ), true)
				--posX, posY = guiGetPosition(v, true)
			else
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i-1], posY[i-1], true)
			end
		end
		end
	elseif direction == "left" then
		if lastdir == "right" then direction = "right"
		else
		lastdir = "left"
		for k,v in ipairs(checkbox) do
			i = i + 1
			if v == checkbox[1] then
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i] - (size), posY[i], true)
				--posX, posY = guiGetPosition(v, true)
			else
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i-1], posY[i-1], true)
			end
		end
		end
	elseif direction == "up" then
		if lastdir == "down" then direction = "down"
		else
		lastdir = "up"
		for k,v in ipairs(checkbox) do
			i = i + 1
			if v == checkbox[1] then
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i], posY[i] - (size ), true)
				--posX, posY = guiGetPosition(v, true)
			else
				posX[i], posY[i] = guiGetPosition(v, true)
				guiSetPosition(v, posX[i-1], posY[i-1], true)
			end
		end
		end
	end
	headX, headY = guiGetPosition(checkbox[1], true)
	if headX < -0.01 or headX >= 0.99 or headY < -0.01 or headY >= 0.99 then
		killTimer(movement)
		--outputChatBox ("Game Over")
		gameOver = guiCreateLabel (0.3, 0.5, 0, 0, "Game over!", true, gameArea)
		guiSetFont (gameOver, "default-bold-small")
		guiSetSize ( gameOver, guiLabelGetTextExtent ( gameOver ), guiLabelGetFontHeight ( gameOver ), false )
		last = #checkbox
		blinks = 0
		snakeVisible = true
		gameover1 = setTimer (destroySnake, 400, 10)
	end
	for k,v in ipairs(checkbox) do
		if v ~= checkbox[1] then
			local x, y = guiGetPosition(v, true)
			if x == headX and y == headY then
				killTimer(movement)
				--outputChatBox ("Game Over")
				gameOver = guiCreateLabel (0.3, 0.5, 0, 0, "Game over!", true, gameArea)
				guiSetSize ( gameOver, guiLabelGetTextExtent ( gameOver ), guiLabelGetFontHeight ( gameOver ), false )
				last = #checkbox
				guiSetFont (gameOver, "default-bold-small")
				blinks = 0
				snakeVisible = true
				gameover1 = setTimer (destroySnake, 400, 10)
			end
		end
	end
	fruitX, fruitY = guiGetPosition(fruit, true)
	if ( math.ceil(headX*100) == math.ceil(fruitX*100) or math.ceil(headX*100) -1 == math.ceil(fruitX*100) or math.ceil(headX*100) + 1 == math.ceil(fruitX*100) ) and ( math.floor(headY*100) == math.floor(fruitY*100) or math.floor(headY*100) - 1 == math.floor(fruitY*100) or math.floor(headY*100) + 1 == math.floor(fruitY*100) ) then
		destroyElement(fruit)
		last = #checkbox
		local newx, newy = guiGetPosition(checkbox[last], true)
		checkbox[last + 1] = guiCreateCheckBox(newx,newy, size, size, "", false, true, gameArea)
		currentScore = currentScore + 10
		guiSetText (score, "Score: "..currentScore)
		guiSetSize ( score, guiLabelGetTextExtent ( score ), guiLabelGetFontHeight ( score ), false )
		x = positions[math.random(1, 10)] / 100
		y = positions[math.random(1, 10)] / 100
		fruit = guiCreateCheckBox (x, y, size, size, "", true, true, gameArea)
	end
end

function destroySnake ()
	blinks = blinks + 1
	if snakeVisible == true then
		for k,v in ipairs(checkbox) do
			guiSetVisible(v, false)
		end
		snakeVisible = false
	else
		for k,v in ipairs(checkbox) do
			guiSetVisible(v, true)
		end
		snakeVisible = true
	end
	if blinks == 10 then
		for k,v in ipairs(checkbox) do
			destroyElement(v)
		end
		destroyElement(fruit)
		started = false
		guiSetText (startPause, "Start!")
		guiSetSize ( score, guiLabelGetTextExtent ( score ), guiLabelGetFontHeight ( score ), false )
	end
	--destroyElement(checkbox[last])
	--last = last - 1
end

addCommandHandler("guitest", function ()
	myLabel = guiCreateLabel(0.5,0.5, 1, 1, "TEST!", true)
	guiSetFont(myLabel, "test")
	local font = guiGetFont (myLabel)
	outputChatBox(""..font.."")
end)