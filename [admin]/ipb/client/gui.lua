
GUI = {}

local screenWidth, screenHeight = guiGetScreenSize()

local comboCategories = {
    server = {"Server info", "Lua timing", "Lua time recordings", "Lua memory", "Packet usage", "Sqlite timing", "Bandwidth reduction", "Bandwidth usage", "Server timing", "Function stats", "Debug info", "Debug table", "Lib memory", "Help"},
    client = {"Lua timing", "Lua time recordings", "Lua memory", "Lib memory", "Packet usage", "Help"},
}

function GUI:exists()
    return self.window and true
end

function GUI:create()
    if self.window then
        return
    end

    local width = math.min((screenWidth - 40), 1280)
    local height = math.min((screenHeight - 40), 720)
    local panelWidth = 170
    local contentWidth = width - panelWidth
    self.window = GuiWindow((screenWidth - width) / 2, (screenHeight - height) / 2, width, height, "Ingame Performance Browser", false)
    self.window:setAlpha(1.0)
    self.window:setSizable(false)
    self.window:setVisible(false)

    local targetLabel = GuiLabel(10, 30, panelWidth - 20, 15, "Target:", false, self.window)
    targetLabel:setFont("default-bold-small")
    targetLabel:setHorizontalAlign("center")

    self.target = GuiComboBox(10, 50, panelWidth - 20, 200, "", false, self.window)
    self.target:addItem("Client")
    self.target:addItem("Server")
    self.target:setSelected(0) --> Client
    self.target:autoHeight()
    self.targetItem = self.target:getItemText(self.target:getSelected())

    addEventHandler("onClientGUIComboBoxAccepted", self.target, function (...) self:onTargetUpdate(...) end, false)

    local categoryLabel = GuiLabel(10, 80, panelWidth - 20, 15, "Category:", false, self.window)
    categoryLabel:setFont("default-bold-small")
    categoryLabel:setHorizontalAlign("center")

    self.category = GuiComboBox(10, 100, panelWidth - 20, 200, "", false, self.window)

    for index, categoryName in ipairs(comboCategories.client) do
        self.category:addItem(categoryName)
    end

    -- We assume we will always have a single item in the combobox
    self.category:setSelected(0)
    self.category:autoHeight()
    self.categoryItem = self.category:getItemText(self.category:getSelected())

    addEventHandler("onClientGUIComboBoxAccepted", self.category, function (...) self:onCategoryUpdate(...) end, false)

    local optionsLabel = GuiLabel(10, 130, panelWidth - 20, 15, "Options:", false, self.window)
    optionsLabel:setFont("default-bold-small")
    optionsLabel:setHorizontalAlign("center")

    self.options = GuiEdit(10, 150, panelWidth - 20, 22, "", false, self.window)
    self.updateOptions = function () self:applyOptionsUpdate() end
    addEventHandler("onClientGUIChanged", self.options, function (...) self:onOptionsUpdate(...) end, false)

    local filterLabel = GuiLabel(10, 180, panelWidth - 20, 15, "Filter:", false, self.window)
    filterLabel:setFont("default-bold-small")
    filterLabel:setHorizontalAlign("center")

    self.filter = GuiEdit(10, 200, panelWidth - 20, 22, "", false, self.window)
    self.updateFilter = function () self:applyFilterUpdate() end
    addEventHandler("onClientGUIChanged", self.filter, function (...) self:onFilterUpdate(...) end, false)

    local closeButton = GuiButton(10, height - 30, panelWidth - 20, 20, "Close", false, self.window)
    addEventHandler("onClientGUIClick", closeButton, function (...) self:onCloseClick(...) end, false)

    self.statistics = GuiGridList(panelWidth, 30, contentWidth, height - 40, false, self.window)
    self.statistics:setSelectionMode(0)
    self.statistics:setSortingEnabled(false)

    self:updateStatistics(STATS_MODE_NEW_LISTENER)
end

function GUI:destroy()
    if not self.window then
        return
    end

    self.window:destroy()

    for key, value in pairs(self) do
        if type(value) ~= "function" then
            if isElement(value) or isTimer(value) then
                value:destroy()
            end

            self[key] = nil
        end
    end
end

function GUI:setVisible(visible)
    if not self.window then
        return
    end

    visible = visible and true
    self.window:setVisible(visible)
    showCursor(visible)

    if self.targetItem == "Server" then
        if self.optionsTimer and isTimer(self.optionsTimer) then
            self.optionsTimer:destroy()
        end

        if self.filterTimer and isTimer(self.filterTimer) then
            self.filterTimer:destroy()
        end

        self.optionsTimer = nil
        self.filterTimer = nil

        triggerServerEvent("ipb.toggle", localPlayer, visible, self.categoryItem)
    else
        if visible then
            if not self.updateTimer then
                self.updateTimer = Timer(function () self:updateStatistics(STATS_MODE_REFRESH) end, UPDATE_FREQUENCY, 0)
            end
        else
            if self.updateTimer and isTimer(self.updateTimer) then
                self.updateTimer:destroy()
            end

            self.updateTimer = nil
        end
    end

    if visible then
        if self.autoDestroyTimer and isTimer(self.autoDestroyTimer) then
            self.autoDestroyTimer:destroy()
        end

        self.autoDestroyTimer = nil
    else
        if not self.autoDestroyTimer then
            self.autoDestroyTimer = Timer(function () self:destroy() end, 60000, 1)
        end
    end
end

function GUI:onTargetUpdate()
    local itemID = self.target:getSelected()

    if not itemID or itemID == -1 then
        self.target:setSelected(0)
        self.targetItem = self.target:getItemText(self.target:getSelected())
        return
    end

    local text = self.target:getItemText(itemID)
    local supported = comboCategories[text:lower()]

    if self.targetItem == text or not supported then
        return
    end

    self.options:setText("")
    self.filter:setText("")

    if self.optionsTimer and isTimer(self.optionsTimer) then
        self.optionsTimer:destroy()
    end

    if self.filterTimer and isTimer(self.filterTimer) then
        self.filterTimer:destroy()
    end

    self.targetItem = text

    self.category:clear()

    for index, categoryName in ipairs(supported) do
        self.category:addItem(categoryName)
    end

    self.category:setSelected(0)
    self.category:autoHeight()
    self.categoryItem = self.category:getItemText(self.category:getSelected())

    self.statistics:wipe()

    triggerServerEvent("ipb.toggle", localPlayer, text == "Server", false)

    if text == "Client" then
        if not self.updateTimer then
            self.updateTimer = Timer(function () self:updateStatistics(STATS_MODE_REFRESH) end, UPDATE_FREQUENCY, 0)
        end

        self:updateStatistics(STATS_MODE_NEW_LISTENER)
    else
        if self.updateTimer and isTimer(self.updateTimer) then
            self.updateTimer:destroy()
        end

        self.updateTimer = nil
    end
end

function GUI:onCategoryUpdate()
    local itemID = self.category:getSelected()

    if not itemID or itemID == -1 then
        self.category:setSelected(0)
        self.categoryItem = self.category:getItemText(self.category:getSelected())
        return
    end

    local text = self.category:getItemText(itemID)

    if self.categoryItem == text then
        return
    end

    self.categoryItem = text
    self.options:setText("")
    self.filter:setText("")

    if self.targetItem == "Server" then
        triggerServerEvent("ipb.updateCategory", localPlayer, text)
    else
        return self:updateStatistics(STATS_MODE_CATEGORY_CHANGE)
    end
end

function GUI:onOptionsUpdate()
    if self.targetItem ~= "Server" then
        return self:updateStatistics(STATS_MODE_OPTIONS_CHANGE)
    end

    if self.optionsTimer and isTimer(self.optionsTimer) then
        self.optionsTimer:destroy()
    end

    self.optionsTimer = Timer(self.updateOptions, 1000, 1)
end

function GUI:applyOptionsUpdate()
    self.optionsTimer = nil
    triggerServerEvent("ipb.updateOptions", localPlayer, self.options:getText())
end

function GUI:onFilterUpdate()
    if self.targetItem ~= "Server" then
        return self:updateStatistics(STATS_MODE_FILTER_CHANGE)
    end

    if self.filterTimer and isTimer(self.filterTimer) then
        self.filterTimer:destroy()
    end

    self.filterTimer = Timer(self.updateFilter, 1000, 1)
end

function GUI:applyFilterUpdate()
    self.filterTimer = nil
    triggerServerEvent("ipb.updateFilter", localPlayer, self.filter:getText())
end

function GUI:onCloseClick()
    GUI:setVisible(false)
end

function GUI:updateStatistics(mode)
    if self.targetItem ~= "Client" then
        return
    end

    self:fill(mode, getPerformanceStats(self.categoryItem, self.options:getText(), self.options:getText()))
end

function GUI:fill(mode, columns, rows)
    if not self.window then
        return
    end

    if mode == STATS_MODE_NEW_LISTENER or mode == STATS_MODE_CATEGORY_CHANGE or mode == STATS_MODE_OPTIONS_CHANGE or mode == STATS_MODE_FILTER_CHANGE then
        self.statistics:wipe()

        for index, columnName in pairs(columns) do
            self.statistics:addColumn(columnName, 0.2)
        end
    end

    if mode == STATS_MODE_REFRESH or mode == STATS_MODE_OPTIONS_CHANGE or mode == STATS_MODE_FILTER_CHANGE then
        local availableRows = self.statistics:getRowCount()
        local requiredRows = #rows

        if availableRows > requiredRows then
            for index = availableRows, requiredRows, -1 do
                self.statistics:removeRow(index)
            end
        elseif availableRows < requiredRows then
            for index = availableRows, requiredRows - 1, 1 do
                self.statistics:addRow()
            end
        end
    end

    for i, row in pairs(rows) do
        for j, value in pairs(row) do
            self.statistics:setItemText(i - 1, j, tostring(value), false, false)
        end
    end

    self.statistics:resizeColumns()
end

function GuiComboBox:autoHeight()
    -- Add a pseudo item to figure out the amount of items
    local itemID = self:addItem("")
    self:removeItem(itemID)

    local width = self:getSize(false)
    return self:setSize(width, itemID * 14 + 40, false)
end

function GuiGridList:wipe()
    self:clear()
    self:clearColumns()
end

function GuiGridList:clearColumns()
    for column = self:getColumnCount(), 0, -1 do
        self:removeColumn(column)
    end
end

function GuiGridList:resizeColumns()
    -- Create a pseudo label to figure out the width of each item
    local label = GuiLabel(0, 0, 0, 0, "", false, nil)

    local rowCount = self:getRowCount()
    local columCount = self:getColumnCount()

    for column = 1, columCount do
        label:setText(self:getColumnTitle(column) or "")
        label:setFont("default-small")
        local width = label:getTextExtent() + 20

        label:setFont("default-normal")

        for row = 0, rowCount - 1 do
            label:setText(self:getItemText(row, column) or "")
            local itemWidth = label:getTextExtent() + 20
            width = math.max(width, itemWidth)
        end

        self:setColumnWidth(column, width, false)
    end

    label:destroy()
end
