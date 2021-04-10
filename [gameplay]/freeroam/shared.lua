local buildType = localPlayer and "client" or "server"

if buildType == "client" then
    local subWindows = {}

    local localVariables = {
        windowName = "FR GUI",

        topTitle = "Local player",

        -- It doesn't matter much, when all is done the window is resized
        defaultWidth = 280,
        defaultHeight = 430,

        rowHeight = 25,
      
        render = {
            {"GuiLabel", text = "Local player"},
            {"br"},

            {"GuiButton", text = "Kill", height = 20},
            {"GuiButton", text = "Skin", height = 20},
            {"GuiButton", text = "Anim", height = 20},
            {"GuiButton", text = "Weapons", height = 20},
            {"GuiButton", text = "Clothes", height = 20},

            {"br"},
            
            {"GuiButton", text = "Grav", height = 20},
            {"GuiButton", text = "Warp", height = 20},
            {"GuiButton", text = "Stats", height = 20},
            {"GuiButton", text = "Bookmarks", height = 20},


            {"br"},
            {"GuiCheckBox", text = "Jetpack"},
            {"GuiCheckBox", text = "Fall of bike"},
            {"br"},
            {"GuiCheckBox", text = "Disable warp"},
            {"GuiCheckBox", text = "Disable knifing"},
            {"br"},
            {"GuiCheckBox", text = "Anti-ramming (vehicle ghostmode)"},
            {"br", height = 30},

            {"GuiLabel", text = "Pos: X Y Z", width = 170},
            {"GuiButton", text = "Map", height = 20},
            {"GuiButton", text = "Int", height = 20},

            {"br", height = 40},

            {"GuiLabel", text = "Vehicle (current name)"},
            {"br"},
            {"GuiButton", text = "Create", height = 20},
            {"GuiButton", text = "Repair", height = 20},
            {"GuiButton", text = "Flip", height = 20},
            {"GuiButton", text = "Upgrades", height = 20},
            {"br"},
            {"GuiButton", text = "Color", height = 20},
            {"GuiButton", text = "Paintjob", height = 20},

            {"br"},
            {"GuiCheckBox", text = "Lights"},

            {"br", height = 70},
            {"GuiLabel", text = "Environment"},
            {"br"},
            {"GuiButton", text = "Time", height = 20},
            {"GuiCheckBox", text = "Freeze"},
            {"GuiButton", text = "Weather", height = 20},
            {"GuiButton", text = "Speed", height = 20},
          
        }
    }
    
    function addWindow(data)
        return table.insert(subWindows, data)
    end

    function getSharedData()
        return localVariables
    end
end