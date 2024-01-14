--[[
	core_s.lua

    Main server script for the New Models Freeroam system.

	Author: https://github.com/Fernando-A-Rocha
]]

----------- GENERAL SCRIPT CONFIGURATION -----------

COMMAND_NAMES = { "newmodelsfreeroam", "newmodels_freeroam", "freeroam_newmodels", "freeroamnewmodels" }

function canUseTool(player)
    return hasObjectPermissionTo(player, "command.start", false) and hasObjectPermissionTo(player, "command.stop", false)
end

local FREEROAM_GUI_XML_GROUP_NAMES = {
    ["vehicles"] = "New Models",
    ["skins"] = "New Models",
}

----------- FUNCTIONALITIES -----------

local waitingFreeroamStop = nil

local function getModelGroupNames(rootChildrenNodes, theType)
    local groupNames = {} -- [id] = name
    local function getGroupNames(node)
        if xmlNodeGetName(node) == "group" then
            local children = xmlNodeGetChildren(node)
            if children then
                local parentName = xmlNodeGetAttribute(node, "name")
                if parentName then
                    for i, child in ipairs(children) do
                        local id = tonumber(xmlNodeGetAttribute(child, "id"))
                        if id then
                            if groupNames[id] then
                                -- outputDebugString("Model "..id.." is already in group "..groupNames[id]..", skipping.", 2)
                                return
                            end
                            groupNames[id] = parentName
                        end
                        if xmlNodeGetName(child) == "group" then
                            getGroupNames(child)
                        end
                    end
                end
            end
        end
    end
    for i, node in ipairs(rootChildrenNodes) do
        getGroupNames(node)
    end
    return groupNames
end

--[[
    Updates the freeroam vehicle & skins XML list with thew new models.
    This cannot be done live when freeroam is running because the XML files are
    loaded as config files in meta.xml and it would be a mess to reload them.
]]
local function updateFreeroamGUIFiles()
    local VEHICLES_PATH = ":freeroam/data/vehicles.xml"
    local SKINS_PATH = ":freeroam/data/skins.xml"

    local groupNames = {}
    if not FREEROAM_GUI_XML_GROUP_NAMES then
        return false, "The freeroam GUI group names are not defined."
    end
    if not FREEROAM_GUI_XML_GROUP_NAMES["vehicles"] then
        return false, "The freeroam GUI vehicles group name is not defined."
    end
    if not FREEROAM_GUI_XML_GROUP_NAMES["skins"] then
        return false, "The freeroam GUI skins group name is not defined."
    end
    groupNames["vehicles"] = FREEROAM_GUI_XML_GROUP_NAMES["vehicles"]
    groupNames["skins"] = FREEROAM_GUI_XML_GROUP_NAMES["skins"]

    if not (fileExists(VEHICLES_PATH) and fileExists(SKINS_PATH)) then
        return false, "The freeroam GUI files could not be found."
    end

    local allMods = exports.newmodels:getModList()
    if not allMods then
        return false, "Failed to get the newmodels mod list."
    end

    local modsList = {
        ["vehicles"] = {},
        ["skins"] = {}
    }

    for elementType, mods in pairs(allMods) do
        if type(elementType) ~= "string" or type(mods) ~= "table" then
            return false, "The newmodels mod list is not valid."
        end
        for i, mod in ipairs(mods) do
            if type(mod) ~= "table" then
                return false, "Mod #"..i.." is not a table."
            end
            local modID = mod.id
            local modBaseID = mod.base_id
            local modName = mod.name

            if type(modID) ~= "number" or type(modBaseID) ~= "number" or type(modName) ~= "string" then
                return false, "Mod #"..i.." is not valid."
            end

            if elementType == "vehicle" then
                table.insert(modsList["vehicles"], {id = modID, base_id = modBaseID, name = modName})
            elseif elementType == "ped" then
                table.insert(modsList["skins"], {id = modID, base_id = modBaseID, name = modName})
            end
        end
    end

    local function addNewModels(theType)
        
        local path = VEHICLES_PATH
        if theType == "skins" then
            path = SKINS_PATH
        end

        local xmlRoot = xmlLoadFile(path)
        if not xmlRoot then
            return false, "Failed to load file: "..path
        end
        local groupNodes = xmlNodeGetChildren(xmlRoot)
        if not groupNodes then
            return false, "Failed to get the group nodes from file: "..path
        end
        for i, groupNode in ipairs(groupNodes) do
            local groupName = xmlNodeGetAttribute(groupNode, "name")
            if groupName and groupName == groupNames[theType] then
                xmlDestroyNode(groupNode)
                break
            end
        end
        groupNodes = xmlNodeGetChildren(xmlRoot)
        if not groupNodes then
            return false, "Failed to get the group nodes from file: "..path
        end
        local defaultGroupNames = getModelGroupNames(groupNodes, xmlNodeGetAttribute(xmlRoot, "type"))

        local parentGroupNode = xmlCreateChild(xmlRoot, "group")
        xmlNodeSetAttribute(parentGroupNode, "name", groupNames[theType])
        local usedGroupNames = {}
        local usedModelGroupNames = {}
        for i, mod in ipairs(modsList[theType]) do
            local modelBaseID = mod.base_id
            local groupName = defaultGroupNames[modelBaseID]
            if not groupName then
                groupName = "Other"
            end
            if not usedGroupNames[groupName] then
                usedGroupNames[groupName] = true
            end
            usedModelGroupNames[modelBaseID] = groupName
        end
        local usedGroupNodes = {}
        for groupName, _ in pairs(usedGroupNames) do
            local groupNode = xmlCreateChild(parentGroupNode, "group")
            xmlNodeSetAttribute(groupNode, "name", groupName)
            usedGroupNodes[groupName] = groupNode
        end

        local count = 0
        for i, mod in ipairs(modsList[theType]) do
            local modelID = mod.id
            local modelBaseID = mod.base_id
            local modelName = mod.name
            local groupName = usedModelGroupNames[modelBaseID]
            local groupNode = usedGroupNodes[groupName]
            local tagName = string.sub(theType, 1, -2)
            local modelNode = xmlCreateChild(groupNode, tagName)
            xmlNodeSetAttribute(modelNode, "id", modelID)
            xmlNodeSetAttribute(modelNode, "base_model", modelBaseID)
            xmlNodeSetAttribute(modelNode, "name", modelName)
            count = count + 1
        end

        xmlSaveFile(xmlRoot)
        xmlUnloadFile(xmlRoot)

        return count
    end

    local theTypeCounts = {}
    for theType, _ in pairs(modsList) do
        local count, errorMessage = addNewModels(theType)
        if not count then
            return false, errorMessage
        end

        theTypeCounts[theType] = count
    end

    return theTypeCounts
end

function freeroamStopped()
    if not waitingFreeroamStop then return end

    setTimer(function()

        local thePlayer, cmd = waitingFreeroamStop[1], waitingFreeroamStop[2]
        waitingFreeroamStop = nil

        if thePlayer~="SYSTEM" and isElement(thePlayer) then
            updateFreeroamNewModels(thePlayer, cmd)
        else
            updateFreeroamNewModels()
        end

    end, 50, 1)
end

--[[
    Runs the tool
]]
function updateFreeroamNewModels(thePlayer, cmd)

    if (waitingFreeroamStop ~= nil) then
        if isElement(thePlayer) then
            outputChatBox("Please wait for the freeroam resource to stop.", thePlayer, 255, 22, 22)
        end
        return 
    end

    local freeroam = getResourceFromName("freeroam")
    if not freeroam then
        if isElement(thePlayer) then
            outputChatBox("The 'freeroam' resource could not be found.", thePlayer, 255, 22, 22)
        end
        return
    end
    
    if getResourceState(freeroam) == "running" then
        local freeroamRoot = getResourceRootElement(freeroam)
        addEventHandler("onResourceStop", freeroamRoot, freeroamStopped)

        if isElement(thePlayer) then
            waitingFreeroamStop = {thePlayer, cmd}
        else
            waitingFreeroamStop = {"SYSTEM"}
        end

        if not stopResource(freeroam) then

            if isElement(thePlayer) then
                outputChatBox("Failed to stop the 'freeroam' resource.", thePlayer, 255, 22, 22)
                outputChatBox("  Try to stop the resource manually (/stop freeroam).", thePlayer, 255, 22, 22)
            else
                outputDebugString("Failed to stop the 'freeroam' resource.", 1)
            end
            
            removeEventHandler("onResourceStop", freeroamRoot, freeroamStopped)
            waitingFreeroamStop = nil
            return
        end
        for _, player in ipairs(getElementsByType("player")) do
            playSoundFrontEnd(player, 40)
            outputChatBox("[New-Models Freeroam] The freeroam resource is now restarting to apply changes...", player, 255, 255, 22)
        end
        return
    end

    local result, reason = updateFreeroamGUIFiles()
    if not result then
        if isElement(thePlayer) then
            outputChatBox("Failed to update the freeroam GUI files: "..reason, thePlayer, 255, 22, 22)
        else
            outputDebugString("Failed to update the freeroam GUI files: "..reason, 1)
        end
        return
    end

    if isElement(thePlayer) then
        outputChatBox("The freeroam GUI files have been updated.", thePlayer, 22, 255, 22)

        local added = {}
        for theType, count in pairs(result) do
            added[#added+1] = count.." new "..theType
        end
        outputChatBox("  Added: "..(table.concat(added, ", ")), thePlayer, 222, 222, 222)
    else
        outputDebugString("Updated the freeroam GUI files:", 3)
        outputDebugString(inspect(result), 3)
    end

    local freeroamState = getResourceState(freeroam)
    if freeroamState == "loaded" then
        if not startResource(freeroam, true) then
            if isElement(thePlayer) then
                outputChatBox("Failed to start the resource 'freeroam'.", thePlayer, 255, 22, 22)
            else
                outputDebugString("Failed to start the resource 'freeroam'.", 1)
            end
            return 
        end
    else
        if isElement(thePlayer) then
            outputChatBox("The 'freeroam' resource is currently "..freeroamState..".", thePlayer, 255, 255, 22)
            outputChatBox("  Try to start the resource manually (/start freeroam).", thePlayer, 255, 255, 22)
        else
            outputDebugString("The 'freeroam' resource is currently "..freeroamState..".", 2)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, updateFreeroamNewModels)

function newModelsFreeroamCmd(thePlayer, cmd)
    if not canUseTool(thePlayer) then
        return outputChatBox("You don't have permission to use /"..cmd..".", thePlayer, 255, 22, 22)
    end

    updateFreeroamNewModels(thePlayer, cmd)
end
for i, cmd in ipairs(COMMAND_NAMES) do
    addCommandHandler(cmd, newModelsFreeroamCmd, false, false)
end
