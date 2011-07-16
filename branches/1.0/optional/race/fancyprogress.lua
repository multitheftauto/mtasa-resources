FancyProgress = {}
FancyProgress.__index = FancyProgress

function FancyProgress.create(minval, maxval, bgName, x, y, width, height, barName, barOffsetX, barOffsetY, barWidth, barHeight)
	local screenWidth, screenHeight = guiGetScreenSize()
	if screenWidth < 1280 and screenHeight < 1024 then
		x = resAdjust(x)
		y = resAdjust(y)
		width = resAdjust(width)
		height = resAdjust(height)
		barOffsetX = resAdjust(barOffsetX)
		barOffsetY = resAdjust(barOffsetY)
		barWidth = resAdjust(barWidth)
		barHeight = resAdjust(barHeight)
	end
	if x < 0 then
		x = screenWidth - width + x
	end
	if y < 0 then
		y = screenHeight - height + y
	end
	return setmetatable(
		{
			background = guiCreateStaticImage(x, y, width, height, bgName, false, nil),
			bar = guiCreateStaticImage(x + barOffsetX, y + barOffsetY, barWidth, barHeight, barName, false, nil),
			width = barWidth,
			height = barHeight,
			min = minval,
			max = maxval,
			range = maxval - minval,
			progress = maxval
		},
		FancyProgress
	)
end

function FancyProgress:setProgress(progress)
	if not progress then progress = 0 end
	if progress < self.min then
		progress = self.min
	elseif progress > self.max then
		progress = self.max
	end
	if progress ~= self.progress then
		guiSetSize(self.bar, math.floor((progress-self.min)*self.width/self.range), self.height, false)
		self.progress = progress
	end
end

function FancyProgress:show()
	guiSetVisible(self.background, true)
	guiSetVisible(self.bar, true)
end

function FancyProgress:hide()
	guiSetVisible(self.background, false)
	guiSetVisible(self.bar, false)
end

function FancyProgress:destroy()
	destroyElement(self.background)
	self.background = nil
	destroyElement(self.bar)
	self.bar = nil
end
