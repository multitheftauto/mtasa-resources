
function string.count (text, search)
	if ( not text or not search ) then return false end
	
	return select ( 2, text:gsub ( search, "" ) );
end


function grabStuffInTable(storage,tabl,string,source)
	local source = source or tabl
	for i=1,#tabl do
		if tabl[i][2] == 'List' then
				grabStuffInTable(storage,source.lists[tabl[i][1]],string,source)
		else
			if (string.count(string.lower(tabl[i][1]),string.lower(string)) > 0) or (string.count(string.lower(tabl[i][5] or ''),string.lower(string)) > 0) then
				table.insert(storage,tabl[i])
				Cacche[string][tabl[i][1]] = true
			else
				if tabl[i][2] == 'Object' then
					if not Cacche[string][tabl[i][1]] then
						for iA,v in pairs(tabl[i][3]) do
							if not Cacche[string][tabl[i][1]] then
								if string.count(string.lower(v),string.lower(string)) > 0 then
									table.insert(storage,tabl[i])
									storage[#storage][4] = {v}
									Cacche[string][tabl[i][1]] = true
								end
							end
						end
					end
				end
			end
		end
	end
end

result = {}
Cacche = {}
function Search(input)
	if result[input] then
		return result[input]
	else
		Cacche[input] = {}
		local tabl = (buttons.right.menu[buttons.right.selected or 'New Element'])
		local count = #tabl
		
		local tTable = {}
		
		for i=1,count do
			if tabl[i][2] == "List" then
				grabStuffInTable(tTable,tabl.lists[tabl[i][1]],input,tabl)
				else
				if (string.count(string.lower(tabl[i][1]),string.lower(string)) > 0) or (string.count(string.lower(tabl[i][5] or ''),string.lower(string)) > 0) then
					table.insert(tTable,tabl[i])
				end
			end
		end
		result[input] = tTable

		return tTable
	end
end
