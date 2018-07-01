--
-- edf_client_cp_lines.lua
--
-- Visualization of checkpoint connections for race
-- Use command 'cplines' to toggle display
--

local showHelpText = false
local showCheckpointLines = true
local updatesPerFrame = 10   -- How many checkpoints to update per frame
local lineList = {}
local curIdx = 0
local startTime = getTickCount()

--
-- Handle cplines command
--
addCommandHandler( "cplines",
	function(command, arg1, arg2)
		if arg1 == "0" then
			showCheckpointLines = false
		elseif arg1 == "1" then
			showCheckpointLines = true
		else
			showCheckpointLines = not showCheckpointLines
		end
		outputChatBox( "cplines is now " .. (showCheckpointLines and 1 or 0) )
	end
)


function drawCheckpointConnections()
	local checkpoints = getElementsByType("checkpoint")

    -- Trim line list
    while #lineList > #checkpoints do
        table.remove( lineList, #lineList )
    end

    -- Update line list (a few cps at a time)
    local numToDo = math.min( updatesPerFrame, #checkpoints )
    for i=1,numToDo do
        curIdx = curIdx % #checkpoints
        local checkpoint = checkpoints[curIdx + 1]

        lineList[curIdx + 1] = false

		local nextID = exports.edf:edfGetElementProperty ( checkpoint, "nextid" )
		if isElement(nextID) then
			local dx,dy,dz = exports.edf:edfGetElementPosition(nextID)
			if dx then
                local sx,sy,sz = exports.edf:edfGetElementPosition(checkpoint)
    			if sx then

                    -- Make arrow points
                    local s = Vector3D:new(sx,sy,sz+1)
                    local d = Vector3D:new(dx,dy,dz+1)
                    local dir = d:SubV(s)
                    local length = dir:Length()
                    local mid = s:AddV(dir:Mul(0.5))
                    dir:Normalize()

                    local left = dir:CrossV(Vector3D:new(0,0,1))
                    left.z = 0
                    left:Normalize()
                    left = left:Mul(2)

                    local p = d:SubV(dir:Mul(3))
                    local p1 = p:AddV(left)
                    local p2 = p:SubV(left)

                    lineList[curIdx + 1] = {s=s,d=d,p1=p1,p2=p2,m=mid,length=length}
    			end
			end
		end

        curIdx = curIdx + 1
    end

    -- Draw line list
	if showCheckpointLines then
		local postGui = not isCursorShowing() and not isMTAWindowActive()
		local camX,camY,camZ = getCameraMatrix()
		for i,line in ipairs(lineList) do
			if line then
				local dist = getDistanceBetweenPoints3D( camX, camY, camZ, line.m.x, line.m.y, line.m.z )
				local maxdist = math.max(300,line.length / 1.5)
				if dist < maxdist then
					-- Alpha calculation
					local alpha = math.unlerpclamped( maxdist, dist, 10 ) * 255

					-- Color calculation
					local pos = i / #lineList
					local invpos = 1 - pos
					local color = tocolor(pos*255,0,invpos*255,alpha)

					-- Line width - Make it bigger if far away, to stop shimmering
					local width = 10
					if dist > 100 then
						width = width + (dist-100)/20
					end

					dxDrawLine3D ( line.s.x,line.s.y,line.s.z, line.d.x,line.d.y,line.d.z, color, width, postGui )
					dxDrawLine3D ( line.d.x,line.d.y,line.d.z, line.p1.x,line.p1.y,line.p1.z, color, width, postGui )
					dxDrawLine3D ( line.d.x,line.d.y,line.d.z, line.p2.x,line.p2.y,line.p2.z, color, width, postGui )
				end
			end
		end
	end

	-- Draw help text
	if startTime then
		local delta = getTickCount() - startTime
		if delta > 14000 then
			startTime = false
		end
		if showHelpText then
			local scx,scy = guiGetScreenSize()
			local alpha = math.unlerpclamped( 2000, delta, 4000 ) * math.unlerpclamped( 14000, delta, 10000 )
			local x,y = 10, scy * 0.6
			local font = "default-bold"
			local scale = 2
			local postGui = true
			dxDrawRectangle( x-5, y-5, scale*300, scale*32+10, tocolor(0,0,0,alpha*128), postGui )
			dxDrawText( "race edf commands:", x, y, x, y, tocolor(255,255,0,alpha*255), scale, font, "left", "top", false, false, postGui )
			dxDrawText( "cplines - toggle checkpoint connections", x, y + scale*16, x, y, tocolor(255,255,255,alpha*255), scale, font, "left", "top", false, false, postGui )
		end
	end
end
addEventHandler('onClientHUDRender', root, drawCheckpointConnections)


---------------------------------------------------------------------------
-- mafs
---------------------------------------------------------------------------
function math.lerp(from,alpha,to)
    return from + (to-from) * alpha
end

function math.unlerp(from,pos,to)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end


function math.clamp(low,value,high)
	return math.max(low,math.min(value,high))
end

function math.unlerpclamped(from,pos,to)
	return math.clamp(0,math.unlerp(from,pos,to),1)
end


---------------------------------------------------------------------------
-- Vector3D
---------------------------------------------------------------------------
Vector3D = {
	new = function(self, _x, _y, _z)
		local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
		return setmetatable(newVector, { __index = Vector3D })
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Length()
		self.x = self.x / mod
		self.y = self.y / mod
		self.z = self.z / mod
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Length = function(self)
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
}
