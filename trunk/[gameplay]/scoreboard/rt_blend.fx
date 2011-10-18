//
// rt_blend.fx
//


//---------------------------------------------------------------------
// rt_blend settings
//---------------------------------------------------------------------
texture sTexture0;


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        // Set our texture
        Texture[0] = sTexture0;

        // Use additive blending
        SrcBlend = One;
        DestBlend = InvSrcAlpha;
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
