--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	admin_wrapper.lua
*
*	Original File by lil_Toady
*
**************************************]]

function table.reverse(t)
	local newt = {}
	for idx,item in ipairs(t) do
		newt[#t - idx + 1] = item
	end
	return newt
end

function table.cmp(t1, t2)
	if not t1 or not t2 or #t1 ~= #t2 then
		return false
	end
	for k,v in pairs(t1) do
		if v ~= t2[k] then
			return false
		end
	end
	return true
end

function table.compare(tab1,tab2)
    if tab1 and tab2 then
        if tab1 == tab2 then
            return true
        end
        if type(tab1) == 'table' and type(tab2) == 'table' then
            if table.size(tab1) ~= table.size(tab2) then
                return false
            end
            for index, content in pairs(tab1) do
                if not table.compare(tab2[index],content) then
                    return false
                end
            end
            return true
        end
    end
    return false
end

function table.size(tab)
    local length = 0
    if tab then
        for _ in pairs(tab) do
            length = length + 1
        end
    end
    return length
end