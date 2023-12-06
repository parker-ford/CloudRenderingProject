Shader "Parker/CloudTypeGradient"
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
            #include "shaderUtils.cginc"
            #include "noise.cginc"

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


                float hieghtNoise = 1.0 + perlinNoise_2D(float2(i.uv.x, i.uv.x), 4) * .4;

                float col = lerp(1,0, ((i.uv.y - 0.1)  * hieghtNoise  / i.uv.x));

                col = 0.9 * col + 0.1 * perlinNoise_2D(i.uv, 4);

                return fixed4(col, col, col, 1.0);
            }
            ENDCG
        }
    }
}
