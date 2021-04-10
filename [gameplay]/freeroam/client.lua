local screenX, screenY = guiGetScreenSize()

local dataConfigs = {}
local dataConfigList = {"animations", "interiors", "skins", "stats", "vehicles", "weapons", "weather"}

local guiPanel

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
        local xml = XML.load("data/%s.xml"):format(value)

        dataConfigs[value] = xml2table(xml:getChildren())

        xml:close()
    end
end

local function buildWindow()
    local data = getSharedData()
    guiPanel = GuiWindow(10, 0, data.defaultWidth, data.defaultHeight, data.windowName, false)
    
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

            if data.click then
                addEventHandler("onClientGUIClick", element, data.click)
            end
            startX = startX + ( w + 5 )
        else
            startY = startY + h
            startX = 10
        end
    end

    guiPanel:setPosition(10, screenY / 2 - data.defaultHeight / 2, false)
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        buildWindow()
    end
)