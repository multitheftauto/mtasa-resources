guiLanguage.hungarian = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Handling Szerkesztő v" .. HVER,

    restrictedPassenger = "A handling szerkesztőt nem használhatod utasként.",
    needVehicle = "A handling szerkesztőt csak vezetés közben használhatod!",
    needLogin = "A handling szerkesztő használatához előbb jelentkezz be.",
    needAdmin = "A handling szerkesztő használatához adminisztrátori jogosultság szükséges.",
    accessDenied = "A handling szerkesztő használatához nincs jogosultságod.",
    invalidView = "Ez a menü nem létezik!",
    disabledView = "Ez a menü ki lett kapcsolva.",

    sameValue = "%s már ugyanazzal az értékkel rendelkezik!",
    exceedLimits = "%s túllépi a limitet. [%s]!",
    cantSameValue = "%s nem lehet ugyanaz mint %s!",
    needNumber = "Egy számot kell megadnod!",
    unsupportedProperty = "%s egy nem támogatott tulajdonság.",
    successRegular = "%s beállítva %s értékre.",
    successHex = "%s %s.",
    unableToChange = "Nem sikerült beállítani a %s tulajdonságot %s értékre!",
	disabledProperty = "A %s tulajdonság szerkesztése ki van kapcsolva ezen a szerveren!",

    resetted = "Sikeresen visszaállítottad a jármű handling-jét!",
    loaded = "Sikeresen betöltötted a handling beállításaidat!",
    imported = "Sikeresen beimportáltad a handling beállításokat!",
    invalidImport = "Sikerertelen importálás! A megadott adat nem érvényes.",
    invalidSave = "Adj meg egy érvényes nevet és leírást a handling mentéséhez.",

    confirmReplace = "Biztosan felülírod az előző mentést?",
    confirmLoad = "Biztosan betöltöd ezeket a handling beállításokat? Minden el nem mentett tevékenység elveszik!",
    confirmDelete = "Bizton kitörlöd ezeket a handling beállításokat?",
    confirmReset = "Biztosan vissza szeretnéd állítani a handling beállításokat? Minden el nem mentett tevékenység elveszik!",
    confirmImport = "Biztosan importálni szeretnéd ezt a handling beállítást? Minden el nem mentett tevékenység elveszik!",

    successSave = "Sikeresen elmentetted a handling beállításaidat!",
    successLoad = "Sikeresen betöltötted a handling beállításaidat!",
    successDelete = "Sikeresen kitörölted a handling beállításaidat!",

    wantTheSettings = "Biztosan szeretnéd ezt a beállítást módosítani? A handling szerkesztő újra fog indulni.",

    vehicle = "Jármű",
    unsaved = "El nem mentett",

    clickToEdit = "Kattints vagy húzd a szerkesztéshez.",
    enterToSubmit = "Nyomd meg az 'enter' billentyűt az elfogadáshoz.",
    clickToViewFullLog = "Nyomd meg a teljes napló megtekintéséhez.",
    copiedToClipboard = "A handling beállítások sikeresen vágólapra másolva!",

    special = {
    },

    --
    -- BUTTON / MENU STRINGS
    --

    --Warning level strings
    warningtitles = {
        info = "Információ",
        question = "Kérdés",
        warning = "Figyelmeztetés!",
        error = "Hiba!"
    },
    --Strings for the buttons at the top
    menubar = {
        handling = "Handling",
        tools = "Eszközök",
        extra = "Egyéb",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "Motor",
        body = "Karossz.",
        wheels = "Kerekek",
        appearance = "Megjelenés",
        modelflags = "Modell\nTulajd.",
        handlingflags = "Handling\nTulajd.",
        dynamometer = "Dyno",
        undo = "<",
        redo = ">",
        save = "Mentések"
    },

    -- Strings for the various views of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "Motor",
            longname = "Motor Beállítások"
        },
        body = {
            shortname = "Karosszéria",
            longname = "Karosszéria Beállítások"
        },
        wheels = {
            shortname = "Kerekek",
            longname = "Kerék Beállítások"
        },
        appearance = {
            shortname = "Megjelenés",
            longname = "Megjelenés Beállítások"
        },
        modelflags = {
            shortname = "Modell Tulajdonságok",
            longname = "Jármű Modell Tulajdonságok"
        },
        handlingflags = {
            shortname = "Handling Tulajdonságok",
            longname = "Speciális Handling Tulajdonságok"
        },
        dynamometer = {
            shortname = "Dyno",
            longname = "Dynamométer elindítása"
        },
        about = {
            shortname = "Rólunk",
            longname = "Az eredeti handling szerkesztőről",
            itemtext = {
                textlabel = "Üdvözlünk az eredeti MTA handling szerkesztőben! Ez a resource lehetőséget ad a járművek irányításának szerkesztésére valós időben.\n\n"..
                            "Elmentheted és betöltheted a saját handling beállításaidat az ablak bal felső sarkában.\n\n"..
                            "További információkért a handling szerkesztőről - lásd:",
                websitebox = "https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/hedit",
                morelabel = "\nKöszönjük, hogy a hedit-et választottad!"
            }
        },
        undo = {
            shortname = "Visszavonás",
            longname = "Visszavonás",
            itemtext = {
                textlabel = "Valami hiba történt."
            }
        },
        redo = {
            shortname = "Újra",
            longname = "Újra",
            itemtext = {
                textlabel = "Valami hiba történt."
            }
        },
        reset = {
            shortname = "Visszaállítás",
            longname = "E jármű teljes handling beállításainak visszaállítása.",
            itemtext = {
                label = "Alap Jármű:",
                combo = "-----",
                button = "Visszaállítás"
            }
        },
        save = {
            shortname = "Mentések",
            longname = "Töltsd be vagy mentsd el a handling beállításaidat.",
            itemtext = {
                nameLabel = "Név",
                descriptionLabel = "Leírás",
                saveButton = "Exportálás",
                loadButton = "Importálás",
                deleteButton = "Törlés",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "handling.cfg",
            longname = "Importálj vagy exportálj handling.cfg formátumban.",
            itemtext = {
                importButton = "Importálás",
                exportButton = "Exportálás és másolás a vágólapra",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "Lekérés",
            longname = "Kérdezd le egy másik játékos handling beállításait."
        },
        share = {
            shortname = "Megosztás",
            longname = "Oszd meg a handling beállításaid egy másik játékossal."
        },
        upload = {
            shortname = "Feltöltés",
            longname = "Töltsd fel a handling beállításaidat erre a szerverre."
        },
        download = {
            shortname = "Letöltés",
            longname = "Töltsd le a handling beállításokat erről a szerverről."
        },

        resourcesave = {
            shortname = "Resource mentés",
            longname = "Mentsd el a handling beállításaid egy resource-ba."
        },
        resourceload = {
            shortname = "Resource betöltés",
            longname = "Töltsd be a handling beállításaid egy resource-ból."
        },
        options = {
            shortname = "Beállítások",
            longname = "Beállítások",
            itemtext = {
                label_key = "Megnyitási Gomb",
                label_cmd = "Megnyitási Parancs:",
                label_template = "Kezelőfelület Minta:",
                label_language = "Nyelv:",
                label_commode = "Tömeg középpont szerkesztése:",
                checkbox_versionreset = "Szeretnéd visszaállítani a verziót %s-ról %s-ra?",
                button_save = "Mentés",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
                checkbox_lockwhenediting = "Jármű bezárása szerkesztés közben",
                checkbox_dragmeterEnabled = "Gyors beállítás használata"
            }
        },
        handlinglog = {
            shortname = "Handling Napló",
            longname = "Napló az elmúlt néhány handling beállítás szerkesztéséről.",
            itemtext = {
                logpane = ""
            }
        },
    },


    handlingPropertyInformation = {
        ["identifier"] = {
            friendlyName = "Jármű Azonosító",
            information = "Reprezentálja a jármű azonosítóját a handling.cfg fájlban.",
            syntax = { "String", "Csak érvényes azonosítót adj meg, hogy elkerüld a hibákat." }
        },
        ["mass"] = {
            friendlyName = "Tömeg",
            information = "Megváltoztatja a jármű súlyát. (kilogramm)",
            syntax = { "Float", "Először változtasd meg a fordulási tömeget a pattogás elkerülése végett!" }
        },
        ["turnMass"] = {
            friendlyName = "Fordulási tömeg",
            information = "Mozgási hatások kiszámítására szolgál.",
            syntax = { "Float", "Nagy értékek esetén a jármű 'lebegőnek' tűnhet." }
        },
        ["dragCoeff"] = {
            friendlyName = "Ellenállás szorzó",
            information = "Megváltoztatja a mozgással szembeni ellenállást.",
            syntax = { "Float", "Minél nagyobb az érték, annál kisebb a végsebesség." }
        },
        ["centerOfMass"] = {
            friendlyName = "Tömegközéppont",
            information = "Megváltoztatja a jármű súlypontját. (méter)",
            syntax = { "Float", "További információért vidd az egérmutatót a koordinátákra." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Tömegközéppont (X)",
            information = "A tömegközéppont elülső-hátsó távolságát adja meg. (méter)",
            syntax = { "Float", "A magas értékek előre, az alacsony értékek hátra billennek." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Tömegközéppont (Y)",
            information = "A tömegközéppont bal-jobb távolságát adja meg. (méter)",
            syntax = { "Float", "A magas értékek jobbra, az alacsony értékek balra billennek." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Tömegközéppont (Z)",
            information = "A tömegközéppont magasságát adja meg. (méter)",
            syntax = { "Float", "Minél nagyobb az érték, annál magasabbra kerül a súlypont." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Merülés",
            information = "Megváltoztatja, hogy a járművet milyen mélyen kell víz alá meríteni, mielőtt lebegni kezd. (százalék)",
            syntax = { "Integer", "A nagyobb értékeknél a jármű mélyebben kezd lebegni." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Tapadási szorzó",
            information = "Megváltoztatja a jármű tapadását a talajhoz kanyarodás közben.",
            syntax = { "Float", "A nagyobb értékek növelik a kerekek és a felület közötti tapadást." }
        },
        ["tractionLoss"] = {
            friendlyName = "Tapadás elvesztése",
            information = "Megváltoztatja a jármű tapadását gyorsítás és lassítás közben.",
            syntax = { "Float", "A nagyobb értékek jobb kanyarokat tesznek lehetővé járművedben." }
        },
        ["tractionBias"] = {
            friendlyName = "Tapadási középpont",
            information = "Megváltoztatja, hogy a tapadás melyik kerekekre hat jobban.",
            syntax = { "Float", "A nagyobb értékek az autó eleje felé tolják a tapadást." }
        },
        ["numberOfGears"] = {
            friendlyName = "Sebességek száma",
            information = "Megváltoztatja a jármű maximum sebességeinek számát.",
            syntax = { "Integer", "Nem befolyásolja a jármű végsebességét vagy gyorsulását." }
        },
        ["maxVelocity"] = {
            friendlyName = "Végsebesség",
            information = "Módosítja a jármű maximális sebességét. (km/h)",
            syntax = { "Float", "Ezt az értéket más tulajdonságok is befolyásolják." }
        },
        ["engineAcceleration"] = {
            friendlyName = "Gyorsulás",
            information = "Módosítja a jármű gyorsulását. (MS^2)",
            syntax = { "Float", "A nagyobb értékek növelik a jármű gyorsulásának sebességét." }
        },
        ["engineInertia"] = {
            friendlyName = "Tehetetlenség",
            information = "Kisimítja vagy élesíti a gyorsulási görbét.",
            syntax = { "Float", "A nagyobb értékek simábbá teszik a gyorsulást." }
        },
        ["driveType"] = {
            friendlyName = "Meghajtás",
            information = "Megváltoztatja, hogy mely kerekeket használja a meghajtáshoz.",
            syntax = { "String", "Az „Összes kerék” választásával a jármű könnyebben irányítható." },
            options = { ["f"]="Első kerekek",["r"]="Hátsó kerekek",["4"]="Összes kerék" }
        },
        ["engineType"] = {
            friendlyName = "Motor típus",
            information = "Megváltoztatja a jármű motorjának típusát.",
            syntax = { "String", "Ennek a tulajdonságnak a hatása ismeretlen." },
            options = { ["p"]="Benzin",["d"]="Dízel",["e"]="Elektromos" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Fék hatékonysága",
            information = "Módosítja a jármű lassítását. (MS^2)",
            syntax = { "Float", "Nagyobb értékek esetén a jármű erősebben fékez, de megcsúszhat, ha a tapadása túl alacsony." }
        },
        ["brakeBias"] = {
            friendlyName = "Fékközéppont",
            information = "Módosítja a fékek hatásának az elhelyezését.",
            syntax = { "Float", "A nagyobb értékek a fékek hatását a jármű eleje felé tolják." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Be vagy kikapcsolja az ABS-t a járművön.",
            syntax = { "Bool", "Ez a tulajdonság nincs hatással a járműre." },
            options = { ["true"]="Bekapcsolva",["false"]="Kikapcsolva" }
        },
        ["steeringLock"] = {
            friendlyName = "Kormányzási szög",
            information = "Megváltoztatja a jármű maximális kormányzási szögét.",
            syntax = { "Float", "Minél alacsonyabb a kormányzási szög, annál gyorsabban kanyarodik a jármű." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Felfüggesztési erő szint",
            information = "Ennek a tulajdonságnak a hatása ismeretlen.",
            syntax = { "Float", "Ennek a tulajdonságnak a hatása ismeretlen." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Felfüggesztés csillapítás",
            information = "Ennek a tulajdonságnak a hatása ismeretlen.",
            syntax = { "Float", "Ennek a tulajdonságnak a hatása ismeretlen." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Felfüggesztés nagy sebességű csillapítása",
            information = "Megváltoztatja a felfüggesztés merevségét, ezáltal gyorsabban tudsz vezetni.",
            syntax = { "Float", "Ennek a tulajdonságnak a hatása nem teszelt." } -- HERE {UNTESTED}
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Felfüggesztés felső határa",
            information = "A felfüggesztés legfelső állása. (méter)",
            syntax = { "Float", "Ennek a tulajdonságnak a hatása nem tesztelt." } -- HERE {UNTESTED}
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Felfüggesztés alsó határa",
            information = "A felfüggesztés magassága.",
            syntax = { "Float", "Az alacsonyabb értékek magasabbá teszik a járműved." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Felfüggesztés középpontja",
            information = "Megváltoztatja, hogy a felfüggesztés ereje a jármű melyik részére megy",
            syntax = { "Float", "A nagyobb értékek a felfüggesztés erejét a jármű eleje felé tolják." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Felfüggesztés 'Anti Dive' szorzó",
            information = "Módosítja a karosszéria dőlésszögét fékezés és gyorsítás közben.",
            syntax = { "Float", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Ülés eltolási távolság",
            information = "Módosítja az ülés távolságát a jármű ajtajától.",
            syntax = { "Float", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Ütközéskár-szorzó",
            information = "Megváltoztatja az ütközésekből adódó károk mennyiségét.",
            syntax = { "Float", "" }
        },
        ["monetary"] = {
            friendlyName = "Pénzbeli érték",
            information = "Módosítja a jármű pontos árát.",
            syntax = { "Integer", "Ez a beállítás a Multi Theft Auto-ban nem használható." }
        },
        ["modelFlags"] = {
            friendlyName = "Modell tulajdonságok",
            information = "Változtatható speciális animációk.", -- HERE "where is this shown?"
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Animálja a hátsó dupla ajtókat."},
                    ["2"] = {"IS_BUS","A jármű megáll a buszmegállókban és megvárja az utasokat."}, -- HERE "Possible teehee"
                    ["4"] = {"IS_LOW","Arra készteti a vezetőket és az utasokat, hogy lejjebb üljenek és hátradőljenek."},
                    ["8"] = {"IS_BIG","Megváltoztatja az AI kanyarokban való mozgását."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","A motorháztető és a csomagtartó az ellenkező irányba nyíljon ki."},
                    ["2"] = {"HANGING_BOOT","A csomagtartó a felső széléről nyílik."},
                    ["4"] = {"TAILGATE_BOOT","A csomagtartót az alsó szélétől nyitja ki."},
                    ["8"] = {"NOSWING_BOOT","A csomagtartó zárva marad."}
                },
                {
                    ["1"] = {"NO_DOORS","Az ajtók zárásával és nyitásával kapcsolatos animációk elhagyása."},
                    ["2"] = {"TANDEM_SEATS","Lehetővé teszi, hogy két személy használja az első utasülést."},
                    ["4"] = {"SIT_IN_BOAT","Arra készteti a ped-eket, hogy az ülés animációt használják az állás helyett hajókban."},
                    ["8"] = {"CONVERTIBLE","Megváltoztatja a beszállás működését és egyéb kis hatásokat."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Eltávolítja az összes kipufogógáz effektet."},
                    ["2"] = {"DBL_EXHAUST","Hozzáad egy második kipufogógáz effektet az első kipufogócső ellentétes oldalán."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Megakadályozza, hogy a játékos a hátsó mező nézetét használja a first-person módban."},
                    ["8"] = {"FORCE_DOOR_CHECK","Ezen beállítás által okozott hatás ismeretlen."} -- HERE {untested}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Az első kerekeket függőlegesen tartja az autóhoz képest. (mint a GTA III-ban."},
                    ["2"] = {"AXLE_F_SOLID","Az első kerekek párhuzamosan maradnak egymással."},
                    ["4"] = {"AXLE_F_MCPHERSON","Az első kerekek bedőlnek (mint a GTA Vice City-ben)."},
                    ["8"] = {"AXLE_F_REVERSE","Az első kerekek ellenkező irányba billenését okozza."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","A hátsó kerekeket függőlegesen tartja az autóhoz képest (mint a GTA III-ban)."},
                    ["2"] = {"AXLE_R_SOLID","A hátsó kerekek párhuzamosan maradnak egymással."},
                    ["4"] = {"AXLE_R_MCPHERSON","A hátsó kerekek megdőlését okozza (mint a GTA Vice City-ben)."},
                    ["8"] = {"AXLE_R_REVERSE","A hátsó kerekek ellenkező irányba billenését okozza."}
                },
                {
                    ["1"] = {"IS_BIKE","Használja az extra beállításokat a kerékpárok kategóriában."},
                    ["2"] = {"IS_HELI","Használja az extra beállításokat a helikopter kategóriában."},
                    ["4"] = {"IS_PLANE","Használja az extra beállításokat a repülő kategóriában."},
                    ["8"] = {"IS_BOAT","Használja az extra beállításokat a hajó kategóriában."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","Ezen beállítás által okozott hatás ismeretlen."}, -- HERE {untested}
                    ["2"] = {"DOUBLE_RWHEELS","Egy második hátsó kereket helyez a normál mellé."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","Ezen beállítás által okozott hatás ismeretlen."}, -- HERE {untested}
                    ["8"] = {"IS_HATCHBACK","Ezen beállítás által okozott hatás ismeretlen."} -- HERE {untested}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Handling tulajdonságok",
            information = "Speciális teljesítmény tulajdonságok.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Nagyobb teljesítményt ad a motornak az állóindításokhoz (a jobb hegymászás érdekében)."},
                    ["2"] = {"2G_BOOST","Valamivel nagyobb fordulatszámon nagyobb teljesítményt ad a motornak."},
                    ["4"] = {"NPC_ANTI_ROLL","Letiltja a felborulást, ha AI vezeti a járművet."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Csökkenti annak valószínűségét, hogy a jármű kereke kipördüljön, amikor AI vezeti azt."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Letiltja a kéziféket."},
                    ["2"] = {"STEER_REARWHEELS","A hátsó kerekek kormányoznak az első kerekek helyett (mint egy targonca)."},
                    ["4"] = {"HB_REARWHEEL_STEER","A kézifék hatására a hátsó kerekek éppúgy kormányozhatók, mint az elsők (mint egy monster truck)."},
                    ["8"] = {"ALT_STEER_OPT","Ezen beállítás által okozott hatás ismeretlen."} -- HERE {untested}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Nagyon keskeny első kerekeket okoz."},
                    ["2"] = {"WHEEL_F_NARROW","Keskeny első kerekeket okoz"},
                    ["4"] = {"WHEEL_F_WIDE","Széles első kerekeket okoz"},
                    ["8"] = {"WHEEL_F_WIDE2","Nagyon széles első kerekeket okoz"}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Nagyon keskeny hátsó kerekeket okoz."},
                    ["2"] = {"WHEEL_F_NARROW","Keskeny hátsó kerekeket okoz"},
                    ["4"] = {"WHEEL_F_WIDE","Széles hátsó kerekeket okoz"},
                    ["8"] = {"WHEEL_F_WIDE2","Nagyon széles hátsó kerekeket okoz"}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","Ezen beállítás által okozott hatás ismeretlen."}, -- HERE {untested}
                    ["2"] = {"HYDRAULIC_INST","A jármű beépített hidraulikával spawn-ol."},
                    ["4"] = {"HYDRAULIC_NONE","Letiltja a hidraulika beépítését."},
                    ["8"] = {"NOS_INST","A jármű beépíett nitro-val spawn-ol."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Jobban teljesít a jármű laza felületeken (például föld)."},
                    ["2"] = {"OFFROAD_ABILITY2","Jobban teljesít a jármű puha felületeken (például homokon)."},
                    ["4"] = {"HALOGEN_LIGHTS","Világosabbá és „kékebbé” teszi a fényszórókat."},
                    ["8"] = {"PROC_REARWHEEL_1ST","Ezen beállítás által okozott hatás ismeretlen."} -- HERE {untested}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Megakadályozza, hogy a jármű a maximális sebességnél gyorsabban haladjon."},
                    ["2"] = {"LOW_RIDER","Lehetővé teszi a jármű módosítását a Loco Low Co üzletekben."},
                    ["4"] = {"STREET_RACER","A jármű csak a Wheel Arch Angelsnél módosítható."},
                    ["8"] = {"",""}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Lehetővé teszi, hogy az autó karosszériája egyik oldalról a másikra mozogjon a felfüggesztésen."},
                    ["2"] = {"",""},
                    ["4"] = {"",""},
                    ["8"] = {"",""}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Fényszórók",
            information = "Megváltoztatja a jármű fényszórójának típusát.",
            syntax = { "Integer", "" },
            options = { ["0"]="Hosszú",["1"]="Kicsi",["2"]="Nagy",["3"]="Magas" }
        },
        ["tailLight"] = {
            friendlyName = "Hátsó lámpák",
            information = "Megváltoztatja a jármű hátsó lámpáinak típusát.",
            syntax = { "Integer", "" },
            options = { ["0"]="Hosszú",["1"]="Kicsi",["2"]="Nagy",["3"]="Magas" }
        },
        ["animGroup"] = {
            friendlyName = "Animációs Csoport",
            information = "Módosítja azt az animációs csoportot, amelyet a ped-ek a járművön belül használnak.",
            syntax = { "Integer", "" }
        }
    }
}
