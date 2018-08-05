data = {assigned = {},id = {},objects = {},broken = {}} -- Global tables, may switch to per resource indexing in the future?

------------------------------
--- Object Loading functions ---
------------------------------

-- If a player failed to load a custom object then it is printed here
function LoadingFailed(name)
	local pname = getPlayerName(client)
	print('JStreamer : '..name..' Failed For - '..pname)
end

	addEvent( "FailedInLoading", true )
	addEventHandler( "FailedInLoading", resourceRoot, LoadingFailed) 
	
-- When an element is created this is triggered,
function loadObject(object,name)
	if isElement(object) then
		if data.id[name] then
			setElementModel(object,data.id[name])
			setElementData(object,'id',name)
			setElementID(object,name)	
		end
			setElementDoubleSided(object,true) -- by default set it to double sided, there's no way to tell if an SA object is suppose to be double sided, so might as well; if it's not suppose to be it'll be changed client side.
		triggerClientEvent ( root, "LoadObject", root,object,name )
	end
end

-- Preps an id for usage whether it be custom or original.
function PrepID(name,reload)
	if name then
	
		if reload then
			data.id[name] = nil
			data.id[name] = data.id[name] or getFreeID()
				
			for i,v in pairs(data.assigned[name]) do
				if isElement(i) then
					JsetElementModel(i,name)
				end
			end
		end
		
		data.id[name] = data.id[name] or getFreeID()
		idused[data.id[name]] = name
		data.assigned[name] = data.assigned[name] or {}
		triggerClientEvent ( root, "LoadID", root,name,data.id[name] ) -- Need this
		return data.id[name]
	end
end

addEvent( "PrepID", true )
addEventHandler( "PrepID", resourceRoot, PrepID) 
	
--------------------------
--- Original functions ---
--------------------------
	
-- When the streamer attempts to create a SA object it'll run it through here, this reverts any elements using said data.id and reassigns them allowing the original data.id to be used.
function loadOriginal(id)
	if idused[id] then
		if not idused[id] == 'Yes' then
			PrepID(idused[id],true)
			idused[id] = 'Yes'
		end
	end
end
	
	addEvent( "prepOriginals", true )
	addEventHandler( "prepOriginals", resourceRoot, loadOriginal)  
	 
------------------------
--- Object functions ---
------------------------

function JcreateObject(name,x,y,z,xr,yr,zr) -- Create object function
			 
	if tonumber(name) or getModelFromID(name) then
		loadOriginal(tonumber(name) or getModelFromID(name))
	end

		local objectid = tonumber(name) or getModelFromID(name) or PrepID(name)
			
		data.id[name] = objectid
			
	if tonumber(objectid) then
			local object = createObject(objectid,x or 0,y or 0,z or 0,xr or 0,yr or 0,zr or 0)
			
		if object then 
			loadObject(object,name)
			data.assigned[name] = data.assigned[name] or {}
			data.assigned[name][object] = true
			data.objects[sourceResource] = data.objects[sourceResource] or {} 
			data.objects[sourceResource][object] = true
			return object
		end
	end
end

function JsetElementModel(element,name) -- Set object model (Should technically be setObjectModel but for legacy purposes Element is kept)
			
	if tonumber(name) or getModelFromID(name) then
		loadOriginal(tonumber(name) or getModelFromID(name))
	end
			
		local currentID = getElementID(element) or getElementData(element,'data.id')
			
	if data.assigned[currentID] then
		data.assigned[currentID][element] = nil
	end
			
		data.id[name] = tonumber(name) or getModelFromID(name) or PrepID(name)	
		setElementModel(element,data.id[name])	
		data.assigned[name] = data.assigned[name] or {}
		data.assigned[name][element] = true	
		loadObject(element,name)
	return element
end

-----------------------
---- Map Functions ----
-----------------------

-- Unloads the original map, if interiors are enabled it attempts to keep them (Check IDs_Sh for the other Interior related stuff if you want to try to get this working properly)
-- Only work around is to use my interior resource which contains all of the DFFs COLs and TXDs from SAs interiors (Unlisted at the moment, needs work)
if unloadMap then
	local dimenision = allowinteriors and 0 or nil
	
	for i=550,20000 do
		removeWorldModel(i,10000,0,0,0,dimenision)
		removeWorldModel(i,10000,0,0,0,13)
	end	
		setOcclusionsEnabled(false)
	setWaterLevel ( -100000,true,false )
end
	
	
	function unloadModel(name)
	triggerClientEvent ( root, "unLoadObject", root,name )
	end
	
addEventHandler ( "onResourceStop", root, -- If you stop the resource 'Vice City' all elements created from the resource 'Vice City' will be destoryed.
function ( resource )
	if data.objects[resource] then
		for i,v in pairs(data.objects[resource]) do
			if isElement(i) then
				destroyElement(i)
			end
		end
	data.objects[resource] = nil
	end
end 
)

--------------------------
---- Broken Functions ----
--------------------------
-- This allows server sided resources to check if an element is broken (Not 100% accurate)

function ElementBroke(Object)
	data.broken[Object] = true
end
	
addEvent( "ElementBroke", true )
addEventHandler( "ElementBroke", resourceRoot, ElementBroke) 


function stopSync()
	data.broken[source] = nil
end

addEventHandler( "onElementStopSync", resourceRoot, stopSync ) 
	
function isElementBroken(object)
	return data.broken[object]
end