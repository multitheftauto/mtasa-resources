lists = {'Alpha and Non Collidable',
'Nighttime Objects',
'Beach and Sea',
'buildings',
'Car parts',
'Weapon Models',
'industrial',
'interior objects',
'land masses',
'miscellaneous',
'nature',
'structures',
'transportation',
'Wires and Cables'
}

function string.split(str)

   if not str or type(str) ~= "string" then return false end

   local splitStr = {}
   for i=1,string.len(str) do
      local char = str:sub( i, i )
      table.insert( splitStr , char )
   end

   return splitStr 
end


for i,v in pairs(lists) do
	local File =  fileOpen('lists/'..v..'.list')   
	local Data =  fileRead(File, fileGetSize(File))
	local Proccessed = split(Data,10)
	fileClose (File)
	table.insert(buttons.right.menu['New Element'].lists['San Andreas Objects'],{v,'List'})
	buttons.right.menu['New Element'].lists[v] = {}
	Parent = nil
	for iA,vA in pairs(Proccessed) do
		if string.split(vA)[1] == '#' then
				Parent = string.gsub(vA,'#','')
				table.insert(buttons.right.menu['New Element'].lists[v],{Parent,'List'})
				buttons.right.menu['New Element'].lists[Parent] = {}
			else
				local Ssplit = split(vA,',')
			if Parent then
				table.insert(buttons.right.menu['New Element'].lists[Parent],{Ssplit[1],'Object',split(Ssplit[3] or '','#'),nil,Ssplit[2]})
			else

				table.insert(buttons.right.menu['New Element'].lists[v],{Ssplit[1],'Object',split(Ssplit[3] or '','#'),nil,Ssplit[2]})
			end
		end
	end
end
