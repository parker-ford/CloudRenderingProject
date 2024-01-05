Shader "Parker/PerlinWorley"
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
            #include "./noise.cginc"

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

                float cellSize = 10;

                float fbm_noise = 0;

                for(int i = 1; i <= 2; i++){

                }
                float noise = worleyNoise_2D(i.uv, cellSize, (1.0 / cellSize) / 1.2);
                noise = lerp(0.5, 1, noise * noise * noise);
                noise = 1 - noise;


                return float4(noise, noise, noise, 1);
            }
            ENDCG
        }
    }
}
