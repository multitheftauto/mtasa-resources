local root = getRootElement()
-- make sure events dont get called more than once in a row!

-- action list
local actionList = {}
local index = 0

-- action states
local justUndid = false
local justRedid = false
local justAdded = false

-- ADD
function insertAction(action) -- messes shit up
	-- insert action into list, removing any actions that might come after it
	if (not justUndid) then
		removeActionsAfterIndex(index)
		index = index + 1
	else
		removeActionsAfterIndex(index-1)
	end
	table.insert(actionList, index, action)
	-- update action state flags
	justUndid = false
	justRedid = false
	justAdded = true
end

-- create
function addActionElementCreate()
	local tempAction = ActionCreate:new{element = source}
	-- give an error if the action wasn't added successfully
	assert(tempAction, "failed to add element Create action")
	-- insert the action into the list
	insertAction(tempAction)
end
addEventHandler("onElementCreate_undoredo", root, addActionElementCreate)

-- move
function addActionElementMove(oldPosX, oldPosY, oldPosZ, oldRotX, oldRotY, oldRotZ)
	local tempAction = ActionMove:new{ element = source, oldPosX = oldPosX, oldPosY = oldPosY, oldPosZ = oldPosZ,
										oldRotX = oldRotX, oldRotY = oldRotY, oldRotZ = oldRotZ}
	-- give an error if the action wasn't added successfully
	assert(tempAction, "failed to add element Move action")
	-- insert the action into the list
	insertAction(tempAction)
end
addEventHandler("onElementMove_undoredo", root, addActionElementMove)

-- destroy
function addActionElementDestroy()
	local tempAction = ActionDestroy:new{element = source}
	-- give an error if the action wasn't added successfully
	assert(tempAction, "failed to add element Destroy action")
	-- insert the action into the list
	insertAction(tempAction)
end
addEventHandler("onElementDestroy_undoredo", root, addActionElementDestroy)

-- properties
function addActionElementPropertiesChange(oldProperties, newProperties)
	local tempAction = ActionProperties:new{element = source, oldProperties = oldProperties, newProperties = newProperties}

	-- give an error if the action wasn't added successfully
	assert(tempAction, "failed to add element Property changes action")
	-- insert the action into the list
	insertAction(tempAction)
end
addEventHandler("onElementPropertiesChange_undoredo", root, addActionElementPropertiesChange)

-- removes lowIndex??
function removeActionsAfterIndex(lowIndex)
	local curIndex = #actionList
	while (curIndex > lowIndex) do
		actionList[curIndex]:destructor()
		table.remove(actionList, curIndex)
		curIndex = curIndex - 1
	end
end

function undo()
	if (justUndid) then
		if (index > 1) then
			index = index - 1
			actionList[index]:performUndo()
			-- update action state flags
			justUndid = true
			justRedid = false
			justAdded = false
		end
	elseif (justRedid or justAdded) then
		actionList[index]:performUndo()
		-- update action state flags
		justUndid = true
		justRedid = false
		justAdded = false
	end
end
addCommandHandler("undo", undo)
addEventHandler("doUndo", root, undo)

function redo()
	if (not justAdded) then
		if (justRedid) then
			if (actionList[index+1]) then
				index = index + 1
				actionList[index]:performRedo()
				-- update action state flags
				justUndid = false
				justRedid = true
				justAdded = false
			end
		elseif (justUndid) then
			actionList[index]:performRedo()
			-- update action state flags
			justUndid = false
			justRedid = true
			justAdded = false
		end
	end
end
addCommandHandler("redo", redo)
addEventHandler("doRedo", root, redo)
