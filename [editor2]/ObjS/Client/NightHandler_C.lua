off = {}
nightElements = {}


function isNightElement(object)

local id = getElementID(object)

if type(cache.defintions[id]) == 'table' then
	if tonumber(cache.defintions[id].on) then
		nightElements[id] = nightElements[id] or {}
		off[id] = off[id] or false
		nightElements[id][#nightElements[id]+1] = object
		
					if getLowLODElement(object) then
						nightElements[id][#nightElements[id]+1] = getLowLODElement(object)
			end
		end
	end
end

function NightReload()
	nightElements = {}
	for i,v in pairs(getElementsByType('object',resourceRoot)) do
		isNightElement(v)
	end
end


function isInTimeRange(start,stop)
hour = getTime()

	if start > stop then
		return (hour < start and hour > stop)
	else
		return (not (hour < stop and hour > start))
	end
end


function NightTimeElementCheck()

for i,v in pairs(nightElements) do
	
	if not tonumber(cache.defintions[i].on) then
		NightReload()
	else
	
	if isInTimeRange(tonumber(cache.defintions[i].on),tonumber(cache.defintions[i].off)) then
		if not off[i] then
			off[i] = true
				for ia,va in pairs(v) do
					if isElement(va) then
						setObjectScale(va,0)
					end
				end
			end
	else
		if off[i] then
			off[i] = false
				for ia,va in pairs(v) do
					if isElement(va) then
						setObjectScale(va,1)
						end
					end
				end
			end
		end
	end
end

setTimer(NightTimeElementCheck,1000,0)
