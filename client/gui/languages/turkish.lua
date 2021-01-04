guiLanguage.turkish = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Mta San Turkiye Handling Menüsü "..HVER,
    
    restrictedPassenger = "Bir yolcu olarak ele editörü kullanmak için izin verilmez.",
    needVehicle = "Sen taşıma editörü kullanmak için bir araç sürüş olmalı!",
    needLogin = "Bu menüyü görmek için giriş yapmalısınız.",
    needAdmin = "Bu menüye erişmek için yönetici olarak oturum açmanız gerekir.",
    accessDenied = "Bu menüye erişmek için gerekli izinlere sahip değilsiniz.",
    invalidView = "Bu menü yok!",
    disabledView = "Bu menü devre dışı bırakıldı.",
 
    sameValue = "% S zaten olduğunu!",
    exceedLimits = "% S kullanılan değer sınırını aşıyor. [%s]!",
    cantSameValue = "%s aynı olmayabilir %s!",
    needNumber = "Bir numara kullanmanız gerekir!",
    unsupportedProperty = "%s desteklenen bir özellik değildir.",
    successRegular = "%s ayarlanır %s.",
    successHex = "%s %s.",
    unableToChange = "Için% s ayarlamak için açılamıyor %s!",
	disabledProperty = "Düzenleme% s bu sunucuda devre dışı!",
    
    resetted = "Başarıyla aracın kullanımı ayarlarını sıfırlamak!",
    loaded = "Başarıyla işleme ayarlarını yüklenen!",
    imported = "Başarıyla kullanımı ayarlarını ithal!",
    invalidImport = "İthalat başarısız oldu. Eğer verilen taşıma veri geçersiz!",
    invalidSave = "Bu aracın kullanım verilerini kaydetmek için geçerli bir ad ve açıklama veriniz!",
    
    confirmReplace = "Eğer mevcut kurtarmak üzerine yazmak istiyorum emin misiniz?",
    confirmLoad = "Bu işleme ayarları yüklemek istiyorum emin misiniz? Kaydedilmemiş değişiklikler kaybolacak!",
    confirmDelete = "Eğer bu işleme ayarlarını silmek istiyorum emin misiniz? ",
    confirmReset = "Eğer işleme sıfırlamak istiyorum emin misiniz? Kaydedilmemiş değişiklikler kaybolacak!",
    confirmImport = "Bu işleme almak istiyorum emin misiniz? Kaydedilmemiş değişiklikler kaybolacak!",

    successSave = "Başarıyla işleme ayarlarını kurtardı!",
    successLoad = "Başarıyla senin kullanımı ayarlarını yüklenen!",

    wantTheSettings = "Bu ayarları uygulamak istiyorum emin misiniz? Taşıma editörü yeniden başlar.",
    
    vehicle = "Vehicle",
    unsaved = "Unsaved",
    
    clickToEdit = "Düzenlemek veya hızlı ayarlamak için sürükleyin tıklayın.",
    enterToSubmit = "Onaylamak için tuşuna basın girin.",
    clickToViewFullLog = "Komple araç günlüğünü görüntülemek için tıklayın.",
    copiedToClipboard = "Taşıma ayarlar panoya kopyalanan!",
    
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
        engine = "motor",
        body = "vücut",
        wheels = "Tekerlekler",
        appearance = "bakın",
        modelflags = "model\nBayraklar",
        handlingflags = "kullanma\nBayraklar",
        dynamometer = "Dyno",
        undo = "<",
        redo = ">",
        save = "kaydet"
    },
    
    -- Strings for the various views of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "motor",
            longname = "motor Ayarları"
        },
        body = {
            shortname = "vücut",
            longname = "Vücut Ayarları"
        },
        wheels = {
            shortname = "Tekerlekler",
            longname = "tekerlek Ayarları"
        },
        appearance = {
            shortname = "görünüm",
            longname = "görünüm Ayarları"
        },
        modelflags = {
            shortname = "Model Bayraklar",
            longname = "araç Modeli Ayarları"
        },
        handlingflags = {
            shortname = "Bayraklar Taşıma",
            longname = "Özel Taşıma Ayarları"
        },
        dynamometer = {
            shortname = "Dyno",
            longname = "Başlangıç Dinamometre"
        },
        about = {
            shortname = "hakkında",
            longname = "Resmi işleme editörü Hakkında",
            itemtext = {
                textlabel = "Mta San Multiplayer Turkey Turkish Sistem.\n\n"..
                            "Turkish Turkey Turkiye \n\n"..
                            "Yapımcı: [K.R.@.L.]<3B@R!$<3",
                websitebox = "Facebook: https://www.facebook.com/TCTurkish",
                morelabel = "\nB@R!$"
            }
        },
        undo = {
            shortname = "Undo",
            longname = "Undo",
            itemtext = {
                textlabel = "Bir şeyler yanlış gitti."
            }
        },
        redo = {
            shortname = "Redo",
            longname = "Redo",
            itemtext = {
                textlabel = "Bir şeyler ters gitti."
            }
        },
        reset = {
            shortname = "ayarlamak",
            longname = "Bu aracın taşıma ayarlarını sıfırlayın.",
            itemtext = {
                label = "Baz Araç:",
                combo = "-----",
                button = "ayarlamak"
            }
        },
        save = {
            shortname = "kaydet",
            longname = "Yük veya taşıma ayarları kaydedin.",
            itemtext = {
                nameLabel = "isim",
                descriptionLabel = "tanım",
                saveButton = "kaydet",
                loadButton = "yükle",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "İthalat / İhracat",
            longname = "İthalat veya handling.cfg biçimi için / İhracat.",
            itemtext = {
                importButton = "ithalat",
                exportButton = "İhracat ve kopyalama panoyad",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "almak",
            longname = "Başka bir oyuncu Ayarları ele alın."
        },
        share = {
            shortname = "pay",
            longname = "Başka bir oyuncu ile işleme ayarlarını paylaşın."
        },
        upload = {
            shortname = "Yükle",
            longname = "Sunucuya taşıma ayarlarınızı yükleyin."
        },
        download = {
            shortname = "indir",
            longname = "Sunucudan ayarları ele bir dizi indirin."
        },
        
        resourcesave = {
            shortname = "kaydetmek Kaynak",
            longname = "Bir kaynak için taşıma kaydedin."
        },
        resourceload = {
            shortname = "Kaynak yükle",
            longname = "Bir kaynak bir taşıma yükleyin. "
        },
        options = {
            shortname = "Seçenekler",
            longname = "Seçenekler",
            itemtext = {
                label_key = "Geçiş Tuşu ",
                label_cmd = "geçiş Komutanlığı:",
                label_template = "GUI şablonu:",
                label_language = "Dil:",
                label_commode = "Kitle düzenleme moduna Of Merkezi:",
                checkbox_versionreset = "% S% s benim sürüm numarasını Düşürme?",
                button_save = "uygulamak",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
				checkbox_lockwhenediting = "Düzenleme ApplyLock araç?"
            }
        },
        handlinglog = {
            shortname = "Oturum Taşıma",
            longname = "Taşıma ayarlarında son değişikliklerin yapın.",
            itemtext = {
                logpane = ""
            }
        },
    },
    

    handlingPropertyInformation = { 
        ["identifier"] = {
            friendlyName = "araç tanıtıcı",
            information = "Bu handling.cfg kullanılacak araç temsilcidir.",
            syntax = { "dizi", "Sadece aksi alışkanlık işi ihraç, geçerli tanımlayıcıları kullanın." }
        },
        ["mass"] = {
            friendlyName = "kitle",
            information = "Aracınızın ağırlığını değiştirir. (kilogram)",
            syntax = { "şamandıra", "Zıplayan önlemek için 'turnMass' ilk değiştirmek için unutmayın!" }
        },
        ["turnMass"] = {
            friendlyName = "kitle açın",
            information = "Hareket efektleri hesaplamak için kullanılır.",
            syntax = { "şamandıra", "Büyük değerler araç görünür hale getirecek 'floaty'." }
        },
        ["dragCoeff"] = {
            friendlyName = "Çarpan sürükleyin",
            information = "Harekete direnç değiştirir.",
            syntax = { "şamandıra", "Değeri daha düşük üst hız." }
        },
        ["centerOfMass"] = {
            friendlyName = "Kütle Merkezi",
            information = "Aracınızın yerçekimi noktasını değiştirir. (metre)",
            syntax = { "şamandıra", "Bilgi için bireysel koordinatlara üzerine gezdirin." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Kütle X geçin",
            information = "Kütle merkezinin ön-arka mesafe atar. (metre)",
            syntax = { "şamandıra", "Yüksek değerler ön ve düşük değerler geri vardır." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Kitle Y Merkezi",
            information = "Kütle merkezinin sol-sağ mesafeyi atar. (metre)",
            syntax = { "şamandıra", "Yüksek değerler sağa ve düşük değerler sola vardır. " }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Kütle Merkezi Z",
            information = "Kütle merkezinin yüksekliğini tayin eder. (metre)",
            syntax = { "şamandıra", "Noktasının konumu yüksek değer daha." }
        },
        ["percentSubmerged"] = {
            friendlyName = "yüzde Batık",
            information = "O yüzer başlayacak önce aracınızın ihtiyacı kadar derin değişiklikler suya sokulmasına. (yüzde)",
            syntax = { "Integer", "Büyükşehir değerler aracınızın daha derin bir düzeyde yüzer başlar yapacaktır." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "çekiş Çarpan",
            information = "Viraj ederken yere aracınızı olacak kavrama miktarını değiştirir.",
            syntax = { "şamandıra", "Büyük değerler tekerlekler ve yüzey arasındaki kavrama artacak." }
        },
        ["tractionLoss"] = {
            friendlyName = "çekiş kaybı",
            information = "Araç hızlanma ve yavaşlama iken sahip olacak kavrama miktarını değiştirir.",
            syntax = { "şamandıra", "Büyükşehir değerler araç kesme köşeleri daha iyi yapacaktır." }
        },
        ["tractionBias"] = {
            friendlyName = "çekiş Önyargı",
            information = "Senin jantlar tüm kavrama tahsis edilecek değişiklikler.",
            syntax = { "şamandıra", "Büyükşehir değerler aracın önüne doğru önyargı hareket edecek." }
        },
        ["numberOfGears"] = {
            friendlyName = "Gears sayısı",
            information = "Aracınız olabilir dişli sayısını değiştirir.",
            syntax = { "Integer", "Aracınızın üst hız veya ivme etkilemez." }
        },
        ["maxVelocity"] = {
            friendlyName = "Maksimum Hız",
            information = "Aracınızın azami hızını değiştirir. (km/h)",
            syntax = { "Float", "Bu değer diğer özellikleri etkilenir." }
        },
        ["engineAcceleration"] = {
            friendlyName = "hızlanma",
            information = "Aracınızın ivme değiştirir. (MS^2)",
            syntax = { "Float", "Büyükşehir değerler aracın hıza oranını artıracaktır." }
        },
        ["engineInertia"] = {
            friendlyName = "uyuşukluk",
            information = "Düzgünleştirir veya hızlanma eğrisi keskinleştirir.",
            syntax = { "Float", "Büyükşehir değerler ivme eğrisi pürüzsüz hale." }
        },
        ["driveType"] = {
            friendlyName = "Drivetype",
            information = "Tekerlekler sürüş esnasında kullanılacak değişiklikler.",
            syntax = { "String", "'Tüm tekerlekleri' Seçimi kontrol etmek daha kolay olması aracın neden olacaktır." },
            options = { ["f"]="Front wheels",["r"]="Rear wheels",["4"]="All wheels" }
        },
        ["engineType"] = {
            friendlyName = "Enginetype",
            information = "Aracınız için motor tipini değiştirir.",
            syntax = { "String", "Bu özellik neden etkisi bilinmemektedir." },
            options = { ["p"]="Petrol",["d"]="Diesel",["e"]="Electric" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Brake Deceleration",
            information = "Aracınızın yavaşlama değiştirir. (MS^2)",
            syntax = { "Float", "Büyükşehir değerler daha güçlü fren aracı neden olur, ancak çekiş çok düşükse kayabilir." }
        },
        ["brakeBias"] = {
            friendlyName = "fren Önyargı",
            information = "Frenlerin ana pozisyonunu değiştirir.",
            syntax = { "Float", "Büyükşehir değerler aracın önüne doğru önyargı hareket edecek." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Etkinleştirin veya araç üzerinde ABS devre dışı bırakın.",
            syntax = { "Bool", "Bu özellik, aracınızın üzerinde hiçbir etkisi yoktur. " },
            options = { ["true"]="Enabled",["false"]="Disabled" }
        },
        ["steeringLock"] = {
            friendlyName = "direksiyon kilidi",
            information = "Aracınızın yönlendirmek maksimum açı değiştirir.",
            syntax = { "şamandıra", "Alt direksiyon açısı daha hızlı araç." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Süspansiyon Kuvvet Seviye",
            information = "Bu özellik neden etkisi bilinmemektedir.",
            syntax = { "şamandıra", "Bu özellik için sözdizimi bilinmemektedir." }
        },
        ["suspensionDamping"] = {
            friendlyName = "süspansiyon süspansiyon",
            information = "Bu özellik neden etkisi bilinmemektedir.",
            syntax = { "şamandıra", "Bu özellik için sözdizimi bilinmemektedir." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Süspansiyon Yüksek Hızlı Süspansiyong",
            information = "Eğer daha hızlı sürmek için neden, süspansiyon sertliğini değiştirir.",
            syntax = { "şamandıra", "Bu özellik neden etkileri test edilmemiştir." } -- HERE {UNTESTED}
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Süspansiyon Üst Sınırı",
            information = "Tekerleklerin en üst hareketi. (metre)",
            syntax = { "şamandıra", "Bu özellik neden etkileri test edilmemiştir." } -- HERE {UNTESTED}
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Süspansiyon Alt Sınırı",
            information = "Senin süspansiyon yüksekliği.",
            syntax = { "şamandıra", "Düşük değerler aracınızın daha yapacak. " }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "süspansiyon Önyargı",
            information = "Süspansiyon gücünün en gidecek değişiklikler.",
            syntax = { "şamandıra", "Büyükşehir değerler aracın önüne doğru önyargı hareket edecek." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Süspansiyon Anti-Dalış Çarpan",
            information = "Frenleme ve hızlanma altında vücut yunuslama miktarını değiştirir.",
            syntax = { "şamandıra", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Koltuk Ofset Mesafe",
            information = "Koltuk aracınızın kapı ne kadar değiştirir.",
            syntax = { "şamandıra", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Hasar Çarpan",
            information = "Aracınızın çarpışmalar alacaksınız zarar değiştirir.",
            syntax = { "şamandıra", "" }
        },
        ["monetary"] = {
            friendlyName = "Parasal Değeri",
            information = "Aracın tam fiyatını değiştirir.",
            syntax = { "tamsayı", "Bu özellik Multi Theft Auto içinde kullanılmamış olduğunu." }
        },
        ["modelFlags"] = {
            friendlyName = "Model Bayraklar",
            information = "Aracın Toggleable özel animasyonlar.", -- HERE "where is this shown?"
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
