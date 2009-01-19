primaryPos = {}
secondaryPos = {}
weapons = {}
--priWeapon = {}

function createVehicleGUI ()
	if isKeyBound("mouse1", "down") == true then
		unbindKey("mouse1", "down")
		unbindKey("mouse1", "up")
		unbindKey("mouse2", "down")
		unbindKey("mouse2", "up")
		unbindKey("r", "down")
	end
	--toggleCameraFixedMode(true)
	--setTimer(setCameraPosition,100, 1, camX, camY, camZ)
	--setTimer(setCameraLookAt, 500, 1, camX, camY + 5, camZ)
	setCameraMatrix(camX, camY, camZ, camX, camY + 5, camZ)
if ( garage ) then
	destroyElement(garage)
	garage = nil
end
if not vehicleList then
	vehicleList	= guiCreateGridList ( 0.80, 0.05, 0.15, 0.2, true )
	addEventHandler ("onClientGUIClick", vehicleList, chooseVehicle, false )
	guiGridListAddColumn ( vehicleList, "Vehicle: ", 0.85 )
	guiGridListSetSortingEnabled ( vehicleList, false )
	vehicles = getElementsByType ("tehVehicle", theVehicles)
	for k,v in ipairs(vehicles) do
		local row = guiGridListAddRow ( vehicleList )
		local name = getElementData (v, "id")
		guiGridListSetItemText ( vehicleList, row, 1, name, false, false )
	end
	
	priWeaponList = guiCreateGridList ( 0.80, 0.25, 0.15, 0.2, true )
	addEventHandler ("onClientGUIClick", priWeaponList, choosePrimary, false )
	guiGridListAddColumn( priWeaponList, "Primary Weapon: ", 0.85 )
	secWeaponList = guiCreateGridList ( 0.80, 0.45, 0.15, 0.2, true )
	addEventHandler ("onClientGUIClick", secWeaponList, chooseSecondary, false )
	guiGridListAddColumn( secWeaponList, "Secondary Weapon: ", 0.85 )
	thrWeaponList = guiCreateGridList ( 0.80, 0.65, 0.15, 0.2, true )
	addEventHandler ("onClientGUIClick", thrWeaponList, chooseAccess, false )
	guiGridListAddColumn( thrWeaponList, "Accessory (R): ", 0.85 )	
	accept1 = guiCreateButton ( 0.85, 0.90, 0.13, 0.04, "Accept", true )
	addEventHandler ( "onClientGUIClick", accept1, acceptSelection, false )
else
	guiSetVisible(vehicleList, true)
	guiSetVisible(priWeaponList, true)
	guiSetVisible(secWeaponList, true)
	guiSetVisible(thrWeaponList, true)
	guiSetVisible(accept1, true)
	guiBringToFront(vehicleList)
	guiBringToFront(priWeaponList)
	guiBringToFront(secWeaponList)
	guiBringToFront(thrWeaponList)
	guiBringToFront(accept1)
	local row, column = guiGridListGetSelectedItem ( vehicleList )
	if (row ~= -1 and column ~= -1) then
		chooseVehicle()
	end
end
	showCursor ( true )
	garage = createObject(14783, camX,camY + 11,camZ, 0, 0, 220)
	setObjectScale (garage, 1.5)
	theLaser = createObject(1337, camX, camY + 11, camZ - 3, 0, 0, 0)
	addEventHandler("onClientElementStreamIn", theLaser, replaceTheLaser, false)
	
end
addCommandHandler ("showgui", createVehicleGUI)
addEvent ("vehicleChooser", true)
addEventHandler ( "vehicleChooser", getLocalPlayer(), createVehicleGUI )

function chooseVehicle()
local row, column = guiGridListGetSelectedItem ( vehicleList )
if (row == -1 and column == -1) then return end
	playSoundFrontEnd(6)
	vehicleName = guiGridListGetItemText ( vehicleList, guiGridListGetSelectedItem ( vehicleList ), 1 )
	vehicle = getElementByID (vehicleName)
	image = getElementData (vehicle, "image")
	model = getElementData (vehicle, "model")
	weapons = getElementChildren ( vehicle )
	guiGridListClear ( priWeaponList )
	guiGridListClear ( secWeaponList )
	guiGridListClear ( thrWeaponList )
	if ( priWeapon0 ~= nil ) then
		destroyElement(priWeapon0)
		priWeapon0 = nil
	end
	if ( priWeapon1 ~= nil ) then
		destroyElement(priWeapon1)
		priWeapon1 = nil
	end
	if ( priWeapon2 ~= nil) then
		destroyElement(priWeapon2)
		priWeapon2 = nil
	end
	if ( priWeapon3 ~= nil) then
		destroyElement(priWeapon3)
		priWeapon3 = nil
	end
	if ( secWeapon0 ~= nil) then
		destroyElement(secWeapon0)
		secWeapon0 = nil
	end
	if ( secWeapon1 ~= nil) then
		destroyElement(secWeapon1)
		secWeapon1 = nil
	end
	if ( secWeapon2 ~= nil) then
		destroyElement(secWeapon2)
		secWeapon2 = nil
	end
	if ( ivehicle ~= nil) then
		destroyElement(ivehicle)
		ivehicle = nil
	end
	 ivehicle = createVehicle (model, camX, camY + 11, camZ - 1, 0, 0, -220)
	local row1, column1 = guiGridListGetSelectedItem ( priWeaponList )
	local row2, column2 = guiGridListGetSelectedItem ( secWeaponList )
	if (row1 ~= -1 and column1 ~= -1 and row2 ~= -1 and column2 ~= -1) then
		choosePrimary()
		chooseSecondary()
	else
	for k,v in ipairs(weapons) do
		local name = getElementData(v, "name")
		--outputChatBox (tostring(getElementType(v)))
		if getElementType(v) == "primary" then
			local name = getElementData(v, "name")
			local row = guiGridListAddRow ( priWeaponList )
			guiGridListSetItemText ( priWeaponList, row, 1, name, false, false )
		elseif getElementType(v) == "secondary" then
			local row = guiGridListAddRow ( secWeaponList )
			guiGridListSetItemText ( secWeaponList, row, 1, name, false, false )
		elseif getElementType(v) == "accessory" then
			local row = guiGridListAddRow ( thrWeaponList )
			guiGridListSetItemText ( thrWeaponList, row, 1, name, false, false )
		--else
			--outputChatBox ("buuu!")
		end
	end
	end
end
function choosePrimary ()
local row1, column1 = guiGridListGetSelectedItem ( priWeaponList )
if (row1 == -1 and column1 == -1) then return end
	playSoundFrontEnd(46)
	vehicleName = guiGridListGetItemText ( vehicleList, guiGridListGetSelectedItem ( vehicleList ), 1 )
	vehicle = getElementByID (vehicleName)
	priWeaponName = guiGridListGetItemText ( priWeaponList, guiGridListGetSelectedItem ( priWeaponList ), 1 )
	
	priWeaponID = getElementByID (vehicleName.."_"..priWeaponName)
	priWeaponModel = getElementData (priWeaponID, "model")
	priWeaponX = getElementData (priWeaponID, "posX")
	priWeaponY = getElementData (priWeaponID, "posY")
	priWeaponZ = getElementData (priWeaponID, "posZ")
	priWeaponrotX = getElementData (priWeaponID, "rotX")
	priWeaponrotY = getElementData (priWeaponID, "rotY")
	priWeaponrotZ = getElementData (priWeaponID, "rotZ")
	if ( priWeapon0 ) then
		destroyElement(priWeapon0)
		priWeapon0 = nil
	end
	if ( priWeapon1 ) then
		destroyElement(priWeapon1)
		priWeapon1 = nil
	end
	if ( priWeapon2 ) then
		destroyElement(priWeapon2)
		priWeapon2 = nil
	end
	if ( priWeapon3 ) then
		destroyElement(priWeapon3)
		priWeapon3 = nil
	end
	priWeapon0 = createObject (priWeaponModel, 0, 0, 0)
	attachElements(priWeapon0, ivehicle, priWeaponX, priWeaponY, priWeaponZ, priWeaponrotX, priWeaponrotY, priWeaponrotZ)
	if getElementData(priWeaponID, "posX1") then
		priWeaponX1 = getElementData (priWeaponID, "posX1")
		priWeaponY1 = getElementData (priWeaponID, "posY1")
		priWeaponZ1 = getElementData (priWeaponID, "posZ1")
		priWeaponrotX1 = getElementData (priWeaponID, "rotX1")
		priWeaponrotY1 = getElementData (priWeaponID, "rotY1")
		priWeaponrotZ1 = getElementData (priWeaponID, "rotZ1")
		priWeapon1 = createObject (priWeaponModel, 0, 0, 0)
		attachElements(priWeapon1, ivehicle, priWeaponX1, priWeaponY1, priWeaponZ1, priWeaponrotX1, priWeaponrotY1, priWeaponrotZ1)
	end
	if getElementData(priWeaponID, "posX2") then
		priWeaponX2 = getElementData (priWeaponID, "posX2")
		priWeaponY2 = getElementData (priWeaponID, "posY2")
		priWeaponZ2 = getElementData (priWeaponID, "posZ2")
		priWeaponrotX2 = getElementData (priWeaponID, "rotX2")
		priWeaponrotY2 = getElementData (priWeaponID, "rotY2")
		priWeaponrotZ2 = getElementData (priWeaponID, "rotZ2")
		priWeapon2 = createObject (priWeaponModel, 0, 0, 0)
		attachElements(priWeapon2, ivehicle, priWeaponX2, priWeaponY2, priWeaponZ2, priWeaponrotX2, priWeaponrotY2, priWeaponrotZ2)
	end
	if getElementData(priWeaponID, "posX3") then
		priWeaponX3 = getElementData (priWeaponID, "posX3")
		priWeaponY3 = getElementData (priWeaponID, "posY3")
		priWeaponZ3 = getElementData (priWeaponID, "posZ3")
		priWeaponrotX3 = getElementData (priWeaponID, "rotX3")
		priWeaponrotY3 = getElementData (priWeaponID, "rotY3")
		priWeaponrotZ3 = getElementData (priWeaponID, "rotZ3")
		priWeapon3 = createObject (priWeaponModel, 0, 0, 0)
		attachElements(priWeapon3, ivehicle, priWeaponX3, priWeaponY3, priWeaponZ3, priWeaponrotX3, priWeaponrotY3, priWeaponrotZ3)
	end
end
function chooseSecondary ()
local row2, column2 = guiGridListGetSelectedItem ( secWeaponList )
if (row2 == -1 and column2 == -1) then return end
	playSoundFrontEnd(46)
	vehicleName = guiGridListGetItemText ( vehicleList, guiGridListGetSelectedItem ( vehicleList ), 1 )
	vehicle = getElementByID (vehicleName)
	secWeaponName = guiGridListGetItemText ( secWeaponList, guiGridListGetSelectedItem ( secWeaponList ), 1 )
	secWeaponID = getElementByID (vehicleName.."_"..secWeaponName)
	if ( secWeapon0 ) then
		destroyElement(secWeapon0)
		secWeapon0 = nil
	end
	if ( secWeapon1 ) then
		destroyElement(secWeapon1)
		secWeapon1 = nil
	end
	if ( secWeapon2 ) then
		destroyElement(secWeapon2)
		secWeapon2 = nil
	end
	secWeaponModel = getElementData (secWeaponID, "model")
	if getElementData(secWeaponID, "posX") then
		secWeaponX = getElementData (secWeaponID, "posX")
		secWeaponY = getElementData (secWeaponID, "posY")
		secWeaponZ = getElementData (secWeaponID, "posZ")
		secWeaponrotX = getElementData (secWeaponID, "rotX")
		secWeaponrotY = getElementData (secWeaponID, "rotY")
		secWeaponrotZ = getElementData (secWeaponID, "rotZ")
		secWeapon0 = createObject (secWeaponModel, 0, 0, 0)
		attachElements(secWeapon0, ivehicle, secWeaponX, secWeaponY, secWeaponZ, secWeaponrotX, secWeaponrotY, secWeaponrotZ)
	end
	if getElementData(secWeaponID, "posX1") then
		secWeaponX1 = getElementData (secWeaponID, "posX1")
		secWeaponY1 = getElementData (secWeaponID, "posY1")
		secWeaponZ1 = getElementData (secWeaponID, "posZ1")
		secWeaponrotX1 = getElementData (secWeaponID, "rotX1")
		secWeaponrotY1 = getElementData (secWeaponID, "rotY1")
		secWeaponrotZ1 = getElementData (secWeaponID, "rotZ1")
		secWeapon1 = createObject (secWeaponModel, 0, 0, 0)
		attachElements(secWeapon1, ivehicle, secWeaponX1, secWeaponY1, secWeaponZ1, secWeaponrotX1, secWeaponrotY1, secWeaponrotZ1)
	end
	if getElementData(secWeaponID, "posX2") then
		secWeaponX2 = getElementData (secWeaponID, "posX2")
		secWeaponY2 = getElementData (secWeaponID, "posY2")
		secWeaponZ2 = getElementData (secWeaponID, "posZ2")
		secWeaponrotX2 = getElementData (secWeaponID, "rotX2")
		secWeaponrotY2 = getElementData (secWeaponID, "rotY2")
		secWeaponrotZ2 = getElementData (secWeaponID, "rotZ2")
		secWeapon2 = createObject (secWeaponModel, 0, 0, 0)
		attachElements(secWeapon2, ivehicle, secWeaponX2, secWeaponY2, secWeaponZ2, secWeaponrotX2, secWeaponrotY2, secWeaponrotZ2)
	end
end

function chooseAccess ()
	playSoundFrontEnd(46)
end

function acceptSelection (element)
	playSoundFrontEnd(5)
	vehicle = {}
	vehicleName = guiGridListGetItemText ( vehicleList, guiGridListGetSelectedItem ( vehicleList ), 1 )
	modelID = getElementByID (vehicleName)
	model = getElementData (modelID, "model")
	vehicle[getLocalPlayer()] = { model }
	--14798
	--14783
	if ( priWeapon0 ) then
		destroyElement(priWeapon0)
		priWeapon0 = nil
	end
	if ( priWeapon1 ) then
		destroyElement(priWeapon1)
		priWeapon1 = nil
	end
	if ( priWeapon2 ) then
		destroyElement(priWeapon2)
		priWeapon2 = nil
	end
	if ( priWeapon3 ) then
		destroyElement(priWeapon3)
		priWeapon3 = nil
	end
	if ( secWeapon0 ) then
		destroyElement(secWeapon0)
		secWeapon0 = nil
	end
	if ( secWeapon1 ) then
		destroyElement(secWeapon1)
		secWeapon1 = nil
	end
	if ( secWeapon2 ) then
		destroyElement(secWeapon2)
		secWeapon2 = nil
	end
	if ( ivehicle ) then
		destroyElement(ivehicle)
		ivehicle = nil
	end
	primaryWeapon = {}
	priWeaponName = guiGridListGetItemText ( priWeaponList, guiGridListGetSelectedItem ( priWeaponList ), 1 )
	priWeaponID = getElementByID (vehicleName.."_"..priWeaponName)
	priWeaponModel = getElementData (priWeaponID, "model")
	priWeaponX = getElementData (priWeaponID, "posX")
	priWeaponY = getElementData (priWeaponID, "posY")
	priWeaponZ = getElementData (priWeaponID, "posZ")
	priWeaponrotX = getElementData (priWeaponID, "rotX")
	priWeaponrotY = getElementData (priWeaponID, "rotY")
	priWeaponrotZ = getElementData (priWeaponID, "rotZ")
	primaryWeapon[getLocalPlayer()] = { object = {priWeaponModel}, pos = {priWeaponX, priWeaponY, priWeaponZ, priWeaponrotX, priWeaponrotY, priWeaponrotZ}}
	if getElementData(priWeaponID, "posX1") then
		primaryWeapon1 = {}
		priWeaponX1 = getElementData (priWeaponID, "posX1")
		priWeaponY1 = getElementData (priWeaponID, "posY1")
		priWeaponZ1 = getElementData (priWeaponID, "posZ1")
		priWeaponrotX1 = getElementData (priWeaponID, "rotX1")
		priWeaponrotY1 = getElementData (priWeaponID, "rotY1")
		priWeaponrotZ1 = getElementData (priWeaponID, "rotZ1")
		primaryWeapon1[getLocalPlayer()] = { pos = {priWeaponX1, priWeaponY1, priWeaponZ1, priWeaponrotX1, priWeaponrotY1, priWeaponrotZ1}}
	else
		primaryWeapon1 = {}
	end
	if getElementData(priWeaponID, "posX2") then
		primaryWeapon2 = {}
		priWeaponX2 = getElementData (priWeaponID, "posX2")
		priWeaponY2 = getElementData (priWeaponID, "posY2")
		priWeaponZ2 = getElementData (priWeaponID, "posZ2")
		priWeaponrotX2 = getElementData (priWeaponID, "rotX2")
		priWeaponrotY2 = getElementData (priWeaponID, "rotY2")
		priWeaponrotZ2 = getElementData (priWeaponID, "rotZ2")
		primaryWeapon2[getLocalPlayer()] = { pos = {priWeaponX2, priWeaponY2, priWeaponZ2, priWeaponrotX2, priWeaponrotY2, priWeaponrotZ2}}
	else
		primaryWeapon2 = {}
	end
	if getElementData(priWeaponID, "posX3") then
		primaryWeapon3 = {}
		priWeaponX3 = getElementData (priWeaponID, "posX3")
		priWeaponY3 = getElementData (priWeaponID, "posY3")
		priWeaponZ3 = getElementData (priWeaponID, "posZ3")
		priWeaponrotX3 = getElementData (priWeaponID, "rotX3")
		priWeaponrotY3 = getElementData (priWeaponID, "rotY3")
		priWeaponrotZ3 = getElementData (priWeaponID, "rotZ3")
		primaryWeapon3[getLocalPlayer()] = { pos = {priWeaponX3, priWeaponY3, priWeaponZ3, priWeaponrotX3, priWeaponrotY3, priWeaponrotZ3}}
	else
		primaryWeapon3 = {}
	end
	--setElementData(getLocalPlayer(), "primary", priWeapon)
	priWeaponModel = getElementData (priWeaponID, "model")
	priWeapon = getElementData (priWeaponID, "type")
	
	
	secWeaponName = guiGridListGetItemText ( secWeaponList, guiGridListGetSelectedItem ( secWeaponList ), 1 )
	secWeaponID = getElementByID (vehicleName.."_"..secWeaponName)
	if getElementData(secWeaponID, "posX") then
		secondaryWeapon = {}
		secWeaponModel = getElementData (secWeaponID, "model")
		secWeaponX = getElementData (secWeaponID, "posX")
		secWeaponY = getElementData (secWeaponID, "posY")
		secWeaponZ = getElementData (secWeaponID, "posZ")
		secWeaponrotX = getElementData (secWeaponID, "rotX")
		secWeaponrotY = getElementData (secWeaponID, "rotY")
		secWeaponrotZ = getElementData (secWeaponID, "rotZ")
		secondaryWeapon[getLocalPlayer()] = { object = {secWeaponModel}, pos = { secWeaponX, secWeaponY, secWeaponZ, secWeaponrotX, secWeaponrotY, secWeaponrotZ}} 
	else
		secondaryWeapon = {}
	end
	if getElementData(secWeaponID, "posX1") then
		secondaryWeapon1 = {}
		secWeaponX1 = getElementData (secWeaponID, "posX1")
		secWeaponY1 = getElementData (secWeaponID, "posY1")
		secWeaponZ1 = getElementData (secWeaponID, "posZ1")
		secWeaponrotX1 = getElementData (secWeaponID, "rotX1")
		secWeaponrotY1 = getElementData (secWeaponID, "rotY1")
		secWeaponrotZ1 = getElementData (secWeaponID, "rotZ1")
		secondaryWeapon1[getLocalPlayer()] = { pos = { secWeaponX1, secWeaponY1, secWeaponZ1, secWeaponrotX1, secWeaponrotY1, secWeaponrotZ1}} 
	else
		secondaryWeapon1 = {}
	end
	if getElementData(secWeaponID, "posX2") then
		secondaryWeapon2 = {}
		secWeaponX2 = getElementData (secWeaponID, "posX2")
		secWeaponY2 = getElementData (secWeaponID, "posY2")
		secWeaponZ2 = getElementData (secWeaponID, "posZ2")
		secWeaponrotX2 = getElementData (secWeaponID, "rotX2")
		secWeaponrotY2 = getElementData (secWeaponID, "rotY2")
		secWeaponrotZ2 = getElementData (secWeaponID, "rotZ2")
		secondaryWeapon2[getLocalPlayer()] = { pos = { secWeaponX2, secWeaponY2, secWeaponZ2, secWeaponrotX2, secWeaponrotY2, secWeaponrotZ2}} 
	else
		secondaryWeapon2 = {}
	end
	secWeaponModel = getElementData (secWeaponID, "model")
	secWeapon = getElementData (secWeaponID, "type")
	
	thrWeaponName = guiGridListGetItemText ( thrWeaponList, guiGridListGetSelectedItem ( thrWeaponList ), 1 )
	thrWeaponID = getElementByID (thrWeaponName)
	thrWeapon = getElementData (thrWeaponID, "type")
	
	if priWeapon and secWeapon and thrWeapon then
		triggerServerEvent ("doTheSpawn", getLocalPlayer(), vehicle, primaryWeapon, primaryWeapon1, primaryWeapon2, primaryWeapon3, secondaryWeapon, secondaryWeapon1, secondaryWeapon2)
		hidethestuff()
	else
		displayGUItextToPlayer(0.3, 0.3, "Could not set data! Please rechoose!", "default-bold-small", 255, 255, 255, 3000)
	end
end

function hidethestuff ()
	destroyElement(garage)
	garage = nil
	guiSetVisible(vehicleList, false)
	guiSetVisible(priWeaponList, false)
	guiSetVisible(secWeaponList, false)
	guiSetVisible(thrWeaponList, false)
	guiSetVisible(accept1, false)
	showCursor ( false )
end
addCommandHandler ( "hidegui", hidethestuff )

function onTheMapStart(maxDeaths, vehicleRoot, cameraPos, realTime, theMode)
	if source ~= getLocalPlayer() then return
	else
		if hasDone == true then return
		else
			if tonumber(theMode) == 1 then
				if ( countDown ) then
					killTimer(countDown)
					countDown = nil
				end
				if ( guiTimerText ) then
					destroyElement (guiTimerText)
					guiTimerText = nil
				end
				maxdeaths1 = maxDeaths
			elseif tonumber(theMode) == 2 then
				maxdeaths1 = 0
				theCountDown = realTime
				theCountDown = math.floor(theCountDown / 1000)
				guiTimer ()
			end
			theMode1 = theMode
			theVehicles = vehicleRoot
			camX, camY, camZ = unpack(cameraPos)
			hasDone = true
			fadeCamera(true)
			clientResourceStart()
			setTimer (createVehicleGUI, 1000, 1)
			players = getElementsByType("player")
			addEventHandler("onClientRender", getLocalPlayer(), checkForVehicles)
		end
	end
end
addEvent("onTheMapStart", true)
addEventHandler("onTheMapStart", getRootElement(), onTheMapStart)

function realTimeUpdate (realTime)
	theCountDown = realTime
	theCountDown = math.floor(theCountDown / 1000)
	if ( countDown ) then
		killTimer(countDown)
		countDown = nil
	end
	guiTimer()
end
addEvent("theRealTime", true)
addEventHandler("theRealTime", getRootElement(), realTimeUpdate)

function isReady(resource)
	hasDone = false
	triggerServerEvent ("iAmReady", getLocalPlayer())
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), isReady)

function onTheMapStop ()
	hasDone = false
	if ( countDown) then
		killTimer(countDown)
		countDown = nil
	end
	if ( guiTimerText ) then
		destroyElement (guiTimerText)
	end
	if isShooting == true then
		stopMiniRocket()
	end
	deaths = 0
	showPlayerHudComponent("health", true)
	showPlayerHudComponent("money", true)
	showPlayerHudComponent("weapon", true)
	showPlayerHudComponent("vehicle_name", true)
	showPlayerHudComponent("armour", true)
	showPlayerHudComponent("area_name", true)
end
addEvent("onTheMapStop", true)
addEventHandler("onTheMapStop", getRootElement(), onTheMapStop)


function guiTimer ()
	local calcString = ""
	local timeHours = 0
	local timeMins = 0
	local timeSecs = 0
	
	timeLeft = tonumber(theCountDown)
	timeSecs = math.mod(timeLeft, 60)
	timeMins = math.mod((timeLeft / 60), 60)	
	timeHours = (timeLeft / 3600)
	
	if ( timeHours >= 1 ) then
		calcString = formatStr(tostring(timeHours)) .. ":"
	end
	calcString = calcString .. formatStr(string.format("%.0d", tostring(timeMins))) .. ":" .. formatStr(tostring(timeSecs))
	
	if not guiTimerText then
		guiTimerText = guiCreateLabel(0.85, 0.10, 0.10, 0.10, calcString, true)
		guiSetFont (guiTimerText, "default-bold-small")
	else
		guiSetVisible(guiTimerText, true)
		guiSetText(guiTimerText, calcString)
	end
	if ( countDown ) then
		killTimer(countDown)
		countDown = nil
	end
	countDown = setTimer (tickDown, 1000, 0)
end
addCommandHandler ("guitext", guiTimer)

function formatStr ( formatString )
	local aString = tostring(formatString)
	
	if ( #aString == 1 ) then
		aString = "0" .. aString
	end
	
	if ( #aString == 0 ) then
		aString = "00"
	end

	return aString
end

function tickDown ()
	local calcString = ""
	local timeHours = 0
	local timeMins = 0
	local timeSecs = 0
	
	timeLeft = timeLeft - 1
	if timeLeft < 0 then
		killTimer(countDown)
		countDown = nil
	else
		timeSecs = math.mod(timeLeft, 60)
		timeMins = math.mod((timeLeft / 60), 60)	
		timeHours = (timeLeft / 3600)
	
	if ( timeHours >= 1 ) then
		calcString = formatStr(tostring(timeHours)) .. ":"
	end
	calcString = calcString .. formatStr(string.format("%.0d", tostring(timeMins))) .. ":" .. formatStr(tostring(timeSecs))
	
	guiSetText (guiTimerText, calcString)
	end
end
addCommandHandler("down", tickDown)


maxDistance = 30
players = {}
nametag = {}
healthbartag = {}
secondhealthbartag = {}
function checkForVehicles () --UNFINISHED FUNCTION! DO NOT ATTEMPT TO USE THIS! YOU HAVE BEEN WARNED!
	for k,v in ipairs(players) do
	if (isElement(v) ) then
		if isElementOnScreen(v) == true then
			if v ~= getLocalPlayer() then
				if isPedInVehicle(v) then
					local x, y, z = getElementPosition(v)
					local px, py, pz = getElementPosition ( getLocalPlayer() )
					local screenX, screenY = getScreenFromWorldPosition (x, y, z)
					if (screenX) then
						local vehicle = getPedOccupiedVehicle(v)
						local distance = getDistanceBetweenPoints3D ( px, py, pz, x, y, z )
						if distance < maxDistance then
							if not nametag[v] then
								nametag[v] = guiCreateLabel(screenX, screenY-15, 100, 20, getPlayerName(v) , false)
								guiSetFont(nametag[v], "default-bold-small")
								guiSetSize ( nametag[v], guiLabelGetTextExtent ( nametag[v] ), guiLabelGetFontHeight ( nametag[v] ), false )
								healthbartag[v] = guiCreateNiceProgressBar(screenX, screenY, 70, 15, false)
								guiSetSize(healthbartag[v], 0.07, 0.015, true)
							else
								guiSetText(nametag[v], getPlayerName(v))
								guiSetVisible(nametag[v], true)
								guiSetPosition(nametag[v], screenX, screenY-15, false)
								guiSetVisible(healthbartag[v], true)
								local x, y = guiGetSize (healthbartag[v], false)
								local x1 = guiLabelGetTextExtent ( nametag[v] )
								local x2 = (x/2) - (x1/2)
								guiSetPosition(healthbartag[v], screenX - (x2), screenY, false)
								guiMoveToBack(nametag[v])
								guiMoveToBack(healthbartag[v])
								if secondhealthbartag[v] then
									guiSetPosition(secondhealthbartag[v], screenX - (x2), screenY+ (y + 3), false)
									--local x, y = guiGetSize(secondhealthbartag[v], false)
									--guiSetSize(secondhealthbartag[v], 70 - (distance), 15 - (distance/4), false)
									guiMoveToBack(secondhealthbartag[v])
								end
							end
							local health = getElementHealth(vehicle)
							local health = health/10
							if health > 100 then
								local secondhealth = health - 100
								local secondhealth = secondhealth * 2
									if not secondhealthbartag[v] then
										secondhealthbartag[v] = guiCreateNiceProgressBar(screenX, screenY+15, 70, 15, false)
										guiSetSize(secondhealthbartag[v], 0.07, 0.015, true)
									else
										guiSetVisible(secondhealthbartag[v], true)
									end
									guiNiceProgressBarSetProgress(healthbartag[v], 100)
									guiNiceProgressBarSetProgress(secondhealthbartag[v], tonumber(secondhealth))
							else
								if secondhealthbartag[v] then
									guiSetVisible(secondhealthbartag[v], false)
								end
								guiNiceProgressBarSetProgress(healthbartag[v], tonumber(health))
							end
							if health <= 0 then
								if nametag[v] then
									guiSetVisible(nametag[v], false)
									guiSetVisible(healthbartag[v], false)
								end
							end
						else
							if nametag[v] then
								guiSetVisible(nametag[v], false)
								guiSetVisible(healthbartag[v], false)
							end
							if secondhealthbartag[v] then
								guiSetVisible(secondhealthbartag[v], false)
							end
						end
					end
				end
			end
		else
			if nametag[v] then
				guiSetVisible(nametag[v], false)
				guiSetVisible(healthbartag[v], false)
			end
			if secondhealthbartag[v] then
				guiSetVisible(secondhealthbartag[v], false)
			end
		end
	end
	end
end
addCommandHandler("check", checkForVehicles)

addEventHandler("onClientPlayerJoin", getRootElement(), function ()
	players = getElementsByType("player")
end)

addEventHandler("onClientPlayerQuit", getRootElement(), function ()
	if nametag[source] then
		destroyElement(nametag[source])
		nametag[source] = nil
		destroyElement(healthbartag[source])
		healthbartag[source] = nil
	end
	if secondhealthbartag[source] then
		destroyElement(secondhealthbartag[source])
		secondhealthbartag[source] = nil
	end
	if isPedInVehicle(source) then
		--destroyElement(getPlayerOccupiedVehicle(source))
	end
	setTimer( function() players = getElementsByType("player") end, 500, 1)
end)

addEvent("getPlayers", true)
addEventHandler("getPlayers", getRootElement(), function ()
	players = getElementsByType("player")
end)

function spawns () --THIS IS A FUNCTION USED TO EASILY WRITE NEW SPAWNPOINTS FOR MAPS. IF YOU WANT TO MAKE A MAP FOR INTERSTATE BEFORE THE EDITOR IS OUT, UNCOMMENT THE addEventHandler() BELOW
	spawnpoints = xmlLoadFile("spawns.xml")
	if not spawnpoints then
		spawnpoints = xmlCreateFile("spawns.xml", "newspawnpoints")
	end
	bindKey ("F1", "down", createspawns)
	outputChatBox ("press F1 to create new spawnpoints")
end
addCommandHandler("newspawns", spawns)
	
function createspawns()	
	local x, y, z = getElementPosition(getLocalPlayer())
	spawn = xmlCreateChild ( spawnpoints, "spawnpoint" )
	xmlNodeSetAttribute(spawn, "posX", x )
	xmlNodeSetAttribute(spawn, "posY", y )
	xmlNodeSetAttribute(spawn, "posZ", z )
	xmlSaveFile(spawnpoints)
	outputChatBox ("Created spawnpoint")
end
	