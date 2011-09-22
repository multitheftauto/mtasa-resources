MAX_PRIRORITY_SLOT = 500

function getNextFreePrioritySlot( startAt )
	startAt = tonumber( startAt ) or 1
	local priorities = {}
	for key, value in ipairs( scoreboardColumns ) do
		priorities[tonumber(value.priority)] = true
	end
	local freePriority = startAt
	while ( priorities[freePriority] ) do
		freePriority = freePriority + 1
	end
	return freePriority
end

function isPrioritySlotFree( slot )
	if type( slot ) == "number" then
		if not (slot > MAX_PRIRORITY_SLOT or slot < 1) then
			local priorities = {}
			for key, value in ipairs( scoreboardColumns ) do
				priorities[tonumber(value.priority)] = true
			end
			return not priorities[slot]
		end
	end
	return false
end

function fixPrioritySlot( slot )
	local priorities = {}
	for key, value in ipairs( scoreboardColumns ) do
		priorities[tonumber(value.priority)] = key
	end
	if priorities[slot] then
		local freeSlot = getNextFreePrioritySlot( slot )
		if freeSlot ~= slot then
			for i=freeSlot-1, slot, -1 do
				local key = priorities[i]
				if key then
					scoreboardColumns[key].priority = scoreboardColumns[key].priority + 1
				end
			end
		end
	end
end

function table.removevalue(t, val)
	for i,v in ipairs(t) do
		if v == val then
			table.remove(t, i)
			return i
		end
	end
	return false
end