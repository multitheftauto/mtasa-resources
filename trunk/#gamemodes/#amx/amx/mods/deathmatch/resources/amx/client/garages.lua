addEventHandler( "onClientRender", getRootElement(),
	function(  )
		for i=0,49 do
			local gx, gy, gz = getGaragePosition( i )
			local px, py, pz = getElementPosition( getLocalPlayer() )
			local dist = getDistanceBetweenPoints3D(gx, gy, gz, px, py, pz)
			if(dist < 20) then
				if(isGarageOpen(i) == false) then
					server.setGarageOpen(i, true)
				end
			else
				if(isGarageOpen(i) == true) then
					server.setGarageOpen(i, false)
				end
			end
		end
	end
)
