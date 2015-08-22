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

---------------------------------------------------------------------------
-- Math extentions
---------------------------------------------------------------------------
function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end

function math.unlerp(from,to,pos)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end

function math.lerprot(from,to,alpha)
	while from - to > 180 do
		to = to + 360
	end
	while from - to < -180 do
		to = to - 360
	end
	return math.lerp(from,to,alpha)
end

function math.clamp(low,value,high)
	return math.max(low,math.min(value,high))
end

function math.evalCurve( curve, input )
	-- First value
	if input<curve[1][1] then
		return curve[1][2]
	end
	-- Interp value
	for idx=2,#curve do
		if input<curve[idx][1] then
			local x1 = curve[idx-1][1]
			local y1 = curve[idx-1][2]
			local x2 = curve[idx][1]
			local y2 = curve[idx][2]
			-- Find pos between input points
			local alpha = (input - x1)/(x2 - x1);
			-- Map to output points
			return math.lerp(y1,y2,alpha)
		end
	end
	-- Last value
	return curve[#curve][2]
end
