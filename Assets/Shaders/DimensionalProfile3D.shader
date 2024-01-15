Shader "Parker/DimensionalProfile3D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #include "UnityCG.cginc"
            #include "ray.cginc"

            #define ATMOSPHERE_LOWER_BOUND 2500.0
            #define ATMOSPHERE_UPPER_BOUND 4200.0

            #define CLOUD_FREQUENCY 2048.0

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
            sampler3D _Cloud3DNoiseTexture;

            float cloudGradient(float h)
            {
                return smoothstep(0., .05, h) * smoothstep(1.25, .5, h);
            }

            float getHeightFract(float3 p){
                return (p.y - ATMOSPHERE_LOWER_BOUND) / (ATMOSPHERE_UPPER_BOUND - ATMOSPHERE_LOWER_BOUND);
            }

            float sampleCloudDensity(float3 pos, float y){
                float4 lowFreqNoise = tex3D(_Cloud3DNoiseTexture, pos);
                float lowFreqFBM = (lowFreqNoise.g * 0.625) + (lowFreqNoise.b * 0.25) + (lowFreqNoise.a * 0.125);
                float baseCloud = remap_f(lowFreqNoise.r, -(1.0 - lowFreqFBM), 1.0, 0.0, 1.0);
                baseCloud = remap_f(baseCloud, .85, 1., 0., 1.);
                baseCloud = saturate(baseCloud);
                return baseCloud;
            }

            float4 getRayColor(v2f i){

                fixed4 mainCol = tex2D(_MainTex, i.uv);
                float3 rayDir = getPixelRayInWorld(i.uv);
                float3 rayOrigin = getCameraOriginInWorld();

                float maxDist = 50000;

                intersectData planeIntersectLower = planeIntersection(rayOrigin, rayDir, float3(0,ATMOSPHERE_LOWER_BOUND,0), float3(0,-1,0));
                intersectData planeIntersectUpper = planeIntersection(rayOrigin, rayDir, float3(0,ATMOSPHERE_UPPER_BOUND,0), float3(0,-1,0));

                if(planeIntersectLower.intersects && planeIntersectUpper.intersects){
                    float3 startPos = rayOrigin + rayDir * planeIntersectLower.intersectPoints.x;
                    float3 endPos = rayOrigin + rayDir * planeIntersectUpper.intersectPoints.x;
                    float dist = length(endPos - startPos);
                    float distPerStep = dist / (float)_MarchSteps;
                    float density = 0;
                    float4 cloudCol = float4(1,1,1,1);
                    if(length(startPos) < maxDist){
                        [unroll(50)]
                        for(int j = 0; j < _MarchSteps; j++){
                            float3 pos = getMarchPosition(rayOrigin, rayDir, planeIntersectLower.intersectPoints.x , float(j), distPerStep);
                            float heightFract = getHeightFract(pos);
                            float3 samplePos;
                            samplePos.x = remap_f(pos.x, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                            samplePos.z = remap_f(pos.z, -CLOUD_FREQUENCY, CLOUD_FREQUENCY, 0.0, 1.0);
                            samplePos.y = heightFract;

                            density += sampleCloudDensity(samplePos, heightFract) * cloudGradient(heightFract);

                            
                        }
                        return lerp(mainCol,cloudCol, density);
                    }


                    // float3 samplePos;
                    // samplePos.x = remap_f(startPos.x, -512.0, 512.0, 0.0, 1.0);
                    // samplePos.z = remap_f(startPos.z, -512.0, 512.0, 0.0, 1.0);
                    // samplePos.y = startPos.y;

                    // float4 cloudCol = float4(1,1,1,1);
                    // float baseCloud = sampleCloudDensity(samplePos);

                    // float4 noiseSample = tex3D(_Cloud3DNoiseTexture, samplePos);
                    // float noiseFBM = (noiseSample.g * 0.625) + (noiseSample.b * 0.25) + (noiseSample.a * 0.125);
                    // float baseCloud = remap_f(noiseSample.r, noiseFBM - 1, 1.0, 0.0, 1.0);
                    // baseCloud = remap_f(baseCloud, .75, 1., 0., 1.);
                    // baseCloud = saturate(baseCloud);
                    // return float4(baseCloud, baseCloud, baseCloud, 1.0);
                    //return lerp(mainCol, cloudCol, baseCloud);


                    // float dist = length(endPos - startPos);
                    // float distPerStep = dist / (float)_MarchSteps;
                    // float cloudDensity = 0;
                    // if(length(startPos) < maxDist){
                    //     [unroll(50)]
                    //     for(int j = 0; j < _MarchSteps; j++){
                    //         float3 pos = getMarchPosition(rayOrigin, rayDir, planeIntersectLower.intersectPoints.x , float(j), distPerStep);

                    //         float3 samplePos;
                    //         samplePos.x = remap_f(pos.x, -512.0, 512.0, 0.0, 1.0);
                    //         samplePos.z = remap_f(pos.z, -512.0, 512.0, 0.0, 1.0);
                    //         samplePos.y = pos.y;

                    //         float density = sampleCloudDensity(samplePos);

                            
                    //         cloudDensity += density;
                    //     }
                    // }

                    // return lerp(mainCol, cloudCol, cloudDensity);
                }

                return mainCol;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                setPixelID(i.uv);
                float4 color = 0;
                 for(int j = 0; j < _RayPerPixel; j++){
                    color += getRayColor(i);
                }

                return color / (float)_RayPerPixel;
            }
            ENDCG
        }
    }
}
