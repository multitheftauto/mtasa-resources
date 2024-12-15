-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

RADIO_GUI = false

local function initializeRadioGUI()
	if (RADIO_GUI) then
		return false
	end

	local screenX, screenY = guiGetScreenSize()
	local radioWindowSizeX, radioWindowSizeY = 325, 380
	local radioWindowPosX, radioWindowPosY = (screenX - 325) / 1.1, (screenY - 380) / 1.4
	local allowRemoteSpeakers = getRadioSetting("allowRemoteSpeakers")

	RADIO_GUI = {}
	RADIO_GUI["Radio window"] = guiCreateWindow(radioWindowPosX, radioWindowPosY, radioWindowSizeX, radioWindowSizeY, "SPEAKER MUSIC (RADIO/MP3)", false)
	RADIO_GUI["Stream URLs gridlist"] = guiCreateGridList(10, 54, 304, 139, false, RADIO_GUI["Radio window"])
	RADIO_GUI["Stream URL edit"] = guiCreateEdit(10, 25, 304, 26, "http://stream.antenne.de:80/80er-kulthits", false, RADIO_GUI["Radio window"])
	RADIO_GUI["Create speaker button"] = guiCreateButton(10, 200, 150, 30, "CREATE SPEAKER", false, RADIO_GUI["Radio window"])
	RADIO_GUI["Destroy speaker button"] = guiCreateButton(162, 200, 150, 30, "DESTROY SPEAKER", false, RADIO_GUI["Radio window"])
	RADIO_GUI["Play/pause button"] = guiCreateButton(10, 235, 150, 30, "Play - Pause", false, RADIO_GUI["Radio window"])
	RADIO_GUI["Close button"] = guiCreateButton(162, 235, 150, 30, "Close", false, RADIO_GUI["Radio window"])

	RADIO_GUI["Toggle remote speakers checkbox"] = guiCreateCheckBox(15, 345, 180, 17, "Allow other players speakers", allowRemoteSpeakers, false, RADIO_GUI["Radio window"])
	RADIO_GUI["Toggle remote speakers label"] = guiCreateLabel(167, 345, 150, 17, "", false, RADIO_GUI["Radio window"])
	RADIO_GUI["Radio station URL column"] = guiGridListAddColumn(RADIO_GUI["Stream URLs gridlist"], "Radio station", 0.8)

	guiSetVisible(RADIO_GUI["Radio window"], false)
	guiEditSetMaxLength(RADIO_GUI["Stream URL edit"], RADIO_STREAM_URL_MAX_LENGTH)
	guiWindowSetSizable(RADIO_GUI["Radio window"], false)
	guiGridListSetSortingEnabled(RADIO_GUI["Stream URLs gridlist"], false)

	loadRadioStations()

	addEventHandler("onClientGUIClick", RADIO_GUI["Stream URLs gridlist"], onClientGUIClickLoadStationStreamURL, false)
	addEventHandler("onClientGUIClick", RADIO_GUI["Create speaker button"], onClientGUIClickCreateSpeaker, false)
	addEventHandler("onClientGUIClick", RADIO_GUI["Play/pause button"], onClientGUIClickToggleSpeaker, false)
	addEventHandler("onClientGUIClick", RADIO_GUI["Destroy speaker button"], onClientGUIClickDestroySpeaker, false)
	addEventHandler("onClientGUIClick", RADIO_GUI["Close button"], onClientGUIClickCloseRadioGUI, false)
	addEventHandler("onClientGUIClick", RADIO_GUI["Toggle remote speakers checkbox"], onClientGUIClickToggleRemoteSpeakers, false)

	for commandID = 1, #RADIO_COMMANDS do
		local commandName = RADIO_COMMANDS[commandID]

		addCommandHandler(commandName, toggleRadioGUI)
	end

	return true
end

function onClientGUIClickToggleRemoteSpeakers()
	local allowRemoteSpeakers = guiCheckBoxGetSelected(source)

	setRadioSetting("allowRemoteSpeakers", allowRemoteSpeakers)
	handleAllSpeakers()
end

function toggleRadioGUI()
	initializeRadioGUI()

	local guiState = guiGetVisible(RADIO_GUI["Radio window"])
	local guiNewState = (not guiState)

	guiSetVisible(RADIO_GUI["Radio window"], guiNewState)
	showCursor(guiNewState)
end
bindKey(RADIO_TOGGLE_KEY, "down", toggleRadioGUI)

function onClientResourceStartRadioGUI()
	if (not RADIO_SHOW_ON_START) then
		return false
	end

	toggleRadioGUI()
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStartRadioGUI)