guiLanguage.polish = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Handling Editor v"..HVER,
    
    restrictedPassenger = "Nie mozesz uzywac edytora jako pasazer.",
    needVehicle = "Musisz byc w pojezdzie aby uzywac edytor!",
    needLogin = "Musisz byc zalogowany aby zobaczyc to menu.",
    needAdmin = "Musisz byc zalogowany jako administrator, aby uzyskac dostep do tego menu.",
    accessDenied = "Nie masz wystarczajacych uprawnien, aby uzyskac dostep do tego menu.",
    invalidView = "To menu nie istnieje!",
    disabledView = "To menu zostalo wylaczone.",
 
    sameValue = "The %s is already that!",
    exceedLimits = "Value used at %s exceeds the limit. [%s]!",
    cantSameValue = "%s may not the same as %s!",
    needNumber = "You must use a number!",
    unsupportedProperty = "%s is not a supported property.",
    successRegular = "%s set to %s.",
    successHex = "%s %s.",
    unableToChange = "Unable to set the %s to %s!",
	disabledProperty = "Editing %s is disabled on this server!",
    
    resetted = "Pomyslnie zresetowano ustawienia kierowania pojazdu!",
    loaded = "Pomyslnie zaladowano ustawienia obslugi!",
    imported = "Pomyslnie improtowano ustawienia kierowania!",
    invalidImport = "Importowanie nie powiodlo sie. Dane obslugi sa nieprawidlowe!",
    invalidSave = "Prosze podac poprawna nazwe i opis, aby zapisac dane obslugi tego pojazdu!",
    
    confirmReplace = "Czy na pewno chcesz zastapic istniejacy zapis?",
    confirmLoad = "Czy na pewno chcesz, aby zaladowac te ustawienia? Wszystkie niezapisane zmiany zostana utracone!",
    confirmDelete = "Czy na pewno chcesz usunac te ustawienia?",
    confirmReset = "Czy na pewno chcesz zresetowac twoje ustawienia? Wszystkie niezapisane zmiany zostana utracone!",
    confirmImport = "Czy na pewno chcesz zaimportowac te ustawienia? Wszystkie niezapisane zmiany zostana utracone!",

    successSave = "Pomyslnie zapisano twoje ustawienia",
    successLoad = "Pomyslnie wczytano twoje ustawienia!",

    wantTheSettings = "Czy na pewno chcesz zastosowac te ustawienia? Edytor uruchomi sie ponownie.",
    
    vehicle = "Pojazd",
    unsaved = "Niezapisany",
    
    clickToEdit = "Kliknij, aby edytowac lub przeciagnij do szybkiej edycji.",
    enterToSubmit = "Wcisnij enter, aby potwierdzic.",
    clickToViewFullLog = "Kliknij aby zobaczyc pelny dziennik pojazdu.",
    copiedToClipboard = "Ustawienia obslugi zostaly skopiowane do schowka!",
    
    special = {
    },
    
    --
    -- BUTTON / MENU STRINGS
    --
    
    --Warning level strings
    warningtitles = {
        info = "Informacja",
        question = "Pytanie",
        warning = "Uwaga!",
        error = "Blad!"
    },
    --Strings for the buttons at the top
    menubar = {
        handling = "Handling",
        tools = "Narzedzia",
        extra = "Extra",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "Silnik",
        body = "Nadwozie",
        wheels = "Kola",
        appearance = "Zamek",
        modelflags = "Model\nFlags",
        handlingflags = "Handling\nFlags",
        dynamometer = "Dyno",
        undo = "<",
        redo = ">",
        save = "Zapisane"
    },
    
    -- Strings for the various views of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "Silnik",
            longname = "Ustawienia Silnika"
        },
        body = {
            shortname = "Nadwozie",
            longname = "Ustawienia Nadwozia"
        },
        wheels = {
            shortname = "Kola",
            longname = "Ustawienia kol"
        },
        appearance = {
            shortname = "Wyglad",
            longname = "Ustawienia Wygladu"
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
            shortname = "Informacje",
            longname = "O edytorze handlingow",
            itemtext = {
                textlabel = "",
                websitebox = "",
                morelabel = ""
            }
        },
        undo = {
            shortname = "Rozwin",
            longname = "Rozwin",
            itemtext = {
                textlabel = "Cos poszlo nie tak."
            }
        },
        redo = {
            shortname = "Zwin",
            longname = "Zwin",
            itemtext = {
                textlabel = "Cos poszlo nie tak."
            }
        },
        reset = {
            shortname = "Reset",
            longname = "Zresetuj swoje ustawienia handlingu.",
            itemtext = {
                label = "Pojazd podstawowy:",
                combo = "-----",
                button = "Reset"
            }
        },
        save = {
            shortname = "Zapisane",
            longname = "Wczytaj lub zapisz swoje ustawienia.",
            itemtext = {
                nameLabel = "Nazwa",
                descriptionLabel = "Opis",
                saveButton = "Zapisz",
                loadButton = "Wczytaj",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "Import/Eksport",
            longname = "Import lub Eksport do/z handling.cfg format.",
            itemtext = {
                importButton = "Import",
                exportButton = "Eksportuj i wyslij na tablice",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "Wez",
            longname = "Wez ustawienia handlingu od innego gracza."
        },
        share = {
            shortname = "Udostepnij",
            longname = "Podziel sie swoim handlingiem z innym graczem."
        },
        upload = {
            shortname = "Przeslij",
            longname = "Przeslij swoj handling na serwer."
        },
        download = {
            shortname = "Pobierz",
            longname = "Pobierz handlingi z serwera."
        },
        
        resourcesave = {
            shortname = "Zapis zasobow",
            longname = "Zapisz swoje handlingi do zasobu."
        },
        resourceload = {
            shortname = "Odczyt zasobow",
            longname = "Wczytaj handlingi z zasobu."
        },
        options = {
            shortname = "Opcje",
            longname = "Opcje",
            itemtext = {
                label_key = "Przycisk",
                label_cmd = "Komenda:",
                label_template = "Szablon GUI:",
                label_language = "Jezyk:",
                label_commode = "Srodek masy, tryb edycji:",
                checkbox_versionreset = "Downgrade my version number from %s to %s?",
                button_save = "Potwierdz",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
				checkbox_lockwhenediting = "Zablokuj pojazd, kiedy edytujesz?"
            }
        },
        handlinglog = {
            shortname = "Handling Log",
            longname = "Zaloguj z ostatnich zmian ustawiez obslugi.",
            itemtext = {
                logpane = ""
            }
        },
    },
    

    handlingPropertyInformation = { 
        ["identifier"] = {
            friendlyName = "Identyfikator pojazdu",
            information = "To reprezentuje identyfikator pojazdu, ktory ma byc uzywany w Handling.cfg.",
            syntax = { "String", "uzywac tylko prawidlowe identyfikatory, inaczej eksport nie bedzie dzialac." }
        },
        ["mass"] = {
            friendlyName = "Masa",
            information = "Zmiana masy pojazdu. (kg)",
            syntax = { "Float", "Pamietaj, aby zmienić 'mase skretu', aby uniknac odbijania!" }
        },
        ["turnMass"] = {
            friendlyName = "Masa skretu",
            information = "Wykorzystywane do obliczania efektow ruchu.",
            syntax = { "Float", "Duże wartości sprawia, ze Twój pojazd pojawi się 'floaty'." }
        },
        ["dragCoeff"] = {
            friendlyName = "Opory",
            information = "Zmienia opór ruchu.",
            syntax = { "Float", "Im wieksza wartosc, tym mniejsza predkosc." }
        },
        ["centerOfMass"] = {
            friendlyName = "Srodek masy",
            information = "Zmienia punkt ciezkosci samochodu. (w metrach)",
            syntax = { "Float", "Najedz na poszczegolnych wspolrzednych dla informacji." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Srodek masy X",
            information = "Przypisuje odleglosc srodka masy przod-tyl. (w metrach)",
            syntax = { "Float", "Wysokie wartosci sa do przodu, a niskie do tylu." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Srodek masy Y",
            information = "Przypisuje odleglosc srodka masy prawo-lewo. (w metrach)",
            syntax = { "Float", "Wysokie wartosci sa na prawo, a niskie na lewo." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Srodek masy Z",
            information = "Przypisuje wysokosc srodka masy. (w metrach)",
            syntax = { "Float", "Wieksza wartosc - wyższa pozycja punktu." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Procent Zanuzenia",
            information = "Zmiany, jak gleboko pojazd nalezy zanurzac w wodzie zanim zacznie sie unosic. (w procentach)",
            syntax = { "Integer", "Wieksza wartosc uczyni, ze Twoj samochod zacznie sie unosic na glebszym poziomie." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Mnoznik trakcji",
            information = "Zmienia wysokosc uchwytu jaka pojazd bedzie mial na ziemie podczas pokonywania zakretow.",
            syntax = { "Float", "Wyzsze wartosci zwiekszaja przyczepnosc pomiedzy kolami a powierzchnia." }
        },
        ["tractionLoss"] = {
            friendlyName = "Utrata trakcji",
            information = "Zmienia przyczepnosc pojazdu podczas przyspieszania - bedzie miał i ma tendencję spadkowa.",
            syntax = { "Float", "Wieksza wartosc sprawi, że pojazd bedzie mial lepsza przyczepnosc" }
        },
        ["tractionBias"] = {
            friendlyName = "Odchylenie trakcji",
            information = "Zmiany ktore sprawia, ze wszystkie uchwyty z kołami będzia przypisany do.",
            syntax = { "Float", "Wieksze wartosci rusza nastawienie w kierunku przodu pojazdu." }
        },
        ["numberOfGears"] = {
            friendlyName = "Liczba biegow",
            information = "Zmienia maksymalna liczbe biegow jakie pojazd moze miec.",
            syntax = { "Integer", "Nie wplywa na predkosc lub przyspieszenie pojazdu." }
        },
        ["maxVelocity"] = {
            friendlyName = "Prędkość maksymalna",
            information = "Zmienia maksymalna predkosc pojazdu. (km / h)",
            syntax = { "Float", "Wartosc ta zalezy od innych wlasciwosci." }
        },
        ["engineAcceleration"] = {
            friendlyName = "Przyspieszenie",
            information = "Zmienia przyspieszanie twojego pojazdu. (MS^2)",
            syntax = { "Float", "Wieksze wartosci zwieksza szybkosc z jaka pojazd przyspiesza." }
        },
        ["engineInertia"] = {
            friendlyName = "Bezwladnosc",
            information = "Wygladza i wyostrza krzywa przyspieszenia.",
            syntax = { "Float", "Wieksze wartosci, aby krzywa przyspieszenia byla gladsza." }
        },
        ["driveType"] = {
            friendlyName = "Rodzaj napedu",
            information = "Zmiany, ktore beda stosowaly kola podczas jazdy.",
            syntax = { "String", "Wybor 'Wszystkie kola' spowoduje, ze pojazd nie jest latwiejszy do kontrolowania." },
            options = { ["f"]="Przednie kola",["r"]="Tylnie kola",["4"]="Wszystkie kola" }
        },
        ["engineType"] = {
            friendlyName = "Rodzaj silnika",
            information = "Zmienia rodzaj silnika dla twojego pojazdu.",
            syntax = { "String", "Efekt jaki powoduje ta wlasciwosc jest nieznany" },
            options = { ["p"]="Benzyna",["d"]="Diesel",["e"]="Elektryczny" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Zwalnianie hamulca",
            information = "Zmienia wyhamowanie pojazdu. (MS ^ 2)",
            syntax = { "Float", "Wieksza wartosc spowoduje, ze hamulec bedzie silniejszy, ale moze wymknac sie spod kontroli, jesli trakcja jest zbyt niska." }
        },
        ["brakeBias"] = {
            friendlyName = "Odchylenie hamulca",
            information = "Zmienia glowną pozycje hamulcow.",
            syntax = { "Float", "Wyzsze wartosci przesuna docisk w kierunku przedniej czesci pojazdu." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Wlaczya lub wylazca ABS w pojezdzie.",
            syntax = { "Bool", "Obiekt ten nie ma wplywu na twoj samochod." },
            options = { ["true"]="Wlaczony",["false"]="Wylaczony" }
        },
        ["steeringLock"] = {
            friendlyName = "Blokada kierownicy",
            information = "Zmienia maksymalny kat skretu kol jaki pojazd moze miec.",
            syntax = { "Float", "Mniejszy kat kierownicy - szybszy samochod." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Wysokosc zawieszenia",
            information = "Efekt jaki powoduje ta wlasciwosc jest nieznany.",
            syntax = { "Float", "Skladnia tej wlasnosci jest nieznana." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Tlumienie zawieszenia",
            information = "Efekt jaki powoduje ta wlasciwosc jest nieznany.",
            syntax = { "Float", "Skladnia tej wlasnosci jest nieznana." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Tlumienie zawieszenia duza predkosc",
            information = "Zmienia sztywnosc zawieszenia, co moze doprowadzic do szybszej jazdy",
            syntax = { "Float", "Efekt tej wlasnosci nie zostal sprawdzony" } -- HERE {UNTESTED}
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Gorna granica Zawieszenia",
            information = "Najwyzszy ruch kol. (w metrach)",
            syntax = { "Float", "Efekt tej wlasnosci nie zostal sprawdzony" } -- HERE {UNTESTED}
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Dolna granica Zawieszenia",
            information = "Wysokosc twojego zawieszenia.",
            syntax = { "Float", "Nizsze wartosci uczynia Twoj samochod wyzszym." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Ukos zawieszania",
            information = "Zmiany, gdzie większosc energii zawieszenia bedza oddane.",
            syntax = { "Float", "Wyzsze wartosci przesunie docisku w kierunku przedniej czesci pojazdu." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Mnoznik Anty-'nurkowania' zawieszenia ",
            information = "Zmienia 'bujanie' nadwozia podczas hamowania i przyspieszania.",
            syntax = { "Float", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Odleglosc siedzenia",
            information = "Zmienia odleglosc siedzenia od drzwi twojego pojazdu.",
            syntax = { "Float", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Mnozik uszkodzen kolizji",
            information = "Zmienia uszkodzenia pojazdu otrzymane przy kolizji.",
            syntax = { "Float", "" }
        },
        ["monetary"] = {
            friendlyName = "Wartosc pieniezna",
            information = "Zmienia dokładną cene pojazdu.",
            syntax = { "Integer", "Ta wlasciwosc nie jest uzywana w ramach Multi Theft Auto." }
        },
        ["modelFlags"] = {
            friendlyName = "Model Flags",
            information = "Przelacza zdolne, specjalne animacje pojazdu.", -- HERE "where is this shown?"
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Animuje tylne drzwi dwuskrzydlowe."},
                    ["2"] = {"IS_BUS","Powoduje zatrzymanie pojazdu na przystankach autobusowych i jedzenia pasazerów."}, -- HERE "Possible teehee"
                    ["4"] = {"IS_LOW","Powoduje, ze kierowcy i pasazerowie siedza nizej i do tylu."},
                    ["8"] = {"IS_BIG","Zmienia sposob, w ktory wszyscy jezdza na zakretach."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","Powoduje otwieranie maski i bagaznika w przeciwnym kierunku."},
                    ["2"] = {"HANGING_BOOT","Powoduje otwieranie bagarnika od gory."},
                    ["4"] = {"TAILGATE_BOOT","Powoduje otwieranie bagarnika od dolu."},
                    ["8"] = {"NOSWING_BOOT","Powoduje, ze bagaznik pozostaje zamkniety."}
                },
                {
                    ["1"] = {"NO_DOORS","Animacje obejmujace zamykanie i otwieranie drzwi, sa pomijane."},
                    ["2"] = {"TANDEM_SEATS","Umozliwia dwom osobom skorzystanie z jednego fotela pasazera."},
                    ["4"] = {"SIT_IN_BOAT","Causes peds to use the seated boat animation instead of standing."},
                    ["8"] = {"CONVERTIBLE","Zmiany w jaki sposob dzialaja prostytutki i inne male efekty."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Powoduje usuniecie wszystkich czasteczek spalin."},
                    ["2"] = {"DBL_EXHAUST","Dodaje druga rure ukladu wydechowego po przeciwnej stronie w stosunku do pierwszej rury."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Chroni gracza od użycia lusterka wstecznego w trybie pierwszej osoby."},
                    ["8"] = {"FORCE_DOOR_CHECK","Efekt tego znacznika nie zostal sprawdzony."} -- HERE {untested}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Powoduje, ze przednie kola pozostana w pionie do samochodu (jak w GTA 3)."},
                    ["2"] = {"AXLE_F_SOLID","Powoduje, ze przednie kola pozostana rownolegle do siebie."},
                    ["4"] = {"AXLE_F_MCPHERSON","Causes the front wheels to tilt (like GTA Vice City)."},
                    ["8"] = {"AXLE_F_REVERSE","Powoduje, ze przednie kola przechylaja sie w przeciwnym kierunku."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Powoduje, ze tylnie kola pozostana w pionie do samochodu (jak w GTA 3)."},
                    ["2"] = {"AXLE_R_SOLID","Powoduje, ze tylnie kola pozostana rownolegle do siebie."},
                    ["4"] = {"AXLE_R_MCPHERSON","Causes rear wheels to tilt (like GTA Vice City)."},
                    ["8"] = {"AXLE_R_REVERSE","Powoduje, ze tylnie kola przechylaja sie w przeciwnym kierunku."}
                },
                {
                    ["1"] = {"IS_BIKE","Uzywa dodatkowych ustawien w sekcji rowery."},
                    ["2"] = {"IS_HELI","Uzywa dodatkowych ustawien w sekcji helikoptery."},
                    ["4"] = {"IS_PLANE","Uzywa dodatkowych ustawien w sekcji samoloty."},
                    ["8"] = {"IS_BOAT","Uzywa dodatkowych ustawien w sekcji lodzie."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","Efekt tego znacznika nie zostal sprawdzony."}, -- HERE {untested}
                    ["2"] = {"DOUBLE_RWHEELS","Stawia drugie tylne koło obok normalnego."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","Efekt tego znacznika nie zostal sprawdzony."}, -- HERE {untested}
                    ["8"] = {"IS_HATCHBACK","Efekt tego znacznika nie zostal sprawdzony."} -- HERE {untested}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Handling Flags",
            information = "Specjalne funkcje wydajnosci.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Daje wiecej mocy dla silnika stojacego na starty (dla lepszych podjazdow pod gorke)."},
                    ["2"] = {"2G_BOOST","Daje wiecej mocy silnika na nieco wyzszych predkosciach."},
                    ["4"] = {"NPC_ANTI_ROLL","Wylacza przechyly nadwozia podczas napedzany znakami AI."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Reduces the likelness of the vehicle to spin out when driven by AI characters."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Wylacza dzialanie hamulca ręcznego."},
                    ["2"] = {"STEER_REARWHEELS","Kola tylne steruja zamiast kol przednich (jak wozek widlowy)."},
                    ["4"] = {"HB_REARWHEEL_STEER","Powoduje, ze naciskajac hamulec reczny tylnie kola skrecaja oprocz przednich (jak monster truck)."},
                    ["8"] = {"ALT_STEER_OPT","Efekt tego znacznika nie zostal sprawdzony."} -- HERE {untested}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Powoduje bardzo wąskie przednie kola."},
                    ["2"] = {"WHEEL_F_NARROW","Powoduje wąskie przednie kola."},
                    ["4"] = {"WHEEL_F_WIDE","Powoduje szerokie przednie kola."},
                    ["8"] = {"WHEEL_F_WIDE2","Powoduje bardzo szerokie przednie koła."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Powoduje bardzo wąskie tylnie kola."},
                    ["2"] = {"WHEEL_R_NARROW","Powoduje waskie tylnie kola."},
                    ["4"] = {"WHEEL_R_WIDE","Powoduje szerokie tylnie kola."},
                    ["8"] = {"WHEEL_R_WIDE2","Powoduje bardzo szerokie tylnie kola."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","Efekt tego znacznika nie zostal sprawdzony."}, -- HERE {untested}
                    ["2"] = {"HYDRAULIC_INST","Causes the vehicle to spawn with hydraulics installed."},
                    ["4"] = {"HYDRAULIC_NONE","Disables the installation of hydraulics."},
                    ["8"] = {"NOS_INST","Causes the vehicle the vehicle to spawn with nitrous installed."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Powoduje, ze pojazd jezdzi lepiej na luznych powierzchniach (jak brud)."},
                    ["2"] = {"OFFROAD_ABILITY2","Powoduje, ze pojazd jezdzi lepiej na miekkich powierzchniach (jak piasek)."},
                    ["4"] = {"HALOGEN_LIGHTS","Sprawia, ze reflektory są jaśniejsze i 'bardziej niebieskie'."},
                    ["8"] = {"PROC_REARWHEEL_1ST","Efekt tego znacznika nie zostal sprawdzony."} -- HERE {untested}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Zapobiega jechanie pojazdu szybciej niz predkosc maksymalna."},
                    ["2"] = {"LOW_RIDER","Pozwala pojazdowi na modyfikacji w sklepach Loco Low CO."},
                    ["4"] = {"STREET_RACER","Causes vehicle to only be modifiable at the Wheel Arch Angels."},
                    ["8"] = {"",""}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Pozwala karoserii poruszac sie  z boku na bok jak zawieszenie."},
                    ["2"] = {"",""},
                    ["4"] = {"",""},
                    ["8"] = {"",""}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Reflektory przednie",
            information = "Zmien typ przednich swiatel jakie samochod bedzie miec.",
            syntax = { "Integer", "" },
            options = { ["0"]="Dlugie",["1"]="Male",["2"]="Duze",["3"]="Wysokie" }
        },
        ["tailLight"] = {
            friendlyName = "Swiatła tylne",
            information = "Zmienia typ Tylnych swiatel jakie pojazd bedzie miec.",
            syntax = { "Integer", "" },
            options = { ["0"]="Dlugie",["1"]="Male",["2"]="Duze",["3"]="Wysokie" }
        },
        ["animGroup"] = {
            friendlyName = "Grupa Animacji",
            information = "Zmienia animacje jaka beda uzywac pasazerowie w pojezdzie.",
            syntax = { "Integer", "" }
        }
    }
}