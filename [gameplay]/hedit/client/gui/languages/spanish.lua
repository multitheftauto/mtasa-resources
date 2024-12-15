guiLanguage.spanish = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Editor de Handling v"..HVER,

    restrictedPassenger = "No puedes usar el editor de handling como pasajero.",
    needVehicle = "Necesitas estar de conductor para usar el menu de handling!",
    needLogin = "Necesitas estar logeado para usar este menu.",
    needAdmin = "Necesitas estar logeado como administrador para usar este menu.",
    accessDenied = "No tienes permisos necesarios para acceder a este menu.",
    invalidView = "Este menu no existe!",
    disabledView = "Este menu fue desactivado.",

    sameValue = "%s ya esta definido igual!",
    exceedLimits = "El valor usado en %s excede el limite. [%s]!",
    cantSameValue = "%s no puede ser igual a %s!",
    needNumber = "Necesitas usar un numero!",
    unsupportedProperty = "%s no es una propiedad soportada.",
    successRegular = "%s definido como %s.",
    successHex = "%s %s.",
    unableToChange = "No es posible definir %s como %s!",
    disabledProperty = "Editar %s esta desactivado en este servidor!",

    resetted = "Las configuracion de handling fueron redefinidas correctamente!",
    loaded = "Sus configuracion de handling fueron cargadas correctamente!",
    imported = "Las configuracion de handling fueron importadas correctamente!",
    invalidImport = "Fallo de importacion. los datos establecidos son incorrectos!",
    invalidSave = "Por favor, inserte un nombre y descripcion validos para guardar los datos de handling del vehiculo!",

    confirmReplace = "¿Estás seguro de que quieres sustituir el handling existente?",
    confirmLoad = "¿Está seguro de que desea cargar estos ajustes de handling? Los cambios no guardados se perderán.",
    confirmDelete = "¿Estás seguro de que quieres borrar estos ajustes de handling??",
    confirmReset = "¿Estás seguro de que quieres restablecer el handling? Cualquier cambio no guardado se perderá.",
    confirmImport = "¿Estás seguro de que quieres importar este handling? Los cambios no guardados se perderán.",

    successSave = "Sus configuraciones de handling fueron guardadas correctamente!",
    successLoad = "Sus configuraciones de handling fueron cargadas correctamente!",
    successDelete = "Sus configuraciones de handling fueron borradas correctamente!",

    wantTheSettings = "¿Está seguro de que desea aplicar estos ajustes? El editor se reiniciará.",

    vehicle = "Vehiculo",
    unsaved = "No Guardado",

    clickToEdit = "Haga clic para editar o arrastre para un ajuste rápido.",
    enterToSubmit = "Presione Enter para confirmar.",
    clickToViewFullLog = "Haga clic para ver el registro completo del vehículo.",
    copiedToClipboard = "Las configuraciones de handling se han copiado en el portapapeles!",

    special = {
    },

    --
    -- BUTTON / MENU STRINGS
    --

    --Warning level strings
    warningtitles = {
        info = "Informacion",
        question = "Pregunta",
        warning = "Aviso!",
        error = "Error!"
    },
    --Strings for the buttons at the top
    menubar = {
        handling = "Handling",
        tools = "Herramientas",
        extra = "Extra",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "Motor",
        body = "Chasis",
        wheels = "Ruedas",
        appearance = "Apariencia",
        modelflags = "Flags\nModelo",
        handlingflags = "Flags\nHandling",
        dynamometer = "Dinamómetro",
        undo = "<",
        redo = ">",
        save = "Saves"
    },

    -- Strings for the various menus of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "Motor",
            longname = "Configuraciones del Motor"
        },
        body = {
            shortname = "Carroceria",
            longname = "Configuraciones de Carroceria"
        },
        wheels = {
            shortname = "Ruedas",
            longname = "Configuraciones de Ruedas"
        },
        appearance = {
            shortname = "Apariencia",
            longname = "Configuracion de Apariencia"
        },
        modelflags = {
            shortname = "Flags del Modelo",
            longname = "Ajustes del modelo de vehículo"
        },
        handlingflags = {
            shortname = "Handling Flags",
            longname = "Configuraciones especiales de Handling"
        },
        dynamometer = {
            shortname = "Dinamómetro",
            longname = "Iniciar Dinamómetro"
        },
        about = {
            shortname = "Info",
            longname = "Info sobre el editor oficial de Handlings",
            itemtext = {
                textlabel = "Bienvenido al editor de Handling oficial de MTA! Este recurso te permite modificar el handling de cualquier vehículo en tiempo real en el juego..\n\n"..
                            "Puede guardar y cargar handlings personalizados a través del menú 'Handling' en la esquina superior izquierda.\n\n"..
                            "Para obtener mas informacion sobre el Editor de Handling - como registro oficial de cambios - visite:",
                websitebox = "https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/hedit",
                morelabel = "\nGracias por escoger hedit!"
            }
        },
        undo = {
            shortname = "Deshacer",
            longname = "Deshacer",
            itemtext = {
                textlabel = "Algo ha salido mal."
            }
        },
        redo = {
            shortname = "Rehacer",
            longname = "Rehacer",
            itemtext = {
                textlabel = "Algo ha salido mal."
            }
        },
        reset = {
            shortname = "Redefinir",
            longname = "Redefinir las configuraciones de handling del vehiculo.",
            itemtext = {
                label = "Vehiculo Base:",
                combo = "-----",
                button = "Redefinir"
            }
        },
        save = {
            shortname = "Saves",
            longname = "Cargar, guardar o eliminar handlings.",
            itemtext = {
                nameLabel = "Nombre",
                descriptionLabel = "Descripcion",
                saveButton = "Guardar",
                loadButton = "Cargar",
                deleteButton = "Borrar",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "handling.cfg",
            longname = "Importar o Exportar en/formato handling.cfg.",
            itemtext = {
                importButton = "Importar",
                exportButton = "Exportar y copiar en el portapapeles",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "Obtener",
            longname = "Obtener configuraciones de handling de otro jugador."
        },
        share = {
            shortname = "Compartir",
            longname = "Compartir sus configuraciones de handling con otro jugador."
        },
        upload = {
            shortname = "Enviar",
            longname = "Enviar sus configuraciones de handling para el servidor."
        },
        download = {
            shortname = "Descargar",
            longname = "Descargar un conjunto de configuraciones de handling del servidor."
        },
        resourcesave = {
            shortname = "Guardar recurso",
            longname = "Guardar las configuraciones de handling en un recurso."
        },
        resourceload = {
            shortname = "Cargar recurso",
            longname = "Cargar una configuracion de handling de un recurso."
        },
        options = {
            shortname = "Opciones",
            longname = "Opciones",
            itemtext = {
                label_key = "Tecla de Alternancia",
                label_cmd = "Comando de Alternancia:",
                label_template = "Modelo de GUI:",
                label_language = "Idioma:",
                label_commode = "Modo de edición del centro de masa:",
                checkbox_versionreset = "Bajar mi número de versión de %s a %s?",
                button_save = "Aplicar",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
                checkbox_lockwhenediting = "Bloquear vehiculo durante edita su handling?",
                checkbox_dragmeterEnabled = "Usar ajuste rapido"
            }
        },
        handlinglog = {
            shortname = "Registro de Handling",
            longname = "Registro de cambios recientes en los ajustes de handling.",
            itemtext = {
                logpane = ""
            }
        },
    },


    handlingPropertyInformation = {
        ["identifier"] = {
            friendlyName = "Identificador del vehiculo",
            information = "Representa el identificador del vehículo que se utilizará en handling.cfg.",
            syntax = { "String", "Utilice sólo identificadores válidos, de lo contrario la exportación no funcionará." }
        },
        ["mass"] = {
            friendlyName = "Masa",
            information = "Altera el peso del vehiculo. (kg)",
            syntax = { "Float", "Recuerda cambiar primero 'turnMass' para evitar saltos!" }
        },
        ["turnMass"] = {
            friendlyName = "Masa de giro",
            information = "Se utiliza para calcular los efectos del movimiento.",
            syntax = { "Float", "Los valores grandes harán que el vehículo parezca 'flotar'." }
        },
        ["dragCoeff"] = {
            friendlyName = "Coeficiente de resistencia",
            information = "Modifica la resistencia al movimiento."
        },
        ["centerOfMass"] = {
            friendlyName = "Centro de masa",
            information = "Modifica el punto de gravedad de tu vehículo. (metros)",
            syntax = { "Float", "Pase el ratón sobre cada una de las coordenadas para obtener información." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Centro de Masa X",
            information = "Asigna la distancia delantera-trasera del centro de masa. (metros)",
            syntax = { "Float", "Los valores altos están delante y los bajos detrás." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Centro de Masa Y",
            information = "Asigna la distancia izquierda-derecha del centro de masa. (metros)",
            syntax = { "Float", "Los valores altos están a la derecha y los bajos a la izquierda." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Centro de Masa Z",
            information = "Asignar la altura del centro de masa. (metros)",
            syntax = { "Float", "Cuanto mayor sea el valor, mayor será la posición del punto." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Porcentaje sumergido",
            information = "Cambia la profundidad a la que debe sumergirse el vehículo para que empiece a flotar. (porcentaje)",
            syntax = { "Inteiro", "Los valores más altos harán que su vehículo comience a flotar a un nivel más profundo." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Multiplicador de tracción",
            information = "Modifica la adherencia del vehículo al suelo en las curvas..",
            syntax = { "Float", "Los valores más altos aumentarán el agarre entre las ruedas y la superficie." }
        },
        ["tractionLoss"] = {
            friendlyName = "Pérdida de tracción",
            information = "Modifica la adherencia del vehículo al acelerar y desacelerar..",
            syntax = { "Float", "Los valores más altos harán que su vehículo tome las curvas con más eficencia." }
        },
        ["tractionBias"] = {
            friendlyName = "Inclinacion de Traccion",
            information = "Cambios en la asignación de la adherencia de las ruedas.",
            syntax = { "Float", "Los valores más altos moverán la inclinacion a la parte delantera de su vehículo." }
        },
        ["numberOfGears"] = {
            friendlyName = "Número de Marchas",
            information = "Cambia el número máximo de marchas que puede tener tu vehículo.",
            syntax = { "Entero", "No afecta a la velocidad máxima ni a la aceleración del vehículo.." }
        },
        ["maxVelocity"] = {
            friendlyName = "Velocidad Máxima",
            information = "Cambia la velocidad máxima de tu vehículo. (km/h)",
            syntax = { "Float", "Este valor se ve afectado por otras propiedades." }
        },

        ["engineAcceleration"] = {
            friendlyName = "Aceleracion",
            information = "Cambia la aceleración de tu vehículo",
            syntax = { "Float", "Los valores más altos aumentarán la velocidad de aceleración del vehículo." }
        },
        ["engineInertia"] = {
            friendlyName = "Inercia",
            information = "Hace que la curva de aceleración sea más suave o más pronunciada.",
            syntax = { "Float", "Los valores más altos hacen que la curva de aceleración sea más suave." }
        },
        ["driveType"] = {
            friendlyName = "Tracción en las ruedas",
            information = "Cambia qué ruedas se utilizan al conducir.",
            syntax = { "String", "Escoger 'Todas las ruedas' facilitará el control del vehículo." },
            options = { ["f"]="Ruedas Delanteras",["r"]="Ruedas Traseras",["4"]="Todas las ruedas" }
        },
        ["engineType"] = {
            friendlyName = "Tipo de Motor",
            information = "Cambia el tipo de motor de tu vehículo.",
            syntax = { "String", "Se desconoce el efecto que causa esta propiedad." },
            options = { ["p"]="Gasolina",["d"]="Diesel",["e"]="Electrico" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Intensidad del freno",
            information = "Cambia la intensidad de frenado",
            syntax = { "Float", "Los valores más altos harán que el vehículo frene con más fuerza, pero puede derrapar si la tracción es demasiado baja." }
        },
        ["brakeBias"] = {
            friendlyName = "Inclinación de frenos",
            information = "Modifica la posición del freno principal.",
            syntax = { "Float", "Los valores más altos desplazarán la inclinación hacia la parte delantera del vehículo." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Activa o desactiva el ABS.",
            syntax = { "Booleano", "Esta propiedad no afecta a su vehículo." },
            options = { ["true"]="Activado",["false"]="Desactivado" }
        },
        ["steeringLock"] = {
            friendlyName = "Límite de dirección",
            information = "Cambia el ángulo máximo de giro del vehículo.",
            syntax = { "Float", "Cuanto menor sea el ángulo de giro, más rápido irá el vehículo." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Fuerza de suspensión",
            information = "Se desconoce el efecto que causa esta propiedad.",
            syntax = { "Float", "Se desconoce la sintaxis de esta propiedad." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Amortiguación de Supension",
            information = "Se desconoce el efecto que causa esta propiedad.",
            syntax = { "Float", "Se desconoce la sintaxis de esta propiedad." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Amortiguación de suspensión a alta velocidad",
            information = "Cambia la rigidez de tu suspensión, haciéndote conducir más rápido.",
            syntax = { "Float", "No se ha comprobado el efecto de esta propiedad." }
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Límite superior de suspensión",
            information = "Máximo desplazamiento de la rueda (metros)",
            syntax = { "Float", "No se ha comprobado el efecto de esta propiedad." }
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Límite inferior de la suspensión",
            information = "La altura de su suspensión.",
            syntax = { "Float", "Los valores más bajos harán que su vehículo sea más alto." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Inclinacion de suspension",
            information = "Cambia dónde se aplicará la mayor parte de la potencia de la suspensión..",
            syntax = { "Float", "Los valores más altos desplazarán la inclinacion hacia la parte delantera del vehículo." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Multiplicador anticaída de la suspensión",
            information = "Modifica la inclinación del cuerpo al frenar y acelerar.",
            syntax = { "Float", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Distancia de desplazamiento del asiento",
            information = "Modifica la distancia entre el asiento y la puerta de tu vehículo.",
            syntax = { "Float", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Multiplicador del daño por colisión",
            information = "Cambia el daño que recibirá tu vehículo en cuando colisione.",
            syntax = { "Float", "" }
        },
        ["monetary"] = {
            friendlyName = "Valor monetario",
            information = "Cambia el precio exacto del vehículo.",
            syntax = { "Inteiro", "Esta propiedad no se utiliza en Multi Theft Auto." }
        },
        ["modelFlags"] = {
            friendlyName = "Flags del vehiculo",
            information = "Animaciones especiales activables de vehículos.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Animar las puertas traseras dobles."},
                    ["2"] = {"IS_BUS","Hace que el vehículo se detenga en las paradas de autobús y recoja pasajeros."},
                    ["4"] = {"IS_LOW","Hace que conductores y pasajeros se sienten más bajos y se inclinen hacia atrás."},
                    ["8"] = {"IS_BIG","Cambia la forma de la IA al tomar curvas."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","Hace que el capó y el maletero se abran en sentido contrario.."},
                    ["2"] = {"HANGING_BOOT","Hace que el maletero se abra por el borde superior."},
                    ["4"] = {"TAILGATE_BOOT","Hace que el maletero se abra desde el borde inferior."},
                    ["8"] = {"NOSWING_BOOT","Mantiene el maletero cerrado."}
                },
                {
                    ["1"] = {"NO_DOORS","Se ignoran las animaciones de apertura y cierre de puertas."},
                    ["2"] = {"TANDEM_SEATS","Permite que dos personas utilicen el asiento del pasajero delantero."},
                    ["4"] = {"SIT_IN_BOAT","Hace que los peatones utilicen la animación sentados en los barcos en lugar de de pie."},
                    ["8"] = {"CONVERTIBLE","Cambia el comportamiento de las prostitutas y otros pequeños efectos."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Elimina todas las partículas de escape."},
                    ["2"] = {"DBL_EXHAUST","Añade una segunda partícula de escape en el lado opuesto al primer tubo de escape."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Impide que el jugador utilice la vista trasera en primera persona."},
                    ["8"] = {"FORCE_DOOR_CHECK","No se ha comprobado el efecto de esta casilla."}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Hace que las ruedas delanteras permanezcan verticales al coche (como en GTA 3)."},
                    ["2"] = {"AXLE_F_SOLID","Hace que las ruedas delanteras permanezcan paralelas entre sí."},
                    ["4"] = {"AXLE_F_MCPHERSON","Hace que las ruedas delanteras se inclinen (como en GTA Vice City)."},
                    ["8"] = {"AXLE_F_REVERSE","Hace que las ruedas delanteras se inclinen en sentido contrario."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Hace que las ruedas traseras permanezcan verticales al coche (como en GTA 3)."},
                    ["2"] = {"AXLE_R_SOLID","Hace que las ruedas traseras permanezcan paralelas entre sí."},
                    ["4"] = {"AXLE_R_MCPHERSON","Hace que las ruedas traseras se inclinen (como en GTA Vice City)."},
                    ["8"] = {"AXLE_R_REVERSE","Hace que las ruedas traseras se inclinen en sentido contrario."}
                },
                {
                    ["1"] = {"IS_BIKE","Utiliza los ajustes adicionales de la sección de motos."},
                    ["2"] = {"IS_HELI","Utiliza los ajustes adicionales de la sección de vuelo."},
                    ["4"] = {"IS_PLANE","Utiliza los ajustes adicionales de la sección de vuelo."},
                    ["8"] = {"IS_BOAT","Utiliza los ajustes adicionales de la sección del barco."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","No se ha comprobado el efecto de esta casilla."},
                    ["2"] = {"DOUBLE_RWHEELS","Esto coloca una segunda rueda trasera junto a la rueda normal."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","No se ha comprobado el efecto de esta casilla."},
                    ["8"] = {"IS_HATCHBACK","No se ha comprobado el efecto de esta casilla."}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Casillas de Handling",
            information = "Recursos especiales de desempeño.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Proporciona más potencia al motor para arranques (mejor para subidas pronunciadas).."},
                    ["2"] = {"2G_BOOST","Proporciona más potencia al motor a velocidades ligeramente superiores."},
                    ["4"] = {"NPC_ANTI_ROLL","Desactiva la inclinación del cuerpo al ser conducido por personajes de la IA.."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Reduce la probabilidad de que el vehículo derrape cuando lo conducen personajes de la IA.."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Desactiva el efecto freno de mano."},
                    ["2"] = {"STEER_REARWHEELS","Las ruedas traseras giran en lugar de las delanteras (como una carretilla)."},
                    ["4"] = {"HB_REARWHEEL_STEER","El freno de mano hace que las ruedas traseras giren más que las delanteras (como un monster truck).."},
                    ["8"] = {"ALT_STEER_OPT","No se ha comprobado el efecto de esta casilla."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Hace que las ruedas delanteras sean demasiado estrechas."},
                    ["2"] = {"WHEEL_R_NARROW","Hace estrechas las ruedas delanteras."},
                    ["4"] = {"WHEEL_R_WIDE","Hace que las ruedas delanteras sean anchas."},
                    ["8"] = {"WHEEL_R_WIDE2","Hace que las ruedas delanteras sean demasiado anchas."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Hace que las ruedas delanteras sean demasiado estrechas."},
                    ["2"] = {"WHEEL_R_NARROW","Hace estrechas las ruedas delanteras."},
                    ["4"] = {"WHEEL_R_WIDE","Hace que las ruedas delanteras sean anchas."},
                    ["8"] = {"WHEEL_R_WIDE2","Hace que las ruedas delanteras sean demasiado anchas."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","El efecto de esta modificación no se ha probado."},
                    ["2"] = {"HYDRAULIC_INST","Hace aparecer el vehículo con el sistema hidráulico instalado."},
                    ["4"] = {"HYDRAULIC_NONE","Desactiva el sistema hidráulico."},
                    ["8"] = {"NOS_INST","Hace que el vehículo aparezca con nitro instalado."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Mejora el rendimiento del vehículo en superficies sueltas (como la tierra)."},
                    ["2"] = {"OFFROAD_ABILITY2","Mejora el rendimiento del vehículo en superficies blandas (como la arena)."},
                    ["4"] = {"HALOGEN_LIGHTS","Hace que los faros parezcan más brillantes y \"mas azules\"."},
                    ["8"] = {"PROC_REARWHEEL_1ST","No se ha comprobado el efecto que causa la modificación."}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Evita que el vehículo supere la velocidad máxima."},
                    ["2"] = {"LOW_RIDER","Permite modificar el vehículo en los talleres Loco Low Co.."},
                    ["4"] = {"STREET_RACER","Hace que el vehículosea modificable en los angulos del arco de la Rueda."},
                    ["8"] = {"",""}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Permite que la carrocería se mueva de lado a lado sobre la suspensión."},
                    ["2"] = {"",""},
                    ["4"] = {"",""},
                    ["8"] = {"",""}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Luces delanteras",
            information = "Cambia el tipo de luces delanteras que tendrá el vehículo.",
            syntax = { "Integer", "" },
            options = { ["0"]="Largas",["1"]="Pequeñas",["2"]="Grandes",["3"]="Altas" }
        },
        ["tailLight"] = {
            friendlyName = "Luces traseras",
            information = "Cambia el tipo de luces traseras que tendrá el vehículo.",
            syntax = { "Integer", "" },
            options = { ["0"]="Largas",["1"]="Pequeñas",["2"]="Grandes",["3"]="Altas" }
        },
        ["animGroup"] = {
            friendlyName = "Grupo de Animacion",
            information = "Altera el grupo de animacion que utilizarán los peatones cuando estén dentro del vehículo.",
            syntax = { "Integer", "" }
        }
    }
}
