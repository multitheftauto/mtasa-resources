local progressbars = {}


function guiCreateNiceProgressBar (x, y, sizex, sizey, relative, parent)
	local bar = guiCreateStaticImage(x, y, sizex, sizey, "pbar.png", relative, parent)
	progressbars[bar] = {}
	progressbars[bar]["progress"] = guiCreateStaticImage(0,0,0,0,"pbar1.png",true,bar)
	progressbars[bar]["alpha"] = guiCreateStaticImage(0,0,0,0,"pbar2.png",true,bar)
	guiSetAlpha ( progressbars[bar]["alpha"], 0 )
	progressbars[bar]["percent"] = 0
	return bar
	--progress = guiCreateStaticImage(0, 0, 0.05, 1, "pbar1.png", true, bar)
end
addCommandHandler("bar", guiCreateNiceProgressBar)

function guiNiceProgressBarSetProgress (bar, progress)
	if progressbars[bar] == nil then return false end
	progress = tonumber(progress)
	if progress == nil then return false end
	--if progress <= 0 then
		--progress = 0.1
	if progress > 100 then
		progress = 100
	end
	progressbars[bar]["percent"] = progress
	local progress = progress / 100
	local theBar = progressbars[bar]["progress"]
	local theAlpha = progressbars[bar]["alpha"]
	local success = guiSetSize(theBar, progress, 1, true)
	local successA = guiSetSize(theAlpha, progress, 1, true)
	if successA == false then return false end
	return success
	
end
addCommandHandler("progress", guiNiceProgressBarSetProgress)

function guiNiceProgressBarGetProgress ( bar )
	return progressbars[bar]["percent"]
end

function guiNiceProgressBarSetAlpha ( bar, alpha )
	returnAlpha = guiSetAlpha ( progressbars[bar]["alpha"], alpha )
	return returnAlpha
end

function guiNiceProgressBarGetAlpha ( bar )
	returnCAlpha = guiGetAlpha ( progressbars[bar]["alpha"] )
	return returnCAlpha
end
			
		
	
	
	