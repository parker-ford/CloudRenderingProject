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

                float noise = 0;

                float perlinNoise = perlinNoise_2D_fbm(i.uv, 0.8, 2, 7); //Perlin noise fBM with cellSize (initial frequency) of 4, 7 octaves, and Hurst Exponent of 0.8
                // perlinNoise = (perlinNoise + 1.0) / 2.0;    //Normalize to 0-1
                perlinNoise = abs(perlinNoise); //Billowy Perlin noise
         
                float worleyNoise = worleyNoise_2D_fbm(i.uv, 0.18 , 0.7, 8, 5); //Worley noise fBM with cellSize (initial frequency) of 4, 4 octaves, and Hurst Exponent of 0.9
                //float worleyNoise = worleyNoise_2D_fbm(i.uv, 0.9, 8, 1); //Worley noise fBM with cellSize (initial frequency) of 4, 4 octaves, and Hurst Exponent of 0.9
                worleyNoise = lerp(0.2, 1, worleyNoise * worleyNoise * worleyNoise); //Change noise domain to have a smoother transition between 0 and 1
                worleyNoise = 1 - worleyNoise;  //Invert noise
    
                noise = remap_f(perlinNoise, 0.0, 1.0, worleyNoise, 1.0); //Remap perlinNoise min value to be value of worleyNoise (PerlinWorley noise)

                return float4(noise, noise, noise, 1);
            }
            ENDCG
        }
    }
}
