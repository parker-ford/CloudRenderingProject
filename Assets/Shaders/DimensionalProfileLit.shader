Shader "Parker/DimensionalProfileLit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlueNoise ("Blue Noise", 2D) = "white" {}
        _Cloud3DNoiseTexture ("Cloud3DNoiseTexture", 3D) = "white" {}
        _CloudCoverage ("Cloud Coverage", 2D) = "white" {}
        _CloudType ("Cloud Type", 2D) = "white" {}
        _CloudGradient ("Cloud Gradient", 2D) = "white" {}
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

            #define ATMOSPHERE_LOWER_BOUND 1500.0
            #define ATMOSPHERE_UPPER_BOUND 5000.0
            #define CLOUD_FREQUENCY 2048.0
            #define CLOUD_COVERAGE 0.55
            #define GOLDEN_RATIO 1.61803398875
            #define EARTH_RADIUS 6378100.0
            #define MAX_VIEW_DISTANCE 50000.0

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


            //Shader Parameters
            sampler2D _MainTex;
            sampler3D _Cloud3DNoiseTexture;
            sampler2D _CloudCoverage;
            sampler2D _CloudType;
            sampler2D _CloudGradient;
            float _Absorption;
            float _NoiseTiling;
            float _WeatherTiling;
            float3 _LightDir;
            float _LightIntensity;
            float _LightAbsorption;

            //Anti Aliasing Parameters
            sampler2D _BlueNoise;
            uint _Frame;
            int _NumSamples;
            int _NoiseMode;

            //Raycast Parameters
            float _RayOffsetWeight;

            float raySphereIntersectLocal(float3 rayOrigin, float3 rayDirection, float radius){
                
                float b = 2. * dot(rayOrigin, rayDirection);
                float c = dot(rayOrigin, rayOrigin) - radius * radius;
                float d = sqrt(b * b - 4. * c);
                return (-b + d) * .5;
            }

            float3 getCameraOriginInWorldLocal(){
                //Transform Camera Position to world space;
                float3 camOrigin = float3(0,0,0);
                float4 camWorldHomog = mul(unity_CameraToWorld, float4(camOrigin, 1.0));
                float3 camWorld = camWorldHomog.xyz / camWorldHomog.w;

                //Put camera on earth surface
                camWorld.y += EARTH_RADIUS;

                return camWorld;
            }


            float getHeightFract(float3 p){
                p.y -= EARTH_RADIUS;
                return (p.y - ATMOSPHERE_LOWER_BOUND) / (ATMOSPHERE_UPPER_BOUND - ATMOSPHERE_LOWER_BOUND);
            }

            float getHeightFract2(float3 p){
                return (p.y - ATMOSPHERE_LOWER_BOUND) / (ATMOSPHERE_UPPER_BOUND - ATMOSPHERE_LOWER_BOUND);
            }

            float cloudGradient(float h){
                return smoothstep(0., .1, h) * smoothstep(1.25, .5, h);
            }

            // float cloudBase(vec3 p, float y)
            // {
            //     vec3 noise = textureLod(iChannel2, (p.xz - (WIND_DIR.xz * iTime * WIND_SPEED))
            //                             * CLOUD_BASE_FREQ, 0.).rgb;
            //     float n = y * y * noise.b + pow(1. - y, 12.);
            //     float cloud = remap01(noise.r - n, noise.g - 1., 1.);
            //     return cloud;
            // }

            // float cloudBase(float4 pos, float y){
            //     float4 lowFreqNoise = tex3Dlod(_Cloud3DNoiseTexture, pos);
            //     float n = 0.5 * 0.5 * lowFreqNoise.b + pow(1. - 0.5, 12.);
            //     float baseCloud = remap_f(lowFreqNoise.r - n, lowFreqNoise.g - 1., 1., 0., 1.);

            //     // float lowFreqFBM = (lowFreqNoise.g * 0.625) + (lowFreqNoise.b * 0.25) + (lowFreqNoise.a * 0.125);
            //     // float baseCloud = remap_f(lowFreqNoise.r, -(1.0 - lowFreqFBM), 1.0, 0.0, 1.0);

            //     //baseCloud = saturate(baseCloud);
            //     return baseCloud;
            // }

            // float sampleCloudDensity(float4 pos, float y){
            //     float d = cloudBase(pos, y);
            //     d = remap_f(d, CLOUD_COVERAGE, 1., 0, 1) * (CLOUD_COVERAGE);
            //     //d *= cloudGradient(y);
            //     return d;
            // }

            float getDenistyHeightGradientForPoint(float3 pos){
                float3 samplePos;
                samplePos.x = remap_f(pos.x, -_WeatherTiling, _WeatherTiling, 0.0, 1.0);
                samplePos.y = getHeightFract(pos.y);
                samplePos.z = remap_f(pos.z, -_WeatherTiling, _WeatherTiling, 0.0, 1.0);
                float cloudType = tex2D(_CloudType, samplePos.xz).r;

                float densityHeight = tex2D(_CloudGradient, float2(cloudType, samplePos.y) ).r;
                // samplePos
                return densityHeight;
            }

            float sampleCloudDensity(float startDist, float3 pos, float y){
                
                float4 samplePos;
                samplePos.x = remap_f(pos.x, -_NoiseTiling, _NoiseTiling, 0.0, 1.0);
                samplePos.z = remap_f(pos.z, -_NoiseTiling, _NoiseTiling, 0.0, 1.0);
                // samplePos.y = getHeightFract(pos); //This may need to change
                samplePos.y = samplePos.z = remap_f(pos.z, -_NoiseTiling, _NoiseTiling, 0.0, 1.0);

                //mip level
                samplePos.w = remap_f(startDist, ATMOSPHERE_LOWER_BOUND, MAX_VIEW_DISTANCE, 0, 6);


                float4 lowFreqNoise = tex3Dlod(_Cloud3DNoiseTexture, samplePos);
                float3 lowFreqFBM = (lowFreqNoise.g * 0.625) + (lowFreqNoise.b * 0.25) + (lowFreqNoise.a * 0.125);
                float base_cloud = remap_f(lowFreqNoise.r, -(1.0 - lowFreqFBM), 1.0, 0.0, 1.0);

                float densityHeight = getDenistyHeightGradientForPoint(pos);

                base_cloud *= densityHeight;

                return base_cloud;
            }

            float3 calculateLuminance(float4 startPos, float blueNoiseSample){
                return float3(1,1,1);
                // float4 intScatterTrans = float4(0,0,0,1);
                // float3 rayDir = normalize(-_LightDir);
                // float distPerStep = 11;
                // for(int step = 0; step < 6; step++){
                //     float3 pos = startPos + (rayDir) * (float(step) * (distPerStep));
                //     float4 samplePos;
                //     samplePos.x = remap_f(pos.x, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                //     samplePos.z = remap_f(pos.z, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                //     samplePos.y = getHeightFract(pos);
                //     //TODO: determine mip level
                //     samplePos.w = 0;

                //     float density = sampleCloudDensity(samplePos, pos.y);
                //     float extinction = density;
                //     float clampedExtinction = max(extinction, 0.0001);
                //     float transmittance = exp(-extinction * distPerStep * _LightAbsorption);
                //     float luminance = 1;
                //     float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;
                //     intScatterTrans.rgb += intScatterTrans.a * integScatter;
                //     intScatterTrans.a *= transmittance;

                // }

                // return _LightIntensity * float3(1,1,1) * intScatterTrans.a;
            }

            
            float updateNoiseSample(float noiseSample){
                if(_NoiseMode == 0){
                    return fract(noiseSample + float(_Frame % _NumSamples) * GOLDEN_RATIO);
                }
                else{
                    return fract(noiseSample + (float(_Frame % _NumSamples) / float(_NumSamples)));
                }
            }

            float4 getBlueNoiseSample(v2f i){
                float2 pixel = i.uv * float2(_ScreenParams.x / 256.0, _ScreenParams.y / 256.0) + 0.5;
                float4 blueNoiseSample = tex2D(_BlueNoise, pixel);
                blueNoiseSample.r = updateNoiseSample(blueNoiseSample.r);
                blueNoiseSample.g = updateNoiseSample(blueNoiseSample.g);
                blueNoiseSample.b = updateNoiseSample(blueNoiseSample.b);
                blueNoiseSample.a = updateNoiseSample(blueNoiseSample.a);
                return blueNoiseSample;
            }

            float3 getPixelRayInWorldLocal(float2 uv, float2 offset){

                //Offset UV
                //offset *= _RayOffsetWeight;
                offset *= 0;
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


            fixed4 frag (v2f i) : SV_Target
            {
                float4 blueNoiseSample = getBlueNoiseSample(i);
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float3 rayDir = getPixelRayInWorldLocal(i.uv, blueNoiseSample.rg);
                float3 rayOrigin = getCameraOriginInWorldLocal();

                

                float startDist = raySphereIntersectLocal(rayOrigin, rayDir, EARTH_RADIUS + ATMOSPHERE_LOWER_BOUND);
                float endDist = raySphereIntersectLocal(rayOrigin, rayDir, EARTH_RADIUS + ATMOSPHERE_UPPER_BOUND);

                // rayOrigin.y -= EARTH_RADIUS;   

                if(startDist < MAX_VIEW_DISTANCE){
                    float3 startPos = rayOrigin + rayDir * startDist;
                    float3 endPos = rayOrigin + rayDir * endDist;
                    float dist = length(endPos - startPos);
                    float distPerStep = dist / (float)_MarchSteps;
                    float4 intScatterTrans = float4(0,0,0,1);
                    float currRayDist = 0;

                    //Debug
                    float totalDensity = 0;
                    float totalTransmittance = 0;

                    [unroll(20)]
                    for(int step = 0; step < _MarchSteps; i++){
                        float3 pos = startPos + rayDir * currRayDist;

                        // float3 samplePos;
                        // samplePos.x = remap_f(pos.x, -_WeatherTiling, _WeatherTiling, 0.0, 1.0);
                        // samplePos.y = getHeightFract(pos.y);
                        // samplePos.z = remap_f(pos.z, -_WeatherTiling, _WeatherTiling, 0.0, 1.0);
                        // return tex2D(_CloudType, samplePos.xz);

                        float density = sampleCloudDensity(startDist, pos, pos.y);
                        
                        //if(density > 0.0001){
                            float extinction = density;
                            float clampedExtinction = max(extinction, 0.0001);

                            // float transmittance = exp(-extinction * distPerStep * _Absorption);
                            float transmittance = exp(-extinction * (1.0/_MarchSteps) * _Absorption);
                            totalTransmittance += transmittance;

                            //TODO: find mip level
                            float luminance = calculateLuminance(float4(pos,0), blueNoiseSample) * extinction;
                            float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;
                            intScatterTrans.rgb += intScatterTrans.a * integScatter;
                            intScatterTrans.a *= transmittance;
                        //}


                        //currRayDist = float(step) * (distPerStep + blueNoiseSample.b);
                        currRayDist = distPerStep * (float(step) + blueNoiseSample.b);
                        updateNoiseSample(blueNoiseSample.b);
                    }
                    intScatterTrans.a = 1 - intScatterTrans.a;
                    return lerp(mainCol, float4(1,1,1,1), intScatterTrans.a);
                    //return lerp(mainCol, intScatterTrans, intScatterTrans.a);
                   //return lerp(mainCol, float4(totalTransmittance * _Absorption,0,0,1), intScatterTrans.a);
                }


                
                // intersectData planeIntersectLower = planeIntersection(rayOrigin, rayDir, float3(0,EARTH_RADIUS + ATMOSPHERE_LOWER_BOUND,0), float3(0,-1,0));
                // intersectData planeIntersectUpper = planeIntersection(rayOrigin, rayDir, float3(0,EARTH_RADIUS + ATMOSPHERE_UPPER_BOUND,0), float3(0,-1,0));

                // if(planeIntersectLower.intersects && planeIntersectUpper.intersects){
                //     float3 startPos = rayOrigin + rayDir * planeIntersectLower.intersectPoints.x;
                //     float3 endPos = rayOrigin + rayDir * planeIntersectUpper.intersectPoints.x;
                //     float dist = length(endPos - startPos);
                //     float distPerStep = dist / (float)_MarchSteps;
                //     float totalDensity = 0;
                //     float4 intScatterTrans = float4(0,0,0,1);
                //     float offset = 0;

                //     [unroll(20)]
                //     for(int step = 0; step < _MarchSteps; step++){
                //         float3 pos = rayOrigin + rayDir * (planeIntersectLower.intersectPoints.x + offset);
                //         float4 samplePos;
                //         samplePos.x = remap_f(pos.x, -_NoiseTiling, _NoiseTiling, 0.0, 1.0);
                //         samplePos.z = remap_f(pos.z, -_NoiseTiling, _NoiseTiling, 0.0, 1.0);
                //         samplePos.y = getHeightFract2(pos);
                //         samplePos.w = remap_f(planeIntersectLower.intersectPoints.x, ATMOSPHERE_LOWER_BOUND, MAX_VIEW_DISTANCE, 0, 6);


                //         //return tex3D(_Cloud3DNoiseTexture, samplePos);

                //         float density = sampleCloudDensity(samplePos, pos.y);

                //     //     float density = sampleCloudDensity(samplePos, pos.y);

                //         //if(density > 0.001){
                //             float extinction = density;
                //             float clampedExtinction = max(extinction, 0.0001);
                //             float transmittance = exp(-clampedExtinction * distPerStep * _Absorption);
                //             float luminance = calculateLuminance(float4(pos,0), blueNoiseSample) * extinction;
                //             float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;
                //             intScatterTrans.rgb += intScatterTrans.a * integScatter;
                //             intScatterTrans.a *= transmittance;
                //         //\}

                //         offset = distPerStep * (float(step) + blueNoiseSample.b);
                //         updateNoiseSample(blueNoiseSample.b);
                //     }
                //     return lerp(mainCol, float4(1,1,1,1), intScatterTrans.a);
                // }

                return mainCol;
            }
            ENDCG
        }
    }
}
