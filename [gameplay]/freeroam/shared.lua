local buildType = localPlayer and "client" or "server"

if buildType == "client" then
    local localVariables = {
        windowName = "FR GUI",

        topTitle = "Local player",

        -- It doesn't matter much, when all is done the window is resized
        defaultWidth = 280,
        defaultHeight = 400,

        rowHeight = 25,
      
        render = {
            {"GuiLabel", text = "Local player"},
            {"br"},

            {"GuiButton", text = "Kill", height = 20, click = killYourself},
            {"GuiButton", text = "Skin", height = 20, click = function() showPopUp("skin") end},
            {"GuiButton", text = "Anim", height = 20, click = function() showPopUp("anim") end},
            {"GuiButton", text = "Weapons", height = 20, click = function() showPopUp("weapons") end},
            {"GuiButton", text = "Clothes", height = 20, click = function() showPopUp("clothes") end},

            {"br"},
            
            {"GuiButton", text = "Grav", height = 20},
            {"GuiButton", text = "Warp", height = 20},
            {"GuiButton", text = "Stats", height = 20},
            {"GuiButton", text = "Bookmarks", height = 20},


            {"br"},
            {"GuiCheckBox", text = "Jetpack", click = toggleJetPack},
            {"GuiCheckBox", text = "Fall of bike"},
            {"br"},
            {"GuiCheckBox", text = "Disable warp"},
            {"GuiCheckBox", text = "Disable knifing"},
            {"br"},
            {"GuiCheckBox", text = "Anti-ramming (vehicle ghostmode)"},
            {"br", height = 30},

            {"GuiLabel", text = "Pos: %s %s %s", width = 170},
            {"GuiButton", text = "Map", height = 20},
            {"GuiButton", text = "Int", height = 20},

            {"br", height = 40},

            {"GuiLabel", text = "Vehicle (None)", id = "vehicle-text", width = 170},
            {"br"},
            {"GuiButton", text = "Create", height = 20},
            {"GuiButton", text = "Repair", height = 20, parent = "vehicle"},
            {"GuiButton", text = "Flip", height = 20, parent = "vehicle"},
            {"GuiButton", text = "Upgrades", height = 20, parent = "vehicle"},
            {"br"},
            {"GuiButton", text = "Color", height = 20, parent = "vehicle"},
            {"GuiButton", text = "Paintjob", height = 20, parent = "vehicle"},

            {"br"},
            {"GuiCheckBox", text = "Lights", parent = "vehicle"},

            {"br", height = 50},
            {"GuiLabel", text = "Environment"},
            {"br"},
            {"GuiButton", text = "Time", height = 20},
            {"GuiCheckBox", text = "Freeze", height = 20},
            {"GuiButton", text = "Weather", height = 20},
            {"GuiButton", text = "Speed", height = 20},  
        }
    }
    
    function getSharedData()
        return localVariables
    end
end