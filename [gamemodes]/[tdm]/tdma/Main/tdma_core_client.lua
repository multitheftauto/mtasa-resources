local guiTextLabel = nil
local guiTextLabelTeamName = nil
local guiTextLabelText = nil

function showPlayerTheirTeam(player, text, r, g, b)
	if ( player == getLocalPlayer() ) then
		if ( guiTextLabel and isElement(guiTextLabel) and guiTextLabelTeamName and isElement(guiTextLabelTeamName) ) then
			guiSetText ( guiTextLabelTeamName, text )
			guiLabelSetColor ( guiTextLabelTeamName, r, g, b )
		else
			guiTextLabel = guiCreateLabel( 0.01, 0.20, 0.8203, 0.5, "Current Team: ", true )
			if ( guiTextLabel ) then
				local guiLength = guiLabelGetTextExtent ( guiTextLabel )
				local screenX, screenY = guiGetScreenSize()
				guiLength = tonumber(guiLength) / screenX
				local guiTextLabelTeamName = guiCreateLabel( tonumber(guiLength) + 0.01, 0.20, 1, 0.5, text, true )
				if ( guiTextLabelTeamName ) then
					guiLabelSetColor ( guiTextLabelTeamName, tonumber(r), tonumber(g), tonumber(b) )
				end
			end
		end
	end
end

function onClientPlayerSpawn()
	--outputChatBox ( "Ive Loaded, contacting server!" )
	triggerServerEvent ( "Event_clientScriptLoaded", getRootElement(), getLocalPlayer() )
end

addEvent ( "Event_showPlayerTheirTeam", true )
addEventHandler ( "Event_showPlayerTheirTeam", getRootElement(), showPlayerTheirTeam )
addEventHandler ( "onClientPlayerSpawn", getLocalPlayer(), onClientPlayerSpawn )
