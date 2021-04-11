local screenX, screenY = guiGetScreenSize()

local _G = _G
local dataConfigs = {}
local dataConfigList = {"animations", "interiors", "skins", "stats", "vehicles", "weapons", "weather"}

local subWindows = {}

local guiElements = {}
local guiParents = {}

local guiPanel
local subWindow

local function xml2table(data)
    local tbl = {}
    for index, node in ipairs(data) do
        local nodeName = node:getName()
        local attributes = node:getAttributes()

        if not tbl[nodeName] then
            tbl[nodeName] = {}
        end

        for name, value in pairs(attributes) do
            tbl[nodeName][name] = value
        end
    end
    return tbl
end

local function importData()
    for index, value in ipairs(dataConfigList) do
        if value then
            local xml = XML.load("data/"..value..".xml")
            if xml then
                dataConfigs[value] = xml2table(xml:getChildren())
                xml:unload()
            end
        end
    end
end

local function updateGUI()
    local vehicle = localPlayer:getOccupiedVehicle()

    for index, element in ipairs(guiParents.vehicle) do
        element:setVisible(vehicle and true or false)
    end
end

local function buildWindow()
    local data = getSharedData()
    guiPanel = GuiWindow(10, 0, data.defaultWidth, data.defaultHeight, data.windowName, false)
    guiPanel:setSizable(false)
    
    local rowHeight = data.rowHeight
    local startX, startY = 10, 25
    for index, data in ipairs(data.render) do
        local func = data[1]

        local x, y, w, h = data.x or startX, data.y or startY, data.width or dxGetTextWidth(data.text or "") + 17, data.height or rowHeight

        if func ~= "br" then
            local element
            if func == "GuiCheckBox" then
                w = w + 10
                element = _G[func](x, y, w, h, data.text, false, false, guiPanel)
            else
                element = _G[func](x, y, w, h, data.text, false, guiPanel)
            end

            if data.parent then
                if not guiParents[data.parent] then
                    guiParents[data.parent] = {}
                end
                table.insert(guiParents[data.parent], element)
            end

            if data.id then
                guiElements[data.id] = element
            end

            if data.click then
                addEventHandler("onClientGUIClick", element, data.click)
            end
            startX = startX + ( w + 5 )
        else
            startY = startY + h
            startX = 10
        end
    end

    updateGUI()
    guiPanel:setPosition(10, screenY / 2 - data.defaultHeight / 2, false)
end

local function buildSubWindow(page)
    local data = subWindows[page]
    if data then
        if not data.element then
            subWindows[page].element = GuiWindow(data.x, data.y, data.defaultWidth, data.defaultHeight, data.topTitle, false)
            subWindows[page].element:setSizable(false)

            local rowHeight = data.rowHeight
            local startX, startY = 10, 25
            for index, data in ipairs(data.render) do
                local func = data[1]
        
                local x, y, w, h = data.x or startX, data.y or startY, data.width or dxGetTextWidth(data.text or "") + 17, data.height or rowHeight
        
                if func ~= "br" then
                    local element
                    if func == "GuiCheckBox" then
                        w = w + 10
                        element = _G[func](x, y, w, h, data.text, false, false, subWindows[page].element)
                    elseif func == "GuiGridList" then
                        element = _G[func](x, y, w, h, false, subWindows[page].element)
                    else
                        element = _G[func](x, y, w, h, data.text, false, subWindows[page].element)
                    end
                    
                    if data.click then
                        addEventHandler("onClientGUIClick", element, data.click)
                    end

                    startX = startX + ( w + 5 )
                else
                    startY = startY + h
                    startX = 10
                end
            end
        end
    end
    return true
end

local function isPanelVisible()
    return guiPanel:getVisible()
end

function showPopUp(page)
    if subWindows[page] then

    end
    return true
end

function addWindow(name, data)
    subWindows[name] = data
    buildSubWindow(name)
    return true
end

addEventHandler("onClientVehicleEnter", root, -- localPlayer don't work here
    function(player, seat)
        if player == localPlayer and isPanelVisible() then
            for index, element in ipairs(guiParents.vehicle) do
                element:setVisible(true)
            end

            local vehicleText = guiElements["vehicle-text"]
            vehicleText:setText(vehicleText:getText():gsub("None", localPlayer:getOccupiedVehicle():getName()))
        end
    end
)

addEventHandler("onClientVehicleExit", root, -- localPlayer don't work here
    function(player, seat)
        if player == localPlayer and isPanelVisible() then
            for index, element in ipairs(guiParents.vehicle) do
                element:setVisible(false)
            end

            local vehicleText = guiElements["vehicle-text"]
            vehicleText:setText(vehicleText:getText():gsub(localPlayer:getOccupiedVehicle():getName(), "None"))
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        buildWindow()
        importData()
    end
)