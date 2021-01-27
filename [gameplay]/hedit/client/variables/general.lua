scrX, scrY = guiGetScreenSize()

guiTemplate = {}
guiLanguage = {}

guiElements = {}
guiID = {}

resetGUI = {
    background = {},
    viewButtons = {},
    viewItems = {},
    menuButtons = {},
    menuItems = {},
    specials = {}
}
heditGUI = resetGUI

staticinfo = {
    header = "",
    text = ""
}

pData = {
    userconfig = {}
}

centerOfMassModes = {
    "splitted",
    "concatenated"
}

logCreated = false
logItems = {}

hiddenEditBox = nil
openedEditBox = nil
pointedButton = nil
buttonValue = nil
buttonHoverColor = nil
pressedKey = nil

errorColor = {
    { 255, 255, 255 },
    { 227, 214, 0   },
    { 200, 0,   0   } 
}