texture gOverlay;

technique TexOverlay
{
	pass P0
	{
		// We don't do a damn thing here
	}
	
	pass P1
	{
		// Draw the overlay on top, if we have one
		Texture[0] = gOverlay;
		
		// Make sure we can use alpha. This shader wouldn't have much use without it
		AlphaBlendEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
	}
}