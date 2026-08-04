local GUI = {
    button = {},
    window = {},
    label = {},
    edit = {}
}

local isWindowOpen = false

function createLicenseWindow()
    if GUI.window[1] then return end 

    GUI.window[1] = guiCreateWindow(671, 319, 307, 152, "License plate", false)
    guiWindowSetSizable(GUI.window[1], false)

    GUI.edit[1] = guiCreateEdit(13, 46, 284, 44, "", false, GUI.window[1])
    GUI.label[1] = guiCreateLabel(16, 23, 281, 19, "Specify the number you want to install.", false, GUI.window[1])
    guiSetFont(GUI.label[1], "default-bold-small")

    GUI.button[1] = guiCreateButton(9, 104, 129, 38, "Set the number", false, GUI.window[1])
    GUI.button[2] = guiCreateButton(168, 104, 129, 38, "Cancel", false, GUI.window[1])

    guiSetVisible(GUI.window[1], false)
end

function showLicenseWindow()
    if isWindowOpen then
        hideLicenseWindow()
        return
    end

    if not GUI.window[1] then
        createLicenseWindow()
    end
    guiSetVisible(GUI.window[1], true)
    guiSetInputEnabled(true)
    guiBringToFront(GUI.window[1])
    guiSetText(GUI.edit[1], "") 
    isWindowOpen = true
end

function hideLicenseWindow()
    if GUI.window[1] then
        guiSetVisible(GUI.window[1], false)
        guiSetInputEnabled(false)
        isWindowOpen = false
    end
end

addCommandHandler("setplate", showLicenseWindow)
addCommandHandler("license", showLicenseWindow)

function onClientGUIClick(button, state)
    if button ~= "left" or state ~= "up" then return end
    local clicked = source
    if clicked == GUI.button[1] then
        local plate = guiGetText(GUI.edit[1])
        plate = plate:gsub("^%s*(.-)%s*$", "%1")

        if plate == "" then
            outputChatBox("Please enter a license plate number.", 255, 0, 0)
            return
        end

        if #plate > 8 then
            outputChatBox("License plate cannot exceed 8 characters.", 255, 0, 0)
            return
        end

        -- (Optionally – uncomment if necessary)
        -- if not string.match(plate, "^[A-Za-z0-9 ]+$") then
        --     outputChatBox("License plate contains invalid characters. Use only letters, numbers and spaces.", 255, 0, 0)
        --     return
        -- end

        local vehicle = getPedOccupiedVehicle(localPlayer)
        if not vehicle then
            outputChatBox("You are not in a vehicle.", 255, 0, 0)
            return
        end

        triggerServerEvent("LicensePlate:set", localPlayer, vehicle, plate)
        hideLicenseWindow()

    elseif clicked == GUI.button[2] then
        hideLicenseWindow()
    end
end
addEventHandler("onClientGUIClick", root, onClientGUIClick)