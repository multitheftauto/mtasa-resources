-- #######################################
-- ## Project: Glue						##
-- ## Author: MTA contributors			##
-- ## Version: 1.3.1					##
-- #######################################

IS_SERVER = (not triggerServerEvent) -- do not touch — constant; helper bool which checks whether it's a server or client environment

GLUE_WEAPON_SLOTS = {} -- do not touch — constant; used to verify whether passed weapon slot is in valid range (0-12), this is used to restore currently held weapon, because MTA resets weapon slot on attach
GLUE_CLIENT_ATTACH_DATA_SIZE = 6 -- do not touch, unless you modify data sent from client via triggerServerEvent (onServerVehicleAttachElement)
GLUE_ELEMENT_TYPES_AND_EVENTS = { -- do not touch — constant; controls which events would be added for glue logic based on allowed element type
	["player"] = "onPlayerWasted",
	["vehicle"] = "onVehicleExplode",
}

GLUE_ALLOWED_ELEMENTS = {"player", "vehicle"} -- elements which could be attached to vehicle (supported: "player", "vehicle")
GLUE_VEHICLE_TYPES = { -- only relevant if GLUE_ALLOWED_ELEMENTS contains "vehicle", specifies which vehicle types are allowed to glue
	"Automobile",
	--"Plane",
	"Bike",
	"Helicopter",
	--"Boat",
	"Train",
	"Trailer",
	"BMX",
	"Monster Truck",
	"Quad",
}

GLUE_VEHICLE_WHITELIST = { -- only relevant if GLUE_ALLOWED_ELEMENTS contains "vehicle", ignores GLUE_VEHICLE_TYPES; specifies which vehicle models are allowed to glue
	500, -- mesa
	411, -- infernus
	443, -- packer
	487, -- maverick
}

GLUE_ATTACH_OVER_VEHICLE = false -- if true, vehicles will attach over the top of target vehicle. if false, vehicles will attach but will maintain original position (seamless, precise glue'ing)
GLUE_DETACH_ON_VEHICLE_EXPLOSION = true -- specifies whether attached elements would be automatically detached, when attachedTo vehicle explodes
GLUE_ATTACH_ON_TOP_OFFSETS = {0, 0, 1.5, 0, 0, 0} -- only relevant if GLUE_ATTACH_OVER_VEHICLE is set to true; offsets (attachX, attachY, attachZ, attachRX, attachRY, attachRZ) used when vehicle is being attached to vehicle on top
GLUE_ATTACH_HELICOPTER_OFFSETS = {0, 0, -1.5, 0, 0, 0} -- offsets (attachX, attachY, attachZ, attachRX, attachRY, attachRZ) used when vehicle is being attached to helicopter
GLUE_ATTACH_VEHICLE_MAX_DISTANCE = 5 -- specifies maximum distance for nearby vehicle to be glued (also serves anti-cheat purpose, so only nearby vehicle could be attached)
GLUE_ATTACH_PLAYER_MAX_DISTANCE = 10 -- ditto

GLUE_PREVENT_CONTROLS = false -- prevent players from shooting their guns while attached to vehicle
GLUE_PREVENT_CONTROLS_LIST = {"fire", "action"} -- only relevant GLUE_PREVENT_CONTROLS is set to true, specifies which controls will be toggled on/off

GLUE_SYNC_CORRECTION = true -- whether attached player positions should be sanity corrected by server, this exists to prevents positional desyncs (e.g: during vehicle teleporting on long distances), which causes player to behave like a ghost (roam freely around SA, while still appearing glued to vehicle for other players)
GLUE_SYNC_CORRECTION_INTERVAL = 3500 -- only relevant if GLUE_SYNC_CORRECTION is set to true, how often glued player position should be corrected, do not set it too low, otherwise you will face weapon aiming interruption (this was constant issue when this variable was set to 1000 before)

GLUE_MESSAGE_PREFIX = "[Glue]:" -- shown in all glue messages
GLUE_MESSAGE_PREFIX_COLOR = "#c68ff8" -- color used by prefix
GLUE_MESSAGE_HIGHLIGHT_COLOR = "#c68ff8" -- color used in message highlights
GLUE_SHOW_ONE_TIME_HINT = true -- whether player should receive one-time (till resource restart) hint, regarding glue keybindings and settings, upon entering a vehicle

GLUE_ALLOW_ATTACH_TOGGLING = true -- should players be able to control attach lock on their vehicle (as a driver)
GLUE_ALLOW_DETACHING_ELEMENTS = true -- should players be able to detach already attached elements (as a driver)
GLUE_ALLOW_DETACHING_VEHICLES_AS_A_DRIVER = true -- should vehicle driver be able to detach vehicle which is attached to his own (this is default behavior for helicopters)

GLUE_ATTACH_DETACH_KEY = "X" -- used to attach/detach yourself/vehicle/nearby vehicle (for helicopters)
GLUE_ATTACH_TOGGLE_KEY = "C" -- only relevant if GLUE_ALLOW_ATTACH_TOGGLING is set to true; key used for toggling attach lock
GLUE_DETACH_ELEMENTS_KEY = "B" -- only relevant if GLUE_ALLOW_DETACHING_ELEMENTS is set to true; key used for detaching all elements attached to vehicle

GLUE_ATTACH_DETACH_DELAY = 300 -- how often player can attach/detach yourself/vehicle
GLUE_ATTACH_TOGGLE_DELAY = 300 -- only relevant if GLUE_ALLOW_ATTACH_TOGGLING is set to true; how often player can toggle vehicle attach lock
GLUE_DETACH_ELEMENTS_DELAY = 1000 -- only relevant if GLUE_ALLOW_DETACHING_ELEMENTS is set to true; how often player can detach all currently attached elements

do
	local vehicleModelsWhitelist = {}
	local vehicleTypesWhitelist = {}

	for vehicleModelID = 1, #GLUE_VEHICLE_WHITELIST do
		local vehicleModel = GLUE_VEHICLE_WHITELIST[vehicleModelID]

		vehicleModelsWhitelist[vehicleModel] = true
	end

	for vehicleTypeID = 1, #GLUE_VEHICLE_TYPES do
		local vehicleType = GLUE_VEHICLE_TYPES[vehicleTypeID]

		vehicleTypesWhitelist[vehicleType] = true
	end

	GLUE_VEHICLE_WHITELIST = vehicleModelsWhitelist
	GLUE_VEHICLE_TYPES = vehicleTypesWhitelist

	local weaponSlotMin = 0
	local weaponSlotMax = 12

	for weaponSlotID = weaponSlotMin, weaponSlotMax do
		GLUE_WEAPON_SLOTS[weaponSlotID] = true
	end
end