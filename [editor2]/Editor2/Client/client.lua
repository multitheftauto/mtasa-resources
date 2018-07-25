fadeCamera(true)
setPlayerHudComponentVisible('all',false)
setCameraTarget(localPlayer)

-----------------------
--// Dynamic Binds \\--
--// These are buttons that you can push and hold (Constantly execute while you hold)
functions['Camera Movement'] = function ()
	if EditSelected then return end
end
table.insert(binds.dynamic,{'Camera Movement',{'w','a','s','d'},'FreeCam'}) -- Name first, then binds (For multiple binds)

countb = 0

functions['Element Movement'] = function (key,keyID)
	if not EditSelected then
		local divison = getKeyState('lalt') and 0.5 or (getKeyState('lshift') and 2 or 1)
		countb = countb + 1
		if countb >= 20 or (not global.snap) then
			countb = 0
			if keyID == 1 then
				local x,y,z = getXYZOrdering(0,-(tonumber(global.snap) or (CameraSpeed/50))*divison,0)
				functions.tranformElements(x,y,z)
			elseif keyID == 2 then
				local x,y,z = getXYZOrdering(-(tonumber(global.snap) or (CameraSpeed/50))*divison,0,0)
				functions.tranformElements(x,y,z,1)
			elseif keyID == 3 then
				local x,y,z = getXYZOrdering(0,(tonumber(global.snap) or (CameraSpeed/50))*divison,0)
				functions.tranformElements(x,y,z)
			else
				local x,y,z = getXYZOrdering((tonumber(global.snap) or (CameraSpeed/50))*divison,0,0)
				functions.tranformElements(x,y,z,-1)
			end
		end
	end
end

table.insert(binds.dynamic,{'Element Movement',{'arrow_u','arrow_l','arrow_d','arrow_r'},'Selected'}) -- Name first, then binds (For multiple binds) --'=','-'


functions['Element Height'] = function (key,keyID)
	if not EditSelected then
		local divison = getKeyState('lalt') and 0.5 or (getKeyState('lshift') and 2 or 1)
		countb = countb + 1
		if countb >= 20 or (not global.snap) then
			countb = 0
			if keyID == 1 then
				functions.tranformElements(0,0,(tonumber(global.snap) or (CameraSpeed/50))*divison)
			elseif keyID == 2 then
				functions.tranformElements(0,0,-(tonumber(global.snap) or (CameraSpeed/50))*divison)
			end
		end
	end
end


function functions.tranformElements(x,y,z,Alternative)
	if global['Mode'] == 'Movement' then
		setElementPositions(x,y,z)
	elseif global['Mode'] == 'Rotation' then
		local m = global.snap and 1 or 100
		setElementRotations(x*m,y*m,z*m)
	end	
end

table.insert(binds.dynamic,{'Element Height',{'num_add','num_sub'},'Selected'}) -- Name first, then binds (For multiple binds)


functions['Speed Modifiers'] = function ()--// Need to be able to send lshift and lalt alt so that other components can read this.
	if EditSelected then return end
end
table.insert(binds.dynamic,{'Speed Modifiers',{'lshift','lalt'},'Mix'}) -- Name first, then binds (For multiple binds)

functions['Replace Elements'] = function () --// Only show this when an element is selected and you are 
end
table.insert(binds.dynamic,{'Replace Element(s)',{'mouse1','rctrl'},'Selected'})

functions['Select By Bounding'] = function ()
end
table.insert(binds.dynamic,{'Select By Bounding',{'lctrl'}}) --// Need to send out ralt

--\\ Dynamic Binds //--
-----------------------

----------------------
--// Static Binds \\--
--// These are buttons that you push once and it executes (Holding does nothing)
functions['Menu Controls'] = function (key)
	if EditSelected then return end
	if global.OptionHover then
		local a,b = unpack(global.OptionHover)
		if binds.layout['Menu Controls'][1] == key then
			functions['Option'](1,a,b)
		else
			functions['Option'](-1,a,b)
		end
	end
end

table.insert(binds.static,{'Menu Controls',{'arrow_l','arrow_r'}})


functions['Select Element(s)'] = function ()
	if EditSelected then return end
end
table.insert(binds.static,{'Select Element(s)',{'mouse1'}}) -- Name first, then binds (For multiple binds)


functions['Nothing'] = function ()
	if EditSelected then return end
end
table.insert(binds.static,{'Nothing',{'mouse2'}})

functions['Show Cusor'] = function ()
	if EditSelected then return end
	showCursor(not isCursorShowing())
end
table.insert(binds.static,{'Show Cusor',{'Q'}}) 


functions['Toggle Freecam'] = function ()
	if EditSelected then return end
	functions.Camera()
end
table.insert(binds.static,{'Toggle Freecam',{'E'}}) -- Name first, then binds (For multiple binds)


functions['Change Movement Speed'] = function ()
	if EditSelected then return end
	global.count['Speed'] = global.count['Speed'] + 1
	if global.count['Speed'] > global.speedC then
		global.count['Speed'] = 1
	end

functions['Speed'](nil,global.count['Speed'])
end
table.insert(binds.static,{'Change Movement Speed',{'F'},'FreeCam'})

functions['Change Magnet Selection'] = function ()
	if EditSelected then return end
	global.count['Magnets'] = (global.count['Magnets'] or 0) + 1
	if global.count['Magnets'] > 4 then
		global.count['Magnets'] = 1
	end

functions['Magnets'](nil,global.count['Magnets'])
end
table.insert(binds.static,{'Change Magnet Selection',{'M'},'FreeMove'})

functions['Toggle Move'] = function ()
	if isFreecamEnabled() and not isCursorShowing() then
		freeMove = not freeMove
		if not freemove then
			if isThereSelected() and global.Mangets and mClose.connection then --// Only do this if these all are true.
				functions.magnetMovement()
				mClose.connection = nil
			end
		end
	end
end
table.insert(binds.static,{'Toggle Move',{'space'}})


for i,v in pairs(binds.static) do
	for iA,vA in pairs(v[2]) do
		bindKey ( vA, "down", functions[v[1]] )
	end
	
	binds.layout[v[1]] = v[2]
end



--\\ Static Binds //--
----------------------


-------------------
--// Binds Check \\--

function binds.check.FreeCam ()
	return isFreecamEnabled()
end

function binds.check.Mix()
	return isFreecamEnabled() or isThereSelected()
end

function binds.check.Selected()
	return (isThereSelected() and isFreecamEnabled())
end


function binds.check.FreeMove()
	return (isThereSelected() and freeMove)
end


--\\ Binds Check //--
---------------------

---------------------
---// Left menu \\---

buttons.left = {{'Save'},{'Controls','Camera','Preview'},selected = {},menu = {}} -- Left menu, first two tables are the left / right part of the top menu.
-- button types, Option and Side Option (More can be added, however requires modifications to GUI)


functions['Controls'] = function() -- Controls
	global.Controls = not global.Controls
end


functions['Camera'] = function () -- Camera
	global.Camera = not global.Camera

	callS('removePedFromVehicleS')
	
	if global.Camera then
		local x,y,z = getElementPosition(localPlayer)
		setFreecamEnabled(x,y,z)
		
		setElementPosition(localPlayer,0,0,1000)
		setElementFrozen(localPlayer,true)	 
		
	timR = setTimer ( function()
		setElementPosition(localPlayer,0,0,1000)
		setElementFrozen(localPlayer,true)	 
	end, 500, 1 )
 
	
	else
		if isTimer(timR) then
			killTimer(timR)
		end
		
		local x,y,z = getCameraMatrix()
		setFreecamDisabled()

			setElementPosition(localPlayer,x,y,z)

		setCameraTarget(localPlayer)
		setElementFrozen(localPlayer,false)
	end
end


functions['Preview'] = function() -- Preview (WIP)

end


table.insert(buttons.left.menu,{'Speed','Option',{'ZFixer','Slow as hell','Slowest','Slower','Slow','Normal','Fast','Faster','Faster Still','Fastest'}}) -- Speed
functions['Speed'] = function (input,index)
	CameraSpeed = math.max((2^(index-1))/200,0.001)
end
functions['Speed'](nil,6)
global.count['Speed'] = 6
global.speedC = #buttons.left.menu[#buttons.left.menu][3]


table.insert(buttons.left.menu,{'Boundries','Option',{'None','Selected','On Screen'}}) 
functions['Boundries'] = function (input,index) -- Boundries
	global['Boundries'] = input
end
global.count['Boundries'] = 2
global['Boundries'] = 'Selected'


table.insert(buttons.left.menu,'blank') -- Short Blank


table.insert(buttons.left.menu,{'Mode','SideOption',{'Movement','Rotation','Scale'}})
functions['Mode'] = function (input,index) -- Mode

	if input == 'Scale' then
		global['Move Type'] = 'Local'
		global.count['Move Type'] = 1
	elseif (input == 'Rotation') and (global['Move Type'] == 'Screen')then
		global['Move Type'] = 'World'
		global.count['Move Type'] = 1
	end
	
	prepMoveTypes(input)
	
	if global['Mode'] == input then
		global['Mode'] = nil
	else
		global['Mode'] = input
	end
end
global['Mode'] = 'Movement' 


function prepMoveTypes(input)
	if input == 'Movement' then
		mTable[3] = {'World','Local','Screen'}
	elseif input == 'Rotation' then
		mTable[3] = {'World','Local'}
	else
		mTable[3] = {'Local'}
	end
end

table.insert(buttons.left.menu,{'Move Type','Option',{'World','Local','Screen'}})
functions['Move Type'] = function (input,index)
	global['Move Type'] = input
end
global['Move Type'] = 'World'
mTable = buttons.left.menu[#buttons.left.menu]


table.insert(buttons.left.menu,{'Magnets','Option',{'Off','Low','Medium','High'}}) -- Magnet Strength
functions['Magnets'] = function (input,index)
	if index == 1 then
		global.Mangets = nil
	else
		global.Mangets = index
	end
end


table.insert(buttons.left.menu,{'Snap','Option',{'off',1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180}}) -- What mode
functions['Snap'] = function (input,index)
	global.snap = tonumber(input)
end


table.insert(buttons.left.menu,{'Depth','Option',{10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200}}) -- Might move this to a range maybe?
functions['Depth'] = function (input,index)
	selectionDepth = index*10 --// This is the depth of the tool. If set to 10 it'll only scan 10 units in front of you for elements.
end
functions['Depth'](nil,5)
global.count['Depth'] = 5 

--\\ Left menu //--
-------------------

---------------------
-----// Misc \\------




addEventHandler( "onClientResourceStop", resourceRoot,
function (	)
	if global.Camera then
		functions.Camera()
	end
end
)

function functions.DrawGimbal()
	if isThereSelected() then
		local center = xSize/2
		local cposition = center-((100*s)/2)
		local lposition = cposition-(105*s)
		local rposition = cposition+(105*s)
		
		local yposition = ySize-(82*s)
		dxDrawText ( 'Position',lposition-(60*s), yposition, lposition, yposition+(30*s), tocolor ( 255, 255, 255, 150	), 1.02, "arial",'center','center'	 )
		X,Y,Z = getSelectedElementsCenterI()
		dxDrawEditBox(lposition,yposition, 100*s, 30*s,1.3*s,'arial',tocolor(255, 100, 100, 255),'x',math.floor(X*100)/100,true,tocolor(0, 0, 0, 200),{255, 100, 100},true) 
		dxDrawEditBox(cposition,yposition, 100*s, 30*s,1.3*s,'arial',tocolor(100, 255, 100, 150),'y',math.floor(Y*100)/100,true,tocolor(0, 0, 0, 200),{100, 255, 100},true)	
		dxDrawEditBox(rposition,yposition, 100*s, 30*s,1.3*s,'arial',tocolor(100, 100, 255, 150),'z',math.floor(Z*100)/100,true,tocolor(0, 0, 0, 200),{100, 100, 255},true) ---// Possibly figure out how to floor to a spefic value and replace.
		Xr,Yr,Zr = getSelectedElementsRotations()
		local yposition = ySize-(50*s)
		dxDrawText ( 'Rotation',lposition-(60*s), yposition, lposition, yposition+(30*s), tocolor ( 255, 255, 255, 150 ), 1.02, "arial",'center','center'	)
		
		
		dxDrawEditBox(lposition,yposition, 100*s, 30*s,1.3*s,'arial',tocolor(255, 100, 100, 255),'xr',math.floor(Xr*100)/100,true,tocolor(0, 0, 0, 200),{255, 100, 100},true) 
		dxDrawEditBox(cposition,yposition, 100*s, 30*s,1.3*s,'arial',tocolor(100, 255, 100, 150),'yr',math.floor(Yr*100)/100,true,tocolor(0, 0, 0, 200),{100, 255, 100},true)	
		dxDrawEditBox(rposition,yposition, 100*s, 30*s,1.3*s,'arial',tocolor(100, 100, 255, 150),'zr',math.floor(Zr*100)/100,true,tocolor(0, 0, 0, 200),{100, 100, 255},true) 
		
		if freeMove then
			dxDrawText ( 'Free Move Enabled',lposition, yposition-(60*s), rposition+(100*s), yposition-(30*s), tocolor ( 255, 0, 0, 150	), 1.02, "arial",'center','center'	 )
		end
	end
	
		
		
	if global['Mode'] then
		if isThereSelected() then
			if global['Mode'] == 'Movement' then
					local x,y,z = getSelectedElementsCenter()
					
					sL = {x,y,z}
				
				
				local xA,yA,zA = functions['getPosition'](10,0,0)
				if lHover == 'x' then
					dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(255,0,0,255), 10,true)
				else
					dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(255,0,0,255), 5,true)
				end
				
				local xA,yA,zA = functions['getPosition'](0,10,0)
				if lHover == 'y' then
					dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,255,0,255), 10,true)
				else
					dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,255,0,255), 5,true)
				end
				
				local xA,yA,zA = functions['getPosition'](0,0,10)
				if lHover == 'z' then
					dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,0,255,255), 10,true)
				else
					dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,0,255,255), 5,true)
				end
					
				elseif global['Mode'] == 'Rotation' then
					local x,y,z = getSelectedElementsCenter()
					local cX,xY,cZ,cX1,xY1,cZ1 = getCameraMatrix()

					
					if isCursorShowing() then
						setElementPosition(circles[1],x,y,z)
						setElementPosition(circles[2],x,y,z)
						setElementPosition(circles[3],x,y,z)
					else
						functions.resetCircles()
					end
					
					local xA,yA,zA = functions['getPosition'](8,0,0)
					local xB,yB,zB = functions['getPosition'](-8,0,0)
					local xC,yC,zC = functions['getPosition'](0,0,100)
					local xD,yD,zD = functions['getPosition'](0,0,-100)
					local xr,yr,zr = findRotation3D(x,y,z,xC,yC,zC) 

					setElementRotation(circles[3],xr-90,yr,zr)

					if lHover == 'zr' then
						dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA, functions.prepImage('CircleSelected',true), 16,tocolor(0,0,255,255),false,xC,yC,zC)
					else
						dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA, functions.prepImage('circle',true), 16,tocolor(0,0,255,255),false,xC,yC,zC)
					end
					
					local disZ = (getDistanceBetweenPointAndSegment3D(cX,xY,cZ, xC,yC,zC,xD,yD,zD) + getDistanceBetweenPointAndSegment3D(cX1,xY1,cZ1, xC,yC,zC,xD,yD,zD))/2

					local xC,yC,zC = functions['getPosition'](0,100,0)
					local xD,yD,zD = functions['getPosition'](0,-100,0)
					local xr,yr,zr = findRotation3D(x,y,z,xC,yC,zC) 
					setElementRotation(circles[2],xr-90,yr,zr)
					
					
					if lHover == 'yr' then
						dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA, functions.prepImage('CircleSelected',true), 16,tocolor(0,255,0,255),false,xC,yC,zC)
					else
						dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA, functions.prepImage('circle',true), 16,tocolor(0,255,0,255),false,xC,yC,zC)
					end
					
					local disY = (getDistanceBetweenPointAndSegment3D(cX,xY,cZ, xC,yC,zC,xD,yD,zD) + getDistanceBetweenPointAndSegment3D(cX1,xY1,cZ1, xC,yC,zC,xD,yD,zD))/2
					
					local xA,yA,zA = functions['getPosition'](0,8,0)
					local xB,yB,zB = functions['getPosition'](0,-8,0)
					local xC,yC,zC = functions['getPosition'](100,0,0)
					local xD,yD,zD = functions['getPosition'](-100,0,0)
					local xr,yr,zr = findRotation3D(x,y,z,xC,yC,zC) 
					setElementRotation(circles[1],xr-90,yr,zr)
 
					if lHover == 'xr' then
						dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA, functions.prepImage('CircleSelected',true), 16,tocolor(255,0,0,255),false,xC,yC,zC)
					else
						dxDrawMaterialLine3D(xB,yB,zB,xA,yA,zA, functions.prepImage('circle',true), 16,tocolor(255,0,0,255),false,xC,yC,zC)
					end
					
					local disX = (getDistanceBetweenPointAndSegment3D(cX,xY,cZ, xC,yC,zC,xD,yD,zD) + getDistanceBetweenPointAndSegment3D(cX1,xY1,cZ1, xC,yC,zC,xD,yD,zD))/2
					
					local minDis = math.min(disX,disY,disZ) 
					
					if minDis == disX then
						lRotationalAxis = 'X'
					elseif minDis == disY then
						lRotationalAxis = 'Y'
					else 
						lRotationalAxis = 'Z'
					end
					
				else
					local x,y,z = getSelectedElementsCenter()
					local xA,yA,zA = functions['getPosition'](10,0,0)
					if lHover == 'sx' then
						dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(255,0,0,255), 10,true)
					else
						dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(255,0,0,255), 5,true)
					end
					
					local xA,yA,zA = functions['getPosition'](0,10,0)
					if lHover == 'sy' then
						dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,255,0,255), 10,true)
					else
						dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,255,0,255), 5,true)
					end
					
					local xA,yA,zA = functions['getPosition'](0,0,10)
					if lHover == 'sz' then
						dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,0,255,255), 10,true)
					else
						dxDrawLine3D (x,y,z,xA,yA,zA,tocolor(0,0,255,255), 5,true)
					end
				end
			if not ignoreGimbal then
				functions.isOnMovementGamble()
				else
				lHover = nil
			end
		end
	end
end


function functions.getCircleSide (input)
	local xa,ya = getCursorPosition()
	local xa,ya = xa*xSize,ya*ySize
	local xb,yb,zb = getCameraMatrix()
	local xc,yc,zc = getElementPosition(circles[cSides[input]])
	local x,y,z = getWorldFromScreenPosition (xa,ya, getDistanceBetweenPoints3D(xb,yb,zb,xc,yc,zc ))
	local matrix = circles[cSides[input]].matrix
	local Left = matrix:transformPosition(Vector3(0,10,0))
	local Right = matrix:transformPosition(Vector3(0,-10,0))
	
	local L = {Left.x,Left.y,Left.z}
	local left = getDistanceBetweenPoints3D(L[1],L[2],L[3],x,y,z)
	local R = {Right.x,Right.y,Right.z}
	local right = getDistanceBetweenPoints3D(R[1],R[2],R[3],x,y,z)
	if (left > right) then
		reverseD = -1
	else
		reverseD = 1
	end
	return reverseD
end


function functions.isOnMovementGamble()
	if not isCursorShowing() then
		functions.resetCircles()
	end
	
	if global['Mode'] == 'Movement' then
		if sL and sL[1] and isCursorShowing() and not getKeyState('mouse1') then
			
			local cx,cy = getCursorPosition()
			local cx,cy = cx*xSize,cy*ySize
				
			local x,y,z = getSelectedElementsCenter()
			
			local xA,yA,zA = functions['getPosition'](10,0,0)
			local xX,xY = getScreenFromWorldPosition(xA,yA,zA,1000)
			
			local xA,yA,zA = functions['getPosition'](0,10,0)
			local yX,yY = getScreenFromWorldPosition(xA,yA,zA,1000)
			
			local xA,yA,zA = functions['getPosition'](0,0,10)
			local zX,zY = getScreenFromWorldPosition(xA,yA,zA,1000)
				
			local x,y = getScreenFromWorldPosition(x,y,z,1000)
			
			if xX then
				if (getDistanceBetweenPointAndSegment2D(cx, cy,x, y, xX,xY) or 6) < 5 then
					lHover = 'x'
					return
				end
			end
			if yX then
				if (getDistanceBetweenPointAndSegment2D(cx, cy,x, y, yX,yY) or 6) < 5 then
					lHover = 'y'
					return
				end
			end
			if yX then
				if (getDistanceBetweenPointAndSegment2D(cx, cy,x, y, zX,zY) or 6) < 5 then
					lHover = 'z'
					return
				end
			end
				lHover = nil
		end
	elseif global['Mode'] == 'Rotation' then
		if isCursorShowing() and (not getKeyState('mouse1')) then
			local xa,ya,za = getSelectedElementsCenter()
			local hit,x,y,z = isCursorOnWorldElement(circles[1])
			if hit then
				functions['getCircleSide']('xr')
	
				lHover = 'xr'
				return
			end
			
			local hit,x,y,z = isCursorOnWorldElement(circles[2])
			
			if hit then
				functions['getCircleSide']('yr')
				lHover = 'yr'
				return
			end
			
			local hit,x,y,z = isCursorOnWorldElement(circles[3])
			
			if hit then
				functions['getCircleSide']('zr')
				lHover = 'zr'
				return
			end
			reverseD = nil
			lHover = nil
		end
	else
		if isCursorShowing() and not getKeyState('mouse1') then
			
			local cx,cy = getCursorPosition()
			local cx,cy = cx*xSize,cy*ySize
				
			local x,y,z = getSelectedElementsCenter()
			
			local xA,yA,zA = functions['getPosition'](10,0,0)
			local xX,xY = getScreenFromWorldPosition(xA,yA,zA,1000)
			
			local xA,yA,zA = functions['getPosition'](0,10,0)
			local yX,yY = getScreenFromWorldPosition(xA,yA,zA,1000)
			
			local xA,yA,zA = functions['getPosition'](0,0,10)
			local zX,zY = getScreenFromWorldPosition(xA,yA,zA,1000)
				
			local x,y = getScreenFromWorldPosition(x,y,z,1000)
			
			if xX then
				if (getDistanceBetweenPointAndSegment2D(cx, cy,x, y, xX,xY) or 6) < 5 then
					lHover = 'sx'
					return
				end
			end
			if yX then
				if (getDistanceBetweenPointAndSegment2D(cx, cy,x, y, yX,yY) or 6) < 5 then
					lHover = 'sy'
					return
				end
			end
			if yX then
				if (getDistanceBetweenPointAndSegment2D(cx, cy,x, y, zX,zY) or 6) < 5 then
					lHover = 'sz'
					return
				end
			end
			lHover = nil
		end
	end
	if not getKeyState('mouse1') then
		reverseD = nil
		lHover = nil
	end
end


function functions.refreshMovements (Xa,Ya,Za,Xra,Yra,Zra) -- Can technically use function functions.refreshMovements() however we wanna retain some constancy.
	X,Y,Z = getSelectedElementsCenterI()
	Xr,Yr,Zr = getSelectedElementsRotations() --// Collio
	if X and Y and Z and Xr and Yr and Zr then
		refreshString((math.floor((Xa or X)*100)/100),'x',true)
		refreshString((math.floor((Ya or Y)*100)/100),'y',true)
		refreshString((math.floor((Za or Z)*100)/100),'z',true)
		refreshString((math.floor((Xra or Xr)*100)/100),'xr',true)
		refreshString((math.floor((Yra or Yr)*100)/100),'yr',true)
		refreshString((math.floor((Zra or Zr)*100)/100),'zr',true)
	end
end


toggle = false

function functions.isCursorOnElement( posX, posY, width, height,inputA,inputB,inputC,inputD,inputE ) -- Gonna change this later to simplify it.
	if isCursorShowing( ) then
		if global.scrollT	then return false end
		local mouseX, mouseY = getCursorPosition( )
		local clientW, clientH = guiGetScreenSize( )
		local mouseX, mouseY = mouseX * clientW, mouseY * clientH
		if ( mouseX > posX and mouseX < ( posX + width ) and mouseY > posY and mouseY < ( posY + height ) ) then
			if inputA then
					ignoreGimbal = not (lMovement) -- Pretty much adds priority to the menu
				if lHover then return false end 
			
				if inputA == 'Option' then
					Option = math.max(Option,1)
				end	
						
					if getKeyState('mouse1') then
						if not toggle then
							if functions[inputA] then
								functions[inputA](inputB,inputC,inputD,inputE) -- When you click a 'Button' then it'll trigger this.
							end
						end
					end
				toggle = getKeyState('mouse1')
			end
			return true
		end
	end
end

holdname = false -- Don't question it.

function functions.isCursorOnElementAlt( posX, posY, width, height,optionA,optionB,optionC,optionD )
	if not getKeyState('mouse1') then
		return functions[optionA]()
	end
	if isCursorShowing( ) then
		local mouseX, mouseY = getCursorPosition( )
		local clientW, clientH = guiGetScreenSize( )
		local mouseX, mouseY = mouseX * clientW, mouseY * clientH
		if ( mouseX > posX and mouseX < ( posX + width ) and mouseY > posY and mouseY < ( posY + height ) ) then
			if getKeyState('mouse1') then
				return functions[optionA](optionB,optionC,optionD)
			else
				return functions[optionA]()
			end
			return true
		end
	end
end


function functions.scroll (name)
	global.scrollT = name
	return true
end

oldx = 0
oldy = 0

countc = 20

function functions.onCursorMove ( _, _, x, y )


	if (lHoverO == lHover) and ((global['Move Type'] == 'Local') or (isThereSelected(true) or 0) > 1) then
		if (lHover == 'x') or (lHover == 'y') or (lHover == 'z') then
			functions.refreshMovements(GXa,GYa,GZa)
		else
			functions.refreshMovements(nil,nil,nil,GXra,GYra,GZra)
		end
	else
		GXa,GYa,GZa,GXra,GYra,GZra = 0,0,0,0,0,0
		functions.refreshMovements()
	end
	lHoverO = lHover
	
	
	if lHover then
		if x > (xSize-5) then
			oldx = 10
			oldy = y
			setCursorPosition ( oldx, oldy )
			return
		elseif y > (ySize-5) then
			oldx = x
			oldy = 10
			setCursorPosition ( oldx, oldy )
			return
		elseif x < 5 then
			oldx = xSize-10
			oldy = y
			setCursorPosition ( oldx, oldy )
			return
		elseif y < 5 then
			oldx = x
			oldy = ySize-10
			setCursorPosition ( oldx, oldy )
			return
		end
	end
			
		local movex = x-oldx
		local movey = y-oldy

		local oX,oY,oZ = getWorldFromScreenPosition (oldx,oldy,20)
		local nX,nY,nZ = getWorldFromScreenPosition (x,y,20)
		
		local fix = ((nX+nY+nZ)-(oX+oY+oZ))
		
		
		local multiplier = getKeyState('lshift') and 2 or (getKeyState('lalt') and 0.1 or 1)

		
		local distance = getDistanceBetweenPoints3D(oX,oY,oZ,nX,nY,nZ)*multiplier
		
		oldy = y
		oldx = x
		
	if global.scrollT then
		global[global.scrollT] = global[global.scrollT] + movey
	end
	
	countc = countc + 1
	if countc == math.max((global.snap or 0)/2,20) or (not global.snap) then
		countc = 0
		
		local distance = ((global.snap or distance)*(reverseD or 1))
		
		lMovement = nil
		if getKeyState('mouse1') and lHover then
			lMovement = true
			if lHover == 'x' then
				local distance = (oX>nX) and (-distance) or distance
				setElementPositions(distance/2,0,0)
			elseif lHover == 'y' then
				local distance = (oY>nY) and (-distance) or distance
				setElementPositions(0,distance/2,0)
			elseif lHover == 'z' then
				local distance = (oZ>nZ) and (-distance) or distance
				setElementPositions(0,0,distance/2)
			elseif lHover == 'xr' then
				local distance = (fix > 0) and (-distance) or distance
				setElementRotations(-distance,0,0)
			elseif lHover == 'yr' then
				local distance = (fix > 0) and (-distance) or distance
				setElementRotations(0,distance,0)
			elseif lHover == 'zr' then
				local distance = (fix > 0) and (-distance) or distance
				setElementRotations(0,0,distance)
			elseif lHover == 'sx' then
				local distance = (oX>nX) and (-distance) or distance
				setElementScales(distance/2,0,0)
			elseif lHover == 'sy' then
				local distance = (oY>nY) and (-distance) or distance
				setElementScales(0,distance/2,0)
			elseif lHover == 'sz' then
				local distance = (oZ>nZ) and (-distance) or distance
				setElementScales(0,0,distance/2)
			end
		end
	end
end

addEventHandler( "onClientCursorMove", getRootElement( ),functions.onCursorMove)


function functions.selectElement ()
	if getHighLightedElement() and (not lHover) and not getKeyState('space') then
			if (not isCursorShowing()) then
			selectedElements[getHighLightedElement()] = not selectedElements[getHighLightedElement()]
			if not selectedElements[getHighLightedElement()] then
				setElementCollisionsEnabled(getHighLightedElement(),true)
				callS('freezeElement',getHighLightedElement(),false)
				selectedElements[getHighLightedElement()] = nil
			end
		end
	end
end


-----\\ Misc //-----
--------------------

--------------------
--// Right menu \\--
buttons.right = {{'Customize','New Element','Ped Editor','Settings'},menu = {}}
-- button types, Option, List, Color, Material, Text, Number, Checkbox,

buttons.right.menu['Customize'] = {menu = {},lists = {},extras = {}}
buttons.right.menu['New Element'] = {menu = {},lists = {},extras = {'Search'}} -- extras / Search means this menu contains a search bar at top in any level. So that you can type in an elements name it'll come up.
buttons.right.menu['Ped Editor'] = {menu = {},lists = {},extras = {}}
buttons.right.menu['Settings'] = {menu = {},lists = {}}

functions['RightMenu'] = function(name)
	buttons.right.selected = name
end

-- Look in client for a lua file with the corresponding name to what you are looking to edit; it's simplified here because there's so much going on in these ones.
--\\ Right menu //--
--------------------


height = 0
width = 0
arrow = functions.prepImage('arrow')


guiTypes['Option'] = function (wStart,hStart,path,iTable,side) --v[1],rStart,start
	local image = functions.prepImage(path)
		
		global.count[path] = global.count[path] or 1 -- Kinda shitty
		
		local hoverA = hover == path and 150 or 255
		dxDrawImage((wStart+5)*s, (hStart)*s, 24*s, 24*s,image, 0, 0, 0, tocolor(255, 255, 255, 255), true)	
		dxDrawText(path,(wStart+35)*s, hStart*s, (wStart+219)*s, (hStart+24)*s, tocolor(255, 255, 255, 220), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
		dxDrawText(iTable[global.count[path]],(wStart+120)*s, hStart*s, (wStart+200)*s, (hStart+24)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "center", "center", false, false, true, false, false)
		local hoverL = functions.isCursorOnElement((wStart+100)*s, (hStart+7.5)*s, 15*s, 10*s,'Option',-1,path,#iTable,iTable) and 150 or 255
		dxDrawImage((wStart+100)*s, (hStart+7.5)*s, 15*s, 10*s,arrow, 0, 0, 0, tocolor(hoverL, hoverL, hoverL, 255), true)	
		local hoverR = functions.isCursorOnElement((wStart+200)*s, (hStart+7.5)*s, 15*s, 10*s,'Option',1,path,#iTable,iTable) and 150 or 255
		dxDrawImage((wStart+200)*s, (hStart+7.5)*s, 15*s, 10*s,arrow, 180, 0, 0, tocolor(hoverR, hoverR, hoverR, 255), true)	


	if functions.isCursorOnElement(wStart*s, hStart*s, 215*s, 10*s,'Option',path,#iTable) then
		global.OptionHover = {path,#iTable}
	end
end

function functions.Option(change,path,tableCount,iTable)
	if tonumber(change) then
		global.count[path] = global.count[path] + change

		if global.count[path] > tableCount then
			global.count[path] = 1
		elseif global.count[path] < 1 then
			global.count[path] = tableCount
		end
	end
	
	if iTable then
		if functions[path] then
			functions[path](iTable[global.count[path]],global.count[path])
		end
	end
end


guiTypes['SideOption'] = function (wStart,hStart,name,iTable,side)--rStart,start,v[3],v // Ignore the mess on this one, it has to be like this.
	if iTable[1] then
		local image = functions.prepImage(iTable[1])
		local color = (global[name] == iTable[1]) and 250
		local b = (functions.isCursorOnElement((wStart+5)*s, (hStart+2)*s, 68*s, 20*s,name,iTable[1]) and 200 or 150)
		local color = color or b
		dxDrawRectangle((wStart+5)*s, (hStart+2)*s, 68*s, 20*s, tocolor(color, color, color, color), true)
		dxDrawImage((wStart+5)*s, (hStart)*s, 68*s, 24*s,image, 0, 0, 0, tocolor(255, 255, 255, 255), true)	
	end
				
	if iTable[2] then
		local image = functions.prepImage(iTable[2])
		local color = (global[name] == iTable[2]) and 250
		local b = (functions.isCursorOnElement((wStart+75)*s, (hStart+2)*s, 68*s, 20*s,name,iTable[2]) and 200 or 150)
		local color = color or b
		dxDrawRectangle((wStart+75)*s, (hStart+2)*s, 68*s, 20*s, tocolor(color, color, color, color), true)
		dxDrawImage((wStart+75)*s, (hStart)*s, 68*s, 24*s,image, 0, 0, 0, tocolor(255, 255, 255, 255), true)	
	end
				
	if iTable[3] then
		local image = functions.prepImage(iTable[3])
		local color = (global[name] == iTable[3]) and 250
		local b = (functions.isCursorOnElement((wStart+145)*s, (hStart+2)*s, 68*s, 20*s,name,iTable[3]) and 200 or 150)
		local color = color or b
		dxDrawRectangle((wStart+145)*s, (hStart+2)*s, 68*s, 20*s, tocolor(color, color, color, color), true)
		dxDrawImage((wStart+145)*s, (hStart)*s, 68*s, 24*s,image, 0, 0, 0, tocolor(255, 255, 255, 255), true)	
	end
end


guiTypes['List'] = function (wStart,hStart,name,iTable,side,subtract,indexing,gTable,spacing)--rStart,start,buttons.right.reverseIndent

	if (buttons[side].index-indexing) > 0 and (buttons[side].index-indexing) < 15 then
	
	dxDrawImage((wStart+10)*s, (hStart+6)*s, 12*s, 12*s,arrow, 180+(global.open[name] and 90 or 0), 0, 0, tocolor(255, 255, 255, 230), true)	
	dxDrawText(name, (wStart+40)*s, hStart*s, (wStart+239)*s, (hStart+24)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
	
	functions.isCursorOnElement(wStart*s, hStart*s, (259-(subtract or 0))*s, 24*s,'List',name)
	end
	
	if global.open[name] then
		for i,v in pairs(iTable) do

			buttons[side].index = buttons[side].index + 1
			global.scroll = global.scroll + 1
				
			if not (iTable[i][2] == 'List') then
				if (buttons[side].index-indexing) > 0 and (buttons[side].index-indexing) < 15 then
					dxDrawRectangle((wStart+15)*s, (spacing+24.5*(buttons[side].index-(indexing or 0)))*s, (259-(subtract or 0)-15)*s, 24*s, tocolor(45, 45, 45, 80), true)
					if guiTypes[iTable[i][2]] then
						guiTypes[iTable[i][2]](wStart+15,spacing+(24.5*(buttons[side].index-indexing)),iTable[i][1],iTable[i][3],side,subtract,indexing,gTable,spacing,iTable[i])
					end
				end
			else
				if (buttons[side].index-indexing) > 0 and (buttons[side].index-indexing) < 15 then
					dxDrawRectangle((wStart+15)*s, (spacing+24.5*(buttons[side].index-(indexing or 0)))*s, (259-(subtract or 0)-15)*s, 24*s, tocolor(35, 35, 35, 120), true)
				end
				guiTypes[iTable[i][2]](wStart+15,spacing+(24.5*(buttons[side].index-indexing)),iTable[i][1],gTable[iTable[i][1]],side,subtract+15,indexing,gTable,spacing,iTable[i])
			end
		end
	end
end

functions['List'] = function (name)
	global.open[name] = not global.open[name]
end


guiTypes['Object'] = function (wStart,hStart,name,iTable,side,subtract,indexing,gTable,spacing,tabl)
	local image = functions.prepImage('Object')
	dxDrawText(tabl[5], (wStart+25)*s, hStart*s, (wStart+239)*s, (hStart+24)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
	
	local hover = functions.isCursorOnElement((wStart+2)*s,hStart*s, 150*s, 24*s,'Object',tabl)
	
	if hover then
		oSelect = name
	end
	
	dxDrawImage((wStart+2)*s,(hStart)*s, 20*s,20*s,image, 0, 0, 0, tocolor(255, 255, 255, hover and 150 or 230), true)	
	
	
	if not (SearchText == '') then
		dxDrawText(((tabl[4] or {})[1]) or '', (wStart+120+(60))*s, hStart*s, (wStart+120+(60))*s, (hStart+24)*s, tocolor(180, 180, 180, 180), 0.8*s, "default-bold", "left", "center", false, false, true, false, false)
	end
end



functions['Object'] = function (tabl)
	local x,y,z = getWorldFromScreenPosition (xSize/2, ySize/2,(selectionDepth or 40)/2)
	callS('ObjectS',selectedElements,tabl[5],getKeyState('lctrl'),x,y,z)
end


functions['Select'] = function (object)
	selectedElements[object] = true
end


guiTypes['Color'] = function (wStart,hStart,name,iTable,side,subtract,indexing,gTable)

rC,gC,bC = unpack(iTable)

local hover = functions.isCursorOnElement((wStart+120)*s,hStart*s, (85-(subtract or 0))*s, 24*s,'Color',name,rC,gC,bC)
local alpha = hover and 150 or 255

if colorpicker.Open then
rC,gC,bC = unpack(colorpicker.colorbar)
end

dxDrawRectangle((wStart+120)*s,hStart*s, (85-(subtract or 0))*s, 24*s, tocolor(rC,gC,bC, alpha), true)

dxDrawText(name, (wStart+20)*s, hStart*s, (wStart+239)*s, (hStart+24)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
end

functions['Color'] = function(name,r,g,b)
	local ra,ga,ba,wB,hB = unpack(colorpicker.colorbar)
	colorpicker.colorbar = {r,g,b,wB,hB,rgb2hex(r,g,b)}
	colorpicker.Open = true
	colorpicker.Arrow = true
end


guiTypes['Material'] = function ()


end


guiTypes['Text'] = function (wStart,hStart,name,iTable,side,subtract,indexing)
	local hover = functions.isCursorOnElement((wStart+120)*s,hStart*s, (120-(subtract or 0))*s, 24*s,'Text',name,Text[name] or iTable)

	local alpha = hover and 50 or 70

	local edit = dxDrawEditBox((wStart+120)*s,hStart*s, (120-(subtract or 0))*s, 24*s,1*s,'default',tocolor(0,0,0),name,iTable) --// Modified version


	TextA = TextA + 1
	dxDrawText( name, (wStart+20)*s, hStart*s, (wStart+239)*s, (hStart+24)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
	return edit
end


functions['Text'] = function(name,iTable)
	Text[name] = iTable
	Text.Selected = name
end


guiTypes['Number'] = function (wStart,hStart,name,iTable,side,subtract,indexing) -- In all reality same as 'Text but with a singular variable change.
	local hover = functions.isCursorOnElement((wStart+120)*s,hStart*s, (120-(subtract or 0))*s, 24*s,'Text',name,Text[name] or iTable)

	local alpha = hover and 50 or 70

	local edit = dxDrawEditBox((wStart+120)*s,hStart*s, (120-(subtract or 0))*s, 24*s,1*s,'default',tocolor(15,15,15),name,iTable,true) --// Modified version

	TextA = TextA + 1
	dxDrawText( name, (wStart+20)*s, hStart*s, (wStart+239)*s, (hStart+24)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
end


guiTypes['Check box'] = function (wStart,hStart,name,iTable,side,subtract,indexing) 

	local image = functions.prepImage('Check')

	global.Checked[name] = global.Checked[name] or (indexing and 1 or 2)

	local hover = functions.isCursorOnElement((wStart+120)*s,(hStart+5)*s, 14*s,14*s,'Check box',name)
	local alpha = hover and 200 or 255

	dxDrawRectangle((wStart+120)*s,(hStart+5)*s, 14*s,14*s, tocolor(255,255,255, alpha), true)

	if global.Checked[name] == 1 then
		dxDrawImage((wStart+120)*s,(hStart+5)*s, 14*s,14*s,image, 0, 0, 0, tocolor(255, 255, 255, 230), true)	
	end


	TextA = TextA + 1
	dxDrawText( name, (wStart+20)*s, hStart*s, (wStart+239)*s, (hStart+24)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
end


functions['Check box'] = function (name)
	global.Checked[name] = (global.Checked[name] == 1) and 2 or 1
end


function functions.draw()
	countb = countb + 0.5

	if not(prepX == 0) or not(prepY == 0) or not(prepZ == 0) then

		local x = math.min(rChange,prepX * isNegative(prepX)) * isNegative(prepX)
		local y = math.min(rChange,prepY * isNegative(prepY)) * isNegative(prepY)
		local z = math.min(rChange,prepZ * isNegative(prepZ)) * isNegative(prepZ)
		setElementRotations(x,y,z,true,nil,true)
		prepX = prepX-x
		prepY = prepY-y
		prepZ = prepZ-z
	end


	ignoreGimbal = nil

	if colorpicker.Open then
		colorpicker.cfunction()
	end

	if TextA == 0 then
		Text.Selected = nil
		toggleAllControls ( true, true, true	)
	end

	if Option == 0 then
		global.OptionHover = nil
	end

	Option = 0
	TextA = 0

	yChange = 0

	--- Left menu ---
	local rStart = 16
	local rEnd = (rStart+218)
	dxDrawRectangle(rStart*s, 31*s, 219*s, 24*s, tocolor(62, 62, 62, 130), true)

	for i,v in pairs(buttons.left[1]) do
		local image = functions.prepImage(v)
		local color = global[v] and 150 or 255
		local color = (functions.isCursorOnElement(rStart-25+(30*(i))*s,31*s, 24*s, 24*s,v) and 80 or color)
		dxDrawImage((rStart-25+(30*(i)))*s,31*s, 24*s, 24*s,image, 0, 0, 0, tocolor(255, 255, 255, color), true)
	end

	for i,v in pairs(buttons.left[2]) do
		local image = functions.prepImage(v)
		local color = global[v] and 150 or 255
		local color = (functions.isCursorOnElement((rEnd-(30*i))*s,31*s, 24*s, 24*s,v) and 80 or color)
		dxDrawImage((rEnd-(30*i))*s,31*s, 24*s, 24*s,image, 0, 0, 0, tocolor(255, 255, 255, color), true)
	end

	buttons.left.subtract = 0
	buttons.left.endT = 0
	buttons.left.index = 0

	for i,v in pairs(buttons.left.menu) do
		if (v == 'blank') then
			buttons.left.subtract = -20
			buttons.left.index = buttons.left.index + 1
		else
			buttons.left.index = buttons.left.index + 1
			local start = (buttons.left.subtract+30+(24.5*buttons.left.index))
			dxDrawRectangle(rStart*s, start*s, 219*s, 24*s, tocolor(5, 5, 5, 130), true)
			buttons.left.endT = math.max(buttons.left.endT,(start+24))
			guiTypes[v[2]](rStart,start,v[1],v[3],'left') -- Moved to function based drawing so that we can use the same type of draws on left, or right.
		end
	end

	---24
	if not global.Controls then
		local start = buttons.left.endT+(15)

		dxDrawRectangle ( 15*s, (start-5)*s, 320*s, height*s, tocolor ( 0, 0, 0, 130 ),true )

		for i,v in pairs(binds.dynamic) do -- This allows us to order the index.
			continue = true
			if binds.check[v[3] or v[1]] then
				if binds.check[v[3] or v[1]]() then
					continue = true
				else
					continue = false
				end
			end
			if continue then
				size = 0
				local ya = 0

				for ia,va in pairs(v[2]) do
					local image,scale = functions.getLetter(va)
					local x,y = unpack(scale)
					local x,y = (x*0.2),(y*0.2)
					local color = getKeyState(va) and 150 or 255
					dxDrawImage((size+20)*s, (yChange+start)*s, x*s, y*s,image, 0, 0, 0, tocolor(220, 220, 220, color), true)

					size = size+(x+2)
					ya = math.max(ya,y+2)
				end
				dxDrawText(v[1], (width+30)*s, (yChange+start)*s, width*s, (yChange+(30)+start)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
				yChange = yChange+ya
				width = math.max(width,size)
			end
		end

		yChange = yChange

		for i,v in pairs(binds.static) do -- This allows us to order the index.
			continue = true
			if binds.check[v[3] or v[1]] then
				if binds.check[v[3] or v[1]]() then
					continue = true
				else
					continue = false
				end
			end
			if continue then
				size = 0
				local ya = 0

				for ia,va in pairs(v[2]) do
					local image,scale = functions.getLetter(va)
					local x,y = unpack(scale)
					local x,y = (x*0.2),(y*0.2)

					local color = getKeyState(va) and 150 or 255
					dxDrawImage((size+20)*s, (yChange+start)*s, x*s, y*s,image, 0, 0, 0, tocolor(220, 220, 220, color), true)

					size = size+(x+2)
					ya = math.max(ya,y+2)
				end
				dxDrawText(v[1], (width+30)*s, (yChange+start)*s, width*s, (yChange+(30)+start)*s, tocolor(255, 255, 255, 255), 1.00*s, "default-bold", "left", "center", false, false, true, false, false)
				yChange = yChange+ya
				width = math.max(width,size)
			end
		end

		height = yChange+5
	end



	local rStart = (xSize - (275*s))
	local rEnd = (rStart+(259*s))
	dxDrawRectangle(rStart, 31*s, 259*s, 24*s, tocolor(62, 62, 62, 130), true)


	for i,v in pairs(buttons.right[1]) do
		local image = functions.prepImage(v)

		local color = (buttons.right.selected == v) and 100 or 255
		local color = functions.isCursorOnElement(rStart+(45*i)*s, 31*s, 24*s, 24*s,'RightMenu',v) and 80 or color


		dxDrawImage(rStart+(45*i)*s, 31*s, 24*s, 24*s,image, 0, 0, 0, tocolor(255, 255, 255, color), true)
	end

	local iTable = (buttons.right.menu[buttons.right.selected or 'New Element'])
	local count = #iTable


	if iTable[3] then
		if iTable[3][1] then
			additionalSpacing = 55
			local start = (30+(24.5))
			SearchText = dxDrawEditBox(rStart,start*s, (259-(buttons.right.reverseIndent or 0))*s, 24*s,1*s,'default',tocolor(0,0,0),'Search Bar','',false,tocolor(250,250,250,200)) --// Modified version
			if SearchText and (not (SearchText == '')) then
				local result = Search(SearchText)
				count = #result
				iTable = result
			end
		else
			additionalSpacing = 30
		end
	end

	buttons.right.reverseIndent = 0
	buttons.right.index =	0

	if (global.scroll or 0) > 15 then
		local fix = (15/global.scroll)*342

		global.old = global.old or global.scroll

		if not (global.scroll-global.old == 0) then
			global.scrollRight = ((global.countadditionUF/(global.scroll-14))*(342-fix))
		end

		global.scrollRight = math.max(math.min(global.scrollRight,(342-fix)),0)

		global.countadditionUF = (global.scrollRight/(342-fix)*(global.scroll-14))
		global.countaddition = math.floor(global.countadditionUF)

		dxDrawRectangle(rEnd-(15*s), 55.5*s, 15*s, 342*s, tocolor(45, 45, 45, 100), true)
		dxDrawRectangle(rEnd-(15*s), (global.scrollRight+55.5)*s, 15*s, fix*s, tocolor(200, 200, 200, 90), true) -- Actual Scroll, math for this is going to be hell. Send help
		buttons.right.reverseIndent = 16 --
		functions.isCursorOnElementAlt(rEnd-(15*s), (global.scrollRight+55.5)*s, 15*s, fix*s,'scroll','scrollRight')


		if functions.isCursorOnElement(rStart+1, 56.5*s, 260*s, 343*s) then
			selectedScroll = 'scrollRight'
		else
			selectedScroll = nil
		end


		global.old = global.scroll
	else
		global.countaddition = 0
	end

	global.scroll = count

	for i=1,count do

		buttons.right.index = buttons.right.index + 1


		if (buttons.right.index-global.countaddition) > 0 and (buttons.right.index-global.countaddition) < 15 then
			local start = (additionalSpacing+(24.5*(buttons.right.index-global.countaddition)))
			dxDrawRectangle(rStart, start*s, (259-(buttons.right.reverseIndent or 0))*s, 24*s, tocolor(0, 0, 0, 130), true)
		end

		if iTable[i][2] then
			if iTable.lists then
				local start = (additionalSpacing+(24.5*(buttons.right.index-global.countaddition)))
				guiTypes[iTable[i][2]](rStart/s,start,iTable[i][1],iTable.lists[iTable[i][1]],'right',buttons.right.reverseIndent,global.countaddition,iTable.lists,additionalSpacing) -- Moved to GUI types so that we can use it on left / right plus we will be drawing children, meaning it'd make no sense to repeat the function a million times.
			else
				if (buttons.right.index-global.countaddition) > 0 and (buttons.right.index-global.countaddition) < 15 then
					local start = (additionalSpacing+(24.5*(buttons.right.index-global.countaddition)))
					guiTypes[iTable[i][2]](rStart/s,start,iTable[i][1],iTable[i][3],'right',buttons.right.reverseIndent,global.countaddition,iTable[i][3],additionalSpacing,iTable[i]) -- Moved to GUI types so that we can use it on left / right plus we will be drawing children, meaning it'd make no sense to repeat the function a million times.
				end
			end
		end
	end

	--//local start = (additionalSpacing+(24.5*math.min(count+1,15)+5))

	if isFreecamEnabled() then

		if isThereSelected() and freeMove then
			local xA,yA,zA,xAb,yAb,zAb = getCameraMatrix()
			local xB,yB,zB = getSelectedElementsCenter()
			local hit, xC,yC,zC,element = processLineOfSight ( xA,yA,zA,xAb,yAb,zAb )

			if selectedElements[element] then
				xB,yB,zB = (xC or xB),(yC or yB),(zC or zB)
			else
				xB,yB,zB = xB,yB,zB
			end


			distanceP = distanceP or getDistanceBetweenPoints3D(xA,yA,zA,xB,yB,zB)

			local xA,yA,zA = getWorldFromScreenPosition ( xSize/2, ySize/2,distanceP )


			if not ((xA == oldMx) and (yA == oldMy) and (yA == oldMy)) then
				if isFreecamEnabled() then
					if oldMx then
						setElementPositions(xA-oldMx,yA-oldMy,zA-oldMz,true,true)
					else
						distanceP = nil
					end
				end
			end

			oldMx,oldMy,oldMz = xA,yA,zA
		else
			oldMx,oldMy,oldMz = nil,nil,nil
			distanceP = nil
		end



		local size = 50*s

		local sizea = (((getKeyState('mouse1') and 40 or 50) - getFreecamSpeed()/80) - (hElement and 5 or 0))*s
		local x = (xSize-size)/2
		local y = (ySize-size)/2

		local xa = (xSize-sizea)/2
		local ya = (ySize-sizea)/2

		local image = functions.prepImage('crosshair')
		local center = functions.prepImage('crosshair_c')

		if not isCursorShowing() then
			local bColor = freeMove and 0 or 255
			dxDrawImage(xa,ya,sizea,sizea,image, 0, 0, 0, tocolor(255,bColor,bColor,150),true)
			dxDrawImage(x,y,size,size,center, 0, 0, 0, tocolor(0, 0, 0, 150), true)
		end


		if isFreecamEnabled() and (not isCursorShowing()) then
			hElement = getHighLightedElement()
		else
			hElement = nil
		end

		if (not (global['Boundries'] == 'On Screen')) and (not (global['Boundries'] == 'None')) then
			if not isCursorShowing() then

				if hElement then
					functions.boundingBox(hElement,true)
				end
			end
		elseif (global['Boundries'] == 'On Screen') then
			for i,v in pairs(getAllElements(true,true)) do
				functions.boundingBox(v,(hElement == v),true)
			end
		end

	end

	if isFreecamEnabled() then
		if getKeyState('mouse1') then
			if not toggleb then
				functions.selectElement()
			end
		end
	end
	toggleb = getKeyState('mouse1')


	if cursor then
		mouseA = functions.prepImage('mouse')
		local xM,yM = getCursorPosition ( )
		dxDrawImage(xM*xSize,yM*ySize,25*s,(25*1.5)*s,mouseA, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	end

	if (not (global['Boundries'] == 'On Screen')) and (not (global['Boundries'] == 'None')) then
		for i,v in pairs(selectedElements) do
			if not (hElement == i) then
				if isElementOnScreen(i) then
					functions.boundingBox(i)
				end
			end
		end
	end

	functions.DrawGimbal()

		for i,v in pairs(selectedElements) do
			callS('freezeElement',i,true)
		end

		for i,v in pairs(binds.dynamic) do
			for ia,va in pairs(v[2]) do
				if getKeyState(va) or (rebind[va] and getKeyState(rebind[va])) then
					if functions[v[1]] then
						functions[v[1]](va,ia,v[2]) --// Bind Name, Bind ID and Bind Table. Table is for funcitons that require multiple binds to be held.
					end
				end
			end
		end
	functions.drawMagnets()
end

addEventHandler("onClientRender", root,functions.draw)


------------------------------------
--// Magnets and Bounding Boxes \\--

function functions.drawMagnets()
	if isThereSelected() and global.Mangets and freeMove then
		local xb,yb,zb = getCameraMatrix()
		for i,v in pairs(getAllElements(true,true)) do
			local m = magnets[v]
			local xa,ya,za = getElementPosition(v)
			if (getDistanceBetweenPoints3D (xa,ya,za,xb,yb,zb) < 50) and m then
				for iA = 1,8 do
				
					if mClose[v] and mClose[v][iA] then
						dxDrawLine3D ( m[iA].x+0.05,m[iA].y+0.05,m[iA].z+0.05,m[iA].x-0.05,m[iA].y-0.05,m[iA].z-0.05,tocolor(255,50,50), 10*s)
					else
						dxDrawLine3D ( m[iA].x+0.05,m[iA].y+0.05,m[iA].z+0.05,m[iA].x-0.05,m[iA].y-0.05,m[iA].z-0.05,tocolor(50,50,255), 10*s)
					end
				end
			end
		end
	end
end

functions.magnetMovement = function ()
	local element = unpack(mClose.connection)
	
	minDistance = global.Mangets
	
	functions.magnetTimer()
	functions.checkMagnets(element)
	
	local _,vector = unpack(mClose.connection)
	setElementPositions(vector.x,vector.y,vector.z,true,true)
end


function functions.prepMagnets(element)
	if freeMove then
		if not (getElementID(element) == 'skybox_model') then
			local xa,ya,za,xb,yb,zb = getElementBoundingBox (element)
			if xa then
				local matrix = element.matrix
				
				
				if getElementType(element) == 'object' then
					local sX,sY,sZ = getObjectScale(element)	
					xa,ya,za,xb,yb,zb = xa*sX,ya*sY,za*sZ,xb*sX,yb*sY,zb*sZ
				end
		
				local tFL = matrix:transformPosition(Vector3(xa,ya,za)) -- Top front left
				local tFR = matrix:transformPosition(Vector3(-xa,ya,za)) -- Top front right
				local tRL = matrix:transformPosition(Vector3(xa,-ya,za)) -- Top rear left
				local tRR = matrix:transformPosition(Vector3(-xa,-ya,za)) -- Top rear right
				local bFL = matrix:transformPosition(Vector3(-xb,-yb,zb)) -- Bottom front left
				local bFR = matrix:transformPosition(Vector3(xb,-yb,zb)) -- Bottom front right
				local bRL = matrix:transformPosition(Vector3(-xb,yb,zb)) -- Bottom rear left
				local bRR = matrix:transformPosition(Vector3(xb,yb,zb)) -- Bottom rear right

				magnets[element] = {tFL,tFR,tRL,tRR,bFL,bFR,bRL,bRR}
			end
		end
	end
end

local positions = {}

function functions.magnetTimer()
	if freeMove then
		if isThereSelected() then
			if global.Mangets then
				for i,element in pairs(getAllElements(true,true)) do -- // Only prep magnets of streamed in crap on screen
					local x,y,z = getElementPosition(element)
					positions[element] = positions[element] or {}
					if (not(x == positions[element][1]) or not(y == positions[element][2]) or not(z == positions[element][3])) then
						functions.prepMagnets(element)
						positions[element] = {x,y,z}
					end
				end
			end
		end
	end
end

minDistance = global.Mangets or 500

function functions.checkMagnets(element)
	if global.Mangets then
		mClose[element] = mClose[element] or {}
		local x,y,z = getCameraMatrix()
		for i,v in pairs(magnets) do
			if isElement(i) and isElementOnScreen(i) then
				local xa,ya,za = getElementPosition(i)
				if getDistanceBetweenPoints3D (xa,ya,za,x,y,z) < 50 then
					if not selectedElements[i] then
						for iA,vA in pairs(v) do
							for iB,vB in pairs(magnets[element]) do
								local distance = getDistanceBetweenPoints3D(vA.x,vA.y,vA.z,vB.x,vB.y,vB.z)
								if (distance < minDistance) then
									minDistance = distance
									mClose[element][iB] = true
									mClose[i] = mClose[i] or {}
									mClose[i][iA] = true
									mClose.connection = {element,Vector3(vA.x-vB.x,vA.y-vB.y,vA.z-vB.z)}
								end
							end
						end
					end
				end
			end
		end
	end
end -- Bit of a mess.

setTimer ( functions.magnetTimer, 1000, 0 )


function functions.boundingBox(element,hover,global)
	local xa,ya,za,xb,yb,zb = getElementBoundingBox ( element )
	if xa then
	--	local xb,yb,zb = -xa,-ya,-za --// Removed the last part because we need perfect squares.
		
		local matrix = element.matrix
		
		if getElementType(element) == 'object' then
			local sX,sY,sZ = getObjectScale(element)	
			xa,ya,za,xb,yb,zb = xa*sX,ya*sY,za*sZ,xb*sX,yb*sY,zb*sZ
		end
		


		local m1 = matrix:transformPosition(Vector3(xa,ya,za)) 		-- Top front left
		local m2 = matrix:transformPosition(Vector3(-xa,ya,za))		-- Top front right
		local m3 = matrix:transformPosition(Vector3(xa,-ya,za)) 	-- Top rear left
		local m4 = matrix:transformPosition(Vector3(-xa,-ya,za)) 	-- Top rear right
		
		local m5 = matrix:transformPosition(Vector3(-xb,-yb,zb))    -- Bottom front left
		local m6 = matrix:transformPosition(Vector3(xb,-yb,zb)) 	-- Bottom front right
		local m7 = matrix:transformPosition(Vector3(-xb,yb,zb)) 	-- Bottom rear left
		local m8 = matrix:transformPosition(Vector3(xb,yb,zb)) 	 	-- Bottom rear right
		
		local x1,y1,z1 = m1.x,m1.y,m1.z
		local x2,y2,z2 = m2.x,m2.y,m2.z
		local x3,y3,z3 = m3.x,m3.y,m3.z
		local x4,y4,z4 = m4.x,m4.y,m4.z
		
		local x5,y5,z5 = m5.x,m5.y,m5.z
		local x6,y6,z6 = m6.x,m6.y,m6.z
		local x7,y7,z7 = m7.x,m7.y,m7.z
		local x8,y8,z8 = m8.x,m8.y,m8.z
		
		
		local cColor = nil

		if global then
			cColor =	tocolor ( 255, 50, 0, 230 )
		end

		if selectedElements[element] then
			cColor =	tocolor ( 255, 0, 0, 230 )
		end

		if hover then
			cColor =	tocolor ( 255, 180, 0, 230 )
		end

		if hover and selectedElements[element] then
			cColor =	tocolor ( 0, 0, 255, 230 )
		end


		
		dxDrawLine3D ( x1,y1,z1,x2,y2,z2,cColor, 3) -- TFL -> TFR
		dxDrawLine3D ( x1,y1,z1,x5,y5,z5,cColor, 3) -- TFL -> BFL
		dxDrawLine3D ( x1,y1,z1,x3,y3,z3,cColor, 3) -- TFL -> TRL

		dxDrawLine3D ( x2,y2,z2,x4,y4,z4,cColor, 3) -- TFR -> TRR
		dxDrawLine3D ( x2,y2,z2,x6,y6,z6,cColor, 3) -- TFR -> BFR

		dxDrawLine3D ( x4,y4,z4,x3,y3,z3,cColor, 3) -- TRR -> TRL
		dxDrawLine3D ( x4,y4,z4,x8,y8,z8,cColor, 3) -- TRR -> BRR

		dxDrawLine3D ( x7,y7,z7,x3,y3,z3,cColor, 3) -- BRL -> TRL
		dxDrawLine3D ( x7,y7,z7,x5,y5,z5,cColor, 3) -- BRL -> BFL
		dxDrawLine3D ( x7,y7,z7,x8,y8,z8,cColor, 3) -- BRL -> BRR

		dxDrawLine3D ( x6,y6,z6,x8,y8,z8,cColor, 3) -- BFR -> BRR
		dxDrawLine3D ( x6,y6,z6,x5,y5,z5,cColor, 3) -- BFR -> BRR
	end
end

--\\ Magnets and Bounding Boxes //--
------------------------------------

