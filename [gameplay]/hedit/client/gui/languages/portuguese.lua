-- AQUI "onde isso é mostrado?"
guiLanguage.portuguese = {
    --
    -- GENERAL STRINGS
    --
    windowHeader = "Editor de Handling v"..HVER,

    restrictedPassenger = "Você não pode usar o editor de handling como passageiro.",
    needVehicle = "Você precisa estar dirigindo um veículo para usar o editor de handling!",
    needLogin = "Você precisa estar logado para visualizar esse menu.",
    needAdmin = "Você precisa estar logado como administrador para acessar esse menu.",
    accessDenied = "Você não possui as permissões necessárias para acessar esse menu.",
    invalidView = "Esse menu não existe!",
    disabledView = "Esse menu foi desativado.",

    sameValue = "%s já está definido como isso!",
    exceedLimits = "Valor usado em %s excede o limite. [%s]!",
    cantSameValue = "%s não pode ser igual a %s!",
    needNumber = "Você precisa usar um número!",
    unsupportedProperty = "%s não é uma propriedade suportada.",
    successRegular = "%s definido como %s.",
    successHex = "%s %s.",
    unableToChange = "Não é possível definir %s como %s!",
    disabledProperty = "Editar %s está desativado nesse servidor!",

    resetted = "As configurações da handling do veículo foram redefinidas com sucesso!",
    loaded = "Suas configurações da handling foram carregadas com sucesso!",
    imported = "As configurações da handling foram importadas com sucesso!",
    invalidImport = "Falha na importação. Os dados da handling fornecidos são inválidos!",
    invalidSave = "Por favor, forneça um nome e descrição válidos para salvar os dados da handling desse veículo!",

    confirmReplace = "Você tem certeza de que deseja substituir o salvamento existente?",
    confirmLoad = "Você tem certeza de que deseja carregar essas configurações de handling? Quaisquer alterações não salvas serão perdidas!",
    confirmDelete = "Você tem certeza de que deseja excluir essas configurações de handling?",
    confirmReset = "Você tem certeza de que deseja redefinir a handling? Quaisquer alterações não salvas serão perdidas!",
    confirmImport = "Você tem certeza de que deseja importar essa handling? Quaisquer alterações não salvas serão perdidas!",

    successSave = "Suas configurações de handling foram salvas com sucesso!",
    successLoad = "Suas configurações de handling foram carregadas com sucesso!",
    successDelete = "Suas configurações de handling foram excluídas com sucesso!",

    wantTheSettings = "Você tem certeza de que deseja aplicar essas configurações? O editor de handling será reiniciado.",

    vehicle = "Veículo",
    unsaved = "Não salvo",

    clickToEdit = "Clique para editar ou arraste para ajuste rápido.",
    enterToSubmit = "Pressione Enter para confirmar.",
    clickToViewFullLog = "Clique para ver o registro completo do veículo.",
    copiedToClipboard = "As configurações de handling foram copiadas para a área de transferência!",

    special = {
    },

    --
    -- BUTTON / MENU STRINGS
    --

    --Warning level strings
    -- warningtitles = {
    --     info = "Informação",
    --     question = "Pergunta",
    --     warning = "Aviso!",
    --     error = "Erro!"
    -- },
    --Strings for the buttons at the top
    menubar = {
        handling = "Handling",
        tools = "Ferramentas",
        extra = "Extra",
    },

    --Strings for the buttons at the left
    viewbuttons = {
        engine = "Motor",
        body = "Carroceria",
        wheels = "Rodas",
        appearance = "Aparência",
        modelflags = "Caixas do\nModelo",
        handlingflags = "Caixas da\nHandling",
        dynamometer = "Dinamômetro",
        undo = "<",
        redo = ">",
        save = "Saves"
    },

    -- Strings for the various menus of the editor. Empty strings are placeholder to avoid debug as the debug is meant to show items which are missing text.
    viewinfo = {
        engine = {
            shortname = "Motor",
            longname = "Configurações do Motor"
        },
        body = {
            shortname = "Carroceria",
            longname = "Configurações da Carroceria"
        },
        wheels = {
            shortname = "Rodas",
            longname = "Configurações das Rodas"
        },
        appearance = {
            shortname = "Aparência",
            longname = "Configurações de Aparência"
        },
        modelflags = {
            shortname = "Caixas do Modelo",
            longname = "Configurações do Modelo do Veículo"
        },
        handlingflags = {
            shortname = "Caixas de Handling",
            longname = "Configurações Especiais de Handling"
        },
        dynamometer = {
            shortname = "Dinamômetro",
            longname = "Iniciar Dinamômetro"
        },
        about = {
            shortname = "Sobre",
            longname = "Sobre o Editor Oficial de Handlings",
            itemtext = {
                textlabel = "Bem-vindo ao editor de Handling oficial do MTA! Esse recurso permite que você edite a handling de qualquer veículo em tempo real no jogo.\n\n"..
                            "Você pode salvar e carregar handlings personalizadas através do menu 'Handling' no canto superior esquerdo.\n\n"..
                            "Para obter mais informações sobre o Editor de Handling - como o registro de alterações oficial - visite:",
                websitebox = "https://github.com/multitheftauto/mtasa-resources/tree/master/%5Bgameplay%5D/hedit",
                morelabel = "\nObrigado por escolher o hedit!"
            }
        },
        undo = {
            shortname = "Desfazer",
            longname = "Desfazer",
            itemtext = {
                textlabel = "Algo deu errado."
            }
        },
        redo = {
            shortname = "Refazer",
            longname = "Refazer",
            itemtext = {
                textlabel = "Algo deu errado."
            }
        },
        reset = {
            shortname = "Redefinir",
            longname = "Redefinir as configurações de handling desse veículo.",
            itemtext = {
                label = "Veículo Base:",
                combo = "-----",
                button = "Redefinir"
            }
        },
        save = {
            shortname = "Saves",
            longname = "Carregar ou salvar configurações de handling.",
            itemtext = {
                nameLabel = "Nome",
                descriptionLabel = "Descrição",
                saveButton = "Salvar",
                loadButton = "Carregar",
                deleteButton = "Excluir",
                grid = "",
                nameEdit = "",
                descriptionEdit = ""
            }
        },
        import = {
            shortname = "handling.cfg",
            longname = "Importar ou Exportar para/formato handling.cfg.",
            itemtext = {
                importButton = "Importar",
                exportButton = "Exportar e copiar para a área de transferência",
                III = "III",
                VC = "VC",
                SA = "SA",
                IV = "IV",
                memo = ""
            }
        },
        get = {
            shortname = "Obter",
            longname = "Obter configurações de handling de outro jogador."
        },
        share = {
            shortname = "Compartilhar",
            longname = "Compartilhar suas configurações de handling com outro jogador."
        },
        upload = {
            shortname = "Enviar",
            longname = "Enviar suas configurações de handling para o servidor."
        },
        download = {
            shortname = "Baixar",
            longname = "Baixar um conjunto de configurações de handling do servidor."
        },
        resourcesave = {
            shortname = "Salvar recurso",
            longname = "Salvar suas configurações de handling em um recurso."
        },
        resourceload = {
            shortname = "Carregar recurso",
            longname = "Carregar uma configuração de handling de um recurso."
        },
        options = {
            shortname = "Opções",
            longname = "Opções",
            itemtext = {
                label_key = "Tecla de Alternância",
                label_cmd = "Comando de Alternância:",
                label_template = "Modelo da GUI:",
                label_language = "Idioma:",
                label_commode = "Modo de Edição do Centro de Massa:",
                checkbox_versionreset = "Rebaixar o meu número de versão de %s para %s?",
                button_save = "Aplicar",
                combo_key = "",
                combo_template = "",
                edit_cmd = "",
                combo_commode = "",
                combo_language = "",
                checkbox_lockwhenediting = "Trancar o veículo durante a edição da handling?",
                checkbox_dragmeterEnabled = "Usar ajuste rápido"
            }
        },
        handlinglog = {
            shortname = "Registro de Handling",
            longname = "Registro das mudanças recentes nas configurações de handling.",
            itemtext = {
                logpane = ""
            }
        },
    },


    handlingPropertyInformation = {
        ["identifier"] = {
            friendlyName = "Identificador do Veículo",
            information = "Isso representa o identificador do veículo a ser usado em handling.cfg.",
            syntax = { "String", "Use apenas identificadores válidos, caso contrário a exportação não funcionará." }
        },
        ["mass"] = {
            friendlyName = "Massa",
            information = "Altera o peso do seu veículo. (quilogramas)",
            syntax = { "Float", "Lembre-se de alterar 'turnMass' primeiro para evitar saltos!" }
        },
        ["turnMass"] = {
            friendlyName = "Massa de Viragem",
            information = "Usada para calcular os efeitos de movimento.",
            syntax = { "Float", "Valores grandes farão com que o veículo pareça 'flutuar'." }
        },
        ["dragCoeff"] = {
            friendlyName = "Coeficiente de Arrasto",
            information = "Altera a resistência ao movimento."
        },
        ["centerOfMass"] = {
            friendlyName = "Centro de Massa",
            information = "Altera o ponto de gravidade do seu veículo. (metros)",
            syntax = { "Float", "Passe o mouse sobre as coordenadas individuais para obter informações." }
        },
        ["centerOfMassX"] = {
            friendlyName = "Centro de Massa X",
            information = "Atribui a distância frente-trás do centro de massa. (metros)",
            syntax = { "Float", "Valores altos estão à frente e valores baixos estão atrás." }
        },
        ["centerOfMassY"] = {
            friendlyName = "Centro de Massa Y",
            information = "Atribui a distância esquerda-direita do centro de massa. (metros)",
            syntax = { "Float", "Valores altos estão à direita e valores baixos estão à esquerda." }
        },
        ["centerOfMassZ"] = {
            friendlyName = "Centro de Massa Z",
            information = "Atribui a altura do centro de massa. (metros)",
            syntax = { "Float", "Quanto maior o valor, mais alta a posição do ponto." }
        },
        ["percentSubmerged"] = {
            friendlyName = "Porcentagem Submersa",
            information = "Altera a profundidade em que o seu veículo precisa estar submerso na água para começar a flutuar. (porcentagem)",
            syntax = { "Inteiro", "Valores maiores farão o seu veículo começar a flutuar em um nível mais profundo." }
        },
        ["tractionMultiplier"] = {
            friendlyName = "Multiplicador de Tração",
            information = "Altera a quantidade de aderência que o seu veículo terá ao solo ao fazer curvas.",
            syntax = { "Float", "Valores maiores aumentarão a aderência entre as rodas e a superfície." }
        },
        ["tractionLoss"] = {
            friendlyName = "Perda de Tração",
            information = "Altera a quantidade de aderência que o seu veículo terá ao acelerar e desacelerar.",
            syntax = { "Float", "Valores maiores farão o seu veículo fazer curvas mais eficazmente." }
        },
        ["tractionBias"] = {
            friendlyName = "Viés de Tração",
            information = "Altera onde toda a aderência das rodas será atribuída.",
            syntax = { "Float", "Valores maiores moverão o viés para a parte frontal do seu veículo." }
        },
        ["numberOfGears"] = {
            friendlyName = "Número de Marchas",
            information = "Altera o número máximo de marchas que o seu veículo pode ter.",
            syntax = { "Inteiro", "Não afeta a velocidade máxima nem a aceleração do seu veículo." }
        },
        ["maxVelocity"] = {
            friendlyName = "Velocidade Máxima",
            information = "Altera a velocidade máxima do seu veículo. (km/h)",
            syntax = { "Float", "Esse valor é afetado por outras propriedades." }
        },

        ["engineAcceleration"] = {
            friendlyName = "Aceleração",
            information = "Altera a aceleração do seu veículo. (MS^2)",
            syntax = { "Float", "Valores maiores aumentarão a taxa de aceleração do veículo." }
        },
        ["engineInertia"] = {
            friendlyName = "Inércia",
            information = "Torna a curva de aceleração mais suave ou acentuada.",
            syntax = { "Float", "Valores maiores tornam a curva de aceleração mais suave." }
        },
        ["driveType"] = {
            friendlyName = "Tração nas Rodas",
            information = "Altera quais rodas serão usadas ao dirigir.",
            syntax = { "String", "Escolher 'Todas as rodas' tornará o veículo mais fácil de controlar." },
            options = { ["f"]="Rodas dianteiras",["r"]="Rodas traseiras",["4"]="Todas as rodas" }
        },
        ["engineType"] = {
            friendlyName = "Tipo de Motor",
            information = "Altera o tipo de motor do seu veículo.",
            syntax = { "String", "O efeito que esta propriedade causa é desconhecido." },
            options = { ["p"]="Gasolina",["d"]="Diesel",["e"]="Elétrico" }
        },
        ["brakeDeceleration"] = {
            friendlyName = "Desaceleração dos Freios",
            information = "Altera a desaceleração do seu veículo. (MS^2)",
            syntax = { "Float", "Valores maiores farão com que o veículo freie com mais intensidade, mas pode derrapar se a tração for muito baixa." }
        },
        ["brakeBias"] = {
            friendlyName = "Viés dos Freios",
            information = "Altera a posição principal dos freios.",
            syntax = { "Float", "Valores maiores moverão o viés para a parte frontal do veículo." }
        },
        ["ABS"] = {
            friendlyName = "ABS",
            information = "Ativa ou desativa o ABS no seu veículo.",
            syntax = { "Booleano", "Esta propriedade não tem efeito no seu veículo." },
            options = { ["true"]="Ativado",["false"]="Desativado" }
        },
        ["steeringLock"] = {
            friendlyName = "Limite de Direção",
            information = "Altera o ângulo máximo que o seu veículo pode virar.",
            syntax = { "Float", "Quanto menor o ângulo de direção, mais rápido o seu veículo." }
        },
        ["suspensionForceLevel"] = {
            friendlyName = "Nível de Força da Suspensão",
            information = "O efeito que esta propriedade causa é desconhecido.",
            syntax = { "Float", "A sintaxe para esta propriedade é desconhecida." }
        },
        ["suspensionDamping"] = {
            friendlyName = "Amortecimento da Suspensão",
            information = "O efeito que esta propriedade causa é desconhecido.",
            syntax = { "Float", "A sintaxe para esta propriedade é desconhecida." }
        },
        ["suspensionHighSpeedDamping"] = {
            friendlyName = "Amortecimento de Alta Velocidade da Suspensão",
            information = "Altera a rigidez da sua suspensão, fazendo você dirigir mais rápido.",
            syntax = { "Float", "O efeito que esta propriedade causa não foi testado." } -- AQUI {NÃO TESTADO}
        },
        ["suspensionUpperLimit"] = {
            friendlyName = "Limite Superior da Suspensão",
            information = "Movimento mais alto das rodas. (metros)",
            syntax = { "Float", "O efeito que esta propriedade causa não foi testado." } -- AQUI {NÃO TESTADO}
        },
        ["suspensionLowerLimit"] = {
            friendlyName = "Limite Inferior da Suspensão",
            information = "A altura da sua suspensão.",
            syntax = { "Float", "Valores menores farão o seu veículo ficar mais alto." }
        },
        ["suspensionFrontRearBias"] = {
            friendlyName = "Viés da Suspensão",
            information = "Altera onde a maior parte da potência da suspensão será aplicada.",
            syntax = { "Float", "Valores maiores moverão o viés para a parte frontal do veículo." }
        },
        ["suspensionAntiDiveMultiplier"] = {
            friendlyName = "Multiplicador de Anti-mergulho da Suspensão",
            information = "Altera a quantidade de inclinação do corpo ao frear e acelerar.",
            syntax = { "Float", "" }
        },
        ["seatOffsetDistance"] = {
            friendlyName = "Distância de Deslocamento do Assento",
            information = "Altera a distância entre o assento e a porta do seu veículo.",
            syntax = { "Float", "" }
        },
        ["collisionDamageMultiplier"] = {
            friendlyName = "Multiplicador de Dano por Colisão",
            information = "Altera o dano que o seu veículo receberá de colisões.",
            syntax = { "Float", "" }
        },
        ["monetary"] = {
            friendlyName = "Valor Monetário",
            information = "Altera o preço exato do veículo.",
            syntax = { "Inteiro", "Esta propriedade não é usada no Multi Theft Auto." }
        },
        ["modelFlags"] = {
            friendlyName = "Caixas do Modelo",
            information = "Animações especiais ativáveis do veículo.", -- AQUI "onde isso é mostrado?"
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"IS_VAN","Anima as portas traseiras duplas."},
                    ["2"] = {"IS_BUS","Faz com que o veículo pare em pontos de ônibus e pegue passageiros."}, -- AQUI "Talvez risos"
                    ["4"] = {"IS_LOW","Faz com que motoristas e passageiros se sentem mais baixo e inclinem para trás."},
                    ["8"] = {"IS_BIG","Altera a forma como a IA dirige ao fazer curvas."}
                },
                {
                    ["1"] = {"REVERSE_BONNET","Faz com que o capô e o porta-malas se abram na direção oposta."},
                    ["2"] = {"HANGING_BOOT","Faz com que o porta-malas se abra pela borda superior."},
                    ["4"] = {"TAILGATE_BOOT","Faz com que o porta-malas se abra pela borda inferior."},
                    ["8"] = {"NOSWING_BOOT","Faz com que o porta-malas permaneça fechado."}
                },
                {
                    ["1"] = {"NO_DOORS","Animações de abertura e fechamento de portas são ignoradas."},
                    ["2"] = {"TANDEM_SEATS","Permite que duas pessoas usem o assento dianteiro do passageiro."},
                    ["4"] = {"SIT_IN_BOAT","Faz com que pedestres usem a animação sentada em barcos em vez de ficarem de pé."},
                    ["8"] = {"CONVERTIBLE","Altera como as prostitutas se comportam e outros pequenos efeitos."}
                },
                {
                    ["1"] = {"NO_EXHAUST","Remove todas as partículas de escapamento."},
                    ["2"] = {"DBL_EXHAUST","Adiciona uma segunda partícula de escapamento no lado oposto ao primeiro cano de escapamento."},
                    ["4"] = {"NO1FPS_LOOK_BEHIND","Impede o jogador de usar a visão traseira em primeira pessoa."},
                    ["8"] = {"FORCE_DOOR_CHECK","O efeito dessa caixa não foi testado."} -- AQUI {não testado}
                },
                {
                    ["1"] = {"AXLE_F_NOTILT","Faz com que as rodas dianteiras permaneçam verticais ao carro (como no GTA 3)."},
                    ["2"] = {"AXLE_F_SOLID","Faz com que as rodas dianteiras permaneçam paralelas entre si."},
                    ["4"] = {"AXLE_F_MCPHERSON","Faz com que as rodas dianteiras inclinem (como no GTA Vice City)."},
                    ["8"] = {"AXLE_F_REVERSE","Faz com que as rodas dianteiras inclinem na direção oposta."}
                },
                {
                    ["1"] = {"AXLE_R_NOTILT","Faz com que as rodas traseiras permaneçam verticais ao carro (como no GTA 3)."},
                    ["2"] = {"AXLE_R_SOLID","Faz com que as rodas traseiras permaneçam paralelas entre si."},
                    ["4"] = {"AXLE_R_MCPHERSON","Faz com que as rodas traseiras inclinem (como no GTA Vice City)."},
                    ["8"] = {"AXLE_R_REVERSE","Faz com que as rodas traseiras inclinem na direção oposta."}
                },
                {
                    ["1"] = {"IS_BIKE","Usa as configurações extras na seção de motos."},
                    ["2"] = {"IS_HELI","Usa as configurações extras na seção de voo."},
                    ["4"] = {"IS_PLANE","Usa as configurações extras na seção de voo."},
                    ["8"] = {"IS_BOAT","Usa as configurações extras na seção de barcos."}
                },
                {
                    ["1"] = {"BOUNCE_PANELS","O efeito dessa caixa não foi testado."}, -- AQUI {não testado}
                    ["2"] = {"DOUBLE_RWHEELS","Isso coloca uma segunda roda traseira ao lado da roda normal."},
                    ["4"] = {"FORCE_GROUND_CLEARANCE","O efeito dessa caixa não foi testado."}, -- AQUI {não testado}
                    ["8"] = {"IS_HATCHBACK","O efeito dessa caixa não foi testado."} -- AQUI {não testado}
                }
            }
        },
        ["handlingFlags"] = {
            friendlyName = "Caixas de Handling",
            information = "Recursos especiais de desempenho.",
            syntax = { "Hexadecimal", "" },
            items = {
                {
                    ["1"] = {"1G_BOOST","Fornece mais potência ao motor para partidas paradas (melhor para subidas íngremes)."},
                    ["2"] = {"2G_BOOST","Fornece mais potência ao motor em velocidades ligeiramente mais altas."},
                    ["4"] = {"NPC_ANTI_ROLL","Desativa a inclinação do corpo ao ser conduzido por personagens de IA."},
                    ["8"] = {"NPC_NEUTRAL_HANDL","Reduz a probabilidade de o veículo derrapar ao ser conduzido por personagens de IA."}
                },
                {
                    ["1"] = {"NO_HANDBRAKE","Desativa o efeito do freio de mão."},
                    ["2"] = {"STEER_REARWHEELS","As rodas traseiras esterçam em vez das rodas dianteiras (como uma empilhadeira)."},
                    ["4"] = {"HB_REARWHEEL_STEER","Faz com que o freio de mão faça as rodas traseiras esterçarem além das rodas dianteiras (como um monster truck)."},
                    ["8"] = {"ALT_STEER_OPT","O efeito dessa caixa não foi testado."} -- AQUI {não testado}
                },
                {
                    ["1"] = {"WHEEL_F_NARROW2","Faz com que as rodas dianteiras sejam muito estreitas."},
                    ["2"] = {"WHEEL_F_NARROW","Faz com que as rodas dianteiras sejam estreitas."},
                    ["4"] = {"WHEEL_F_WIDE","Faz com que as rodas dianteiras sejam largas."},
                    ["8"] = {"WHEEL_F_WIDE2","Faz com que as rodas dianteiras sejam muito largas."}
                },
                {
                    ["1"] = {"WHEEL_R_NARROW2","Faz com que as rodas dianteiras sejam muito estreitas."},
                    ["2"] = {"WHEEL_R_NARROW","Faz com que as rodas dianteiras sejam estreitas."},
                    ["4"] = {"WHEEL_R_WIDE","Faz com que as rodas dianteiras sejam largas."},
                    ["8"] = {"WHEEL_R_WIDE2","Faz com que as rodas dianteiras sejam muito largas."}
                },
                {
                    ["1"] = {"HYDRAULIC_GEOM","O efeito que esta modificação causa não foi testado."}, -- AQUI {não foi testado}
                    ["2"] = {"HYDRAULIC_INST","Faz com que o veículo apareça com o sistema hidráulico instalado."},
                    ["4"] = {"HYDRAULIC_NONE","Desativa a instalação de hidráulica."},
                    ["8"] = {"NOS_INST","Faz com que o veículo apareça com o nitro instalado."}
                },
                {
                    ["1"] = {"OFFROAD_ABILITY","Faz com que o veículo tenha um melhor desempenho em superfícies soltas (como atritos)."},
                    ["2"] = {"OFFROAD_ABILITY2","Faz com que o veículo tenha um melhor desempenho em superfícies macias (como areia)."},
                    ["4"] = {"HALOGEN_LIGHTS","Faz os faróis parecerem mais brilhantes e \"mais azuis\"."},
                    ["8"] = {"PROC_REARWHEEL_1ST","O efeito que modificação causa não foi testado."} -- AQUI {não foi testado}
                },
                {
                    ["1"] = {"USE_MAXSP_LIMIT","Evita que o veículo ultrapasse a velocidade máxima."},
                    ["2"] = {"LOW_RIDER","Permite que o veículo seja modificado nas lojas Loco Low Co."},
                    ["4"] = {"STREET_RACER","Faz com que o veículo seja modificável apenas nos Anjos do Arco da Roda."},
                    ["8"] = {"",""}
                },
                {
                    ["1"] = {"SWINGING_CHASSIS","Permite que a carroceria do carro se movimente de um lado para o outro na suspensão."},
                    ["2"] = {"",""},
                    ["4"] = {"",""},
                    ["8"] = {"",""}
                }
            }
        },
        ["headLight"] = {
            friendlyName = "Faróis Dianteiros",
            information = "Altera o tipo de faróis dianteiros que o veículo terá.",
            syntax = { "Integer", "" },
            options = { ["0"]="Longos",["1"]="Pequenos",["2"]="Grandes",["3"]="Altos" }
        },
        ["tailLight"] = {
            friendlyName = "Faróis Traseiros",
            information = "Altera o tipo de faróis traseiros que o veículo terá.",
            syntax = { "Integer", "" },
            options = { ["0"]="Longos",["1"]="Pequenos",["2"]="Grandes",["3"]="Altos" }
        },
        ["animGroup"] = {
            friendlyName = "Grupo de Animação",
            information = "Altera o grupo de animação que os pedestres usarão ao estar dentro do veículo.",
            syntax = { "Integer", "" }
        }
    }
}
