-- #######################################
-- ## Project: Internet radio			##
-- ## Authors: MTA contributors			##
-- ## Version: 1.0						##
-- #######################################

RADIO_TRACK_SCALE = 1
RADIO_TRACK_FONT = "default-bold"
RADIO_TRACK_COLOR = tocolor(150, 50, 150, 255)
RADIO_TRACK_BACKGROUND_COLOR = tocolor(0, 0, 0, 255)

RADIO_TOGGLE_KEY = "F3"
RADIO_SHOW_SPEAKER_OWNER_KEY = "lalt"
RADIO_SHOW_ON_START = false
RADIO_COMMANDS = {"sound", "music", "musica", "song", "radio", "speaker"}
RADIO_SETTINGS_PATH = "settings.json"

RADIO_SETTINGS_TEMPLATE = {
	["allowRemoteSpeakers"] = {
		defaultsTo = true,
		dataType = {
			["boolean"] = true,
		},
	},
}