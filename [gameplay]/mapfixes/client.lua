addEvent("mapfixes:client:loadAllComponents", true)
addEvent("mapfixes:client:togOneComponent", true)

local mapFixComponents = {}

local function loadOneMapFixComponent(name, data)
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
    -- Restore the previous removed models if any
    local removeWorldModels = data.removeWorldModels
    if removeWorldModels then
        for _, v in pairs(removeWorldModels) do
            restoreWorldModel(unpack(v))
        end
    end

    -- Don't proceed if the component is disabled
    if not data.enabled then
        return
    end

    -- Create the new elements if any
    local spawnBuildings = data.spawnBuildings
    if spawnBuildings then
        data.createdElements = {}
        for _, v in pairs(spawnBuildings) do
            local building = createBuilding(unpack(v))
            if building then
                data.createdElements[#data.createdElements + 1] = building
            end
        end
    end
    -- Remove world models if any
    if removeWorldModels then
        for _, v in pairs(removeWorldModels) do
            iprint(name, v)
            removeWorldModel(unpack(v))
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
        outputDebugString("Map fix component '"..name.."' is now "..(data.enabled and "enabled" or "disabled")..".")
    end
end
addEventHandler("mapfixes:client:togOneComponent", localPlayer, toggleOneMapFixComponent, false)

local function unloadAllMapFixComponents()
    for name, _ in pairs(mapFixComponents) do
        toggleOneMapFixComponent(name, false)
    end
end
addEventHandler("onClientResourceStop", resourceRoot, unloadAllMapFixComponents, false)
