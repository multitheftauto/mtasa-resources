function elementSearch ( cachetable, query, results, foundCache )
	if not foundCache then foundCache = {} end
	query = string.lower(query)
	if results == nil then results = {} end
	for gindex, object in pairs(cachetable) do
		local model = tonumber(object["model"])
		if ( type(gindex) == "string" ) then --if a category
			results = elementSearch ( object, query, results, foundCache ) --recursively check this category
		else
			if not foundCache[model] then --if it wasnt found already
				local matches = false
				if query == "" then
					table.insert ( results, object )
					foundCache[model] = true
					matches = true
				end

				if ( string.find ( string.lower(object["name"]), query ) ) and not matches then
					table.insert ( results, object )
					foundCache[model] = true
					matches = true
				end
				if not matches then
					for keywordKey, keywordValue in pairs(object["keywords"]) do --search keywords
						if matches then break end
						if string.find ( string.lower(keywordValue), query ) then
							table.insert ( results, object )
							foundCache[model] = true
							matches = true
						end
					end
				end
				if not matches then
					if tonumber(query) then
						if string.find ( model, tonumber(query) ) then
							table.insert ( results, object )
							foundCache[model] = true
						end
					end
				end
			end
		end
	end
	return results
end


function cacheElements ( node, elemtype )
	newcache = recursiveLookup ( node, elemtype )
	return newcache
end

function recursiveLookup ( node, elemtype, cache, parent )
	if cache == nil then cache = {} end
	for i,objectnode in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName ( objectnode ) == elemtype then
			local model = xmlNodeGetAttribute ( objectnode, "model" )
			key = #cache + 1
			--Note: possibly use model as key instead of "i" so duplicate searches do not return.
			local name = xmlNodeGetAttribute ( objectnode, "name" )
			if ( not name ) and ( elemtype == "vehicle" ) then name = getVehicleNameFromModel ( tonumber(model)) end
			cache[key] = {}
			cache[key]["model"] = model
			cache[key]["name"] = name
			cache[key]["parent"] = parent
			local keywordString = xmlNodeGetAttribute ( objectnode, "keywords" )
			local keywordTable = split ( keywordString, 44 )
			cache[key]["keywords"] = {}
			for index, keyword in pairs(keywordTable) do
				cache[key]["keywords"][index] = keyword
			end
		elseif xmlNodeGetName ( objectnode ) == "group" then
			local name = xmlNodeGetAttribute ( objectnode, "name" )
			cache[name] = recursiveLookup ( objectnode, elemtype, {}, cache )
		end
	end
	return cache
end
