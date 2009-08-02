g_ModelForPickupType = { nitro = 1337, repair = 1338, vehiclechange = 1339 }

addEventHandler ( "onMapOpened", root,
	function()
		for i,pickup in ipairs(getElementsByType"racepickup") do
			local pickupType = exports.edf:edfGetElementProperty ( pickup, "type" )
			local object = getRepresentation(pickup, "object")
			if object then
				setElementModel ( object, g_ModelForPickupType[pickupType] or 1337 )
			end		
		end
		for i,checkpoint in ipairs(getElementsByType"checkpoint") do
			local marker = getRepresentation(checkpoint, "marker")
			local nextID = exports.edf:edfGetElementProperty ( checkpoint, "nextid" )
			if nextID then
				setMarkerIcon ( marker, "arrow" )
				setMarkerTarget ( marker, exports.edf:edfGetElementPosition(nextID) )
			else
				setMarkerIcon ( marker, "finish" )
			end
		end
	end
)

addEventHandler ( "onElementCreate", root,
	function()
		if getElementType(source) == "checkpoint" then
			--Find the first element without a nextid
			for i,checkpoint in ipairs(getElementsByType"checkpoint") do
				if checkpoint ~= source and not exports.edf:edfGetElementProperty ( checkpoint, "nextid" ) then
					exports.edf:edfSetElementProperty ( checkpoint, "nextid", source )
					break
				end
			end
			local marker = getRepresentation(source,"marker")
			setMarkerIcon ( marker, "finish" )
		end
	end
)

addEventHandler ( "onElementPropertyChanged", root,
	function ( propertyName )
		if getElementType(source) == "racepickup" and propertyName == "type" then
			local pickupType = exports.edf:edfGetElementProperty ( source, propertyName )
			local object = getRepresentation(source, "object")
			if object then
				setElementModel ( object, g_ModelForPickupType[pickupType] or 1337 )
			end
		elseif getElementType(source) == "checkpoint" then
			if propertyName == "nextid" then
				local nextID = exports.edf:edfGetElementProperty ( source, propertyName )
				local marker = getRepresentation(source,"marker")
				if nextID then
					setMarkerIcon ( marker, "arrow" )
					setMarkerTarget ( marker, exports.edf:edfGetElementPosition(nextID) )
				else
					setMarkerIcon ( marker, "finish" )
				end
			elseif propertyName == "position" then
				--If this checkpoint is the nextid of any other checkpoints
				for i,checkpoint in ipairs(getElementsByType"checkpoint") do
					if exports.edf:edfGetElementProperty ( checkpoint, "nextid" ) == source then
						local marker = getRepresentation(checkpoint,"marker")
						setMarkerTarget ( marker, exports.edf:edfGetElementPosition(source) )
					end
				end
			end
		end
	end
)

function getRepresentation(element,type)
	for i,elem in ipairs(getElementsByType(type,element)) do
		if elem ~= exports.edf:edfGetHandle ( elem ) then
			return elem
		end
	end
	return false
end
