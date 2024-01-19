Shader "Parker/PerlinNoise"
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

            float perlinNoise_2D(float2 p, float cellSize, int x) {
    
                //Interval between cells
                float i = 1.0 / cellSize;

                //Cell that this pixel lies in
                float2 id = floor(p * cellSize) / cellSize;

                //Cordinates of cell corners
                float2 tl = float2(id.x, id.y);
                float2 tr = float2(id.x + i, id.y);;
                float2 bl = float2(id.x, id.y + i);
                float2 br = float2(id.x + i, id.y + i);

                //Wrap around
                tl = modulo(tl, float2(1,1));
                tr = modulo(tr, float2(1,1));
                bl = modulo(bl, float2(1,1));
                br = modulo(br, float2(1,1));

                //Vector from corners of cell to point
                float2 v_tl = remap_f2(float2(p.x - id.x, p.y - id.y), 0.0, i, 0.0, 1.0);
                float2 v_tr = remap_f2(float2(p.x - id.x - i, p.y - id.y), 0.0, i, 0.0, 1.0);
                float2 v_bl = remap_f2(float2(p.x - id.x, p.y - id.y - i), 0.0, i, 0.0, 1.0);
                float2 v_br = remap_f2(float2(p.x - id.x - i, p.y - id.y - i), 0.0, i, 0.0, 1.0);

                //Gradient vectors at each cell corner
                float2 gv_tl = gradientVector_2D(tl);
                float2 gv_tr = gradientVector_2D(tr);
                float2 gv_bl = gradientVector_2D(bl);
                float2 gv_br = gradientVector_2D(br);

                //Fade value
                float fx = fade((p.x * cellSize) - floor(p.x * cellSize));
                float fy = fade((p.y * cellSize) - floor(p.y * cellSize));

                //Dot product of corner gradient and vector to point
                float dot_tl = dot(v_tl, gv_tl);
                float dot_tr = dot(v_tr, gv_tr);
                float dot_bl = dot(v_bl, gv_bl);
                float dot_br = dot(v_br, gv_br);

                //Bilinear interpolation
                float n_t = lerp(dot_tl, dot_tr, fx);
                float n_b = lerp(dot_bl, dot_br, fx);
                float n = lerp(n_t, n_b, fy);

                return n;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float noise = perlinNoise_2D(i.uv, 8.0, 1);
                noise = (noise + 1.0) / 2.0;
                return float4(noise,noise,noise,1.0);
            }
            ENDCG
        }
    }
}
