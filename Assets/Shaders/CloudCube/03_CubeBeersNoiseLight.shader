Shader "CloudCube/03_CubeBeersLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #include "../ray.cginc"

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
            sampler3D _Noise3D;
            float3 _CubePosition;
            float _CubeLength;
            float _Absorption;
            float _NoiseTiling;
            float3 _LightPosition;
            int _LightSteps;

            bool pointInsideCube(float3 p, float3 cubePosition, float cubeLength){
                float3 min = cubePosition - cubeLength / 2;
                float3 max = cubePosition + cubeLength / 2;
                return p.x > min.x && p.x < max.x && p.y > min.y && p.y < max.y && p.z > min.z && p.z < max.z;
            }

            float marchTowardsLight(float3 p){
                float result = 0;
                float distPerStep = length(_CubePosition - _LightPosition) / 45;
                float3 rayDir = normalize(_LightPosition - p);
                [unroll(5)]
                for(int i = 1; i < 6; i++){
                    float3 pos = getMarchPosition(p, rayDir, 0, float(i), distPerStep);
                    if(pointInsideCube(pos, _CubePosition, _CubeLength)){
                        float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                        result += tex3D(_Noise3D, samplePos).r * distPerStep;
                    }
                }

                return exp(-result * _Absorption);
                // return result;
            }

            float4 cubeLight(v2f i){
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float4 cubeCol = float4(1,1,1,1);
                intersectData cubeIntersect = cubeIntersection(rayOrigin, rayDir, _CubePosition, _CubeLength);
                float density = 0;
                float lightDensity = 0;
                if(cubeIntersect.intersects){
                    float3 enterPoint = rayOrigin + rayDir * cubeIntersect.intersectPoints.x;
                    float3 exitPoint = rayOrigin + rayDir * cubeIntersect.intersectPoints.y;
                    float distance = length(exitPoint - enterPoint);
                    float maxDistance = sqrt(_CubeLength * _CubeLength + _CubeLength * _CubeLength + _CubeLength * _CubeLength);
                    float distPerStep = maxDistance / _MarchSteps;
                    float totalDensity = 0;
                    [unroll(5)]
                    for(int j = 0; j < 5; j++){
                        float3 pos = getMarchPosition(rayOrigin, rayDir, cubeIntersect.intersectPoints.x, float(j), distPerStep);
                        if(pointInsideCube(pos, _CubePosition, _CubeLength)){                           
                            float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                            totalDensity += tex3D(_Noise3D, samplePos).r * distPerStep;
                            lightDensity += marchTowardsLight(pos) * distPerStep;
                        }
                    }
                    density = 1 - exp(-totalDensity * _Absorption);
                }
                // float light = exp(-lightDensity * _Absorption);
                return float4(lightDensity,lightDensity,lightDensity,1);
                //return lerp(mainCol, cubeCol * lightDensity, density);
            }

            
            float4 getRayColor(v2f i){
                return cubeLight(i);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                setPixelID(i.uv);
                float4 color = 0;
                [unroll(2)]
                 for(int j = 0; j < _RayPerPixel; j++){
                    color += getRayColor(i);
                }

                return color / _RayPerPixel;
            }
            ENDCG
        }
    }
}
