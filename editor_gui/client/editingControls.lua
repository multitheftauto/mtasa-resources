addEvent "onClientGUIMouseDown"
addEvent "onClientDropDownSelect"
addEvent "onClientDropDownOpen"

addEvent "onClientControlBrowserLaunch"
addEvent "onClientControlBrowserClose"

local guiRoot = getResourceGUIElement(getThisResource())

local catalogTypes = {
	objectID  = true,
	vehicleID = true,
	skinID	= true,
}

local dropdownTypes = {
	markerType   = {"arrow","checkpoint","corona","cylinder","ring"},
	colshapeType = {"colcircle","coltube","colsquare","colcube"},
}

local weaponDropDownTypes = {
	weaponID = {"[1] Brassknuckle","[2] Golfclub","[3] Nightstick","[4] Knife","[5] Bat","[6] Shovel","[7] Poolstick","[8] Katana","[9] Chainsaw","[10] Dildo 1","[11] Dildo 2","[12] Vibrator 1","[13] Vibrator 2","[14] Flower","[15] Cane","[16] Grenade","[17] Teargas","[18] Molotov","[22] Colt 45","[23] Silenced","[24] Deagle","[25] Shotgun","[26] Sawed-off","[27] Combat Shotgun","[28] Uzi","[29] MP5","[30] AK-47","[31] M4","[32] Tec-9","[33] Rifle","[34] Sniper","[35] Rocket Launcher","[36] Rocket Launcher HS","[37] Flamethrower","[38] Minigun","[39] Satchel","[40] Satchel Detonator","[41] Spraycan","[42] Fire Extinguisher","[43] Camera","[44] Nightvision goggles","[45] Infrared goggles","[46] Parachute"},
	pickupType = {"Health","Armor","[1] Brassknuckle","[2] Golfclub","[3] Nightstick","[4] Knife","[5] Bat","[6] Shovel","[7] Poolstick","[8] Katana","[9] Chainsaw","[10] Dildo 1","[11] Dildo 2","[12] Vibrator 1","[13] Vibrator 2","[14] Flower","[15] Cane","[16] Grenade","[17] Teargas","[18] Molotov","[22] Colt 45","[23] Silenced","[24] Deagle","[25] Shotgun","[26] Sawed-off","[27] Combat Shotgun","[28] Uzi","[29] MP5","[30] AK-47","[31] M4","[32] Tec-9","[33] Rifle","[34] Sniper","[35] Rocket Launcher","[36] Rocket Launcher HS","[37] Flamethrower","[38] Minigun","[39] Satchel","[40] Satchel Detonator","[41] Spraycan","[42] Fire Extinguisher","[43] Camera","[44] Nightvision goggles","[45] Infrared goggles","[46] Parachute"},
}

local nameToID = {
	["Health"] = "health",
	["Armor"] = "armor",
	["[1] Brassknuckle"] = 1,
	["[2] Golfclub"] = 2,
	["[3] Nightstick"] = 3,
	["[4] Knife"] = 4,
	["[5] Bat"] = 5,
	["[6] Shovel"] = 6,
	["[7] Poolstick"] = 7,
	["[8] Katana"] = 8,
	["[9] Chainsaw"] = 9,
	["[10] Dildo 1"] = 10,
	["[11] Dildo 2"] = 11,
	["[12] Vibrator 1"] = 12,
	["[13] Vibrator 2"] = 13,
	["[14] Flower"] = 14,
	["[15] Cane"] = 15,
	["[16] Grenade"] = 16,
	["[17] Teargas"] = 17,
	["[18] Molotov"] = 18,
	["[22] Colt 45"] = 22,
	["[23] Silenced"] = 23,
	["[24] Deagle"] = 24,
	["[25] Shotgun"] = 25,
	["[26] Sawed-off"] = 26,
	["[27] Combat Shotgun"] = 27,
	["[28] Uzi"] = 28,
	["[29] MP5"] = 29,
	["[30] AK-47"] = 30,
	["[31] M4"] = 31,
	["[32] Tec-9"] = 32,
	["[33] Rifle"] = 33,
	["[34] Sniper"] = 34,
	["[35] Rocket Launcher"] = 35,
	["[36] Rocket Launcher HS"] = 36,
	["[37] Flamethrower"] = 37,
	["[38] Minigun"] = 38,
	["[39] Satchel"] = 39,
	["[40] Satchel Detonator"] = 40,
	["[41] Spraycan"] = 41,
	["[42] Fire Extinguisher"] = 42,
	["[43] Camera"] = 43,
	["[44] Nightvision goggles"] = 44,
	["[45] Infrared goggles"] = 45,
	["[46] Parachute"] = 46
}


function getStringFromColor( R, G, B, A )
	if R and G and B then
		return ('#%02x%02x%02x'):format(R, G, B, A or 255)
	else
		return false
	end
end

function table.find(tableToSearch, value)
	for k,v in pairs(tableToSearch) do
		if v == value then
			return k
		end
	end
	return false
end

--doesn't take selfreferencing into account, not needed
function table.copy(theTable)
	local t = {}
	for k, v in pairs(theTable) do
		if type(v) == "table" then
			t[k] = table.copy(theTable)
		else
			t[k] = v
		end
	end
	return t
end

--editing controls' prototype table--
editingControl = {}

local eC = editingControl

eC.string = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		relative = false,
		value = "",
	},
	constructor = function( self, info )
		self.GUI.editField = guiCreateEdit( info.x, info.y, info.width, info.height, tostring(info.value), info.relative, info.parent )

		self:addHandler( "onClientGUIChanged", self.GUI.editField, self.callChangeHandlers )

		return self
	end,
	setValue = function( self, value )
		return guiSetText( self.GUI.editField, tostring(value) )
	end,
	getValue = function( self )
		return guiGetText( self.GUI.editField )
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.GUI.editField) )
	end,
}

eC.number = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		relative = false,
		value = "",
		maxLength = 10,
		enabled = true,
	},
	constructor = function( self, info )
		self.GUI.editField = guiCreateEdit( info.x, info.y, info.width, info.height, tostring(info.value), info.relative, info.parent )
		if info.maxLength then
			guiEditSetMaxLength( self.GUI.editField, info.maxLength )
		end

		self.min = info.min
		self.max = info.max
		self.enabled = info.enabled
		if self.enabled == nil then self.enabled = true end
		if not self.enabled then
			self:disable()
		end

		self:addHandler( "onClientGUIChanged", self.GUI.editField, self.forceNumber )
		self:addHandler( "onClientGUIChanged", self.GUI.editField, self.forceRange )
		self:setChangeHandler( "onClientGUIChanged", self.GUI.editField, self.callChangeHandlers )

		return self
	end,
	setValue = function( self, value )
		return guiSetText( self.GUI.editField, tostring(value) )
	end,
	getValue = function( self )
		self:forceRange()
		return tonumber(guiGetText( self.GUI.editField ))
	end,
	forceNumber = function( self )
		local inputText = guiGetText( self.GUI.editField )
		local changedText
		if not tonumber( inputText ) then
			local sign = ""
			if inputText:sub(1,1) == '-' then
				sign = '-'
			end

			changedText = string.gsub( inputText, "[^%.%d]", "" )

			local numberParts = split( changedText, string.byte('.') )
			if #numberParts > 0 then
				if #numberParts > 1 then
					--local decimalPart = string.gsub( table.concat(numberParts,'',2), "%.", "" )
					local decimalPart = table.concat(numberParts,'',2)
					if decimalPart == "" then
						changedText = numberParts[1]
					else
						changedText = numberParts[1] .. '.' .. decimalPart
					end
				else
					changedText = numberParts[1]
				end
			end

			changedText = sign .. changedText
		end

		if changedText and changedText ~= inputText then
			guiSetText(self.GUI.editField, changedText)
		end
	end,
	forceRange = function( self )
		local inputNumber = tonumber(guiGetText( self.GUI.editField ))
		if inputNumber then
			local clampedNumber = inputNumber
			if self.min then
				clampedNumber = math.max(clampedNumber, self.min)
			end
			if self.max then
				clampedNumber = math.min(clampedNumber, self.max)
			end
			if clampedNumber ~= inputNumber then
				guiSetText(self.GUI.editField, tostring(clampedNumber))
			end
		end
	end,
	enable = function ( self )
		self.enabled = true
		guiSetEnabled ( self.GUI.editField, true )
		return true
	end,
	disable = function ( self )
		self.enabled = false
		guiSetEnabled ( self.GUI.editField, false )
		return true
	end,
	isEnabled = function ( self )
		return self.enabled
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.GUI.editField) )
	end,
}

eC.integer = {
	default = eC.number.default,
	constructor = function( self, info )
		eC.number.constructor( self, info )

		self:addHandler( "onClientGUIChanged", self.GUI.editField, self.forceInteger )
		self:setChangeHandler( "onClientGUIChanged", self.GUI.editField, self.callChangeHandlers )

		return self
	end,
	setValue = eC.number.setValue,
	getValue = eC.number.getValue,
	focus = eC.number.focus,
	forceNumber = eC.number.forceNumber,
	forceRange = eC.number.forceRange,
	forceInteger = function( self )
		local inputText = guiGetText( source )
		if tonumber( inputText ) then
			local integerText = string.gsub( inputText, "%.", "" )

			if inputText ~= integerText then
				guiSetText( source, integerText )
			end
		end
	end,
}

eC.natural = {
	default = eC.integer.default,
	constructor = function( self, info )
		eC.integer.constructor( self, info )

		self:addHandler( "onClientGUIChanged", self.GUI.editField, self.forceNatural )
		self:setChangeHandler( "onClientGUIChanged", self.GUI.editField, self.callChangeHandlers )

		return self
	end,
	setValue = eC.number.setValue,
	getValue = eC.number.getValue,
	enable = eC.number.enable,
	disable = eC.number.disable,
	isEnabled = eC.number.isEnabled,
	focus = eC.number.focus,
	forceNumber = eC.number.forceNumber,
	forceInteger = eC.integer.forceInteger,
	forceRange = eC.number.forceRange,
	forceNatural = function( self )
		local inputText = guiGetText( source )
		if tonumber( inputText ) then
			if inputText:sub(1,1) == '-' then
				guiSetText( source, inputText:sub(2) )
			end
		end
	end,
}

eC.boolean = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		relative = false,
		label = "",
		value = false,
	},
	constructor = function( self, info )
		self.GUI.checkbox = guiCreateCheckBox ( info.x, info.y, info.width, info.height, info.label, info.value, info.relative, info.parent )
		local changeFunction = function ( control, button, state )
			if state == "up" then self:callChangeHandlers() end
		end
		self:setChangeHandler( "onClientGUIMouseDown", self.GUI.checkbox, changeFunction, false )
		return self
	end,
	setValue = function( self, value )
		local ret = guiCheckBoxSetSelected( self.GUI.checkbox, value )
		self:callChangeHandlers()
		return ret
	end,
	getValue = function( self )
		return guiCheckBoxGetSelected( self.GUI.checkbox )
	end,
	setPosition = function ( self, x, y, relative )
		return guiSetPosition ( self.GUI.checkbox, x, y, relative )
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.GUI.checkbox) )
	end,
}

eC.element = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		relative = false,
		editWidth = .5,
		clearButtonWidth = .2,
		browseButtonWidth = .3,
		value = nil,
		types = {},
		ignoredElements = {},
	},
	constructor = function( self, info )
		local editWidth = info.width * self.default.editWidth
		local clearButtonWidth = info.width * self.default.clearButtonWidth
		local browseButtonWidth = info.width * self.default.browseButtonWidth

		self.GUI.editField = guiCreateEdit( info.x, info.y, editWidth, info.height, "", info.relative, info.parent )
		self.GUI.clearButton = guiCreateButton( info.x  + editWidth, info.y, clearButtonWidth, info.height, "X", info.relative, info.parent )
		self.GUI.launchBrowserButton = guiCreateButton( info.x  + editWidth + clearButtonWidth, info.y, browseButtonWidth, info.height, "Browse", info.relative, info.parent )

		guiEditSetReadOnly(self.GUI.editField, true)

		self:setIgnoredElements( info.ignoredElements )
		if info.validvalues then
			info.types = info.validvalues
		end
		self:setTypes( info.types )
		self:setValue( info.value )
		self:addHandler( "onClientGUIClick", self.GUI.clearButton, self.clearValue )
		self:addHandler( "onClientGUIClick", self.GUI.launchBrowserButton, self.launchElementBrowser )

		return self
	end,
	setValue = function( self, value )
		if not value then
			value = nil
		elseif type(value) == "string" then
			value = getElementByID( value )
		end

		if isElement(value) then
			local valueType = getElementType(value)

			-- if only certain types are allowed, check our value belongs to one
			if #self.types > 0 then
				local isAllowed = false
				for i, allowedType in ipairs(self.types) do
					if valueType == allowedType then
						isAllowed = true
						break
					end
				end
				if not isAllowed then
					return false
				end
			end

			self.value = value
			guiSetText( self.GUI.editField, valueType..":"..(getElementID( value ) or "<no id>") )
			self:callChangeHandlers()
			return true
		elseif value == nil then
			self.value = nil
			guiSetText( self.GUI.editField, "<none>" )
			self:callChangeHandlers()
			return true
		else
			return false
		end
	end,
	getValue = function( self )
		return self.value
	end,
	clearValue = function( self )
		return self:setValue(nil)
	end,
	setTypes = function( self, types )
		local typesArgType = type(types)
		if typesArgType == "table" then
			self.types = types
			return true
		elseif typesArgType == "string" then
			self.types = {types}
			return true
		else
			return false
		end
	end,
	setIgnoredElements = function( self, ignoredElements )
		self.ignoredElements = ignoredElements
	end,
	launchElementBrowser = function( self )
		local previousCamera = {getCameraMatrix()}
		local callback = function( elementID )
			setCameraMatrix(unpack(previousCamera))
			triggerEvent( "onClientControlBrowserClose", self.GUI.launchBrowserButton )
			return self:setValue( elementID )
		end
		if #self.types > 0 then
			showCurrentBrowser ( self.types, self.ignoredElements, false, false, callback )
		else
			showCurrentBrowser ( false, self.ignoredElements, false, false, callback )
		end
		triggered = triggerEvent( "onClientControlBrowserLaunch", self.GUI.launchBrowserButton )
	end,
	focus = function(self)
		self:launchBrowserButton()
	end,
}

eC.catalogID = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		relative = false,
		editWidth = .5,
		buttonWidth = .5,
		value = "",
	},
	constructor = function( self, info )
		local typeParameterDatatype = type(info.type)
		if typeParameterDatatype ~= "string" then
			error("Catalog type string expected in 'type' parameter, got "..typeParameterDatatype..".", 2)
		end

		self.IDType = info.type

		if isElement(info.value) then
			info.value = getElementID( info.value ) or ""
		else
			info.value = tostring( info.value )
		end

		local editWidth = info.width * info.editWidth
		local buttonWidth = info.width * info.buttonWidth
		self.GUI.editField = guiCreateEdit( info.x, info.y, editWidth, info.height, info.value, info.relative, info.parent )
		self.GUI.launchBrowserButton = guiCreateButton( info.x  + editWidth, info.y, buttonWidth, info.height, "Browse", info.relative, info.parent )

		guiEditSetReadOnly(self.GUI.editField, true)

		self:addHandler( "onClientGUIClick", self.GUI.launchBrowserButton, self.launchCatalogBrowser )

		return self
	end,
	setValue = function( self, value )
		local ret = guiSetText(self.GUI.editField, tostring(value))
		self:callChangeHandlers()
		return ret
	end,
	getValue = function( self )
		local stringValue = guiGetText(self.GUI.editField)
		return tonumber(stringValue) or stringValue
	end,
	launchCatalogBrowser = function( self, autoSet )
		local callback = function( categoryType, chosenCategory, chosenModel, cancelled)
			self.category = chosenCategory
			self.cancelled = cancelled
			self:setValue(chosenModel)
			if isElement(self.GUI.launchBrowserButton) then
				triggerEvent( "onClientControlBrowserClose", self.GUI.launchBrowserButton )
			end
		end
		self.cancelled = nil
		startBrowser( self.IDType, callback, self.category, tonumber(self:getValue()), autoSet )
		triggerEvent( "onClientControlBrowserLaunch", self.GUI.launchBrowserButton )
	end,
	focus = function(self)
		self:launchCatalogBrowser(true)
	end
}

eC.plate = {
	default = eC.string.default,
	constructor = function( self, info )
		eC.string.constructor( self, info )

		self:addHandler( "onClientGUIChanged", self.GUI.editField, self.forcePlate )
		self:setChangeHandler( "onClientGUIChanged", self.GUI.editField, self.callChangeHandlers )

		return self
	end,
	setValue = eC.string.setValue,
	getValue = eC.string.getValue,
	focus = eC.number.focus,
	forcePlate = function( self )
		local inputText = guiGetText( source )
		if inputText ~= "" and string.find( inputText, "[^%d%u ]+" ) then
			guiSetText( source, string.upper(string.gsub( inputText, "[^%d%a ]", "" )) )
		end
	end,
}

eC.dropdown = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		labelLeftPadding = 10,
		labelTopPadding = 1,
		relative = false,
		visibleOptions = 3,
		enabled = true,
	},
	constructor = function ( self, info )
		if dropdownTypes[info.type] then
			info.rows = dropdownTypes[info.type]
		elseif weaponDropDownTypes[info.type] then
			info.rows = weaponDropDownTypes[info.type]
			self.weaponType = true
		else
			local rowsParameterDatatype = type(info.rows)
			if rowsParameterDatatype ~= "table" then
				error("Options table expected in 'rows' parameter, got "..rowsParameterDatatype..".", 2)
			elseif #info.rows < 1 then
				error("At least one string is necessary in 'rows' parameter.", 2)
			end
		end

		self.GUI.gridlist = guiCreateGridList ( info.x, info.y, info.width, info.height, info.relative, info.parent )

		guiGridListSetScrollBars ( self.GUI.gridlist, false, false )
		guiGridListAddColumn ( self.GUI.gridlist, " ", 0.85 )

		local screenX, screenY = guiGetScreenSize()
		self.GUI.label = guiCreateLabel ( info.labelLeftPadding, info.labelTopPadding, screenX, 16, "", false, self.GUI.gridlist )

		guiGridListSetSortingEnabled ( self.GUI.gridlist, false )
		guiGridListSetSelectionMode ( self.GUI.gridlist, 2 )

		--create a button as a hitbox instead of the header, make it invisible.
		self.GUI.button = guiCreateButton ( 0, 0, 1, 1, "", true, self.GUI.gridlist )
		guiSetAlpha ( self.GUI.button, 0 )

		self.width = info.width
		self.height = info.height
		self.relative = info.relative
		self.dropWidth = info.dropWidth or info.width
		self.dropHeight = info.dropHeight or info.height * (math.min(info.visibleOptions, #info.rows) + .5)
		self.isOpen = false

		self.enabled = info.enabled
		if self.enabled then
			self:addHandler ( "onClientGUIClick", root, self.dropdownClick, true )
		else
			self.enabled = true
			self:disable()
		end

		self.rows = info.rows

		for k, rowtext in ipairs(self.rows) do
			guiGridListSetItemText ( self.GUI.gridlist, guiGridListAddRow ( self.GUI.gridlist ), 1, rowtext, false, false )
		end

		self.row = info.rows.initial or info.value
		if (self.weaponType) then
			self.row = table.find ( nameToID, self.row )
		end
		if type(self.row) == "string" then
			self.row = self:getRowsFromName(self.row)[1]
		end
		self.row = self.row or 1

		guiGridListSetSelectedItem ( self.GUI.gridlist, self.row-1, 1 )
		local rowText = guiGridListGetItemText ( self.GUI.gridlist, self.row-1, 1 )
		guiSetText ( self.GUI.label, rowText )

		return self
	end,
	setValue = function( self, value, index, internal )
		local row
		if type(value) == "number" then
			row = math.abs(math.floor(value))
			if row == 0 or row > #(self.rows) then
				return false
			end
		elseif type(value) == "string" then
			row = self:getRowsFromName(value)[index or 1]
			if not row then
				return false
			end
		end
		self.row = row
		local selectedText = guiGridListGetItemText ( self.GUI.gridlist, row-1, 1 )
		if selectedText then
			guiSetText ( self.GUI.label, selectedText )
		end
		guiBringToFront ( self.GUI.button )

		self:callChangeHandlers()

		return true
	end,
	getValue = function( self )
		if (self.weaponType) then
			return nameToID[self.rows[self.row]]
		end
		return self.rows[self.row] or false
	end,
	getRow = function( self )
		return self.row
	end,
	getRowName = function( self, row )
		return self.rows[row] or false
	end,
	getRows = function( self )
		local rowsCopy = {}
		for i, rowtext in ipairs(self.rows) do
			rowsCopy[i] = rowtext
		end
		return rowsCopy
	end,
	getRowsFromName = function( self, name )
		local rowsFromName = {}
		for i, rowtext in ipairs(self.rows) do
			if rowtext == name then
				table.insert(rowsFromName,i)
			end
		end
		return rowsFromName
	end,
	dropdownClick = function ( self, passedSource )
		if type(passedSource) ~= "string" then source = passedSource end
		if source == self.GUI.gridlist or source == self.GUI.button then
			if self.isOpen == false then
				self.isOpen = true

				guiSetSize ( self.GUI.gridlist, self.dropWidth, self.dropHeight, self.relative )

				guiBringToFront ( self.GUI.button )
				local screenX = guiGetScreenSize()
				guiSetSize ( self.GUI.button, screenX, 23, false )
				guiSetAlpha ( self.GUI.button, 0 )

				triggerEvent ( "onClientDropDownOpen", self.GUI.gridlist )
			else
				local cellrow = guiGridListGetSelectedItem ( self.GUI.gridlist )
				self.isOpen = false

				guiSetSize ( self.GUI.gridlist, self.width, self.height, self.relative )

				guiBringToFront ( self.GUI.button )

				if cellrow ~= -1 then
					self:setValue(cellrow+1)
				else
					--ensure one is selected
					guiGridListSetSelectedItem ( self.GUI.gridlist, self.row-1, 1 )
					self:callChangeHandlers()
				end

				triggerEvent ( "onClientDropDownSelect", self.GUI.gridlist, cellrow )
			end
		else
			if source ~= root then
				local height = self.height
				local width = self.width

				guiSetSize ( self.GUI.gridlist, width, height, self.relative )
				self.isOpen = false
				guiGridListSetSelectedItem ( self.GUI.gridlist, self.row-1, 1 )
			end
		end
	end,
	enable = function ( self )
		if not self.enabled then
			self:addHandler ( "onClientGUIClick", root, self.dropdownClick, true )
			self.enabled = true
			guiLabelSetColor(self.GUI.label,255,255,255,255)
			return true
		else
			return false
		end
	end,
	disable = function ( self )
		if self.enabled then
			self:removeHandler()
			self.enabled = false
			guiLabelSetColor(self.GUI.label,112,112,112,255)
			return true
		else
			return false
		end
	end,
	isEnabled = function ( self )
		return self.enabled
	end,
	setSize = function ( self, width, height, dropWidth, dropHeight, relative )
		self.width = width
		self.height = height
		self.relative = relative
		self.dropWidth = dropWidth or width
		self.dropHeight = dropHeight or self.dropHeight
		if ( self.isOpen ) then
			guiSetSize ( self.GUI.gridlist, self.dropWidth, self.dropHeight, self.relative )
		else
			guiSetSize ( self.GUI.gridlist, self.width, self.height, self.relative )
		end
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.GUI.gridlist) )
		self:dropdownClick(self.GUI.gridlist)
	end,
}

eC.slider = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		relative = false,
		value = 0,
		min = 0,
		max = 100,
	},
	constructor = function ( self, info )
		self.relative = info.relative

		self.min = info.min
		self.max = info.max
		self.range = info.max - info.min

		if info.ticks then
			self.tickwidth = 100 / info.ticks
		end

		self.GUI.bar = guiCreateProgressBar ( info.x, info.y, info.width, info.height, info.relative, info.parent )

		local absoluteBarWidth = (guiGetSize(self.GUI.bar, false))
		local padLeft  = 10 --px
		local padRight = 10 --px

		self.GUI.minLabel = guiCreateLabel ( 0, 0, 0, 0, tostring(self.min), false, self.GUI.bar )
		local minHeight = guiLabelGetFontHeight(self.GUI.minLabel)
		local minExtent = guiLabelGetTextExtent(self.GUI.minLabel)
		guiSetPosition(self.GUI.minLabel, padLeft, minHeight/2, false)
		guiSetSize(self.GUI.minLabel, minExtent, minHeight, false)
		guiSetFont(self.GUI.minLabel, "default-bold-small")
		guiLabelSetColor(self.GUI.minLabel, 0, 0, 0)

		self.GUI.maxLabel = guiCreateLabel ( 0, 0, 0, 0, tostring(self.max), false, self.GUI.bar )
		local maxHeight = guiLabelGetFontHeight(self.GUI.maxLabel)
		local maxExtent = guiLabelGetTextExtent(self.GUI.maxLabel)
		guiSetPosition(self.GUI.maxLabel, absoluteBarWidth - maxExtent - padRight, maxHeight/2, false)
		guiSetSize(self.GUI.maxLabel, maxExtent, maxHeight, false)
		guiSetFont(self.GUI.maxLabel, "default-bold-small")
		guiLabelSetColor(self.GUI.maxLabel, 0, 0, 0)

		-- It's safe to call setValue in the constructor, since there shouldn't be
		-- any change handlers registered at this moment. -- ryden
		self:setValue(info.value)

		self:addHandler( "onClientGUIClick", self.GUI.bar, self.sliderClicked, true )
		self:addHandler( "onClientGUIMouseDown", self.GUI.bar, self.dragHandler, true )

		return self
	end,
	setValue = function( self, value )
		value = math.min(math.max(value, self.min), self.max)
		local percent = 100 * (value - self.min) / self.range
		guiProgressBarSetProgress ( self.GUI.bar, percent )
		self.percent = percent

		self:callChangeHandlers()

		return true
	end,
	getValue = function( self )
		return ( self.range * self.percent / 100 ) + self.min
	end,
	sliderClicked = function ( self )
		if source ~= self.GUI.bar and source ~= self.GUI.minLabel and source ~= self.GUI.maxLabel then
			return
		end

		local clickedX
		if self.relative then
			clickedX = getCursorPosition() * (guiGetScreenSize())
		else
			clickedX = getCursorPosition()
		end

		local currentStartX = guiGetPosition( self.GUI.bar, false )
		local currentWidth = guiGetSize( self.GUI.bar, false )

		local guiParent = getElementParent( self.GUI.bar )
		while guiParent ~= guiRoot do
			currentStartX = currentStartX + guiGetPosition(guiParent, false)
			guiParent = getElementParent( guiParent )
		end

		local percent = 100 * ( clickedX - currentStartX ) / currentWidth
		percent = math.min(math.max(percent, 0),100) --clamp value

		if self.tickwidth then
			local nearesttick = math.floor( percent / self.tickwidth + .5 )
			percent = nearesttick * self.tickwidth
		end
		self:setValue( ( self.range * percent / 100 ) + self.min )
	end,
	dragHandler = function ( self, button, state, absoluteX, absoluteY )
		if state == "down" then
			if not isCursorShowing() then return end
			self:addHandler( "onClientMouseMove", self.GUI.bar, self.sliderClicked, true )
		elseif state == "up" then
			self:removeHandler(3)
		end
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.GUI.bar) )
	end
}

eC.camera = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 23,
		relative = false,
		value = {{0,0,0},{0,0,0}}
	},
	constructor = function( self, info )
		self.value = info.value
		local eye = info.value[1]

		local current = tostring(math.ceil(eye[1]))..","..tostring(math.ceil(eye[2]))..","..tostring(math.ceil(eye[3]))
		self.GUI.showButton = guiCreateButton( info.x, info.y, info.width/2, info.height, current, info.relative, info.parent )
		self.GUI.grabButton = guiCreateButton( info.x+info.width/2, info.y, info.width/2, info.height, "Get current", info.relative, info.parent )
		guiSetFont ( self.GUI.showButton, "default-bold-small" )

		self:addHandler ( "onClientGUIClick", self.GUI.showButton, self.showCamera )
		self:addHandler ( "onClientGUIClick", self.GUI.grabButton, self.grabCamera )

		return self
	end,
	setValue = function( self, value )
		self.value = value
		local eye = value[1]
		local current = tostring(math.ceil(eye[1]))..","..tostring(math.ceil(eye[2]))..","..tostring(math.ceil(eye[3]))
		guiSetText ( self.GUI.showButton, current )

		self:callChangeHandlers()

		return true
	end,
	getValue = function( self )
		return self.value
	end,
	showCamera = function( self )
		setCameraMatrix(self.value[1][1], self.value[1][2], self.value[1][3], self.value[2][1], self.value[2][2], self.value[2][3])
	end,
	grabCamera = function( self )
		local camX, camY, camZ, targetX, targetY, targetZ = getCameraMatrix()
		self:setValue({{camX, camY, camZ}, {targetX, targetY, targetZ}})
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.GUI.grabButton) )
	end,
}

eC.coord3d = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 69,
		relative = false,
		value = {0,0,0},
	},
	constructor = function( self, info )
		local heightThird = info.height/3
		local info_mt = {__index=info}
		local labelX = guiCreateLabel ( info.x, info.y + 3, 10, 23, "x:", false, info.parent )
		local infoX = setmetatable( {value=info.value[1], x=info.x + 14, height = heightThird, width = info.width - 14, y=info.y + 2 }, info_mt )
		local labelY = guiCreateLabel ( info.x, info.y + 26, 10, 23, "y:", false, info.parent )
		local infoY = setmetatable( {value=info.value[2], x=info.x + 14, height = heightThird, width = info.width - 14, y=info.y + 25 }, info_mt )
		local labelZ = guiCreateLabel ( info.x, info.y + 48, 10, 23, "z:", false, info.parent )
		local infoZ = setmetatable( {value=info.value[3], x=info.x + 14, height = heightThird, width = info.width - 14, y=info.y + 48 }, info_mt )
		self.children.numberX = eC.number:create( infoX )
		self.children.numberY = eC.number:create( infoY )
		self.children.numberZ = eC.number:create( infoZ )

		self.children.numberX:addChangeHandler(function() self:callChangeHandlers() end)
		self.children.numberY:addChangeHandler(function() self:callChangeHandlers() end)
		self.children.numberZ:addChangeHandler(function() self:callChangeHandlers() end)

		self.GUI = { self.children.numberX.GUI.editField, self.children.numberY.GUI.editField, self.children.numberZ.GUI.editField, labelX, labelY, labelZ }

		return self
	end,
	setValue = function( self, value )
		return self.children.numberX:setValue(value[1]) and self.children.numberY:setValue(value[2]) and self.children.numberZ:setValue(value[3])
	end,
	getValue = function( self )
		return {self.children.numberX:getValue(), self.children.numberY:getValue(), self.children.numberZ:getValue()}
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.children.numberX.GUI.editField) )
	end,
}

eC.color = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 20,
		buttonWidth = .38,
		testWidth = .6,
		testHeight = 1,
		relative = false,
		value = "#ff0000ff",
		selectWindow =
		{
			width = 350,
			height = 400,
			paletteX = 18,
			paletteY = 30,
			luminanceOffset = 10,
			luminanceWidth = 15,
			alphaOffset = 25 + 17,
			alphaWidth = 15,
			rgbX = 265,
			rgbY = 300,
			rgbWidth = 50,
			rgbHeight = 21,
			hslX = 190,
			hslY = 300,
			hslWidth = 50,
			hslHeight = 21,
			historyX = 18,
			historyY = 300,
			historyWidth = 140,
			historyHeight = 80,
		}
	},
	constructor = function( self, info )
		self.value = self:convertColorToTable(info.value)

		self.testWidth = info.width * self.default.testWidth
		self.testHeight = info.height * self.default.testHeight
		self.buttonWidth = info.width * self.default.buttonWidth

		local height = 10
		local sizeX, sizeY = guiGetSize(info.parent, false)
		if not sizeX then
			sizeX, sizeY = guiGetScreenSize()
		end
		if info.relative then
			height = height / sizeY
		end
		local fillerString = string.rep('l', math.ceil(sizeX/2))

		self.GUI.test = { }
		local numlabels = math.ceil(self.testHeight / height) - 1

		for i6=0,numlabels do
			if i6 == numlabels then
				height = self.testHeight - ((i6-1)*height)
			end
			self.GUI.test[(i6*2) + 1] = guiCreateLabel(info.x, info.y + 7*i6, self.testWidth, height, fillerString, info.relative, info.parent)
			self.GUI.test[(i6*2) + 2] = guiCreateLabel(info.x+1, info.y + 7*i6, self.testWidth, height, fillerString, info.relative, info.parent)
		end

		self.GUI.changeButton = guiCreateButton(info.x + self.testWidth + sizeX * 0.02, info.y,
		                                        self.buttonWidth, info.height,
							"Change", info.relative, info.parent)

		-- Create the color selection window
		local screenW, screenH = guiGetScreenSize()
		self.selectWindow = info.selectWindow
		self.WGUI.selectWindow = guiCreateWindow(screenW - info.selectWindow.width, (screenH - info.selectWindow.height) / 2,
		                                        info.selectWindow.width, info.selectWindow.height, "Pick a color", false)
		guiSetVisible(self.WGUI.selectWindow, false)
		guiWindowSetSizable(self.WGUI.selectWindow, false)

		self.WGUI.palette = guiCreateStaticImage(self.selectWindow.paletteX, self.selectWindow.paletteY,
		                                        256, 256, "client/images/palette.png", false, self.WGUI.selectWindow)
		self.WGUI.alphaBar = guiCreateStaticImage(self.selectWindow.paletteX + 255 + self.selectWindow.alphaOffset, self.selectWindow.paletteY,
		                                         self.selectWindow.alphaWidth, 255, "client/images/alpha.png", false, self.WGUI.selectWindow)
		self:updateTest()

		self:addHandler("onClientGUIClick", self.GUI.changeButton, self.openSelect, false)
		self.isSelectOpen = false

		-- Create the RGB and HSL edit boxes
		local info_mt = {__index=info}
		local infoR = setmetatable( {
		                              value=self.value[1],
		                              width=info.selectWindow.rgbWidth,
		                              height=info.selectWindow.rgbHeight,
		                              x=info.selectWindow.rgbX + 10,
					      y=info.selectWindow.rgbY,
		                              min=0,
		                              max=255,
					      parent=self.WGUI.selectWindow
		                            }, info_mt )
		self.children.R = eC.natural:create( infoR )
		self.WGUI.labelR = guiCreateLabel(info.selectWindow.rgbX, info.selectWindow.rgbY + 3,
		                                 10, 20, "R", false, self.WGUI.selectWindow)
		guiSetFont(self.WGUI.labelR, "default-bold-small")
		self.children.R:addChangeHandler(function () self:selectionManualInputRGB() end)

		local infoG = setmetatable( {
		                              value=self.value[2],
					      width=info.selectWindow.rgbWidth,
					      height=info.selectWindow.rgbHeight,
					      x=info.selectWindow.rgbX + 10,
					      y=info.selectWindow.rgbY + info.selectWindow.rgbHeight,
					      min=0,
					      max=255,
					      parent = self.WGUI.selectWindow
					    }, info_mt )
		self.children.G = eC.natural:create( infoG )
		self.WGUI.labelG = guiCreateLabel(info.selectWindow.rgbX, info.selectWindow.rgbY + 3 + info.selectWindow.rgbHeight,
		                                 10, 20, "G", false, self.WGUI.selectWindow)
		guiSetFont(self.WGUI.labelG, "default-bold-small")
		self.children.G:addChangeHandler(function () self:selectionManualInputRGB() end)

		local infoB = setmetatable( {
		                              value=self.value[3],
					      width=info.selectWindow.rgbWidth,
					      height=info.selectWindow.rgbHeight,
					      x=info.selectWindow.rgbX + 10,
					      y=info.selectWindow.rgbY + info.selectWindow.rgbHeight*2,
					      min=0,
					      max=255,
					      parent = self.WGUI.selectWindow
					    }, info_mt )
		self.children.B = eC.natural:create( infoB )
		self.WGUI.labelB = guiCreateLabel(info.selectWindow.rgbX, info.selectWindow.rgbY + 3 + info.selectWindow.rgbHeight*2,
		                                 10, 20, "B", false, self.WGUI.selectWindow)
		guiSetFont(self.WGUI.labelB, "default-bold-small")
		self.children.B:addChangeHandler(function () self:selectionManualInputRGB() end)

		local infoA = setmetatable( {
		                              value=self.value[4],
					      width=info.selectWindow.rgbWidth,
					      height=info.selectWindow.rgbHeight,
					      x=info.selectWindow.rgbX + 10,
					      y=info.selectWindow.rgbY + info.selectWindow.rgbHeight*3,
					      min=0,
					      max=255,
					      parent = self.WGUI.selectWindow
					    }, info_mt )
		self.children.A = eC.natural:create( infoA )
		self.WGUI.labelA = guiCreateLabel(info.selectWindow.rgbX - 25, info.selectWindow.rgbY + 3 + info.selectWindow.rgbHeight*3,
		                                 50, 20, "Alpha", false, self.WGUI.selectWindow)
		guiSetFont(self.WGUI.labelA, "default-bold-small")
		self.children.A:addChangeHandler(function () self:selectionManualInputRGB() end)


		self.h, self.s, self.l = self:rgb2hsl(self.value[1] / 255, self.value[2] / 255, self.value[3] / 255)
		local infoH = setmetatable( {
		                              value=math.floor(self.h * 255),
					      width=info.selectWindow.hslWidth,
					      height=info.selectWindow.hslHeight,
					      x=info.selectWindow.hslX + 10,
					      y=info.selectWindow.hslY,
					      min=0,
					      max=255,
					      parent = self.WGUI.selectWindow
					    }, info_mt )
		self.children.H = eC.natural:create( infoH )
		self.WGUI.labelH = guiCreateLabel(info.selectWindow.hslX, info.selectWindow.hslY + 3,
		                                 10, 20, "H", false, self.WGUI.selectWindow)
		guiSetFont(self.WGUI.labelH, "default-bold-small")
		self.children.H:addChangeHandler(function () self:selectionManualInputHSL() end)

		local infoS = setmetatable( {
		                              value=math.floor(self.s * 255),
					      width=info.selectWindow.hslWidth,
					      height=info.selectWindow.hslHeight,
					      x=info.selectWindow.hslX + 10,
					      y=info.selectWindow.hslY + info.selectWindow.hslHeight,
					      min=0,
					      max=255,
					      parent = self.WGUI.selectWindow
					    }, info_mt )
		self.children.S = eC.natural:create( infoS )
		self.WGUI.labelS = guiCreateLabel(info.selectWindow.hslX, info.selectWindow.hslY + 3 + info.selectWindow.hslHeight,
		                                 10, 20, "S", false, self.WGUI.selectWindow)
		guiSetFont(self.WGUI.labelS, "default-bold-small")
		self.children.S:addChangeHandler(function () self:selectionManualInputHSL() end)

		local infoL = setmetatable( {
		                              value=math.floor(self.l * 256),
					      width=info.selectWindow.hslWidth,
					      height=info.selectWindow.hslHeight,
					      x=info.selectWindow.hslX + 10,
					      y=info.selectWindow.hslY + info.selectWindow.hslHeight*2,
					      min=0,
					      max=256,
					      parent = self.WGUI.selectWindow
					    }, info_mt )
		self.children.L = eC.natural:create( infoL )
		self.WGUI.labelL = guiCreateLabel(info.selectWindow.hslX, info.selectWindow.hslY + 3 + info.selectWindow.hslHeight*2,
		                                 10, 20, "L", false, self.WGUI.selectWindow)
		guiSetFont(self.WGUI.labelL, "default-bold-small")
		self.children.L:addChangeHandler(function () self:selectionManualInputHSL() end)


		-- Create the color history
		if not colorHistory then
			colorHistory = {}
			for i5=1,9 do
				colorHistory[i5] = { 255, 255, 255, 200 }
			end
		end

		self.WGUI.historyLabel = guiCreateLabel(info.selectWindow.historyX, info.selectWindow.historyY,
		                                       150, 15, "Recently used colors:", false, self.WGUI.selectWindow)

		self.avoidRecursion = false

		return self
	end,
	setValue = function( self, value )
		self.value = self:convertColorToTable(value)

		self:updateTest()
		local avoidRecursion = self.avoidRecursion
		self.avoidRecursion = true
		self:updateSelectionWindowEdits()
		self.avoidRecursion = avoidRecursion
		self:callChangeHandlers()

		return true
	end,
	getValue = function( self )
		local colorStr = "#" .. string.format("%02X%02X%02X%02X", self.value[1], self.value[2], self.value[3], self.value[4])
		return colorStr
	end,
	selectionManualInputRGB = function( self )
		if not self.avoidRecursion then
			self.avoidRecursion = true
			local r, g, b, a = self.children.R:getValue(),
			                   self.children.G:getValue(),
					   self.children.B:getValue(),
					   self.children.A:getValue()
			if not r or not g or not b or not a then
				self.avoidRecursion = false
				return
			end
			self.h, self.s, self.l = self:rgb2hsl(r / 255, g / 255, b / 255)
			self:setValue({r, g, b, a})
			self.avoidRecursion = false
		end
	end,
	selectionManualInputHSL = function( self )
		if not self.avoidRecursion then
			self.avoidRecursion = true
			local h, s, l = self.children.H:getValue(),
			                self.children.S:getValue(),
					self.children.L:getValue()
			if not h or not s or not l then
				self.avoidRecursion = false
				return
			end
			self.h, self.s, self.l = h / 255, s / 255, l / 256
			local r, g, b = self:hsl2rgb(self.h, self.s, self.l)
			self:setValue({r * 255, g * 255, b * 255, self.value[4]})
			self.avoidRecursion = false
		end
	end,
	updateSelectionWindowEdits = function( self )
		self.children.R:setValue(self.value[1])
		self.children.G:setValue(self.value[2])
		self.children.B:setValue(self.value[3])
		self.children.A:setValue(self.value[4])
		self.children.H:setValue(math.floor(self.h * 255))
		self.children.S:setValue(math.floor(self.s * 255))
		self.children.L:setValue(math.floor(self.l * 256))
	end,
	updateTest = function( self )
		local r, g, b, a = self.value[1], self.value[2], self.value[3], self.value[4]
		a = a / 255

		for k, label in ipairs(self.GUI.test) do
			guiLabelSetColor(label, r, g, b)
			guiSetAlpha(label, a)
		end
	end,
	openSelect = function( self )
		if self.isSelectOpen then return end

		guiSetVisible(self.WGUI.selectWindow, true)
		guiBringToFront(self.WGUI.selectWindow)
		self:addHandler("onClientRender", root, self.updateSelectedValue)
		self:addHandler("onClientClick", root, self.pickColor)

		self.isSelectOpen = true
		self.pickingColor = false
		self.pickingLuminance = false
		self.pickingAlpha = false
		self.h, self.s, self.l = self:rgb2hsl(self.value[1] / 255, self.value[2] / 255, self.value[3] / 255)
	end,
	closeSelect = function( self )
		if not self.isSelectOpen then return end

		guiSetVisible(self.WGUI.selectWindow, false)
		self:removeHandler()
		self:removeHandler()

		self.isSelectOpen = false

		self:addCurrentColorToHistory()
	end,
	addCurrentColorToHistory = function( self )
		-- First look up in color history to check if the
		-- current color is already present there
		for i=1,9 do
			local color = colorHistory[i]
			if color[1] == self.value[1] and
			   color[2] == self.value[2] and
			   color[3] == self.value[3] and
			   color[4] == self.value[4]
			then
				return
			end
		end

		-- Pop the last color and insert the new value
		table.remove(colorHistory)
		table.insert(colorHistory, 1, table.copy(self.value))
	end,
	updateSelectedValue = function( self )
		if not guiGetVisible(self.WGUI.selectWindow) then return end

		local r, g, b

		-- Check for color changes
		local wx, wy = guiGetPosition(self.WGUI.selectWindow, false)
		local paletteX, paletteY = wx + self.selectWindow.paletteX, wy + self.selectWindow.paletteY
		local luminanceX, luminanceY = paletteX + 255 + self.selectWindow.luminanceOffset, paletteY
		local alphaX, alphaY = paletteX + 255 + self.selectWindow.alphaOffset - 1, paletteY
		local cursorX, cursorY = getCursorPosition()
		local screenW, screenH = guiGetScreenSize()

		cursorX = cursorX * screenW
		cursorY = cursorY * screenH

		if self.pickingColor then
			if cursorX < paletteX then cursorX = paletteX
			elseif cursorX > paletteX + 255 then cursorX = paletteX + 255 end
			if cursorY < paletteY then cursorY = paletteY
			elseif cursorY > paletteY + 255 then cursorY = paletteY + 255 end

			setCursorPosition(cursorX, cursorY)

			self.h, self.s  = (cursorX - paletteX) / 255, (255 - cursorY + paletteY) / 255
			r, g, b = self:hsl2rgb(self.h, self.s, self.l)
			self.avoidRecursion = true
			self:setValue({r*255, g*255, b*255, self.value[4]})
			self.avoidRecursion = false
		elseif self.pickingLuminance then
			if cursorY < luminanceY then cursorY = luminanceY
			elseif cursorY > luminanceY + 256 then cursorY = luminanceY + 256 end

			setCursorPosition(cursorX, cursorY)

			self.l = (256 - cursorY + luminanceY) / 256
			r, g, b = self:hsl2rgb(self.h, self.s, self.l)
			self.avoidRecursion = true
			self:setValue({r*255, g*255, b*255, self.value[4]})
			self.avoidRecursion = false
		elseif self.pickingAlpha then
			if cursorY < alphaY then cursorY = alphaY
			elseif cursorY > alphaY + 255 then cursorY = alphaY + 255 end

			setCursorPosition(cursorX, cursorY)

			self.avoidRecursion = true
			self:setValue({self.value[1], self.value[2], self.value[3], cursorY - alphaY})
			self.avoidRecursion = false
		end

		-- Draw the lines pointing to the current selected color
		local x = paletteX + (self.h * 255)
		local y = paletteY + ((1 - self.s) * 255)
		local color = tocolor(0, 0, 0, 255)

		dxDrawLine(x - 12, y, x - 2, y, color, 3, true)
		dxDrawLine(x + 2, y, x + 12, y, color, 3, true)
		dxDrawLine(x, y - 12, x, y - 2, color, 3, true)
		dxDrawLine(x, y + 2, x, y + 12, color, 3, true)

		-- Draw the luminance for this color
		for i3=0,256 do
			local _r, _g, _b = self:hsl2rgb(self.h, self.s, (256 - i3) / 256)
			local color2 = tocolor(_r * 255, _g * 255, _b * 255, 255)
			dxDrawRectangle(luminanceX, luminanceY + i3, self.selectWindow.luminanceWidth, 1, color2, true)
		end

		-- Draw the luminance position marker
		local arrowX = luminanceX + self.selectWindow.luminanceWidth + 4
		local arrowY = luminanceY + ((1 - self.l) * 256)
		dxDrawLine(arrowX, arrowY, arrowX + 8, arrowY, tocolor(255, 255, 255, 255), 2, true)

		-- Draw the alpha for this color
		for i2=0,255 do
			local color2 = tocolor(self.value[1], self.value[2], self.value[3], i2)
			dxDrawRectangle(alphaX, alphaY + i2, self.selectWindow.alphaWidth + 1, 1, color2, true)
		end

		-- Draw the alpha position marker
		arrowX = alphaX + self.selectWindow.alphaWidth + 4
		arrowY = alphaY + self.value[4]
		dxDrawLine(arrowX, arrowY, arrowX + 8, arrowY, tocolor(255, 255, 255, 255), 2, true)

		-- Draw the recently used colors
		local boxWidth = (self.selectWindow.historyWidth - 15) / 3
		local boxHeight = (self.selectWindow.historyHeight - 45) / 3
		for i2=1,3 do
			for j=1,3 do
				local color2 = colorHistory[j + ((i2 - 1) * 3)]
				local x2 = wx + self.selectWindow.historyX + ((boxWidth + 5) * (j-1))
				local y2 = wy + self.selectWindow.historyY + 30 + ((boxHeight + 5) * (i2-1))
				dxDrawRectangle(x2, y2, boxWidth, boxHeight, tocolor(unpack(color2)), true)
			end
		end
	end,
	isCursorInArea = function( self, cursorX, cursorY, minX, minY, maxX, maxY )
		if cursorX < minX or cursorX > maxX or
		   cursorY < minY or cursorY > maxY
		then
			return false
		end
		return true
	end,
	pickColor = function( self, button, state, cursorX, cursorY )
		if button ~= "left" then return end

		local wx, wy = guiGetPosition(self.WGUI.selectWindow, false)
		local ww, wh = guiGetSize(self.WGUI.selectWindow, false)

		local isOutsideWindow = not self:isCursorInArea(cursorX, cursorY, wx, wy, wx+ww, wy+wh)

		local minX, minY, maxX, maxY = wx + self.selectWindow.paletteX,
		                               wy + self.selectWindow.paletteY,
					       wx + self.selectWindow.paletteX + 255,
					       wy + self.selectWindow.paletteY + 255
		local isInPalette = self:isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)

		minX, maxX = maxX + self.selectWindow.luminanceOffset,
		             maxX + self.selectWindow.luminanceOffset + self.selectWindow.luminanceWidth + 12
		maxY = maxY + 1
		local isInLuminance = self:isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)
		maxY = maxY - 1

		minX, maxX = wx + self.selectWindow.paletteX + 255 + self.selectWindow.alphaOffset,
		             wx + self.selectWindow.paletteX + 255 + self.selectWindow.alphaOffset + self.selectWindow.alphaWidth + 12
		local isInAlpha = self:isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)

		minX, minY, maxX, maxY = wx + self.selectWindow.historyX,
		                         wy + self.selectWindow.historyY,
					 wx + self.selectWindow.historyX + self.selectWindow.historyWidth,
					 wy + self.selectWindow.historyY + self.selectWindow.historyHeight
		local isInHistory = self:isCursorInArea(cursorX, cursorY, minX, minY, maxX, maxY)

		if state == "down" then
			if isOutsideWindow then
				self:closeSelect()
			elseif isInPalette then
				self.pickingColor = true
			elseif isInLuminance then
				self.pickingLuminance = true
			elseif isInAlpha then
				self.pickingAlpha = true
			elseif isInHistory then
				self:pickHistory(cursorX - minX, cursorY - minY)
			end
		elseif state == "up" then
			if self.pickingColor then
				self.pickingColor = false
			elseif self.pickingLuminance then
				self.pickingLuminance = false
			elseif self.pickingAlpha then
				self.pickingAlpha = false
			end
		end
	end,
	pickHistory = function( self, cursorX, cursorY)
		local relX = cursorX
		local relY = cursorY - 25

		if relX < 0 or relY < 0 then return end

		local boxWidth = (self.selectWindow.historyWidth - 15) / 3
		local boxHeight = (self.selectWindow.historyHeight - 45) / 3

		local modX = relX % (boxWidth + 5)
		local modY = relY % (boxHeight + 5)

		if modX > boxWidth or modY > boxHeight then return end

		local j = math.floor(relX / (boxWidth + 5))
		local i = math.floor(relY / (boxHeight + 5))
		local box = j + 1 + i * 3

		if box < 1 or box > #colorHistory then return end
		local color = colorHistory[box]
		self.h, self.s, self.l = self:rgb2hsl(color[1] / 255, color[2] / 255, color[3] / 255)
		self.avoidRecursion = true
		self:setValue(color)
		self.avoidRecursion = false
	end,
	convertColorToTable = function( self, color )
		local result

		if type(color) == "string" then
			result = {getColorFromString(color)}
		elseif type(color) == "number" then
			local str
			if color > 0xFFFFFF then
				-- RGBA color
				str = "#" .. string.format("%08X", color)
			else
				-- RGB color
				str = "#" .. string.format("%06X", color)
			end
			result = {getColorFromString(str)}
		elseif type(color) == "table" then
			result = color
		else
			result = { 255, 255, 255, 255 }
		end

		local checkValue = function(value)
		                     if not value then return 255 end
				     value = math.floor(tonumber(value))
		                     if value < 0 then return 0
		                     elseif value > 255 then return 255
		                     else return value end
		                  end
		result[1] = checkValue(result[1])
		result[2] = checkValue(result[2])
		result[3] = checkValue(result[3])
		result[4] = checkValue(result[4])

		return result
	end,
	hsl2rgb = function(self, h, s, l)
		local m2
		if l < 0.5 then
			m2 = l * (s + 1)
		else
			m2 = (l + s) - (l * s)
		end
		local m1 = l * 2 - m2

		local hue2rgb = function(m3, m4, h2)
			if h2 < 0 then
				h2 = h2 + 1
			elseif h2 > 1 then
				h2 = h2 - 1
			end

			if h2*6 < 1 then
				return m3 + (m4 - m3) * h2 * 6
			elseif h2*2 < 1 then
				return m4
			elseif h2*3 < 2 then
				return m3 + (m4 - m3) * (2/3 - h2) * 6
			else
				return m3
			end
		end

		local r = hue2rgb(m1, m2, h + 1/3)
		local g = hue2rgb(m1, m2, h)
		local b = hue2rgb(m1, m2, h - 1/3)
		return r, g, b
	end,
	rgb2hsl = function(self, r, g, b)
		local max = math.max(r, g, b)
		local min = math.min(r, g, b)
		local l = (min + max) / 2
		local h
		local s

		if max == min then
			h = 0
			s = 0
		else
			local d = max - min

			if l < 0.5 then
				s = d / (max + min)
			else
				s = d / (2 - max - min)
			end

			if max == r then
				h = (g - b) / d
				if g < b then h = h + 6 end
			elseif max == g then
				h = (b - r) / d + 2
			else
				h = (r - g) / d + 4
			end

			h = h / 6
		end

		return h, s, l
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.WGUI.selectWindow) )
		self:openSelect()
	end,
}
eC.colour = eC.color

eC.vehicleupgrades = {
	default = {
		x = 0,
		y = 0,
		width=240,
		height=320,
		buttonHeight=20,
		buttonWidth=100,
		relative = false,
		value = {},
	},
	constructor = function( self, info )
		local vehicleID
		local IDnumber = tonumber(info.vehicle)
		if IDnumber then
			vehicleID = IDnumber
		elseif isElement(info.vehicle) and getElementType(info.vehicle) == "vehicle" then
			vehicleID = getElementModel(info.vehicle)
		else
			error("Vehicle ID or vehicle element expected in 'vehicle' parameter, got '"..tostring(info.vehicle).."'.",2)
		end

		self.selectedUpgrades = {}

		local gridlistHeight = info.height - info.buttonHeight

		self.GUI.list = guiCreateGridList(info.x, info.y, info.width, gridlistHeight, info.relative, info.parent)
		guiGridListSetSortingEnabled(self.GUI.list, false)
		guiGridListSetSelectionMode(self.GUI.list, 0)
		guiGridListAddColumn(self.GUI.list, "Upgrade",  .4)
		guiGridListAddColumn(self.GUI.list, "Installed?", .2)

		self:addCompatibleUpgrades(vehicleID)
		self:setValue(info.value)

		--add a handler to update the caption when the selected item changes
		self:addHandler("onClientGUIClick", self.GUI.list, self.changeCaptionOnClick)
		self:addHandler("onClientGUIDoubleClick", self.GUI.list, self.toggleUpgrade)

		self.GUI.button = guiCreateButton(info.x, info.y + gridlistHeight, info.buttonWidth, info.buttonHeight, "Add", info.relative, info.parent)
		self:addHandler("onClientGUIClick", self.GUI.button, self.toggleUpgrade)

		return self
	end,
	addCompatibleUpgrades = function ( self, vehicleID  )
		guiGridListClear(self.GUI.list)
		self.currentModel = vehicleID

		--populate list with compatible upgrades
		self.upgradeItemRows = {}
		if compatibleUpgrades[vehicleID] then
			for upgradeSlot=0,16 do
				local compatList = compatibleUpgrades[vehicleID][upgradeSlot]
				if compatList then
					guiGridListSetItemText(self.GUI.list, guiGridListAddRow(self.GUI.list), 1,
					                       getVehicleUpgradeSlotName(upgradeSlot), true, false) --!
					for i, upgradeID in ipairs(compatList) do
						local itemRow = guiGridListAddRow(self.GUI.list)
						self.upgradeItemRows[upgradeID] = itemRow
						guiGridListSetItemText(self.GUI.list, itemRow, 1, getVehicleUpgradeName(upgradeID), false, true)
						guiGridListSetItemData(self.GUI.list, itemRow, 1, tostring(upgradeID))
						guiGridListSetItemText(self.GUI.list, itemRow, 2, " ", false, false)
					end
				end
			end
		end

		self.selectedUpgrades = {}

		guiGridListSetSelectedItem(self.GUI.list, 1, 1)
		guiGridListSetSelectedItem(self.GUI.list, -1, -1)
	end,
	getCurrentModel = function ( self )
		return self.currentModel
	end,
	setValue = function( self, ... )
		local arg = {...}

		--get the list
		local newSelectedUpgrades
		if type(arg[1]) == "number" then
			newSelectedUpgrades = arg
		elseif type(arg[1]) == "table" then
			newSelectedUpgrades = arg[1]
		elseif type(arg[1]) == "string" then
			local upgrades = split(arg[1], string.byte(','))
			for i, upgradeID in ipairs(upgrades) do
				upgrades[i] = tonumber(upgradeID)
			end
			newSelectedUpgrades = upgrades
		else
			error("Upgrade ID list, table or comma-separated string expected.",2)
		end

		--remove current selection marks
		for i, upgradeID in ipairs(self.selectedUpgrades) do
			guiGridListSetItemText(self.GUI.list, self.upgradeItemRows[upgradeID], 2, "", false, false)
		end

		self.selectedUpgrades = {}

		--only take last upgrade of the same slot
		local upgradeOnSlot = {}
		for i, selectedUpgrade in ipairs(newSelectedUpgrades) do
			local slotName = getVehicleUpgradeSlotName( selectedUpgrade )
			upgradeOnSlot[slotName] = selectedUpgrade
		end

		--add them to list and update selection marks
		for k, upgradeID in pairs(upgradeOnSlot) do
			table.insert(self.selectedUpgrades, upgradeID)
			guiGridListSetItemText(self.GUI.list, self.upgradeItemRows[upgradeID], 2, "X", false, false)
		end

		---[[!w
		guiGridListSetSelectedItem( self.GUI.list, 1, 1 )
		guiGridListSetSelectedItem( self.GUI.list, -1, -1 )
		---]]

		self:callChangeHandlers()

		return true
	end,
	getValue = function( self )
		return table.copy(self.selectedUpgrades)
	end,
	changeCaptionOnClick = function( self )
		local selectedItem = guiGridListGetSelectedItem( self.GUI.list )
		if not selectedItem then return end

		local upgradeID = tonumber(guiGridListGetItemData( self.GUI.list, selectedItem, 1 ))
		if not upgradeID then return end

		local buttonCaption
		if table.find(self.selectedUpgrades, upgradeID) then
			buttonCaption = "Remove"
		else
			buttonCaption = "Add"
		end
		guiSetText(self.GUI.button, buttonCaption)
	end,
	toggleUpgrade = function( self )
		local selectedItem = guiGridListGetSelectedItem( self.GUI.list )
		if not selectedItem then return end

		local upgradeID = tonumber(guiGridListGetItemData( self.GUI.list, selectedItem, 1 ))
		if not upgradeID then return end

		local buttonCaption
		local pos = table.find(self.selectedUpgrades, upgradeID)
		if pos then
			table.remove(self.selectedUpgrades, pos)
			guiGridListSetItemText(self.GUI.list, self.upgradeItemRows[upgradeID], 2, " ", false, false)
			buttonCaption = "Add"
		else
			--remove the currently selected upgrade for the same slot
			local slotName = getVehicleUpgradeSlotName(upgradeID)
			for i, selectedUpgrade in ipairs(self.selectedUpgrades) do
				if getVehicleUpgradeSlotName(selectedUpgrade) == slotName then
					guiGridListSetItemText(self.GUI.list, self.upgradeItemRows[selectedUpgrade], 2, " ", false, false)
					table.remove(self.selectedUpgrades, i)
					break
				end
			end

			table.insert(self.selectedUpgrades, upgradeID)
			guiGridListSetItemText(self.GUI.list, self.upgradeItemRows[upgradeID], 2, "X", false, false)
			buttonCaption = "Remove"
		end

		---[[!w
		guiGridListSetSelectedItem( self.GUI.list, selectedItem, 2 )
		guiGridListSetSelectedItem( self.GUI.list, selectedItem, 1 )
		---]]
		guiSetText(self.GUI.button, buttonCaption)

		self:callChangeHandlers()
	end,
}

eC.blipID = {
	default = {
		x = 0,
		y = 0,
		width = 200,
		height = 20,
		iconY = 2,
		iconWidth = 16,
		iconHeight = 16,
		iconPadding = 7,
		idWidth = 60,
		browserWidth = 260,
		browserHeight = 270,
		relative = false,
	},
	constructor = function( self, info )
		self.value = info.value
		self.parent = info.parent

		self.GUI.icon = guiCreateStaticImage(info.x, info.y + info.iconY,
		                                     info.iconWidth, info.iconHeight,
						     "client/images/blips/" .. tostring(self.value) .. ".png",
						     info.relative, info.parent)

		local info_mt = {__index=info}
		local infoID = setmetatable( {value=info.value, width=info.idWidth,
		                              x=info.x + info.iconWidth + info.iconPadding,
					      min=0, max=63}, info_mt )

		self.children.ID = eC.natural:create(infoID)
		self.children.ID:addChangeHandler(function() self:setValue(self.children.ID:getValue()) end)

		local changeX = info.x + info.iconWidth + info.idWidth + info.iconPadding
		local changeWidth = info.width - info.iconWidth - info.idWidth - info.iconPadding
		self.GUI.change = guiCreateButton(changeX, info.y,
		                                  changeWidth, info.height,
						  "Change", info.relative, info.parent)
		self:addHandler("onClientGUIClick", self.GUI.change, self.openBrowser, false)

		local screenWidth, screenHeight
		if info.relative then
			screenWidth, screenHeight = 1,1
		else
			screenWidth, screenHeight = guiGetScreenSize()
		end
		local browserX = screenWidth - info.browserWidth
		local browserY = (screenHeight - info.browserHeight) / 2

		self.WGUI.browser = guiCreateWindow(browserX, browserY,
		                                   info.browserWidth, info.browserHeight,
						   "Choose an icon", info.relative)
		guiSetVisible(self.WGUI.browser, false)
		self.browserActive = false

		self.WGUI.browserIcons = {}
		for i=0,7 do
			for j=0,7 do
				local iconX = 12 + (j*30)
				local iconY = 25 + (i*30)
				local id = i*8+j
				self.WGUI.browserIcons[id] = guiCreateStaticImage(iconX, iconY, 24, 24,
				                                                 "client/images/blips/"..id..".png",
										 false, self.WGUI.browser)
			end
		end

		return self
	end,
	setValue = function( self, value )
		if value and not self.avoidRecursion then
			self.avoidRecursion = true
			self.children.ID:setValue(value)
			self.avoidRecursion = false

			self.value = value
			guiStaticImageLoadImage(self.GUI.icon, "client/images/blips/" .. tostring(self.value) .. ".png")

			self:callChangeHandlers()
		end
	end,
	getValue = function( self )
		return self.value
	end,
	openBrowser = function( self )
		if not self.browserActive then
			guiSetVisible(self.WGUI.browser, true)
			self:addHandler("onClientGUIClick", self.WGUI.browser, self.browserClick, true)
			self.browserActive = true
		end
	end,
	closeBrowser = function( self )
		if self.browserActive then
			guiSetVisible(self.WGUI.browser, false)
			self:removeHandler()
			self.browserActive = false
		end
	end,
	browserClick = function( self, button, buttonState )
		if button ~= "left" then return end

		for id=0, 63 do
			if self.WGUI.browserIcons[id] == source then
				self:closeBrowser()
				self:setValue(id)
				break
			end
		end
	end,
	focus = function(self)
		setCursorPosition ( guiElementGetScreenPosition(self.WGUI.browser) )
		self:openBrowser()
	end,
}

eC.selection = {
	default = eC.dropdown.default,
	constructor = function( self, info )
		if info.validvalues then
			info.rows = info.validvalues
		else
			info.rows = {}
		end
		self.children.dropdown = eC.dropdown:create( info )
		self.children.dropdown:addChangeHandler(function() self:callChangeHandlers() end)
		return self
	end,
	setValue = function ( self, value )
		self.children.dropdown:setValue ( value )
	end,
	getValue = function( self )
		return self.children.dropdown:getValue()
	end,
	focus = function(self)
		self.children.dropdown:focus()
	end,
}

--controls' metatable--
local function destroyElementsInTable( t )
	for name, guiElement in pairs( t ) do
		if type(guiElement) == "table" then
			destroyElementsInTable(guiElement)
		elseif isElement(guiElement) then
			destroyElement(guiElement)
		end
	end
end

local control_mt = {
	create = function( control, info )
		info = info or {}
		if not getmetatable(info) then
			setmetatable(info, control.default)
		end

		local newControl = setmetatable({}, {__index = control})
		newControl.GUI = {}
		newControl.WGUI = {}
		newControl.handlers = {}
		newControl.binds = {}
		newControl.changeHandlers = {}
		newControl.children = {}

		-- Apply common values for controls
		newControl.datafield = info.datafield
		newControl.label = info.label

		return newControl:constructor(info)
	end,

	getLabel = function( control )
		return control.label
	end,

	getType = function( control )
		return control.name
	end,

	getDataField = function( control )
		return control.datafield
	end,

	destroy = function( control )
		if control.changeHandler then
			removeEventHandler(unpack(control.changeHandler))
		end
		for i, packedHandler in ipairs( control.handlers ) do
			removeEventHandler(unpack(packedHandler))
		end
		for i, packedBind in ipairs(control.binds) do
			unbindKey(unpack(packedBind))
		end
		for name, childControl in pairs( control.children ) do
			childControl:destroy()
		end
		destroyElementsInTable( control.GUI )
		destroyElementsInTable( control.WGUI )
		setmetatable(control, nil)
	end,

	setChangeHandler = function ( control, mtaEvent, fromElement, handlerFunction, getPropagated )
		if control.changeHandler then
			removeEventHandler(unpack(control.changeHandler))
		end
		fromElement = fromElement or root
		local wrapperFunction = function(...) handlerFunction(control, ...) end
		control.changeHandler = { mtaEvent, fromElement, wrapperFunction }
		addEventHandler(mtaEvent, fromElement, wrapperFunction, (getPropagated == true))
	end,

	addChangeHandler = function ( control, handlerFunction )
		if not handlerFunction then error("handlerFunction is nil", 2) end
		table.insert( control.changeHandlers, handlerFunction )
	end,

	callChangeHandlers = function ( control )
		for k,handler in ipairs(control.changeHandlers) do
			handler( control )
		end
	end,

	addHandler = function ( control, mtaEvent, fromElement, handlerFunction, getPropagated )
		if not handlerFunction then error("handlerFunction is nil", 2) end
		fromElement = fromElement or root
		-- generate a function that sends the control, then the parameters, to the real handler
		local wrapperFunction = function(...) handlerFunction(control, ...) end
		-- register it in a table so we can remove it on destroy
		table.insert( control.handlers, {mtaEvent, fromElement, wrapperFunction} )
		-- register it as the event's handler
		addEventHandler( mtaEvent, fromElement, wrapperFunction, (getPropagated == true) )

		return #control.handlers
	end,

	removeHandler = function ( control, handlerIndex )
		local packedHandler = control.handlers[handlerIndex or #control.handlers]
		if packedHandler then
			table.remove(control.handlers, handlerIndex)
			return removeEventHandler(unpack(packedHandler))
		else
			return false
		end
	end,

	addBind = function ( control, key, keyState, handlerFunction, ... )
		if not handlerFunction then error("handlerFunction is nil", 2) end
		local wrapperFunction = function(...) handlerFunction(control, ...) end
		table.insert( control.binds, {key, keyState, wrapperFunction} )
		bindKey(key, keyState, wrapperFunction, unpack(arg))

		return #control.binds
	end,

	removeBind = function ( control, bindIndex )
		local packedBind = control.binds[bindIndex or #control.binds]
		if packedBind then
			table.remove(control.binds, bindIndex)
			return unbindKey(unpack(packedBind))
		else
			return false
		end
	end,
}

--inheritance--
control_mt.__index = control_mt
for controlName, control in pairs(eC) do
	setmetatable(control, control_mt)
	control.default.__index = control.default
	control.name = controlName
end

--redirect shortcut control names, so--
--editingControl.shortcut:create(...) -> editingControl.associatedControl:create("shortcut",...)--
local shortcutCreator

local eC_mt = {}
eC_mt.__index = function(t, key)
	if catalogTypes[key] then
		eC_mt.accessedControl = eC.catalogID
		eC_mt.valueType = key
	elseif dropdownTypes[key] then
		eC_mt.accessedControl = eC.dropdown
		eC_mt.valueType = key
	elseif weaponDropDownTypes[key] then
		eC_mt.accessedControl = eC.dropdown
		eC_mt.valueType = key
	else
		return
	end
	shortcutCreator.__index = eC_mt.accessedControl
	return shortcutCreator
end
setmetatable(eC, eC_mt)

shortcutCreator = {
	create = function(control, info)
		info = info or {}
		info.type = eC_mt.valueType
		eC_mt.valueType = nil
		return control_mt.create(eC_mt.accessedControl, info)
	end,
}
setmetatable(shortcutCreator, shortcutCreator)

function guiElementGetScreenPosition(element)
	local x,y = guiGetPosition(element,false)
	local parent = getElementParent(element)
	while getElementType(parent) ~= "guiroot" do
		local parentX,parentY = guiGetPosition(parent,false)
		x = x + parentX
		y = y + parentY
		if getElementType(parent) == "gui-window" then --Account for the title bar
			y = y + 20
		end
		parent = getElementParent(parent)
	end
	local width,height = guiGetSize(element,false)
	x = x + (width/2)
	y = y + (height/2)
	y = y + 7 --Account for the mouse's height
	return x,y
end

