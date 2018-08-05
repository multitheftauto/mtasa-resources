//
// highlight.fx
// By Ren712
//

//------------------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------------------
float2 sRes = float2(800,600);
float blurStr = 1;
float edgeStr = 4;
float4 fillColor = float4(0,0.3,0.7,0.1);

// between 1 and 64
float bitDepth = 16;

// between 0 and 1
float outlStreng = 1;

//------------------------------------------------------------------------------------------
// Textures
//------------------------------------------------------------------------------------------
texture sTex0;

//------------------------------------------------------------------------------------------
// Sampler Inputs
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = <sTex0>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(float2 TexCoord : TEXCOORD0) : COLOR0
{
    float4 Blur = tex2D(Sampler0, TexCoord);
    float4 s1 = tex2D(Sampler0, TexCoord + blurStr * float2(-1.0f / sRes.x, -1.0f / sRes.y));
    float4 s2 = tex2D(Sampler0, TexCoord + blurStr * float2(0, -1.0f / sRes.y));
    float4 s3 = tex2D(Sampler0, TexCoord + blurStr * float2(1.0f / sRes.x, -1.0f / sRes.y));
    float4 s4 = tex2D(Sampler0, TexCoord + blurStr * float2(-1.0f / sRes.x, 0));
    float4 s5 = tex2D(Sampler0, TexCoord + blurStr * float2(-1.0f / sRes.x, 0));
    float4 s6 = tex2D(Sampler0, TexCoord + blurStr * float2(-1.0f / sRes.x, 1.0f / sRes.y));
    float4 s7 = tex2D(Sampler0, TexCoord + blurStr * float2(0, 1.0f / sRes.y));
    float4 s8 = tex2D(Sampler0, TexCoord + blurStr * float2(1.0f / sRes.x, 1.0f / sRes.y));
	  
    Blur = (Blur + s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8) / 9;
  
    float4 Color = Blur;

    Color.rgb *= bitDepth;
    Color.rgb = floor(Color.rgb);
    Color.rgb /= bitDepth;

    float4 lum = float4(0.30, 0.6, 0.1, 1);
 
    float s11 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(-1.0f / sRes.x, -1.0f / sRes.y)), lum);
    float s12 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(0, -1.0f / sRes.y)), lum);
    float s13 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(1.0f / sRes.x, -1.0f / sRes.y)), lum);
 
    float s21 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(-1.0f / sRes.x, 0)), lum);
    float s23 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(-1.0f / sRes.x, 0)), lum);
 
    float s31 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(-1.0f / sRes.x, 1.0f / sRes.y)), lum);
    float s32 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(0, 1.0f / sRes.y)), lum);
    float s33 = dot(tex2D(Sampler0, TexCoord + edgeStr * float2(1.0f / sRes.x, 1.0f / sRes.y)), lum);

    float t1 = s13 + s33 + (2 * s23) - s11 - (2 * s21) - s31;
    float t2 = s31 + (2 * s32) + s33 - s11 - (2 * s12) - s13;
 
    float4 OutLine;
 
    if (((t1 * t1) + (t2 * t2)) > outlStreng/10) {
        OutLine = 1;
    } else {
        OutLine = 0;
    }

    float4 finalColor = tex2D(Sampler0, TexCoord);
    finalColor.a = 0.1;
    if (OutLine.a == 1){
        finalColor = Blur * OutLine;
        finalColor.a = 1;
    }
	
    return finalColor;
}
 
technique edge
{
    pass Pass1
    {
        SrcBlend = SrcAlpha;
        DestBlend = One;
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
