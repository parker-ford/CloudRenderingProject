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
            uint _Frame;
            int _NumSamples;
            float _RayOffsetWeight;
            

            bool pointInsideCube(float3 p, float3 cubePosition, float cubeLength){
                float3 min = cubePosition - cubeLength / 2;
                float3 max = cubePosition + cubeLength / 2;
                float offset = 0.0001; // Small offset to reduce aliasing
                return p.x >= min.x - offset && p.x <= max.x + offset && p.y >= min.y - offset && p.y <= max.y + offset && p.z >= min.z - offset && p.z <= max.z + offset;
            }

            
            float3 getPixelRayInWorldLocal(float2 uv, float2 offset){

                //Shift uv by random amount
                // if(checkBit(_RaycastOptions, RANDOM_BIT)){
                //     uv = float2(uv.x + (1. / _ScreenParams.x) * random(), uv.y + (1. / _ScreenParams.y) * random());
                // }
                // uv += (offset / _ScreenParams.xy);

                offset *= _RayOffsetWeight;
                uv = float2(uv.x + (1. / _ScreenParams.x) * offset.x, uv.y + (1. / _ScreenParams.y) * offset.y);


                //Convert to screen space uv (-1 - 1)
                uv = remap_f2(uv, 0, 1, -1, 1);

                //Account for aspect ratio and FOV
                uv *= tan_d(_CameraFOV * 0.5);
                uv.x *= _CameraAspect;

                //Get ray
                //TODO: Test if the z component should be -1 or 1
                float3 ray = normalize(float3(uv.x, uv.y, 1.0));

                //Transform ray to world space
                float4 rayWorldHomog = mul(unity_CameraToWorld, float4(ray, 0.0));
                float3 rayWorld = normalize(rayWorldHomog.xyz);

                return rayWorld;

            }

            float calculateLuminance(float3 startPos, float blueNoiseSample){

                float noiseKernel[6 * 3] = {
                     .38051305,  .92453449, -.02111345,
                    -.50625799, -.03590792, -.86163418,
                    -.32509218, -.94557439,  .01428793,
                     .09026238, -.27376545,  .95755165,
                     .28128598,  .42443639, -.86065785,
                    -.16852403,  .14748697,  .97460106
                };

                float4 intScatterTrans = float4(0,0,0,1);
                float maxDistance = sqrt(_CubeLength * _CubeLength + _CubeLength * _CubeLength + _CubeLength * _CubeLength);
                float distPerStep = maxDistance / 6.0;
                float3 rayDir = normalize(-_LightDir);
                float lightRayDist = rayDir * distPerStep;
                float consSpread = length(lightRayDist);
                float totalDensity = 0;
                for(int i = 0; i < 6; i++){
                    float3 pos = startPos + (rayDir) * (float(i) + fract(blueNoiseSample + float(i) * GOLDEN_RATIO)) * (distPerStep);
                    

                    if(pointInsideCube(pos, _CubePosition, _CubeLength)){
                            float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                            
                            float extinction = tex3D(_Noise3D, samplePos).r;
                            totalDensity += extinction * distPerStep;

                            float clampedExtinction = max(extinction, 0.0001);
                            float transmittance = exp(-extinction * distPerStep * _LightAbsorption);

                            float luminance = 1;
                            float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;

                            intScatterTrans.rgb += intScatterTrans.a * integScatter;
                            intScatterTrans.a *= transmittance;
                    }
                }

                return _LightIntensity * float3(1,1,1) * intScatterTrans.a;
                //return _LightIntensity * float3(1,1,1) * exp(-totalDensity * _LightAbsorption);
                //return totalDensity;
            }




            fixed4 frag (v2f i) : SV_Target
            {
                float2 pixel = i.uv * float2(_ScreenParams.x / 256.0, _ScreenParams.y / 256.0) + 0.5;
                float2 offsetSample = tex2D(_BlueNoise, float2(_Frame * 2 % _NumSamples, (_Frame * 2 + 1) % _NumSamples) / 256.0);
                float4 blueNoiseSample = tex2D(_BlueNoise, pixel);


                // blueNoiseSample.r = fract(blueNoiseSample.r + float(_Frame % _NumSamples) * GOLDEN_RATIO);
                // blueNoiseSample.g = fract(blueNoiseSample.g + float(_Frame % _NumSamples) * GOLDEN_RATIO);
                blueNoiseSample.r = fract(blueNoiseSample.r + tex2D(_BlueNoise, float2(0, (float)_Frame/256.0)).r);
                blueNoiseSample.g = fract(blueNoiseSample.g + tex2D(_BlueNoise, float2(0, (float)_Frame/256.0)).g);
                // blueNoiseSample.r = blueNoiseSample.r + (1.0 / _ScreenParams.x * offsetSample.x);
                // blueNoiseSample.g = blueNoiseSample.g + (1.0 / _ScreenParams.y * offsetSample.y);

                blueNoiseSample.b = fract(blueNoiseSample.b + float(_Frame % _NumSamples) * GOLDEN_RATIO);


                float3 rayDir = getPixelRayInWorldLocal(i.uv, blueNoiseSample.rg);
                // float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();
                fixed4 mainCol = tex2D(_MainTex, i.uv);
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
                    [unroll(15)]
                    for(int j = 0; j < _MarchSteps; j++){
                        float3 pos = enterPoint + rayDir * ((float(j) + fract(blueNoiseSample.b + float(j) * GOLDEN_RATIO)) * (distPerStep));
                        if(pointInsideCube(pos, _CubePosition, _CubeLength)){         
                            pos = pos - _CubePosition;                  
                            float3 samplePos = remap_f3(pos, -_NoiseTiling, _NoiseTiling, 0, 1);
                            
                            float extinction = tex3D(_Noise3D, samplePos).r;
                            float clampedExtinction = max(extinction, 0.0001);
                            float transmittance = exp(-extinction * distPerStep * _Absorption);
                            float luminance = calculateLuminance(pos, blueNoiseSample.b) * extinction;

                            //Debug
                            totalLuminance += luminance;
                            totalDensity += tex3D(_Noise3D, samplePos).r * distPerStep;

                            float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;
                            intScatterTrans.rgb += intScatterTrans.a * integScatter;
                            intScatterTrans.a *= transmittance;


                        }

                        cameraRayDist += distPerStep;
                    }
                    density = 1 - exp(-totalDensity * _Absorption);
                    intScatterTrans.a = 1 - intScatterTrans.a;
                }

                return lerp(mainCol, intScatterTrans, intScatterTrans.a);
                //return lerp(mainCol, float4(1,1,1,1), intScatterTrans.a);
                // return lerp(mainCol, cubeCol, density);

            }
            ENDCG
        }
    }
}
