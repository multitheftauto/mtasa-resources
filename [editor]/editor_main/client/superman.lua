-- Copyright (c) 2008, Alberto Alonso
--
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice, this
--       list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright notice, this
--       list of conditions and the following disclaimer in the documentation and/or other
--       materials provided with the distribution.
--     * Neither the name of the superman script nor the names of its contributors may be used
--       to endorse or promote products derived from this software without specific prior
--       written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--[[THIS IS A MODIFIED VERSION OF SUPERMAN RESOURCE FOR PURPOSES OF THE EDITOR]]
local Superman = {}

-- Settings
local ZERO_TOLERANCE = 0.00001
local MAX_ANGLE_SPEED = 6 -- In degrees per frame
local FLIGHT_ANIMLIB = "swim"
local FLIGHT_ANIMATION = "Swim_Dive_Under"
local FLIGHT_ANIM_LOOP = false
local IDLE_ANIMLIB = "cop_ambient"
local IDLE_ANIMATION = "Coplook_loop"
local IDLE_ANIM_LOOP = true
local MAX_Y_ROTATION = 55
local ROTATION_Y_SPEED = 3.8

-- Static global variables
local thisResource = getThisResource()
local rootElement = getRootElement()
local serverGravity = getGravity()
local supermanPlayers = {}

--
-- Utility functions
--
function isPlayerFlying(player)
  if player == localPlayer then return false end
  local data = supermanPlayers[player]
  if not data or data == false then return false
  else return true end
end

function setPlayerFlying(player, state)
  if state == true then state = true
  else
	state = nil
    local self = Superman
    if isPlayerFlying(player) then
      self:restorePlayer(player)
	end
  end

  supermanPlayers[player] = state
  return true
end

local function iterateFlyingPlayers()
  local current = 1
  local allPlayers = getElementsByType("player")

  return function()
    local player

    repeat
      player = allPlayers[current]
      current = current + 1
    until not player or (isPlayerFlying(player) and isElementStreamedIn(player))

    return player
  end
end

function Superman:restorePlayer(player)
  setPlayerFlying(player, false)
  setPedAnimation(player, false)
  setElementVelocity(player, 0, 0, 0)
  setElementRotation(player, 0, 0, 0)
  --setPedRotation(player, getPedRotation(player))
  setElementCollisionsEnabled(player, true)
  self.rotations[player] = nil
  self.previousVelocity[player] = nil
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

local function isPedInWater(ped)
  local pedPosition = Vector3D:new(getElementPosition(ped))
  if pedPosition.z <= 0 then return true end

  local waterLevel = getWaterLevel(pedPosition.x, pedPosition.y, pedPosition.z)
  if not isElementStreamedIn(ped) or not waterLevel or waterLevel < pedPosition.z then
    return false
  else
    return true
  end
end

local function isnan(x)
	math.inf = 1/0
	if x == math.inf or x == -math.inf or x ~= x then
		return true
	end
	return false
end

local function getVector2DAngle(vec)
  if vec.x == 0 and vec.y == 0 then return 0 end
  local angle = math.deg(math.atan(vec.x / vec.y)) + 90
  if vec.y < 0 then
    angle = angle + 180
  end
  return angle
end

--
-- Initialization and shutdown functions
--
function Superman.Start()
  local self = Superman

  -- Register events
  addEventHandler("onClientResourceStop", getResourceRootElement(thisResource), Superman.Stop, false)
  addEventHandler("onPlayerQuit", rootElement, Superman.onQuit)
  addEventHandler("onClientRender", rootElement, Superman.processFlight)
  addEventHandler("onClientElementStreamIn", rootElement, Superman.onStreamIn)
  addEventHandler("onClientElementStreamOut", rootElement, Superman.onStreamOut)

  -- Initializate attributes
  self.rotations = {}
  self.previousVelocity = {}
end
addEventHandler("onClientResourceStart", getResourceRootElement(thisResource), Superman.Start, false)

function Superman.Stop()
  local self = Superman

  setGravity(serverGravity)

  -- Restore all players animations, collisions, etc
  for player in iterateFlyingPlayers() do
    self:restorePlayer(player)
  end
end



--
-- Join/Quit
--
function Superman.onQuit(reason, player)
  local self = Superman
  local player = player or source

  if isPlayerFlying(player) then
    self:restorePlayer(player)
  end
end


--
-- onDamage: superman is invulnerable
--


--
-- onStreamIn: Reset rotation attribute for player
--
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

--
-- Players flight processing
--
function Superman.processFlight()
  local self = Superman

  for player in iterateFlyingPlayers() do
    local Velocity = Vector3D:new(getElementVelocity(player))
    local distanceToBase = getElementDistanceFromCentreOfMassToBaseOfModel(player)
    local playerPos = Vector3D:new(getElementPosition(player))
    playerPos.z = playerPos.z - distanceToBase

    if Velocity:Module() < ZERO_TOLERANCE then
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
end

function Superman:processMovingFlight(player, Velocity)
  -- Set the proper animation on the player
  local animLib, animName = getPedAnimation(player)
  if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
    setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
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
  if not self.rotations[player] then self.rotations[player] = 0 end
  if not self.previousVelocity[player] then self.previousVelocity[player] = Vector3D:new(0, 0, 0) end

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

--
-- Vectors
--
Vector3D = {
  new = function(self, _x, _y, _z)
    local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
    return setmetatable(newVector, { __index = Vector3D })
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
    return Vector3D:new(self.y * V.z - self.z * V.y,
                        self.z * V.x - self.x * V.z,
                        self.x * V.y - self.y * V.z)
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
  end,
}

