-- DEFINES
local DEF_VehicleOffset = 0.003 -- Distance between click point and actual position to avoid spawning in the bodywork.
local DEF_AllowSync = true
local DEF_KeyBind = "0"
-- End of Defines don't edit below here if you don't know what you are doing.


local windowMultiplier = 0
local myWindow = guiCreateWindow ( 0.35, 0.3, 0.4, 0.4, "Siren Script", true )

local numberOfSirens = guiCreateComboBox( 0.28, 0.07+windowMultiplier, 0.5, 0.3, "Select a number of sirens", true, myWindow )
guiCreateLabel( 0.02, 0.06+windowMultiplier, 0.2, 0.1, "Number of Sirens:", true, myWindow )

windowMultiplier = 0.03
local sirenType = guiCreateComboBox( 0.28, 0.12+windowMultiplier, 0.5, 0.3, "Select a Type", true, myWindow )
guiCreateLabel( 0.02, 0.12+windowMultiplier, 0.2, 0.1, "Siren Type:", true, myWindow )

windowMultiplier = 0.06
local sirens = guiCreateComboBox( 0.28, 0.18+windowMultiplier, 0.5, 0.3, "Select a siren to edit", true, myWindow )
guiCreateLabel( 0.02, 0.18+windowMultiplier, 0.2, 0.1, "Siren ID:", true, myWindow )

windowMultiplier = 0.08

local posLabelX = guiCreateLabel( 0.02, 0.24+windowMultiplier, 0.3, 0.1, "X Position:", true, myWindow )
local sirensX = guiCreateScrollBar( 0.28, 0.24+windowMultiplier, 0.5, 0.05, true, true, myWindow)
local posLabelY = guiCreateLabel( 0.02, 0.30+windowMultiplier, 0.3, 0.1, "Y Position:", true, myWindow )
local sirensY = guiCreateScrollBar( 0.28, 0.30+windowMultiplier, 0.5, 0.05, true, true, myWindow)
local posLabelZ = guiCreateLabel( 0.02, 0.36+windowMultiplier, 0.3, 0.1, "Z Position:", true, myWindow )
local sirensZ = guiCreateScrollBar( 0.28, 0.36+windowMultiplier, 0.5, 0.05, true, true, myWindow )


local alphaLabel = guiCreateLabel( 0.02, 0.42+windowMultiplier, 0.34, 0.1, "Alpha: 255", true, myWindow )
local sirensAlpha = guiCreateScrollBar( 0.28, 0.42+windowMultiplier, 0.5, 0.05, true, true, myWindow )
local minAlphaLabel = guiCreateLabel( 0.02, 0.48+windowMultiplier, 0.34, 0.1, "Minimum Alpha: 255", true, myWindow )
local sirensMinAlpha = guiCreateScrollBar( 0.28, 0.48+windowMultiplier, 0.5, 0.05, true, true, myWindow )

guiCreateLabel( 0.02, 0.54+windowMultiplier, 0.34, 0.1, "Flags:", true, myWindow )
local sirensChk360 = guiCreateCheckBox( 0.16, 0.6+windowMultiplier, 0.46, 0.04, "Render 360 degrees", false, true, myWindow )
local sirensChkLOS = guiCreateCheckBox( 0.59, 0.6+windowMultiplier, 0.46, 0.04, "Check Visible", false, true, myWindow )

local sirensChkRand = guiCreateCheckBox( 0.16, 0.67+windowMultiplier, 0.46, 0.04, "Randomise", false, true, myWindow )
local sirensChkSilent = guiCreateCheckBox( 0.59, 0.67+windowMultiplier, 0.46, 0.04, "Silent", false, true, myWindow )
local windowMultiplierX = 0.05
local sirensBtn = guiCreateButton( 0.1+windowMultiplierX, 0.8+windowMultiplier, 0.15, 0.1, "Apply", true, myWindow )
local sirensBtnGet = guiCreateButton( 0.28+windowMultiplierX, 0.8+windowMultiplier, 0.15, 0.1, "Print", true, myWindow )
local sirensBtnRGB = guiCreateButton( 0.46+windowMultiplierX, 0.8+windowMultiplier, 0.15, 0.1, "Colour: #FFFFFF", true, myWindow )
local sirensBtnClose = guiCreateButton( 0.64+windowMultiplierX, 0.8+windowMultiplier, 0.15, 0.1, "Close", true, myWindow )
local sirensBtnSelect = guiCreateButton( 0.75+windowMultiplierX, 0.37, 0.15, 0.1, "Select", true, myWindow )


guiScrollBarSetScrollPosition( sirensX, 50 )
guiScrollBarSetScrollPosition( sirensY, 50 )
guiScrollBarSetScrollPosition( sirensZ, 50 )
guiSetProperty ( sirensX, "StepSize", 0.01 )
guiSetProperty ( sirensY, "StepSize", 0.01 )
guiSetProperty ( sirensZ, "StepSize", 0.01 )
guiSetProperty ( sirensAlpha, "StepSize", 0.04 )
guiSetProperty ( sirensMinAlpha, "StepSize", 0.04 )
for k = 1, 8 do
	guiComboBoxAddItem ( sirens, k )
	guiComboBoxAddItem ( numberOfSirens, k )
end
guiComboBoxAddItem ( sirenType, "Invisible" )
guiComboBoxAddItem ( sirenType, "Single" )
guiComboBoxAddItem ( sirenType, "Dual" )
guiComboBoxSetSelected ( sirens, 0 )
guiComboBoxSetSelected ( numberOfSirens, 0 )
function sirenCmd()
	local veh = getPedOccupiedVehicle ( getLocalPlayer() )
	if ( guiGetVisible ( myWindow ) == false ) then
	if ( veh ~= false ) then
		guiSetVisible ( myWindow, true )
		showCursor( true )
		InitUI ( )
		vParamsTable = getVehicleSirenParams( veh )
		if ( vParamsTable == false ) then
			vParamsTable = { SirenCount = 1, SirenType = 4, Flags = { Silent = true, DoLOSCheck = true, UseRandomiser = true, ["360"]=true } }
			triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		end
	end
	else
		guiSetVisible ( myWindow, false )
		showCursor ( false )
	end
end
addCommandHandler("sirens", sirenCmd)

bindKey (DEF_KeyBind, "down", function ( ) sirenCmd ( ) end)
guiSetVisible ( myWindow, false )

local vParamsTable = { SirenCount = 1, SirenType = 2, Flags = { Silent = false, DoLOSCheck = false, UseRandomiser = true, ["360"]=true } }
function applySirenTable ( veh, sirenTable, bSync )
	if ( bSync ) then
		triggerServerEvent( "sirens_sync", veh, sirenTable )
	else
		if ( DEF_AllowSync == true ) then
			for k,v in ipairs( sirenTable ) do
				if ( v.Red == 0 and v.Green == 0 and v.Blue == 0 ) then
					v.Red = 255
					v.Green = 255
					v.Blue = 255
				end
				setVehicleSirens ( veh, k, v.x, v.y, v.z, v.Red, v.Green, v.Blue, v.Alpha, v.Min_Alpha )
			end
		end
	end
end
function InitUI ( )
	local veh = getPedOccupiedVehicle ( getLocalPlayer() )
	local selectedItem = guiComboBoxGetSelected ( sirens ) + 1
	if ( veh ) then
		local sirensTable = getVehicleSirens(veh)
		guiScrollBarSetScrollPosition ( sirensX, 50 + ( sirensTable[selectedItem].x * 10 ) )
		guiScrollBarSetScrollPosition ( sirensY, 50 + ( sirensTable[selectedItem].y * 10 ) )
		guiScrollBarSetScrollPosition ( sirensZ, 50 + ( sirensTable[selectedItem].z * 10 ) )
		guiScrollBarSetScrollPosition ( sirensAlpha, 255 )
		guiScrollBarSetScrollPosition ( sirensMinAlpha, 255 )
		guiSetText ( posLabelX, "Position X: " .. string.format( "%.3f", sirensTable[selectedItem].x ) )
		guiSetText ( posLabelY, "Position Y: " .. string.format( "%.3f", sirensTable[selectedItem].y ) )
		guiSetText ( posLabelZ, "Position Z: " .. string.format( "%.3f", sirensTable[selectedItem].z ) )
		guiSetText ( alphaLabel, "Alpha: " .. sirensTable[selectedItem].Alpha )
		guiSetText ( minAlphaLabel, "Minimum Alpha: " .. sirensTable[selectedItem].Min_Alpha )
		guiSetText ( sirensBtnRGB, string.format ( "Colour: #%02X%02X%02X", sirensTable[selectedItem].Red, sirensTable[selectedItem].Green, sirensTable[selectedItem].Blue ) )
		guiCheckBoxSetSelected ( sirensChk360, vParamsTable.Flags["360"] )
		guiCheckBoxSetSelected ( sirensChkLOS, vParamsTable.Flags.DoLOSCheck )
		guiCheckBoxSetSelected ( sirensChkRand, vParamsTable.Flags.UseRandomiser )
		guiCheckBoxSetSelected ( sirensChkSilent, vParamsTable.Flags.Silent )
		guiComboBoxSetSelected ( numberOfSirens, vParamsTable.SirenCount - 1 )
		guiComboBoxSetSelected ( sirenType, vParamsTable.SirenType - 1 )
		triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		sirensTable[selectedItem].Alpha = 255
		sirensTable[selectedItem].Min_Alpha = 255
		applySirenTable(veh, sirensTable, false)
	end
end
InitUI ( )

function scrollFunc(scrolled)
	local veh = getPedOccupiedVehicle ( getLocalPlayer() )
	local selectedItem = guiComboBoxGetSelected ( sirens ) + 1
	if ( selectedItem ~= nil and selectedItem ~= false and selectedItem > 0 and veh ~= false ) then
		if ( scrolled == sirensX ) then
			local sirensTable = getVehicleSirens(veh)
			sirensTable[selectedItem].x = ( guiScrollBarGetScrollPosition ( scrolled ) / 10 ) - 5
			guiSetText( posLabelX, "Position X: " .. string.format( "%.3f", sirensTable[selectedItem].x ) )
			applySirenTable ( veh, sirensTable, false )
			return
		end
		if ( scrolled == sirensY ) then
			local sirensTable = getVehicleSirens(veh)
			sirensTable[selectedItem].y = ( guiScrollBarGetScrollPosition ( scrolled ) / 10 ) - 5
			guiSetText( posLabelY, "Position Y: " .. string.format( "%.3f", sirensTable[selectedItem].y ) )
			applySirenTable ( veh, sirensTable, false )
			return
		end
		if ( scrolled == sirensZ ) then
			local sirensTable = getVehicleSirens(veh)
			sirensTable[selectedItem].z = ( guiScrollBarGetScrollPosition ( scrolled ) / 10 ) - 5
			guiSetText( posLabelZ, "Position Z: " .. string.format( "%.3f", sirensTable[selectedItem].z ) )
			applySirenTable ( veh, sirensTable, false )
			return
		end
		if ( scrolled == sirensAlpha ) then
			local sirensTable = getVehicleSirens(veh)
			sirensTable[selectedItem].Alpha = math.ceil ( (guiScrollBarGetScrollPosition ( scrolled ) * 2.55 ) - 0.05 )
			guiSetText( alphaLabel, "Alpha: " .. sirensTable[selectedItem].Alpha )
			applySirenTable ( veh, sirensTable, false )
			return
		end
		if ( scrolled == sirensMinAlpha ) then
			local sirensTable = getVehicleSirens(veh)
			sirensTable[selectedItem].Min_Alpha = math.ceil ( ( guiScrollBarGetScrollPosition ( scrolled ) * 2.55 )  - 0.05 )
			guiSetText( minAlphaLabel, "Minimum Alpha: " .. sirensTable[selectedItem].Min_Alpha )
			applySirenTable ( veh, sirensTable, false )
			return
		end
	end
end
addEventHandler("onClientGUIScroll", root, scrollFunc)
local bSelecting = false
function btnFunc ( button, state )
	local veh = getPedOccupiedVehicle ( getLocalPlayer() )
	if ( veh ~= false ) then
		if ( source == sirensBtnRGB ) then
			if ( state == "up" ) then
				exports.cpicker:openPicker(source, "#FFAA00", "Pick a Beacon Colour")
			end
		end
		if ( source == sirensBtnGet ) then
			local selectedItem = guiComboBoxGetSelected ( sirens ) + 1
			local v = getVehicleSirens(veh)[selectedItem]
			outputChatBox("setVehicleSirens ( veh, " ..selectedItem .. ", " .. string.format( "%.3f", v.x ) .. ", " .. string.format( "%.3f", v.y ) .. ", " .. string.format( "%.3f", v.z ) .. ", " .. v.Red .. ", " .. v.Green .. ", " .. v.Blue .. ", " .. v.Alpha .. ", " .. v.Min_Alpha .. " )" )
			outputChatBox("addVehicleSirens ( veh, " .. vParamsTable.SirenCount .. ", " .. vParamsTable.SirenType .. ", " .. tostring ( vParamsTable.Flags["360"] ) .. ", " .. tostring ( vParamsTable.Flags.DoLOSCheck ) .. ", " .. tostring ( vParamsTable.Flags.UseRandomiser ) .. ", " .. tostring ( vParamsTable.Flags.Silent ) .. " ) "  )
		end
		if ( source == sirensBtn ) then
			local sirensTable = getVehicleSirens(veh)
			applySirenTable ( veh, sirensTable, true )
		end
		if ( source == sirensBtnClose ) then
			guiSetVisible ( myWindow, false )
			showCursor( false )
		end
		if ( source == sirensBtnSelect ) then
			guiSetVisible ( myWindow, false )
			showCursor( true )
			bSelecting = true
		end
		if ( source == sirensChk360 ) then
			local bValue = guiCheckBoxGetSelected ( source )
			vParamsTable.Flags["360"] = bValue
			triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		end
		if ( source == sirensChkLOS ) then
			local bValue = guiCheckBoxGetSelected ( source )
			vParamsTable.Flags.DoLOSCheck = bValue
			triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		end
		if ( source == sirensChkRand ) then
			local bValue = guiCheckBoxGetSelected ( source )
			vParamsTable.Flags.UseRandomiser = bValue
			triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		end
		if ( source == sirensChkSilent ) then
			local bValue = guiCheckBoxGetSelected ( source )
			vParamsTable.Flags.Silent = bValue
			triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		end
	end
end
addEventHandler("onClientGUIClick", root, btnFunc)

function PickedBeaconStuff ( element, hex, red, green, blue )
	local veh = getPedOccupiedVehicle ( getLocalPlayer() )
	local selectedItem = guiComboBoxGetSelected ( sirens ) + 1
	if ( selectedItem ~= nil and selectedItem ~= false and selectedItem > 0 and veh ~= false ) then
		local sirensTable = getVehicleSirens(veh)
		sirensTable[selectedItem].Red = red
		sirensTable[selectedItem].Green = green
		sirensTable[selectedItem].Blue = blue
		applySirenTable ( veh, sirensTable, false )
		guiSetText ( sirensBtnRGB, string.format ( "Colour: #%02X%02X%02X", sirensTable[selectedItem].Red, sirensTable[selectedItem].Green, sirensTable[selectedItem].Blue ) )
	end
end

addEventHandler("onColorPickerOK", root, PickedBeaconStuff)
function SelectedSiren ( )
	local veh = getPedOccupiedVehicle ( getLocalPlayer() )
	if ( veh ~= false ) then
		if ( source == sirens ) then
			InitUI()
		end
		if ( source == sirenType ) then
			local Value = guiComboBoxGetSelected ( source ) + 1
			vParamsTable.SirenType = Value
			triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		end
		if ( source == numberOfSirens ) then
			local Value = guiComboBoxGetSelected ( source ) + 1
			vParamsTable.SirenCount = Value
			triggerServerEvent( "sirens_sync2", veh, vParamsTable )
		end
	end
end
addEventHandler("onClientGUIComboBoxAccepted", root, SelectedSiren)

function matTransformVector( mat, vec )
	local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1] + mat[4][1]
	local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2] + mat[4][2]
	local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3] + mat[4][3]
	return {offX, offY, offZ}
end
function fixOutput ( out )
	if ( out < 0 ) then
		return out - 0.003
	else
		return out + 0.003
	end
end

function test ( button, state, l, f, x, y, z, element )
	local veh = getPedOccupiedVehicle ( getLocalPlayer() )
	if ( element == veh and veh ~= false and bSelecting == true ) then
		local selectedItem = guiComboBoxGetSelected ( sirens ) + 1
		local sirensTable = getVehicleSirens(veh)

		local x2,y2,z2 = getElementPosition( veh )
		local rx, ry, rz = getElementRotation ( veh )

		local vehmat = matrix(getElementMatrix ( veh ))
		vehmat[1][4] = 0
		vehmat[2][4] = 0
		vehmat[3][4] = 0
		vehmat[4][4] = 1
		local vehmatInv = matrix.invert( vehmat )
		local result = matTransformVector( vehmatInv, {x, y, z} )


		sirensTable[selectedItem].x = fixOutput ( result[1] )
		guiSetText( posLabelX, "Position X: " .. string.format( "%.3f", sirensTable[selectedItem].x ) )

		sirensTable[selectedItem].y = fixOutput ( result[2] )
		guiSetText( posLabelY, "Position Y: " .. string.format( "%.3f", sirensTable[selectedItem].y ) )

		sirensTable[selectedItem].z = fixOutput ( result[3] )
		guiSetText( posLabelY, "Position Y: " .. string.format( "%.3f", sirensTable[selectedItem].y ) )

		applySirenTable ( veh, sirensTable, false )

		bSelecting = false
		guiSetVisible ( myWindow, true )
		showCursor( true )
	end
end

addEventHandler("onClientClick", root, test)
