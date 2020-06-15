dxText = {}
dxText_mt = { __index = dxText }
local idAssign,idPrefix = 0,"c"
local g_screenX,g_screenY = guiGetScreenSize()
local visibleText = {}
------
defaults = {
	fX							= 0.5,
	fY							= 0.5,
	bRelativePosition			= true,
	strText						= "",
	bVerticalAlign 				= "center",
	bHorizontalAlign 			= "center",
	tColor 						= {255,255,255,255},
	fScale 						= 1,
	strFont 					= "default",
	strType						= "normal",
	tAttributes					= {},
	bPostGUI 					= false,
	bClip 						= false,
	bWordWrap	 				= true,
	bVisible 					= true,
	tBoundingBox				= false, --If a bounding box is not set, it will not be used.
	bRelativeBoundingBox		= true,
}

local validFonts = {
	default						= true,
	["default-bold"]			= true,
	clear						= true,
	arial						= true,
	pricedown					= true,
	bankgothic					= true,
	diploma						= true,
	beckett						= true,
}

local validTypes = {
	normal						= true,
	shadow						= true,
	border						= true,
	stroke						= true, --Clone of border
}

local validAlignTypes = {
	center						= true,
	left						= true,
	right						= true,
}

function dxText:create( text, x, y, relative, strFont, fScale, horzA )
	assert(not self.fX, "attempt to call method 'create' (a nil value)")
	if ( type(text) ~= "string" ) or ( not tonumber(x) ) or ( not tonumber(y) ) then
		outputDebugString ( "dxText:create - Bad argument", 0, 112, 112, 112 )
		return false
	end
    local new = {}
	setmetatable( new, dxText_mt )
	--Add default settings
	for i,v in pairs(defaults) do
		new[i] = v
	end
	idAssign = idAssign + 1
	new.id = idPrefix..idAssign
	new.strText = text or new.strText
	new.fX = x or new.fX
	new.fY = y or new.fY
	if type(relative) == "boolean" then
		new.bRelativePosition = relative
	end
	new:scale( fScale or new.fScale )
	new:font( strFont or new.strFont )
	new:align( horzA or new.bHorizontalAlign )
	visibleText[new] = true
	return new
end

function dxText:text(text)
	if type(text) ~= "string" then return self.strText end
	self.strText = text
	return true
end

function dxText:position(x,y,relative)
	if not tonumber(x) then return self.fX, self.fY end
	self.fX = x
	self.fY = y
	if type(relative) == "boolean" then
		self.bRelativePosition = relative
	else
		self.bRelativePosition = true
	end
	return true
end

function dxText:color(r,g,b,a)
	if not tonumber(r) then return unpack(self.tColor) end
	g = g or self.tColor[2]
	b = b or self.tColor[3]
	a = a or self.tColor[4]
	self.tColor = { r,g,b,a }
	return true
end

function dxText:scale(scale)
	if not tonumber(scale) then return self.fScale end
	self.fScale = scale
	return true
end

function dxText:visible(bool)
	if type(bool) ~= "boolean" then return self.bVisible end
	if self.bVisible == bool then return end
	self.bVisible = bool
	if bool then
		visibleText[self] = true
	else
		visibleText[self] = nil
	end
	return true
end

function dxText:destroy()
	self.bDestroyed = true
	setmetatable( self, self )
	return true
end

function dxText:font(font)
	if not validFonts[font] then return self.strFont end
	self.strFont = font
	return true
end

function dxText:postGUI(bool)
	if type(bool) ~= "boolean" then return self.bPostGUI end
	self.bPostGUI = bool
	return true
end

function dxText:clip(bool)
	if type(bool) ~= "boolean" then return self.bClip end
	self.bClip = bool
	return true
end

function dxText:wordWrap(bool)
	if type(bool) ~= "boolean" then return self.bWordWrap end
	self.bWordWrap = bool
	return true
end

function dxText:type(type,...)
	if not validTypes[type] then return self.strType, unpack(self.tAttributes) end
	self.strType = type
	self.tAttributes = {...}
	return true
end

function dxText:align(horzA, vertA)
	if not validAlignTypes[horzA] then return self.bHorizontalAlign, self.bVerticalAlign end
	vertA = vertA or self.bVerticalAlign
	self.bHorizontalAlign, self.bVerticalAlign = horzA, vertA
	return true
end

function dxText:boundingBox(left,top,right,bottom,relative)
	if left == nil then
		if self.tBoundingBox then
			return unpack(boundingBox)
		else
			return false
		end
	elseif tonumber(left) and tonumber(right) and tonumber(top) and tonumber(bottom) then
		self.tBoundingBox = {left,top,right,bottom}
		if type(relative) == "boolean" then
			self.bRelativeBoundingBox = relative
		else
			self.bRelativeBoundingBox = true
		end
	else
		self.tBoundingBox = false
	end
	return true
end

addEventHandler ( "onClientRender", getRootElement(),
	function()
		for self,_ in pairs(visibleText) do
			while true do
				if self.bDestroyed then
					visibleText[self] = nil
					break
				end
				if self.tColor[4] < 1 then
					break
				end
				local l,t,r,b
				--If we arent using a bounding box
				if not self.tBoundingBox then
					--Decide if we use relative or absolute
					local p_screenX,p_screenY = 1,1
					if self.bRelativePosition then
						p_screenX,p_screenY = g_screenX,g_screenY
					end
					local fX,fY = (self.fX)*p_screenX,(self.fY)*p_screenY
					if self.bHorizontalAlign == "left" then
						l = fX
						r = fX + g_screenX
					elseif self.bHorizontalAlign == "right" then
						l = fX - g_screenX
						r = fX
					else
						l = fX - g_screenX
						r = fX + g_screenX
					end
					if self.bVerticalAlign == "top" then
						t = fY
						b = fY + g_screenY
					elseif self.bVerticalAlign == "bottom" then
						t = fY - g_screenY
						b = fY
					else
						t = fY - g_screenY
						b = fY + g_screenY
					end
				elseif type(self.tBoundingBox) == "table" then
					local b_screenX,b_screenY = 1,1
					if self.bRelativeBoundingBox then
						b_screenX,b_screenY = g_screenX,g_screenY
					end
					l,t,r,b = self.tBoundingBox[1],self.tBoundingBox[2],self.tBoundingBox[3],self.tBoundingBox[4]
					l = l*b_screenX
					t = t*b_screenY
					r = r*b_screenX
					b = b*b_screenY
				end
				local type,att1,att2,att3,att4,att5 = self:type()
				if type == "border" or type == "stroke" then
					att2 = att2 or 0
					att3 = att3 or 0
					att4 = att4 or 0
					att5 = att5 or self.tColor[4]
					outlinesize = att1 or 2
					outlinesize = math.min(self.fScale,outlinesize) --Make sure the outline size isnt thicker than the size of the label
					if outlinesize > 0 then
						for offsetX=-outlinesize,outlinesize,outlinesize do
							for offsetY=-outlinesize,outlinesize,outlinesize do
								if not (offsetX == 0 and offsetY == 0) then
									dxDrawText(self.strText, l + offsetX, t + offsetY, r + offsetX, b + offsetY, tocolor(att2, att3, att4, att5), self.fScale, self.strFont, self.bHorizontalAlign, self.bVerticalAlign, self.bClip, self.bWordWrap, self.bPostGUI )
								end
							end
						end
					end
				elseif type == "shadow" then
					local shadowDist = att1
					att2 = att2 or 0
					att3 = att3 or 0
					att4 = att4 or 0
					att5 = att5 or self.tColor[4]
					dxDrawText(self.strText, l + shadowDist, t + shadowDist, r + shadowDist, b + shadowDist, tocolor(att2, att3, att4, att5), self.fScale, self.strFont, self.bHorizontalAlign, self.bVerticalAlign, self.bClip, self.bWordWrap, self.bPostGUI )
				end
				dxDrawText ( self.strText, l, t, r, b, tocolor(unpack(self.tColor)), self.fScale, self.strFont, self.bHorizontalAlign, self.bVerticalAlign, self.bClip, self.bWordWrap, self.bPostGUI )
				break
			end
		end
	end
)

if addEvent ( "updateDisplaysDM", true ) then
	addEventHandler ( "updateDisplaysDM", getRootElement(),
		function(self)
			setmetatable( self, dxText_mt )
			--Use "smart positioning"
			updateSmartPositions(self)
			--Remove any old ones with the same id
			for text,_ in pairs(visibleText) do
				if text.id == self.id then
					visibleText[text] = nil
				end
			end
			if self.bVisible and not self.bDestroyed then
				visibleText[self] = true
			end
		end
	)
end

function updateSmartPositions(self)
	self.fX = getSmartPosition(self.fX,g_screenX)
	self.fY = getSmartPosition(self.fY,g_screenY)
	if self.tBoundingBox then
		self.tBoundingBox[1] = getSmartPosition(self.tBoundingBox[1],g_screenX)
		self.tBoundingBox[2] = getSmartPosition(self.tBoundingBox[2],g_screenY)
		self.tBoundingBox[3] = getSmartPosition(self.tBoundingBox[3],g_screenX)
		self.tBoundingBox[4] = getSmartPosition(self.tBoundingBox[4],g_screenY)
	end
	self.bRelative, self.bRelativeBoundingBox = false, false
end

function getSmartPosition(pos,full)
	local final = pos
	if pos > 1 then --Is X bigger than 1?  If so we've got an absolute position
		final = pos
	elseif pos < -1 then --We have a reversed absolute position
		final = full - pos
	elseif pos > 0 then --We have a relative position
		final = full * pos
	else --We have a reversed relative position
		final = full - (full * pos)
	end
	return final
end
