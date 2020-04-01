--[[**********************************
*
*   Multi Theft Auto - Admin Panel
*
*   client\main\admin.lua
*
*   Original File by lil_Toady
*
**************************************]]
aAdminMain = {
    Form = nil,
    Panel = nil,
    Tabs = {},
    Tab = nil,
    Widgets = {},
    Refresh = 0,
    Hidden = false
}

addEvent(EVENT_SYNC, true)
addEvent("onAdminInitialize", true)
addEvent("onAdminRefresh", false)

addEvent("aClientAdminMenu", true)
addEventHandler(
    "aClientAdminMenu",
    root,
    function()
        if (((aAdminMain.Form) and (guiGetVisible(aAdminMain.Form) == true)) or (aAdminMain.Hidden)) then
            aAdminMain.Close(false)
        else
            aAdminMain.Open()
        end
    end
)

function aAdminMain.Open()
    if (aAdminMain.Form == nil) then
        local x, y = guiGetScreenSize()
        aAdminMain.Form = guiCreateWindow(x / 2 - 372, y / 2 - 312, 744, 624, "Admin Menu - v" .. _version, false)
        guiSetText(aAdminMain.Form, "Admin Menu - v" .. _version)
        guiCreateLabel(0.75, 0.05, 0.45, 0.04, "Admin Panel by lil_Toady", true, aAdminMain.Form)
        aAdminMain.Panel = guiCreateTabPanel(0.01, 0.05, 0.98, 0.95, true, aAdminMain.Form)

        guiSetInputMode('no_binds_when_editing')

        aAdminMain.AddTab("Players", aPlayersTab, "players")
        aAdminMain.AddTab("Resources", aResourcesTab, "resources")
        aAdminMain.AddTab("Server", aServerTab, "server")
        aAdminMain.AddTab("Bans", aBansTab, "bans")
        aAdminMain.AddTab("Admin Chat", aChatTab, "adminchat")
        aAdminMain.AddTab("Rights", aAclTab, "acl")
        -- aAdminMain.AddTab("Network", aNetworkTab)
        aAdminMain.AddTab("Options", aOptionsTab)

        addEventHandler("onClientGUITabSwitched", aAdminMain.Panel, aAdminMain.Switch)
        addEventHandler("onAdminInitialize", aAdminMain.Form, aAdminMain.Initialize)

        triggerEvent("onAdminInitialize", aAdminMain.Form)
    end
    guiSetAlpha(aAdminMain.Form, 0)
    guiBlendElement(aAdminMain.Form, 0.8)
    guiSetVisible(aAdminMain.Form, true)
    showCursor(true)
    aAdminMain.Hidden = false
end

function aAdminMain.Close(destroy, exception)
    if (exception) then
        aAdminMain.Hidden = true
    else
        aAdminMain.Hidden = false
    end
    guiSetInputEnabled(false)
    for name, widget in pairs(aAdminMain.Widgets) do
        if (name ~= exception) then
            widget.close(destroy)
        end
    end
    if (destroy) then
        destroyElement(aAdminMain.Form)
        aAdminMain.Form = nil
    else
        --guiSetVisible ( aAdminMain.Form, false )
        guiBlendElement(aAdminMain.Form, 0, true)
    end
    guiSetInputEnabled(false)
    showCursor(false)
end

function aAdminMain.Initialize()
    if (#aAdminMain.Tabs > 0) then
        aAdminMain.Switch(aAdminMain.Tabs[1].Tab)
    end
end

function aAdminMain.Switch(tab)
    aAdminMain.Tab = tab
    local id = aAdminMain.GetTab(tab)
    if (id) then
        if (not aAdminMain.Tabs[id].Loaded) then
            aAdminMain.Tabs[id].Class.Create(tab)
            aAdminMain.Tabs[id].Loaded = true
        end
    end
end

function aAdminMain.AddTab(name, class, acl)
    assert(class)
    local tab = guiCreateTab(name, aAdminMain.Panel, acl)
    table.insert(aAdminMain.Tabs, {Tab = tab, Class = class, Loaded = false})
end

function aAdminMain.GetTab(tab)
    for k, v in ipairs(aAdminMain.Tabs) do
        if (v.Tab == tab) then
            return k
        end
    end
    return nil
end

function aRegister(name, welement, fopen, fclose)
    aAdminMain.Widgets[name] = {}
    aAdminMain.Widgets[name].element = welement
    aAdminMain.Widgets[name].initialize = fopen
    aAdminMain.Widgets[name].close = fclose
end

addEventHandler(
    "onClientRender",
    root,
    function()
        if (aAdminMain.Form and guiGetVisible(aAdminMain.Form) and aAdminMain.Tab) then
            if (getTickCount() > aAdminMain.Refresh) then
                triggerEvent("onAdminRefresh", aAdminMain.Tab)
                aAdminMain.Refresh = getTickCount() + 100
            end
        end
    end
)
