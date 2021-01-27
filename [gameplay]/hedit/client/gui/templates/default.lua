template = {}

local yellow = colors.yellow

-- This handles the main window template
template.window = {
    type = "window",
    pos = { 0, 0 },
    size = { 374, 513 },
    centered = true,
    sizable = false,
    movable = true,
    
    {
        type = "gridlist",
        pos = { 65, 54 },
        size = { 300, 435 },
        runfunction = function ( this )
            guiMoveToBack ( this )
        end
    },
    {
        type = "line",
        pos = { 0, 32 },
        width = 365,
        alpha = 152
    },
    {
        type = "line",
        pos = { 66, 63 },
        width = 299,
        alpha = 76
    },
    {
        type = "line",
        pos = { 66, 378 },
        width = 299,
        alpha = 76
    },
    {
        type = "line",
        pos = { 66, 431 },
        width = 299,
        alpha = 76
    }
}

template.menubar = {
    hovercolor = colors.cyan,
    {
        title = "tools",
        "import",
        "reset"
    },
    {
        title = "extra",
        "options",
        "about"
    }
}

template.views = {
    hovercolor = yellow,
    { title = "engine", content = "handlingconfig" },
    { title = "body", content = "handlingconfig" },
    { title = "wheels", content = "handlingconfig" },
    { title = "modelflags", content = "handlingflags" },
    { title = "handlingflags", content = "handlingflags" },
    -- { title = "dynamometer", content = "submenu" },
    { title = "save", content = "submenu" },
    { contents = {} },
}

    
template.viewcontents = {
    --// MULTI USAGE
    redirect_handlingconfig = {
        redirect = "THIS_IS_ONE",
        content = {
            labels = {
                {
                    type = "label",
                    pos = { 72, 83 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 108 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 133 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 158 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 183 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 208 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 233 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 258 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 283 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 308 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 333 },
                    size = { 180, 20 },
                    hovercolor = yellow
                },
                {
                    type = "label",
                    pos = { 72, 358 },
                    size = { 180, 20 },
                    hovercolor = yellow
                }
            },
            buttons = { -- Do not need a type!
                {
                    pos = { 258, 83 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 108 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 133 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 158 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 183 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 208 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 233 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 258 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 283 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 308 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 333 },
                    size = { 100, 20 }
                },
                {
                    pos = { 258, 358 },
                    size = { 100, 20 }
                }
            }
        }
    },

    ------------------------------------------------------------------------------------------------

    redirect_handlingflags = {
        redirect = "THIS_IS_ONE",
        content = {
            checkboxes = {
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 77 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 92 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 77 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 92 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                },
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 107 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 122 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 107 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 122 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                },
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 137 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 152 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 137 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 152 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                },
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 167 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 182 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 167 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 182 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                },
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 197 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 212 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 197 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 212 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                },
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 227 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 242 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 227 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 242 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                },
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 257 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 272 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 257 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 272 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                },
                {
                    ["1"] = {
                        type = "checkbox",
                        pos = { 72, 287 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["2"] = {
                        type = "checkbox",
                        pos = { 72, 302 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["4"] = {
                        type = "checkbox",
                        pos = { 212, 287 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    },
                    ["8"] = {
                        type = "checkbox",
                        pos = { 212, 302 },
                        size = { 135, 15 },
                        hovercolor = yellow
                    }
                }
            },
            extras = {
            }
        }
    },
    
    ------------------------------------------------------------------------------------------------

    --// MENU BUTTONS
    engine = {
        requirelogin = false,
        requireadmin = false,
        redirect = "handlingconfig",
        content = {
            "numberOfGears",
            "maxVelocity",
            "engineAcceleration",
            "engineInertia",
            "driveType",
            "engineType",
            "steeringLock",
            "collisionDamageMultiplier"
        }
    },

    ------------------------------------------------------------------------------------------------

    body = {
        requirelogin = false,
        requireadmin = false,
        redirect = "handlingconfig",
        content = {
            "mass",
            "turnMass",
            "dragCoeff",
            "centerOfMass",
            "percentSubmerged",
            "animGroup",
            "seatOffsetDistance",
        }
    },

    ------------------------------------------------------------------------------------------------

    wheels = {
        requirelogin = false,
        requireadmin = false,
        redirect = "handlingconfig",
        content = {
            "tractionMultiplier",
            "tractionLoss",
            "tractionBias",
            "brakeDeceleration",
            "brakeBias",
            "suspensionForceLevel",
            "suspensionDamping",
            "suspensionHighSpeedDamping",
            "suspensionUpperLimit",
            "suspensionLowerLimit",
            "suspensionAntiDiveMultiplier",
            "suspensionFrontRearBias"
        }
    },

    ------------------------------------------------------------------------------------------------

    modelflags = {
        requirelogin = false,
        requireadmin = false,
        redirect = "handlingflags",
        content = {
            "modelFlags"
        }
    },

    ------------------------------------------------------------------------------------------------

    handlingflags = {
        requirelogin = false,
        requireadmin = false,
        redirect = "handlingflags",
        content = {
            "handlingFlags"
        }
    },

    ------------------------------------------------------------------------------------------------

    dynamometer = {
        requirelogin = false,
        requireadmin = false,
        disable = true,
        content = {
        }
    },

    ------------------------------------------------------------------------------------------------

    about = {
        requirelogin = false,
        requireadmin = false,
        --[[runfunction = function ( content )
            setElementParent ( content.textlabel, content.pane ) -- MEH
            guiSetSize ( content.textlabel, 290, 1000, false )
        end,]]
        content = {
            --[[pane = {
                type = "scrollpane",
                pos = { 73, 77 },
                size = { 290, 300 }
            },]]
            textlabel = {
                type = "label",
                pos = { 73, 77 },
                size = { 290, 200 },
                runfunction = function ( this )
                    guiLabelSetHorizontalAlign ( this, "left", true )
                    guiSetFont ( this, "default" )
                end
            },
            websitebox = {
                type = "editbox",
                pos = { 73, 220 },
                size = { 290, 30 },
                runfunction = function ( this )
                    this.enabled = false
                    this.readOnly = true
                end
            },
            morelabel = {
                type = "label",
                pos = { 73, 250 },
                size = { 290, 50 },
                runfunction = function ( this )
                    guiLabelSetHorizontalAlign ( this, "left", true )
                end
            }
        }
    },

    ------------------------------------------------------------------------------------------------
    
    --// UTILITY
    reset = {
        requirelogin = false,
        requireadmin = false,
        onOpen = function ( content )
            local vehicle = getPedOccupiedVehicle ( localPlayer )
            if vehicle then
                local name = getVehicleNameFromModel ( getElementModel ( vehicle ) )
                
                for i=0,212 do
                    local item = guiComboBoxGetItemText ( content.combo, i )
                    if item == name then
                        guiComboBoxSetSelected ( content.combo, i )
                        return true
                    end
                end
            end 
        end,
        content = {
            label = {
                type = "label",
                pos = { 72, 83 },
                size = { 180, 20 }
            },
            combo = {
                type = "combobox",
                pos = { 258, 83 },
                size = { 100, 4240 },
                runfunction = function ( this )
                    local vehNames = {}
                    for v=400,611 do
                        local name = getVehicleNameFromModel ( v )
                        
                        table.insert ( vehNames, name )
                    end
                    
                    table.sort ( vehNames )
                    
                    for i,v in ipairs ( vehNames ) do
                        guiComboBoxAddItem ( this, v )
                    end
                end
            },
            button = {
                type = "button",
                pos = { 72, 359 },
                size = { 285, 25 },
                events = {
                    onClick = function ( this )
                        local vehicle = getPedOccupiedVehicle ( localPlayer )
                        if vehicle then
                            local content = heditGUI.viewItems.reset.guiItems
                            local selected = guiComboBoxGetSelected ( content.combo )
                            local vehID = getVehicleModelFromName ( guiComboBoxGetItemText ( content.combo, selected ) )
                            
                            local function func ( )
                                resetVehicleHandling ( vehicle, vehID )
                            end
                            
                            guiCreateWarningMessage ( getText ( "confirmReset" ), 2, {func} )
                        end
                    end
                }
            }
        }
    },

    ------------------------------------------------------------------------------------------------

    save = {
        requirelogin = false,
        requireadmin = false,
        onOpen = function ( content ) 
            guiGridListClear ( content.grid )

            local saves = getClientSaves ( )
            for name,info in pairs ( saves ) do
                local row = guiGridListAddRow ( content.grid )
                local model = getVehicleNameFromModel ( tonumber ( info.model ) )
                guiGridListSetItemText ( content.grid, row, 1, info.name, false, false )
                guiGridListSetItemText ( content.grid, row, 2, model, false, false )
            end
            
            guiSetText ( content.nameEdit, "title" )
            guiSetText ( content.descriptionEdit, "description" )
            
            guiBringToFront ( content.nameLabel )
            guiBringToFront ( content.descriptionLabel )
        end,

        onClose = function ( content )
            guiResetStaticInfoText ( )
        end,

        content = {
            grid = {
                type = "gridlist",
                pos = { 72, 83 },
                size = { 285, 246 },
                runfunction = function ( this )
                    guiGridListAddColumn ( this, "Name",  0.5 )
                    guiGridListAddColumn ( this, "Model", 0.4 )
                end,
                events = {
                    onClick = function ( this )
                        local content = heditGUI.viewItems.save.guiItems
                        local row,col = guiGridListGetSelectedItem ( this )
                        if row > -1 and col > -1 then
                            local name = string.lower ( guiGridListGetItemText ( this, row, col ) )
                            local save = getClientSaves()[name]
                            guiSetStaticInfoText ( save.name, save.description )
                            guiSetVisible ( content.nameLabel, false )
                            guiSetVisible ( content.descriptionLabel, false )
                            guiSetText ( content.nameEdit, save.name )
                            guiSetText ( content.descriptionEdit, save.description )
                            return true
                        end
                        guiResetStaticInfoText()
                        guiSetVisible ( content.nameLabel, true )
                        guiSetVisible ( content.descriptionLabel, true )
                        guiBringToFront ( content.nameLabel )
                        guiBringToFront ( content.descriptionLabel )
                        guiSetText ( content.nameEdit, "" )
                        guiSetText ( content.descriptionEdit, "" )
                    end,

                    onDoubleClick = function ( this )
                        local row,col = guiGridListGetSelectedItem ( this )

                        if row ~= -1 and col ~= -1 then
                            local name = string.lower ( guiGridListGetItemText ( this, row, col ) )

                            local function func ( )
                                if loadClientHandling ( pVehicle, name ) then
                                    guiCreateWarningMessage ( getText ( "successLoad" ), 3)
                                end
                            end

                            if not isVehicleSaved ( pVehicle ) then
                                guiCreateWarningMessage ( getText ( "confirmLoad" ), 2, {func} )
                                return true
                            end

                            func ( )
                        end
                    end
                }
            },
            nameEdit = {
                type = "editbox",
                pos = { 72, 334 },
                size = { 212, 25 },
                events = {
                    onFocus = function ( this )
                        local content = heditGUI.viewItems.save.guiItems
                        guiSetVisible ( content.nameLabel, false )
                    end,
                    onBlur = function ( this )
                        if guiGetText ( this ) == "" then
                            local content = heditGUI.viewItems.save.guiItems
                            guiBringToFront ( content.nameLabel )
                            guiSetVisible ( content.nameLabel, true )
                        end
                    end
                }
            },
            descriptionEdit = {
                type = "editbox",
                pos = { 72, 359 },
                size = { 212, 25 },
                events = {
                    onFocus = function ( this )
                        local content = heditGUI.viewItems.save.guiItems
                        guiSetVisible ( content.descriptionLabel, false )
                    end,
                    onBlur = function ( this )
                        if guiGetText ( this ) == "" then
                            local content = heditGUI.viewItems.save.guiItems
                            guiBringToFront ( content.descriptionLabel )
                            guiSetVisible ( content.descriptionLabel, true )
                        end
                    end
                }
            },
            nameLabel = {
                type = "label",
                pos = { 80, 334 },
                size = { 50, 12 },
                runfunction = function ( this )
                    guiLabelSetColor ( this, 0, 0, 0 )
                    guiSetFont ( this, "default-small" )
                end,
                events = {
                    onClick = function ( this )
                        local content = heditGUI.viewItems.save.guiItems
                        
                        guiSetVisible ( this, false )
                        guiBringToFront ( content.nameEdit )
                        guiEditSetCaretIndex ( content.nameEdit, string.len ( guiGetText ( content.nameEdit ) ) )
                    end
                }
            },
            descriptionLabel = {
                type = "label",
                pos = { 80, 359 },
                size = { 50, 12 },
                runfunction = function ( this )
                    guiLabelSetColor ( this, 0, 0, 0 )
                    guiSetFont ( this, "default-small" )
                end,
                events = {
                    onClick = function ( this )
                        local content = heditGUI.viewItems.save.guiItems
                        
                        guiSetVisible ( this, false )
                        guiBringToFront ( content.descriptionEdit )
                        guiEditSetCaretIndex ( content.descriptionEdit, string.len ( guiGetText ( content.descriptionEdit ) ) )
                    end
                }
            },
            saveButton = {
                type = "button",
                pos = { 289, 334 },
                size = { 68, 25 },
                events = {
                    onClick = function ( this )
                        local content = heditGUI.viewItems.save.guiItems
                        local name = guiGetText ( content.nameEdit )
                        local description = guiGetText ( content.descriptionEdit )

                        if string.len ( name ) < 1 or string.len ( description ) < 1 then
                            guiCreateWarningMessage ( getText ( "invalidSave" ), 0 )
                            return false
                        end

                        local function func ( )
                            saveClientHandling ( pVehicle, name, description )
                            guiShowView ( previousMenu )
                            guiCreateWarningMessage ( getText ( "successSave" ), 3 )
                        end

                        if isClientHandlingExisting ( name ) then
                            guiCreateWarningMessage ( getText ( "confirmReplace" ), 2, {func} )
                            return false
                        end

                        func ( )
                    end
                }
            },

            loadButton = {
                type = "button",
                pos = { 289, 359 },
                size = { 68, 25 },
                events = {
                    onClick = function ( this )
                        local content = heditGUI.viewItems.save.guiItems
                        local row,col = guiGridListGetSelectedItem ( content.grid )

                        if row ~= -1 and col ~= -1 then
                            local name = string.lower ( guiGridListGetItemText ( content.grid, row, col ) )

                            local function func ( )
                                if loadClientHandling ( pVehicle, name ) then
                                    guiCreateWarningMessage ( getText ( "successLoad" ), 3 )
                                end
                            end

                            if not isVehicleSaved ( pVehicle ) then
                                guiCreateWarningMessage ( getText ( "confirmLoad" ), 2, {func} )
                                return true
                            end

                            func ( )
                        end
                    end
                }
            }
        }
    },

    ------------------------------------------------------------------------------------------------

    import = {
        requirelogin = false,
        requireadmin = false,

        content = {
            methods = {
                III = {
                    type = "checkbox",
                    pos = { 72, 83 },
                    size = { 34, 15 },
                    runfunction = function ( this )
                        guiSetEnabled ( this, false )
                    end,
                    events = {
                        onClick = function ( this )
                            for k,v in pairs ( heditGUI.viewItems.import.guiItems.methods ) do
                                guiCheckBoxSetSelected ( v, false )
                            end
                            guiCheckBoxSetSelected ( this, true )
                        end
                    }
                },
                VC = {
                    type = "checkbox",
                    pos = { 110, 83 },
                    size = { 34, 15 },
                    runfunction = function ( this )
                        guiSetEnabled ( this, false )
                    end,
                    events = {
                        onClick = function ( this )
                            for k,v in pairs ( heditGUI.viewItems.import.guiItems.methods ) do
                                guiCheckBoxSetSelected ( v, false )
                            end
                            guiCheckBoxSetSelected ( this, true )
                        end
                    }
                },
                SA = {
                    type = "checkbox",
                    pos = { 148, 83 },
                    size = { 34, 15 },
                    runfunction = function ( this )
                        guiSetEnabled ( this, false )
                    end,
                    events = {
                        onClick = function ( this )
                            for k,v in pairs ( heditGUI.viewItems.import.guiItems.methods ) do
                                guiCheckBoxSetSelected ( v, false )
                            end
                            guiCheckBoxSetSelected ( this, true )
                        end
                    },
                    runfunction = function ( this )
                        guiCheckBoxSetSelected ( this, true )
                    end
                },
                IV = {
                    type = "checkbox",
                    pos = { 186, 83 },
                    size = { 34, 15 },
                    runfunction = function ( this )
                        guiSetEnabled ( this, false )
                    end,
                    events = {
                        onClick = function ( this )
                            for k,v in pairs ( heditGUI.viewItems.import.guiItems.methods ) do
                                guiCheckBoxSetSelected ( v, false )
                            end
                            guiCheckBoxSetSelected ( this, true )
                        end
                    }
                }
            },

            memo = {
                type = "memo",
                pos = { 72, 103 },
                size = { 285, 251 }
            },

            importButton = {
                type = "button",
                pos = { 227, 78 },
                size = { 123, 25 },
                events = {
                    onClick = function ( this )
                        local vehicle = getPedOccupiedVehicle ( localPlayer )
                        if vehicle then
                            local items = heditGUI.viewItems.import.guiItems
                            local method = "SA"
                            for k,v in pairs ( items.methods ) do
                                if guiCheckBoxGetSelected ( v ) then
                                    method = k
                                end
                            end
                            
                            importHandling ( vehicle, guiGetText ( items.memo ), method )
                        end
                    end
                }
            },

            exportButton = {
                type = "button",
                pos = { 72, 359 },
                size = { 285, 25 },
                events = {
                    onClick = function ( this )
                        local vehicle = getPedOccupiedVehicle ( localPlayer )
                        if vehicle then
                            local items = heditGUI.viewItems.import.guiItems
                            guiSetText ( items.memo, exportHandling ( vehicle ) )
                            setClipboard ( exportHandling ( vehicle ) )
                            guiCreateWarningMessage ( getText ( "copiedToClipboard" ), 3 )
                        end
                    end
                }
            }
        }
    },

    ------------------------------------------------------------------------------------------------

    get = {
        requirelogin = false,
        requireadmin = false,
        disable = true,
        content = {
        }
    },

    ------------------------------------------------------------------------------------------------

    share = {
        requirelogin = false,
        requireadmin = false,
        disable = true,
        content = {
        }
    },

    ------------------------------------------------------------------------------------------------

    upload = {
        requirelogin = true,
        requireadmin = true,
        disable = true,
        content = {
        }
    },

    ------------------------------------------------------------------------------------------------

    download = {
        requirelogin = false,
        requireadmin = false,
        disable = true,
        content = {
        }
    },

    ------------------------------------------------------------------------------------------------

    resourcesave = {
        requirelogin = true,
        requireadmin = true,
        disable = true,
        content = {
        }
    },

    ------------------------------------------------------------------------------------------------

    resourceload = {
        requirelogin = true,
        requireadmin = true,
        disable = true,
        content = {
        }
    },

    ------------------------------------------------------------------------------------------------

    options = {
        requirelogin = false,
        requireadmin = false,
        content = {
            label_key = {
                type = "label",
                pos = { 72, 83 },
                size = { 180, 25 }
            },
            combo_key = {
                type = "combobox",
                pos = { 258, 83 },
                size = { 100, 25 },
                runfunction = function ( this )
                    for i=1,#validKeys do
                        guiComboBoxAddItem ( this, validKeys[i] )
                        guicache.optionmenu_item[ string.lower( validKeys[i] ) ] = i-1
                    end
                    guiSetSize ( this, 100, ( 20 * #validKeys ) + 25, false )
                end
            },
            label_cmd = {
                type = "label",
                pos = { 72, 113 },
                size = { 180, 25 }
            },
            edit_cmd = {
                type = "editbox",
                pos = { 258, 113 },
                size = { 100, 25 }
            },
            label_language = {
                type = "label",
                pos = { 72, 144 },
                size = { 180, 25 }
            },
            combo_language = {
                type = "combobox",
                pos = { 258, 144 },
                size = { 100, 25 },
                runfunction = function ( this )
                    local item = 0
                    for name in pairs ( guiLanguage ) do
                        guiComboBoxAddItem ( this, name )
                        guicache.optionmenu_item[name] = item
                        item = item + 1
                    end
                    local size = table.size ( guiLanguage )
                    size = size == 1 and 52 or ( 21 * size ) + 25
                    guiSetSize ( this, 100, size, false )
                end
            },
            checkbox_lockwhenediting = {
                type = "checkbox",
                pos = {72, 175},
                size = { 285, 25},
                runfunction = function(this)
                    guiCheckBoxSetSelected(this, tobool(getUserConfig("lockVehicleWhenEditing")))
                end
            },
            checkbox_dragmeterEnabled = {
                type = "checkbox",
                pos = {72, 196},
                size = { 285, 25},
                runfunction = function(this)
                    guiCheckBoxSetSelected(this, tobool(getUserConfig("dragmeterEnabled")))
                end
            },
            button_save = {
                type = "button",
                pos = { 72, 359 },
                size = { 285, 25 },
                events = {
                    onClick = function ( this )
                        local item = heditGUI.viewItems.options.guiItems

                        local function confirm ( )

                            local function apply ( bool )

                                unbindKey ( getUserConfig ( "usedKey" ), "down", toggleEditor )
                                removeCommandHandler ( getUserConfig ( "usedCommand", toggleEditor ) )
                            
                                setUserConfig ( "usedKey", guiComboBoxGetItemText ( item.combo_key, guiComboBoxGetSelected ( item.combo_key ) ) )
                                setUserConfig ( "usedCommand", guiGetText ( item.edit_cmd ) )
                                -- setUserConfig ( "template", guiComboBoxGetItemText ( item.combo_template, guiComboBoxGetSelected ( item.combo_template ) ) )
                                setUserConfig ( "language", guiComboBoxGetItemText ( item.combo_language, guiComboBoxGetSelected ( item.combo_language ) ) )
								setUserConfig("lockVehicleWhenEditing", guiCheckBoxGetSelected(item.checkbox_lockwhenediting))
                                setUserConfig("dragmeterEnabled", guiCheckBoxGetSelected(item.checkbox_dragmeterEnabled))

                                if bool then
                                    setUserConfig ( "version", tostring ( HREV ) )
                                    setUserConfig ( "minVersion", tostring ( HMREV ) )
                                end
                            
                                startBuilding ( )
                            
                                toggleEditor ( )

                            end
								
                            -- if guiCheckBoxGetSelected ( item.checkbox_versionreset ) then
                            --     guiCreateWarningMessage ( getText ( "confirmVersionReset" ), 2, {apply, true}, {apply,false} )
                            --     return true
                            -- end
                            
                            apply ( false )

                            return true
                        end

                        guiCreateWarningMessage ( getText ( "wantTheSettings" ), 2, {confirm} )
                    end
                }
            }
        },
        onOpen = function ( content )
            guiSetText ( content.edit_cmd, getUserConfig ( "usedCommand" ) )
            guiComboBoxSetSelected ( content.combo_key, guicache.optionmenu_item[ string.lower ( getUserConfig ( "usedKey" ) ) ] )
            guiComboBoxSetSelected ( content.combo_language, guicache.optionmenu_item[ getUserConfig ( "language" ) ] )
        end
    },

    ------------------------------------------------------------------------------------------------

    handlinglog = {
        requirelogin = false,
        requireadmin = false,
        disable = true,
        content = {
            logpane = {
                type = "scrollpane",
                pos = { 73, 77 },
                size = { 290, 300 }
            }
        }
    },
}


template.specials = {
    menuheader = {
        type = "label",
        pos = { 72, 58 },
        size = { 299, 15 },
        runfunction = function ( this )
            guiSetFont ( this, "default-bold-small" )
        end
    },
    infobox = {
        header = {
            type = "label",
            pos = { 72, 393 },
            size = { 285, 16 }
        },
        text = {
            type = "label",
            pos = { 72, 409 },
            size = { 285, 30 },
            runfunction = function ( this )
                guiSetFont ( this, "default-small" )
                guiLabelSetHorizontalAlign ( this, "left", true )
            end
        }
    },
    minilog = {
        {
            timestamp = {
                type = "label",
                pos = { 72, 446 },
                size = { 45, 13 },
                runfunction = function ( this )
                    guiSetFont ( this, "default-small" )
                end
            },
            text = {
                type = "label",
                pos = { 117, 446 },
                size = { 230, 13 },
                runfunction = function ( this )
                    guiSetFont ( this, "default-small" )
                end
            }
        },
        {
            timestamp = {
                type = "label",
                pos = { 72, 459 },
                size = { 45, 13 },
                runfunction = function ( this )
                    guiSetFont ( this, "default-small" )
                end
            },
            text = {
                type = "label",
                pos = { 117, 459 },
                size = { 230, 13 },
                runfunction = function ( this )
                    guiSetFont ( this, "default-small" )
                end
            }
        },
        {
            timestamp = {
                type = "label",
                pos = { 72, 472 },
                size = { 45, 13 },
                runfunction = function ( this )
                    guiSetFont ( this, "default-small" )
                end
            },
            text = {
                type = "label",
                pos = { 117, 472 },
                size = { 230, 13 },
                runfunction = function ( this )
                    guiSetFont ( this, "default-small" )
                end
            }
        }
    },
    vehicleinfo = {
        type = "label",
        pos = { 10, 493 },
        size = { 354, 12 },
        runfunction = function ( this )
            guiSetFont ( this, "default-small" )
        end
    }
}
