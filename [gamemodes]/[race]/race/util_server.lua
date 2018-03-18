g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())

function clientCall(player, fnName, ...)
	triggerClientEvent(onlyJoined(player), 'onClientCall_race', resourceRoot, fnName, ...)
end

g_AllowedRPCFunctions = {}

function allowRPC(...)
	for i,name in ipairs({...}) do
		g_AllowedRPCFunctions[name] = true
	end
end

addEvent('onServerCall_race', true)
addEventHandler('onServerCall_race', resourceRoot,
	function(fnName, ...)
		if checkClient( false, source, 'onServerCall_race' ) then return end
		if g_AllowedRPCFunctions[fnName] then
			local fn = _G
			for i,pathpart in ipairs(fnName:split('.')) do
				fn = fn[pathpart]
			end
			fn(...)
		end
	end
)

local _warpPedIntoVehicle = warpPedIntoVehicle
function warpPedIntoVehicle(player, vehicle)
	if isValidPlayer(player) then
		if getPedOccupiedVehicle(player) ~= vehicle then
			if isValidPlayerVehicle(player,vehicle) then
				_warpPedIntoVehicle(player, vehicle)
			end
		end
	end
end

g_Messages = {}		-- { player =  { display = display, textitem = textitem, timer = timer } }
function showMessage(text, r, g, b, player)
    local ypos = 0.25
	if not player then
		player = g_Root
        ypos = 0.35
	end

	if g_Messages[player] then
		TimerManager.destroyTimersFor("message",player)
	else
		g_Messages[player] = {
			display = textCreateDisplay(),
			textitem = textCreateTextItem('', 0.5, ypos, 'medium', 255, 0, 0, 255, 3.0, 'center', 'center', 128)
		}
	end

	local display = g_Messages[player].display
	local textitem = g_Messages[player].textitem
	textDisplayAddText(display, textitem)
	textItemSetText(textitem, text)
	textItemSetColor(textitem, r or 255, g or 0, b or 0, 255)
	if player == g_Root then
		for i,player in ipairs(getElementsByType('player')) do
			textDisplayAddObserver(display, player)
		end
	else
		textDisplayAddObserver(display, player)
	end
	TimerManager.createTimerFor("raceresource","message",player):setTimer(destroyMessage, 8000, 1, player)
end

function destroyMessage(player)
	TimerManager.destroyTimersFor("message",player)
	if not g_Messages[player] then
		return
	end
	textDestroyDisplay(g_Messages[player].display)
	textDestroyTextItem(g_Messages[player].textitem)
	g_Messages[player] = nil
end

function destroyAllMessages()
    for key,value in pairs(g_Messages) do
        destroyMessage(key)
    end
    g_Messages = {}
end


function setVehicleID(vehicle, id)
	setElementModel(vehicle, id)
	local player = getVehicleController(vehicle)
	if player then
		Override.setAlpha( "ForRCVehicles", player, g_RCVehicleIDs[id] and 0 or nil )
	end
    if g_GameOptions.vehiclecolors == 'random' then
		setRandomSeedForMap('vehiclecolors')
		local vehicleColorFixed = false
		for vehicleID,color in pairs(g_FixedColorVehicles) do
			if vehicleID == tonumber(id) then
				if color then
					setVehicleColor(vehicle, color[1], color[2], color[3], color[4])
				end
				vehicleColorFixed = true
				break
			end
		end
		if not vehicleColorFixed then
			setVehicleColor(vehicle, math.random(0, 126), math.random(0, 126), 0, 0)
		end
	end
	TimerManager.createTimerFor("map",vehicle):setTimer(revertVehicleWheels, 1000, 1, vehicle)
	TimerManager.createTimerFor("map",vehicle):setTimer(revertVehicleDoors, 1000, 1, vehicle)

	return vehicle
end

function revertVehicleWheels(vehicle)
	local wheels = { getVehicleWheelStates(vehicle) }
	if table.find(wheels, 2) then
		setVehicleWheelStates(vehicle, 0, 0, 0, 0)
	end
end

function revertVehicleDoors(vehicle)
	for i=2,5 do
		setVehicleDoorState(vehicle, i, 0)
	end
end

function setVehiclePaintjobAndUpgrades(vehicle, paintjob, upgrades)
	if paintjob then
		setVehiclePaintjob(vehicle, paintjob)
	end
	if upgrades and type(upgrades) == 'table' then
		local appliedUpgrade
		local appliedUpgrades = getVehicleUpgrades(vehicle)
		local k
		for i=#appliedUpgrades,1,-1 do
			appliedUpgrade = appliedUpgrades[i]
			k = table.find(upgrades, appliedUpgrade)
			if k then
				table.remove(upgrades, k)
			else
				removeVehicleUpgrade(vehicle, appliedUpgrade)
			end
		end
		for i,upgrade in ipairs(upgrades) do
			addVehicleUpgrade(vehicle, upgrade)
		end
	end
end

function getVehicleCompatibleUpgradesGrouped(vehicle)
	local upgrades = getVehicleCompatibleUpgrades(vehicle)
	local result = {}
	local slotName
	for i,upgrade in ipairs(upgrades) do
		slotName = getVehicleUpgradeSlotName(upgrade)
		if not result[slotName] then
			result[slotName] = {}
		end
		table.insert(result[slotName], upgrade)
	end
	return result
end

function pimpVehicleRandom(vehicle)
    setRandomSeedForMap('upgrades')
	if not g_PimpableVehicles then
		g_PimpableVehicles = table.create(
			{
				602, 496, 401, 518, 527, 589, 419, 533, 526, 474,
				545, 517, 410, 600, 436, 580, 439, 549, 491,
				445, 605, 507, 585, 587, 466, 592, 546, 551, 516,
				467, 426, 547, 405, 409, 550, 566, 540, 421, 529,
				536, 575, 534, 567, 535, 576, 412,
				402, 542, 603, 475,
				444, 556, 557, 495,
				429, 541, 415, 480, 562, 565, 434,
				411, 559, 561, 560, 506, 451, 558, 555, 477
			},
			true
		)
	end
	if not g_PimpableVehicles[getElementModel(vehicle)] then
		return
	end
	for slotName,upgrades in pairs(getVehicleCompatibleUpgradesGrouped(vehicle)) do
		if slotName ~= 'Nitro' and slotName ~= 'Hydraulics' then
			addVehicleUpgrade(vehicle, upgrades[math.random(#upgrades)])
		end
	end
end

function getRandomFromRangeList(rangelist)
	-- takes a string of the form "4 10 16-20 15" and returns a random number that is in this list
	local range = table.random(tostring(rangelist):split(' '))
	local low, high = range:match('(%d+)-(%d+)')
	if low then
		return math.random(tonumber(low), tonumber(high))
	else
		return tonumber(range)
	end
end

function destroyBlipsAttachedTo(elem)
	table.each(table.filter(getAttachedElements(elem) or {}, getElementType, 'blip'), destroyElement)
end

function showBlipsAttachedTo(elem, bShow)
	local elements = getAttachedElements ( elem )
	for k,v in ipairs( elements ) do
		if ( getElementType( v ) == "blip" ) then
			local r,g,b,a = getBlipColor ( v )
			a = bShow and 255 or 0
			setBlipColor ( v, r,g,b,a )
		end
	end
end


function getStringFromColor(r, g, b)
	return string.format('#%02X%02X%02X', r, g, b)
end

function isPlayerInACLGroup(player, groupName)
	local account = getPlayerAccount(player)
	if not account then
		return false
	end
	local accountName = getAccountName(account)
	for _,name in ipairs(string.split(groupName,',')) do
		local group = aclGetGroup(name)
		if group then
			for i,obj in ipairs(aclGroupListObjects(group)) do
				if obj == 'user.' .. accountName or obj == 'user.*' then
					return true
				end
			end
		end
	end
	return false
end

---------------------------------------------------------------------------
-- Version
---------------------------------------------------------------------------
function getBuildString()
	return getResourceInfo(getThisResource(), 'build') or 'n/a'
end

--------------------------------
-- Table extensions

function table.map(t, callback, ...)
	for k,v in ipairs(t) do
		t[k] = callback(v, ...)
	end
	return t
end

function table.maptry(t, callback, ...)
	for k,v in pairs(t) do
		t[k] = callback(v, ...)
		if not t[k] then
			return false
		end
	end
	return t
end

function table.each(t, index, callback, ...)
	local args = { ... }
	if type(index) == 'function' then
		table.insert(args, 1, callback)
		callback = index
		index = false
	end
	for k,v in pairs(t) do
		callback(index and v[index] or v, unpack(args))
	end
	return t
end

function table.find(t, ...)
	local args = { ... }
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				return k
			end
		end
		return false
	end

	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			return k
		end
	end
	return false
end

function table.merge(t1, t2)
	local l = #t1
	for i,v in ipairs(t2) do
		t1[l+i] = v
	end
	return t1
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

function table.deletevalue(t, val)
	for k,v in pairs(t) do
		if v == val then
			t[k] = nil
			return k
		end
	end
	return false
end

function table.deepcopy(t)
	local known = {}
	local function _deepcopy(t)
		local result = {}
		for k,v in pairs(t) do
			if type(v) == 'table' then
				if not known[v] then
					known[v] = _deepcopy(v)
				end
				result[k] = known[v]
			else
				result[k] = v
			end
		end
		return result
	end
	return _deepcopy(t)
end

function table.random(t)
	return t[math.random(#t)]
end

function table.dump(t, caption, depth)
	if not depth then
		depth = 1
	end
	if depth == 1 and caption then
		outputConsole(caption .. ':')
	end
	if not t then
		outputConsole('Table is nil')
	elseif type(t) ~= 'table' then
		outputConsole('Argument passed is of type ' .. type(t))
		local str = tostring(t)
		if str then
			outputConsole(str)
		end
	else
		local braceIndent = string.rep('  ', depth-1)
		local fieldIndent = braceIndent .. '  '
		outputConsole(braceIndent .. '{')
		for k,v in pairs(t) do
			if type(v) == 'table' and k ~= 'siblings' and k ~= 'parent' then
				outputConsole(fieldIndent .. tostring(k) .. ' = ')
				table.dump(v, nil, depth+1)
			else
				outputConsole(fieldIndent .. tostring(k) .. ' = ' .. tostring(v))
			end
		end
		outputConsole(braceIndent .. '}')
	end
end

function table.create(keys, vals)
	local result = {}
	if type(vals) == 'table' then
		for i,k in ipairs(keys) do
			result[k] = vals[i]
		end
	else
		for i,k in ipairs(keys) do
			result[k] = vals
		end
	end
	return result
end

function table.filter(t, callback, cmpval)
	if cmpval == nil then
		cmpval = true
	end
	for k,v in pairs(t) do
		if callback(v) ~= cmpval then
			t[k] = nil
		end
	end
	return t
end

function table.insertUnique(t,val)
    if not table.find(t, val) then
        table.insert(t,val)
    end
end


function string:split(separator)
	if separator == '.' then
		separator = '%.'
	end
	local result = {}
	for part in self:gmatch('(.-)' .. separator) do
		result[#result+1] = part
	end
	result[#result+1] = self:match('.*' .. separator .. '(.*)$') or self
	return result
end


function msToTimeStr(ms)
	if not ms then
		return ''
	end
	local centiseconds = tostring(math.floor(math.fmod(ms, 1000)/10))
	if #centiseconds == 1 then
		centiseconds = '0' .. centiseconds
	end
	local s = math.floor(ms / 1000)
	local seconds = tostring(math.fmod(s, 60))
	if #seconds == 1 then
		seconds = '0' .. seconds
	end
	local minutes = tostring(math.floor(s / 60))
	return minutes .. ':' .. seconds .. ':' .. centiseconds
end


function getTickTimeStr()
    return msToTimeStr(getTickCount())
end


function outputDebug( chan, msg )
    if _DEBUG_LOG then
        if not msg then
            msg = chan
            chan = 'UNDEF'
        end
        if table.find(_DEBUG_LOG,chan) then
            outputDebugString( getTickTimeStr() .. ' DEBUG: ' .. msg )
        end
    end
    if g_PipeDebugTo then
        if not table.find(getElementsByType('player'), g_PipeDebugTo) then
            outputWarning( 'cleared g_PipeDebugTo' )
            g_PipeDebugTo = nil
        else
            outputConsole( getTickTimeStr() .. ' DEBUG: ' .. (msg or chan), g_PipeDebugTo )
        end
    end
end


-- Always send to server window
-- and all client consoles
function outputWarning( msg )
    outputDebugString( getTickTimeStr() .. ' WARNING: ' .. msg )
    outputConsole( getTickTimeStr() .. ' WARNING: ' .. msg )
end

-- Always send to server window
-- and chat box window
function outputError( msg )
    outputDebugString( getTickTimeStr() .. ' ERROR: ' .. msg )
    outputChatBox( getTickTimeStr() .. ' ERROR: ' .. msg )
end


---------------------------------------------------------------------------
--
-- getRealDateTimeNowString()
--
-- current date and time as a sortable string
-- eg '2010-12-25 15:32:45'
--
---------------------------------------------------------------------------
function getRealDateTimeNowString()
    return getRealDateTimeString( getRealTime() )
end

function getRealDateTimeString( time )
    return string.format( '%04d-%02d-%02d %02d:%02d:%02d'
                        ,time.year + 1900
                        ,time.month + 1
                        ,time.monthday
                        ,time.hour
                        ,time.minute
                        ,time.second
                        )
end

function getRealTimeSeconds()
	return realTimeDateToSeconds( getRealTime() )
end

function realTimeDateToSeconds( time )
	local leapyears = math.floor( ( time.year - 72 + 3 ) / 4 )
	local days = ( time.year - 70 ) * 365 + leapyears + time.yearday
	local seconds = days * 60*60*24
	seconds = seconds + time.hour * 60*60
	seconds = seconds + time.minute * 60
	seconds = seconds + time.second
	seconds = seconds - time.isdst * 60*60
	return seconds
end

function realTimeDateToSecondsTest()
	for i=1,100 do
		local time1 = getRealTime( math.random(0, 60*60*24*365*50) )	-- Get a random date between 1970 and 2020
		local time2 = getRealTime( realTimeToSeconds( time1 ) )
		assert( getRealDateTimeString( time1 ) == getRealDateTimeString( time2 ) )
	end
end

---------------------------------------------------------------------------
--
-- gets
--
---------------------------------------------------------------------------

-- get string or default
function getString(var,default)
    local result = get(var)
    if not result then
        return default
    end
    return tostring(result)
end

-- get number or default
function getNumber(var,default)
    local result = get(var)
    if not result then
        return default
    end
    return tonumber(result)
end

-- get true or false or default
function getBool(var,default)
    local result = get(var)
    if not result then
        return default
    end
    return result == 'true'
end
