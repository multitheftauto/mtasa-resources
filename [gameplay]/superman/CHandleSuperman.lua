local playerRotation = {}
local playerVelocity = {}
local streamedPlayers = {}

-- local player data

local extraVelocity = {}
local lastDirection = {}
local currentSpeed = 0

-- static variables

local serverGravity = getGravity()

-- utility functions

local function isPlayerFlying(playerElement)
	local playerFlying = getSupermanData(playerElement, SUPERMAN_FLY_DATA_KEY)

	return playerFlying
end

local function getSupermansFlying()
	local supermansFlying = {}

	for playerElement, _ in pairs(streamedPlayers) do
		local playerFlying = isPlayerFlying(playerElement)

		if (playerFlying) then
			supermansFlying[#supermansFlying + 1] = playerElement
		end
	end

	return supermansFlying
end

local function restorePlayerFromSuperman(playerElement)
	setSupermanData(playerElement, SUPERMAN_FLY_DATA_KEY, false)
	setPedAnimation(playerElement, false)
	setElementVelocity(playerElement, 0, 0, 0)
	setElementRotation(playerElement, 0, 0, 0)
	setElementCollisionsEnabled(playerElement, true)

	playerRotation[playerElement] = nil
	playerVelocity[playerElement] = nil
end

local function angleDiff(angle1, angle2)
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

function onClientResourceStartSuperman()
	addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStopSuperman)
	addEventHandler("onClientRender", root, onClientRenderSupermanProcessControls)
	addEventHandler("onClientRender", root, onClientRenderSupermanProcessFlight)
	addEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerDamageSuperman)
	addEventHandler("onClientPlayerVehicleEnter", localPlayer, onClientPlayerVehicleEnterSuperman)
	addEventHandler("onClientElementStreamIn", root, onClientElementStreamInSuperman)
	addEventHandler("onClientElementStreamOut", root, onClientElementStreamOutSuperman)
	addEventHandler("onClientPlayerQuit", root, onClientPlayerQuitClearSupermanData)

	bindKey("jump", "down", handleSupermanJump)

	addCommandHandler("superman", handleSupermanCommand)

	-- get already streamed players (onClientElementStreamIn won't be called for those who are already streamed in)

	local startAt = root
	local streamedIn = true
	local playersTable = getElementsByType("player", startAt, streamedIn)

	for playerID = 1, #playersTable do
		local playerElement = playersTable[playerID]

		streamedPlayers[playerElement] = true
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStartSuperman)

function onClientResourceStopSuperman()
	setGravity(serverGravity)

	-- restore all players animations, collisions, etc

	local supermansFlying = getSupermansFlying()

	for playerID = 1, #supermansFlying do
		local playerElement = supermansFlying[playerID]

		restorePlayerFromSuperman(playerElement)
	end
end

local function onClientRenderVehicleWarning()
	local boneX, boneY, boneZ = getPedBonePosition(localPlayer, 6)
	local screenX, screenY, distanceToBone = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.3)

	if (not screenX or not screenY) or (distanceToBone and distanceToBone > 100) then
		return false
	end

	dxDrawText("You can not warp into a vehicle when superman is activated.", screenX, screenY, screenX, screenY, WARNING_TEXT_COLOR, 1.1, "default-bold", "center")
end

function hideWarning()
	removeEventHandler("onClientRender", root, onClientRenderVehicleWarning)
end

function onClientPlayerVehicleEnterSuperman()
	if (isPlayerFlying(localPlayer) or getSupermanData(localPlayer, SUPERMAN_TAKE_OFF_DATA_KEY)) and not isTimer(warningTimer) then
		addEventHandler("onClientRender", root, onClientRenderVehicleWarning)
		warningTimer = setTimer(hideWarning, 5000, 1)
	end
end

function onClientPlayerDamageSuperman()
	local playerFlying = isPlayerFlying(localPlayer)

	if (not playerFlying) then
		return false
	end

	cancelEvent()
end

function onClientElementStreamInSuperman()
	local validElement = isElement(source)

	if (not validElement) then
		return false
	end

	local elementType = getElementType(source)
	local playerType = (elementType == "player")

	if (not playerType) then
		return false
	end

	streamedPlayers[source] = true
end

function onClientElementStreamOutSuperman()
	streamedPlayers[source] = nil
	playerRotation[source] = nil
	playerVelocity[source] = nil
end

function onClientPlayerQuitClearSupermanData()
	streamedPlayers[source] = nil
	playerRotation[source] = nil
	playerVelocity[source] = nil
end

function onClientSupermanDataChange(dataKey, _, newValue)
	local flyDataKey = (dataKey == SUPERMAN_FLY_DATA_KEY)

	if (not flyDataKey) then
		return false
	end

	if (not newValue) then
		restorePlayerFromSuperman(source)
	end
end
if (not SUPERMAN_USE_ELEMENT_DATA) then addEvent("onClientSupermanDataChange", false) end
addEventHandler(SUPERMAN_USE_ELEMENT_DATA and "onClientElementDataChange" or "onClientSupermanDataChange", root, onClientSupermanDataChange)

-- handleSupermanJump: combo to start flight without any command

function handleSupermanJump()
	local playerFlying = isPlayerFlying(localPlayer)

	if (playerFlying) then
		return false
	end

	local playerTask = getPedSimplestTask(localPlayer)
	local playerInAir = (playerTask == "TASK_SIMPLE_IN_AIR")

	if (not playerInAir) then
		return false
	end

	setElementVelocity(localPlayer, 0, 0, TAKEOFF_VELOCITY)
	setTimer(startSupermanFlight, 100, 1)
end

function handleSupermanCommand()
	local playerInVehicle = isPedInVehicle(localPlayer)
	local playerFlying = isPlayerFlying(localPlayer)

	if (playerInVehicle or playerFlying) then
		return false
	end

	setElementVelocity(localPlayer, 0, 0, TAKEOFF_VELOCITY)
	setTimer(startSupermanFlight, TAKEOFF_FLIGHT_DELAY, 1)
	setSupermanData(localPlayer, SUPERMAN_TAKE_OFF_DATA_KEY, true)
end

function startSupermanFlight()
	local playerFlying = isPlayerFlying(localPlayer)

	setSupermanData(localPlayer, SUPERMAN_TAKE_OFF_DATA_KEY, false)

	if (playerFlying) then
		return false
	end

	setSupermanData(localPlayer, SUPERMAN_FLY_DATA_KEY, true)
	setElementVelocity(localPlayer, 0, 0, 0)
	currentSpeed = 0
	extraVelocity = {x = 0, y = 0, z = 0}
end

-- controls processing

local jump, oldJump = false, false

function onClientRenderSupermanProcessControls()
	local playerFlying = isPlayerFlying(localPlayer)

	if (not playerFlying) then
		jump, oldJump = getPedControlState(localPlayer, "jump"), jump

		if (not oldJump and jump) then
			handleSupermanJump()
		end

		return false
	end

	-- calculate the requested movement direction

	local Direction = newVector3D(0, 0, 0)

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

	Direction = normalizeVector3D(Direction)

	-- calculate the sight direction

	local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
	local SightDirection = newVector3D((lookX - cameraX), (lookY - cameraY), (lookZ - cameraZ))

	SightDirection = normalizeVector3D(SightDirection)

	if getPedControlState(localPlayer, "look_behind") then
		SightDirection = mulVector3D(SightDirection, -1)
	end

	-- calculate the current max speed and acceleration values

	local maxSpeed = MAX_SPEED
	local acceleration = ACCELERATION

	if getPedControlState(localPlayer, "sprint") then
		maxSpeed = MAX_SPEED * EXTRA_SPEED_FACTOR
		acceleration = acceleration * EXTRA_ACCELERATION_FACTOR
	elseif getPedControlState(localPlayer, "walk") then
		maxSpeed = MAX_SPEED * LOW_SPEED_FACTOR
		acceleration = acceleration * LOW_ACCELERATION_FACTOR
	end

	local DirectionModule = moduleVector3D(Direction)

	-- check if we must change the gravity

	if DirectionModule == 0 and currentSpeed ~= 0 then
		setGravity(0)
	else
		setGravity(serverGravity)
	end

	-- calculate the new current speed

	if currentSpeed ~= 0 and (DirectionModule == 0 or currentSpeed > maxSpeed) then
		currentSpeed = currentSpeed - acceleration -- deccelerate
		if currentSpeed < 0 then
			currentSpeed = 0
		end
	elseif DirectionModule ~= 0 and currentSpeed < maxSpeed then
		currentSpeed = currentSpeed + acceleration -- accelerate
		if currentSpeed > maxSpeed then
			currentSpeed = maxSpeed
		end
	end

	-- calculate the movement requested direction

	if DirectionModule ~= 0 then
		Direction = newVector3D(SightDirection.x * Direction.y - SightDirection.y * Direction.x, SightDirection.x * Direction.x + SightDirection.y * Direction.y, SightDirection.z * Direction.y)

		lastDirection = Direction -- save the last movement direction for when player releases all direction keys
	else

		if lastDirection then -- player is not specifying any direction, use last known direction or the current velocity
			Direction = lastDirection
			if currentSpeed == 0 then
				lastDirection = nil
			end
		else
			Direction = newVector3D(getElementVelocity(localPlayer))
		end
	end

	Direction = normalizeVector3D(Direction)
	Direction = mulVector3D(Direction, currentSpeed)

	if currentSpeed > 0 then -- applicate a smooth direction change, if moving
		local VelocityDirection = newVector3D(getElementVelocity(localPlayer))

		VelocityDirection = normalizeVector3D(VelocityDirection)

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

	if moduleVector3D(Direction) == 0 then
		extraVelocity = {x = 0, y = 0, z = 0}
	end

	-- set the new velocity

	setElementVelocity(localPlayer, Direction.x + extraVelocity.x, Direction.y + extraVelocity.y, Direction.z + extraVelocity.z)

	if extraVelocity.z > 0 then
		extraVelocity.z = extraVelocity.z - 1
		if extraVelocity.z < 0 then
			extraVelocity.z = 0
		end
	elseif extraVelocity.z < 0 then
		extraVelocity.z = extraVelocity.z + 1
		if extraVelocity.z > 0 then
			extraVelocity.z = 0
		end
	end
end

-- players flight processing

local function processIdleFlight(player)
	-- set the proper animation on the player

	local animLib, animName = getPedAnimation(player)
	if animLib ~= IDLE_ANIMLIB or animName ~= IDLE_ANIMATION then
		setPedAnimation(player, IDLE_ANIMLIB, IDLE_ANIMATION, -1, IDLE_ANIM_LOOP, false, false)
	end

	setElementCollisionsEnabled(player, false)

	-- if this is myself, calculate the ped rotation depending on the camera rotation

	if player == localPlayer then
		local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
		local Sight = newVector3D(lookX - cameraX, lookY - cameraY, lookZ - cameraZ)

		Sight = normalizeVector3D(Sight)

		if getPedControlState(localPlayer, "look_behind") then
			Sight = mulVector3D(Sight, -1)
		end

		Sight.z = math.atan(Sight.x / Sight.y)

		if Sight.y > 0 then
			Sight.z = Sight.z + math.pi
		end

		Sight.z = math.deg(Sight.z) + 180

		setElementRotation(localPlayer, 0, 0, Sight.z)
	else
		local Zangle = getPedCameraRotation(player)

		setElementRotation(player, 0, 0, Zangle)
	end
end

local function processMovingFlight(player, Velocity)
	-- set the proper animation on the player

	local animLib, animName = getPedAnimation(player)

	if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
		setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
	end

	local enablePlayerCollision = (player == localPlayer)

	setElementCollisionsEnabled(player, enablePlayerCollision)

	-- calculate the player rotation depending on their velocity

	local Rotation = newVector3D(0, 0, 0)

	if Velocity.x == 0 and Velocity.y == 0 then
		Rotation.z = getElementRotation(player)
	else
		Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))

		if Velocity.y > 0 then
			Rotation.z = Rotation.z - 180
		end

		Rotation.z = (Rotation.z + 180) % 360
	end
	Rotation.x = -math.deg(Velocity.z / moduleVector3D(Velocity) * 1.2)

	-- rotation compensation for the self animation rotation

	Rotation.x = Rotation.x - 40

	-- calculate the Y rotation for barrel rotations

	if not playerRotation[player] then
		playerRotation[player] = 0
	end

	if not playerVelocity[player] then
		playerVelocity[player] = newVector3D(0, 0, 0)
	end

	local previousAngle = getVector2DAngle(playerVelocity[player])
	local currentAngle = getVector2DAngle(Velocity)
	local diff = angleDiff(currentAngle, previousAngle)

	if isnan(diff) then
		diff = 0
	end

	local calculatedYRotation = -diff * MAX_Y_ROTATION / MAX_ANGLE_SPEED

	if calculatedYRotation > playerRotation[player] then
		if calculatedYRotation - playerRotation[player] > ROTATION_Y_SPEED then
			playerRotation[player] = playerRotation[player] + ROTATION_Y_SPEED
		else
			playerRotation[player] = calculatedYRotation
		end
	else
		if playerRotation[player] - calculatedYRotation > ROTATION_Y_SPEED then
			playerRotation[player] = playerRotation[player] - ROTATION_Y_SPEED
		else
			playerRotation[player] = calculatedYRotation
		end
	end

	if playerRotation[player] > MAX_Y_ROTATION then
		playerRotation[player] = MAX_Y_ROTATION
	elseif playerRotation[player] < -MAX_Y_ROTATION then
		playerRotation[player] = -MAX_Y_ROTATION
	elseif math.abs(playerRotation[player]) < ZERO_TOLERANCE then
		playerRotation[player] = 0
	end

	Rotation.y = playerRotation[player]

	-- apply the calculated rotation

	setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)

	-- save the current velocity

	playerVelocity[player] = Velocity
end

local function processLanding(player, Velocity, distanceToGround)
	-- set the proper animation on the player

	local animLib, animName = getPedAnimation(player)

	if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
		setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
	end

	local enablePlayerCollision = (player == localPlayer)

	setElementCollisionsEnabled(player, enablePlayerCollision)

	-- calculate the player rotation depending on their velocity and distance to ground

	local Rotation = newVector3D(0, 0, 0)

	if Velocity.x == 0 and Velocity.y == 0 then
		Rotation.z = getElementRotation(player)
	else
		Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))
		if Velocity.y > 0 then
			Rotation.z = Rotation.z - 180
		end
		Rotation.z = (Rotation.z + 180) % 360
	end
	Rotation.x = -(85 - (distanceToGround * 85 / LANDING_DISTANCE))

	-- rotation compensation for the self animation rotation

	Rotation.x = Rotation.x - 40

	-- apply the calculated rotation

	setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)
end

function onClientRenderSupermanProcessFlight()
	local supermansFlying = getSupermansFlying()

	for playerID = 1, #supermansFlying do
		local playerElement = supermansFlying[playerID]

		local Velocity = newVector3D(getElementVelocity(playerElement))
		local distanceToBase = getElementDistanceFromCentreOfMassToBaseOfModel(playerElement)
		local playerPos = newVector3D(getElementPosition(playerElement))

		playerPos.z = playerPos.z - distanceToBase

		local distanceToGround

		if playerPos.z > 0 then
			local hit, _, _, hitZ =
				processLineOfSight(playerPos.x, playerPos.y, playerPos.z, playerPos.x, playerPos.y, playerPos.z - LANDING_DISTANCE - 1, true, true, true, true, true, false, false, false)
			if hit then
				distanceToGround = playerPos.z - hitZ
			end
		end

		if distanceToGround and distanceToGround < GROUND_ZERO_TOLERANCE then
			local isLocalPlayer = (playerElement == localPlayer)

			restorePlayerFromSuperman(playerElement)

			if (isLocalPlayer) then
				setGravity(serverGravity)
				setSupermanData(localPlayer, SUPERMAN_FLY_DATA_KEY, false)
			end
		elseif distanceToGround and distanceToGround < LANDING_DISTANCE then
			processLanding(playerElement, Velocity, distanceToGround)
		elseif moduleVector3D(Velocity) < ZERO_TOLERANCE then
			processIdleFlight(playerElement)
		else
			processMovingFlight(playerElement, Velocity)
		end
	end
end