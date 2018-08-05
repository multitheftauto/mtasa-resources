--[[
function createShader()
	x,y = guiGetScreenSize()
	highlightRT = dxCreateRenderTarget( x,y, true )
	highlightShader = dxCreateShader( "Shader/selectorCol.fx", 1, 0, true )
	dxSetShaderValue (highlightShader, "secondRT", highlightRT)
	highlightPostShader = dxCreateShader( "Shader/highlight.fx", 1, 0, true )
	dxSetShaderValue(highlightPostShader, "sTex0", highlightRT)
	dxSetShaderValue(highlightPostShader, "sRes", x,y)

	addEventHandler( "onClientHUDRender", root, onClientHUDRenderFunction )
end


function RemoveElementFromSelection(element)
	engineRemoveShaderFromWorldTexture( highlightShader, "*", element )
end

function AddElementToSelection(element)
	engineApplyShaderToWorldTexture( highlightShader, "*", element )
end


function onClientHUDRenderFunction()
	dxDrawImage( 0, 0, x,y, highlightPostShader )
	dxSetRenderTarget( highlightRT, true )
	dxSetRenderTarget()
end
createShader()

AddElementToSelection(getElementsByType('vehicle',true)[1])
]]--