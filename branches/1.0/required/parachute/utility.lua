local FPS_BENCHMARK = 30
local DEFAULT_GRAVITY = 0.008
local DEFAULT_GAMESPEED = 1

function a(angle,tick)
	return ((tick * angle)/FPS_BENCHMARK)*(getGameSpeed()/DEFAULT_GAMESPEED)
end

function s(speed)
	return speed*(getGravity()/DEFAULT_GRAVITY)
end

function t(time)
	return time*(DEFAULT_GAMESPEED/getGameSpeed())
end

function getMoveState ( key )
	if getAnalogControlState ( key ) > 0.5 then
		return true
	end
	return false
end
