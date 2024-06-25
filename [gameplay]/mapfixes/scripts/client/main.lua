addEvent("mapfixes:client:loadAllComponents", true)
addEvent("mapfixes:client:togOneComponent", true)

local mapFixComponents = {}

local function loadOneMapFixComponent(name, data)
    -- Restore previously replaced models if any
    local modelsToReplace = data.modelsToReplace
    if modelsToReplace then
        for _, v in pairs(modelsToReplace) do
            engineRestoreCOL(v.modelID)
            engineRestoreModel(v.modelID)
        end
    end
    -- Clear the previous elements if any
    local createdElements = data.createdElements
    if createdElements then
        for _, element in pairs(createdElements) do
            if isElement(element) then
                destroyElement(element)
            end
        end
        data.createdElements = {}
    end
    -- Clear the previous requested model IDs if any
    local allocatedIDs = data.allocatedIDs
    if allocatedIDs then
        for _, modelID in pairs(allocatedIDs) do
            engineFreeModel(modelID)
        end
        data.allocatedIDs = {}
    end
    -- Restore the previous removed models if any
    local worldModelsToRemove = data.worldModelsToRemove
    if worldModelsToRemove then
        for _, v in pairs(worldModelsToRemove) do
            restoreWorldModel(unpack(v))
        end
    end
    -- Close previously opened garages if any
    local garageIDsForInteriorsToOpen = data.garageIDsForInteriorsToOpen
    if garageIDsForInteriorsToOpen then
        for _, garageID in pairs(garageIDsForInteriorsToOpen) do
            setGarageOpen(garageID, false)
        end
    end

    -- Don't proceed if the component is disabled
    if not data.enabled then
        return
    end

    -- Replace models if any
    if modelsToReplace then
        for _, v in pairs(modelsToReplace) do
            if v.colPath then
                local colElement = engineLoadCOL("models/" .. v.colPath)
                if colElement then
                    engineReplaceCOL(colElement, v.modelID)
                    if not data.createdElements then data.createdElements = {} end
                    data.createdElements[#data.createdElements + 1] = colElement
                end
            end
        end
    end
    -- Create the new elements if any
    local buildingsToSpawn = data.buildingsToSpawn
    if buildingsToSpawn then
        for _, v in pairs(buildingsToSpawn) do
            local building = createBuilding(unpack(v))
            if building then
                if not data.createdElements then data.createdElements = {} end
                data.createdElements[#data.createdElements + 1] = building
            end
        end
    end
    local objectsWithCustomPropertiesGroupToSpawn = data.objectsWithCustomPropertiesGroupToSpawn
    if objectsWithCustomPropertiesGroupToSpawn then
        for _, v in pairs(objectsWithCustomPropertiesGroupToSpawn) do
            if not data.allocatedIDs then data.allocatedIDs = {} end
            local allocatedID = engineRequestModel("object", v.modelID)
            if allocatedID then
                data.allocatedIDs[#data.allocatedIDs + 1] = allocatedID
                local object = createObject(allocatedID, v.x, v.y, v.z, v.rx, v.ry, v.rz)
                if object then
                    engineSetModelPhysicalPropertiesGroup(allocatedID, v.physicalPropertiesGroup)
                    if not data.createdElements then data.createdElements = {} end
                    data.createdElements[#data.createdElements + 1] = object
                end
            end
        end
    end
    -- Remove world models if any
    if worldModelsToRemove then
        for _, v in pairs(worldModelsToRemove) do
            removeWorldModel(unpack(v))
        end
    end
    -- Open garages if any
    if garageIDsForInteriorsToOpen then
        for _, garageID in pairs(garageIDsForInteriorsToOpen) do
            setGarageOpen(garageID, true)
        end
    end
end

local function loadMapFixComponents(mapFixComponentsFromServer)
    assert(type(mapFixComponentsFromServer) == "table")
    mapFixComponents = mapFixComponentsFromServer
    for name, data in pairs(mapFixComponents) do
        loadOneMapFixComponent(name, data)
    end
end
addEventHandler("mapfixes:client:loadAllComponents", localPlayer, loadMapFixComponents, false)

local function toggleOneMapFixComponent(name, enable)
    assert(type(name) == "string")
    assert(type(enable) == "boolean")
    local data = mapFixComponents[name]
    if not data then
        return
    end
    data.enabled = (enable == true)
    loadOneMapFixComponent(name, data)
    if eventName ~= "onClientResourceStop" then
        outputDebugString("Map fix component '" .. name .. "' is now " .. (data.enabled and "enabled" or "disabled"))
    end
end
addEventHandler("mapfixes:client:togOneComponent", resourceRoot, toggleOneMapFixComponent, false)

local function unloadAllMapFixComponents()
    for name, _ in pairs(mapFixComponents) do
        toggleOneMapFixComponent(name, false)
    end
end
addEventHandler("onClientResourceStop", resourceRoot, unloadAllMapFixComponents, false)
