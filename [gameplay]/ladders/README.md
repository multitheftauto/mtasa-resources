# Chemical_Ladders
 Make working ladders in MTA 
 Allows ladders to be climbed in Multi-Theft Auto
 Usage:
  enter - enter or exit ladders
  jump - jump of ladders (left/right changes directly)
  crouch - slides down ladders
  sprint - enter trough ladders with platforms 

 Video v2 - https://youtu.be/K3JhbzGyQto
 Video v1 - https://youtu.be/-XVog1RXpxI
 

 For more cool free mods:
  Visit https://ko-fi.com/chemicalcreations
  Share your thoughts https://discord.com/invite/FxHCc7j or HMU
  Help the code https://github.com/ChemicalCreations/Chemical_Ladders

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