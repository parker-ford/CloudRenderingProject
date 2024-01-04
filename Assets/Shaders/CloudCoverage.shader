Shader "Parker/CloudCoverage"
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

            int _CoverageOption;

            float _NodeSize1;
            float _NodeSize2;
            float _NodeSize3;
            float _NodeWeight1;
            float _NodeWeight2;
            float _NodeWeight3;
            float _ZSlice;
            float _NoiseThreshold;
            float _NoiseMultiplier;
            float _NoiseShift;

            fixed4 coverage_perlin3(v2f i){
                float noise = 0;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), _NodeSize1) * _NodeWeight1;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), _NodeSize2) * _NodeWeight2;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), _NodeSize3) * _NodeWeight3;

                noise = (noise + _NoiseShift) * _NoiseMultiplier;

                float mask = step(_NoiseThreshold, noise);
                noise *= mask;
                
                return fixed4(noise, noise, noise, 1.0);
            }

            float coverage_perlin7(v2f i){
                float noise = 0;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), 1) * 1;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), 2) * 0.5;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), 4) * 0.25;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), 8) * 0.125;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), 16) * 0.0625;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), 32) * 0.03125;
                noise += perlinNoise_3D(float3(i.uv, _ZSlice), 64) * 0.015625;

                noise = abs(noise * 2 + 1);

                return fixed4(noise, noise, noise, 1.0);
            }




            fixed4 frag (v2f i) : SV_Target
            {
                if(_CoverageOption == 0){
                    return coverage_perlin3(i);
                }
                else if(_CoverageOption == 1){
                    return coverage_perlin7(i);
                }
                else{
                    return fixed4(0, 0, 0, 1);
                }
            }
            ENDCG
        }
    }
}
