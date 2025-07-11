-- make sure events dont get called more than once in a row!

-- action list
actionList = {}
currentActionIndex = 0

-- ADD
function insertAction(action) -- messes shit up
	-- insert action into list, removing any actions that might come after it
    while #actionList > currentActionIndex do
        table.remove(actionList, #actionList)
    end
	currentActionIndex = currentActionIndex + 1
    table.insert(actionList, currentActionIndex, action)
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
function addActionElementMove(oldPosX, oldPosY, oldPosZ, oldRotX, oldRotY, oldRotZ, oldScale)
	local tempAction = ActionMove:new{ element = source, oldPosX = oldPosX, oldPosY = oldPosY, oldPosZ = oldPosZ,
										oldRotX = oldRotX, oldRotY = oldRotY, oldRotZ = oldRotZ, oldScale = oldScale}
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

function undo()
    if currentActionIndex > 0 then
        actionList[currentActionIndex]:performUndo()
        currentActionIndex = currentActionIndex - 1
    end
end
addCommandHandler("undo", undo)
addEventHandler("doUndo", root, undo)

function redo()
    if currentActionIndex < #actionList then
        currentActionIndex = currentActionIndex + 1
        actionList[currentActionIndex]:performRedo()
    end
end
addCommandHandler("redo", redo)
addEventHandler("doRedo", root, redo)
