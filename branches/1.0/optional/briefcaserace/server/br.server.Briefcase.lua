-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BRIEFCASE OBJECT --
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Briefcase = {x = 0, y = 0, z = 0, bidle = false, carrier = false}

function Briefcase:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- must always call this before deleting briefcase object!
function Briefcase:destroy()
	if (self.bidle) then
		scheduleClientEventForPlayers(getReadyPlayers(), "clientDestroyIdleBriefcase", root)
		self.bidle = false
	elseif (self.carrier) then
		scheduleClientEventForPlayers(getReadyPlayers(), "clientTakeBriefcaseFromPlayer", self.carrier)
		self.carrier = false
	end
end

function Briefcase:idle(x, y, z)
	assert(not self.bidle and not self.carrier)
	self.x, self.y, self.z = x, y, z
	self.bidle = true
	scheduleClientEventForPlayers(getReadyPlayers(), "clientCreateIdleBriefcase", root, x, y, z)
end

function Briefcase:isIdle()
	return self.bidle
end

function Briefcase:getPosition()
	return self.x, self.y, self.z
end

function Briefcase:notIdle()
	assert(self.bidle)
	self.bidle = false
	scheduleClientEventForPlayers(getReadyPlayers(), "clientDestroyIdleBriefcase", root)
end

function Briefcase:attach(player, r, g, b)
	assert(not self.bidle and not self.carrier)
	self.carrier = player
	scheduleClientEventForPlayers(getReadyPlayers(), "clientGiveBriefcaseToPlayer", player, r, g, b)
end

function Briefcase:getCarrier()
	return self.carrier
end

function Briefcase:detach()
	assert(self.carrier)
	scheduleClientEventForPlayers(getReadyPlayers(), "clientTakeBriefcaseFromPlayer", self.carrier)
	self.carrier = false
end
