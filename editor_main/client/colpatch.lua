local PLACEMENT_FILENAME = "client/colpatch/placement.list"
local COL_FILENAME = "client/colpatch/patches.col"
local COL_LOAD_FRAME = 10 -- Files to load and replace per frame
local COL_CREATE_FRAME = 100 -- Objects to create per frame
local COL_RESTORE_FRAME = 20 -- Files to restore and destroy per frame
local COL_DESTROY_FRAME = 100 -- Objects to destroy per frame

local g_colData -- Contains collision data from patches.col file
local g_colElements -- Contains loaded col
local g_placementData -- Contains placement data from placement.list
local g_placementObjs -- Contains created objs as [obj] = {} pairs
local g_placementIDObjs -- Contains [model] = {obj, ...} pairs

local g_threadCoroutine
local g_threadTimer
local function threadHandler()
	-- Resume coroutine if not finished
	if coroutine.status(g_threadCoroutine) == "suspended" then
		return coroutine.resume(g_threadCoroutine)
	end
	
	killTimer(g_threadTimer)
	g_threadCoroutine = nil
	g_threadTimer = nil
end

local function initThread(fn)
	g_threadTimer = setTimer(threadHandler, 0, 0)
	g_threadCoroutine = coroutine.create(fn)
	coroutine.resume(g_threadCoroutine)
	return true
end

-- Called from editor_gui options_actions.lua
function toggleColPatch(value)
	-- Archive not loaded?
	if not g_colData then
		return false, false
	end
	-- Placements not loaded?
	if not g_placementData then
		return false, false
	end

	-- Get current state
	local isLoaded = g_colElements and true or false

	-- Are we busy
	if g_threadCoroutine then return false, isLoaded end
	
	if value then
		-- Already loaded?
		if g_colElements then return false, isLoaded end
		
		return initThread(loadAndReplaceCollision)
	end
	
	-- Not loaded?
	if not g_colElements then return false, isLoaded end
	return initThread(restoreAndDestroyCollision)
end

function createColPatchObjects()
	g_placementObjs = {}
	g_placementIDObjs = {}
	
	if g_placementData then
		for k,v in ipairs(g_placementData) do
			if k % COL_CREATE_FRAME == 0 then
				coroutine.yield()
			end
			
			local obj = createObject(v.id, v.x, v.y, v.z, v.rx, v.ry, v.rz)
			if obj then
				setElementDimension(obj, getWorkingDimension())
				setElementAlpha(obj, 0)
				if v.int > 0 and v.int < 256 then
					setElementInterior(obj, v.int)
				end
				g_placementObjs[obj] = v
				
				if not g_placementIDObjs[v.id] then
					g_placementIDObjs[v.id] = {}
				end
				table.insert(g_placementIDObjs[v.id], obj)
			end
		end
	end
	
	applyRemovedColPatches()
	return true
end

function isColPatchObject(obj)
	return g_placementObjs and g_placementObjs[obj] or false
end

function destroyColPatchObjects()
	local i = 0
	if g_placementObjs then
		for obj in pairs(g_placementObjs) do
			if i % COL_DESTROY_FRAME == 0 then
				coroutine.yield()
			end
			destroyElement(obj)
			i = i + 1
		end
	end
	
	g_placementObjs = nil
	g_placementIDObjs = nil
	return true
end

function loadColPatchPlacements()
	local file = fileOpen(PLACEMENT_FILENAME, true)
	if not file then return false end
	
	g_placementData = {}
	local fileStr = fileRead(file, fileGetSize(file))
	fileClose(file)
	
	local fileLines = split(fileStr, "\n")
	for k,v in ipairs(fileLines) do
		v = split(v, ",")
		local pl = {
			id = tonumber(v[1]),
			int = tonumber(v[2]),
			x = tonumber(v[3]),
			y = tonumber(v[4]),
			z = tonumber(v[5]),
			rx = tonumber(v[6]),
			ry = tonumber(v[7]),
			rz = tonumber(v[8]),
		}
		if pl.id and pl.int and pl.x and pl.y and pl.z and pl.rx and pl.ry and pl.rz then
			table.insert(g_placementData, pl)
		end
	end
	
	return true
end

function loadColPatchArchive()
	local file = fileOpen(COL_FILENAME, true)
	if not file then return false end
	
	g_colData = {}
	local fileSize = fileGetSize(file)
	
	local filePos = 0
	while true do
		-- Are we at EOF
		if filePos == fileSize then
			break
		end
		-- First 4 bytes contain col version COLL/COL2/COL3
		fileSetPos(file, filePos + 4)
		-- Next 4 bytes contain file size after this value
		local colSize_byte1, colSize_byte2 = fileRead(file, 4):byte(1, 2)
		-- Reading the first two bytes gives us 65 KB
		local colSize = colSize_byte1 + colSize_byte2 * 256
		-- Next 22 bytes contain col name
		local colName = fileRead(file, 22)
		-- Null-terminated string
		colName = colName:sub(1, colName:find("\0")-1)
		-- Seek to start of col and read it all
		fileSetPos(file, filePos)
		local colFile = fileRead(file, colSize + 8)
		filePos = fileGetPos(file)
		
		local id = engineGetModelIDFromName(colName)
		table.insert(g_colData, {["colName"] = colName, ["colID"] = id, ["colFile"] = colFile})
	end
	
	fileClose(file)
	return true
end

function loadAndReplaceCollision()
	g_colElements = {}
	if g_colData then
		for k,colData in ipairs(g_colData) do
			if k % COL_LOAD_FRAME == 0 then
				coroutine.yield()
			end
			
			local col = engineLoadCOL(colData.colFile)
			if col then
				if engineReplaceCOL(col, colData.colID) then
					table.insert(g_colElements, col)
				else
					destroyElement(col)
				end
			end
		end
	end

	createColPatchObjects()
end

function restoreAndDestroyCollision()
	if g_colData then
		for k,colData in ipairs(g_colData) do
			if k % COL_RESTORE_FRAME == 0 then
				coroutine.yield()
			end
			engineRestoreCOL(colData.colID)
		end
	end
	if g_colElements then
		for k,col in ipairs(g_colElements) do
			if isElement(col) then
				if k % COL_RESTORE_FRAME == 0 then
					coroutine.yield()
				end
				destroyElement(col)
			end
		end
		g_colElements = nil
	end

	destroyColPatchObjects()
end

-- Called after we finish loading to apply removed world objects in current map
function applyRemovedColPatches()
	if not g_placementIDObjs then return end
	if not g_placementObjs then return end
	for i,element in ipairs(getElementsByType("removeWorldObject")) do
		local model = getElementData(element, "model")
		if g_placementIDObjs[model] then
			local posX = getElementData(element, "posX")
			local posY = getElementData(element, "posY")
			local posZ = getElementData(element, "posZ")
			local radius = getElementData(element, "radius")

			for k,v in ipairs(g_placementIDObjs[model]) do
				-- Is it a created object
				if type(v) == "userdata" then
					-- Is it within radius
					if getDistanceBetweenPoints3D(g_placementObjs[v].x, g_placementObjs[v].y, g_placementObjs[v].z, posX, posY, posZ) <= radius then
						-- Store the placement data here instead
						g_placementIDObjs[model][k] = g_placementObjs[v]
						-- Destroy the object
						g_placementObjs[v] = nil
						destroyElement(v)
					end
				end
			end
		end
	end
end

local function onClientElementCreateDestroy()
	if not g_placementData then return end
	if not g_placementIDObjs then return end
	if not g_placementObjs then return end
	if (getElementType(source) ~= "removeWorldObject") then return end

	local model = getElementData(source, "model")
	if not g_placementIDObjs[model] then return end
	local posX = getElementData(source, "posX")
	local posY = getElementData(source, "posY")
	local posZ = getElementData(source, "posZ")
	local radius = getElementData(source, "radius")
	if (eventName == "onClientElementCreate") then
		for k,v in ipairs(g_placementIDObjs[model]) do
			-- Is it a created object
			if type(v) == "userdata" then
				-- Is it within radius
				if getDistanceBetweenPoints3D(g_placementObjs[v].x, g_placementObjs[v].y, g_placementObjs[v].z, posX, posY, posZ) <= radius then
					-- Store the placement data here instead
					g_placementIDObjs[model][k] = g_placementObjs[v]
					-- Destroy the object
					g_placementObjs[v] = nil
					destroyElement(v)
				end
			end
		end
	else
		for k,v in ipairs(g_placementIDObjs[model]) do
			-- Is it a destroyed object
			if type(v) == "table" then
				-- Is it within radius
				if getDistanceBetweenPoints3D(v.x, v.y, v.z, posX, posY, posZ) <= radius then
					-- Create the object again
					local obj = createObject(v.id, v.x, v.y, v.z, v.rx, v.ry, v.rz)
					if obj then
						setElementDimension(obj, getWorkingDimension())
						setElementAlpha(obj, 0)
						if v.int > 0 and v.int < 256 then
							setElementInterior(obj, v.int)
						end
						g_placementObjs[obj] = v
						-- Store it as an object again
						g_placementIDObjs[model][k] = obj
					end
				end
			end
		end
	end
end
addEventHandler("onClientElementCreate", resourceRoot, onClientElementCreateDestroy)
addEventHandler("onClientElementDestroyed", resourceRoot, onClientElementCreateDestroy)

