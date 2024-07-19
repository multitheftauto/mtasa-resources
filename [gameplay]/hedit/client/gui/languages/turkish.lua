guiLanguage.turkish = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Handling Düzenleyici v "..HVER,

    restrictedPassenger = "Panele erişebilmek için sürücü olmalısınız.",
    needVehicle = "Panele erişebilmek için araçta olmalısınız!",
    needLogin = "Bu menüyü görüntülemek için hesabınıza giriş yapmalısınız.",
    needAdmin = "Bu menüyü görüntülemek için yetkili olmalısınız.",
    accessDenied = "Bu menüyü görüntülemek için yetkiniz yok.",
    invalidView = "Bu menü bulunamadı!",
    disabledView = "Bu menü devre dışı.",

    sameValue = "%s aynı!",
    exceedLimits = "%s değeri limitten fazla. [%s]!",
    cantSameValue = "%s ile %s aynı olmayabilir!",
    needNumber = "Sayı kullanmalısın!",
    unsupportedProperty = "%s desteklenen bir özellik değil.",
    successRegular = "%s değeri %s olarak ayarlandı.",
    successHex = "%s %s.",
    unableToChange = "%s değeri %s olarak ayarlanamaz!",
    disabledProperty = "%s değeri bu sunucuda düzenlenemez!",

    resetted = "Aracın handling ayarları başarılı bir şekilde sıfırlandı!",
    loaded = "Handling ayarlarınız başarılı bir şekilde yüklendi!",
    imported = "Handling ayarları başarılı bir şekilde içe aktarıldı!",
    invalidImport = "İçe aktarılamadı. Handling ayarları geçersiz!",
    invalidSave = "Lütfen geçerli bir ad ve açıklama giriniz!",

    confirmReplace = "Mevcut kaydın üzerine yazmak istediğinizden emin misiniz?",
    confirmLoad = "Handling ayarlarını yüklemek istediğinizden emin misiniz? Kaydedilmemiş tüm değişiklikler kaybolacak!",
    confirmDelete = "Handling ayarlarını silmek istediğinizden emin misiniz?",
    confirmReset = "Handling ayarlarını sıfırlamak istediğinizden emin misiniz? Kaydedilmemiş tüm değişiklikler kaybolacak!",
    confirmImport = "Handling ayarlarını içe aktarmak istediğinizden emin misiniz? Kaydedilmemiş tüm değişiklikler kaybolacak!",

    successSave = "Handling ayarları başarılı bir şekilde kaydedildi!",
    successLoad = "Handling ayarları başarılı bir şekilde yüklendi!",
    successDelete = "Handling ayarlarınız başarılı bir şekilde silindi!",

   wantTheSettings = "Bu ayarları uygulamak istediğinizden emin misiniz? Handling düzenleyici yeniden başlayacaktır.",

    vehicle = "Vehicle",
    unsaved = "Unsaved",

    clickToEdit = "Düzenlemek için tıkla veya kaydır.",
    enterToSubmit = "Onaylamak için enter tuşuna basın.",
    clickToViewFullLog = "Araç kaydını görüntülemek için tıklayın.",
    copiedToClipboard = "Handling ayarları kopyalandı!",

    special = {
    },

    --
    -- BUTTON / MENU STRINGS
    --

    --Warning level strings
    warningtitles = {
        info = "Bilgi",
        question = "Soru",
        warning = "Dikkat!",
        error = "Hata!"
    },
    --Strings for the buttons at the top
    menubar = {
        handling = "Handling",
        tools = "Araçlar",
        extra = "Ekstra",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "Motor",
        body = "Gövde",
        wheels = "Tekerlekler",
        appearance = "Görünüm",
        modelflags = "Model\nSeçenekleri",
        handlingflags = "Handling\nSeçenekleri",
        dynamometer = "Dyno",
        undo = "<",
        redo = ">",
        save = "Kayıtlar"
    },

    -- Strings for the various views of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "Motor",
            longname = "Motor Ayarları"
        },
        body = {
            shortname = "Gövde",
            longname = "Gövde Ayarları"
        },
        wheels = {
            shortname = "Tekerlekler",
            longname = "Tekerlek Ayarları"
        },
        appearance = {
            shortname = "Görünüm",
            longname = "Görünüm Ayarları"
        },
        modelflags = {
            shortname = "Model Seçenekleri",
            longname = "Araç Model Seçenekleri"
        },
        handlingflags = {
            shortname = "Handling Seçenekleri",
            longname = "Özel Handling Seçenekleri"
        },
        dynamometer = {
            shortname = "Dyno",
            longname = "Dinamometreyi Başlat"
        },
        about = {
            shortname = "About",
            longname = "About the official handling editor",
            itemtext = {
                textlabel = "Welcome to the official MTA handling editor! This resource allows you to edit the handling of any vehicle in-game in real time.\n\n"..
                            "You can save and load custom handlings you make through the 'Handling' menu in the top left corner.\n\n"..
                            "For more information about the handling editor - such as the official changelog - visit:",
                websitebox = "https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/hedit",
                morelabel = "\nThank you for choosing hedit!"
            }
        },
        undo = {
            shortname = "Geri Al",
            longname = "Geri Al",
            itemtext = {
                textlabel = "Bir şeyler yanlış."
            }
        },
        redo = {
            shortname = "Yeniden Yap",
            longname = "Yeniden Yap",
            itemtext = {
                textlabel = "Bir şeyler yanlış."
            }
        },
        reset = {
             shortname = "Sıfırla",
            longname = "Bu aracın handling ayarlarını sıfırla.",
            itemtext = {
                label = "Sıfırlanacak Araç:",
                combo = "-----",
                button = "Sıfırla"
            }
        },
        save = {
            shortname = "Kayıtlar",
            longname = "Handling ayarlarını yükle veya kaydet.",
            itemtext = {
                nameLabel = "İsim",
                descriptionLabel = "Açıklama",
                saveButton = "Kaydet",
                loadButton = "Yükle",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "handling.cfg",
            longname = "handling.cfg formatında içe/dışa aktar.",
            itemtext = {
                importButton = "İçe Aktar",
                exportButton = "Dışa Aktar (kopyala)",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "Getir",
            longname = "Handling ayarlarını başka bir oyuncudan al."
        },
        share = {
            shortname = "Paylaş",
            longname = "Handling ayarlarını başka bir oyuncu ile paylaş."
        },
        upload = {
            shortname = "Yükle",
            longname = "Handling ayarlarını sunucuya yükle."
        },
        download = {
            shortname = "İndir",
            longname = "Handling ayarlarını sunucudan indir."
        },
        
        resourcesave = {
            shortname = "Scripte kaydet",
            longname = "Handling ayarlarını scripte kaydet."
        },
        resourceload = {
            shortname = "Scriptten yükle",
            longname = "Handling ayarlarını scriptten yükle."
        },
        options = {
            shortname = "Seçenekler",
            longname = "Seçenekler",
            itemtext = {
                label_key = "Tuş",
                label_cmd = "Komut:",
                label_template = "GUI tema:",
                label_language = "Dil:",
                label_commode = "Kütle merkezi düzenleme modu:",
                checkbox_versionreset = "Versiyonumu %s den %s ye düşür?",
                button_save = "Uygula",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
		checkbox_lockwhenediting = "Handling esnasında aracı kilitle?",
                checkbox_dragmeterEnabled = "Hızlı ayar kullan"
            }
        },
        handlinglog = {
            shortname = "Handling Geçmişi",
            longname = "Handling ayarlarında son yapılan değişiklikler.",
            itemtext = {
                logpane = ""
            }
        },
    },


    handlingPropertyInformation = {
        ["identifier"] = {
            friendlyName = "Araç Tanımlayıcısı",
            information = "handling.cfg dosyasında kullanılacak araç tanımlayıcısını temsil eder.",
            syntax = { "String", "Lütfen uygun 'tanımlayıcılar' kullanın." }
        },
        ["mass"] = {
            friendlyName = "Kütle",
            information = "Aracın ağırlığını değiştirir. (kilogram)",
            syntax = { "Float", "'Dönüş Kütlesini' değiştirmeyi unutmayın!" }
        },
        ["turnMass"] = {
            friendlyName = "Dönüş Kütlesi",
            information = "Hareket efektlerini hesaplamak için kullanılır.",
            syntax = { "Float", "Büyük değerler, aracınızın 'yüzüyor gibi' görünmesini sağlayacaktır." }
        },
        ["dragCoeff"] = {
            friendlyName = "Sürüklenme Çarpanı",
            information = "Harekete karşı direnci değiştirir.",
            syntax = { "Float", "Değer ne kadar büyükse, en yüksek hız o kadar düşük olur." }
        },
        ["centerOfMass"] = {
            friendlyName = "Kütle Merkezi",
            information = "Aracınızın kütle merkezini değiştirir. (metre)",
            syntax = { "Float", "Bilgi için imleci ayrı koordinatların üzerine getirin." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Kütle Merkezi - X",
            information = "Kütle merkezinin ön-arka mesafesini belirler. (metre)",
            syntax = { "Float", "Yüksek değerler ön, düşük değerler arka taraftadır." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Kütle Merkezi - Y",
            information = "Kütle merkezinin sol-sağ mesafesini belirler. (metre)",
            syntax = { "Float", "Yüksek değerler sağ, düşük değerler sol taraftadır" }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Kütle Merkezi - Z",
            information = "Kütle merkezinin yüksekliğini belirler. (metre)",
            syntax = { "Float", "Değer ne kadar büyükse, noktanın konumu da o kadar yüksek olur." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Yüzme Yüzdesi",
            information = "Aracınızın yüzmeye başlamadan önce ne kadar derin suya batması gerektiğini değiştirir. (yüzde)",
            syntax = { "Integer", "Daha büyük değerler, aracınızın daha derin bir seviyede yüzmeye başlamasını sağlayacaktır." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Yola Tutunma (Viraj)",
            information = "Aracın virajlarda yola ne kadar tutunacağını ayarlar.",
            syntax = { "Float", "Daha büyük değerler tekerlekler ile yüzey arasındaki tutuşu artıracaktır." }
        },
        ["tractionLoss"] = {
            friendlyName = "Dönüş Kaybı",
            information = "Hızlanır/yavaşlarken aracın ne kadar iyi döneceğini ayarlar.",
            syntax = { "Float", "Daha büyük değerler, aracınızın virajları daha iyi dönmesini sağlayacaktır." }
        },
        ["tractionBias"] = {
            friendlyName = "Çekiş Eğilimi",
            information = "Tekerleklerinizin tüm çekişlerinin atanacağı değişiklikler.",
            syntax = { "Float", "Daha büyük değerler çekişi aracınızın önüne doğru hareket ettirecektir." }
        },
        ["numberOfGears"] = {
            friendlyName = "Vites Sayısı",
            information = "Aracınızın sahip olabileceği maksimum vites sayısını değiştirir.",
            syntax = { "Integer", "Aracınızın en yüksek hızını veya ivmesini etkilemez." }
        },
        ["maxVelocity"] = {
            friendlyName = "Maksimum Hız",
            information = "Aracınızın maksimum hızını değiştirir. (km / h)",
            syntax = { "Float", "Bu değer diğer özelliklerden etkilenir." }
        },
        ["engineAcceleration"] = {
            friendlyName = "İvme",
            information = "Aracınızın ivmesini değiştirir. (MS ^ 2)",
            syntax = { "Float", "Daha büyük değerler, aracın hızlanmasını artıracaktır." }
        },
        ["engineInertia"] = {
            friendlyName = "Eylemsizlik",
            information = "İvme eğrisini düzleştirir veya keskinleştirir.",
            syntax = { "Float", "Daha büyük değerler hızlanma eğrisini daha düzgün hale getirir." }
        },
        ["driveType"] = {
            friendlyName = "Çekiş",
            information = "Aracın çekişini ayarlar.",
            syntax = { "String", "'Dört Çeker' in seçilmesi, aracın kontrolünün daha kolay olmasına neden olacaktır." },
            options = { ["f"]="Ön Çekiş",["r"]="Arka Çekiş",["4"]="Dört Çeker" }
        },
        ["engineType"] = {
            friendlyName = "Motor Türü",
            information = "Aracınızın motor tipini değiştirir.",
            syntax = { "String", "Bu özelliğin neyi etkilediği bilinmemektedir." },
            options = { ["p"]="Benzin",["d"]="Dizel",["e"]="Elektrik" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Fren Yavaşlaması",
            information = "Aracınızın yavaşlamasını değiştirir. (MS ^ 2)",
            syntax = { "Float", "Daha büyük değerler aracın daha güçlü fren yapmasına neden olur, ancak çekişiniz çok düşükse kayabilir." }
        },
        ["brakeBias"] = {
            friendlyName = "Fren Konumu",
            information = "Frenlerin ana konumunu değiştirir.",
            syntax = { "Float", "Daha büyük değerler, frenleri aracın önüne doğru hareket ettirecektir." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Aracınızda ABS'yi etkinleştirir veya devre dışı bırakır.",
            syntax = { "Bool", "Bu özelliğin aracınız üzerinde hiçbir etkisi yoktur." },
            options = { ["true"]="Etkin",["false"]="Devre Dışı" }
        },
        ["steeringLock"] = {
            friendlyName = "Direksiyon Kilidi",
            information = "Direksiyonunuzun açısını değiştirmenizi sağlar.",
            syntax = { "Float", "Direksiyon açısı ne kadar düşükse, aracınız o kadar hızlıdır." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Süspansiyon Kuvveti Seviyesi",
            information = "Bu özelliğin neyi etkilediği bilinmemektedir.",
            syntax = { "Float", "Bu özelliğin neyi etkilediği bilinmemektedir." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Süspansiyon Sönümleme",
            information = "Bu özelliğin neyi etkilediği bilinmemektedir.",
            syntax = { "Float", "Bu özelliğin neyi etkilediği bilinmemektedir." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Süspansiyon Yüksek Hızlı Sönümleme",
            information = "Süspansiyonunuzun sertliğini değiştirerek daha hızlı sürmenize neden olur.",
            syntax = { "Float", "Bu özelliğin etkisi test edilmemiştir." } -- HERE {UNTESTED}
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Süspansiyon Üst Sınırı",
            information = "Tekerleklerin en yüksek hareketi (??). (metre)",
            syntax = { "Float", "Bu özelliğin etkisi test edilmemiştir." } -- HERE {UNTESTED}
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Süspansiyon Alt Sınırı",
            information = "Süspansiyonunuzun yüksekliğini ayarlamanızı sağlar.",
            syntax = { "Float", "Daha düşük değerler aracınızı yükseltir." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Süspansiyon Sapması",
            information = "Değişiklikler, süspansiyon gücünün çoğunun gideceği şekildeydi.",
            syntax = { "Float", "Daha büyük değerler sapmayı aracın önüne doğru hareket ettirecektir." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Süspansiyon Sallanması",
            information = "Frenleme ve hızlanma sırasında gövde sallama miktarını değiştirir.",
            syntax = { "Float", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Koltuk Mesafesi",
            information = "Koltuğun aracınızın kapısından ne kadar uzakta olduğunu değiştirir.",
            syntax = { "Float", "Bu özelliğin neyi etkilediği bilinmemektedir." }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Çarpışma Hasarı Katlayıcısı",
            information = "Aracınızın çarpışmalardan alacağı hasarı değiştirir.",
            syntax = { "Float", "0 yapılırsa araç çarpışmalarda hasar almaz." }
        },
        ["monetary"] = {
            friendlyName = "Parasal Değer",
            information = "Aracın tam fiyatını değiştirir.",
            syntax = { "Integer", "Bu özellik Multi Theft Auto 'da kullanılmamakta." }
        },
        ["modelFlags"] = {
            friendlyName = "Model Seçenekleri",
            information = "Aracın değiştirilebilir özel animasyonları. Buradaki özellikler her araçta çalışmayabilir.", -- HERE "where is this shown?"
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Arka çift kapıları hareketlendirir."},
                    ["2"] = {"IS_BUS","Aracın otobüs duraklarında durmasını ve yolcu almasını sağlar."}, -- HERE "Possible teehee"
                    ["4"] = {"IS_LOW","Sürücülerin ve yolcuların daha aşağıda oturmasını ve arkasına yaslanmasını sağlar."},
                    ["8"] = {"IS_BIG","Yapay zekanın köşelerden geçme şeklini değiştirir."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","Kaputun ve bagajın ters yönde açılmasını sağlar."},
                    ["2"] = {"HANGING_BOOT","Bagajın üst kenardan açılmasını sağlar."},
                    ["4"] = {"TAILGATE_BOOT","Bagajın alt kenardan açılmasını sağlar."},
                    ["8"] = {"NOSWING_BOOT","Bagajın kapalı kalmasını sağlar."}
                },
                {
                    ["1"] = {"NO_DOORS","Kapıların kapanma/açılma animasyonları atlanır."},
                    ["2"] = {"TANDEM_SEATS","Ön yolcu koltuğunu iki kişinin kullanabilmesini sağlar."},
                    ["4"] = {"SIT_IN_BOAT","Pedlerin ayakta durmak yerine oturarak tekne kullanmasını sağlar."},
                    ["8"] = {"CONVERTIBLE","Fahişelerin çalışma şeklini ve diğer küçük etkileri değiştirir."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Tüm egzoz parçacıklarının giderilmesine neden olur."},
                    ["2"] = {"DBL_EXHAUST","İki tane egzoz dumanı çıkışı sağlar. (ilkini yansıtır)"},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Oynatıcının birinci şahıs modundayken arka alan görünümünü kullanmasını engeller."},
                    ["8"] = {"FORCE_DOOR_CHECK","Bu özelliğin etkisi test edilmemiştir."} -- HERE {untested}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Ön tekerleklerin araca dikey kalmasını sağlar (GTA 3 gibi)."},
                    ["2"] = {"AXLE_F_SOLID","Ön tekerleklerin birbirine paralel kalmasını sağlar."},
                    ["4"] = {"AXLE_F_MCPHERSON","Ön tekerleklerin devrilmesini sağlar (GTA Vice City gibi)."},
                    ["8"] = {"AXLE_F_REVERSE","Ön tekerleklerin ters yönde eğilmesini sağlar."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Arka tekerleklerin araca dikey kalmasını sağlar (GTA 3 gibi)."},
                    ["2"] = {"AXLE_R_SOLID","Arka tekerleklerin birbirine paralel kalmasını sağlar."},
                    ["4"] = {"AXLE_R_MCPHERSON","Arka tekerleklerin devrilmesini sağlar (GTA Vice City gibi)."},
                    ["8"] = {"AXLE_R_REVERSE","rka tekerleklerin ters yönde eğilmesini sağlar."}
                },
                {
                    ["1"] = {"IS_BIKE","Bisikletler bölümündeki ekstra ayarları kullanın."},
                    ["2"] = {"IS_HELI","Uçak bölümündeki ekstra ayarları kullanın."},
                    ["4"] = {"IS_PLANE","Uçak bölümündeki ekstra ayarları kullanın."},
                    ["8"] = {"IS_BOAT","Tekne bölümündeki ekstra ayarları kullanın."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","Bu özelliğin etkisi test edilmemiştir."}, -- HERE {untested}
                    ["2"] = {"DOUBLE_RWHEELS","Bu, normal olanın yanına ikinci bir arka tekerleği yerleştirir (tırlar gibi)."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","Bu özelliğin etkisi test edilmemiştir."}, -- HERE {untested}
                    ["8"] = {"IS_HATCHBACK","Bu özelliğin etkisi test edilmemiştir."} -- HERE {untested}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Handling Seçenekleri",
            information = "Özel performans özellikleri. Buradaki özellikler her araçta çalışmayabilir.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Motora yokuş tırmanışı için daha fazla güç verir."},
                    ["2"] = {"2G_BOOST","Biraz daha yüksek hızlarda motora daha fazla güç verir."},
                    ["4"] = {"NPC_ANTI_ROLL","AI karakterleri tarafından sürüldüğünde aracın yuvarlanmasını devre dışı bırakır."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","AI karakterleri tarafından sürüldüğünde aracın dönme olasılığını azaltır."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","El frenini devre dışı bırakır."},
                    ["2"] = {"STEER_REARWHEELS","Ön tekerlekler yerine arka tekerlekler yönlendirilir (forklift gibi)."},
                    ["4"] = {"HB_REARWHEEL_STEER","El freninin ön ve arka tekerlekleri çevirmesini sağlar (Monster gibi)."},
                    ["8"] = {"ALT_STEER_OPT","Bu özelliğin etkisi test edilmemiştir."} -- HERE {untested}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Çok dar ön tekerlekler."},
                    ["2"] = {"WHEEL_F_NARROW","Dar ön tekerlekler."},
                    ["4"] = {"WHEEL_F_WIDE","Geniş ön tekerlekler."},
                    ["8"] = {"WHEEL_F_WIDE2","Çok geniş ön tekerlekler."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Çok dar arka tekerlekler."},
                    ["2"] = {"WHEEL_R_NARROW","Dar arka tekerlekler."},
                    ["4"] = {"WHEEL_R_WIDE","Geniş arka tekerlekler."},
                    ["8"] = {"WHEEL_R_WIDE2","Çok geniş arka tekerlekler."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","Bu özelliğin etkisi test edilmemiştir."}, -- HERE {untested}
                    ["2"] = {"HYDRAULIC_INST","Aracın hidrolik takılı yaratılmasını sağlar."},
                    ["4"] = {"HYDRAULIC_NONE","Hidroliği devre dışı bırakır."},
                    ["8"] = {"NOS_INST","Aracın nitro takılı yaratılmasını sağlar."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Aracın gevşek yüzeylerde (toprak gibi) daha iyi sürülmesini sağlar."},
                    ["2"] = {"OFFROAD_ABILITY2","Aracın yumuşak yüzeylerde (kum gibi) daha iyi sürülmesini sağlar."},
                    ["4"] = {"HALOGEN_LIGHTS","Farların daha parlak ve mavi görünmesini sağlar."},
                    ["8"] = {"PROC_REARWHEEL_1ST","Bu özelliğin etkisi test edilmemiştir."} -- HERE {untested}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Aracın maksimum hızdan daha hızlı gitmesini engeller."},
                    ["2"] = {"LOW_RIDER","Aracın Loco Low Co mağazalarında değiştirilmesine izin verir."},
                    ["4"] = {"STREET_RACER","Aracın yalnızca Wheel Arch Angels değiştirilebilir olmasını sağlar."},
                    ["8"] = {"??","??"}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Araç gövdesinin süspansiyon üzerinde bir yandan diğer yana hareket etmesini sağlar."},
                    ["2"] = {"??","??"},
                    ["4"] = {"??","??"},
                    ["8"] = {"??","??"},
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Ön Farlar",
            information = "Aracınızın sahip olacağı ön farların türünü değiştirir.",
            syntax = { "Integer", "" },
            options = { ["0"]="Normal",["1"]="Küçük",["2"]="Büyük",["3"]="Uzun" }
        },
        ["tailLight"] = {
            friendlyName = "Arka Farlar",
            information = "Aracınızın sahip olacağı arka farların türünü değiştirir.",
            syntax = { "Integer", "" },
            options = { ["0"]="Normal",["1"]="Küçük",["2"]="Büyük",["3"]="Uzun" }
        },
        ["animGroup"] = {
            friendlyName = "Animasyon Grubu",
            information = "Pedlerin araç içindeyken kullanacağı animasyon grubunu değiştirir.",
            syntax = { "Integer", "" }
        }
    }
}
