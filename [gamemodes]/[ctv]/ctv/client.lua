-- vehicle health bar added by arc_

local theVan
local screenWidth, screenHeight = guiGetScreenSize()

local healthbar = {}
healthbar.width = math.floor(0.5*screenWidth)
healthbar.height = math.floor(0.013*screenHeight)
healthbar.x = screenWidth/2 - math.floor(healthbar.width/2)
healthbar.y = math.floor(0.9*screenHeight)
healthbar.border = 2
healthbar.color = { 255, 255, 255, 0 }

addEventHandler('onClientResourceStart', getResourceRootElement(getThisResource()),
	function()
		setPlayerHudComponentVisible('area_name', false)
		triggerServerEvent('onLoadedAtClient', getLocalPlayer())
		setTimer(checkVehicleDrowned, 2000, 0)
	end
)

function checkVehicleDrowned()
	if not theVan or not isElement(theVan) then
		return
	end
	local x, y, z = getElementPosition(theVan)
	local waterZ = getWaterLevel(x, y, z)
	if waterZ and z < waterZ then
		triggerServerEvent('onVanDrown', theVan)
		theVan = false
	end
end

function getHealthBarColor()
	if not theVan or not isElement(theVan) then
		return 255, 255, 255, 0
	end
	local driver = getVehicleController(theVan)
	local r, g, b, a
	if driver and not isPedDead(driver) and getPlayerTeam(driver) then
		r, g, b = getTeamColor(getPlayerTeam(driver))
		a = 255
	else
		r, g, b, a = 240, 240, 240, 60
	end
	return r, g, b, a
end

addEvent('doSetVan', true)
addEventHandler('doSetVan', root,
	function()
		theVan = source
		healthbar.color = { getHealthBarColor() }
		healthbar.color[4] = 0
		adaptHealthBar()
	end
)

function interpolateColor(bar, val, info)
	for i=1,4 do
		bar.color[i] = info.startcolor[i] + (info.endcolor[i] - info.startcolor[i])*val
	end
end

function adaptHealthBar()
	if healthbar.anim then
		healthbar.anim:remove()
	end
	local newcolor = { getHealthBarColor() }
	healthbar.anim = Animation.createAndPlay(healthbar, { from = 0, to = 1, time = 500, fn = interpolateColor, startcolor = table.shallowcopy(healthbar.color), endcolor = newcolor }, function() healthbar.color = newcolor healthbar.anim = nil end)
end
addEvent('doAdaptHealthBar', true)
addEventHandler('doAdaptHealthBar', root, adaptHealthBar)

addEventHandler('onClientRender', root,
	function()
		if not theVan or not isElement(theVan) or healthbar.color[4] == 0 then
			return
		end
		local health = getElementHealth(theVan)
		local healthWidth = math.max(math.floor(healthbar.width*(health-250)/1750), 0)

		-- border
		local borderColor = tocolor(0, 0, 0, healthbar.color[4])
		dxDrawRectangle(healthbar.x - healthbar.border, healthbar.y - healthbar.border, healthbar.width + healthbar.border*2, healthbar.border, borderColor)
		dxDrawRectangle(healthbar.x - healthbar.border, healthbar.y, healthbar.border, healthbar.height, borderColor)
		dxDrawRectangle(healthbar.x + healthbar.width, healthbar.y, healthbar.border, healthbar.height, borderColor)
		dxDrawRectangle(healthbar.x - healthbar.border, healthbar.y + healthbar.height, healthbar.width + healthbar.border*2, healthbar.border, borderColor)
		-- health left
		dxDrawRectangle(healthbar.x, healthbar.y, healthWidth, healthbar.height, tocolor(math.floor(healthbar.color[1]*0.75), math.floor(healthbar.color[2]*0.75), math.floor(healthbar.color[3]*0.75), healthbar.color[4]))
		-- damage
		if healthWidth < healthbar.width then
			dxDrawRectangle(healthbar.x + healthWidth, healthbar.y, healthbar.width - healthWidth, healthbar.height, tocolor(math.floor(healthbar.color[1]*0.4), math.floor(healthbar.color[2]*0.4), math.floor(healthbar.color[3]*0.4), healthbar.color[4]))
		end
	end
)

function table.shallowcopy(t)
	local result = {}
	for k,v in pairs(t) do
		result[k] = v
	end
	return result
end
