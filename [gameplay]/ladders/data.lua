testing = false



--[[ [Help]
	-- Table Layouts --

	---- Table: climbs ----
	["SurfaceID"/ladderElement] = { -- Note: If surfaceID is an element, all positions are relative
		[ladderIndex] = { -- individual ladders of a surface
			sx=0 , sy=0, sz=0, -- ladder start position
			tx=0, ty=0, tz=0, -- ladder end position
			rx=0, ry=0, rz=0, -- ladder rotation
			d=1, -- distance from ladder it can be grabbed (not players grab point has a 0.3 offset)
			shift_exit = 0, -- distance to warp player upon ladder exit (Y axis relative to ladder) (doesn't affect all exits)
			water = false, -- will fall on ladder exit (change exit anim)
			sliding = true, -- allows sliding down ladders by hold "crouch" key
			inside = false, -- allows entering ladders' the "sprint" key (for ladders with platforms) (also allows entering from rear of ladder)
			jumping = true, -- allows jumping off ladders with the "jump" key
			dynamic = false, -- detects ground level to exit ladder
		}
	}


	---- Table: ladderModels ----
		Note: This table will automatically assign a ladder surface to all vehicles/objects created as the index models
	[ModelNumber/ModelName] -- { -- Note: Model Name is untested and would likely only support vehicle names atm
		[ladderIndex] = {ladderData} -- (See ladder data under "Table Layouts > climbs")
	}


	---- Table: anims ----
	["ladderAnim"] = {
		block = "dozer", -- animation block
		anim = "DOZER_Align_LHS", -- animation name
		anim_start = 350, -- anim start position
		anim_hold = 530, -- anim wait for player input position
		anim_end = 720, -- anim end position
		anim_fade = 120, -- ms to blend into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 930, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 150, -- ms to blend into anim (for when starting to use a ladder)
		climb_up = "exit_l", -- next anim for going up (often to exit)
		climb_next = "climb_r", -- next animation to move along lader
		climb_down = "enter_l", -- next anim for going down (often to exit)
		climb_move = {{0, 250}, {0.04, 300}, {0.424, 430}, {0.494, 530}, {1.093, 720}}, -- used to move ped up/down ladder per time
		climb_angle = {{-90, 0}, {0, 170}}, -- used to apply rotation per time
		climb_adjust = {{0.0, 000, 300}, {0.243, 400}, {0.700, 800}}, -- used to move ped in/out per time (Y pos axis)
		climb_roll = {{0, 300}, {-22, 500}}, -- used to apply "X" rot axis tilt per time
		velocity = {x=0.0, y=0.0, z=0.0}, -- used to apply velocity to ped over time (replaces "climb_move" value with velocity)
		straight = true, -- used to disable some ped rotation adjustment (mainly in case of "X" axis leaning)
	},
]]

--[[	[Help]
	
	---- Server Events ----
		"onLadderAdd" ++ root/surfaceElement (surface, ladder) -- when a new ladder is added (may be bypassed by onElementModelChange)
		"onLadderRemove" ++ root/surfaceElement (surface[, ladder]) -- when a new ladder is removed (may be bypassed by onElementModelChange)
		"onLadderClimbingStart" ++ root/surfaceElement (surface, ladder, ped, step) -- when a ladder is enterd by a ped
		"onLadderClimbingStop" ++ root/surfaceElement (surface, ladder, ped) -- when a ladder is exited by a ped
		"onPedLadderClimbingStart" ++ ped (surface, ladder, step) -- when a ped starts using a ladder
		"onPedLadderClimbingStop" ++ ped (surface, ladder, position) -- when a ped stops using a ladder
		"onPedLadderClimbingStep" ++ ped (surface, ladder) -- when a ped changes ladder step animation
		NOTE: Ladders are built for player elements and peds may not work or give unexpected results
  
	---- Server Functions ----
		setPedClimbingLadder(ped, surface, ladder, pos) - server
		isPedClimbingLadder(ped) - shared
		getPedsOnLadder(surface) - shared
		setPedLadderClimbingEnabled(ped, enabled) - server
		isPedLadderClimbingEnabled(ped) - shared
		getLadderClosestToPosition(px, py, pz) - shared
		getLadders(surface) - shared
		setLadderEnabled(surface, ladder, active) - server
		setLadderProperties(surface, ladder, properties) - server
		getLadderProperties(surface, ladder) - shared
		addLadder(surface, sx, sy, sz, tx, ty, tz, rx, ry, rz, d, jumping, inside, sliding, water, exitShift) - server
		removeLadder(surface, ladder) - server
  
	---- Client Events ----
		"onClientPedLadderClimbingStart" ++ ped (step) -- when a ped starts using a ladder
		"onClientPedLadderClimbingStop" ++ ped () -- when a ped stops using a ladder
		"onClientPedLadderClimbingStep" ++ ped (step) -- when a ped changes ladder step animation

	---- Client Functions ----
		isPedClimbingLadder(ped) - shared
		getPedsOnLadder(surface) - shared
		isPedLadderClimbingEnabled(ped) - shared
		getLadderClosestToPosition(px, py, pz) - shared
		getLadders(surface) - shared
		getLadderProperties(surface, ladder) - shared
]]


ladderProperties = {sx=0 , sy=0, sz=0, tx=0, ty=0, tz=0, rx=0, ry=0, rz=0, d=0, shift_exit=0, water=false, sliding=true, inside=false, jumping=true, dynamic=false}

ladderModels = {
	[590] = {
		{sx=2.1 , sy=8.25, sz=-1.2, tx=2.1, ty=8.25, tz=3.2, rx=0, ry=0, rz=90, d=1, dynamic=true},
		{sx=-2.1 , sy=8.25, sz=-1.2, tx=-2.1, ty=8.25, tz=3.2, rx=0, ry=0, rz=-90, d=1, dynamic=true},
		{sx=2.1 , sy=-8.25, sz=-1.2, tx=2.1, ty=-8.25, tz=3.2, rx=0, ry=0, rz=90, d=1, dynamic=true},
		{sx=-2.1 , sy=-8.25, sz=-1.2, tx=-2.1, ty=-8.25, tz=3.2, rx=0, ry=0, rz=-90, d=1, dynamic=true},
	},
	[1428] = {
		{sx=0 , sy=-0.7, sz=-0.55, tx=0, ty=0.2, tz=2.6, rx=0, ry=0, rz=0, d=1, dynamic=true},
	},
	[1437] = { -- BIG LADDER
		{sx=0 , sy=-0.8, sz=-0.4, tx=0, ty=0.7, tz=5.9, rx=0, ry=0, rz=0, d=1, dynamic=true},
	},
}

climbs = { -- ladder ID (or vehicle/object element )
    ["airport_sf"] = {
        {sx=-1736.60, sy=-445.96, sz=1.96, tx=-1736.60, ty=-445.96, tz=14.10, rx=0, ry=0, rz=-90, d=1},
        {sx=-1618.83, sy=-83.9, sz=1.96, tx=-1618.74, ty=-84.0, tz=14.10, rx=0, ry=0, rz=-135, d=1},
		{sx=-1444.528 , sy=90.304, sz=1.96, tx=-1444.528, ty=90.304, tz=14.10, rx=0, ry=0, rz=225, d=1},
		{sx=-1164.727 , sy=370.074, sz=1.96, tx=-1164.727, ty=370.074, tz=14.10, rx=0, ry=0, rz=225, d=1},
		{sx=-1115.7 , sy=335.3, sz=1.96, tx=-1115.7, ty=335.3, tz=14.10, rx=0, ry=0, rz=45, d=1},
		{sx=-1182.519 , sy=60.546, sz=1.96, tx=-1182.519, ty=60.546, tz=14.10, rx=0, ry=0, rz=135, d=1},
		{sx=-1081.827 , sy=-207.873, sz=1.96, tx=-1081.827, ty=-207.873, tz=14.10, rx=0, ry=0, rz=110, d=1},
		{sx=-1154.118 , sy=-476.786, sz=1.96, tx=-1154.118, ty=-476.786, tz=14.10, rx=0, ry=0, rz=60, d=1},
		{sx=-1361.046 , sy=-696.801, sz=1.96, tx=-1361.046, ty=-696.801, tz=14.10, rx=0, ry=0, rz=0, d=1},
		{sx=-1603.401 , sy=-696.76, sz=1.96, tx=-1603.401, ty=-696.76, tz=14.10, rx=0, ry=0, rz=0, d=1},
	},
	["cargo_ship"] = {--ships
        {sx=-2328.9, sy=1528.65, sz=-0.6, tx=-2328.9, ty=1528.65, tz=18.6, rx=0, ry=0, rz=12, d=1, water=true}
	},
    ["factory_sf"] = {--Factory 1
        {sx=-1055.58, sy=-719.10, sz=32.00, tx=-1055.58, ty=-719.10, tz=55.50, rx=0, ry=0, rz=180, d=1, water=nil},
        {sx=-1013.51, sy=-719.10, sz=32.00, tx=-1013.51, ty=-719.10, tz=55.50, rx=0, ry=0, rz=180, d=1, water=nil},
        {sx=-1099.84, sy=-719.10, sz=32.00, tx=-1099.84, ty=-719.10, tz=55.50, rx=0, ry=0, rz=180, d=1, water=nil},
        {sx=-1073.27, sy=-645.60, sz=32.00, tx=-1073.27, ty=-645.60, tz=56.20, rx=0, ry=0, rz=180, d=1, water=nil},
        {sx=-1111.00, sy=-645.60, sz=32.00, tx=-1111.00, ty=-645.60, tz=56.20, rx=0, ry=0, rz=180, d=1, water=nil},
		{sx=-1060.10, sy=-617.627, sz=34.09, tx=-1060.10, ty=-617.627, tz=129.862, rx=0, ry=0, rz=270, d=1.1, inside=true},
		{sx=-1056.11 , sy=-627.688, sz=32.007, tx=-1056.11, ty=-627.688, tz=129.862, rx=0, ry=0, rz=180, d=1.1, inside=true},
		{sx=-1026.794 , sy=-700.45, sz=64.532, tx=-1026.794, ty=-700.45, tz=129.664, rx=0, ry=0, rz=180, d=1.1, inside=true},
		{sx=-1019.00 , sy=-703.90, sz=54.45, tx=-1019.00, ty=-703.90, tz=130.468, rx=0, ry=0, rz=270.00, d=1.1, inside=true},
        {sx=-1063.20, sy=-640.44, sz=34.09, tx=-1063.20, ty=-640.44, tz=44.20, rx=0, ry=0, rz=0, d=1.1},
		{sx=-1097.464 , sy=-640.731, sz=34.089, tx=-1097.464, ty=-640.731, tz=44.20, rx=0, ry=0, rz=0, d=1.1},
        {sx=-1062.69, sy=-671.95, sz=32.50, tx=-1062.69, ty=-671.95, tz=56.33, rx=0, ry=0, rz=180, d=1.5, shift_exit=-1.5, jumping=false},
		{sx=-1008.30 , sy=-704.145, sz=32.00, tx=-1008.30, ty=-704.145, tz=94.60, rx=0, ry=0, rz=270, d=1.1, shift_exit=-1.0, water=nil, sliding=nil, inside=true, jumping=false, dynamic=false}, -- shit col
		{sx=-1059.062 , sy=-603.542, sz=34.09, tx=-1059.062, ty=-603.542, tz=92.92, rx=0, ry=0, rz=270, d=10, shift_exit=-1, water=nil, sliding=nil, inside=true, jumping=false, dynamic=false}, -- shit col
	},
	["factory_lv"] = {--Factory 2
		{sx=2688.041 , sy=2637.703, sz=10.82, tx=2688.041, ty=2637.703, tz=34.82, rx=0, ry=0, rz=0, d=1},
		{sx=2657.46 , sy=2643.843, sz=10.82, tx=2657.46, ty=2643.843, tz=34.5, rx=0, ry=0, rz=0, d=1},
		{sx=2613.297 , sy=2643.682, sz=10.82, tx=2613.297, ty=2643.682, tz=34.5, rx=0, ry=0, rz=0, d=1},
		{sx=2571.2 , sy=2643.759, sz=10.82, tx=2571.2, ty=2643.759, tz=34.5, rx=0, ry=0, rz=0, d=1},
		{sx=2588.6 , sy=2638.341, sz=10.82, tx=2588.6, ty=2638.341, tz=109.15, rx=0, ry=0, rz=270, d=1.2, inside=true},
		{sx=2632.54 , sy=2836.948, sz=24.124, tx=2632.54, ty=2836.948, tz=122.84, rx=0, ry=0, rz=180, d=1.2, water=true, inside=true},
		{sx=2501.651 , sy=2690.546, sz=10.812, tx=2501.651, ty=2690.546, tz=74.812, rx=0, ry=0, rz=270, d=1.2, inside=true},
		{sx=2713.684 , sy=2773.602, sz=10.82, tx=2713.684, ty=2773.602, tz=74.82, rx=0, ry=0, rz=270, d=1.2, inside=true},
		{sx=2562.597 , sy=2723.70, sz=12.824, tx=2562.597, ty=2723.70, tz=22.94, rx=0, ry=0, rz=180, d=1},
		{sx=2703.173 , sy=2676.83, sz=12.822, tx=2703.173, ty=2676.83, tz=22.92, rx=0, ry=0, rz=0, d=1},
	},
	["area_51"] = testing and {--test ladder
		{sx=268.8 , sy=1884.75, sz=-30.1, tx=268.8, ty=1884.75, tz=22.0, rx=0, ry=0, rz=0, d=1, water=nil, sliding=nil, inside=true, jumping=false, enabled=true, shift_exit=0},
    } or nil,
}

anims = {
	enter_r = {
		block = "dozer",
		anim = "DOZER_Align_LHS",
		anim_start = 00, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 350, -- anim end position
		anim_fade = 50, -- ms to blend  into next anim
		speed = 0.8, -- task speed multiplier
		anim_duration = 970, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		edge_dist = 0.42, -- gta units from edge, anim starts
		climb_up = "climb_r",
		climb_down = nil,
		climb_move = {{0, 0, 300}, {0.2, 430, 530}},
		climb_angle = {{90, 0}, {0, 170}}, -- ped rot alignment angle
		straight = true,
	},
	enter_l = {
		block = "dozer",
		anim = "DOZER_Align_RHS",
		anim_start = 00, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 350, -- anim end position
		anim_fade = 50, -- ms to blend  into next anim
		speed = 0.8, -- task speed multiplier
		anim_duration = 930, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		edge_dist = 0.42, -- gta units from edge, anim starts
		climb_up = "climb_l",
		climb_down = nil,
		climb_move = {{0, 0, 300}, {0.2, 430, 530}},
		climb_angle = {{-90, 0}, {0, 170}},
		straight = true,
	},
	climb_l = {
		block = "dozer",
		anim = "DOZER_Align_RHS",
		anim_start = 350, -- anim start position
		anim_hold = 530, -- anim wait for player input position
		anim_end = 720, -- anim end position
		anim_fade = 120, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 930, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 150, -- ms to blend into anim
		climb_up = "exit_l",
		climb_next = "climb_r",
		climb_down = "enter_l",
		climb_move = {{0, 250}, {0.04, 300}, {0.424, 430}, {0.494, 530}, {1.093, 720}}, -- l
	},
	climb_r = {
		block = "dozer",
		anim = "DOZER_Align_LHS",
		anim_start = 350, -- anim start position
		anim_hold = 530, -- anim wait for player input position
		anim_end = 720, -- anim end position
		anim_fade = 120, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 970, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 150, -- ms to blend into anim
		climb_up = "exit_r",
		climb_next = "climb_l",
		climb_down = "enter_r",
		climb_move = {{0.011, 0, 250}, {0.037, 300}, {0.42, 430}, {0.496, 530}, {1.082, 720}}, -- r
	},
	exit_l = { -- start exit blend at hold
		block = "ped",
		anim = "CLIMB_Pull",
		anim_start = 220, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 870, -- anim end position
		anim_fade = 50, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 870, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		edge_dist = 1.7,
		climb_up = "exit",
		climb_down = "climb_l",
		climb_move = {{-0.015, 000}, {0.300, 200}, {1.02, 700}, {1.075, 870}},
		--climb_adjust = {{0.0000199, 000}, {-0.0000161, 400, 435}, {0.0000223, 870}},
	},
	exit_r = {
		block = "ped",
		anim = "CLIMB_Pull",
		anim_start = 350, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 870, -- anim end position
		anim_fade = 50, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 870, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		edge_dist = 1.6, -- gta units from edge, anim starts
		climb_up = "exit",
		climb_down = "climb_r",
		climb_move = {{-0.015, 000}, {0.300, 200}, {1.02, 700}, {1.075, 870}},
		--climb_adjust = {{0.0000199, 000}, {-0.0000161, 400, 435}, {0.000223, 870}},
	},
	exit = {
		block = "ped",
		anim = "CLIMB_Stand",
		anim_start = 0, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 800, -- anim end position
		anim_fade = 120, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 800, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		climb_up = "exit_f",
		climb_down = "exit_r",
		climb_move = {{0.004, 0}, {0.017, 100}, {0.97, 720}, {0.99, 760}, {0.973, 800}},
		climb_adjust = {{0.0, 000, 300}, {0.243, 400}, {0.700, 800}},
		straight = true,
	},
	exit_f = {
		block = "ped",
		anim = "CLIMB_Stand_finish",
		anim_start = 0, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 200, -- anim end position
		anim_fade = 50, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 200, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 50, -- ms to blend into anim
		climb_up = nil,
		climb_down = "exit",
		climb_move = {{0.1, 200}},
		climb_adjust = {{0.700, 000}, {1, 200}},
		shift_exit = false,
		straight = true,
	},
	fall = {
		block = "BSKTBALL",
		anim = "BBall_idle2_O",
		anim_start = 00, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 160, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 300, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_next = nil,
		climb_down = nil,
		climb_move = {{0.1, 300}},
	},
	fall2 = {
		block = "ped",
		anim = "FALL_glide",
		anim_start = 00, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 160, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 300, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_next = nil,
		climb_down = nil,
		climb_move = {{0.3, 300}},
	},
	align_r = {
		block = "ped",
		anim = "turn_180",
		anim_start = 000, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 630, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 630, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_down = "exit_f",
		climb_move = {{0, 000}},
		climb_adjust = {{1, 000, 630}},
		climb_angle = {{0, 0}, {180, 630}}, -- ped rot alignment angle
		straight = true,
	},
	align_l = {
		block = "ped",
		anim = "turn_180",
		anim_start = 000, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 630, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		reverse = true, -- task speed multiplier
		anim_duration = 630, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_down = "exit_f",
		climb_move = {{0, 000}},
		climb_adjust = {{1, 000, 630}},
		climb_angle = {{0, 0}, {-180, 630}}, -- ped rot alignment angle
		straight = true,
	},
	leap = {
		block = "QUAD",
		anim = "QUAD_getoff_B",
		anim_start = 800, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 1200, -- anim end position
		anim_fade = 150, -- ms to blend  into next anim
		speed = 0.8, -- task speed multiplier
		reverse = true, -- task speed multiplier
		anim_duration = 1630, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_down = "leap_fall",
		climb_next = nil,
		climb_move = {{0, 1100}, {-0.2, 1200}},
		climb_adjust = {{-0.3, 900}, {0, 1200}},
		climb_angle = {{180, 0, 900}, {90, 1110}, {0, 1200}}, -- ped rot alignment angle
		velocity = {x=0.6, y=0.6, z=1},
	},
	leap_fall = {
		block = "ped",
		anim = "JUMP_glide",
		anim_start = 400, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 400, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 500, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_next = nil,
		climb_down = nil,
		climb_move = {{1.5, 0, 400}, {2, 500}},
		climb_adjust = {{-0.3, 0, 400}, {-0.4, 500}},
		climb_angle = {{180, 0, 500}}, -- ped rot alignment angle
		velocity = {x=0.5, y=0.5, z=1},
	},
	kick = {
		block = "dozer",
		anim = "DOZER_Align_RHS", -- DOZER_pullout_LHS --
		anim_start = 720, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 930, -- anim end position
		anim_fade = 150, -- ms to blend  into next anim
		speed = 0.9, -- task speed multiplier
		anim_duration = 930, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = "kick2",
		climb_next = nil,
		climb_down = nil,
		climb_move = {{0, 250}, {0.04, 300}, {0.424, 430}, {0.494, 530}, {1.093, 720}},
	},
	kick2 = {
		block = "BIKELEAP",
		anim = "truck_getin",
		anim_start = 1800, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 2350, -- anim end position
		anim_fade = 150, -- ms to blend  into next anim
		speed = 0.7, -- task speed multiplier
		anim_duration = 2500, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		climb_up = "kick3",
		climb_next = nil,
		climb_down = "kick",
		climb_move = {{0, 1800}, {0.65,  2050, 2080}, {0.0, 2200}},
		climb_adjust = {{0, 1800}, {-0.08, 2000, 2080}, {0.5, 2200}, {1.3, 2350}},
	},
	kick3 = {
		block = "ped",
		anim = "JUMP_glide",
		anim_start = 400, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 500, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 500, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_next = nil,
		climb_down = nil,
		velocity = {x=1, y=1, z=0.6},
		climb_move = {{0, 400}, {0.08, 500}},
		climb_adjust = {{1.3, 400}, {1.5, 500}},
		shift_exit = false,
	},
	switch = {
		block = "dozer",
		anim = "DOZER_Align_RHS", -- DOZER_pullout_LHS --
		anim_start = 730, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 930, -- anim end position
		anim_fade = 150, -- ms to blend  into next anim
		speed = 0.9, -- task speed multiplier
		anim_duration = 930, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = "switch2",
		climb_next = nil,
		climb_down = nil,
		climb_angle = {{180, 0, 1000}},
		climb_move = {{0, 250}, {0.04, 300}, {0.424, 430}, {0.494, 530}, {1.093, 720}},
		climb_adjust = {{1.3, 0, 930}},
	},
	switch2 = {
		block = "BIKELEAP",
		anim = "truck_getin",
		anim_start = 1800, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 2350, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 0.7, -- task speed multiplier
		anim_duration = 2500, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		climb_up = "switch3",
		climb_next = nil,
		climb_down = nil,
		climb_angle = {{180, 0, 2180}, {250, 2350}},
		climb_move = {{0, 1800}, {0.65,  2050, 2080}, {-0.0, 2350}},
		climb_adjust = {{1.3, 1800}, {1.38, 2000, 2080}, {0.80, 2200}, {0.2, 2350}},
		--climb_adjust = {{0, 1800}, {-0.08, 2000, 2080}, {0.5, 2200}, {1.5, 2350}},
	},
	switch3 = {
		block = "ped",
		anim = "CLIMB_jump",
		anim_start = 200, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 570, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 0.9, -- task speed multiplier
		anim_duration = 570, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		climb_up = "climb_l",
		climb_down = nil,
		climb_next = nil,
		climb_move = {{0, 200}, {-0.5, 400, 490}, {-0.0, 570}},
		climb_adjust = {{0.2, 200}, {0, 450}},
		climb_angle = {{240, 0, 200}, {360, 400}}, -- ped rot alignment angle
	},

	slide_l = {
		block = "dozer",
		anim = "DOZER_Align_RHS",
		anim_start = 350, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 720, -- anim end position
		anim_fade = 200, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 930, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_next = nil,
		climb_down = "slide",
		climb_move = {{0, 250}, {0.04, 300}, {0.424, 430}, {0.494, 530}, {1.093, 720}}, -- l
		climb_roll = {{-22, 350}, {0, 530}},
		climb_adjust = {{0.1, 350}, {0, 530}},
	},
	slide_r = {
		block = "dozer",
		anim = "DOZER_Align_LHS",
		anim_start = 350, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 720, -- anim end position
		anim_fade = 200, -- ms to blend  into next anim
		speed = 1, -- task speed multiplier
		anim_duration = 970, -- ms lenght of anim
		align = 130, -- max ms to align to ladder 
		blend = 100, -- ms to blend into anim
		climb_up = nil,
		climb_next = nil,
		climb_down = "slide",
		climb_move = {{0.011, 0, 250}, {0.037, 300}, {0.42, 430}, {0.496, 530}, {1.082, 720}}, -- r
		climb_roll = {{-22, 350}, {0, 530}},
		climb_adjust = {{0.1, 350}, {0, 530}},
	},
	slide = {
		block = "truck",
		anim = "TRUCK_ALIGN_LHS",
		dir = -1,
		down_turn = 1.8,
		anim_start = 0, -- anim start position
		anim_hold = 200, -- anim wait for player input position
		anim_end = 400, -- anim end position
		anim_fade = 300, -- ms to blend  into next anim
		anim_frame = 400/570,
		speed = 2, -- task speed multiplier
		anim_duration = 400, -- ms lenght of anim
		blend = 150, -- ms to blend into anim
		climb_up = nil,
		climb_down = "slide_ext",
		climb_next = "slide",
		climb_move = {{0, 0}, {1.6, 400}},
		climb_angle = {{-0, 0, 400}}, -- ped rot alignment angle
		climb_roll = {{-22, 0, 400}},
		climb_adjust = {{0.1, 0, 400}},
	},
	slide_ext = {
		block = "ped",
		anim = "FALL_land",
		anim_start = 300, -- anim start position
		anim_hold = nil, -- anim wait for player input position
		anim_end = 500, -- anim end position
		anim_fade = 100, -- ms to blend  into next anim
		speed = 1.6, -- task speed multiplier
		anim_duration = 500, -- ms lenght of anim
		blend = 100, -- ms to blend into anim
		edge_dist = 0.42, -- gta units from edge, anim starts
		climb_up = nil,
		climb_down = nil,
		climb_move = {{0.3, 500}},
		climb_roll = {{0, 300}, {-22, 500}},
		climb_adjust = {{0.1, 0}, {0.1, 500}},
		velocity = {x=0.0, y=0.0, z=0.0},
	},
}

do -- Function Libary Extract
	function table.load(table1, table2, overWrite)
		local table1 = table1
		if overWrite ~= true then
			table1 = table.load({}, table1, true)
		end
		for cellName, cell in pairs(table2) do
			if type(cell) == "table" then
				if type(table1[cellName]) ~= 'table' then table1[cellName] = {} end
				table1[cellName] = table.load(table1[cellName], cell, true)
			else
				table1[cellName] = cell
			end
		end
		return table1
	end
	_G["table.load"] = table.load
	do -- Matrix functions
		function createMatrix(x, y, z, rx, ry, rz)
			if x and type(x)~="number" and isElement(x) then
				rx, ry, rz = getElementRotation(x, "ZXY")
				x, y, z = getElementPosition(x)
			end
			rx, ry, rz = math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0)
			local matrix = {}
			matrix[1] = {}
			matrix[1][1] = math.cos(rz)*math.cos(ry) - math.sin(rz)*math.sin(rx)*math.sin(ry)
			matrix[1][2] = math.cos(ry)*math.sin(rz) + math.cos(rz)*math.sin(rx)*math.sin(ry)
			matrix[1][3] = -math.cos(rx)*math.sin(ry)
			matrix[1][4] = 1
			
			matrix[2] = {}
			matrix[2][1] = -math.cos(rx)*math.sin(rz)
			matrix[2][2] = math.cos(rz)*math.cos(rx)
			matrix[2][3] = math.sin(rx)
			matrix[2][4] = 1
			
			matrix[3] = {}
			matrix[3][1] = math.cos(rz)*math.sin(ry) + math.cos(ry)*math.sin(rz)*math.sin(rx)
			matrix[3][2] = math.sin(rz)*math.sin(ry) - math.cos(rz)*math.cos(ry)*math.sin(rx)
			matrix[3][3] = math.cos(rx)*math.cos(ry)
			matrix[3][4] = 1
			
			matrix[4] = {}
			matrix[4][1], matrix[4][2], matrix[4][3] = x or 0, y or 0, z or 0
			matrix[4][4] = 1
			
			return matrix
		end
		
		function getRotationFromMatrix(fm)
			local fx, fy, fz = 0, 0, 0
	
			fx = math.asin(fm[2][3])
			fy = math.cos(fx)
			if fy~=0 then
				fy = fm[3][3]/fy
				fy = fy>1 and 1 or fy<-1 and -1 or fy
				fy = -math.acos(fy)
				if fm[1][3]<0 then fy = -fy end
			end
			if fm[2][1]==0 and fm[2][2]==0 then
				fz = -math.atan2(fm[3][1], fm[3][2])
			else
				fz = -math.atan2(fm[2][1], fm[2][2])
			end
			
			local fx, fy, fz = math.deg(fx), math.deg(fy), math.deg(fz)
			--dxDrawText(inspect({nx=nx, ny=ny, yRot=getDifferenceBetweenRotations(fy, y)}), 300, 20)
			--local text = tostring((fx)).."\n"..tostring(fy).."\n"..tostring((fz))
			--dxDrawText(text, 500, 300)
			return fx, fy, fz
		end
		
		function getPositionFromMatrix(fm)
			return fm[4][1], fm[4][2], fm[4][3]
		end
	
		function getPositionFromMatrixOffset(matrix, offX, offY, offZ)
			local m = matrix -- Get the matrix
			local x = offX*m[1][1] + offY*m[2][1] + offZ*m[3][1] + m[4][1]
			local y = offX*m[1][2] + offY*m[2][2] + offZ*m[3][2] + m[4][2]
			local z = offX*m[1][3] + offY*m[2][3] + offZ*m[3][3] + m[4][3]
			return x, y, z
		end
	
		function getMatrixFromOffset(m, x, y, z, rx, ry, rz)
			local o = createMatrix(0, 0, 0, rx, ry, rz)
			local ox = {getPositionFromMatrixOffset(o, 1, 0, 0)}
			local oy = {getPositionFromMatrixOffset(o, 0, 1, 0)}
			local oz = {getPositionFromMatrixOffset(o, 0, 0, 1)}
			local x, y, z = getPositionFromMatrixOffset(m, x, y, z)
			local xx = ox[1]*m[1][1] + ox[2]*m[2][1] + ox[3]*m[3][1]
			local xy = ox[1]*m[1][2] + ox[2]*m[2][2] + ox[3]*m[3][2]
			local xz = ox[1]*m[1][3] + ox[2]*m[2][3] + ox[3]*m[3][3]
			local yx = oy[1]*m[1][1] + oy[2]*m[2][1] + oy[3]*m[3][1]
			local yy = oy[1]*m[1][2] + oy[2]*m[2][2] + oy[3]*m[3][2]
			local yz = oy[1]*m[1][3] + oy[2]*m[2][3] + oy[3]*m[3][3]
			local zx = oz[1]*m[1][1] + oz[2]*m[2][1] + oz[3]*m[3][1]
			local zy = oz[1]*m[1][2] + oz[2]*m[2][2] + oz[3]*m[3][2]
			local zz = oz[1]*m[1][3] + oz[2]*m[2][3] + oz[3]*m[3][3]
			local fm = {
				{xx, xy, xz, 1},
				{yx, yy, yz, 1},
				{zx, zy, zz, 1},
				{x, y, z, 1},
			}
			return fm
		end
	end
end