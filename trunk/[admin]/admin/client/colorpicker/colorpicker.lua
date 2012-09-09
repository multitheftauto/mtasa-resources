sw, sh = guiGetScreenSize()

pickerTable = {}

colorPicker = {}
colorPicker.__index = colorPicker

function openPicker(id, start, title)
  if id and not pickerTable[id] then
    pickerTable[id] = colorPicker.create(id, start, title)
    pickerTable[id]:updateColor()
    return true
  end
  return false
end

function closePicker(id)
  if id and pickerTable[id] then
    pickerTable[id]:destroy()
    return true
  end
  return false
end


function colorPicker.create(id, start, title)
  local cp = {}
  setmetatable(cp, colorPicker)
  cp.id = id
  cp.color = {}
  cp.color.h, cp.color.s, cp.color.v, cp.color.r, cp.color.g, cp.color.b, cp.color.hex = 0, 1, 1, 255, 0, 0, "#FF0000"
  cp.color.white = tocolor(255,255,255,255)
  cp.color.black = tocolor(0,0,0,255)
  cp.color.current = tocolor(255,0,0,255)
  cp.color.huecurrent = tocolor(255,0,0,255)
  if start and getColorFromString(start) then
    cp.color.h, cp.color.s, cp.color.v = rgb2hsv(getColorFromString(start))
  end
  cp.gui = {}
  cp.gui.width = 416
  cp.gui.height = 304
  cp.gui.snaptreshold = 0.02
  cp.gui.window = guiCreateWindow((sw-cp.gui.width)/2, (sh-cp.gui.height)/2, cp.gui.width, cp.gui.height, tostring(title or "COLORPICKER"), false)
  cp.gui.svmap = guiCreateStaticImage(16, 32, 256, 256, "client/colorpicker/blank.png", false, cp.gui.window)
  cp.gui.hbar = guiCreateStaticImage(288, 32, 32, 256, "client/colorpicker/blank.png", false, cp.gui.window)
  cp.gui.blank = guiCreateStaticImage(336, 32, 64, 64, "client/colorpicker/blank.png", false, cp.gui.window)
  cp.gui.edith = guiCreateLabel(338, 106, 64, 20, "H: 0°", false, cp.gui.window)
  cp.gui.edits = guiCreateLabel(338, 126, 64, 20, "S: 100%", false, cp.gui.window)
  cp.gui.editv = guiCreateLabel(338, 146, 64, 20, "V: 100%", false, cp.gui.window)
  cp.gui.editr = guiCreateLabel(338, 171, 64, 20, "R: 255", false, cp.gui.window)
  cp.gui.editg = guiCreateLabel(338, 191, 64, 20, "G: 0", false, cp.gui.window)
  cp.gui.editb = guiCreateLabel(338, 211, 64, 20, "B: 0", false, cp.gui.window)
  cp.gui.okb = guiCreateButton(336, 235, 64, 24, "OK", false, cp.gui.window)
  cp.gui.closeb = guiCreateButton(336, 265, 64, 24, "Cancel", false, cp.gui.window)
  guiWindowSetSizable(cp.gui.window, false)	

  cp.handlers = {}
  cp.handlers.mouseDown = function() cp:mouseDown() end
  cp.handlers.mouseSnap = function() cp:mouseSnap() end
  cp.handlers.mouseUp = function(b,s) cp:mouseUp(b,s) end
  cp.handlers.mouseMove = function(x,y) cp:mouseMove(x,y) end
  cp.handlers.render = function() cp:render() end
  cp.handlers.guiFocus = function() cp:guiFocus() end
  cp.handlers.guiBlur = function() cp:guiBlur() end
  cp.handlers.pickColor = function() cp:pickColor() end
  cp.handlers.destroy = function() cp:destroy() end
  
  addEventHandler("onClientGUIMouseDown", cp.gui.svmap, cp.handlers.mouseDown, false)
  addEventHandler("onClientMouseLeave", cp.gui.svmap, cp.handlers.mouseSnap, false)
  addEventHandler("onClientMouseMove", cp.gui.svmap, cp.handlers.mouseMove, false)
  addEventHandler("onClientGUIMouseDown", cp.gui.hbar, cp.handlers.mouseDown, false)
  addEventHandler("onClientMouseMove", cp.gui.hbar, cp.handlers.mouseMove, false)
  addEventHandler("onClientClick", root, cp.handlers.mouseUp)
  addEventHandler("onClientGUIMouseUp", root, cp.handlers.mouseUp)
  addEventHandler("onClientRender", root, cp.handlers.render)
  addEventHandler("onClientGUIFocus", cp.gui.window, cp.handlers.guiFocus, false)
  addEventHandler("onClientGUIBlur", cp.gui.window, cp.handlers.guiBlur, false)
  addEventHandler("onClientGUIClick", cp.gui.okb, cp.handlers.pickColor, false)
  addEventHandler("onClientGUIClick", cp.gui.closeb, cp.handlers.destroy, false)  
  showCursor(true)
  return cp
end

function colorPicker:render()
  -- if not self.gui.focus then return end
  local x,y = guiGetPosition(self.gui.window, false)
  dxDrawRectangle(x+16, y+32, 256, 256, self.color.huecurrent, self.gui.focus)
  dxDrawImage(x+16, y+32, 256, 256, "client/colorpicker/sv.png", 0, 0, 0, self.color.white, self.gui.focus)
  dxDrawImage(x+288, y+32, 32, 256, "client/colorpicker/h.png", 0, 0, 0, self.color.white, self.gui.focus)
  dxDrawImageSection(x+8+math.floor(256*self.color.s), y+24+(256-math.floor(256*self.color.v)), 16, 16, 0, 0, 16, 16, "client/colorpicker/cursor.png", 0, 0, 0, self.color.white, self.gui.focus)
  dxDrawImageSection(x+280, y+24+(256-math.floor(256*self.color.h)), 48, 16, 16, 0, 48, 16, "client/colorpicker/cursor.png", 0, 0, 0, self.color.huecurrent, self.gui.focus)
  dxDrawRectangle(x+336, y+32, 64, 64, self.color.current, self.gui.focus)
  dxDrawText(self.color.hex, x+336, y+32, x+400, y+96, self.color.v < 0.5 and self.color.white or self.color.black, 1, "default", "center", "center", true, true, self.gui.focus)
end

function colorPicker:mouseDown()
  if source == self.gui.svmap or source == self.gui.hbar then
    self.gui.track = source
    local cx, cy = getCursorPosition()
    self:mouseMove(sw*cx, sh*cy)
  end  
end

function colorPicker:mouseUp(button, state)
  if not state or state ~= "down" then
    if self.gui.track then 
      triggerEvent("onColorPickerChange", root, self.id, self.color.hex, self.color.r, self.color.g, self.color.b) 
    end
    self.gui.track = false 
  end  
end

function colorPicker:mouseMove(x,y)
  if self.gui.track and source == self.gui.track then
    local gx,gy = guiGetPosition(self.gui.window, false)
    if source == self.gui.svmap then
      local offsetx, offsety = x - (gx + 16), y - (gy + 32)
      self.color.s = offsetx/255
      self.color.v = (255-offsety)/255
    elseif source == self.gui.hbar then
      local offset = y - (gy + 32)
      self.color.h = (255-offset)/255
    end 
    self:updateColor()
  end
end

function colorPicker:mouseSnap()
  if self.gui.track and source == self.gui.track then
    if self.color.s < self.gui.snaptreshold or self.color.s > 1-self.gui.snaptreshold then self.color.s = math.round(self.color.s) end
    if self.color.v < self.gui.snaptreshold or self.color.v > 1-self.gui.snaptreshold then self.color.v = math.round(self.color.v) end
    self:updateColor()
  end
end

function colorPicker:updateColor()
  self.color.r, self.color.g, self.color.b = hsv2rgb(self.color.h, self.color.s, self.color.v)
  self.color.current = tocolor(self.color.r, self.color.g, self.color.b,255)
  self.color.huecurrent = tocolor(hsv2rgb(self.color.h, 1, 1))
  self.color.hex = string.format("#%02X%02X%02X", self.color.r, self.color.g, self.color.b)
  guiSetText(self.gui.edith, "H: "..tostring(math.round(self.color.h*360)).."°")
  guiSetText(self.gui.edits, "S: "..tostring(math.round(self.color.s*100)).."%")
  guiSetText(self.gui.editv, "V: "..tostring(math.round(self.color.v*100)).."%")
  guiSetText(self.gui.editr, "R: "..tostring(self.color.r))
  guiSetText(self.gui.editg, "G: "..tostring(self.color.g))
  guiSetText(self.gui.editb, "B: "..tostring(self.color.b))
end


function colorPicker:guiFocus()
  self.gui.focus = true
  guiSetAlpha(self.gui.window, 1)
end

function colorPicker:guiBlur()
  self.gui.focus = false
  guiSetAlpha(self.gui.window, 0.5)
end

function colorPicker:pickColor()
  triggerEvent("onColorPickerOK", root, self.id, self.color.hex, self.color.r, self.color.g, self.color.b)
  self:destroy()
end

function colorPicker:destroy()
  removeEventHandler("onClientGUIMouseDown", self.gui.svmap, self.handlers.mouseDown)
  removeEventHandler("onClientMouseLeave", self.gui.svmap, self.handlers.mouseSnap)
  removeEventHandler("onClientMouseMove", self.gui.svmap, self.handlers.mouseMove)
  removeEventHandler("onClientGUIMouseDown", self.gui.hbar, self.handlers.mouseDown)
  removeEventHandler("onClientMouseMove", self.gui.hbar, self.handlers.mouseMove)
  removeEventHandler("onClientClick", root, self.handlers.mouseUp)
  removeEventHandler("onClientGUIMouseUp", root, self.handlers.mouseUp)
  removeEventHandler("onClientRender", root, self.handlers.render)
  removeEventHandler("onClientGUIFocus", self.gui.window, self.handlers.guiFocus)
  removeEventHandler("onClientGUIBlur", self.gui.window, self.handlers.guiBlur)
  removeEventHandler("onClientGUIClick", self.gui.okb, self.handlers.pickColor)
  removeEventHandler("onClientGUIClick", self.gui.closeb, self.handlers.destroy)  
  destroyElement(self.gui.window)
  pickerTable[self.id] = nil
  setmetatable(self, nil)
  --showCursor(areThereAnyPickers())
end

function areThereAnyPickers()
  for _ in pairs(pickerTable) do
    return true
  end
  return false
end

function hsv2rgb(h, s, v)
  local r, g, b
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)
  local switch = i % 6
  if switch == 0 then
    r = v g = t b = p
  elseif switch == 1 then
    r = q g = v b = p
  elseif switch == 2 then
    r = p g = v b = t
  elseif switch == 3 then
    r = p g = q b = v
  elseif switch == 4 then
    r = t g = p b = v
  elseif switch == 5 then
    r = v g = p b = q
  end
  return math.floor(r*255), math.floor(g*255), math.floor(b*255)
end

function rgb2hsv(r, g, b)
  r, g, b = r/255, g/255, b/255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s 
  local v = max
  local d = max - min
  s = max == 0 and 0 or d/max
  if max == min then 
    h = 0
  elseif max == r then 
    h = (g - b) / d + (g < b and 6 or 0)
  elseif max == g then 
    h = (b - r) / d + 2
  elseif max == b then 
    h = (r - g) / d + 4
  end
  h = h/6
  return h, s, v
end

function math.round(v)
  return math.floor(v+0.5)
end

addEvent("onColorPickerOK", true)
addEvent("onColorPickerChange", true)