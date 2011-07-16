

function createGui(options)
	
	if (logo == nil) then
		-- Create logo
		
		local screenWidth, screenHeight = guiGetScreenSize()
		local sizeX = screenWidth/1280
		local sizeY = screenHeight/1024
		local width = 420*sizeX
		local height = 300*sizeY
		outputConsole("Creating image: "..width.."x"..height)
		logo = guiCreateStaticImage ( screenWidth/2-width/2, screenHeight/2-height/1.5, width, height, "logo.png", false, nil )
	end
	
	if (options == nil) then return end
	local justCreated = false
	
	if (assaultGui == nil) then
		--outputDebugString("Creating/updating assault gui")
		-- Get GUI from helpmanager
		assaultGui = call(getResourceFromName("helpmanager"), "addHelpTab", getThisResource(), true)

		-- Create tabs
		assaultGuiTabPanel = guiCreateTabPanel( 0, 0.04, 1, 1, true, assaultGui )

		tabMap = guiCreateTab( "Map Information", assaultGuiTabPanel )
		tabHelp = guiCreateTab( "Help", assaultGuiTabPanel )
		
		local version = guiCreateLabel(0.72,0.048,0.4,0.1,"Assault v1.0 by driver2",true,assaultGui)
		guiSetAlpha(version,0.4)
		
		justCreated = true
	end
	
	if (assaultGui == nil) then
		--outputDebugString("test")
	end
	
	-- TAB: Map Information
	
	if (justCreated) then
		text = "This page displays information about the map and it's objectives. To get general help, click on 'Help'."
		guiCreateLabel(0.02,0.04,0.94,0.2,text,true,tabMap)
	end
	
	-- General Map Information
	if (justCreated) then 
		assaultGuiGrid2 = guiCreateGridList(0.02,0.1,0.96,0.3,true,tabMap)
		guiGridListAddColumn(assaultGuiGrid2,"Option",0.2)
		guiGridListAddColumn(assaultGuiGrid2,"Value",0.8)
	else
		guiGridListClear(assaultGuiGrid2)
	end
	guiGridListAddRow( assaultGuiGrid2 )
	guiGridListSetItemText( assaultGuiGrid2, 0, 1, "Map", false, false )
	guiGridListSetItemText( assaultGuiGrid2, 0, 2, options.name, false, false )
	guiGridListAddRow( assaultGuiGrid2 )
	guiGridListSetItemText( assaultGuiGrid2, 1, 1, "Timelimit", false, false )
	guiGridListSetItemText( assaultGuiGrid2, 1, 2, calcTime(options.timelimit), false, false )
	guiGridListAddRow( assaultGuiGrid2 )
	guiGridListSetItemText( assaultGuiGrid2, 2, 1, "Finish Type", false, false )
	guiGridListSetItemText( assaultGuiGrid2, 2, 2, options.finishType, false, false )
	guiGridListAddRow( assaultGuiGrid2 )
	guiGridListSetItemText( assaultGuiGrid2, 3, 1, "Author", false, false )
	guiGridListSetItemText( assaultGuiGrid2, 3, 2, options.author, false, false )
	guiGridListAddRow( assaultGuiGrid2 )
	guiGridListSetItemText( assaultGuiGrid2, 4, 1, "Description", false, false )
	guiGridListSetItemText( assaultGuiGrid2, 4, 2, options.description, false, false )
	
	--guiGridListAutoSizeColumn(assaultGuiGrid2,1)
	guiGridListAutoSizeColumn(assaultGuiGrid2,2)
	
	-- Objective Information
	local objectivesTable = {}
	if (justCreated) then
		guiCreateLabel(0.02,0.42,0.92,0.1,"These are the attackers objectives:",true,tabMap)
		assaultGuiGrid = guiCreateGridList(0.02,0.48,0.96,0.44,true,tabMap)
		guiGridListAddColumn(assaultGuiGrid,"Objective",0.2)
		guiGridListAddColumn(assaultGuiGrid,"Description",0.8)
	else
		guiGridListClear(assaultGuiGrid)
	end
	
	for k,v in ipairs(options.objective) do
		guiGridListAddRow( assaultGuiGrid )
		guiGridListSetItemText (assaultGuiGrid, k-1, 1, v.name, false, false)
		guiGridListSetItemText (assaultGuiGrid, k-1, 2, v.description, false, false)
	end
	--guiGridListAutoSizeColumn(assaultGuiGrid,1)
	guiGridListAutoSizeColumn(assaultGuiGrid,2)
	
	
	-- TAB: Help
	
	if (justCreated) then
		local text = "What to do:\n\n"
		text = text.."You need to reach objectives. These are usually checkpoints you need to enter, but it can also be "
		text = text.."something else. Click on 'Map Information' for details.\n\n"
		text = text.."When the attacking team reached the final objective, sides will be switched and the attacking team will "
		text = text.."defend, while the previously defending team will attack. The team that finishes faster wins the map. If "
		text = text.."neither team manages to finish within the timelimit, the map will end tied.\n\n"
		text = text.."The objectives are listed on the screen. Green color means they are next to be done by the attackers, "
		text = text.."red color indicates they are already done and white color means they have yet to be done, but others "
		text = text.."have to be done first. "
		text = text.."At the bottom of the screen, the current tasks for your team are displayed. You can cycle through them "
		text = text.."using F4, if necessary."
		text = text.."\n\n\n"
		
		text = text.."General Information:\n\n"
		text = text.."This gamemode is roughly based on UnrealTournament's Assault."
		
		local helpLabel = guiCreateLabel(0.02,0.04,0.94,0.92,text,true,tabHelp)
		guiLabelSetHorizontalAlign ( helpLabel, "left", true )
	end
	
	
	
end

function nextObjectivesText( objectives )

	currentObjectives = objectives
	
	--outputConsole(tostring(getElementData("assaultAttackingTeam")))
	--outputConsole("client next objectives "..tostring(getElementData(getLocalPlayer(),"assaultAttacker")))
	
	if (nextObjectivesLabel == nil) then
		--outputConsole("Creating next objectives text label")
		local screenWidth, screenHeight = guiGetScreenSize()
		
		-- background
		local background = guiCreateStaticImage ( 0, screenHeight - 22, screenWidth, 22, "blackpixel.png", false, nil )
		guiSetAlpha(background,0.5)
		
		nextObjectivesLabel = guiCreateLabel(0.1,screenHeight,screenWidth,10,"" ,false)
		local fontHeight = guiLabelGetFontHeight(nextObjectivesLabel)
		guiSetSize(nextObjectivesLabel,screenWidth,fontHeight,false)
		guiSetPosition(nextObjectivesLabel,10,screenHeight - fontHeight - 4,false)
		guiLabelSetColor(nextObjectivesLabel,255,255,255)
		--outputChatBox(tostring(guiBringToFront(nextObjectivesLabel)))
		
	end
	
	currentObjectiveShowing = 1
	currentObjectiveCount = #currentObjectives
	--outputChatBox(tostring(currentObjectiveCount))
	if (currentObjectiveCount > 0) then
		setCurrentObjectiveText(1)
		--guiSetText(nextObjectivesLabel,"Next objectives [1/"..currentObjectiveCount.."]: "..currentObjectives[1].text)
	end
end
function switchObjectivesText()
	if (currentObjectiveShowing == currentObjectiveCount) then
		currentObjectiveShowing = 1
	else
		currentObjectiveShowing = currentObjectiveShowing + 1
	end
	setCurrentObjectiveText(currentObjectiveShowing)
end

addCommandHandler( "Switch objective text", switchObjectivesText )
bindKey( "F4", "down", "Switch objective text" )

function setCurrentObjectiveText(number)
	local team = getPlayerTeam(getLocalPlayer())
	--outputChatBox("moo?"..tostring(team))
	if (team == false) then
		guiSetText(nextObjectivesLabel,"Choose a team..")
	else
		local description
		if (getPlayerTeam(getLocalPlayer()) == attacker) then
			description = currentObjectives[number].attackerText
		else
			description = currentObjectives[number].defenderText
		end
		local text
		if (currentObjectiveCount == 1) then
			text = "Next objective: "..description
		else
			text = "Next objectives ["..number.."/"..currentObjectiveCount.."]: "..description.." [F4 for next]"
		end
		guiSetText(nextObjectivesLabel,text)
	end
end

addEventHandler("onClientPlayerSpawn", getLocalPlayer(),
	function()
		setCurrentObjectiveText(currentObjectiveShowing)
	end
)

-- stolen from mission_timer.lua
function calcTime ( timeLeft )
	local calcString = ""
	local timeHours = 0
	local timeMins = 0
	local timeSecs = 0
	
	timeLeft = tonumber(timeLeft)
	timeSecs = math.mod(timeLeft, 60)
	timeMins = math.mod((timeLeft / 60), 60)
	timeHours = (timeLeft / 3600)
	
	if ( timeHours >= 1 ) then
		calcString = formatStr(tostring(timeHours)) .. ":"
	end
	calcString = calcString .. formatStr(string.format("%.0d", tostring(timeMins))) .. ":" .. formatStr(tostring(timeSecs))
	
	return calcString
end

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

function showProgress(objectiveId, bool, progress, total, stayText)
	if (progressBar == nil) then progressBar = {} end
	if (progressBarText == nil) then progressBarText = {} end

	if (progressBar[objectiveId] == nil and bool == true) then
		local x, y = guiGetScreenSize()
		x = ( x / 2 ) - 100
		y = y * 0.6
		progressBar[objectiveId] = guiCreateProgressBar ( x, y, 200, 20, false )
		progressBarText[objectiveId] = guiCreateLabel ( x, y - 30, 100, 25, stayText, false )
		guiSetSize ( progressBarText[objectiveId], guiLabelGetTextExtent ( progressBarText[objectiveId] ), guiLabelGetFontHeight ( progressBarText[objectiveId] ), false )
		guiLabelSetColor ( progressBarText[objectiveId], 255, 255, 255, 255 )
	end
	
	if (progressBar[objectiveId] == nil) then return end
	guiSetVisible(progressBar[objectiveId],bool)
	guiSetVisible(progressBarText[objectiveId],bool)
	if (progress ~= nil and total ~= nil) then
		local p = math.ceil(progress / total * 100)
		guiProgressBarSetProgress(progressBar[objectiveId],p)
		guiSetText ( progressBarText[objectiveId], ("%s %d%%"):format(stayText, p) )
		guiSetSize ( progressBarText[objectiveId], guiLabelGetTextExtent ( progressBarText[objectiveId] ), guiLabelGetFontHeight ( progressBarText[objectiveId] ), false )
	end
end

function toggleLogo(bool)
	guiSetVisible(logo,bool)
	--outputDebugString("Set logo visible: "..tostring(bool))
end



addEventHandler("onClientResourceStart", getRootElement(getThisResource()), 
	function()
		triggerServerEvent("assaultClientScriptLoaded", getLocalPlayer())
	end
)

addEvent("assaultNextRound", true)
addEventHandler("assaultNextRound", getRootElement(),
	function( newAttacker )
		attacker = newAttacker
		--outputConsole("New round, now attacking: "..getTeamName(attacker))
	end
)

addEvent("assaultNextObjectivesText", true)
addEventHandler("assaultNextObjectivesText", getRootElement(), nextObjectivesText)

addEvent("assaultToggleLogo", true)
addEventHandler("assaultToggleLogo", getRootElement(), toggleLogo)

addEvent( "assaultCreateGui", true )
addEventHandler("assaultCreateGui", getRootElement(), createGui)

addEvent( "assaultShowProgress", true)
addEventHandler("assaultShowProgress", getRootElement(), showProgress)

fadeCamera(true)
