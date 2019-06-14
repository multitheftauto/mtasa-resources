addEvent("onChat2SendMessage", true)
addEvent("onPlayerChat2")

local isDefaultOutput = true
local minLength = 1
local maxLength = 96

function clear(player)
  triggerClientEvent(player, "onChat2Clear", player)
end

function show(player, bool)
  triggerClientEvent(player, "onChat2Show", player, bool)
end

function isVisible(player)
  return getElementData(player, "chat2IsVisible", false)
end

function output(player, message)
  triggerClientEvent(player, "onChat2Output", player, message)
end

function useDefaultOutput(bool)
  isDefaultOutput = bool
end

function onChatSendMessage(message)
  local sender = client
  local nickname = getPlayerName(sender)

  if type(message) ~= "string" or utf8.len(message) < minLength or utf8.len(message) > maxLength then
    return
  end

  if utf8.sub(message, 0, 1) == "/" then
    handleCommand(sender, message)
    return
  end

  if not isDefaultOutput then
    triggerEvent("onPlayerChat2", root, sender, message)
    return
  end

  for _, player in ipairs(getElementsByType("player")) do
    local text = string.format("%s#ffffff: %s", nickname, message)
    output(player, text)
    outputServerLog(text)
  end
end

function handleCommand(client, input)
  local splittedInput = split(input, " ")
  local cmd = utf8.sub(splittedInput[1], 2, utf8.len(splittedInput[1]))
  local args = {}

  for i, arg in ipairs(splittedInput) do
    if (i ~= 1) then
      args[i - 1] = arg
    end
  end

  for i, part in ipairs(splittedInput) do
    if i == 1 then
      cmd = utf8.sub(part, i + 1, utf8.len(part))
    end
  end

  executeCommandHandler(cmd, client, unpack(args))
end

addEventHandler("onChat2SendMessage", resourceRoot, onChatSendMessage)
