local chatInstance
local chatInstanceLoading
local chatInstanceLoaded

addEvent("onChat2Loaded")
addEvent("onChat2Input")
addEvent("onChat2SendMessage")
addEvent("onChat2Output", true)
addEvent("onChat2Clear", true)
addEvent("onChat2Show", true)

function execute(eval)
  executeBrowserJavascript(chatInstance, eval)
end

function create()
  chatInstance = guiGetBrowser(guiCreateBrowser(0.01, 0.01, 0.25, 0.4, true, true, true))
  chatInstanceLoading = true
  addEventHandler("onClientBrowserCreated", chatInstance, load)
end

function load()
  loadBrowserURL(chatInstance, "http://mta/local/index.html")
end

function output(message)
  if not chatInstanceLoaded then
    return setTimer(output, 250, 1, message)
  end

  local eval = string.format("addMessage(%s)", toJSON(message))
  execute(eval)
end

function clear()
  local eval = "clear()"
  execute(eval)
end

function show(bool)
  if chatInstanceLoaded ~= true then
    if chatInstanceLoading ~= true then
      create()
      setTimer(show, 300, 1, bool)
    else
      setTimer(show, 300, 1, bool)
    end
  end

  local eval = "show(" .. tostring(bool) .. ");"
  execute(eval)
  setElementData(localPlayer, "chat2IsVisible", bool)
end

function isVisible()
  return getElementData(localPlayer, "chat2IsVisible", false)
end

function onResourceStart()
  showChat(false)
  show(true)
end

function onChatLoaded()
  chatInstanceLoaded = true
  focusBrowser(chatInstance)
end

function onChatInput(isActive)
  if isActive == "true" then
    guiSetInputEnabled(true)
  else
    guiSetInputEnabled(false)
  end
end

function onChatSendMessage(message)
  triggerServerEvent("onChat2SendMessage", resourceRoot, message)
end

addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)
addEventHandler("onChat2Loaded", resourceRoot, onChatLoaded)
addEventHandler("onChat2Input", resourceRoot, onChatInput)
addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
addEventHandler("onChat2Output", localPlayer, output)
addEventHandler("onChat2Clear", localPlayer, clear)
addEventHandler("onChat2Show", localPlayer, show)
