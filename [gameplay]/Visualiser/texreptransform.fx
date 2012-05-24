//  Texture replace and transform

//#include "mta-helper.fx"
float4x4 gWorld : WORLD;
float4x4 gView  : VIEW;
float4x4 gProjection  : PROJECTION;
float gTime : TIME;

texture gTexture;
float gHScale = 1.0;
float gVScale = 1.0;
float gHOffset = 0.0;
float gVOffset = 0.0;
float gBrighten = 0;
float gRotAngle = 0;  
float gGrayScale = 0;
float gRedColor = 0;
float gGrnColor = 0;
float gBluColor = 0;
float gAlpha = 1.0;
float gScrRig = 0;
float gScrDow= 0;

sampler2D gTextureSampler = sampler_state
{
	Texture = ( gTexture );
	MinFilter = Linear;
	MagFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

struct VertexShaderInput
{
	float4 Position : POSITION0;
	float2 TextureCoordinate : TEXCOORD0;
};

struct PixelShaderInput
{
	float4 Position : POSITION0;
	float2 TextureCoordinate : TEXCOORD0;
};

PixelShaderInput VertexShaderFunction ( VertexShaderInput input )
{
	PixelShaderInput output;
	
	float4 worldPosition = mul ( input.Position, gWorld );
	float4 viewPosition  = mul ( worldPosition, gView );
	output.Position      = mul ( viewPosition, gProjection );
	
	output.TextureCoordinate = input.TextureCoordinate;
	return output;
}

float4 PixelShaderFunction ( PixelShaderInput output ) : COLOR0
{
	float2 textureCoordinate = output.TextureCoordinate;

	textureCoordinate[0] *= -0.2;
	textureCoordinate[1] *= 0.4;

	textureCoordinate[0] += -0.2;
	textureCoordinate[1] += 0.4;
	
	textureCoordinate[0] *= gHScale;
	textureCoordinate[1] *= gVScale;
	
	textureCoordinate[0] += gHOffset;
	textureCoordinate[1] += gVOffset;
	if(gScrRig!=0) 
	{ 
		float posU = fmod( gTime*gScrRig ,1 );   
		textureCoordinate[0] -= posU;
	}
	if(gScrDow!=0) 
	{ 			   
    		float posV = fmod( gTime*gScrDow ,1 );     
		textureCoordinate[1] -= posV;
	}
	
	float4 textureColor = tex2D ( gTextureSampler, textureCoordinate );
	
    	if(gRotAngle!=0)
	{
		float x = (textureCoordinate[0] * cos(gRotAngle)) + (textureCoordinate[1] * -sin(gRotAngle));
    		float y = (textureCoordinate[0] * sin(gRotAngle)) + (textureCoordinate[1] * cos(gRotAngle));				
		textureColor = tex2D ( gTextureSampler, float2(x,y));
	}

	if(gGrayScale!=0)
	{
	float averg=(textureColor.r + textureColor.g + textureColor.b)/3.0;
	textureColor=averg;
	}

    	textureColor.r=textureColor.r+gRedColor;
	textureColor.g=textureColor.g+gGrnColor;
	textureColor.b=textureColor.b+gBluColor;
	
	textureColor = textureColor+gBrighten;
	textureColor.a = gAlpha;
	return textureColor;
      
}

technique Replace
{
	pass P0
	{
        AlphaBlendEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		VertexShader = compile vs_1_1 VertexShaderFunction ( );
		PixelShader  = compile ps_2_0 PixelShaderFunction  ( );
	}
}