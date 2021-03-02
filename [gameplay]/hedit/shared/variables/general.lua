xmlFile = {}
xmlCache = {
    serversaves = {},
    clientsaves = {},
    resourcesaves = {}
}

guicache = {
    optionmenu_item = {}
}

client_config_file = "settings_c.xml"
client_handling_file = "saves/saves.xml" -- handlings_c.xml

validKeys = {
    "mouse1", "mouse2", "mouse3", "mouse4", "mouse5", "mouse_wheel_up", "mouse_wheel_down", "arrow_l", "arrow_u",
    "arrow_r", "arrow_d", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
    "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "num_0", "num_1", "num_2", "num_3", "num_4", "num_5",
    "num_6", "num_7", "num_8", "num_9", "num_mul", "num_add", "num_sep", "num_sub", "num_div", "num_dec", "F1", "F2", "F3", "F4", "F5",
    "F6", "F7", "F8", "F9", "F10", "F11", "F12", "backspace", "tab", "lalt", "ralt", "enter", "space", "pgup", "pgdn", "end", "home",
    "insert", "delete", "lshift", "rshift", "lctrl", "rctrl", "[", "]", "pause", "capslock", "scroll", ";", ",", "-", ".", "/", "#", "\\", "="
}

_G[getLocalPlayer and "clientside" or "serverside"] = true