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
    notifyUpdate = "El editor de handling ha sido actualizado despues de la última vez que lo utilizaste. ¿Quieres ver ahora la lista de cambios? \Siempre puedes ver la lista de cambios en 'Extra > Actualizaciones'.",
    notifyUpgrade = "El editor de handling ha sido ACTUALIZADO. Esto significa que algunos de sus archivos, como los handlings guardados han sido cambiados a otro formato. Como resultado, los servidores con una versión obsoleta de hedit no son totalmente compatibles.\n¿Quieres ver una lista de cambios ahora? \nSiempre puede ver la lista de cambios en 'Extra > Actualizaciones'",
    outdatedUpdate = "This server runs an outdated version of the handling editor. As a result, some features may be missing.\nPlease contact an administrator.",
    outdatedUpgrade = "Este servidor ejecuta una versión extremadamente obsoleta del editor de handling. Como resultado, todos los ajustes/configuraciones de handling guardadas son incompatibles.\nPóngase en contacto con un administrador.",
    mtaUpdate = "Si tienes algun handling guardado en MTA 1.1, tus manipulaciones ya no son compatibles; visita 'http://hedit.googclecode.com/' para obtener más detalles..",

    sameValue = "El valor %s es el mismo!",
    exceedLimits = "El valor usado en %s excede el limite. [%s]!",
    cantSameValue = "%s no puede ser el mismo que %s!",
    needNumber = "Debes utilizar un numero!",
    unsupportedProperty = "%s no es una propiedad soportada.",
    successRegular = "%s cambio a %s.",
    successHex = "%s %s.",
    unableToChange = "No se pudo cambiar %s a %s!",
	disabledProperty = "Editar %s esta deshabilitado en este servidor!",

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
    successDelete = "Listo tú handling ha sido borrado!",


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
                textlabel = "¡Bienvenido al editor oficial de manejo de MTA! Este recurso te permite editar el manejo de cualquier vehículo del juego en tiempo real..\n"..
                            "Puedes guardar y cargar los Handlings personalizados que realices a través del menú 'Handling' situado en la parte superior derecha..\n"..
                            "Para más información sobre este editor de handling, visite nuestro changelog:\n",
                websitebox = "http://hedit.googlecode.com/",
                morelabel = "Gracias por preferir hedit!"
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
            syntax = { "String", "[DESCONOCIDO]" },
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
            options = { ["true"]="Activado",["false"]="Desactivado" }
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
            friendlyName = "Multiplicador de colision",
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
                    ["1"] = {"IS_VAN","Permite puertas dobles para la animación trasera."},
                    ["2"] = {"IS_BUS","El vehículo utilizara las paradas de autobús e intentará subir pasajeros."},
                    ["4"] = {"IS_LOW","El conductor y los pasajeros se sientan más bajos y reclinados."},
                    ["8"] = {"IS_BIG","Cambia la forma en que la IA conduce en las curvas."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","El capó y el maletero se abren en sentido contrario al normal."},
                    ["2"] = {"HANGING_BOOT","El maletero se abre por el borde superior."},
                    ["4"] = {"TAILGATE_BOOT","El maletero se abre por el borde inferior."},
                    ["8"] = {"NOSWING_BOOT","El maletero no abre."}
                },
                {
                    ["1"] = {"NO_DOORS","Se omiten las animaciones de abrir y cerrar puertas."},
                    ["2"] = {"TANDEM_SEATS","Dos personas utilizarán el asiento del pasajero delantero."},
                    ["4"] = {"SIT_IN_BOAT","Utiliza la animación del barco sentado en lugar de pie."},
                    ["8"] = {"CONVERTIBLE","Cambia el funcionamiento de las prostitutas y otros pequeños efectos."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Elimina todas las partículas de escape."},
                    ["2"] = {"DBL_EXHAUST","Añade una segunda partícula de escape en el lado opuesto a la primera."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Evita que el jugador utilice la vista trasera en modo primera persona."},
                    ["8"] = {"FORCE_DOOR_CHECK","Necesita un test."}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Las ruedas delanteras permanecen verticales al coche como en GTA 3."},
                    ["2"] = {"AXLE_F_SOLID","Las ruedas delanteras permanecen paralelas entre sí."},
                    ["4"] = {"AXLE_F_MCPHERSON","Las ruedas delanteras se inclinan como en GTA Vice City."},
                    ["8"] = {"AXLE_F_REVERSE","Invierte la inclinación de las ruedas cuando se utiliza la suspensión AXLE_F_MCPHERSON."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Las ruedas traseras permanecen verticales al coche como en GTA 3."},
                    ["2"] = {"AXLE_R_SOLID","Las ruedas traseras permanecen paralelas entre sí."},
                    ["4"] = {"AXLE_R_MCPHERSON","Las ruedas traseras se inclinan como en GTA Vice City."},
                    ["8"] = {"AXLE_R_REVERSE","Invierte la inclinación de las ruedas cuando se utiliza la suspensión AXLE_R_MCPHERSON."}
                },
                {
                    ["1"] = {"IS_BIKE","Utilizar ajustes de handlings adicionales en la sección de motos."},
                    ["2"] = {"IS_HELI","Utilizar ajustes de manejo adicionales en la sección de vuelo."},
                    ["4"] = {"IS_PLANE","Utilizar ajustes de manejo adicionales en la sección de vuelo."},
                    ["8"] = {"IS_BOAT","Utilizar ajustes de manejo adicionales en la sección de vuelo."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","Necesita un test."},
                    ["2"] = {"DOUBLE_RWHEELS","Coloca una segunda instancia de cada rueda trasera junto a la normal."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","Necesita un test."},
                    ["8"] = {"IS_HATCHBACK","Necesita un test."}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Extras de handling",
            information = "Caracteristicas especiales de prestaciones.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Aumenta la potencia del motor en los arranques y mejora la subida de montañas."},
                    ["2"] = {"2G_BOOST","Da más potencia al motor a regímenes ligeramente superiores."},
                    ["4"] = {"NPC_ANTI_ROLL","No hay balanceo de la carrocería cuando la conducen personajes de la IA."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Menos probabilidades de girarse cuando lo conducen personajes de IA."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Desactiva el efecto de freno de mano."},
                    ["2"] = {"STEER_REARWHEELS","Las ruedas traseras dirigen en lugar de las delanteras."},
                    ["4"] = {"HB_REARWHEEL_STEER","El freno de mano hace que las ruedas traseras giren igual que las delanteras, como el monster truck"},
                    ["8"] = {"ALT_STEER_OPT","Necesita un test."}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Ruedas delanteras mas estrechas."},
                    ["2"] = {"WHEEL_F_NARROW","Ruedas delanteras estrechas."},
                    ["4"] = {"WHEEL_F_WIDE","Ruedas delanteras anchas."},
                    ["8"] = {"WHEEL_F_WIDE2","Ruedas delanteras mas anchas."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Ruedas traseras mas estrechas."},
                    ["2"] = {"WHEEL_R_NARROW","Ruedas traseras estrechas."},
                    ["4"] = {"WHEEL_R_WIDE","Ruedas traseras anchas."},
                    ["8"] = {"WHEEL_R_WIDE2","Ruedas traseras mas anchas."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","Necesita un test."},
                    ["2"] = {"HYDRAULIC_INST","El vehiculo obtendra un hidraulico cuando spawnea."},
                    ["4"] = {"HYDRAULIC_NONE","El sistema hidraulico no puede ser instalado."},
                    ["8"] = {"NOS_INST","El vehiculo obtendra nitro cuando spawne."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","El vehículo funcionará mejor en superficies sueltas como la tierra."},
                    ["2"] = {"OFFROAD_ABILITY2","El vehículo funcionará mejor en superficies blandas como la arena."},
                    ["4"] = {"HALOGEN_LIGHTS","Hace que los faros sean más brillantes y azules."},
                    ["8"] = {"PROC_REARWHEEL_1ST","Necesita un test."}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Impide que el vehículo supere la velocidad máxima."},
                    ["2"] = {"LOW_RIDER","Permite modificar el vehículo en los talleres de Loco Low Co."},
                    ["4"] = {"STREET_RACER","Cuando está establecido, el vehículo sólo puede modificarse en los ángulos del paso de rueda."},
                    ["8"] = {"UNDEFINED","Ningun efecto."}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Permite que la carrocería se mueva de lado a lado sobre la suspensión."},
                    ["2"] = {"UNDEFINED","Ningun efecto."},
                    ["4"] = {"UNDEFINED","Ningun efecto."},
                    ["8"] = {"UNDEFINED","Ningun efecto."}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Luces",
            information = "Establece el tipo de luces delanteras que tendrá su vehículo.",
            syntax = { "Integer", "" },
            options = { ["0"]="Largas",["1"]="Pequeñas",["2"]="Grandes",["3"]="Altas" }
        },
        ["tailLight"] = {
            friendlyName = "Luces Traseras",
            information = "Establece el tipo de luces traseras que tendrá su vehículo.",
            syntax = { "Integer", "" },
            options = { ["0"]="Largas",["1"]="Pequeñas",["2"]="Grandes",["3"]="Altas" }
        },
        ["animGroup"] = {
            friendlyName = "Grupo de Animacion",
            information = "Establece el grupo de animación que tu ped utilizará para su vehículo.",
            syntax = { "Integer", "" }
        }
    }
}
