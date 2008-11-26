local interiorAnims = {}
local setInteriorMarkerZ = {
	interiorEntry = function(marker,z)
		local interiorElement = getElementParent(marker)
		local vx = getElementData ( interiorElement,"posX" )
		local vy = getElementData ( interiorElement,"posY" )
		local vz = getElementData ( interiorElement,"posZ" )
		--
	 	setElementPosition(marker, vx, vy, vz + z/2 + 2.4)
	end,
	interiorReturn = function(marker,z)
		local interiorElement = getElementParent(marker)
		local vx = getElementData ( interiorElement,"posX" )
		local vy = getElementData ( interiorElement,"posY" )
		local vz = getElementData ( interiorElement,"posZ" )
		--
	 	setElementPosition(marker, vx, vy, vz + z/2 + 2.4)	
	end
}

addEventHandler("onClientElementStreamIn",getRootElement(),
	function()
		if getElementType ( source ) == "marker" then
			local parent = getElementParent ( source ) 
			local parentType = getElementType(parent)
			if parentType == "interiorEntry" or parentType == "interiorReturn" then
				interiorAnims[source] = Animation.createAndPlay(
		source,
 		{ from = 0, to = 2*math.pi, time = 2000, repeats = 0, transform = math.sin, fn = setInteriorMarkerZ[parentType] }
)
			end
		end
	end
)

addEventHandler("onClientElementStreamOut",getRootElement(),
	function()
		if getElementType ( source ) == "marker" then
			local parent = getElementParent ( source ) 
			local parentType = getElementType(parent)
			if parentType == "interiorEntry" or parentType == "interiorReturn" then
				if (interiorAnims[source] ) then
					interiorAnims[source]:remove()
				end
			end
		end
	end
)





