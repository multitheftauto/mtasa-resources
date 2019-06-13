errorCode = {
	--startPoll error codes: 1x
	pollAlreadyRunning = 10,
	lessThanTwoOptions = 11,
	invalidTitle = 12,
	invalidVisibleTo = 13,
	noVoters = 14,
	startCancelled = 15,
	--stopPoll error codes: 2x
	noPollRunning = 20,
	stopCancelled = 21,
	--premade poll error codes: 3x
	invalidMap = 30,
	invalidPlayer = 31,
	twoMapsNeeded = 32,
	noGamemodeRunning = 33,
	mapIsntCompatible = 34,
	twoModesNeeded = 35,
	onlyOneCompatibleMap = 36
}

function getErrorCodes()
	return errorCode
end
