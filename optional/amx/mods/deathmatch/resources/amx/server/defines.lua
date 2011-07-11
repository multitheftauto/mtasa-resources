g_WeaponIDMapping = setmetatable({
	[330] = 0,	-- Melee
	[331] = 1,	-- Brass knuckles
	[333] = 2,	-- Golf club
	[334] = 3,	-- Nightstick
	[335] = 4,	-- Knife
	[336] = 5,	-- Baseball bat
	[337] = 6,	-- Shovel
	[338] = 7,	-- Pool cue
	[339] = 8,	-- Katana
	[341] = 9,	-- Chainsaw
	[321] = 10,	-- Purple dildo
	[322] = 11,	-- Short dildo
	[323] = 12,	-- Vibrator
	[324] = 13,	-- Silver vibrator
	[325] = 14,	-- Flowers
	[326] = 15,	-- Cane
	[342] = 16,	-- Grenade
	[343] = 17,	-- Tear gas
	[344] = 18,	-- Molotov
	[346] = 22,	-- Pistol
	[347] = 23,	-- Silenced
	[348] = 24,	-- Desert eagle
	[349] = 25,	-- Shotgun
	[350] = 26,	-- Sawnoff
	[351] = 27,	-- Combat shotgun
	[352] = 28,	-- Uzi
	[353] = 29,	-- MP5
	[355] = 30,	-- AK47
	[356] = 31,	-- M4
	[372] = 32,	-- Tec9
	[357] = 33,	-- Country sniper
	[358] = 34,	-- Sniper rifle
	[359] = 35,	-- Rocket launcher
	[360] = 36,	-- Heatseaking rocket launcher
	[361] = 37,	-- Flamethrower
	[362] = 38,	-- Minigun
	[363] = 39,	-- Satchel
	[364] = 40,	-- Detonator
	[365] = 41,	-- Spray can
	[366] = 42,	-- Fire extinguisher
	[367] = 43,	-- Camera
	[368] = 44,	-- Night vision
	[369] = 45,	-- Infrared
	[371] = 46	-- Parachute
}, {
	__index = function(t, k)
		if k >= 0 and k <= 46 then
			return k
		end
	end
})

g_CommandMapping = setmetatable({
	['?']     = 'help',
	['auth']  = 'login',
	['speak'] = 'say',
	['leave'] = 'exit',
	['out']   = 'quit',
	['mstart'] = 'start',
	['mstop'] = 'stop',
	['reg'] = 'register'
}, {
	__index = function(t, k)
		return table.find(t, k) or nil
	end
})

local controlMappingMT = {
	__index = function(t, k)
		for samp,mta in pairs(t) do
			if type(mta) == 'table' then
				if table.find(mta, k) then
					return samp
				end
			elseif mta == k then
				return samp
			end
		end
	end
}

g_KeyMapping = setmetatable({
	[1] = 'action',
	[2] = 'crouch',
	[4] = { 'fire', 'vehicle_fire' },
	[8] = 'sprint',
	[16] = 'vehicle_secondary_fire',
	[32] = 'jump',
	[64] = 'vehicle_look_right',
	[128] = 'handbrake',
	[256] = 'vehicle_look_left',
	[512] = { 'look_behind', 'sub_mission' },
	[1024] = 'walk',
	[2048] = 'special_control_up',
	[4096] = 'special_control_down',
	[8192] = 'special_control_left',
	[16384] = 'special_control_right',
}, controlMappingMT)

g_LeftRightMapping = setmetatable({
	[65408] = { 'left', 'vehicle_left' },
	[128] = { 'right', 'vehicle_right' }
}, controlMappingMT)

g_UpDownMapping = setmetatable({
	[65408] = { 'forwards', 'accelerate' },
	[128] = { 'backwards', 'brake_reverse' }
}, controlMappingMT)

g_RCVehicles = {
	[441] = true,
	[464] = true,
	[465] = true,
	[501] = true,
	[564] = true
}

g_PoliceVehicles = {
	[416] = true,
	[433] = true,
	[427] = true,
	[470] = true,
	[490] = true,
	[528] = true,
	[596] = true,
	[597] = true,
	[598] = true,
	[599] = true,
	[601] = true
}

PLAYER_STATE_NONE = 0
PLAYER_STATE_ONFOOT = 1
PLAYER_STATE_DRIVER = 2
PLAYER_STATE_PASSENGER = 3
PLAYER_STATE_WASTED = 7
PLAYER_STATE_SPAWNED = 8
PLAYER_STATE_SPECTATING = 9

SPECIAL_ACTION_NONE = 0
SPECIAL_ACTION_USEJETPACK = 2
SPECIAL_ACTION_DANCE1 = 5
SPECIAL_ACTION_DANCE2 = 6
SPECIAL_ACTION_DANCE3 = 7
SPECIAL_ACTION_DANCE4 = 8
SPECIAL_ACTION_HANDSUP = 10
SPECIAL_ACTION_USECELLPHONE = 11
SPECIAL_ACTION_SITTING = 12
SPECIAL_ACTION_STOPUSECELLPHONE = 13

g_SpecialActions = {
	[SPECIAL_ACTION_NONE] = { false },
	[SPECIAL_ACTION_DANCE1] = { 'dancing', 'dnce_m_a' },
	[SPECIAL_ACTION_DANCE2] = { 'dancing', 'dnce_m_b' },
	[SPECIAL_ACTION_DANCE3] = { 'dancing', 'dnce_m_c' },
	[SPECIAL_ACTION_DANCE4] = { 'dancing', 'dnce_m_d' },
	[SPECIAL_ACTION_HANDSUP] = { 'ped', 'handsup', -1, false, false },
	[SPECIAL_ACTION_USECELLPHONE] = { 'ped', 'phone_talk' },
	[SPECIAL_ACTION_SITTING] = { 'attractors', 'stepsit_loop' },
	[SPECIAL_ACTION_STOPUSECELLPHONE] = { 'ped', 'phone_out', -1, false, false }
}