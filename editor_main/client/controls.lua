local blockMTAControls
local thisResource = getThisResource()
local validKeys = {
["mouse1"]=true,["mouse2"]=true,["mouse3"]=true,["mouse4"]=true,["mouse5"]=true,
["mouse_wheel_up"]=true,["mouse_wheel_down "]=true,["arrow_l"]=true,["arrow_u"]=true,
["arrow_r"]=true,["arrow_d "]=true,["0"]=true,["1"]=true,["2"]=true,["3"]=true,["4"]=true,
["5"]=true,["6"]=true,["7"]=true,["8"]=true,["9"]=true,["a"]=true,["b"]=true,["c"]=true,
["d"]=true,["e"]=true,["f"]=true,["g"]=true,["h"]=true,["i"]=true,["j"]=true,["k"]=true,
["l"]=true,["m"]=true,["n"]=true,["o"]=true,["p"]=true,["q"]=true,["r"]=true,["s"]=true,
["t"]=true,["u"]=true,["v"]=true,["w"]=true,["x"]=true,["y"]=true,["z"]=true,["num_0"]=true,
["num_1"]=true,["num_2"]=true,["num_3"]=true,["num_4"]=true,["num_5"]=true,["num_6"]=true,
["num_7"]=true,["num_8"]=true,["num_9"]=true,["num_mul"]=true,["num_add"]=true,["num_sep"]=true,
["num_sub"]=true,["num_div"]=true,["num_dec "]=true,["F1"]=true,["F2"]=true,["F3"]=true,["F4"]=true,
["F5"]=true,["F6"]=true,["F7"]=true,["F8"]=true,["F9"]=true,["F10"]=true,["F11"]=true,["F12 "]=true,
["backspace"]=true,["tab"]=true,["lalt"]=true,["ralt"]=true,["enter"]=true,["space"]=true,["pgup"]=true,
["pgdn"]=true,["end"]=true,["home"]=true,["insert"]=true,["delete"]=true,["lshift"]=true,["rshift"]=true,
["lctrl"]=true,["rctrl"]=true,["["]=true,["]"]=true,["pause"]=true,["capslock"]=true,["scroll"]=true,
[";"]=true,[","]=true,["-"]=true,["."]=true,["/"]=true,["#"]=true,["\\"]=true,["="]=true }


local defaultControls = {

{	name="toggle_cursor",			key ="f",				friendlyName="Toggle Cursor"					},
{	name="select_target_keyboard",	key ="mouse1",			friendlyName="Select (Keyboard Mode)"			},
{	name="select_target_mouse",		key ="mouse2",			friendlyName="Select (Mouse Mode)"				},
{	name="quick_rotate_increase",	key ="mouse_wheel_up",	friendlyName="+Z / Yaw (Rotate Modifier)"		},
{	name="quick_rotate_decrease",	key ="mouse_wheel_down",friendlyName="-Z / Yaw (Rotate Modifier)"		},
{	name="zoom_in",					key ="mouse_wheel_down",friendlyName="Increase Select Distance"			},
{	name="zoom_out",				key ="mouse_wheel_up",	friendlyName="Decrease Select Distance"			},
{	name="mod_fast_speed",			key ="lshift",			friendlyName="Fast speed Modifier"				},
{	name="mod_slow_speed",			key ="lalt",			friendlyName="Slow speed Modifier"				},
{	name="mod_rotate",				key ="lctrl",			friendlyName="Rotate Modifier World Space"		},
{	name="mod_rotate_local",		key ="rctrl",			friendlyName="Rotate Modifier Local Space"		},
{	name="high_sensitivity_mode",	key ="e",				friendlyName="High Sensivity Mode"				},
{	name="element_move_right",		key ="arrow_r",			friendlyName="Move Element Right / Yaw"			},
{	name="element_move_left",		key ="arrow_l",			friendlyName="Move Element Left / Yaw"			},
{	name="element_move_forward",	key ="arrow_u",			friendlyName="Move Element Forward / Pitch"		},
{	name="element_move_backward",	key ="arrow_d",			friendlyName="Move Element Backward / Pitch"	},
{	name="element_move_upwards",	key ="pgup",			friendlyName="Move Element Upwards / Roll"		},
{	name="element_move_downwards",	key ="pgdn",			friendlyName="Move Element Downwards / Roll"	},
{	name="element_scale_up", 		key ="num_add",			friendlyName="Scale Element Up"					},
{	name="element_scale_down", 		key ="num_sub", 		friendlyName="Scale Element Down"				},
{	name="camera_move_forwards",	key ="w",				friendlyName="Camera forwards"					},
{	name="camera_move_backwards",	key ="s",				friendlyName="Camera backwards"					},
{	name="camera_move_left",		key ="a",				friendlyName="Camera strafe left"				},
{	name="camera_move_right",		key ="d",				friendlyName="Camera strafe right"				},
{	name="toggle_gui_display",		key ="F4",				friendlyName="Toggle GUI Display"				},
{	name="reset_rotation",			key ="r",				friendlyName="Reset Rotation (Rotate Modifier)"	},
{	name="clone_drop_modifier",		key ="lctrl",			friendlyName="Clone Drop Modifier"				},
{	name="clone_selected_element",	key ="c",				friendlyName="Clone Selected Element"			},
{	name="pickup_selected_element",	key ="F2",				friendlyName="Pickup selected element"			},
{	name="drop_selected_element",	key ="space",			friendlyName="Drop Selected Element"			},
{	name="destroy_selected_element",key ="delete",			friendlyName="Destroy element"					},
{	name="undo",					key ="z",				friendlyName="Undo"								},
{	name="redo",					key ="y",				friendlyName="Redo"								},
{	name="properties_toggle",		key ="F3",				friendlyName="Show Properties Box"				},
{	name="edf_next",				key ="mouse_wheel_up",	friendlyName="EDF Next resource"				},
{	name="edf_prev",				key ="mouse_wheel_down",friendlyName="EDF Prev resource"				},
-- {	name="currentelements_confirm",			key ="enter",		},
{	name="currentelements_up",		key ="num_8",			friendlyName="Current Elements Up"				},
{	name="currentelements_down",	key ="num_2",			friendlyName="Current Elements Down"			},
{	name="browser_up",				key ="arrow_u",			friendlyName="Model Browser Up"					},
{	name="browser_down",			key ="arrow_d",			friendlyName="Model Browser Down"				},
{	name="browser_confirm",			key ="enter",			friendlyName="Model Browser Confirm"			},
{	name="browser_zoom_in",			key ="mouse_wheel_up",	friendlyName="Model Browser Zoom In"			},
{	name="browser_zoom_out",		key ="mouse_wheel_down",friendlyName="Model Browser Zoom Out"			},
{	name="toggle_test",				key ="F5",				friendlyName="Toggle test mode"					},
{	name="toggle_basictest",		key ="F6",				friendlyName="Toggle basic test mode"			},
{	name="lock_selected_element",		key ="l",				friendlyName="Lock/Unlock Selected Element"			},
-- {	name="clipboard_copy"			key ="c",		},
-- {	name="clipboard_cut"			key ="x",		},
-- {	name="clipboard_paste"			key ="v",		},

}
cc = {}
for i,control in ipairs(defaultControls) do
	cc[control.name] = control.key
end

function getControls()
	return cc
end

--Turn all controls into commands
addEvent ( "onControlPressed" )
local function parseControls ( command, keyState )
	--Get the key name
	local key = ""
	for i,control in ipairs(defaultControls) do
		if control.friendlyName == command then
			key = control.name
		end
	end
	keyState = keyState or "down"
	triggerEvent ( "onControlPressed", localPlayer, key, keyState )
end

function processControls()
	for i,control in ipairs(defaultControls) do
		addCommandHandler ( control.friendlyName, parseControls )
		bindKey ( cc[control.name], "down", control.friendlyName )
		bindKey ( cc[control.name], "up", control.friendlyName, "up" )
	end
end

addEventHandler("onClientResourceStart", root,
	function (resource)
		if resource == getResourceFromName("freecam") then
			freecam.setFreecamOption("key_fastMove", cc.mod_fast_speed)
			freecam.setFreecamOption("key_slowMove", cc.mod_slow_speed)
			freecam.setFreecamOption("key_forward", cc.camera_move_forwards)
			freecam.setFreecamOption("key_backward", cc.camera_move_backwards)
			freecam.setFreecamOption("key_left", cc.camera_move_left)
			freecam.setFreecamOption("key_right", cc.camera_move_right)
			freecam.setFreecamOption("fov", cc.camera_move_right)
		elseif resource == thisResource then
			bindKey ("lctrl","both",blockMTAControls )
			processControls()
		end
	end
)

--Disable MTA controls when holding LCTRL
function blockMTAControls(key,state)
	if state == "down" then
		toggleAllControls(false,false,true)
	else
		toggleAllControls(true,false,true)
	end
end


