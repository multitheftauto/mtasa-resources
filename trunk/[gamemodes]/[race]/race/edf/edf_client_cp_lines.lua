--
-- edf_client_cp_lines.lua
--
-- Visualization of checkpoint connections for race
--

local updatesPerFrame = 10   -- How many checkpoints to update per frame
local lineList = {}
local curIdx = 0

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
                    local s = Vector3D:new(sx,sy,sz)
                    local d = Vector3D:new(dx,dy,dz)
                    local dir = d:SubV(s)
                    dir:Normalize()
    
                    local left = dir:CrossV(Vector3D:new(0,0,1))
                    left.z = 0
                    left:Normalize()
                    left = left:Mul(2)
    
                    local p = d:SubV(dir:Mul(3))
                    local p1 = p:AddV(left)
                    local p2 = p:SubV(left)
    
                    lineList[curIdx + 1] = {s=s,d=d,p1=p1,p2=p2}
    			end
			end
		end

        curIdx = curIdx + 1
    end

    -- Draw line list
    local width = 10
    for i,line in ipairs(lineList) do
        if line then
            local pos = i / #lineList
            local invpos = 1 - pos
            local color = tocolor(pos*255,0,invpos*255,255)
            dxDrawLine3D ( line.s.x,line.s.y,line.s.z, line.d.x,line.d.y,line.d.z, color, width, true )
            dxDrawLine3D ( line.d.x,line.d.y,line.d.z, line.p1.x,line.p1.y,line.p1.z, color, width, true )
            dxDrawLine3D ( line.d.x,line.d.y,line.d.z, line.p2.x,line.p2.y,line.p2.z, color, width, true )
        end
    end
end
addEventHandler('onClientRender', root, drawCheckpointConnections)


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
