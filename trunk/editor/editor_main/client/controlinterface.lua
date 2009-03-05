addEvent "onControlChanged"
addEvent "onEditorSuspended"
addEvent "onEditorResumed"
local rootElement = getRootElement()
local keybinds = {}
local keyStates = { down = true, up = true, both = true }

function bindControl ( control, keyState, handlerFunction, ... )
	local key = cc[control]
	if not keyStates[keyState] then return false end
	if not key then return false end
	local returnValue = bindKey ( key, keyState, handlerFunction, ... )
	if ( returnValue ) then
		keybinds[control] = keybinds[control] or {}
		keybinds[control][keyState] = keybinds[control][keyState] or {}
		keybinds[control][keyState][handlerFunction] = {...}
	end
	return returnValue
end


function unbindControl ( control, keyState, handlerFunction )
	local key = cc[control]
	if not key then return false end
	local returnValue = unbindKey ( key, keyState, handlerFunction )
	if ( returnValue ) then
		--Handle the optional arguments just like bindKey
		if keyState then
			if handlerFunction then
				--The control may not be necessarilly be binded
				if ( keybinds[control] ) then
					if ( keybinds[control][keyState] ) then
						keybinds[control][keyState][handlerFunction] = nil
					end
				end
			else
				if ( keybinds[control] ) then
					keybinds[control][keyState] = nil
				end
			end
		else
			keybinds[control] = nil
		end
	end
	return returnValue
end

addEventHandler ( "onControlsChanged", rootElement,
	function ( changedControls )
		--Table in the format of { [controlName] = newKey }
		for control,newKey in pairs(changedControls) do
			--Rebind the key
			unbindKey ( cc[control] )
			for keyState,functionTable in pairs(keybinds[control]) do
				for handlerFunction, argumentsTable in pairs(functionTable) do
					bindKey ( newKey, keyState, handlerFunction, unpack(argumentsTable) )
				end
			end
			cc[control] = newKey
		end
	end
)

addEventHandler ( "onEditorSuspended", rootElement,
	function ()
		for control,keyStateTable in pairs(keybinds) do
			for keyState,functionTable in pairs(keyStateTable) do
				for handlerFunction, argumentsTable in pairs(functionTable) do
					unbindKey ( cc[control], keyState, handlerFunction )
				end
			end
		end
	end
)

addEventHandler ( "onEditorResumed", rootElement,
	function ()
		for control,keyStateTable in pairs(keybinds) do
			for keyState,functionTable in pairs(keyStateTable) do
				for handlerFunction, argumentsTable in pairs(functionTable) do
					bindKey ( cc[control], keyState, handlerFunction, unpack(argumentsTable) )
				end
			end
		end
	end
)

