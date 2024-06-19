config =  {
	boardRows = get("boardRows"), --Default:10  Number of rows to put on the board
	boardColumns = get("boardColumns"), --Default:8   Number of columns to put on the board
	winningBoards = get("winningBoards"), --Default:3   Number of boards that will not fall. Must be higher than board count!
	scoreLimit = get("scoreLimit"), --Default:10  wins required to win the fallout tournament default is 10
	callSpeedA = get("callSpeedA"), --Default:250 Call speed when 30 or more boards exist
	callSpeedB = get("callSpeedB"), --Default:500 Call speed when 29 to 15 boards exist
	callSpeedC = get("callSpeedC"), --Default:750 Call speed when 14 or less boards exist
	peacefulMode = get("peacefulMode") == "true" -- Default:true Disable player melee attack
}