local langs = {}
local addEvent = addEvent
local addEventHandler = addEventHandler
local resourceRoot = resourceRoot

local playerLocalization
local defaultLanguage = "en_US"

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        playerLocalization = getLocalization().code

        triggerServerEvent("langs.sendLocalization", localPlayer, playerLocalization)
    end
)

addEvent("langs.sendClient", true)
addEventHandler("langs.sendClient", root,
    function(data)
        langs = data
    end
)

function _(str)
    assert(str, "The value to be translated was empty.")

    local languageData = langs[playerLocalization]
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