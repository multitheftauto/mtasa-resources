local activeBoards = {}

function createBoards()
	local rows, columns = config.boardRows, config.boardColumns
	--Create boards. Platform #1 is at SW Corner
	for i = 1, rows do --Nested to create rows and columns
		for j = 1, columns do
			activeBoards[#activeBoards + 1] = createObject(1697, 1540.122926 + 4.466064 * j, -1317.568237 + 5.362793 * i, 603.105469, math.deg(0.555), 0, 0)
		end
	end
	setElementDoubleSided(resourceRoot, true)
end

--- Returns active board elements
function getActiveBoardElements()
	return activeBoards
end

--- Returns active board element count
function getActiveBoardElementCount()
	return #activeBoards
end

function disableBoard(board)
	for i = 1, #activeBoards do
		if activeBoards[i] == board then
			table.remove(activeBoards, i)
			break
		end
	end
end

--- Returns a random board from the activeBoards table
function getRandomActiveBoard ()
	return activeBoards[math.random(#activeBoards)]
end

--- Resets the activeBoards table
function resetActiveBoards ()
	for i = #activeBoards, 1, -1  do
		table.remove(activeBoards, i)
	end
end

--- Destroy all board elements
function destroyBoards ()
	for k, v in ipairs(getElementsByType("object", resourceRoot)) do
		destroyElement(v)
	end
end