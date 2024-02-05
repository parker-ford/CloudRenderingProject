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
            float3 _LightDir;
            float _LightIntensity;
            float _LightAbsorption;

            bool pointInsideCube(float3 p, float3 cubePosition, float cubeLength){
                float3 min = cubePosition - cubeLength / 2;
                float3 max = cubePosition + cubeLength / 2;
                float offset = 0.0001; // Small offset to reduce aliasing
                return p.x >= min.x - offset && p.x <= max.x + offset && p.y >= min.y - offset && p.y <= max.y + offset && p.z >= min.z - offset && p.z <= max.z + offset;
            }

            float calculateLuminance(float3 startPos, float blueNoiseSample){

                float4 intScatterTrans = float4(0,0,0,1);


                float maxDistance = sqrt(_CubeLength * _CubeLength + _CubeLength * _CubeLength + _CubeLength * _CubeLength);
                float distPerStep = maxDistance / 6.0 * 0.7;
                //float distPerStep = 0.25;
                float totalDensity = 0;
                float3 rayDir = normalize(-_LightDir);
                for(int i = 0; i < 6; i++){
                    float3 pos = startPos + (rayDir) * (float(i) * (distPerStep));
                    if(pointInsideCube(pos, _CubePosition, _CubeLength)){
                            float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                            
                            float extinction = tex3D(_Noise3D, samplePos).r;
                            totalDensity += extinction * distPerStep;

                            // float clampedExtinction = max(extinction, 0.0001);
                            // float transmittance = exp(-extinction * distPerStep * _LightAbsorption);

                            // float luminance = 1;
                            // float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;

                            // intScatterTrans.rgb += intScatterTrans.a * integScatter;
                            // intScatterTrans.a *= transmittance;
                    }
                }

                // return _LightIntensity * float3(1,1,1) * intScatterTrans.a;
                return _LightIntensity * float3(1,1,1) * exp(-totalDensity * _LightAbsorption);
                //return totalDensity;
            }



            fixed4 frag (v2f i) : SV_Target
            {
                float blueNoiseSample = tex2D(_BlueNoise, (i.uv + 0.5) * _CameraAspect * (_ScreenParams.x / 64.0)).x;
                // blueNoiseSample = fract(blueNoiseSample + float(_Time.y % 32) * GOLDEN_RATIO);


                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();

                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float4 cubeCol = float4(0,1,0,1);
                intersectData cubeIntersect = cubeIntersection(rayOrigin, rayDir, _CubePosition, _CubeLength);
                float density = 0;
                float4 intScatterTrans = float4(0,0,0,0);
                float totalLuminance = 0;
                if(cubeIntersect.intersects){
                    float3 enterPoint = rayOrigin + rayDir * (cubeIntersect.intersectPoints.x);
                    float maxDistance = sqrt(_CubeLength * _CubeLength + _CubeLength * _CubeLength + _CubeLength * _CubeLength);
                    float distPerStep = maxDistance / _MarchSteps;
                    float cameraRayDist = (cubeIntersect.intersectPoints.x) += blueNoiseSample * distPerStep;

                    float totalDensity = 0;
                    intScatterTrans = float4(0,0,0,1);
                    [unroll(20)]
                    for(int j = 0; j < _MarchSteps; j++){
                        float3 pos = enterPoint + rayDir * (float(j) * (distPerStep * blueNoiseSample));
                        //float3 pos = rayOrigin + rayDir * cameraRayDist;
                        //float3 pos = enterPoint + rayDir * (float(j) * distPerStep);
                        if(pointInsideCube(pos, _CubePosition, _CubeLength)){         
                            pos = pos - _CubePosition;                  
                            float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                            

                            float extinction = tex3D(_Noise3D, samplePos).r;
                            float clampedExtinction = max(extinction, 0.0001);
                            float transmittance = exp(-extinction * distPerStep);

                            float luminance = calculateLuminance(pos, blueNoiseSample) * extinction;

                            //Debug
                            totalLuminance += luminance;

                            float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;

                            intScatterTrans.rgb += intScatterTrans.a * integScatter;
                            intScatterTrans.a *= transmittance;


                            totalDensity += tex3D(_Noise3D, samplePos).r * distPerStep;
                        }

                        cameraRayDist += distPerStep;
                    }
                    density = 1 - exp(-totalDensity * _Absorption);
                    intScatterTrans.a = 1 - intScatterTrans.a;
                }

                return lerp(mainCol, intScatterTrans, intScatterTrans.a);
                // return lerp(mainCol, cubeCol, density);

            }
            ENDCG
        }
    }
}
