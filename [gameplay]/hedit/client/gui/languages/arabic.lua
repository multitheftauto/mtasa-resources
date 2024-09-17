guiLanguage.arabic = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "معدل الوزانيات v"..HVER,

    restrictedPassenger = "غير مسموح لك باستعمال معدل الوزانية ك راكب.",
    needVehicle = "عليك ان تسوق مركبة ما لكي تستعمل معدل الوزانية",
    needLogin = "يجب عليك تسجيل الدخول لكي تتمكن من مشاهدة هذه القائمة",
    needAdmin = "يجب عليك تسجيل الدخول ك مسؤول للوصول الى هذه القائمة",
    accessDenied = "ليس لديك صلاحية اللازمة للوصول الى هذه القائمة",
    invalidView = "هده لائحة غير موجودة",
    disabledView = "هذه لائحة تم تعطيلها",

    sameValue = "The %s is already that!",
    exceedLimits = "Value used at %s exceeds the limit. [%s]!",
    cantSameValue = "%s may not the same as %s!",
    needNumber = "يجب عليك استخدام رقم",
    unsupportedProperty = "%s هذه ليست خاصية مدعومة.",
    successRegular = "%s set to %s.",
    successHex = "%s %s.",
    unableToChange = "Unable to set the %s to %s!",
	disabledProperty = "تم تعطيل تعديل ٪  على هذا سيرفر",

    resetted = "تم اعادة ضبظ اعدادات وزانية السيارة بنجاح",
    loaded = "تم تحميل اعدادات وزانية خاصة بك بنجاح",
    imported = "تم استيراد اعدادات وزانية بنجاح",
    invalidImport = "فشل استيراد . بيانات وزانية الذي قدمتها غير صالحة",
    invalidSave = "يرجى تقديم اسم و وصف صحيحيين من اجل حفظ بيانات وزانية المركبة",

    confirmReplace = "هل انت متاكد من انك تريد اعادة الكتابة فوق الحفظ الحالي ?",
    confirmLoad = "هل انت متاكد من انك تريد تحميل اعدادات هذه وزانية ? سيتم فقد اي تغييرات غير محفوظة ?",
    confirmDelete = "هل انت متاكد من انك تريد حذف حذف اعدادات هذه وزانية ?",
    confirmReset = "هل انت متاكد من انك تريد اعادة ضبظ وزانيتك ? سيتم حذف اي تغييرات غير محفوظة",
    confirmImport = "هل انت متاكد من انك تريد استيراد هذه وزانية ? سيتم حذف اي تغييرات غير محفوظة",

    successSave = "تم حفظ اعدادات وزانيتك بنجاح",
    successLoad = "تم تحميل اعدادات وزانيتك بنجاح",
    successDelete = "تم حذف إعدادات الوزنية الخاصة بك بنجاح!",

    wantTheSettings = "هل انت متاكد من انك تريد تطبيق هذه الاعدادات ? معدل وزانيات سيتم اعادة تشغيله",

    vehicle = "مركبة",
    unsaved = "غير محفوظ",

    clickToEdit = "انقر للتعديل او السحب إلى ضبظ-سريع.",
    enterToSubmit = "اضغط على Enter للتأكيد.",
    clickToViewFullLog = "انقر لعرض سجل المركبة بالكامل.",
    copiedToClipboard = "لقد تم نسخ اعدادات وزانيتك الى كيبورد",

    special = {
    },

    --
    -- BUTTON / MENU STRINGS
    --

    --Warning level strings
    warningtitles = {
        info = "معلومة",
        question = "سؤال",
        warning = "تحذير!",
        error = "خلل!"
    },
    --Strings for the buttons at the top
    menubar = {
        handling = "وزانية",
        tools = "ادوات",
        extra = "اضافي",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "محرك",
        body = "جسم",
        wheels = "عجلات",
        appearance = "المظهر",
        modelflags = "نموذج/طراز",
        handlingflags = "وزانية/طراز",
        dynamometer = "المقوى أداة",
        undo = "<",
        redo = ">",
        save = "حفظ"
    },

    -- Strings for the various views of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "محرك",
            longname = "اعدادات محرك"
        },
        body = {
            shortname = "جسم",
            longname = "اعدادات جسم"
        },
        wheels = {
            shortname = "عجلات",
            longname = "اعدادات عجلات"
        },
        appearance = {
            shortname = "مظهر خارجي",
            longname = "اعدادات مظهر خارجي"
        },
        modelflags = {
            shortname = "نموذج",
            longname = "إعدادات نموذج السيارة"
        },
        handlingflags = {
            shortname = "طراز الوزانيات",
            longname = "اعدادات وزانية مميزة"
        },
        dynamometer = {
            shortname = "Dyno",
            longname = "تشغيل المقوى أداة"
        },
        about = {
            shortname = "حول",
            longname = "حول معدل الوزانيات الرسمي",
            itemtext = {
                textlabel = "مرحبا بكم في معدل وزانيات MTA الرسمي ! يتيح لك هذا المورد تعديل تعامل أي سيارة في اللعبة في الوقت الفعلي . \n \n "..
                            "يمكنك حفظ و تحميل وزانيات التي صممتها باستعمال قائمة وزانية في الجانب العلوي الايمن \n \n "..
                            "للمزيد من المعلومات حول معدل الوزنيات - مثل التغيير الرسمي - زر:",
                websitebox = "https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/hedit",
                morelabel = "شكرا لك لاستخدامك ل Hedit"
            }
        },
        undo = {
            shortname = "تراجع",
            longname = "تراجع",
            itemtext = {
                textlabel = "هناك خطأ ما."
            }
        },
        redo = {
            shortname = "اعادة",
            longname = "اعادة",
            itemtext = {
                textlabel = "هناك خطأ ما."
            }
        },
        reset = {
            shortname = "اعادة ضبظ",
            longname = "اعادة ضبظ اعدادات وزانية لهذه المركبة",
            itemtext = {
                label = "المركبة الأساسية:",
                combo = "-----",
                button = "اعادة ضبظ"
            }
        },
        save = {
            shortname = "محفوظات",
            longname = "حمل او احفظ اعدادات وزانية",
            itemtext = {
                nameLabel = "اسم",
                descriptionLabel = "وصف",
                saveButton = "حفظ",
                loadButton = "حمل",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "handling.cfg",
            longname = "استيراد او تصدير من/الى صيغة handling.cfg",
            itemtext = {
                importButton = "استيراد",
                exportButton = "تصدير و نسخ إلى الكيبورد",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "احصل",
            longname = "احصل على اعدادات وزانية من لاعب اخر"
        },
        share = {
            shortname = "شارك",
            longname = "شارك اعدادات وزانيتك مع لاعب اخر"
        },
        upload = {
            shortname = "ارفع",
            longname = "ارفع اعدادات وزانيتك الى سيرفر"
        },
        download = {
            shortname = "حمل",
            longname = "حمل اعدادات وزانية من سيرفر"
        },

        resourcesave = {
            shortname = "حفظ المورد",
            longname = "احفظ وزانيتك الى المورد"
        },
        resourceload = {
            shortname = "تشغيل المورد",
            longname = "شغل وزانيتك الى المورد"
        },
        options = {
            shortname = "اعدادات",
            longname = "اعدادات",
            itemtext = {
                label_key = "تبديل المفتاح",
                label_cmd = "تبديل الامر:",
                label_template = "قالب واجهة المستخدم الرسومية:",
                label_language = "اللغة:",
                label_commode = "مركز تحرير الوضع الشامل:",
                checkbox_versionreset = "Downgrade my version number from %s to %s?",
                button_save = "تطبيق",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
                checkbox_lockwhenediting = "قفل السيارة عند التعديل ?",
                checkbox_dragmeterEnabled = "استعمل ضبظ-سريع"
            }
        },
        handlinglog = {
            shortname = "سجل وزانية",
            longname = "سجل التغييرات الاخيرة لاعدادات وزانية",
            itemtext = {
                logpane = ""
            }
        },
    },


    handlingPropertyInformation = {
        ["identifier"] = {
            friendlyName = "معرف المركبة",
            information = "هذا يمثل معرف السيارة الذي سيتم استخدامه في handling.cfg.",
            syntax = { "خيط", "استخدم فقط المعرفات الصالحة ، وإلا فالتصدير لن يعمل." }
        },
        ["mass"] = {
            friendlyName = "كتلة",
            information = "يغير من وزن سيارتك. (كيلوجرام)",
            syntax = { "تطفو", "تذكر تغيير تحويل الكتلة أولاً لتجنب الارتداد!" }
        },
        ["turnMass"] = {
            friendlyName = "تحويل الكتلة",
            information = "تستخدم لحساب تأثيرات الحركة.",
            syntax = { "تطفو", "ستجعل القيم الكبيرة سيارتك تظهر تطفو." }
        },
        ["dragCoeff"] = {
            friendlyName = "السحب مضاعف",
            information = "يغير المقاومة للحركة.",
            syntax = { "تطفو", "كلما زادت القيمة ، انخفضت السرعة القصوى." }
        },
        ["centerOfMass"] = {
            friendlyName = "مركز الكتلة",
            information = "يغير نقطة خطورة سيارتك . (متر)",
            syntax = { "تطفو", "تحوم في الإحداثيات الفردية للحصول على المعلومات." }
        },
        ["centerOfMassX"] = {
            friendlyName = "مركز كتلة X",
            information = "يعين المسافة الأمامية الخلفية لمركز الكتلة . (متر)",
            syntax = { "تطفو", "القيم العليا هي إلى الأمام و القيم المنخفضة هي الظهر." }
        },
        ["centerOfMassY"] = {
            friendlyName = "مركز كتلة Y",
            information = "يعيّن المسافة اليسرى اليمنى من مركز الكتلة . (متر)",
            syntax = { "تطفو", "القيم العالية هي إلى اليمين والقيم المنخفضة إلى اليسار." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "مركز كتلة Z",
            information = "يعين ارتفاع مركز الكتلة. (متر)",
            syntax = { "تطفو", "كلما زادت القيمة ، ارتفع موضع النقطة." }
        },
        ["percentSubmerged"] = {
            friendlyName = "النسبة المئوية المغمورة",
            information = "يغير مدى عمق الحاجة إلى غمر مركبتك بالماء قبل أن تبدأ في الطفو. (نسبه مئويه)",
            syntax = { "عدد صحيح", "القيم الأكبر ستجعل سيارتك تبدأ في التعويم على مستوى أعمق." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "الجر المضاعف",
            information = "يغير مقدار قبضة سيارتك إلى الأرض أثناء الانعطاف.",
            syntax = { "تطفو", "القيم الأكبر ستزيد القبضة بين العجلات والسطح." }
        },
        ["tractionLoss"] = {
            friendlyName = "فقدان الجر",
            information = "يغير مقدار قبضة سيارتك أثناء التسارع والتباطؤ.",
            syntax = { "تطفو", "القيم الأكبر ستجعل سيارتك تنقسم بشكل أفضل." }
        },
        ["tractionBias"] = {
            friendlyName = "تحيز الجر",
            information = "التغييرات حيث سيتم تعيين كل قبضة العجلات الخاصة بك.",
            syntax = { "تطفو", "القيم الأكبر ستحرك التحيز نحو مقدمة سيارتك." }
        },
        ["numberOfGears"] = {
            friendlyName = "عدد التروس",
            information = "يغير الحد الأقصى لعدد التروس التي يمكن أن تحملها سيارتك.",
            syntax = { "عدد صحيح", "لا يؤثر على السرعة القصوى أو تسارع سيارتك." }
        },
        ["maxVelocity"] = {
            friendlyName = "أقصى سرعة",
            information = "يغير السرعة القصوى لسيارتك. (كم / ساعة)",
            syntax = { "تطفو", "تتأثر هذه القيمة بخصائص أخرى." }
        },
        ["engineAcceleration"] = {
            friendlyName = "التعجيل",
            information = "يغير تسارع سيارتك. (م.ث ^2)",
            syntax = { "تطفو", "ستزيد القيم الأكبر من معدل تسارع السيارة." }
        },
        ["engineInertia"] = {
            friendlyName = "التعطيل",
            information = "ينعم أو يقوي منحنى التسارع.",
            syntax = { "تطفو", "القيم الأكبر تجعل منحنى التسارع أكثر سلاسة." }
        },
        ["driveType"] = {
            friendlyName = "عجلة القيادة",
            information = "التغييرات التي سوف تستخدم العجلات أثناء القيادة.",
            syntax = { "خيط", "اختيار كل العجلات سيؤدي إلى سهولة التحكم في السيارة." },
            options = { ["f"]="العجلات الامامية",["r"]="الاطارات الخلفية",["4"]="كل العجلات" }
        },
        ["engineType"] = {
            friendlyName = "نوع المحرك",
            information = "يغير نوع المحرك لسيارتك.",
            syntax = { "خيط", "تأثير هذه الخاصية يسبب غير معروف." },
            options = { ["p"]="بنزين",["d"]="ديزل",["e"]="كهربائي" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "تباطؤ الفرامل",
            information = "يغير تباطؤ سيارتك. (م.ث^ 2)",
            syntax = { "تطفو", "ستؤدي القيم الأكبر إلى جعل المركبة أكثر قوة ، ولكن قد تنزلق إذا كان السحب منخفضًا جدًا." }
        },
        ["brakeBias"] = {
            friendlyName = "تحيز الفرامل",
            information = "يغير المركز الرئيسي للفرامل.",
            syntax = { "تطفو", "القيم الأكبر ستحرك الانحياز نحو مقدمة السيارة." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "تمكين أو تعطيل ABS على سيارتك.",
            syntax = { "Bool", "هذه الخاصية ليس لها أي تأثير على سيارتك." },
            options = { ["true"]="مشغلة",["false"]="معطلة" }
        },
        ["steeringLock"] = {
            friendlyName = "قفل مقود",
            information = "يغير الحد الأقصى للزاوية التي يمكن أن تقودها سيارتك.",
            syntax = { "تطفو", "كلما كانت زاوية التوجيه أقل كلما كانت سيارتك أسرع." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "مستوى قوة التعليق",
            information = "تأثير هذه الخاصية يسبب غير معروف.",
            syntax = { "تطفو", "بناء الجملة لهذه الخاصية غير معروف." }
        },
        ["suspensionDamping"] = {
            friendlyName = "تعليق التخميد",
            information = "تأثير هذه الخاصية يسبب غير معروف.",
            syntax = { "تطفو", "بناء الجملة لهذه الخاصية غير معروف." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "تعليق التخميد عالي السرعة",
            information = "يغير صلابة التعليق الخاص بك ، مما يتسبب في قيادتك بشكل أسرع.",
            syntax = { "تطفو", "لم يتم اختبار تأثير هذه الخاصية." } -- HERE {UNTESTED}
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "تعليق الحد الأعلى",
            information = "الحركة العليا للعجلات. (متر)",
            syntax = { "تطفو", "لم يتم اختبار تأثير هذه الخاصية." } -- HERE {UNTESTED}
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "تعليق الحد الأدنى",
            information = "ذروة التعليق الخاص بك.",
            syntax = { "تطفو", "سوف القيم السفلى تجعل سيارتك أعلى." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "تعليق التحيز",
            information = "التغييرات التي ستذهب إليها معظم قوة التعليق.",
            syntax = { "تطفو", "القيم الأكبر ستحرك الانحياز نحو مقدمة السيارة." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "تعليق مضاد الغطس المضاعف",
            information = "يغير مقدار نصب الجسم تحت الكبح والتسارع.",
            syntax = { "تطفو", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "مسافة المقعد",
            information = "يغير إلى أي مدى يكون المقعد من باب سيارتك.",
            syntax = { "تطفو", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "ضرر الاصطدام المضاعف",
            information = "يغير الضرر الذي تتعرض له سيارتك من الاصطدامات.",
            syntax = { "تطفو", "" }
        },
        ["monetary"] = {
            friendlyName = "القيمة النقدية",
            information = "يغير السعر المحدد للسيارة.",
            syntax = { "عدد صحيح", "هذه الخاصية غير مستخدمة داخل اللعبة (multi theft auto)" }
        },
        ["modelFlags"] = {
            friendlyName = "الطراز المعدل",
            information = "تبديل الرسوم المتحركة الخاصة قادرة على السيارة.", -- HERE "where is this shown?"
            syntax = { "عشري", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","يقوم بتحريك الأبواب الخلفية المزدوجة."},
                    ["2"] = {"IS_BUS","يتسبب في توقف السيارة عند محطات الحافلات وأكل الركاب."}, -- HERE "Possible teehee"
                    ["4"] = {"IS_LOW","يتسبب السائقين والركاب في الجلوس وتراجع."},
                    ["8"] = {"IS_BIG","يغير الطريقة التي يحرك بها الذكاء الاصطناعي حول الزوايا."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","تسبب غطاء المحرك والتمهيد لفتح في الاتجاه المعاكس."},
                    ["2"] = {"HANGING_BOOT","يتسبب في فتح التمهيد من الحافة العلوية."},
                    ["4"] = {"TAILGATE_BOOT","يتسبب في التمهيد لفتح من الحافة السفلية."},
                    ["8"] = {"NOSWING_BOOT","يتسبب في أن تظل الحذاء مغلقة."}
                },
                {
                    ["1"] = {"NO_DOORS","يتم تخطي الرسوم المتحركة التي تشمل إغلاق وفتح الأبواب."},
                    ["2"] = {"TANDEM_SEATS","تمكن شخصين من استخدام مقعد الراكب الأمامي."},
                    ["4"] = {"SIT_IN_BOAT","يسبب لاعب لاستخدام الرسوم المتحركة القارب جالس بدلاً من الوقوف."},
                    ["8"] = {"CONVERTIBLE","Changes how hookers operate and other small effects."}
                },
                {
                    ["1"] = {"NO_EXHAUST","يسبب إزالة جميع جزيئات العادم."},
                    ["2"] = {"DBL_EXHAUST","يضيف جسيمات العادم الثانية على الجانب الآخر إلى أنبوب العادم الأول."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","يمنع اللاعب من استخدام عرض الحقل الخلفي عندما يكون في وضع الشخص الأول."},
                    ["8"] = {"FORCE_DOOR_CHECK","لم يتم اختبار التأثير الذي تسببه هذه العلامة."} -- HERE {untested}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","تسبب العجلات الأمامية للبقاء عموديًا على السيارة (مثل GTA 3)."},
                    ["2"] = {"AXLE_F_SOLID","يتسبب في العجلات الأمامية للبقاء موازية لبعضها البعض."},
                    ["4"] = {"AXLE_F_MCPHERSON","تسبب العجلات الأمامية للإمالة (مثل GTA Vice City)."},
                    ["8"] = {"AXLE_F_REVERSE","يتسبب في إمالة العجلات الأمامية في الاتجاه المعاكس."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","تسبب العجلات الخلفية للبقاء عموديًا على السيارة (مثل GTA 3)."},
                    ["2"] = {"AXLE_R_SOLID","تسبب العجلات الخلفية للبقاء موازية لبعضها البعض."},
                    ["4"] = {"AXLE_R_MCPHERSON","تسبب العجلات الخلفية للإمالة (مثل GTA Vice City)."},
                    ["8"] = {"AXLE_R_REVERSE","يتسبب في إمالة العجلات الخلفية في الاتجاه المعاكس."}
                },
                {
                    ["1"] = {"IS_BIKE","استخدم الإعدادات الإضافية في قسم الدراجات."},
                    ["2"] = {"IS_HELI","استخدم الإعدادات الإضافية في قسم الطيران."},
                    ["4"] = {"IS_PLANE","استخدم الإعدادات الإضافية في قسم الطيران."},
                    ["8"] = {"IS_BOAT","استخدم الإعدادات الإضافية في قسم القوارب."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","لم يتم اختبار التأثير الذي تسببه هذه العلامة."}, -- HERE {untested}
                    ["2"] = {"DOUBLE_RWHEELS","هذا يضع عجلة خلفية ثانية إلى جانب العجلة العادية."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","لم يتم اختبار التأثير الذي تسببه هذه العلامة."}, -- HERE {untested}
                    ["8"] = {"IS_HATCHBACK","لم يتم اختبار التأثير الذي تسببه هذه العلامة."} -- HERE {untested}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "طراز الوزانيات",
            information = "ميزات الأداء الخاصة.",
            syntax = { "عشري", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","يمنح المحرك طاقة أكبر لبدء التشغيل (من أجل تسلق أفضل للتلال)."},
                    ["2"] = {"2G_BOOST","يمنح المحرك طاقة أكبر بسرعات أعلى قليلاً."},
                    ["4"] = {"NPC_ANTI_ROLL","تعطيل لفة الجسم عند تشغيلها بواسطة أحرف AI."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","يقلل من احتمالية دخول السيارة إلى الخارج عند قيادة شخصيات AI."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","تعطيل تأثير فرملة اليد."},
                    ["2"] = {"STEER_REARWHEELS","يتم توجيه العجلات الخلفية بدلاً من العجلات الأمامية (مثل الرافعة الشوكية)."},
                    ["4"] = {"HB_REARWHEEL_STEER","يتسبب في فرملة اليد لجعل العجلات الخلفية تقود كذلك إلى الأمام (مثل شاحنة الوحش)."},
                    ["8"] = {"ALT_STEER_OPT","لم يتم اختبار التأثير الذي تسببه هذه العلامة."} -- HERE {untested}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","يسبب عجلات أمامية ضيقة جدا."},
                    ["2"] = {"WHEEL_F_NARROW","يسبب العجلات الأمامية الضيقة."},
                    ["4"] = {"WHEEL_F_WIDE","يسبب عجلات أمامية واسعة."},
                    ["8"] = {"WHEEL_F_WIDE2","يسبب عجلات أمامية واسعة جدا."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","تسبب العجلات الخلفية ضيقة جدا."},
                    ["2"] = {"WHEEL_R_NARROW","يسبب العجلات الخلفية الضيقة."},
                    ["4"] = {"WHEEL_R_WIDE","يسبب العجلات الخلفية واسعة."},
                    ["8"] = {"WHEEL_R_WIDE2","يسبب العجلات الخلفية واسعة جدا."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","لم يتم اختبار التأثير الذي تسببه هذه العلامة."}, -- HERE {untested}
                    ["2"] = {"HYDRAULIC_INST","يتسبب في تركيب المركبة مع المكونات الهيدروليكية المثبتة."},
                    ["4"] = {"HYDRAULIC_NONE","تعطيل تركيب المكونات الهيدروليكية."},
                    ["8"] = {"NOS_INST","يتسبب في السيارة المركبة لتفرخ مع النيتروز المثبتة."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","يتسبب في أداء السيارة بشكل أفضل على السطوح غير المستوية (مثل الأوساخ)."},
                    ["2"] = {"OFFROAD_ABILITY2","يتسبب في أداء السيارة بشكل أفضل على الأسطح الناعمة (مثل الرمل)."},
                    ["4"] = {"HALOGEN_LIGHTS","تجعل المصابيح الأمامية تبدو أكثر إشراقاً و أكثر زرقة."},
                    ["8"] = {"PROC_REARWHEEL_1ST","لم يتم اختبار التأثير الذي تسببه هذه العلامة."} -- HERE {untested}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","يمنع السيارة من الذهاب أسرع من السرعة القصوى."},
                    ["2"] = {"LOW_RIDER","يسمح بتعديل السيارة في متاجر (Loco Low Co)"},
                    ["4"] = {"STREET_RACER","لا يمكن تعديل السيارة إلا في (Wheel Wheel Angels)"},
                    ["8"] = {"",""}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","دع جسم السيارة يتحرك من جانب إلى آخر على التعليق."},
                    ["2"] = {"",""},
                    ["4"] = {"",""},
                    ["8"] = {"",""}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "أضواء الرأس",
            information = "قم بتغيير نوع المصابيح الأمامية في سيارتك.",
            syntax = { "عدد صحيح", "" },
            options = { ["0"]="طويل",["1"]="صغير",["2"]="كبير",["3"]="طويل" }
        },
        ["tailLight"] = {
            friendlyName = "إضاءة خلفية",
            information = "يغير نوع المصابيح الخلفية في سيارتك.",
            syntax = { "عدد صحيح", "" },
            options = { ["0"]="طويل",["1"]="صغير",["2"]="كبير",["3"]="طويل" }
        },
        ["animGroup"] = {
            friendlyName = "مجموعة الرسوم المتحركة",
            information = "سوف يستخدم التغييرات التي تقوم بها مجموعة الرسوم المتحركة داخل السيارة.",
            syntax = { "عدد صحيح", "" }
        }
    }
}
