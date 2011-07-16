dxImage = {}
dxImage_mt = { __index = dxImage }
local g_screenX,g_screenY = guiGetScreenSize()
local visibleImages = {}
------
local defaults = {
	fX							= 0.5,
	fY							= 0.5,
	fWidth						= 0,
	fHeight						= 0,
	bRelativePosition			= true,
	bRelativeSize				= true,
	fRot						= 0,
	fRotXOff					= 0,
	fRotYOff					= 0,
	strPath						= "",
	tColor 						= {255,255,255,255},
	bPostGUI 					= false,
	bVisible 					= true,
}

function dxImage:create( path, x, y, width, height, relative )
	assert(not self.fX, "attempt to call method 'create' (a nil value)")
	if ( type(path) ~= "string" ) or ( not tonumber(x) ) or ( not tonumber(y) ) then
		outputDebugString ( "dxImage:create - Bad argument", 0, 112, 112, 112 )
		return false
	end
    local new = {}
	setmetatable( new, dxImage_mt )
	--Add default settings
	for i,v in pairs(defaults) do
		new[i] = v
	end
	new.fX = x or new.fX
	new.fY = y or new.fY
	new.strPath = path
	new.fWidth = width or new.fWidth
	new.fHeight = height or new.fHeight
	if type(relative) == "boolean" then
		new.bRelativePosition = relative
		new.bRelativeSize = relative
	end
	visibleImages[new] = true
	return new
end

function dxImage:path(path)
	if type(path) ~= "string" then return self.strPath end
	self.strPath = path
	return true
end

function dxImage:position(x,y,relative)
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

function dxImage:size(x,y,relative)
	if not tonumber(x) then return self.fWidth, self.fHeight end
	self.fWidth = x
	self.fHeight = y
	if type(relative) == "boolean" then
		self.bRelativeSize = relative
	else
		self.bRelativeSize = true
	end
	return true
end

function dxImage:color(r,g,b,a)
	if not tonumber(r) then return unpack(self.tColor) end
	g = g or self.tColor[2]
	b = b or self.tColor[3]
	a = a or self.tColor[4]
	self.tColor = { r,g,b,a }
	return true
end

function dxImage:rotation(rot,xoff,yoff)
	if not tonumber(rot) then return self.fRot,self.fRotXOff,self.fRotYOff end
	self.fRot = rot or self.fRot
	self.fRotXOff = xoff or self.fRotXOff
	self.fRotYOff = yoff or self.fRotYOff
	return true
end

function dxImage:visible(bool)
	if type(bool) ~= "boolean" then return self.bVisible end
	self.bVisible = bool
	if bool then
		visibleImages[self] = true
	else
		visibleImages[self] = nil
	end
	return true
end

function dxImage:destroy()
	self.bDestroyed = true
	setmetatable( self, self )
	return true
end

function dxImage:postGUI(bool)
	if type(bool) ~= "boolean" then return self.bPostGUI end
	self.bPostGUI = bool
	return true
end

addEventHandler ( "onClientRender", getRootElement(),
	function()
		for self,_ in pairs(visibleImages) do
			while true do
				if self.bDestroyed then
					visibleImages[self] = nil
					break
				end
				local x,y,width,height = self.fX,self.fY,self.fWidth,self.fHeight
				if self.bRelativePosition then
					x = x/g_screenX
					y = y/g_screenY
				end
				if self.bRelativeSize then
					width = width/g_screenX
					height = height/g_screenY
				end
				dxDrawImage ( x,y, width, height, self.strPath, self.fRot, self.fRotXOff, self.fRotYOff, tocolor(unpack(self.tColor)), self.bPostGUI )
				break
			end
		end
	end
)

