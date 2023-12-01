Shader "Parker/CheckerTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {

                float checkerSize = 8;
                uint2 pixelPosition = uint2(uint(i.uv.x * _ScreenParams.x), uint(i.uv.y * _ScreenParams.y));
                uint2 checkerPosition = uint2(pixelPosition.x % (1.0/checkerSize * _ScreenParams.x * 2.0), pixelPosition.y % (1.0/checkerSize * _ScreenParams.y * 2.0));

                uint x = step(checkerPosition.x, 1.0/checkerSize * _ScreenParams.x);
                uint  y = step(checkerPosition.y, 1.0/checkerSize * _ScreenParams.y);
                float col = y^x;
                return float4(col,col,col,1);
            }
            ENDCG
        }
    }
}
