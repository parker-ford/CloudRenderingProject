Shader "Parker/DimensionalProfileLit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlueNoise ("Blue Noise", 2D) = "white" {}
        _Cloud3DNoiseTexture ("Cloud3DNoiseTexture", 3D) = "white" {}
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

            #define ATMOSPHERE_LOWER_BOUND 250.0
            #define ATMOSPHERE_UPPER_BOUND 300.0
            #define CLOUD_FREQUENCY 2048.0
            #define CLOUD_COVERAGE 0.5
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
            sampler3D _Cloud3DNoiseTexture;
            float _Absorption;
            float _NoiseTiling;
            float3 _LightDir;
            float _LightIntensity;
            float _LightAbsorption;

            float getHeightFract(float3 p){
                return (p.y - ATMOSPHERE_LOWER_BOUND) / (ATMOSPHERE_UPPER_BOUND - ATMOSPHERE_LOWER_BOUND);
            }

            float cloudGradient(float h){
                return smoothstep(0., .1, h) * smoothstep(1.25, .5, h);
            }

            float cloudBase(float3 pos, float y){
                float4 lowFreqNoise = tex3D(_Cloud3DNoiseTexture, pos);
                float lowFreqFBM = (lowFreqNoise.g * 0.625) + (lowFreqNoise.b * 0.25) + (lowFreqNoise.a * 0.125);
                float baseCloud = remap_f(lowFreqNoise.r, -(1.0 - lowFreqFBM), 1.0, 0.0, 1.0);
                baseCloud = remap_f(baseCloud, .85, 1., 0., 1.);
                baseCloud = saturate(baseCloud);
                return baseCloud;
            }

            float sampleCloudDensity(float3 pos, float y){
                float d = cloudBase(pos, y);
                //d = remap_f(d, CLOUD_COVERAGE, 1., 0, 1) * (CLOUD_COVERAGE);
                //d *= cloudGradient(y);
                return d;
            }

            float3 calculateLuminance(float3 startPos, float blueNoiseSample){
                float4 intScatterTrans = float4(0,0,0,1);
                float3 rayDir = normalize(-_LightDir);
                float distPerStep = 11;
                for(int step = 0; step < 6; step++){
                    float3 pos = startPos + (rayDir) * (float(step) * (distPerStep));
                    float3 samplePos;
                    samplePos.x = remap_f(pos.x, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                    samplePos.z = remap_f(pos.z, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                    samplePos.y = getHeightFract(pos);
                    float density = sampleCloudDensity(samplePos, pos.y);
                    float extinction = density;
                    float clampedExtinction = max(extinction, 0.0001);
                    float transmittance = exp(-extinction * distPerStep * _LightAbsorption);
                    float luminance = 1;
                    float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;
                    intScatterTrans.rgb += intScatterTrans.a * integScatter;
                    intScatterTrans.a *= transmittance;

                }

                return _LightIntensity * float3(1,1,1) * intScatterTrans.a;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();

                intersectData planeIntersectLower = planeIntersection(rayOrigin, rayDir, float3(0,ATMOSPHERE_LOWER_BOUND,0), float3(0,-1,0));
                intersectData planeIntersectUpper = planeIntersection(rayOrigin, rayDir, float3(0,ATMOSPHERE_UPPER_BOUND,0), float3(0,-1,0));

                if(planeIntersectLower.intersects && planeIntersectUpper.intersects){
                    float3 startPos = rayOrigin + rayDir * planeIntersectLower.intersectPoints.x;
                    float3 endPos = rayOrigin + rayDir * planeIntersectUpper.intersectPoints.x;
                    float dist = length(endPos - startPos);
                    float distPerStep = dist / (float)_MarchSteps;
                    float blueNoiseSample = tex2D(_BlueNoise, (i.uv + 0.5) * _CameraAspect * (_ScreenParams.x / 64.0)).x;
                    //blueNoiseSample = fract(blueNoiseSample + float(_Time.y % 32) * GOLDEN_RATIO);
                    float cameraRayDist = planeIntersectLower.intersectPoints.x;
                    cameraRayDist += blueNoiseSample * distPerStep;
                    float totalDensity = 0;
                    float4 intScatterTrans = float4(0,0,0,1);

                    for(int step = 0; step < 23; step++){
                        // float3 pos = startPos + rayDir * float(step) * distPerStep * blueNoiseSample;
                        //float3 pos = startPos + rayDir * float(step) * distPerStep;
                        float3 pos = rayOrigin + cameraRayDist * rayDir;
                        //float3 pos = startPos + rayDir * float(step) * distPerStep + rayDir * blueNoiseSample * distPerStep;

                        float3 samplePos;
                        samplePos.x = remap_f(pos.x, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                        samplePos.z = remap_f(pos.z, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                        samplePos.y = getHeightFract(pos);

                        float density = sampleCloudDensity(samplePos, pos.y);

                        if(density > 0.001){
                            float extinction = density;
                            float clampedExtinction = max(extinction, 0.0001);
                            float transmittance = exp(-extinction * distPerStep);
                            float luminance = calculateLuminance(pos, blueNoiseSample) * extinction;
                            float3 integScatter = (luminance - luminance * transmittance) / clampedExtinction;
                            intScatterTrans.rgb += intScatterTrans.a * integScatter;
                            intScatterTrans.a *= transmittance;
                        }

                        cameraRayDist += (distPerStep * blueNoiseSample);
                    }


                    return lerp(mainCol, intScatterTrans, intScatterTrans.a);
                    //return lerp(mainCol, float4(1,1,1,1), intScatterTrans.a);
                }

                return mainCol;
            }
            ENDCG
        }
    }
}
