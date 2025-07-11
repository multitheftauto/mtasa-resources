-- Default values
local DEFAULT_FRAME_COUNT = 10
local DEFAULT_BACKGROUND  = { r = 255, g = 255, b = 128 }
local DEFAULT_FOREGROUND  = { r = 0,   g = 0,   b = 0   }
local DEFAULT_BORDER      = { r = 0,   g = 0,   b = 0   }
local FONT_SCALE          = 1
local FONT_NAME           = "arial"


-- Internal vars
local isEventHandled = false
local processTooltips

--
-- Utility functions
--
local function isValidTooltip(tooltip)
	if tooltip and isElement(tooltip) and getElementType(tooltip) == "__tooltip" then
		return true
	else
		return false
	end
end

local function colorToTable(color)
	color = math.floor(color)
	local result = {}

	result.a = math.floor(color / 16777216)
	color = color - (result.a * 16777216)
	result.r = math.floor(color / 65536)
	color = color - (result.r * 65536)
	result.g = math.floor(color / 256)
	color = color - (result.g * 256)
	result.b = color

	return result
end

local function linesIterator(str)
	local i,j = 0,0
	local _
	local finished = false

	return function()
		if finished then return nil end

		i = j + 1
		_,j = string.find(str, "\n", i)

		if not j then
			finished = true
			return i, #str
		else
			return i,j-1
		end
	end
end

local function getTooltipBestSizeForText(text)
	local width
	local height
	local numlines = 0

	for i,j in linesIterator(text) do
		local substr = string.sub(text, i, j)
		local tempwidth = dxGetTextWidth(substr, FONT_SCALE, FONT_NAME)

		if not width or tempwidth > width then
			width = tempwidth
		end

		numlines = numlines + 1
	end
	height = dxGetFontHeight(FONT_SCALE, FONT_NAME) * numlines

	return (width or 0), height
end


--
-- Interface functions
--
function Create(x, y, text, foreground2, background2, border2)
	if not x or not y or not text or type(x) ~= "number" or type(y) ~= "number" or type(text) ~= "string" then
		return false
	end

	local w, h = guiGetScreenSize()
	if x < 0 then x = 0 end
	if x > w then x = w end
	if y < 0 then y = 0 end
	if y > h then y = h end

	x = math.floor(tonumber(x))
	y = math.floor(tonumber(y))
	text = tostring(text)

	local foreground
	local background
	local border

	if foreground2 and type(foreground2) == "number" then
		foreground = colorToTable(foreground2)
	else
		foreground = DEFAULT_FOREGROUND
	end

	if background2 and type(background2) == "number" then
		background = colorToTable(background2)
	else
		background = DEFAULT_BACKGROUND
	end

	if border2 and type(border2) == "number" then
		border = colorToTable(border2)
	else
		border = DEFAULT_BORDER
	end

	local newTooltip = createElement("__tooltip")
	setElementData(newTooltip, "x", x)
	setElementData(newTooltip, "y", y)
	setElementData(newTooltip, "text", text)
	setElementData(newTooltip, "state", "hidden")
	setElementData(newTooltip, "framesToFade", 0)
	setElementData(newTooltip, "framesFaded", 0)
	setElementData(newTooltip, "background", background)
	setElementData(newTooltip, "foreground", foreground)
	setElementData(newTooltip, "border", border)

	local width, height = getTooltipBestSizeForText(text)
	setElementData(newTooltip, "width", width)
	setElementData(newTooltip, "height", height)

	return newTooltip
end

function FadeIn(tooltip, frames)
	if not frames then frames = DEFAULT_FRAME_COUNT end
	if type(frames) ~= "number" then
		return false
	end
	if frames < 1 then frames = 1 end

	if isValidTooltip(tooltip) then
		setElementData(tooltip, "state", "faddingin")
		setElementData(tooltip, "framesToFade", math.floor(tonumber(frames)))
		setElementData(tooltip, "framesFaded", 0)

		if not isEventHandled then
			addEventHandler("onClientRender", root, processTooltips)
			isEventHandled = true
		end

		return true
	else
		return false
	end
end

function FadeOut(tooltip, frames)
	if not frames then frames = DEFAULT_FRAME_COUNT end
	if type(frames) ~= "number" then
		return false
	end
	if frames < 1 then frames = 1 end

	if isValidTooltip(tooltip) then
		setElementData(tooltip, "state", "faddingout")
		setElementData(tooltip, "framesToFade", math.floor(tonumber(frames)))
		setElementData(tooltip, "framesFaded", 0)

		if not isEventHandled then
			addEventHandler("onClientRender", root, processTooltips)
			isEventHandled = true
		end

		return true
	else
		return false
	end
end

function GetState(tooltip)
	if isValidTooltip(tooltip) then
		return getElementData(tooltip, "state")
	else
		return false
	end
end

function SetPosition(tooltip, x, y)
	if isValidTooltip(tooltip)
	   and x and y
	   and type(x) == "number" and type(y) == "number"
	then
		local w, h = guiGetScreenSize()
		if x < 0 then x = 0 end
		if x > w then x = w end
		if y < 0 then y = 0 end
		if y > h then y = h end

		setElementData(tooltip, "x", math.floor(tonumber(x)))
		setElementData(tooltip, "y", math.floor(tonumber(y)))
		return true
	else
		return false
	end
end

function GetPosition(tooltip)
	if isValidTooltip(tooltip) then
		local x = getElementData(tooltip, "x")
		local y = getElementData(tooltip, "y")
		return x, y
	else
		return false
	end
end

function SetText(tooltip, text)
	if isValidTooltip(tooltip) and text and type(text) == "string" then
		setElementData(tooltip, "text", tostring(text))

		local width, height = getTooltipBestSizeForText(text)
		setElementData(tooltip, "width", width)
		setElementData(tooltip, "height", height)

		return true
	else
		return false
	end
end

function GetText(tooltip)
	if isValidTooltip(tooltip) then
		return getElementData(tooltip, "text")
	else
		return false
	end
end


--
-- Color setting/getting interface functions
--
local function setTooltipColor(tooltip, colorname, color)
	if isValidTooltip(tooltip) and color and type(color) == "number" then
		setElementData(tooltip, colorname, colorToTable(color))
		return true
	else
		return false
	end
end

local function getTooltipColor(tooltip, colorname)
	if isValidTooltip(tooltip) then
		local color = getElementData(tooltip, colorname)
		return color.r, color.g, color.b
	else
		return false
	end
end

function SetForegroundColor(tooltip, color)
	return setTooltipColor(tooltip, "foreground", color)
end

function GetForegroundColor(tooltip)
	return getTooltipColor(tooltip, "foreground")
end

function SetBackgroundColor(tooltip, color)
	return setTooltipColor(tooltip, "background", color)
end

function GetBackgroundColor(tooltip)
	return getTooltipColor(tooltip, "background")
end

function SetBorderColor(tooltip, color)
	return setTooltipColor(tooltip, "border", color)
end

function GetBorderColor(tooltip)
	return getTooltipColor(tooltip, "border")
end


--
-- processTooltips
-- Event called for every frame to draw with directx the tooltips
-- that should be drawn.
--
processTooltips = function()
	local tooltips = getElementsByType("__tooltip")

	if #tooltips == 0 then
		removeEventHandler("onClientRender", root, processTooltips)
		isEventHandled = false
		return
	end

	local existVisibleTooltips = false

	for k,tooltip in ipairs(tooltips) do
		local state = getElementData(tooltip, "state")
		local alpha = false


		if state == "visible" then
			-- If the state is visible we don't need to calculate any alpha value
			alpha = 255

		elseif state == "faddingin" then
			-- If it's still fadding in we must calculate the tooltip transparency
			local framesToFade = getElementData(tooltip, "framesToFade")
			local framesFaded = getElementData(tooltip, "framesFaded")

			framesFaded = framesFaded + 1
			if framesFaded >= framesToFade then
				-- When it has finished fadding in, set it as visible so we don't have to
				-- calculate the intermediate alpha values
				setElementData(tooltip, "state", "visible")
				alpha = 255
			else
				setElementData(tooltip, "framesFaded", framesFaded)
				alpha = math.floor(framesFaded * 255 / framesToFade)
			end

		elseif state == "faddingout" then
			-- If it's fadding out we must calculate the tooltip transparency
			local framesToFade = getElementData(tooltip, "framesToFade")
			local framesFaded = getElementData(tooltip, "framesFaded")

			framesFaded = framesFaded + 1
			if framesFaded >= framesToFade then
				-- When it has finished fadding out, set it as hidden so it won't be checked again
				setElementData(tooltip, "state", "hidden")
				alpha = false
			else
				setElementData(tooltip, "framesFaded", framesFaded)
				alpha = math.floor(255 - (framesFaded * 255 / framesToFade))
			end
		end


		-- Alpha can be false if the tooltip state is unknown or hidden
		if alpha then
			local x = getElementData(tooltip, "x")
			local y = getElementData(tooltip, "y")
			local text = getElementData(tooltip, "text")
			local background = getElementData(tooltip, "background")
			local foreground = getElementData(tooltip, "foreground")
			local border = getElementData(tooltip, "border")
			local width = getElementData(tooltip, "width")
			local height = getElementData(tooltip, "height")
			local borderColor = tocolor(border.r, border.g, border.b, alpha)
			local backColor = tocolor(background.r, background.g, background.b, alpha)
			local foreColor = tocolor(foreground.r, foreground.g, foreground.b, alpha)

			existVisibleTooltips = true

			-- Draw the tooltip borders
			dxDrawLine(x, y, x + width + 6, y, borderColor, 1, true)
			dxDrawLine(x, y + height + 4, x + width + 6, y + height + 4, borderColor, 1, true)
			dxDrawLine(x, y, x, y + height + 4, borderColor, 1, true)
			dxDrawLine(x + width + 6, y, x + width + 6, y + height + 4, borderColor, 1, true)

			-- Draw the tooltip background
			dxDrawRectangle(x + 1, y + 1, width + 4, height + 2, backColor, true)

			-- Draw the tooltip text
			dxDrawText(text, x + 3, y + 2, x + 3 + width, y + 2 + height, foreColor,
				   FONT_SCALE, FONT_NAME, "left", "top", false, false, true)
		end
	end

	if not existVisibleTooltips then
		removeEventHandler("onClientRender", root, processTooltips)
		isEventHandled = false
	end
end
