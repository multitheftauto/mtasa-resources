

function createShader()

	local x,y = guiGetScreenSize()
	RT = dxCreateRenderTarget( x,y, true )
	Shader = dxCreateShader( "files/Shaders/selectorCol.fx", 1, 0, true )
	dxSetShaderValue (Shader, "secondRT", RT)
	Shader2 = dxCreateShader( "files/Shaders/highlight.fx", 1, 0, true )
	dxSetShaderValue(Shader2, "sTex0", RT)
	dxSetShaderValue(Shader2, "sRes", x,y)

	addEventHandler( "onClientHUDRender", root, onClientHUDRenderFunction )
end



function onClientHUDRenderFunction()
	dxDrawImage( 0, 0,  x,y, Shader2)
	dxSetRenderTarget( RT, true )
	dxSetRenderTarget()
end


engineApplyShaderToWorldTexture( Shader2, "*" )
--engineRemoveShaderFromWorldTexture( Shader2, "*")