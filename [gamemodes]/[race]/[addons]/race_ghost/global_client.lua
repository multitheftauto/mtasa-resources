POSITION_PULSE = 200
KEYSPAM_LIMIT = 200
_DEGUG = false
g_Root = getRootElement()

keyNames = 	{ 	"vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right", "steer_forward", "steer_back", "accelerate",
				"brake_reverse", "horn", "sub_mission", "handbrake", "vehicle_look_left", "vehicle_look_right", "special_control_left",
				"special_control_right", "special_control_down", "special_control_up"
			}
analogNames = {
	vehicle_left = true, vehicle_right = true, steer_forward = true, steer_back = true, accelerate = true, brake_reverse = true,
	special_control_left = true, special_control_right = true, special_control_up = true, special_control_down = true
}
globalInfo = {
	bestTime = math.huge,
	racer = ""
}

function outputDebug( ... )
	if _DEGUG then
		outputDebugString( ... )
	end
end

function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end

-- Trying to avoid client/server event errors
addEventHandler( "onClientResourceStart", getResourceRootElement(),
	function()
		triggerServerEvent ( "onRaceGhostResourceStarted", g_Root )
	end
)