------------------------------
--- File Loading functions ---
------------------------------

cache = {txd = {},coll = {},dff = {},usingTXD = {},list = {},info = {},defintions = {},lods = {}}

function requestCOL(path)
	if path then
		cache.coll[path] = cache.coll[path] or engineLoadCOL(path)
			if not cache.coll[path] then
				triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
			end
		return cache.coll[path]
	end
end
	
function requestTXD(path,name)
	if path then
	cache.txd[path] = cache.txd[path] or engineLoadTXD(path)

		cache.usingTXD[path] = cache.usingTXD[path] or {}
			if name then
				cache.usingTXD[path][name] = true
			end
			
			if not cache.txd[path] then
				triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
			end
		return cache.txd[path]
	end
end

function requestDFF(path)
	if path then
		cache.dff[path] = cache.dff[path] or engineLoadDFF(path)
			if not cache.dff[path] then
				triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
			end
		return cache.dff[path]
	end
end
	
-------------------------
--- Loading functions ---
-------------------------

function LoadModel(name,model)
		
		cache.info[name] = cache.info[name] or {}
		
		if not cache.defintions[name] then return end
		
		if not (cache.info[name]['ID'] == model) then

		if tonumber(cache.info[name]['ID']) then
			engineRestoreCOL (cache.info[name]['ID'])
			engineRestoreModel (cache.info[name]['ID'])
		end
		
		cache.info[name]['ID'] = model        
	
		local definitionTable = cache.defintions[name]
	
		engineSetModelLODDistance (model,math.max(tonumber(definitionTable.drawdistance),150)) 

		engineImportTXD (requestTXD(definitionTable.txd,name),model)
		engineReplaceModel (requestDFF(definitionTable.dff),model,definitionTable.alpha)
		engineReplaceCOL (requestCOL(definitionTable.col),model)
	end
end

addEvent( "LoadID", true )
addEventHandler( "LoadID", root, LoadModel )


for i,v in pairs(getElementsByType('object',resourceRoot)) do
	local id = getElementID(v) or getElementData(v,'ID')
		cache.list[id] = cache.list[id] or {}
	cache.list[id][v] = true
end

function JCreateObjectDefinition(name,dffLocation,txdLocation,collLocation,streamingDistance,alphaFlag,cullFlag,lodFlag,turnOn,turnOff)
	if name then
	
	cache.defintions[name] = {drawdistance = streamingDistance,col = collLocation,txd = txdLocation,dff = dffLocation,alpha = alphaFlag,cull = cullFlag,lod = lodFlag,on = turnOn,off = turnOff}
	
		requestCOL(collLocation)
		requestTXD(txdLocation)
		requestDFF(dffLocation)
	

		for i,v in pairs(cache.list[name] or {}) do
			if isElement(i) then
				changeObject(i,name)
			end
		end
	end
	triggerServerEvent ( "PrepID", resourceRoot,name)
end

------------------------
--- object functions ---
------------------------

function changeObject(object,name)
	
	if not cache.defintions[name] then
			cache.list[name] = cache.list[name] or {}
			cache.list[name][object] = true
		return
	end
	
	if isElement(object) and cache.defintions[name] then
				
			cache.list[name] = cache.list[name] or {}
			cache.list[name][object] = true
			
			local definitionTable = cache.defintions[name] 
			
			setElementDoubleSided(object,definitionTable.cull)
			
		if getLowLODElement(object) then
				destroyElement(getLowLODElement(object)) -- Remove any previous lod elements
		end
			
		setElementData(object,'ID',name)
		setElementID(object,name)				
			
		if definitionTable.lod then 							
			local lod = createObject(getElementModel(object),0,0,0,0,0,0,true)
			cache.lods[name] = cache.lods[name] or {}
			setElementID(lod,name)
			setElementData(lod,'ID',name)
			setLowLODElement(object,lod)
			setElementDoubleSided(lod,definitionTable.cull)
			setElementDimension(lod,getElementDimension(object))
			setElementCollisionsEnabled(lod,false)
			local x,y,z = getElementPosition(object)
			local xr,yr,zr = getElementRotation(object)
			setElementPosition(lod,x,y,z)
			setElementRotation(lod,xr,yr,zr)
		end					
		return true
	end

	isVegElement(object)
	isNightElement(object)
end
	addEvent( "LoadObject", true )
	addEventHandler( "LoadObject", root, changeObject )

Objects = {}

function JcreateObject(name,x,y,z,xr,yr,zr)

	if tonumber(name) or getModelFromID(name) then
		triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(name) or getModelFromID(name))
		return createObject(tonumber(name) or getModelFromID(name),x,y,z,xr,yr,zr) 
	end
	
	if not cache.info[name] then
		triggerServerEvent ( "PrepID", resourceRoot,name) -- Attempt to load ID
	end
		
	if cache.info[name] then 
		local object = createObject(1899,x,y,z,xr,yr,zr)
		setElementModel(object,cache.info[name]['ID'])
			
		Objects[sourceResource] = Objects[sourceResource] or {} 
		Objects[sourceResource][object] = true

		return object
	end
end

function JsetElementModel(element,name) --- SET model

	local id = getElementID(element)
		
	if cache.list[id] then
		cache.list[id][element] = nil
	end
		
	if tonumber(name) or getModelFromID(name) then
		triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(name) or getModelFromID(name) )
		return setElementModel(element,tonumber(name) or getModelFromID(name))
	end
		
		
	if not cache.info[name] then
	triggerServerEvent ( "PrepID", resourceRoot,name) -- Attempt to load ID
	end
		
	if cache.info[name] then
		if cache.info[name]['ID'] then
			setElementModel(element,cache.info[name]['ID'])
			changeObject(element,name)
		end
	end
end

---------------------------
--- UnLoading functions ---
---------------------------

function checkTXD(txd)
	if cache.usingTXD[txd] then
		for i,v in pairs(cache.usingTXD[txd]) do
			if i then 
				return
			end
		end
		destroyElement(cache.txd[txd])
	cache.txd[txd] = nil
	end
end

function unloadModel(name)
	if cache.defintions[name] then
		if cache.info[name] then
		
			if cache.defintions[name].col then
				if cache.coll[cache.defintions[name].col] and cache.dff[cache.defintions[name].dff] then
				
					destroyElement(cache.coll[cache.defintions[name].col])
					cache.coll[cache.defintions[name].col] = nil
					
					destroyElement(cache.dff[cache.defintions[name].dff])
					cache.dff[cache.defintions[name].dff] = nil
					
					cache.usingTXD[cache.defintions[name].txd][name] = nil
					
					checkTXD(cache.defintions[name].txd)
				end
			end
		
				for i,v in pairs(cache.lods[name] or {}) do
					if isElement(i) then
						destroyElement(i)
					end
				end
			
			if cache.info[name]['ID'] then
				engineRestoreCOL (cache.info[name]['ID'])
				engineRestoreModel (cache.info[name]['ID'])
			end
			
			cache.lods[name] = nil
			cache.info[name] = nil
			cache.defintions[name] = nil
		end
	end
	VegReload()
	NightReload()
end
	addEvent( "unLoadObject", true )
	addEventHandler( "unLoadObject", root, unloadModel )

	
addEventHandler("onClientObjectBreak", resourceRoot,
    function()
		triggerServerEvent ( "ElementBroke", resourceRoot,source)
    end
)

addEventHandler("onClientElementDestroy", resourceRoot, function ()
	if getElementType(source) == "object" then
		if getLowLODElement(source) then
			destroyElement(getLowLODElement(source))
		end
	end
end)

addEventHandler ( "onClientResourceStop", root, 
    function ( resource )
		if Objects[resource] then
			for i,v in pairs(Objects[resource]) do
				if isElement(i) then
					destroyElement(i)
				end
			end
			Objects[resource] = nil
		end
   end 
)


addEventHandler( "onClientElementStreamIn", getRootElement( ),
    function ( )
        if getElementType( source ) == "object" then
			LoadModel(getElementID(source),getElementModel(source))
        end
    end
);

