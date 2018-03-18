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
		if self.countelems and self.countelems[1] then
			table.each( self.countelems, destroyElement )
		end
		self.countelems = {}

		local screenWidth, screenHeight = guiGetScreenSize()
		local numImages = g_GameOptions.countdowneffect and self.value == 0 and 3 or 1
		for i=numImages,1,-1 do
			self.countelems[i] = guiCreateStaticImage(
				math.floor(screenWidth/2 - self.images.width/2),
				math.floor(screenHeight/2 - self.images.height/2),
				self.images.width,
				self.images.height,
				string.format(self.images.namepattern, self.value),
				false,
				nil
			)
		end
		if self.fade then
			Animation.createAndPlay(
				self.countelems,
				{ from = 0, to = 1, time = 1000, fn = zoomFades, width = self.images.width, height = self.images.height }
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
	if self.countelems and self.countelems[1] then
		table.each( self.countelems, destroyElement )
	end
	self.countelems = nil
	if self.background and self.background.elem then
		destroyElement(self.background.elem)
		self.background.elem = nil
	end
	Countdown.instances[self.id] = nil
	self.id = nil
end

-- Custom fancy effect for final countdown image
function zoomFades(elems, val, info)
	if type( val ) == 'table' then
		return
	end

	local valinv = 1 - val
	local width = info.width
	local height = info.height

	local val = 1-((1-val) * (1-val))
	local slope = val * 0.95
	local alphas = { valinv, (valinv-0.35) * 0.20, (valinv-0.5) * 0.125 }

	if #elems > 1 then
		alphas[1] = valinv*valinv-valinv*0.5
	end

	for i,elem in ipairs(elems) do
		if isElement(elem) then
			local scalex = 1 + slope * (i-1)
			local scaley = 1 + slope * (i-1)
			local sx = width * scalex
			local sy = height * scaley
			local screenWidth, screenHeight = guiGetScreenSize()
			sx = math.min( screenWidth, sx )
			sy = math.min( screenHeight, sy )
			local px = math.floor(screenWidth/2 - sx/2)
			local py = math.floor(screenHeight/2 - sy/2)
			guiSetPosition( elem, px, py, false )
			guiSetSize( elem, sx, sy, false )
			guiSetAlpha( elem, alphas[i] )
		end
	end
end
