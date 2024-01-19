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


            float perlinNoise_3D(float3 p, float cellSize, int x, int z){
                
                //Interval between cells
                float i = 1.0 / cellSize;

                //Cell that point lies in
                float3 id = floor(p * cellSize) / cellSize;

                //Coordinates of cell corners in 3D
                float3 c000 = float3(id.x, id.y, id.z);
                float3 c001 = float3(id.x, id.y, id.z + i);
                float3 c010 = float3(id.x, id.y + i, id.z);
                float3 c011 = float3(id.x, id.y + i, id.z + i);
                float3 c100 = float3(id.x + i, id.y, id.z);
                float3 c101 = float3(id.x + i, id.y, id.z + i);
                float3 c110 = float3(id.x + i, id.y + i, id.z);
                float3 c111 = float3(id.x + i, id.y + i, id.z + i);

                //Wrap around
                float3 c000_w = modulo(c000, float3(1,1,1));
                float3 c001_w = modulo(c001, float3(1,1,1));
                float3 c010_w = modulo(c010, float3(1,1,1));
                float3 c011_w = modulo(c011, float3(1,1,1));
                float3 c100_w = modulo(c100, float3(1,1,1));
                float3 c101_w = modulo(c101, float3(1,1,1));
                float3 c110_w = modulo(c110, float3(1,1,1));
                float3 c111_w = modulo(c111, float3(1,1,1));

                //Vectors from corners to point
                float3 v000 = remap_f3(p - c000, 0.0, i, 0.0, 1.0);
                float3 v001 = remap_f3(p - c001, 0.0, i, 0.0, 1.0);
                float3 v010 = remap_f3(p - c010, 0.0, i, 0.0, 1.0);
                float3 v011 = remap_f3(p - c011, 0.0, i, 0.0, 1.0);
                float3 v100 = remap_f3(p - c100, 0.0, i, 0.0, 1.0);
                float3 v101 = remap_f3(p - c101, 0.0, i, 0.0, 1.0);
                float3 v110 = remap_f3(p - c110, 0.0, i, 0.0, 1.0);
                float3 v111 = remap_f3(p - c111, 0.0, i, 0.0, 1.0);

                //Gradient vectors at each corner of cell
                float3 gv000 = gradientVector_3D(c000_w);
                float3 gv001 = gradientVector_3D(c001_w);
                float3 gv010 = gradientVector_3D(c010_w);
                float3 gv011 = gradientVector_3D(c011_w);
                float3 gv100 = gradientVector_3D(c100_w);
                float3 gv101 = gradientVector_3D(c101_w);
                float3 gv110 = gradientVector_3D(c110_w);
                float3 gv111 = gradientVector_3D(c111_w);

                //Fade values
                float fx = fade(fract(p.x * cellSize));
                float fy = fade(fract(p.y * cellSize));
                float fz = fade(fract(p.z * cellSize));

                //Dot products
                float dot000 = dot(v000, gv000);
                float dot001 = dot(v001, gv001);
                float dot010 = dot(v010, gv010);
                float dot011 = dot(v011, gv011);
                float dot100 = dot(v100, gv100);
                float dot101 = dot(v101, gv101);
                float dot110 = dot(v110, gv110);
                float dot111 = dot(v111, gv111);

                //Trilinear interpolation
                float n1 = lerp(dot000, dot100, fx);
                float n2 = lerp(dot010, dot110, fx);
                float n3 = lerp(dot001, dot101, fx);
                float n4 = lerp(dot011, dot111, fx);

                float n5 = lerp(n1, n2, fy);
                float n6 = lerp(n3, n4, fy);

                float n = lerp(n5, n6, fz);

                return n;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float noise = perlinNoise_3D(float3(i.uv, _Time.x), 8.0, 1, 2);
                //float noise = perlinNoise_2D(i.uv, 8.0);
                noise = (noise + 1.0) / 2.0;
                return float4(noise,noise,noise,1.0);
            }
            ENDCG
        }
    }
}
