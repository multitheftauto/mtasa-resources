-- #######################################
-- ## Project: Superman					##
-- ## Authors: MTA contributors			##
-- ## Version: 3.0						##
-- #######################################

local Superman = {}

-- Settings

local ZERO_TOLERANCE = 0.00001
local MAX_ANGLE_SPEED = 6 -- In degrees per frame
local MAX_SPEED = 2.5
local EXTRA_SPEED_FACTOR = 2.6
local LOW_SPEED_FACTOR = 0.40
local ACCELERATION = 0.035
local EXTRA_ACCELERATION_FACTOR = 1.8
local LOW_ACCELERATION_FACTOR = 0.85
local TAKEOFF_VELOCITY = 1.75
local TAKEOFF_FLIGHT_DELAY = 750
local GROUND_ZERO_TOLERANCE = 0.18
local LANDING_DISTANCE = 3.2
local FLIGHT_ANIMLIB = "swim"
local FLIGHT_ANIMATION = "Swim_Dive_Under"
local FLIGHT_ANIM_LOOP = false
local IDLE_ANIMLIB = "cop_ambient"
local IDLE_ANIMATION = "Coplook_loop"
local IDLE_ANIM_LOOP = true
local MAX_Y_ROTATION = 70
local ROTATION_Y_SPEED = 3.8

-- Static variables

local serverGravity = getGravity()

--
-- Utility functions
--

local function isPlayerFlying(playerElement)
	local playerFlying = getSupermanData(playerElement, SUPERMAN_FLY_DATA_KEY)

	return playerFlying
end

local function iterateFlyingPlayers()
	local current = 1
	local x, y, z = getElementPosition(localPlayer)
	local nearbyPlayers = getElementsWithinRange(x, y, z, 300, "player")

	return function()
		local player

		repeat
			player = nearbyPlayers[current]
			current = current + 1
		until not player or (isPlayerFlying(player) and isElementStreamedIn(player))

		return player
	end
end

function Superman:restorePlayer(playerElement)
	setSupermanData(playerElement, SUPERMAN_FLY_DATA_KEY, false)
	setPedAnimation(playerElement, false)
	setElementVelocity(playerElement, 0, 0, 0)
	setElementRotation(playerElement, 0, 0, 0)
	setElementCollisionsEnabled(playerElement, true)
	self.rotations[playerElement] = nil
	self.previousVelocity[playerElement] = nil
end

function angleDiff(angle1, angle2)
	angle1, angle2 = angle1 % 360, angle2 % 360
	local diff = (angle1 - angle2) % 360

	if diff <= 180 then
		return diff
	else
		return -(360 - diff)
	end
end

local function isnan(x)
	math.inf = 1 / 0

	if x == math.inf or x == -math.inf or x ~= x then
		return true
	end

	return false
end

local function getVector2DAngle(vec)

	if vec.x == 0 and vec.y == 0 then
		return 0
	end

	local angle = math.deg(math.atan(vec.x / vec.y)) + 90

	if vec.y < 0 then
		angle = angle + 180
	end

	return angle
end

function Superman.Start()
	local self = Superman

	-- Register events

	addEventHandler("onClientResourceStop", resourceRoot, Superman.Stop, false)
	addEventHandler("onClientRender", root, Superman.processControls)
	addEventHandler("onClientRender", root, Superman.processFlight)
	addEventHandler("onClientPlayerDamage", localPlayer, Superman.onDamage, false)
	addEventHandler("onClientPlayerVehicleEnter", localPlayer, Superman.onEnter)
	addEventHandler("onClientElementStreamIn", root, Superman.onStreamIn)
	addEventHandler("onClientElementStreamOut", root, Superman.onStreamOut)

	bindKey("jump", "down", Superman.onJump)

	addCommandHandler("superman", Superman.cmdSuperman)

	-- Initializate attributes

	self.rotations = {}
	self.previousVelocity = {}
end
addEventHandler("onClientResourceStart", resourceRoot, Superman.Start, false)

function Superman.Stop()
	local self = Superman

	setGravity(serverGravity)

	-- Restore all players animations, collisions, etc
	for player in iterateFlyingPlayers() do
		self:restorePlayer(player)
	end
end

-- onEnter: superman cant enter vehicles
-- There's a fix (serverside) for players glitching other players' vehicles by warping into them while superman is active, causing them to flinch into air and get stuck.
function showWarning()
	local x, y, z = getPedBonePosition(localPlayer, 6)
	local sx, sy, dist = getScreenFromWorldPosition(x, y, z + 0.3)

	if sx and sy and dist and dist < 100 then
		dxDrawText("You can not warp into a vehicle when superman is activated.", sx, sy, sx, sy, tocolor(255, 0, 0, 255), 1.1, "default-bold", "center")
	end
end

function hideWarning()
	removeEventHandler("onClientRender", root, showWarning)
end

function Superman.onEnter()
	if (isPlayerFlying(localPlayer) or getSupermanData(localPlayer, SUPERMAN_TAKE_OFF_DATA_KEY)) and not isTimer(warningTimer) then
		addEventHandler("onClientRender", root, showWarning)
		warningTimer = setTimer(hideWarning, 5000, 1)
	end
end

function Superman.onDamage()
	local self = Superman

	if isPlayerFlying(localPlayer) then
		cancelEvent()
	end
end

-- onStreamIn: Reset rotation attribute for player
function Superman.onStreamIn()
	local self = Superman
end

function Superman.onStreamOut()
	local self = Superman

	if source and isElement(source) and getElementType(source) == "player" and isPlayerFlying(source) then
		self.rotations[source] = nil
		self.previousVelocity[source] = nil
	end
end

function onClientSupermanDataChange(dataKey, _, newValue)
	local flyDataKey = (dataKey == SUPERMAN_FLY_DATA_KEY)

	if (not flyDataKey) then
		return false
	end

	if (not newValue) then
		Superman:restorePlayer(source)
	end
end
addEvent("onClientSupermanDataChange", false)
addEventHandler("onClientSupermanDataChange", root, onClientSupermanDataChange)

-- onJump: Combo to start flight without any command
function Superman.onJump(key, keyState)
	local self = Superman
	local task = getPedSimplestTask(localPlayer)

	if not isPlayerFlying(localPlayer) then
		if task == "TASK_SIMPLE_IN_AIR" then
			setElementVelocity(localPlayer, 0, 0, TAKEOFF_VELOCITY)
			setTimer(Superman.startFlight, 100, 1)
		end
	end
end

function Superman.cmdSuperman()
	local self = Superman

	if isPedInVehicle(localPlayer) or isPlayerFlying(localPlayer) then
		return
	end

	setElementVelocity(localPlayer, 0, 0, TAKEOFF_VELOCITY)
	setTimer(Superman.startFlight, TAKEOFF_FLIGHT_DELAY, 1)
	setSupermanData(localPlayer, SUPERMAN_TAKE_OFF_DATA_KEY, true)
end

function Superman.startFlight()
	local self = Superman

	setSupermanData(localPlayer, SUPERMAN_TAKE_OFF_DATA_KEY, false)

	if isPlayerFlying(localPlayer) then
		return
	end

	triggerServerEvent("onServerSupermanStart", localPlayer)
	setSupermanData(localPlayer, SUPERMAN_FLY_DATA_KEY, true)
	setElementVelocity(localPlayer, 0, 0, 0)
	self.currentSpeed = 0
	self.extraVelocity = {x = 0, y = 0, z = 0}
end

-- Controls processing
local jump, oldJump = false, false

function Superman.processControls()
	local self = Superman

	if not isPlayerFlying(localPlayer) then
		jump, oldJump = getPedControlState(localPlayer, "jump"), jump
		if not oldJump and jump then
			Superman.onJump()
		end
		return
	end

	-- Calculate the requested movement direction
	local Direction = Vector3D:new(0, 0, 0)

	if getPedControlState(localPlayer, "forwards") then
		Direction.y = 1
	elseif getPedControlState(localPlayer, "backwards") then
		Direction.y = -1
	end

	if getPedControlState(localPlayer, "left") then
		Direction.x = 1
	elseif getPedControlState(localPlayer, "right") then
		Direction.x = -1
	end

	Direction:Normalize()

	-- Calculate the sight direction
	local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
	local SightDirection = Vector3D:new((lookX - cameraX), (lookY - cameraY), (lookZ - cameraZ))
	SightDirection:Normalize()

	if getPedControlState(localPlayer, "look_behind") then
		SightDirection = SightDirection:Mul(-1)
	end

	-- Calculate the current max speed and acceleration values
	local maxSpeed = MAX_SPEED
	local acceleration = ACCELERATION

	if getPedControlState(localPlayer, "sprint") then
		maxSpeed = MAX_SPEED * EXTRA_SPEED_FACTOR
		acceleration = acceleration * EXTRA_ACCELERATION_FACTOR
	elseif getPedControlState(localPlayer, "walk") then
		maxSpeed = MAX_SPEED * LOW_SPEED_FACTOR
		acceleration = acceleration * LOW_ACCELERATION_FACTOR
	end

	local DirectionModule = Direction:Module()

	-- Check if we must change the gravity
	if DirectionModule == 0 and self.currentSpeed ~= 0 then
		setGravity(0)
	else
		setGravity(serverGravity)
	end

	-- Calculate the new current speed
	if self.currentSpeed ~= 0 and (DirectionModule == 0 or self.currentSpeed > maxSpeed) then
		-- deccelerate
		self.currentSpeed = self.currentSpeed - acceleration
		if self.currentSpeed < 0 then
			self.currentSpeed = 0
		end
	elseif DirectionModule ~= 0 and self.currentSpeed < maxSpeed then
		-- accelerate
		self.currentSpeed = self.currentSpeed + acceleration
		if self.currentSpeed > maxSpeed then
			self.currentSpeed = maxSpeed
		end
	end

	-- Calculate the movement requested direction
	if DirectionModule ~= 0 then
		Direction = Vector3D:new(SightDirection.x * Direction.y - SightDirection.y * Direction.x, SightDirection.x * Direction.x + SightDirection.y * Direction.y, SightDirection.z * Direction.y)
		-- Save the last movement direction for when player releases all direction keys
		self.lastDirection = Direction
	else
		-- Player is not specifying any direction, use last known direction or the current velocity
		if self.lastDirection then
			Direction = self.lastDirection
			if self.currentSpeed == 0 then
				self.lastDirection = nil
			end
		else
			Direction = Vector3D:new(getElementVelocity(localPlayer))
		end
	end
	Direction:Normalize()
	Direction = Direction:Mul(self.currentSpeed)

	-- Applicate a smooth direction change, if moving
	if self.currentSpeed > 0 then
		local VelocityDirection = Vector3D:new(getElementVelocity(localPlayer))
		VelocityDirection:Normalize()

		if math.sqrt(VelocityDirection.x ^ 2 + VelocityDirection.y ^ 2) > 0 then
			local DirectionAngle = getVector2DAngle(Direction)
			local VelocityAngle = getVector2DAngle(VelocityDirection)

			local diff = angleDiff(DirectionAngle, VelocityAngle)
			local calculatedAngle

			if diff >= 0 then
				if diff > MAX_ANGLE_SPEED then
					calculatedAngle = VelocityAngle + MAX_ANGLE_SPEED
				else
					calculatedAngle = DirectionAngle
				end
			else
				if diff < MAX_ANGLE_SPEED then
					calculatedAngle = VelocityAngle - MAX_ANGLE_SPEED
				else
					calculatedAngle = DirectionAngle
				end
			end
			calculatedAngle = calculatedAngle % 360

			local DirectionModule2D = math.sqrt(Direction.x ^ 2 + Direction.y ^ 2)
			Direction.x = -DirectionModule2D * math.cos(math.rad(calculatedAngle))
			Direction.y = DirectionModule2D * math.sin(math.rad(calculatedAngle))
		end
	end

	if Direction:Module() == 0 then
		self.extraVelocity = {x = 0, y = 0, z = 0}
	end

	-- Set the new velocity
	setElementVelocity(localPlayer, Direction.x + self.extraVelocity.x, Direction.y + self.extraVelocity.y, Direction.z + self.extraVelocity.z)

	if self.extraVelocity.z > 0 then
		self.extraVelocity.z = self.extraVelocity.z - 1
		if self.extraVelocity.z < 0 then
			self.extraVelocity.z = 0
		end
	elseif self.extraVelocity.z < 0 then
		self.extraVelocity.z = self.extraVelocity.z + 1
		if self.extraVelocity.z > 0 then
			self.extraVelocity.z = 0
		end
	end
end

-- Players flight processing
function Superman.processFlight()
	local self = Superman

	for player in iterateFlyingPlayers() do
		local Velocity = Vector3D:new(getElementVelocity(player))
		local distanceToBase = getElementDistanceFromCentreOfMassToBaseOfModel(player)
		local playerPos = Vector3D:new(getElementPosition(player))
		playerPos.z = playerPos.z - distanceToBase

		local distanceToGround
		if playerPos.z > 0 then
			local hit, hitX, hitY, hitZ, hitElement =
				processLineOfSight(playerPos.x, playerPos.y, playerPos.z, playerPos.x, playerPos.y, playerPos.z - LANDING_DISTANCE - 1,true, true, true, true, true, false, false, false)
			if hit then
				distanceToGround = playerPos.z - hitZ
			end
		end

		if distanceToGround and distanceToGround < GROUND_ZERO_TOLERANCE then
			self:restorePlayer(player)
			if player == localPlayer then
				setGravity(serverGravity)
				triggerServerEvent("onServerSupermanStop", localPlayer)
			end
		elseif distanceToGround and distanceToGround < LANDING_DISTANCE then
			self:processLanding(player, Velocity, distanceToGround)
		elseif Velocity:Module() < ZERO_TOLERANCE then
			self:processIdleFlight(player)
		else
			self:processMovingFlight(player, Velocity)
		end
	end
end

function Superman:processIdleFlight(player)
	-- Set the proper animation on the player
	local animLib, animName = getPedAnimation(player)
	if animLib ~= IDLE_ANIMLIB or animName ~= IDLE_ANIMATION then
		setPedAnimation(player, IDLE_ANIMLIB, IDLE_ANIMATION, -1, IDLE_ANIM_LOOP, false, false)
	end

	setElementCollisionsEnabled(player, false)

	-- If this is myself, calculate the ped rotation depending on the camera rotation
	if player == localPlayer then
		local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
		local Sight = Vector3D:new(lookX - cameraX, lookY - cameraY, lookZ - cameraZ)
		Sight:Normalize()

		if getPedControlState(localPlayer, "look_behind") then
			Sight = Sight:Mul(-1)
		end

		Sight.z = math.atan(Sight.x / Sight.y)

		if Sight.y > 0 then
			Sight.z = Sight.z + math.pi
		end

		Sight.z = math.deg(Sight.z) + 180

		setPedRotation(localPlayer, Sight.z)
		setElementRotation(localPlayer, 0, 0, Sight.z)
	else
		local Zangle = getPedCameraRotation(player)
		setPedRotation(player, Zangle)
		setElementRotation(player, 0, 0, Zangle)
	end
end

function Superman:processMovingFlight(player, Velocity)
	-- Set the proper animation on the player
	local animLib, animName = getPedAnimation(player)

	if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
		setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
	end

	if player == localPlayer then
		setElementCollisionsEnabled(player, true)
	else
		setElementCollisionsEnabled(player, false)
	end

	-- Calculate the player rotation depending on their velocity
	local Rotation = Vector3D:new(0, 0, 0)

	if Velocity.x == 0 and Velocity.y == 0 then
		Rotation.z = getPedRotation(player)
	else
		Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))

		if Velocity.y > 0 then
			Rotation.z = Rotation.z - 180
		end

		Rotation.z = (Rotation.z + 180) % 360
	end
	Rotation.x = -math.deg(Velocity.z / Velocity:Module() * 1.2)

	-- Rotation compensation for the self animation rotation
	Rotation.x = Rotation.x - 40

	-- Calculate the Y rotation for barrel rotations
	if not self.rotations[player] then
		self.rotations[player] = 0
	end

	if not self.previousVelocity[player] then
		self.previousVelocity[player] = Vector3D:new(0, 0, 0)
	end

	local previousAngle = getVector2DAngle(self.previousVelocity[player])
	local currentAngle = getVector2DAngle(Velocity)
	local diff = angleDiff(currentAngle, previousAngle)

	if isnan(diff) then
		diff = 0
	end

	local calculatedYRotation = -diff * MAX_Y_ROTATION / MAX_ANGLE_SPEED

	if calculatedYRotation > self.rotations[player] then
		if calculatedYRotation - self.rotations[player] > ROTATION_Y_SPEED then
			self.rotations[player] = self.rotations[player] + ROTATION_Y_SPEED
		else
			self.rotations[player] = calculatedYRotation
		end
	else
		if self.rotations[player] - calculatedYRotation > ROTATION_Y_SPEED then
			self.rotations[player] = self.rotations[player] - ROTATION_Y_SPEED
		else
			self.rotations[player] = calculatedYRotation
		end
	end

	if self.rotations[player] > MAX_Y_ROTATION then
		self.rotations[player] = MAX_Y_ROTATION
	elseif self.rotations[player] < -MAX_Y_ROTATION then
		self.rotations[player] = -MAX_Y_ROTATION
	elseif math.abs(self.rotations[player]) < ZERO_TOLERANCE then
		self.rotations[player] = 0
	end

	Rotation.y = self.rotations[player]

	-- Apply the calculated rotation
	setPedRotation(player, Rotation.z)
	setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)

	-- Save the current velocity
	self.previousVelocity[player] = Velocity

end

function Superman:processLanding(player, Velocity, distanceToGround)
	-- Set the proper animation on the player
	local animLib, animName = getPedAnimation(player)

	if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
		setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
	end

	if player == localPlayer then
		setElementCollisionsEnabled(player, true)
	else
		setElementCollisionsEnabled(player, false)
	end

	-- Calculate the player rotation depending on their velocity and distance to ground
	local Rotation = Vector3D:new(0, 0, 0)

	if Velocity.x == 0 and Velocity.y == 0 then
		Rotation.z = getPedRotation(player)
	else
		Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))
		if Velocity.y > 0 then
			Rotation.z = Rotation.z - 180
		end
		Rotation.z = (Rotation.z + 180) % 360
	end
	Rotation.x = -(85 - (distanceToGround * 85 / LANDING_DISTANCE))

	-- Rotation compensation for the self animation rotation
	Rotation.x = Rotation.x - 40

	-- Apply the calculated rotation
	setPedRotation(player, Rotation.z)
	setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)
end

--
-- Vectors
--
Vector3D = {
new = function(self, posX, posY, posZ)
		local newVector = {x = posX or 0.0, y = posY or 0.0, z = posZ or 0.0}
		return setmetatable(newVector, {__index = Vector3D})
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Module()
		if mod ~= 0 then
			self.x = self.x / mod
			self.y = self.y / mod
			self.z = self.z / mod
		end
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Module = function(self)
		return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	end,

	AddV = function(self, V)
		return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	CrossV = function(self, V)
		return Vector3D:new(self.y * V.z - self.z * V.y, self.z * V.x - self.x * V.z, self.x * V.y - self.y * V.z)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,

	MulV = function(self, V)
		return Vector3D:new(self.x * V.x, self.y * V.y, self.z * V.z)
	end,

	DivV = function(self, V)
		return Vector3D:new(self.x / V.x, self.y / V.y, self.z / V.z)
	end
}