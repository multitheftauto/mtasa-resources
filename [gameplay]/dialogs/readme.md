# Dialogs

## Description
Create and manage dialogs with callbacks.

## Pictures
![img](https://i.imgur.com/yawOkA6.png)

## Functions

###  MessageBeep

**Description**<br>
This function plays a sound from the **messageSounds** table.

**Syntax**
```lua
messageBeep( string soundType, [ int soundVolume ] )
```

**Example**
> This example plays an info sound with the default volume (1)
```lua
messageBeep("INFO")
```

<br>

> This example plays a question sound with specified volume (0.5)
```lua
messageBeep("QUESTION", 0.5)
```

**Arguments**
> - soundType: A string specifying the sound data, which is in the **messageSounds** table.
> - soundVolume: An integer between 1 and 0 that specifies the volume. (optional)

<br>

**Returns**<br>
Returns the sound element.

###  MessageBox

**Description**<br>
This function creates a dialog box with a callback function.

**Syntax**
```lua
messageBox( string messageTitle, string messageContent, string messageCallback, [ string messageIcon, string messageButton, int messageButtonDefault, string messageSound, int messageSoundVolume] )
```

**Example**
> This example creates a dialog containing an information.
```lua
messageBox("Welcome", "Multi Theft Auto provides the best online Grand Theft Auto experience there is.", "callbackFunction", "INFO", "OK")
```

```lua
function callbackFunction(callbackResult)
    if callbackResult == "OK" then
        print("Read")
    end
end
```

<br>

> This example creates a dialog containing a question.
```lua
messageBox("Save", "Are you sure you want to save your changes? This action will overwrite your previous saves.", "callbackFunction", "QUESTION", "YESNOCANCEL")
```

```lua
function callbackFunction(callbackResult)
    if callbackResult == "YES" then
        print("Save")
    elseif callbackResult == "NO" then
        print("Undo")
    else
        print("Cancel")
    end
end
```

<br>

> This example creates a dialog containing a warning.
```lua
messageBox("Mismatch", "The selected file does not exist. Would you like to try the download again?", "callbackFunction", "WARNING", "ABORTRETRYIGNORE")
```

```lua
function callbackFunction(callbackResult)
    if callbackResult == "ABORT" then
        print("Abort")
    elseif callbackResult == "RETRY" then
        print("Retry")
    else
        print("Ignore")
    end
end
```

<br>

> This example creates a dialog containing an error.
```lua
messageBox("Your wallet is empty", "You do not have enough money to purchase the selected vehicle.", "callbackFunction", "ERROR", "OK")
```

```lua
function callbackFunction(callbackResult)
    if callbackResult == "OK" then
        print("Read")
    end
end
```

**Arguments**
> - messageTitle: A string specifing the title of the message (note that it will be always uppercase)
> - messageContent: A string specifing the content of the message
> - messageCallback: A string specifying the name of the function that will be exported when a button is pressed. (Note that you must specify the function name as a string and specify the function as exportable in the meta.xml of the source.)
> - messageIcon: A string specifing the icon of the message, which is in the **messageIcons** table.
> - messageButton: A string specifing the button(s) of the message, which is in the **messageButtons** table.
> - messageButtonDefault: An integer specifing the default button (note that it will receive a bolder font)
> - messageSound: A string specifing the sound of the message, which is in the **messageSounds** table.
> - messageSoundVolume: An integer between 1 and 0 specifing the volume of the sound.
<br>

**Returns**<br>
This function does not contain returns because it uses a callback function.

###  MessageBoxEx

**Description**<br>
This function creates a dialog box without a callback function.

**Syntax**
```lua
messageBoxEx( string messageTitle, string messageContent, [ string messageIcon, string messageButton, int messageButtonDefault, string messageSound, int messageSoundVolume] )
```

**Example**
> This example creates a dialog containing an information.
```lua
local buttonOK = messageBoxEx("Welcome", "Multi Theft Auto provides the best online Grand Theft Auto experience there is.", "INFO", "OK")

addEventHandler("onClientGUIClick", buttonOK,
    function()
        print("Read")
    end
)
```

<br>

> This example creates a dialog containing a question.
```lua
local buttonYes, buttonNo, buttonCancel = messageBoxEx("Save", "Are you sure you want to save your changes? This action will overwrite your previous saves.", "QUESTION", "YESNOCANCEL")

addEventHandler("onClientGUIClick", buttonYes,
    function()
        print("Save")
    end
)

addEventHandler("onClientGUIClick", buttonNo,
    function()
        print("Undo")
    end
)

addEventHandler("onClientGUIClick", buttonCancel,
    function()
        print("Cancel")
    end
)
```

<br>

> This example creates a dialog containing a warning.
```lua
local buttonAbort, buttonRetry, buttonIgnore = messageBoxEx("Save", "Are you sure you want to save your changes? This action will overwrite your previous saves.", "QUESTION", "YESNOCANCEL")

addEventHandler("onClientGUIClick", buttonAbort,
    function()
        print("Abort")
    end
)

addEventHandler("onClientGUIClick", buttonRetry,
    function()
        print("Retry")
    end
)

addEventHandler("onClientGUIClick", buttonIgnore,
    function()
        print("Ignore")
    end
)
```

<br>

> This example creates a dialog containing an error.
```lua
local buttonOK = messageBoxEx("Your wallet is empty", "You do not have enough money to purchase the selected vehicle.", "ERROR", "OK")

addEventHandler("onClientGUIClick", buttonOK,
    function()
        print("Read")
    end
)
```

**Arguments**
> - messageTitle: A string specifing the title of the message (note that it will be always uppercase)
> - messageContent: A string specifing the content of the message
> - messageIcon: A string specifing the icon of the message, which is in the **messageIcons** table.
> - messageButton: A string specifing the button(s) of the message, which is in the **messageButtons** table.
> - messageButtonDefault: An integer specifing the default button (note that it will receive a bolder font)
> - messageSound: A string specifing the sound of the message, which is in the **messageSounds** table.
> - messageSoundVolume: An integer between 1 and 0 specifing the volume of the sound.
<br>

**Returns**<br>
Returns as many buttons in order as specified in the messageButton argument.