guiLanguage.german = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Handling-Editor v"..HVER,

    restrictedPassenger = "Sie dürfen den Handling-Editor als Passagier nicht verwenden.",
    needVehicle = "Sie müssen ein Fahrzeug fahren, um den Handling-Editor zu verwenden!",
    needLogin = "Sie müssen eingeloggt sein, um dieses Menü zu sehen.",
    needAdmin = "Sie müssen als Administrator eingeloggt sein, um auf dieses Menü zuzugreifen.",
    accessDenied = "Sie haben nicht die erforderlichen Berechtigungen, um auf dieses Menü zuzugreifen.",
    invalidView = "Dieses Menü existiert nicht!",
    disabledView = "Dieses Menü wurde deaktiviert.",

    sameValue = "Der %s ist bereits so!",
    exceedLimits = "Der Wert bei %s überschreitet das Limit. [%s]!",
    cantSameValue = "%s darf nicht dasselbe sein wie %s!",
    needNumber = "Sie müssen eine Zahl verwenden!",
    unsupportedProperty = "%s ist keine unterstützte Eigenschaft.",
    successRegular = "%s auf %s gesetzt.",
    successHex = "%s %s.",
    unableToChange = "Es ist nicht möglich, %s auf %s zu setzen!",
    disabledProperty = "Das Bearbeiten von %s ist auf diesem Server deaktiviert!",

    resetted = "Die Fahreinstellungen des Fahrzeugs wurden erfolgreich zurückgesetzt!",
    loaded = "Ihre Fahreinstellungen wurden erfolgreich geladen!",
    imported = "Die Fahreinstellungen wurden erfolgreich importiert!",
    invalidImport = "Import fehlgeschlagen. Die angegebenen Fahreinstellungen sind ungültig!",
    invalidSave = "Bitte geben Sie einen gültigen Namen und eine Beschreibung ein, um die Fahreinstellungen dieses Fahrzeugs zu speichern!",

    confirmReplace = "Möchten Sie die vorhandene Speicherung wirklich überschreiben?",
    confirmLoad = "Möchten Sie diese Fahreinstellungen wirklich laden? Alle ungespeicherten Änderungen gehen verloren!",
    confirmDelete = "Möchten Sie diese Fahreinstellungen wirklich löschen?",
    confirmReset = "Möchten Sie Ihre Fahreinstellungen wirklich zurücksetzen? Alle ungespeicherten Änderungen gehen verloren!",
    confirmImport = "Möchten Sie diesen Import wirklich durchführen? Alle ungespeicherten Änderungen gehen verloren!",

    successSave = "Ihre Fahreinstellungen wurden erfolgreich gespeichert!",
    successLoad = "Ihre Fahreinstellungen wurden erfolgreich geladen!",
    successDelete = "Ihre Fahreinstellungen wurden erfolgreich gelöscht!",

    wantTheSettings = "Möchten Sie diese Einstellungen wirklich anwenden? Der Handling-Editor wird neu gestartet.",

    vehicle = "Fahrzeug",
    unsaved = "Nicht gespeichert",

    clickToEdit = "Klicken, um zu bearbeiten, oder ziehen, um schnell anzupassen.",
    enterToSubmit = "Drücken Sie die Eingabetaste, um zu bestätigen.",
    clickToViewFullLog = "Klicken, um das vollständige Fahrzeugprotokoll anzuzeigen.",
    copiedToClipboard = "Die Fahreinstellungen wurden in die Zwischenablage kopiert!",

    special = {
    },

    --
    -- BUTTON / MENU STRINGS
    --

    --Warning level strings
    warningtitles = {
        info = "Information",
        question = "Frage",
        warning = "Warnung!",
        error = "Fehler!"
    },
    --Strings for the buttons at the top
    menubar = {
        handling = "Handling",
        tools = "Werkzeuge",
        extra = "Extra",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "Motor",
        body = "Karosserie",
        wheels = "Räder",
        appearance = "Aussehen",
        modelflags = "Modell\nFlags",
        handlingflags = "Handling\nFlags",
        dynamometer = "Dyno",
        undo = "<",
        redo = ">",
        save = "Speichern"
    },

    -- Strings for the various views of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "Motor",
            longname = "Motor-Einstellungen"
        },
        body = {
            shortname = "Karosserie",
            longname = "Karosserie-Einstellungen"
        },
        wheels = {
            shortname = "Räder",
            longname = "Radeinstellungen"
        },
        appearance = {
            shortname = "Aussehen",
            longname = "Aussehen-Einstellungen"
        },
        modelflags = {
            shortname = "Modell-Flags",
            longname = "Fahrzeug-Modell-Einstellungen"
        },
        handlingflags = {
            shortname = "Handling-Flags",
            longname = "Spezielle Fahreinstellungen"
        },
        dynamometer = {
            shortname = "Dyno",
            longname = "Dynamometer starten"
        },
        about = {
            shortname = "Über",
            longname = "Über den offiziellen Handling-Editor",
            itemtext = {
                textlabel = "Welcome to the official MTA handling editor! This resource allows you to edit the handling of any vehicle in-game in real time.\n\n"..
                            "You can save and load custom handlings you make through the 'Handling' menu in the top left corner.\n\n"..
                            "For more information about the handling editor - such as the official changelog - visit:",
                websitebox = "https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/hedit",
                morelabel = "\nThank you for choosing hedit!"
            }
        },
        undo = {
            shortname = "Rückgängig",
            longname = "Rückgängig",
            itemtext = {
                textlabel = "Etwas ist schief gelaufen."
            }
        },
        redo = {
            shortname = "Wiederholen",
            longname = "Wiederholen",
            itemtext = {
                textlabel = "Etwas ist schief gelaufen."
            }
        },
        reset = {
            shortname = "Zurücksetzen",
            longname = "Die Fahreinstellungen dieses Fahrzeugs zurücksetzen.",
            itemtext = {
                label = "Basisfahrzeug:",
                combo = "-----",
                button = "Zurücksetzen"
            }
        },
        save = {
            shortname = "Speichern",
            longname = "Fahreinstellungen laden oder speichern.",
            itemtext = {
                nameLabel = "Name",
                descriptionLabel = "Beschreibung",
                saveButton = "Speichern",
                loadButton = "Laden",
                deleteButton = "Löschen",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "handling.cfg",
            longname = "In / aus handling.cfg-Format importieren/exportieren.",
            itemtext = {
                importButton = "Importieren",
                exportButton = "Exportieren und in Zwischenablage kopieren",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "Abrufen",
            longname = "Fahreinstellungen von einem anderen Spieler abrufen."
        },
        share = {
            shortname = "Teilen",
            longname = "Teilen Sie Ihre Fahreinstellungen mit einem anderen Spieler."
        },
        upload = {
            shortname = "Hochladen",
            longname = "Laden Sie Ihre Fahreinstellungen auf den Server hoch."
        },
        download = {
            shortname = "Herunterladen",
            longname = "Laden Sie einen Satz Fahreinstellungen vom Server herunter."
        },

        resourcesave = {
            shortname = "Ressourcen speichern",
            longname = "Speichern Sie Ihre Fahreinstellungen in einer Ressource."
        },
        resourceload = {
            shortname = "Ressource laden",
            longname = "Laden Sie Fahreinstellungen aus einer Ressource."
        },
        options = {
            shortname = "Optionen",
            longname = "Optionen",
            itemtext = {
                label_key = "Umschalttaste",
                label_cmd = "Umschaltbefehl:",
                label_template = "GUI-Vorlage:",
                label_language = "Sprache:",
                label_commode = "Massemittelpunkt-Bearbeitungsmodus:",
                checkbox_versionreset = "Versionsnummer von %s auf %s herabsetzen?",
                button_save = "Anwenden",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
                checkbox_lockwhenediting = "Fahrzeug beim Bearbeiten sperren?",
                checkbox_dragmeterEnabled = "Schnellanpassung verwenden"
            }
        },
        handlinglog = {
            shortname = "Handling-Protokoll",
            longname = "Protokoll der letzten Änderungen an Fahreinstellungen.",
            itemtext = {
                logpane = ""
            }
        },
    },


    handlingPropertyInformation = {
        ["identifier"] = {
            friendlyName = "Fahrzeugkennung",
            information = "Dies stellt die Fahrzeugkennung dar, die in handling.cfg verwendet werden soll.",
            syntax = { "String", "Verwenden Sie nur gültige Kennungen, sonst funktioniert der Export nicht." }
        },
        ["mass"] = {
            friendlyName = "Masse",
            information = "Ändert das Gewicht Ihres Fahrzeugs. (Kilogramm)",
            syntax = { "Float", "Ändern Sie zuerst 'turnMass', um ein Hüpfen zu vermeiden!" }
        },
        ["turnMass"] = {
            friendlyName = "Drehmasse",
            information = "Wird zur Berechnung von Bewegungseffekten verwendet.",
            syntax = { "Float", "Große Werte lassen Ihr Fahrzeug 'schweben' erscheinen." }
        },
        ["dragCoeff"] = {
            friendlyName = "Widerstandsmultiplikator",
            information = "Ändert den Widerstand gegen Bewegung.",
            syntax = { "Float", "Je größer der Wert, desto niedriger die Höchstgeschwindigkeit." }
        },
        ["centerOfMass"] = {
            friendlyName = "Schwerpunkt",
            information = "Ändert den Schwerkraftpunkt Ihres Fahrzeugs. (Meter)",
            syntax = { "Float", "Fahren Sie über einzelne Koordinaten, um Informationen anzuzeigen." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Schwerpunkt X",
            information = "Bestimmt die vordere-hintere Entfernung des Schwerpunkts. (Meter)",
            syntax = { "Float", "Hohe Werte sind vorne und niedrige Werte hinten." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Schwerpunkt Y",
            information = "Bestimmt die linke-rechte Entfernung des Schwerpunkts. (Meter)",
            syntax = { "Float", "Hohe Werte sind rechts und niedrige Werte links." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Schwerpunkt Z",
            information = "Bestimmt die Höhe des Schwerpunkts. (Meter)",
            syntax = { "Float", "Je größer der Wert, desto höher die Position des Punktes." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Prozent unter Wasser",
            information = "Ändert, wie tief Ihr Fahrzeug unter Wasser sein muss, bevor es zu schwimmen beginnt. (Prozent)",
            syntax = { "Integer", "Größere Werte lassen das Fahrzeug tiefer schwimmen." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Traktionsmultiplikator",
            information = "Ändert die Bodenhaftung beim Kurvenfahren.",
            syntax = { "Float", "Größere Werte erhöhen die Haftung zwischen Rädern und Oberfläche." }
        },
        ["tractionLoss"] = {
            friendlyName = "Traktionsverlust",
            information = "Ändert die Bodenhaftung beim Beschleunigen und Verzögern.",
            syntax = { "Float", "Größere Werte lassen das Fahrzeug Kurven besser schneiden." }
        },
        ["tractionBias"] = {
            friendlyName = "Traktionsverteilung",
            information = "Ändert, wo die Haftung Ihrer Räder zugewiesen wird.",
            syntax = { "Float", "Größere Werte verschieben die Verteilung nach vorne." }
        },
        ["numberOfGears"] = {
            friendlyName = "Anzahl der Gänge",
            information = "Ändert die maximale Anzahl der Gänge Ihres Fahrzeugs.",
            syntax = { "Integer", "Beeinflusst nicht die Höchstgeschwindigkeit oder Beschleunigung." }
        },
        ["maxVelocity"] = {
            friendlyName = "Maximale Geschwindigkeit",
            information = "Ändert die Höchstgeschwindigkeit Ihres Fahrzeugs. (km/h)",
            syntax = { "Float", "Dieser Wert wird von anderen Eigenschaften beeinflusst." }
        },
        ["engineAcceleration"] = {
            friendlyName = "Beschleunigung",
            information = "Ändert die Beschleunigung Ihres Fahrzeugs. (MS^2)",
            syntax = { "Float", "Größere Werte erhöhen die Beschleunigungsrate." }
        },
        ["engineInertia"] = {
            friendlyName = "Trägheit",
            information = "Glättet oder verschärft die Beschleunigungskurve.",
            syntax = { "Float", "Größere Werte machen die Kurve glatter." }
        },
        ["driveType"] = {
            friendlyName = "Antriebstyp",
            information = "Ändert, welche Räder beim Fahren verwendet werden.",
            syntax = { "String", "Die Auswahl von 'Alle Räder' macht das Fahrzeug leichter kontrollierbar." },
            options = { ["f"]="Vorderräder", ["r"]="Hinterräder", ["4"]="Alle Räder" }
        },
        ["engineType"] = {
            friendlyName = "Motorart",
            information = "Ändert den Motortyp Ihres Fahrzeugs.",
            syntax = { "String", "Die Wirkung dieser Eigenschaft ist unbekannt." },
            options = { ["p"]="Benzin", ["d"]="Diesel", ["e"]="Elektro" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Bremsverzögerung",
            information = "Ändert die Verzögerung Ihres Fahrzeugs. (MS^2)",
            syntax = { "Float", "Größere Werte bewirken stärkere Bremsung, können jedoch zu Rutschgefahr führen." }
        },
        ["brakeBias"] = {
            friendlyName = "Bremsverteilung",
            information = "Ändert die Hauptposition der Bremsen.",
            syntax = { "Float", "Größere Werte verschieben die Verteilung nach vorne." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "ABS für Ihr Fahrzeug aktivieren oder deaktivieren.",
            syntax = { "Bool", "Diese Eigenschaft hat keine Auswirkung auf Ihr Fahrzeug." },
            options = { ["true"]="Aktiviert", ["false"]="Deaktiviert" }
        },
        ["steeringLock"] = {
            friendlyName = "Lenkwinkel",
            information = "Ändert den maximalen Lenkwinkel Ihres Fahrzeugs.",
            syntax = { "Float", "Kleinere Winkel erhöhen die Geschwindigkeit des Fahrzeugs." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Federungskraft",
            information = "Die Wirkung dieser Eigenschaft ist unbekannt.",
            syntax = { "Float", "Die Syntax dieser Eigenschaft ist unbekannt." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Federungsdämpfung",
            information = "Die Wirkung dieser Eigenschaft ist unbekannt.",
            syntax = { "Float", "Die Syntax dieser Eigenschaft ist unbekannt." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Hochgeschwindigkeitsdämpfung",
            information = "Ändert die Steifigkeit der Federung und ermöglicht schnelleres Fahren.",
            syntax = { "Float", "Die Wirkung dieser Eigenschaft wurde nicht getestet." }
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Obere Begrenzung der Federung",
            information = "Oberste Bewegung der Räder. (Meter)",
            syntax = { "Float", "Die Wirkung dieser Eigenschaft wurde nicht getestet." }
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Untere Begrenzung der Federung",
            information = "Die Höhe der Federung.",
            syntax = { "Float", "Niedrigere Werte machen das Fahrzeug höher." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Federungsverteilung",
            information = "Ändert, wo die Federkraft vorwiegend hinfließt.",
            syntax = { "Float", "Größere Werte verschieben die Verteilung nach vorne." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Anti-Tauchen-Multiplikator",
            information = "Ändert das Wanken des Körpers beim Bremsen und Beschleunigen.",
            syntax = { "Float", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Sitzabstand",
            information = "Ändert den Abstand des Sitzes zur Tür.",
            syntax = { "Float", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Kollisionsschaden-Multiplikator",
            information = "Ändert den Schaden bei Kollisionen.",
            syntax = { "Float", "" }
        },
        ["monetary"] = {
            friendlyName = "Geldwert",
            information = "Ändert den genauen Preis des Fahrzeugs.",
            syntax = { "Integer", "Diese Eigenschaft wird in Multi Theft Auto nicht verwendet." }
        },
        
        ["modelFlags"] = {
            friendlyName = "Modell-Flags",
            information = "Umlegbare spezielle Animationen des Fahrzeugs.", -- HIER "nerede gösteriliyor?"
            syntax = { "Hexadezimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Animiert die hinteren Doppeltüren."},
                    ["2"] = {"IS_BUS","Lässt das Fahrzeug an Bushaltestellen anhalten und Passagiere einsteigen."}, -- HIER "Möglicherweise teehee"
                    ["4"] = {"IS_LOW","Lässt Fahrer und Passagiere tiefer sitzen und sich zurücklehnen."},
                    ["8"] = {"IS_BIG","Ändert, wie die KI um Ecken fährt."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","Lässt die Motorhaube und den Kofferraum in die entgegengesetzte Richtung öffnen."},
                    ["2"] = {"HANGING_BOOT","Lässt den Kofferraum von der oberen Kante öffnen."},
                    ["4"] = {"TAILGATE_BOOT","Lässt den Kofferraum von der unteren Kante öffnen."},
                    ["8"] = {"NOSWING_BOOT","Lässt den Kofferraum geschlossen bleiben."}
                },
                {
                    ["1"] = {"NO_DOORS","Animationen zum Schließen und Öffnen der Türen werden übersprungen."},
                    ["2"] = {"TANDEM_SEATS","Ermöglicht zwei Personen, den vorderen Beifahrersitz zu benutzen."},
                    ["4"] = {"SIT_IN_BOAT","Lässt Passagiere die sitzende Bootsanimation anstelle des Stehens verwenden."},
                    ["8"] = {"CONVERTIBLE","Ändert, wie Prostituierte operieren und andere kleine Effekte."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Entfernt alle Abgaspartikel."},
                    ["2"] = {"DBL_EXHAUST","Fügt einen zweiten Abgaspartikel auf der gegenüberliegenden Seite des ersten Auspuffrohrs hinzu."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Verhindert, dass der Spieler in der Ego-Perspektive den Rückblick nutzt."},
                    ["8"] = {"FORCE_DOOR_CHECK","Die Wirkung dieses Flags wurde nicht getestet."} -- HIER {ungetestet}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Lässt die Vorderräder vertikal zum Auto bleiben (wie in GTA 3)."},
                    ["2"] = {"AXLE_F_SOLID","Lässt die Vorderräder parallel zueinander bleiben."},
                    ["4"] = {"AXLE_F_MCPHERSON","Lässt die Vorderräder kippen (wie in GTA Vice City)."},
                    ["8"] = {"AXLE_F_REVERSE","Lässt die Vorderräder in die entgegengesetzte Richtung kippen."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Lässt die Hinterräder vertikal zum Auto bleiben (wie in GTA 3)."},
                    ["2"] = {"AXLE_R_SOLID","Lässt die Hinterräder parallel zueinander bleiben."},
                    ["4"] = {"AXLE_R_MCPHERSON","Lässt die Hinterräder kippen (wie in GTA Vice City)."},
                    ["8"] = {"AXLE_R_REVERSE","Lässt die Hinterräder in die entgegengesetzte Richtung kippen."}
                },
                {
                    ["1"] = {"IS_BIKE","Verwendet die zusätzlichen Einstellungen im Motorradbereich."},
                    ["2"] = {"IS_HELI","Verwendet die zusätzlichen Einstellungen im Hubschrauberbereich."},
                    ["4"] = {"IS_PLANE","Verwendet die zusätzlichen Einstellungen im Flugbereich."},
                    ["8"] = {"IS_BOAT","Verwendet die zusätzlichen Einstellungen im Bootsbereich."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","Die Wirkung dieses Flags wurde nicht getestet."}, -- HIER {ungetestet}
                    ["2"] = {"DOUBLE_RWHEELS","Platziert ein zweites Hinterrad neben dem normalen."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","Die Wirkung dieses Flags wurde nicht getestet."}, -- HIER {ungetestet}
                    ["8"] = {"IS_HATCHBACK","Die Wirkung dieses Flags wurde nicht getestet."} -- HIER {ungetestet}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Handhabungs-Flags",
            information = "Spezielle Leistungsmerkmale.",
            syntax = { "Hexadezimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Gibt dem Motor mehr Leistung für den Standstart (für besseres Bergauffahren)."},
                    ["2"] = {"2G_BOOST","Gibt dem Motor mehr Leistung bei leicht höheren Geschwindigkeiten."},
                    ["4"] = {"NPC_ANTI_ROLL","Deaktiviert das Karosserie-Kippen, wenn es von KI-Fahrern gesteuert wird."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Verringert die Wahrscheinlichkeit, dass das Fahrzeug beim Fahren durch KI-Fahrer ins Schleudern gerät."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Deaktiviert den Handbremseneffekt."},
                    ["2"] = {"STEER_REARWHEELS","Hinterräder steuern statt der Vorderräder (wie ein Gabelstapler)."},
                    ["4"] = {"HB_REARWHEEL_STEER","Lässt die Handbremse die Hinterräder genauso steuern wie die Vorderräder (wie ein Monstertruck)."},
                    ["8"] = {"ALT_STEER_OPT","Die Wirkung dieses Flags wurde nicht getestet."} -- HIER {ungetestet}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Verursacht sehr schmale Vorderräder."},
                    ["2"] = {"WHEEL_F_NARROW","Verursacht schmale Vorderräder."},
                    ["4"] = {"WHEEL_F_WIDE","Verursacht breite Vorderräder."},
                    ["8"] = {"WHEEL_F_WIDE2","Verursacht sehr breite Vorderräder."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Verursacht sehr schmale Hinterräder."},
                    ["2"] = {"WHEEL_R_NARROW","Verursacht schmale Hinterräder."},
                    ["4"] = {"WHEEL_R_WIDE","Verursacht breite Hinterräder."},
                    ["8"] = {"WHEEL_R_WIDE2","Verursacht sehr breite Hinterräder."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","Die Wirkung dieses Flags wurde nicht getestet."}, -- HIER {ungetestet}
                    ["2"] = {"HYDRAULIC_INST","Lässt das Fahrzeug mit hydraulischen Anlagen spawnen."},
                    ["4"] = {"HYDRAULIC_NONE","Deaktiviert die Installation von Hydraulik."},
                    ["8"] = {"NOS_INST","Lässt das Fahrzeug mit Nitro installiert spawnen."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Lässt das Fahrzeug auf lockeren Oberflächen (wie Erde) besser abschneiden."},
                    ["2"] = {"OFFROAD_ABILITY2","Lässt das Fahrzeug auf weichen Oberflächen (wie Sand) besser abschneiden."},
                    ["4"] = {"HALOGEN_LIGHTS","Lässt die Scheinwerfer heller und 'blauer' erscheinen."},
                    ["8"] = {"PROC_REARWHEEL_1ST","Die Wirkung dieses Flags wurde nicht getestet."} -- HIER {ungetestet}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Verhindert, dass das Fahrzeug schneller als die Höchstgeschwindigkeit fährt."},
                    ["2"] = {"LOW_RIDER","Ermöglicht das Modifizieren des Fahrzeugs in den Loco Low Co Shops."},
                    ["4"] = {"STREET_RACER","Lässt das Fahrzeug nur in den Wheel Arch Angels modifizieren."},
                    ["8"] = {"",""}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Lässt die Karosserie des Autos von Seite zu Seite auf der Federung bewegen."},
                    ["2"] = {"",""},
                    ["4"] = {"",""},
                    ["8"] = {"",""}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Scheinwerfer",
            information = "Ändert die Art der Frontlichter Ihres Fahrzeugs.",
            syntax = { "Ganzzahl", "" },
            options = { ["0"]="Lang",["1"]="Klein",["2"]="Groß",["3"]="Hoch" }
        },
        ["tailLight"] = {
            friendlyName = "Rücklichter",
            information = "Ändert die Art der Rücklichter Ihres Fahrzeugs.",
            syntax = { "Ganzzahl", "" },
            options = { ["0"]="Lang",["1"]="Klein",["2"]="Groß",["3"]="Hoch" }
        },
        ["animGroup"] = {
            friendlyName = "Animationsgruppe",
            information = "Ändert die Animationsgruppe, die Peds während der Fahrt im Fahrzeug verwenden.",
            syntax = { "Ganzzahl", "" }
        }
    }
}
