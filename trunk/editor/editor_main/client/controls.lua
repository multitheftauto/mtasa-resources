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
toggle_cursor				=	"f",
select_target_keyboard		=	"mouse1",
select_target_mouse			=	"mouse2",
quick_rotate_increase		=	"mouse_wheel_up",
quick_rotate_decrease		=	"mouse_wheel_down",
zoom_in						=	"mouse_wheel_down",
zoom_out					=	"mouse_wheel_up",
mod_fast_speed				=	"lshift",
mod_slow_speed				=	"lalt",
mod_rotate					=	"lctrl",
high_sensitivity_mode		=	"e",
element_move_right			=	"arrow_r",
element_move_left			=	"arrow_l",
element_move_forward		=	"arrow_u",
element_move_backward		=	"arrow_d",
element_move_upwards		=	"pgup",
element_move_downwards		=	"pgdn",
camera_move_forwards		=	"w",
camera_move_backwards		=	"s",
camera_move_left			=	"a",
camera_move_right			=	"d",
toggle_gui_display			=	"F4",
reset_rotation				=	"r",
clone_drop_modifier			=	"lctrl",
clone_selected_element		=	"c",
pickup_selected_element		=	"F2",
destroy_selected_element	=	"delete",
undo						=	"z",
redo						=	"y",
drop_selected_element		=	"space",
properties_toggle			=	"F3",
edf_next					=	"mouse_wheel_up",
edf_prev					=	"mouse_wheel_down",
-- currentelements_confirm			=	"enter",
currentelements_up			=	"num_8",
currentelements_down		=	"num_2",
browser_up					=	"arrow_u",
browser_down				=	"arrow_d",
browser_confirm				=	"enter",
browser_zoom_in				=	"mouse_wheel_up",
browser_zoom_out			=	"mouse_wheel_down",
toggle_test					=	"F5",
-- clipboard_copy					=	"c",
-- clipboard_cut					=	"x",
-- clipboard_paste					=	"v",
}
cc = defaultControls
function getControls()
	return cc
end


function loadXMLControls()
	local controlsXML = xmlLoadFile ( "controls.xml" )
	if not controlsXML then 
		controlsXML = createDefaultXML() 
	end
	if not controlsXML then
		outputChatBox ( "Error: Controls could not be loaded", 255,0,0 )
		return
	end
	--
	cc = {}
	for nodeName,value in pairs(defaultControls) do
		local node = xmlFindChild ( controlsXML, nodeName, 0 )
		if ( node ) then
			cc[nodeName] = xmlNodeGetValue ( node )
		else
			xmlNodeSetValue(xmlCreateChild ( controlsXML, nodeName ), value)
			cc[nodeName] = value
		end
	end
end

function createDefaultXML()
	local xml = xmlCreateFile ( "controls.xml", "controls" )
	for nodeName,defaultValue in pairs(cc) do
		local node = xmlCreateChild ( xml, nodeName )
		xmlNodeSetValue ( node, defaultValue )
	end
	xmlSaveFile ( xml )
	return xml
end

addEventHandler("onClientResourceStart", getRootElement(), 
	function (resource)
		if resource == getResourceFromName("freecam") then
			freecam.setFreecamOption("key_fastMove", cc.mod_fast_speed)
			freecam.setFreecamOption("key_slowMove", cc.mod_slow_speed)
			freecam.setFreecamOption("key_forward", cc.camera_move_forwards)
			freecam.setFreecamOption("key_backward", cc.camera_move_backwards)
			freecam.setFreecamOption("key_left", cc.camera_move_left)
			freecam.setFreecamOption("key_right", cc.camera_move_right)
		elseif resource == thisResource then
			bindKey ("lctrl","both",blockMTAControls )
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