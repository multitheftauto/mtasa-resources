dxText = {}
dxText_mt = { __index = dxText }
local idAssign,idPrefix = 0,"s"
------
defaults = {
	fX							= 0.5,
	fY							= 0.5,
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

function dxText:create( text, x, y, strFont, fScale, horzA )
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
	new:scale( fScale or new.fScale )
	new:font( strFont or new.strFont )
	new:align( horzA or new.bHorizontalAlign )
	new.bVisible = true
	return new
end

function dxText:text(text)
	if type(text) ~= "string" then return self.strText end
	self.strText = text
	return true
end

function dxText:position(x,y)
	if not tonumber(x) then return self.fX, self.fY end
	self.fX = x
	self.fY = y
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
	self.bVisible = bool
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
end

function dxText:boundingBox(left,top,right,bottom)
	if left == nil then
		if self.tBoundingBox then
			return unpack(boundingBox)
		else
			return false
		end
	elseif tonumber(left) and tonumber(right) and tonumber(top) and tonumber(bottom) then
		self.tBoundingBox = {left,top,right,bottom}
	else
		self.tBoundingBox = false
	end
	return true
end

function dxText:sync(element)
	element = element or getRootElement()
	if not isElement(element) then
		outputDebugString ( "dxText:sync - Bad argument", 0, 112, 112, 112 )
		return false
	end
	local type = getElementType(element)
	if type ~= "player" and type ~= "root" then
		outputDebugString ( "dxText:sync - Bad argument", 0, 112, 112, 112 )
		return false
	end
	return triggerClientEvent ( element, "updateDisplaysDM", element, self )
end
