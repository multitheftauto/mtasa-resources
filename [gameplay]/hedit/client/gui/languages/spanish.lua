guiLanguage.spanish = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Editor de Handling v"..HVER,
    
    restrictedPassenger = "No se le permite utilizar el editor de handling como pasajero.",
    needVehicle = "Debes estar conduciendo un vehículo para utilizar el editor de handling!",
    needLogin = "Debes iniciar sesion para poder visualizar este menú.",
    needAdmin = "Debes iniciar sesion como administrador para acceder a este menú.",
    invalidMenu = "Este menu no existe!",
    disabledMenu = "Este menu ha sido desactivado.",
    notifyUpdate = "The handling editor has been updated since the last time you've used it. Would you like to see a list of changes now? \nYou can always see the list of changes at 'Extra > Updates'",
    notifyUpgrade = "The handling editor has been UPGRADED. This means some of your files, such as saved handlings have been changed to another format. As a result, servers with an outdated version of hedit are not fully supported.\nWould you like to see a list of changes now? \nYou can always see the list of changes at 'Extra > Updates'",
    outdatedUpdate = "This server runs an outdated version of the handling editor. As a result, some features may be missing.\nPlease contact an administrator.",
    outdatedUpgrade = "This server runs an extremely outdated version of the handling editor. As a result, all settings/saved handling settings are incompatible.\nPlease contact an administrator.",
    mtaUpdate = "If you have any saved handlings on MTA 1.1, your handlings are no longer compatible; please visit 'http://hedit.googclecode.com/' for details.",
    
    sameValue = "El valor %s es el mismo!",
    exceedLimits = "El valor usado en %s excede el limite. [%s]!",
    cantSameValue = "%s no puede ser el mismo que %s!",
    needNumber = "Debes utilizar un numero!",
    unsupportedProperty = "%s no es una propiedad soportada.",
    successRegular = "%s cambio a %s.",
    successHex = "%s %s.",
    unableToChange = "No se pudo cambiar %s a %s!",
	disabledProperty = "Editing %s is disabled on this server!",
    
    resetted = "Reiniciaste con exito los valores de handling originales!",
    loaded = "Cargaste con exito tu configuracion de handling!",
    imported = "Importaste con exito tu configuracion de handling!",
    invalidImport = "Error al importar; los datos de handling son invalidos!",
    invalidSave = "Por favor, proporciona un nombre valido y una descripción para guardar el handling de este vehículo!",
    
    confirmReplace = "Estas seguro de que deseas sobrescribir este handling?",
    confirmLoad = "Estas seguro que quieres cargar este handling? Todas las modificaciones no guardadas se perderan!",
    confirmDelete = "Estas seguro que quieres borrar este handling?",
    confirmReset = "Estas seguro que quieres reiniciar este handling? Todas las modificaciones no guardadas se perderan!",
    confirmImport = "Estas seguro que quieres importar este handling? Todas las modificaciones no guardadas se perderan!",

    successSave = "Se guardo el handling con exito!",
    successLoad = "Se cargo el handling con exito!",
    
	confirmVersionReset = "Estas seguro de que deseas establecer la version del editor a la de este servidor? Tus handlings guardados pueden llegar a ser incompatibles.",
	successVersionReset = "La version de editor se ha actualizado.",
    wantTheSettings = "Estas seguro que deseas aplicar esta configuracion? El editor de handling se reiniciara.",
    
    vehicle = "Vehiculo",
    unsaved = "No guardado",
    
    clickToEdit = "Click para editar.",
    enterToSubmit = "Presiona enter para confirmar.",
    clickToViewFullLog = "Click para ver el registro del vehiculo completo.",
    copiedToClipboard = "Los valores de handling se han copiado en el portapapeles!",
    
    special = {
        commode = {
            "Dividir",
            "Unir"
        }
    },
    
    --
    -- BUTTON / MENU STRINGS
    --
    
    --Warning level strings
    warningtitles = {
        info = "Informacion",
        question = "Pregunta",
        warning = "Advertencia!",
        ["error"] = "Error!"
    },
    --Strings for the buttons at the top
    utilbuttons = {
        handling = "Handling",
        tools = "Herramientas",
        extra = "Extras",
        close = "X"
    },

    --Strings for the buttons at the right
    menubuttons = {
        engine = "Motor",
        body = "Chasis",
        wheels = "Traccion",
        appearance = "Vista",
        modelflags = "Extras Modelo",
        handlingflags = "Extras Handling",
        dynamometer = "Dinamo",
        help = "Ayuda"
    },
    
    --Strings for the various menus of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    menuinfo = {
        engine = {
            shortname = "Motor",
            longname = "Configuracion potencia"
        },
        body = {
            shortname = "Carroceria",
            longname = "Configuracion de peso, centro de gravedad y suspencion"
        },
        wheels = {
            shortname = "Ruedas",
            longname = "Configuracion de traccion y frenos"
        },
        appearance = {
            shortname = "Apariencia",
            longname = "Configuracion de apariencia"
        },
        modelflags = {
            shortname = "Variacion Modelo",
            longname = "Configuraciones extra de vehiculo"
        },
        handlingflags = {
            shortname = "Handling Flags",
            longname = "Configuraciones especiales de handling"
        },
        dynamometer = {
            shortname = "Dinamo",
            longname = "Empezar prueba dinamometrica"
        },
        help = {
            shortname = "Ayuda e Informacion",
            longname = "Ayuda",
            itemtext = {
                textlabel = "Welcome to the official MTA handling editor! This resource allows you to edit the handling of any vehicle in-game in real time.\n"..
                            "You can save and load custom handlings you make, via the 'Handling' menu at the top right.\n"..
                            "For more information about this handling editor, such as the official changelog, visit:\n",
                websitebox = "http://hedit.googlecode.com/",
                morelabel = "Thank you for choosing hedit!"
            }
        },
        reset = {
            shortname = "Reiniciar",
            longname = "Reiniciar a la configuracion original de handling.",
            itemtext = {
                label = "Vehiculo base:",
                combo = "-----",
                button = "Reiniciar"
            }
        },
        save = {
            shortname = "Guardar",
            longname = "Guardar el handling de este vehiculo.",
            itemtext = {
                nameLabel = "Nombre",
                descriptionLabel = "Descripcion",
                button = "Guardar",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        load = {
            shortname = "Cargar",
            longname = "Cargar un handling ya guardado.",
            itemtext = {
                button = "Cargar",
                grid = ""
            }
        },
        import = {
            shortname = "Importar",
            longname = "Importar una linea de handling en el formato usado en el archivo handling.cfg",
            itemtext = {
                button = "Importar",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        export = {
            shortname = "Exportar",
            longname = "Exportar la configuracion de handling al formato del archivo handling.cfg",
            itemtext = {
                button = "Copiar al portapapeles",
                memo = ""
            }
        },
        get = {
            shortname = "Obtener",
            longname = "Obtener el handling de otro jugador."
        },
        share = {
            shortname = "Compartir",
            longname = "Compartir tu configuracion de handling con otros jugadores."
        },
        upload = {
            shortname = "Subir",
            longname = "Subir tu handling al servidor."
        },
        download = {
            shortname = "Descargar",
            longname = "Descargar un handling del servidor."
        },
        
        resourcesave = {
            shortname = "Guardar en un recurso",
            longname = "Guarda el handling en un recurso."
        },
        resourceload = {
            shortname = "Cargar de un recurso",
            longname = "Carga el handling de un recurso."
        },
        options = {
            shortname = "Opciones",
            longname = "Opciones",
            itemtext = {
                label_key = "Tecla de acceso",
                label_cmd = "Comando de ejecucion:",
                label_template = "Plantilla GUI:",
                label_language = "Languaje:",
                label_commode = "Modo de edicion de centro de gravedad:",
                checkbox_versionreset = "Cambiar mi numero de version de %s a %s?",
                button_save = "Aplicar",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
				checkbox_lockwhenediting = "Bloquear el vehiculo al editarlo?"
            }
        },
        administration = {
            shortname = "Administracion",
            longname = "Herramientas de administrador."
        },
        handlinglog = {
            shortname = "Historial de Handling",
            longname = "Historial de cambios recientes en la configuracion de handling.",
            itemtext = {
                logpane = ""
            }
        },
        updatelist = {
            shortname = "Actualizaciones",
            longname = "Lista de actualizaciones recientes.",
            itemtext = {
                scrollpane = ""
            }
        },
        mtaversionupdate = {
            shortname = "Actualizacion de MTA",
            longname = "Multi Theft Auto se actualizo!",
            itemtext = {
                infotext = "Multi Theft Auto se actualizo. Debido a esto, los handlings creados en versiones anteriores no seran compatibles. Visita el siguiente link para ayuda y tener tus handlings de vuelta.",
                websitebox = "http://hedit.googlecode.com/"
            }
        }
    },
    
    --
    --NOTE: 12/17/2011 This section is pending review for typos and grammar.
    --
    handlingPropertyInformation = { 
        ["identifier"] = {
            friendlyName = "Identificacion de Vehiculo",
            information = "Esto representa la identificacion del vehiculo que se usara en el archivo handling.cfg.",
            syntax = { "String", "Solo usa identificadores validos, o al exportar no funcionara." }
        },
        ["mass"] = {
            friendlyName = "Peso",
            information = "Establece el peso de tu vehiculo en Kilos.",
            syntax = { "Valores", "Recuerda cambiar 'turnMass' primero para evitar que el vehiculo rebote!" }
        },
        ["turnMass"] = {
            friendlyName = "Peso al girar",
            information = "Se utiliza para calcular los efectos de movimiento.",
            syntax = { "Valores", "Valores altos hace sentir que tu vehiculo 'flota'." }
        },
        ["dragCoeff"] = {
            friendlyName = "Resistencia al Movimiento",
            information = "Cambia la resistencia al movimiento.",
            syntax = { "Valores", "Cuanto mas alto sea el valor, menor sera la velocidad maxima." }
        },
        ["centerOfMass"] = {
            friendlyName = "Centro de gravedad",
            information = "Establece el punto de gravedad del vehiculo, en metros.",
            syntax = { "Valores", "X Desplaza el peso izq/der, Y desplaza el peso adelante/atras, y Z desplaza el peso arriba/abajo." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Centro de gravedad X",
            information = "Desplaza en metros el peso del vehiculo hacia la derecha o hacia la izquierda.",
            syntax = { "Valores", "Valores altos desplazan el peso a la derecha, valores bajos a la izquierda." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Centro de gravedad Y",
            information = "Desplaza en metros el peso del vehiculo hacia adelante o atras.",
            syntax = { "Valores", "Valores altos desplazan el peso hacia adelante, valores bajos hacia atras." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Centro de gravedad Z",
            information = "Desplaza en metros el peso del vehiculo hacia arriba o hacia abajo.",
            syntax = { "Valores", "Valores altos suben tu centro de gravedad haciendo mas facil volcar, valores bajos hacen bajar tu centro de gravedad y obtienes mejor estabilidad." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Porcentaje sumergido",
            information = "Ajusta el valor de flote cuanto tu vehiculo cae al agua.",
            syntax = { "Nuemro Entero", "Valores altos hacen que tu vehiculo se hunda mas rapido." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Traccion",
            information = "Establece la cantidad de agarre que tendra tu vehículo.",
            syntax = { "Valores", "Valores altos hacen que tu vehiculo tenga mas agarre." }
        },
        ["tractionLoss"] = {
            friendlyName = "Traccion con fuerzas G",
            information = "Establece la cantidad de agarre que tendra tu vehículo al ser sometido a fuerzas centrifugas.",
            syntax = { "Valores", "Valores altos hacen que tu vehiculo tenga mas agarre y tome mejor las curvas." }
        },
        ["tractionBias"] = {
            friendlyName = "Diferencia de traccion",
            information = "Modifica el agarre entre los neumaticos delanteros y traseros.",
            syntax = { "Valores", "Valores altos desplazan el agarre hacia las ruedas delanteras, valores bajos hacia las traseras y 0,5 ambos trenes tienen el mismo agarre." }
        },
        ["numberOfGears"] = {
            friendlyName = "Numero de marchas",
            information = "Establece cuantos cambios tendra tu vehiculo.",
            syntax = { "Numero Entero", "No tiene efectos en la aceleracion o en la velocidad final. Solo es una animacion." }
        },
        ["maxVelocity"] = {
            friendlyName = "Velocidad Maxima",
            information = "Establece la velocidad maxima en KM/H.",
            syntax = { "Valores", "Puede ser afectada por otros valores." }
        },
        ["engineAcceleration"] = {
            friendlyName = "Aceleracion",
            information = "Establece la aceleracion en MS^2 de tu vehiculo.",
            syntax = { "Valores", "Valores altos hacen que el vehiculo acelere mas rapido." }
        },
        ["engineInertia"] = {
            friendlyName = "Inercia",
            information = "Suaviza o agudiza la aceleracion.",
            syntax = { "Valores", "Valores altos hacen que la aceleracion no sea tan brusca." }
        },
        ["driveType"] = {
            friendlyName = "Tipo de Traccion",
            information = "Establece que ruedas llevan la fuerza de motriz.",
            syntax = { "String", "Escojiendo '4x4' resultara en un vehiculo mas facil de conducir." },
            options = { ["f"]="Traccion Delantera",["r"]="Traccion Trasera",["4"]="Traccion Integral" }
        },
        ["engineType"] = {
            friendlyName = "Tipo de Motor",
            information = "Establece el tipo de motor que tiene tu vehiculo.",
            syntax = { "String", "[UNKNOWN]" },
            options = { ["p"]="Bencinero",["d"]="Diesel",["e"]="Electrico" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Fuerza de Frenado",
            information = "Establece la fuerza de frenado en MS^2.",
            syntax = { "Valores", "Valores altos hacen que la frenada sea mas fuerte, pero puedes bloquear las ruedas." }
        },
        ["brakeBias"] = {
            friendlyName = "Diferencia de Frenado",
            information = "Define a que ruedas se le da mayor fuerza.",
            syntax = { "Valores", "Valores altos hacen que la fuerza de frenado se aplique en las ruedas delanteras, valores bajos en las traseras y 0,5 es balanceado." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Enciende o apaga el ABS de tu vehiculo.",
            syntax = { "Bool", "Sin efectos." },
            options = { ["true"]="Enabled",["false"]="Disabled" }
        },
        ["steeringLock"] = {
            friendlyName = "Angulo de giro",
            information = "Establece el angulo de giro maximo que pueden tener las ruedas delanteras.",
            syntax = { "Valores", "El angulo de giro disminuye a medida que vas mas rapido." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Fuerza de Suspencion",
            information = "Hace la suspencion mas dura o blanda.",
            syntax = { "Float", "Hace la suspencion mas fuerte." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Rebote de amortiguacion",
            information = "Define el rebote de la amortiguacion.",
            syntax = { "Valores", "Valores del orden de 0.01 hacen que la suspencion rebote mas." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Rebote de amortiguacion a alta velocidad",
            information = "Define el rebote de la amortiguacion a altas velocidades.",
            syntax = { "Valores", "Casi imperceptible" } -- HERE
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Limite superior suspencion",
            information = "Establece el recorrido superior de la suspencion al amortiguar.",
            syntax = { "Valores", "Establece que tan alto puede llegar la suspencion al amortiguar" } -- HERE
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Altura de suspencion",
            information = "Establece la altura de la suspencion.",
            syntax = { "Valores", "Valores altos hacen que tu vehiculo este mas pegado al piso." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Diferencia de amortiguacion",
            information = "Define a que eje se le da mayor fuerza de amortiguacion.",
            syntax = { "Valores", "Valores altos, ruedas delanteras - valores bajos, traseras - 0,5 Balance." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Cabeceo de Suspencion",
            information = "Cambia la cantidad de carga en la suspencion al acelerar o desacelerar.",
            syntax = { "Valores", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Separador de distancia de asiento",
            information = "Define la distancia entre el asiento y la puerta de tu vehículo.",
            syntax = { "Valores", "Usa 1 para vehiculos con volante a la derecha" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Multiplicador de colicion",
            information = "Establece el dano recibido al colicionar.",
            syntax = { "Valores", "" }
        },
        ["monetary"] = {
            friendlyName = "Valor Monetario",
            information = "Establece el valor de tu vehiculo.",
            syntax = { "Numero Entero", "" }
        },
        ["modelFlags"] = {
            friendlyName = "Extras de Modelo",
            information = "Animaciones especiales que pueden ser activadas o desactivadas.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Allows double doors for the rear animation."},
                    ["2"] = {"IS_BUS","Vehicle uses bus stops and will try to take on passengers."},
                    ["4"] = {"IS_LOW","Drivers and passengers sit lower and lean back."},
                    ["8"] = {"IS_BIG","Changes the way that the AI drives around corners."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","Bonnet and boot open in opposite direction from normal."},
                    ["2"] = {"HANGING_BOOT","Boot opens from top edge."},
                    ["4"] = {"TAILGATE_BOOT","Boot opens from bottom edge."},
                    ["8"] = {"NOSWING_BOOT","Boot does not open."}
                },
                {
                    ["1"] = {"NO_DOORS","Door open and close animations are skipped."},
                    ["2"] = {"TANDEM_SEATS","Two people will use the front passenger seat."},
                    ["4"] = {"SIT_IN_BOAT","Uses seated boat animation instead of standing."},
                    ["8"] = {"CONVERTIBLE","Changes how hookers operate and other small effects."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Removes all exhaust particles."},
                    ["2"] = {"DBL_EXHAUST","Adds a second exhaust particle on opposite side to first."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Prevents player using rear view when in first-person mode."},
                    ["8"] = {"FORCE_DOOR_CHECK","Needs testing."}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Front wheels stay vertical to the car like GTA 3."},
                    ["2"] = {"AXLE_F_SOLID","Front wheels stay parallel to each other."},
                    ["4"] = {"AXLE_F_MCPHERSON","Front wheels tilt like GTA Vice City."},
                    ["8"] = {"AXLE_F_REVERSE","Reverses the tilting of wheels when using AXLE_F_MCPHERSON suspension."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Rear wheels stay vertical to the car like GTA 3."},
                    ["2"] = {"AXLE_R_SOLID","Rear wheels stay parallel to each other."},
                    ["4"] = {"AXLE_R_MCPHERSON","Rear wheels tilt like GTA Vice City."},
                    ["8"] = {"AXLE_R_REVERSE","Reverses the tilting of wheels when using AXLE_R_MCPHERSON suspension."}
                },
                {
                    ["1"] = {"IS_BIKE","Use extra handling settings in the bikes section."},
                    ["2"] = {"IS_HELI","Use extra handling settings in the flying section."},
                    ["4"] = {"IS_PLANE","Use extra handling settings in the flying section."},
                    ["8"] = {"IS_BOAT","Use extra handling settings in the flying section."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","Needs testing."},
                    ["2"] = {"DOUBLE_RWHEELS","Places a second instance of each rear wheel next to the normal one."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","Needs testing."},
                    ["8"] = {"IS_HATCHBACK","Needs testing."}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Extras de handling",
            information = "Caracteristicas especiales de prestaciones.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Gives more engine power for standing starts; better hill climbing."},
                    ["2"] = {"2G_BOOST","Gives more engine power at slightly higher speeds."},
                    ["4"] = {"NPC_ANTI_ROLL","No body roll when driven by AI characters."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Less likely to spin out when driven by AI characters."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Disables the handbrake effect."},
                    ["2"] = {"STEER_REARWHEELS","Rear wheels steer instead of front, like a forklift truck."},
                    ["4"] = {"HB_REARWHEEL_STEER","Handbrake makes the rear wheels steer as well as front, like the monster truck"},
                    ["8"] = {"ALT_STEER_OPT","Needs testing."}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Very narrow front wheels."},
                    ["2"] = {"WHEEL_F_NARROW","Narrow front wheels."},
                    ["4"] = {"WHEEL_F_WIDE","Wide front wheels."},
                    ["8"] = {"WHEEL_F_WIDE2","Very wide front wheels."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Very narrow rear wheels."},
                    ["2"] = {"WHEEL_R_NARROW","Narrow rear wheels."},
                    ["4"] = {"WHEEL_R_WIDE","Wide rear wheels."},
                    ["8"] = {"WHEEL_R_WIDE2","Very wide rear wheels."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","Needs testing."},
                    ["2"] = {"HYDRAULIC_INST","Will spawn with hydraulics installed."},
                    ["4"] = {"HYDRAULIC_NONE","Hydraulics cannot be installed."},
                    ["8"] = {"NOS_INST","Vehicle automatically gets NOS installed when it spawns."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Vehicle will perform better on loose surfaces like dirt."},
                    ["2"] = {"OFFROAD_ABILITY2","Vehicle will perform better on soft surfaces like sand."},
                    ["4"] = {"HALOGEN_LIGHTS","Makes headlights brighter and more blue."},
                    ["8"] = {"PROC_REARWHEEL_1ST","Needs testing."}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Prevents vehicle going faster than the maximum speed."},
                    ["2"] = {"LOW_RIDER","Allows vehicle to be modified at Loco Low Co shops."},
                    ["4"] = {"STREET_RACER","When set, vehicle can only be modified at Wheel Arch Angels."},
                    ["8"] = {"UNDEFINED","No effect."}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Lets the car body move from side to side on the suspension."},
                    ["2"] = {"UNDEFINED","No effect."},
                    ["4"] = {"UNDEFINED","No effect."},
                    ["8"] = {"UNDEFINED","No effect."}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Luces",
            information = "Sets the type of front lights your vehicle will have.",
            syntax = { "Integer", "" },
            options = { ["0"]="Long",["1"]="Small",["2"]="Big",["3"]="Tall" }
        },
        ["tailLight"] = {
            friendlyName = "Luces Traseras",
            information = "Sets the type of rear lights your vehicle will have.",
            syntax = { "Integer", "" },
            options = { ["0"]="Long",["1"]="Small",["2"]="Big",["3"]="Tall" }
        },
        ["animGroup"] = {
            friendlyName = "Grupo de Animacion",
            information = "Sets the group of animation your ped will use for it's vehicle.",
            syntax = { "Integer", "" }
        }
    }
}