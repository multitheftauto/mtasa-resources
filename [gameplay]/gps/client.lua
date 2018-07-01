local floor = math.floor

addCommandHandler('path',
	function(command, node1, node2)
		if not tonumber(node1) or not tonumber(node2) then
			outputChatBox("Usage: /path node1 node2", 255, 0, 0)
			return
		end
		local path = server.calculatePathByNodeIDs(tonumber(node1), tonumber(node2))
		if not path then
			outputConsole('No path found')
			return
		end
		server.spawnPlayer(getLocalPlayer(), path[1].x, path[1].y, path[1].z)
		fadeCamera(true)
		setCameraTarget(getLocalPlayer())

		removeLinePoints ( )
		table.each(getElementsByType('marker'), destroyElement)
		for i,node in ipairs(path) do
			createMarker(node.x, node.y, node.z, 'corona', 5, 50, 0, 255, 200)
			addLinePoint ( node.x, node.y )
		end
	end
)
addCommandHandler('path2',
	function(command, tox, toy, toz)
		if not tonumber(tox) or not tonumber(toy) then
			outputChatBox("Usage: /path2 x y z (z is optional)", 255, 0, 0)
			return
		end
		local x,y,z = getElementPosition(getLocalPlayer())
		local path = server.calculatePathByCoords(x, y, z, tox, toy, toz)
		if not path then
			outputConsole('No path found')
			return
		end
		server.spawnPlayer(getLocalPlayer(), path[1].x, path[1].y, path[1].z)
		fadeCamera(true)
		setCameraTarget(getLocalPlayer())

		removeLinePoints ( )
		table.each(getElementsByType('marker'), destroyElement)
		for i,node in ipairs(path) do
			createMarker(node.x, node.y, node.z, 'corona', 5, 50, 0, 255, 200)
			addLinePoint ( node.x, node.y )
		end
	end
)

local function getAreaID(x, y)
	return math.floor((y + 3000)/750)*8 + math.floor((x + 3000)/750)
end

local function getNodeByID(db, nodeID)
	local areaID = floor(nodeID / 65536)
	return db[areaID][nodeID]
end

--[[
addEventHandler('onClientRender', getRootElement(),
	function()
		local db = vehicleNodes

		local camX, camY, camZ = getCameraMatrix()
		local x, y, z = getElementPosition(getLocalPlayer())
		local areaID = getAreaID(x, y)
		local drawn = {}
		for id,node in pairs(db[areaID]) do
			if getDistanceBetweenPoints3D(x, y, z, node.x, node.y, z) < 300 then
				--[/[
				local screenX, screenY = getScreenFromWorldPosition(node.x, node.y, node.z)
				if screenX then
					dxDrawText(tostring(id), screenX - 10, screenY - 5)
				end
				--]/]
				--[/[
				for neighbourid,distance in pairs(node.neighbours) do
					if not drawn[neighbourid .. '-' .. id] then
						local neighbour = getNodeByID(db, neighbourid)
						dxDrawLine3D(node.x, node.y, node.z + 1, neighbour.x, neighbour.y, neighbour.z + 1, tocolor(0, 0, 200, 255), 3)
						drawn[id .. '-' .. neighbourid] = true
					end
				end
				--]/]
			end
		end
	end
)
--]]
