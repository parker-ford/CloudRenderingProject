Shader "Parker/BlueNoiseTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlueNoise ("Blue Noise", 2D) = "white" {}
        _TestTexture ("Test Texture", 2D) = "white" {}
        _Noise3D ("Noise 3D", 3D) = "white" {}
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
            #include "ray.cginc"

            #define GOLDEN_RATIO 1.61803398875

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
            sampler2D _BlueNoise;
            sampler2D _TestTexture;
            sampler3D _Noise3D;
            float3 _CubePosition;
            float _CubeLength;
            float _Absorption;
            float _NoiseTiling;

            bool pointInsideCube(float3 p, float3 cubePosition, float cubeLength){
                float3 min = cubePosition - cubeLength / 2;
                float3 max = cubePosition + cubeLength / 2;
                float offset = 0.0001; // Small offset to reduce aliasing
                return p.x >= min.x - offset && p.x <= max.x + offset && p.y >= min.y - offset && p.y <= max.y + offset && p.z >= min.z - offset && p.z <= max.z + offset;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float blueNoiseSample = tex2D(_BlueNoise, (i.uv + 0.5) * _CameraAspect * (_ScreenParams.x / 64.0)).x;
                //blueNoiseSample = fract(blueNoiseSample + float(_Time.y % 32) * GOLDEN_RATIO);


                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();

                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float4 cubeCol = float4(0,1,0,1);
                intersectData cubeIntersect = cubeIntersection(rayOrigin, rayDir, _CubePosition, _CubeLength);
                float density = 0;
                if(cubeIntersect.intersects){
                    float3 enterPoint = rayOrigin + rayDir * (cubeIntersect.intersectPoints.x);
                    float3 exitPoint = rayOrigin + rayDir * (cubeIntersect.intersectPoints.y);
                    float distance = length(exitPoint - enterPoint);
                    float maxDistance = sqrt(_CubeLength * _CubeLength + _CubeLength * _CubeLength + _CubeLength * _CubeLength);
                    float distPerStep = maxDistance / _MarchSteps;
                    float totalDensity = 0;
                    [unroll(50)]
                    for(int j = 0; j < _MarchSteps; j++){
                        // float3 pos = getMarchPosition(rayOrigin, rayDir, cubeIntersect.intersectPoints.x, float(j), distPerStep);
                        float3 pos = enterPoint + rayDir * (float(j) * (distPerStep * blueNoiseSample));
                        if(pointInsideCube(pos, _CubePosition, _CubeLength)){         
                            pos = pos - _CubePosition;                  
                            float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                            totalDensity += tex3D(_Noise3D, samplePos).r * distPerStep;
                        }
                    }
                    density = 1 - exp(-totalDensity * _Absorption);
                }

                return lerp(mainCol, cubeCol, density);

            }
            ENDCG
        }
    }
}
