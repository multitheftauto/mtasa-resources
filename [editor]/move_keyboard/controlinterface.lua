addEvent "onControlPressed"
addEvent "onEditorSuspended"
addEvent "onEditorResumed"
local rootElement = getRootElement()
local commandState = {}
local keyStateToBool = { down = true, up = false }
local keybinds = {}
local keyStates = { down = true, up = true, both = true }


function math.round(number, decimals)
    decimals = decimals or 0
    return tonumber(("%."..decimals.."f"):format(number))
end

function roundToLevel(number, decimals,method)
    decimals = decimals or 1
    return math[method](number/decimals)*decimals
end

function sticknumbertoMult(number,mult,mode)
	number = number/mult
	number = math[mode](number)*mult
	return number
end

_setElementPosition = setElementPosition
function setElementPosition(element,x,y,z,warp)
	local exactsnap = exports["editor_gui"]:sx_getOptionData("enablePrecisionSnap")
	local snaplevel = tonumber(exports["editor_gui"]:sx_getOptionData("precisionLevel"))
	--outputDebugString("snaplevel:"..tostring(snaplevel).."snapmode:"..tostring(exactsnap))
	if exactsnap then
		if snaplevel <= 1 then
			x = roundToLevel(x,snaplevel,"round")
			y = roundToLevel(y,snaplevel,"round")
			z = roundToLevel(z,snaplevel,"round")
		else
			x = sticknumbertoMult(x,snaplevel,"round")
			y = sticknumbertoMult(y,snaplevel,"round")
			z = sticknumbertoMult(z,snaplevel,"round")
		end
	end
	_setElementPosition(element,x,y,z,warp)
end

_setElementRotation = setElementRotation
function setElementRotation(element,x,y,z,warp)
	local exactsnap =  exports["editor_gui"]:sx_getOptionData("enablePrecisionRotation")
	local snaplevel = tonumber(exports["editor_gui"]:sx_getOptionData("precisionRotLevel"))
	--outputDebugString("snaplevel:"..tostring(snaplevel).."snapmode:"..tostring(exactsnap))
	if exactsnap then
		if snaplevel <= 1 then
			x = roundToLevel(x,snaplevel,"round")
			y = roundToLevel(y,snaplevel,"round")
			z = roundToLevel(z,snaplevel,"round")
		else
			x = sticknumbertoMult(x,snaplevel,"round")
			y = sticknumbertoMult(y,snaplevel,"round")
			z = sticknumbertoMult(z,snaplevel,"round")
		end
	end
	_setElementRotation(element,x,y,z)
end


function bindControl ( control, keyState, handlerFunction, ... )
	if not control or keyStates[keyState] then
		return false
	end
	
	keybinds[control] = keybinds[control] or {}
	keybinds[control][keyState] = keybinds[control][keyState] or {}
	keybinds[control][keyState][handlerFunction] = {...}
	
	return true
end

function unbindControl ( control, keyState, handlerFunction )
	if not control then 
		return false 
	end
	
	--Handle the optional arguments just like bindKey
	if keyState then
		if handlerFunction then
			--The control may not be necessarily be binded
			if keybinds[control] then
				if keybinds[control][keyState] then
					keybinds[control][keyState][handlerFunction] = nil
				end
			end
		else
			if keybinds[control] then
				keybinds[control][keyState] = nil
			end
		end
	else
		keybinds[control] = nil
	end
	
	return true
end

function getCommandState ( command )
	return commandState[command]
end

function processControl ( key, keyState )
	commandState[key] = keyStateToBool[keyState]
	
	if keybinds[key] then
		if keybinds[key][keyState] then
			for handlerFunction, args in pairs(keybinds[key][keyState]) do
				handlerFunction ( key, keyState, unpack(args) )
			end
		end
	end
end
addEventHandler ( "onControlPressed", localPlayer, processControl )


addEventHandler ( "onEditorSuspended", rootElement, disable )
addEventHandler ( "onEditorResumed", rootElement, enable )
