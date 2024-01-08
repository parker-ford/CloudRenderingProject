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

            float fbm_worley(v2f i){
                float cellSize = 10;

                float noise = 0;
                noise += worleyNoise_2D(i.uv, cellSize, (1.0 / cellSize) / 1.2);

                cellSize += 10;
                noise += worleyNoise_2D(i.uv, cellSize) * 0.25;

                cellSize += 20;
                noise += worleyNoise_2D(i.uv, cellSize) * 0.125;

                cellSize += 40;
                noise += worleyNoise_2D(i.uv, cellSize) * 0.075;


                noise = lerp(0.5, 1, noise * noise * noise);
                noise = 1 - noise;

                return noise;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float noise = 0;

                float perlinNoise = perlinNoise_2D_fbm(i.uv, 0.8, 4, 7); //Perlin noise fBM with cellSize (initial frequency) of 4, 7 octaves, and Hurst Exponent of 0.8
                perlinNoise = (perlinNoise + 1.0) / 2.0;    //Normalize to 0-1
                perlinNoise = abs(perlinNoise * 2.0 - 1.0); //Billowy Perlin noise
         
                float worleyNoise = worleyNoise_2D_fbm(i.uv, .25 * 1.2, 0.9, 4, 4);
                worleyNoise = lerp(0.5, 1, worleyNoise * worleyNoise * worleyNoise);
                worleyNoise = 1 - worleyNoise;
                return float4(worleyNoise, worleyNoise, worleyNoise, 1);


                noise = remap_f(perlinNoise, 0.0, 1.0, worleyNoise, 1.0);

                // noise = worleyNoise;


                // return float4(noise, perlinNoise, worleyNoise, 1.0);
                return float4(noise, noise, noise, 1);
                // return float4(noise, noise, perlinNoise, 1);
            }
            ENDCG
        }
    }
}
