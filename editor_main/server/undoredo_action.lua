local DESTROYED_ELEMENT_DIMENSION = getWorkingDimension() + 1

-- ACTION CLASSES

ActionMove = {}

-- private

ActionMove.element = false
ActionMove.name = "move"
ActionMove.oldPosX, ActionMove.curPosX = 0, 0
ActionMove.oldPosY, ActionMove.curPosY = 0, 0
ActionMove.oldPosZ, ActionMove.curPosZ = 0, 0
ActionMove.oldRotX, ActionMove.curRotX = 0, 0
ActionMove.oldRotY, ActionMove.curRotY = 0, 0
ActionMove.oldRotZ, ActionMove.curRotZ = 0, 0
ActionMove.oldScale, ActionMove.curScale = 1, 1

function ActionMove:new(object)
    object = object or {}
    setmetatable(object, self)
    self.__index = self
    if (object.element and isElement(object.element)) then
        object:setElementCurrentPositionAndRotation()
    end
    return object
end

function ActionMove:setElementCurrentPositionAndRotation()
	self.curPosX, self.curPosY, self.curPosZ = edf.edfGetElementPosition(self.element)
	self.curRotX, self.curRotY, self.curRotZ = edf.edfGetElementRotation(self.element)
	self.curScale = edf.edfGetElementScale(self.element)
end

-- public

function ActionMove:getActionName()
	return self.name
end

function ActionMove:setElement(element)
	if (element and isElement(element)) then
	    self.element = element
	    self:setElementCurrentPositionAndRotation()
	    return true
	else
	    return false
	end
end

function ActionMove:performUndo()
	if (self.element and isElement(self.element) and self.oldPosX and self.oldPosY and self.oldPosZ) then
		edf.edfSetElementPosition(self.element, self.oldPosX, self.oldPosY, self.oldPosZ)
		if (self.oldRotX and self.oldRotY and self.oldRotZ) then
			edf.edfSetElementRotation(self.element, self.oldRotX, self.oldRotY, self.oldRotZ)
		end
		if (self.oldScale) then
			edf.edfSetElementScale(self.element, self.oldScale)
		end
	else
		outputDebugString("Cannot perform undo: element does not exist, position does not exist, or invalid element (ActionMove:performUndo)")
		return false
	end
end

function ActionMove:performRedo()
	if (self.element and isElement(self.element) and self.curPosX and self.curPosY and self.curPosZ) then
		edf.edfSetElementPosition(self.element, self.curPosX, self.curPosY, self.curPosZ)
		if (self.curRotX and self.curRotY and self.curRotZ) then
			edf.edfSetElementRotation(self.element, self.curRotX, self.curRotY, self.curRotZ)
		end
		if (self.curScale) then
			edf.edfSetElementScale(self.element, self.curScale)
		end
	else
		outputDebugString("Cannot perform redo: element does not exist, position does not exist, or invalid element")
		return false
	end
end

function ActionMove:destructor()
	return true
end


ActionCreate = {}

-- private

ActionCreate.element = false
ActionCreate.name = "create"

function ActionCreate:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

-- public

function ActionCreate:getActionName()
	return self.name
end

function ActionCreate:setElement(element)
	if (element and isElement(element)) then
	    self.element = element
	    return true
	else
	    return false
	end
end

function ActionCreate:performUndo()
	if (self.element and isElement(self.element)) then
		if ( getElementType ( self.element ) == "removeWorldObject" ) then
			local model = getElementData ( self.element, "model" )
			local lodModel = getElementData ( self.element, "lodModel" )
			local posX = getElementData ( self.element, "posX" )
			local posY = getElementData ( self.element, "posY" )
			local posZ = getElementData ( self.element, "posZ" )
			local scale = getElementData ( self.element, "scale" )
			local interior = getElementData ( self.element, "interior" )
			local radius = getElementData ( self.element, "radius" )
			restoreWorldModel ( model, radius, posX, posY, posZ, interior )
			restoreWorldModel ( lodModel, radius, posX, posY, posZ, interior )
		end

		edf.edfSetElementDimension(self.element, DESTROYED_ELEMENT_DIMENSION)
		triggerEvent("onElementDestroy", self.element)
		triggerClientEvent(root, "onClientElementDestroyed", self.element)
	else
		outputDebugString("Cannot perform undo: element does not exist or invalid element (ActionCreate:performUndo)")
		return false
	end
end

function ActionCreate:performRedo()
	if (self.element and isElement(self.element)) then
		if ( getElementType ( self.element ) == "removeWorldObject" ) then
			local model = getElementData ( self.element, "model" )
			local lodModel = getElementData ( self.element, "lodModel" )
			local posX = getElementData ( self.element, "posX" )
			local posY = getElementData ( self.element, "posY" )
			local posZ = getElementData ( self.element, "posZ" )
			local scale = getElementData ( self.element, "scale" )
			local interior = getElementData ( self.element, "interior" )
			local radius = getElementData ( self.element, "radius" )
			removeWorldModel ( model, radius, posX, posY, posZ, interior )
			removeWorldModel ( lodModel, radius, posX, posY, posZ, interior )
			edf.edfSetElementDimension(self.element, getWorkingDimension())

			return true
		end

		edf.edfSetElementDimension(self.element, getWorkingDimension())
		triggerEvent("onElementCreate", self.element)
		triggerClientEvent(root, "onClientElementCreate", self.element)
	else
		outputDebugString("Cannot perform undo: element does not exist or invalid element (ActionCreate:performRedo)")
		return false
	end
end

function ActionCreate:destructor()
	if (self.element and isElement(self.element)) then
		destroyElement(self.element)
		return true
	else
		outputDebugString("Cannot destroy element: element does not exist or invalid element")
		return false
	end
end


ActionDestroy = {}

-- private

ActionDestroy.element = false
ActionDestroy.name = "destroy"
ActionDestroy.parentOf = {}

function ActionDestroy:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	if (object.element and isElement(object.element)) then
		object:setElement(object.element)
	end
	return object
end

-- public

function ActionDestroy:getActionName()
	return self.name
end

local function getElementsWithParent(element, base, res)
	base = base or mapContainer
	res = res or {}
	local children = getElementChildren(base)

	for k,child in ipairs(children) do
		getElementsWithParent(element, child, res)
	end

	if getElementData(base, "me:parent") == element then
		table.insert(res, base)
	end

	return res
end
function ActionDestroy:setElement(element)
	if (element and isElement(element)) then
		self.element = element
		local setDimension = edf.edfSetElementDimension(self.element, DESTROYED_ELEMENT_DIMENSION)
		if (not setDimension) then -- For some unknown reason peds sometimes can't get their dimension set, MTA bug
			-- If we can't make it undo-deleted then we'll have to fully delete it
			destroyElement(element)
			return false
		end

		self.parentOf = getElementsWithParent(self.element)
		for k,element2 in ipairs(self.parentOf) do
			setElementData(element2, "me:parent", nil)
		end

		self.references = getElementData(element,"me:references")
		if self.references then
			for refElement,property in pairs(self.references) do
				edf.edfSetElementProperty(refElement, property, nil)
			end
		end

		return true
	else
		return false
	end
end

function ActionDestroy:performUndo()
	if (self.element and isElement(self.element)) then
		edf.edfSetElementDimension(self.element, getWorkingDimension())
		triggerEvent("onElementCreate", self.element)
		triggerClientEvent(root, "onClientElementCreate", self.element)

		for k,element in ipairs(self.parentOf) do
			setElementData(element, "me:parent", self.element)
		end

		if self.references then
			for refElement,property in pairs(self.references) do
				edf.edfSetElementProperty(refElement, property, self.element)
			end
		end
	else
		outputDebugString("Cannot perform undo: element does not exist or invalid element (ActionDestroy:performUndo)")
		return false
	end
end

function ActionDestroy:performRedo()
	if (self.element and isElement(self.element)) then
		edf.edfSetElementDimension(self.element, DESTROYED_ELEMENT_DIMENSION)
		triggerEvent("onElementDestroy", self.element)
		triggerClientEvent(root, "onClientElementDestroyed", self.element)

		for k,element in ipairs(self.parentOf) do
			setElementData(element, "me:parent", nil)
		end

		if self.references then
			for refElement,property in pairs(self.references) do
				edf.edfSetElementProperty(refElement, property, nil)
			end
		end
	else
		outputDebugString("Cannot perform undo: element does not exist or invalid element (ActionDestroy:performRedo)")
		return false
	end
end

function ActionDestroy:destructor()
	if (self.element and isElement(self.element)) then
		if (edf.edfGetElementDimension(self.element) == DESTROYED_ELEMENT_DIMENSION) then
			destroyElement(self.element)
		end
		return true
	else
		outputDebugString("Cannot destroy element: element does not exist or invalid element (ActionDestroy:destructor)")
		return false
	end
end


ActionProperties = {}

-- private

ActionProperties.element = false
ActionProperties.name = "properties"
ActionProperties.oldProperties = false
ActionProperties.newProperties = false

function ActionProperties:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

-- public

function ActionProperties:getActionName()
	return self.name
end

function ActionProperties:setElement(element)
	if (element and isElement(element)) then
		self.element = element
		return true
	else
		return false
	end
end

function ActionProperties:performUndo()
	if (self.element and isElement(self.element)) then
		syncProperties(self.newProperties, self.oldProperties, self.element, true)
	else
		outputDebugString("Cannot perform undo: element does not exist or invalid element (ActionProperties:performUndo)")
		return false
	end
end

function ActionProperties:performRedo()
	if (self.element and isElement(self.element)) then
		syncProperties(self.oldProperties, self.newProperties, self.element, true)
	else
		outputDebugString("Cannot perform redo: element does not exist or invalid element")
		return false
	end
end

function ActionProperties:destructor()
	return true
end

