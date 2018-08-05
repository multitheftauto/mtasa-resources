
function string.count (text, search)
	if ( not text or not search ) then return false end
 
	return select ( 2, text:gsub ( search, "" ) )
end

	tree = {"veg_",'palm','feuillu'}
	trees = {}
	
function isVegElement(object)
	for i,v in pairs(tree) do
		if (string.count((getElementID(object) or getElementData(object,'id')),v) or 0) > 0 then -- Does a check to see if the element has a vegitation based string in its name; might add veg strings to resource configs later.
			trees[object] = true -- This assigns the object as a tree
		end
	end
end

function VegReload()
	trees = {}
	for i,v in pairs(getElementsByType('object',resourceRoot)) do
		isVegElement(v)
	end
end


vprocc = {}

function swayVegitation()
	weather1,weather2 = getWeather()

	
	if (weather1 == 8) or (weather2 == 8) then
		multiplier = 10
		else
		mulitplier = 1
	end
	
	local xr,yr,zr = getWindVelocity()



	for i,v in pairs(trees) do
		if isElement(i) then
			if isElementStreamedIn(i) then
				local x,y,z = getElementPosition(i)

	if vprocc[i] then 
		local nx,ny = unpack(vprocc[i])
			vprocc[i] = nil
		moveObject ( i, 8000,x,y,z,-nx,-ny,0 )
	else
			local xr,yr = math.random(xr+0.1,xr*multiplier+3),math.random(yr+0.1,yr*multiplier+3)
				vprocc[i] = {xr,yr}
					moveObject ( i, 8000,x,y,z,xr,yr,0 )
				end
			end
		end
	end
end

swayVegitation()

setTimer ( swayVegitation, 8000, 0)
