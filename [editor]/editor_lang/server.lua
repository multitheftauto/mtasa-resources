local langs = {}
local playerLocalizations = {}
local addEvent = addEvent
local addEventHandler = addEventHandler
local resourceRoot = resourceRoot

local defaultLanguage = "en_US"

addEventHandler("onResourceStart", resourceRoot,
    function()
        local file = fileOpen("langs/langs.json")
        if file then
            local fileContent = fromJSON( fileRead( file, fileGetSize(file) ) ) or {}
            if fileContent then
                for index, lang in ipairs(fileContent) do
                    local langFile = fileOpen( ("langs/%s.json"):format(lang) )
                    if langFile then
                        local langContent = fromJSON( fileRead( langFile, fileGetSize(langFile) ) ) or {}
                        langs[lang] = langContent
                    end
                end
            end
        end
    end
)

addEvent("langs.sendLocalization", true)
addEventHandler("langs.sendLocalization", root,
    function(country)
        playerLocalizations[source] = country

        triggerClientEvent(source, "langs.sendClient", source, langs)
        addEventHandler("onPlayerQuit", source,
            function()
                playerLocalizations[source] = nil
                collectgarbage("collect")
            end
        )
    end
)

function _(player, str)
    assert(isElement(player), "The first argument must be an element.")
    assert(str, "The value to be translated was empty.")

    local languageData = langs[playerLocalizations[player]]
    if not languageData then
        languageData = langs[defaultLanguage]
    end

    if languageData[str] then
        return languageData[str]
    else
        if langs[defaultLanguage][str] then
            return langs[defaultLanguage][str]
        end
        return false, "EMPTY_STR"
    end
    return false, "EMPTY_STR"
end