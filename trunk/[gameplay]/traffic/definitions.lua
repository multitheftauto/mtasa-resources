-- DEBUG = true

_root = getRootElement()

if ( getLocalPlayer ) then
	_local = getLocalPlayer()
else
	_local = getResourceRootElement ( getThisResource() )
end

SYNC_DIST = 200

AREA_PATHS = {}
AREA_PATHS_ALL = {}
AREA_LIMITS = {}
AREA_VEHICLECOUNT = {}
AREA_ACTIVE = {}

AREA_PRELOAD = true -- This defines if it should preload the areas around active ones

PLAYER_NOLOADDISTANCE = 150
PLAYER_LOADDISTANCE = 250
PLAYER_VEHICLECOUNT = {}
PLAYER_MAXVEHICLECOUNT = 20

TRAFFIC_VEHICLES = {}
TRAFFIC_PRELOADER = {}
TRAFFIC_UNLOADER = {}

LANE_OFFSET = 2.2
PANIC_DIST = 50
PANIC_TIME = 25000
PANIC_SPEED = 30
HIGHWAY_SPEED = 70

HORN_ENABLED = true
HORN_TIME = 1500
HORN_STARTTIME = {}
HORN_STARTTIMELONG = {}

COLLIDE_STARTTIME = {}

ALLOW_PARKINGS = true
ALLOW_EMERGENCY = true

TYPE_DEFAULT = 1
TYPE_BOAT = 2

SPEED_LIMIT = {
	[TYPE_DEFAULT] = 30,
	[TYPE_BOAT] = 50
}
SPEED_TURNING = {
	[TYPE_DEFAULT] = 15,
	[TYPE_BOAT] = 50
}

----------
-- PACKETS

VEH_CREATED = "v_1"
VEH_REWARP = "v_2"

if ( getLocalPlayer ) then
	addCommandHandler("toggledebug", function()
		DEBUG = not DEBUG
	end)
else
	addCommandHandler("togglesdebug", function()
		DEBUG = not DEBUG
	end)
end
