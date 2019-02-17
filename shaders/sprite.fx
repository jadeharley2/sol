float4x4 MVP;

Texture2D tSpritesheet;  
Texture2D tSpritesheetFont;  
float4 Color = float4(1,1,1,1); 
bool useClip = false;

SamplerState sView
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};


struct VS_IN
{
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
}; 
struct I_IN
{
	float4x4 transform : WORLD; 
	float4 tint : COLOR0;
	float4 tcrd : TEXCOORD1;
};
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
	float4 tint : TEXCOORD1;
};
  
PS_IN VS( VS_IN input,I_IN inst ) 
{
	PS_IN output = (PS_IN)0; 
	output.pos = mul(mul(input.pos,transpose(inst.transform)),transpose(MVP));
	//output.pos =  mul(input.pos,transpose(inst.transform));
	output.tcrd = input.tcrd * inst.tcrd.zw + inst.tcrd.xy;
	output.tint = inst.tint*Color;
	return output;
} 
float4 PS( PS_IN input ) : SV_Target
{ 
	float4 pDiffuse;
	if(input.tcrd.x>=0)
	{
		pDiffuse = tSpritesheet.Sample(sView, input.tcrd);
		if(useClip)
		{
			pDiffuse.a = (pDiffuse.r+pDiffuse.g+pDiffuse.b)/3;//clip(pDiffuse.r-0.2);
		}
	}
	else
	{
		pDiffuse = tSpritesheetFont.Sample(sView, -input.tcrd);
		pDiffuse.a = (pDiffuse.r+pDiffuse.g+pDiffuse.b)/3;
	}
	
	return   pDiffuse * input.tint;
}

technique10 Render
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}