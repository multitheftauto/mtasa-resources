guiLanguage.english = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Handling Editor v"..HVER,
    
    restrictedPassenger = "You are not allowed to use the handling editor as a passenger.",
    needVehicle = "You must be driving a vehicle to use the handling editor!",
    needLogin = "You must be logged in in order to view this menu.",
    needAdmin = "You must be logged in as an administrator to access this menu.",
    accessDenied = "You do not have the required permissions to access this menu.",
    invalidView = "This menu does not exist!",
    disabledView = "This menu has been disabled.",
 
    sameValue = "The %s is already that!",
    exceedLimits = "Value used at %s exceeds the limit. [%s]!",
    cantSameValue = "%s may not the same as %s!",
    needNumber = "You must use a number!",
    unsupportedProperty = "%s is not a supported property.",
    successRegular = "%s set to %s.",
    successHex = "%s %s.",
    unableToChange = "Unable to set the %s to %s!",
	disabledProperty = "Editing %s is disabled on this server!",
    
    resetted = "Successfully reset the vehicle's handling settings!",
    loaded = "Successfully loaded your handling settings!",
    imported = "Successfully imported the handling settings!",
    invalidImport = "Import failed. The handling data you provided is invalid!",
    invalidSave = "Please provide a valid name and description to save this vehicle's handling data!",
    
    confirmReplace = "Are you sure you would like to overwrite the existing save?",
    confirmLoad = "Are you sure you would like to load these handling settings? Any unsaved changes will be lost!",
    confirmDelete = "Are you sure you would like to delete these handling settings?",
    confirmReset = "Are you sure you would like to reset your handling? Any unsaved changes will be lost!",
    confirmImport = "Are you sure you would like to import this handling? Any unsaved changes will be lost!",

    successSave = "Successfully saved your handling settings!",
    successLoad = "Successfully loaded your handling settings!",

    wantTheSettings = "Are you sure you would like to apply these settings? The handling editor will restart.",
    
    vehicle = "Vehicle",
    unsaved = "Unsaved",
    
    clickToEdit = "Click to edit or drag to quick-tune.",
    enterToSubmit = "Press enter to confirm.",
    clickToViewFullLog = "Click to view the complete vehicle log.",
    copiedToClipboard = "The handling settings have been copied to the clipboard!",
    
    special = {
    },
    
    --
    -- BUTTON / MENU STRINGS
    --
    
    --Warning level strings
    warningtitles = {
        info = "Information",
        question = "Question",
        warning = "Warning!",
        error = "Error!"
    },
    --Strings for the buttons at the top
    menubar = {
        handling = "Handling",
        tools = "Tools",
        extra = "Extra",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "Engine",
        body = "Body",
        wheels = "Wheels",
        appearance = "Look",
        modelflags = "Model\nFlags",
        handlingflags = "Handling\nFlags",
        dynamometer = "Dyno",
        undo = "<",
        redo = ">",
        save = "Saves"
    },
    
    -- Strings for the various views of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "Engine",
            longname = "Engine Settings"
        },
        body = {
            shortname = "Body",
            longname = "Body Settings"
        },
        wheels = {
            shortname = "Wheels",
            longname = "Wheel Settings"
        },
        appearance = {
            shortname = "Appearance",
            longname = "Appearance Settings"
        },
        modelflags = {
            shortname = "Model Flags",
            longname = "Vehicle Model Settings"
        },
        handlingflags = {
            shortname = "Handling Flags",
            longname = "Special Handling Settings"
        },
        dynamometer = {
            shortname = "Dyno",
            longname = "Start Dynamometer"
        },
        about = {
            shortname = "About",
            longname = "About the official handling editor",
            itemtext = {
                textlabel = "Welcome to the official MTA handling editor! This resource allows you to edit the handling of any vehicle in-game in real time.\n\n"..
                            "You can save and load custom handlings you make through the 'Handling' menu in the top left corner.\n\n"..
                            "For more information about the handling editor - such as the official changelog - visit:",
                websitebox = "http://github.com/hedit/hedit",
                morelabel = "\nThank you for choosing hedit!"
            }
        },
        undo = {
            shortname = "Undo",
            longname = "Undo",
            itemtext = {
                textlabel = "Something went wrong."
            }
        },
        redo = {
            shortname = "Redo",
            longname = "Redo",
            itemtext = {
                textlabel = "Something went wrong."
            }
        },
        reset = {
            shortname = "Reset",
            longname = "Reset the handling settings of this vehicle.",
            itemtext = {
                label = "Base Vehicle:",
                combo = "-----",
                button = "Reset"
            }
        },
        save = {
            shortname = "Saves",
            longname = "Load or save handling settings.",
            itemtext = {
                nameLabel = "Name",
                descriptionLabel = "Description",
                saveButton = "Save",
                loadButton = "Load",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "handling.cfg",
            longname = "Import or Export to/from handling.cfg format.",
            itemtext = {
                importButton = "Import",
                exportButton = "Export and copy to clipboard",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "Get",
            longname = "Get handling settings from another player."
        },
        share = {
            shortname = "Share",
            longname = "Share your handling settings with another player."
        },
        upload = {
            shortname = "Upload",
            longname = "Upload your handling settings to the server."
        },
        download = {
            shortname = "Download",
            longname = "Download a set of handling settings from the server."
        },
        
        resourcesave = {
            shortname = "Resource save",
            longname = "Save your handling to a resource."
        },
        resourceload = {
            shortname = "Resource load",
            longname = "Load a handling from a resource."
        },
        options = {
            shortname = "Options",
            longname = "Options",
            itemtext = {
                label_key = "Toggle Key",
                label_cmd = "Toggle Command:",
                label_template = "GUI template:",
                label_language = "Language:",
                label_commode = "Center Of Mass edit mode:",
                checkbox_versionreset = "Downgrade my version number from %s to %s?",
                button_save = "Apply",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
                checkbox_lockwhenediting = "Lock vehicle when editing?",
                checkbox_dragmeterEnabled = "Use quick-tune"
            }
        },
        handlinglog = {
            shortname = "Handling Log",
            longname = "Log of recent changes to handling settings.",
            itemtext = {
                logpane = ""
            }
        },
    },
    

    handlingPropertyInformation = { 
        ["identifier"] = {
            friendlyName = "Vehicle Identifier",
            information = "This represents the vehicle identifier to be used in handling.cfg.",
            syntax = { "String", "Only use valid identifiers, otherwise exporting wont work." }
        },
        ["mass"] = {
            friendlyName = "Mass",
            information = "Changes the weight of your vehicle. (kilograms)",
            syntax = { "Float", "Remember to change 'turnMass' first to avoid bouncing!" }
        },
        ["turnMass"] = {
            friendlyName = "Turn Mass",
            information = "Used to calculate motion effects.",
            syntax = { "Float", "Large values will make your vehicle appear 'floaty'." }
        },
        ["dragCoeff"] = {
            friendlyName = "Drag Multiplier",
            information = "Changes resistance to movement.",
            syntax = { "Float", "The greater the value, the lower the top speed." }
        },
        ["centerOfMass"] = {
            friendlyName = "Center of Mass",
            information = "Changes the gravity point of your vehicle. (metres)",
            syntax = { "Float", "Hover onto individual coordinates for information." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Center of Mass X",
            information = "Assigns the front-rear distance of the center of mass. (metres)",
            syntax = { "Float", "High values are to the front and low values are to the back." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Center of Mass Y",
            information = "Assigns the left-right distance of the center of mass. (metres)",
            syntax = { "Float", "High values are to the right and low values are to the left." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Center of Mass Z",
            information = "Assigns the height of the center of mass. (metres)",
            syntax = { "Float", "The greater the value, the higher the position of the point." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Percent Submerged",
            information = "Changes how deep your vehicle needs to be submerged in water before it will begin to float. (percent)",
            syntax = { "Integer", "Greater values will make your vehicle begin to float at a deeper level." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Traction Multiplier",
            information = "Changes the amount of grip your vehicle will have to the ground whilst cornering.",
            syntax = { "Float", "Greater values will increase the grip between the wheels and the surface." }
        },
        ["tractionLoss"] = {
            friendlyName = "Traction Loss",
            information = "Changes the amount of grip your vehicle will have whilst accelerating and decelerating.",
            syntax = { "Float", "Greater values will make your vehicle cut corners better." }
        },
        ["tractionBias"] = {
            friendlyName = "Traction Bias",
            information = "Changes where all the grip of your wheels will be assigned to.",
            syntax = { "Float", "Greater values will move the bias towards the front of your vehicle." }
        },
        ["numberOfGears"] = {
            friendlyName = "Number of Gears",
            information = "Changes the maximum number of gears your vehicle can have.",
            syntax = { "Integer", "Doesn't affect the top speed or acceleration of your vehicle." }
        },
        ["maxVelocity"] = {
            friendlyName = "Maximum Velocity",
            information = "Changes the maximum speed of your vehicle. (km/h)",
            syntax = { "Float", "This value is affected by other properties." }
        },
        ["engineAcceleration"] = {
            friendlyName = "Acceleration",
            information = "Changes the acceleration of your vehicle. (MS^2)",
            syntax = { "Float", "Greater values will increase the rate of which the vehicle accelerates." }
        },
        ["engineInertia"] = {
            friendlyName = "Inertia",
            information = "Smoothens or sharpens the acceleration curve.",
            syntax = { "Float", "Greater values make the acceleration curve smoother." }
        },
        ["driveType"] = {
            friendlyName = "Wheel Drive",
            information = "Changes which wheels will be used whilst driving.",
            syntax = { "String", "Choosing 'All wheels' will result in the vehicle being easier to control." },
            options = { ["f"]="Front wheels",["r"]="Rear wheels",["4"]="All wheels" }
        },
        ["engineType"] = {
            friendlyName = "Engine Type",
            information = "Changes the type of engine for your vehicle.",
            syntax = { "String", "The effect this property causes is unknown." },
            options = { ["p"]="Petrol",["d"]="Diesel",["e"]="Electric" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Brake Deceleration",
            information = "Changes the deceleration of your vehicle. (MS^2)",
            syntax = { "Float", "Greater values will cause the vehicle to brake stronger, but may slip if your traction is too low." }
        },
        ["brakeBias"] = {
            friendlyName = "Brake Bias",
            information = "Changes the main position of the brakes.",
            syntax = { "Float", "Greater values will move the bias towards the front of the vehicle." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Enable or disable ABS on your vehicle.",
            syntax = { "Bool", "This property has no effect on your vehicle." },
            options = { ["true"]="Enabled",["false"]="Disabled" }
        },
        ["steeringLock"] = {
            friendlyName = "Steering Lock",
            information = "Changes the maximum angle your vehicle can steer.",
            syntax = { "Float", "The lower the steering angle the faster your vehicle." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Suspension Force Level",
            information = "The effect this property causes is unknown.",
            syntax = { "Float", "The syntax for this property is unknown." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Suspension Damping",
            information = "The effect this property causes is unknown.",
            syntax = { "Float", "The syntax for this property is unknown." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Suspension High Speed Damping",
            information = "Changes the stiffness of your suspension, causing you to drive faster.",
            syntax = { "Float", "The effect this property causes has not been tested." } -- HERE {UNTESTED}
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Suspension Upper Limit",
            information = "Uppermost movement of the wheels. (metres)",
            syntax = { "Float", "The effect this property causes has not been tested." } -- HERE {UNTESTED}
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Suspension Lower Limit",
            information = "The height of your suspension.",
            syntax = { "Float", "Lower values will make your vehicle higher." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Suspension Bias",
            information = "Changes where most of the suspension power will go to.",
            syntax = { "Float", "Greater values will move the bias towards the front of the vehicle." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Suspension Anti Dive Multiplier",
            information = "Changes the amount of body pitching under braking and acceleration.",
            syntax = { "Float", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Seat Offset Distance",
            information = "Changes how far the seat is from the door of your vehicle.",
            syntax = { "Float", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Collision Damage Multiplier",
            information = "Changes the damage your vehicle will receive from collisions.",
            syntax = { "Float", "" }
        },
        ["monetary"] = {
            friendlyName = "Monetary Value",
            information = "Changes the exact price of the vehicle.",
            syntax = { "Integer", "This property is unused within Multi Theft Auto." }
        },
        ["modelFlags"] = {
            friendlyName = "Model Flags",
            information = "Toggleable special animations of the vehicle.", -- HERE "where is this shown?"
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Animates the rear double doors."},
                    ["2"] = {"IS_BUS","Causes the vehicle to stop at bus stops and eat passengers."}, -- HERE "Possible teehee"
                    ["4"] = {"IS_LOW","Causes drivers and passengers to sit lower and lean back."},
                    ["8"] = {"IS_BIG","Changes the way in which the AI drives around corners."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","Cause the bonnet and boot to open in the opposite direction."},
                    ["2"] = {"HANGING_BOOT","Causes the boot to opens from the top edge."},
                    ["4"] = {"TAILGATE_BOOT","Causes the boot to open from the bottom edge."},
                    ["8"] = {"NOSWING_BOOT","Causes the boot to remain closed."}
                },
                {
                    ["1"] = {"NO_DOORS","Animations involving the closing and opening of doors are skipped."},
                    ["2"] = {"TANDEM_SEATS","Enables two people to use the front passenger seat."},
                    ["4"] = {"SIT_IN_BOAT","Causes peds to use the seated boat animation instead of standing."},
                    ["8"] = {"CONVERTIBLE","Changes how hookers operate and other small effects."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Causes the removal of all exhaust particles."},
                    ["2"] = {"DBL_EXHAUST","Adds a second exhaust particle on the opposite side to the first exhaust pipe."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Prevents the player from using rear field view when in first-person mode."},
                    ["8"] = {"FORCE_DOOR_CHECK","The effect this flag causes has not been tested."} -- HERE {untested}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Causes the front wheels to stay vertical to the car (like GTA 3)."},
                    ["2"] = {"AXLE_F_SOLID","Causes the front wheels to stay parallel to each other."},
                    ["4"] = {"AXLE_F_MCPHERSON","Causes the front wheels to tilt (like GTA Vice City)."},
                    ["8"] = {"AXLE_F_REVERSE","Causes the front wheels to tilt in the opposite direction."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Causes rear wheels to stay vertical to the car (like GTA 3)."},
                    ["2"] = {"AXLE_R_SOLID","Causes rear wheels to stay parallel to each other."},
                    ["4"] = {"AXLE_R_MCPHERSON","Causes rear wheels to tilt (like GTA Vice City)."},
                    ["8"] = {"AXLE_R_REVERSE","Causes the rear wheels to tilt in the opposite direction."}
                },
                {
                    ["1"] = {"IS_BIKE","Use the extra settings in the bikes section."},
                    ["2"] = {"IS_HELI","Use the extra settings in the flying section."},
                    ["4"] = {"IS_PLANE","Use the extra settings in the flying section."},
                    ["8"] = {"IS_BOAT","Use the extra settings in the boat section."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","The effect this flag causes has not been tested."}, -- HERE {untested}
                    ["2"] = {"DOUBLE_RWHEELS","This places a second rear wheel alongside the normal one."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","The effect this flag causes has not been tested."}, -- HERE {untested}
                    ["8"] = {"IS_HATCHBACK","The effect this flag causes has not been tested."} -- HERE {untested}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Handling Flags",
            information = "Special performance features.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Gives the engine more power for standing starts (for better hill climbing)."},
                    ["2"] = {"2G_BOOST","Gives the engine more power at slightly higher speeds."},
                    ["4"] = {"NPC_ANTI_ROLL","Disables body roll when driven by AI characters."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Reduces the likelness of the vehicle to spin out when driven by AI characters."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Disables the handbrake effect."},
                    ["2"] = {"STEER_REARWHEELS","Rear wheels steer instead of the front wheels (like a forklift)."},
                    ["4"] = {"HB_REARWHEEL_STEER","Causes the handbrake to make the rear wheels steer as well as front (like a monster truck)."},
                    ["8"] = {"ALT_STEER_OPT","The effect this flag causes has not been tested."} -- HERE {untested}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Causes very narrow front wheels."},
                    ["2"] = {"WHEEL_F_NARROW","Causes narrow front wheels."},
                    ["4"] = {"WHEEL_F_WIDE","Causes wide front wheels."},
                    ["8"] = {"WHEEL_F_WIDE2","Causes very wide front wheels."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Causes very narrow rear wheels."},
                    ["2"] = {"WHEEL_R_NARROW","Causes narrow rear wheels."},
                    ["4"] = {"WHEEL_R_WIDE","Causes wide rear wheels."},
                    ["8"] = {"WHEEL_R_WIDE2","Causes very wide rear wheels."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","The effect this flag causes has not been tested."}, -- HERE {untested}
                    ["2"] = {"HYDRAULIC_INST","Causes the vehicle to spawn with hydraulics installed."},
                    ["4"] = {"HYDRAULIC_NONE","Disables the installation of hydraulics."},
                    ["8"] = {"NOS_INST","Causes the vehicle the vehicle to spawn with nitrous installed."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Causes the vehicle to perform better on loose surfaces (like dirt)."},
                    ["2"] = {"OFFROAD_ABILITY2","Causes the vehicle to perform better on soft surfaces (like sand)."},
                    ["4"] = {"HALOGEN_LIGHTS","Makes headlights appear brighter and 'bluer'."},
                    ["8"] = {"PROC_REARWHEEL_1ST","The effect this flag causes has not been tested."} -- HERE {untested}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Prevents the vehicle from going faster than the maximum speed."},
                    ["2"] = {"LOW_RIDER","Allows the vehicle to be modified at the Loco Low Co shops."},
                    ["4"] = {"STREET_RACER","Causes vehicle to only be modifiable at the Wheel Arch Angels."},
                    ["8"] = {"",""}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Lets the car body move from side to side on the suspension."},
                    ["2"] = {"",""},
                    ["4"] = {"",""},
                    ["8"] = {"",""}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Head Lights",
            information = "Change the type of front lights your vehicle will have.",
            syntax = { "Integer", "" },
            options = { ["0"]="Long",["1"]="Small",["2"]="Big",["3"]="Tall" }
        },
        ["tailLight"] = {
            friendlyName = "Tail Lights",
            information = "Changes the type of rear lights your vehicle will have.",
            syntax = { "Integer", "" },
            options = { ["0"]="Long",["1"]="Small",["2"]="Big",["3"]="Tall" }
        },
        ["animGroup"] = {
            friendlyName = "Animation Group",
            information = "Changes the animation group peds will use whilst inside the vehicle.",
            syntax = { "Integer", "" }
        }
    }
}