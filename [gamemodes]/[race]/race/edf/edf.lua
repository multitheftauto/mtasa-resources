g_ModelForPickupType = { nitro = 2221, repair = 2222, vehiclechange = 2223 }

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
				if getMarkerType(marker) == "checkpoint" then
					setMarkerIcon ( marker, "arrow" )
				end
				setMarkerTarget ( marker, exports.edf:edfGetElementPosition(nextID) )
			else
				if getMarkerType(marker) == "checkpoint" then
					setMarkerIcon ( marker, "finish" )
				end
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

addEventHandler ( "onElementDestroy", root,
	function()
		if getElementType(source) == "checkpoint" then
			for i,checkpoint in ipairs(getElementsByType"checkpoint") do
				if checkpoint ~= source and exports.edf:edfGetElementProperty ( checkpoint, "nextid" ) == source then
					local nextcp = exports.edf:edfGetElementProperty ( source, "nextid" )
					exports.edf:edfSetElementProperty ( checkpoint, "nextid", nextcp )
					if not nextcp then
						local marker = getRepresentation(checkpoint, "marker")
						setMarkerIcon ( marker, "finish" )
					end
					break
				end
			end
		end
	end
)

addEventHandler ( "onElementPropertyChanged", root,
	function ( propertyName )
		if getElementType(source) == "racepickup" and propertyName == "type" then
			local pickupType = exports.edf:edfGetElementProperty ( source, "type" )
			local object = getRepresentation(source, "object")
			if object then
				setElementModel ( object, g_ModelForPickupType[pickupType] or 1337 )
			end
		elseif getElementType(source) == "checkpoint" then
			if propertyName == "nextid" or propertyName == "type" then
				local nextID = exports.edf:edfGetElementProperty ( source, "nextid" )
				local marker = getRepresentation(source,"marker")
				if nextID then
					if getMarkerType(marker) == "checkpoint" then
						setMarkerIcon ( marker, "arrow" )
					end
					setMarkerTarget ( marker, exports.edf:edfGetElementPosition(nextID) )
				else
					if getMarkerType(marker) == "checkpoint" then
						setMarkerIcon ( marker, "finish" )
					end
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
