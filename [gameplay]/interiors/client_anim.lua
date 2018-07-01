--STOLED FROM ARC_ LUL
--[[
	Anim queue: list of animation specifications that have to complete their animation one after the other
	Anim: an element (GUI, player, vehicle...) and a list of phases
	Anim phase: a list of parameters with start/end value, time, eventually a transformation function,
		and a function that applies the parameter to the element. May also have an attribute setting number
		of repeats (0 = infinite).
--]]

Animation = {}
Animation.__index = Animation

Animation.collection = {}

function Animation.create(elem, ...)
	local anim = setmetatable({ type = 'anim', elem = elem, phases = {...} }, Animation)
	for i,phase in ipairs(anim.phases) do
		if type(phase) == 'table' then
			phase.from = phase.from or 0
			phase.to = phase.to or 1
			phase.time = phase.time or 0
			phase.value = phase.from
			phase.speed = phase.time > 0 and ((phase.to - phase.from) / phase.time) or 0
		end
	end
	return anim
end

function Animation.createAndPlay(elem, ...)
	local anim = Animation.create(elem, ...)
	anim:play()
	return anim
end

function Animation.createQueue(...)
	local queue = setmetatable({ type = 'queue' }, Animation)
	local args = { ... }
	if type(args[1]) == 'string' then
		queue.name = table.remove(args, 1)
	end
	for i,obj in ipairs(args) do
		queue:add(obj)
	end
	return queue
end

function Animation.createQueueAndPlay(...)
	local queue = Animation.createQueue(...)
	queue:play()
	return queue
end

function Animation.getQueue(name)
	for i,obj in ipairs(Animation.collection) do
		if obj:isQueue() and obj.name == name then
			return obj
		end
	end
	return false
end

function Animation.getOrCreateQueue(name)
	local queue = Animation.getQueue(name)
	if not queue then
		queue = Animation.createQueue(name)
	end
	return queue
end

function Animation:isPlaying()
	return self.playing or false
end

function Animation.playingAnimationsExist()
	return table.find(Animation.collection, 'playing', true) and true
end

function Animation:add(anim)
	if self:isQueue() then
		if type(anim) == 'function' then
			anim = setmetatable({ type = 'function', fn = anim }, Animation)
		end
		anim.queue = self
		table.insert(self, anim)
	end
end

function Animation:remove()
	if self.queue then
		table.removevalue(self.queue, self)
		if #self.queue == 0 then
			self.queue:remove()
		end
	else
		table.removevalue(Animation.collection, self)
		if not Animation.playingAnimationsExist() then
			removeEventHandler('onClientRender', getRootElement(), updateAnim)
			Animation.prevTick = nil
		end
	end
	self.playing = false
end

function Animation:isAnimation()
	return self.type == 'anim'
end

function Animation:isQueue()
	return self.type == 'queue'
end

function Animation:play()
	if self:isPlaying() then
		return
	end
	if not table.find(Animation.collection, self) then
		table.insert(Animation.collection, self)
	end
	if not Animation.playingAnimationsExist() then
		Animation.prevTick = getTickCount()
		addEventHandler('onClientRender', getRootElement(), updateAnim)
	end
	self.playing = true
end

function Animation:pause()
	self.playing = false
	if not Animation.playingAnimationsExist() then
		removeEventHandler('onClientRender', getRootElement(), updateAnim)
		Animation.prevTick = nil
	end
end

function updateAnim()
	local phase
	local curTick = getTickCount()

	for i,obj in ipairs(Animation.collection) do
		if not isElement(obj.elem) then
			obj:remove()
		end
		if obj.playing then
			if obj:isQueue() then
				obj = obj[1]
			end
			phase = obj.phases[1]
			if (type(phase) == 'function')
			  or (phase.speed > 0 and phase.value >= phase.to)
			  or (phase.speed < 0 and phase.value <= phase.to)
			  or (phase.speed == 0) then
				local doRemove = true
				if type(phase) == 'function' then
					phase(obj.elem)
				elseif phase.repeats then
					if phase.repeats == 0 then
						doRemove = false
					else
						phase.repeats = phase.repeats - 1
						doRemove = phase.repeats == 0
					end
					phase.starttick = getTickCount()
					phase.value = phase.from
				end
				if doRemove then
					table.remove(obj.phases, 1)
					phase = false
					if #obj.phases == 0 then
						obj:remove()
						obj = false
					end
				end
			end
			if obj and phase then
				if phase.fn then
					phase.fn(obj.elem, phase.transform and phase.transform(phase.value) or phase.value, phase)
				end
				if not phase.starttick then
					phase.starttick = curTick
				end
				phase.value = phase.from + phase.speed*(curTick - phase.starttick)
			end
		end
	end
end

Animation.presets = {}

function Animation.presets.pulse(elem, value, phase)
	if not value then
		return { from = 0, to = 2*math.pi, transform = math.sin, time = elem, repeats = 0, fn = Animation.presets.pulse }
	else
		if not phase.width then
			phase.width, phase.height = guiGetSize(elem, false)
			phase.centerX, phase.centerY = guiGetPosition(elem, false)
			phase.centerX = phase.centerX + math.floor(phase.width/2)
			phase.centerY = phase.centerY + math.floor(phase.height/2)
		end
		local pct = 1 - (value+1)*0.1
		local width = pct*phase.width
		local height = pct*phase.height
		local x = phase.centerX - math.floor(width/2)
		local y = phase.centerY - math.floor(height/2)
		guiSetPosition(elem, x, y, false)
		guiSetSize(elem, width, height, false)
	end
end

function table.removevalue(t, val)
	for i,v in ipairs(t) do
		if v == val then
			table.remove(t, i)
			return i
		end
	end
	return false
end

function table.find(tableToSearch, index, value)
	if not value then
		value = index
		index = false
	elseif value == '[nil]' then
		value = nil
	end
	for k,v in pairs(tableToSearch) do
		if index then
			if v[index] == value then
				return k
			end
		elseif v == value then
			return k
		end
	end
	return false
end
