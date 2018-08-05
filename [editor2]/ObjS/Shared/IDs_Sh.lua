global = {}

function readFile()
	local File =  fileOpen('Shared/IDs.ID')   
	local Data =  fileRead(File, fileGetSize(File))
	 fileClose ( File)
	return split(Data,10)
end

function index(table,name)
	local placeholder = {}
	for i,v in pairs(table) do
		local split = split(v,",")
		placeholder[tonumber(split[1])] = split[2]
		placeholder[split[2]] = split[1]
	end
	global[name] = placeholder
end

function indexUsables(table,name)
	local placeholder = {}
	count = 0
	for i,v in pairs(table) do
		
		local split = split(v,",")
		if split[3] then -- 1 = Usable not interior, 2 = Usable but interior element
			if allowinteriors then 
				if tonumber(split[3]) == 1 then -- If interiors are enabled it'll check the number to see if it's 1
						count = count + 1
						placeholder[count] = {tonumber(split[1]),split[2]}
				end
			else
				count = count + 1
				placeholder[count] = {tonumber(split[1]),split[2]} -- If interiors are not enabled it just checks if 3 strings exist and if so writes it.
			end
		end
	end
	global[name] = placeholder
end

-- Turns files into tables
index(readFile(),'EveryID') 
indexUsables(readFile(),'Useable')


function getModelFromID(id)
	return global['EveryID'][id] -- checking a models name from server side isn't possible this is work around; plus it allows me to manipulate names and crap from the .ID file.
end

idused = {}

Starting = 0

function getFreeID(IDa)
	if data.id[IDa] then
		return data.id[IDa] -- If id is already assigned then just send back that ID
	else
		Starting = Starting + 1
		if not global['Useable'][Starting] then
			print('JStreamer Error : Out of IDS')
			return -- Kill off function to prevent spam, might make it loop through in the future if issues start to emerge.
		end
			
		if not idused[global['Useable'][Starting][1]] then
			return global['Useable'][Starting][1]
			else
			return getFreeID(IDa)
		end
	end
end
