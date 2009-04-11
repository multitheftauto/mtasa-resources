-- This client script is completely controlled by the server
Countdown = {}
Countdown.__index = Countdown
Countdown.instances = {}

function Countdown.call(id, fn, ...)
	if not Countdown.instances[id] then
		Countdown.instances[id] = setmetatable({ id = id }, Countdown)
	end
	Countdown[fn](Countdown.instances[id], ...)
end

function Countdown:start(info)
	for k,v in pairs(info) do
		self[k] = v
	end
	
	self.images.width = resAdjust(self.images.width)
	self.images.height = resAdjust(self.images.height)
	if self.background then
		local screenWidth, screenHeight = guiGetScreenSize()
		self.background.width = resAdjust(self.background.width)
		self.background.height = resAdjust(self.background.height)
		self.background.elem = guiCreateStaticImage(
			math.floor(screenWidth/2 - self.background.width/2),
			math.floor(screenHeight/2 - self.background.height/2),
			self.background.width,
			self.background.height,
			self.background.file,
			false,
			nil
		)
	end
	
	self.value = self.startvalue
end

function Countdown:update()
	if type(self) ~= 'table' then
		self = Countdown.instances[self]
	end
	if self.hooks and self.hooks[self.value] then
		for i,hook in ipairs(self.hooks[self.value]) do
			_G[hook.fn](unpack(hook.args))
		end
	end
	if self.value == -1 then
		self:destroy()
		return
	end
	if self.images then
		if self.countelem then
			destroyElement(self.countelem)
		end
		local screenWidth, screenHeight = guiGetScreenSize()
		self.countelem = guiCreateStaticImage(
			math.floor(screenWidth/2 - self.images.width/2),
			math.floor(screenHeight/2 - self.images.height/2),
			self.images.width,
			self.images.height,
			string.format(self.images.namepattern, self.value),
			false,
			nil
		)
		if self.fade then
			Animation.createAndPlay(
				self.countelem,
				{ from = 1, to = 0, time = 1000, fn = guiSetAlpha }
			)
			if self.background and self.value == 0 then
				Animation.createAndPlay(
					self.background.elem,
					{ from = 1, to = 0, time = 700, fn = guiSetAlpha }
				)
			end
		end
	end
    if self.value then
    	self.value = self.value - 1
    else
        outputDebug( 'MISC', 'Countdown self.value is nil' )
    end
end

function Countdown:destroy()
	if type(self) ~= 'table' then
		self = Countdown.instances[self]
	end
	if self.countelem then
		destroyElement(self.countelem)
		self.countelem = nil
	end
	if self.background and self.background.elem then
		destroyElement(self.background.elem)
		self.background.elem = nil
	end
	Countdown.instances[self.id] = nil
	self.id = nil
end
