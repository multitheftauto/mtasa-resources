-- get string or default
function getString(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return tostring(result)
end

-- get number or default
function getNumber(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return tonumber(result)
end

-- get true or false or default
function getBool(var,default)
	local result = get(var)
	if not result then
		return default
	end
	return result == 'true'
end

-- get valid bind key/control
local validBindKeyValues = table.create({ "fire", "aim_weapon", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right",
    "zoom_in", "zoom_out", "change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "conversation_yes", "conversation_no",
    "group_control_forwards", "group_control_back", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
    "steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn", "sub_mission",
    "handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
    "special_control_down", "special_control_up", "mouse1", "mouse2", "mouse3", "mouse4", "mouse5", "mouse_wheel_up", "mouse_wheel_down", "arrow_l",
    "arrow_u", "arrow_r", "arrow_d", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
    "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "num_0", "num_1", "num_2", "num_3", "num_4", "num_5", "num_6", "num_7",
    "num_8", "num_9", "num_mul", "num_add", "num_sep", "num_sub", "num_div", "num_dec", "num_enter", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9",
    "f10", "f11", "f12", "backspace", "tab", "lalt", "ralt", "enter", "space", "pgup", "pgdn", "end", "home",
    "insert", "delete", "lshift", "rshift", "lctrl", "rctrl", "[", "]", "pause", "capslock", "scroll", ";", ",", "-", ".", "/", "#", "\\", "="
}, true)

function getBindKeyValue(var,default)
	local result = get(var)
	if not result then
		return default
    end

    result = result:lower()
    if not validBindKeyValues[result] then
        outputDebugString("Setting " .. var .. " has an invalid bind key value: " .. result , 2)
        return default
    end

	return result
end
